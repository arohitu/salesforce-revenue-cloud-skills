#!/usr/bin/env python3
"""
Revenue Cloud dev-org cleanup helper.

Runs a dependency-safe delete sequence for core Revenue Cloud catalog,
transaction, and usage-management records, then emits a machine-readable
summary that an agent can quote back to the user.
"""

from __future__ import annotations

import argparse
import csv
import json
import subprocess
import sys
import tempfile
from pathlib import Path


STATUS_TRANSITIONS = [
    ("Order", "Status", "Draft"),
    ("UsageResourceBillingPolicy", "Status", "Draft"),
    ("UsageResource", "Status", "Draft"),
    ("ProductUsageGrant", "Status", "Draft"),
    ("ProductUsageResource", "Status", "Inactive"),
]

DELETE_SEQUENCE = [
    "QuoteLineItem",
    "OpportunityLineItem",
    "Quote",
    "Opportunity",
    "ProductRelComponentOverride",
    "ProductComponentGrpOverride",
    "ProductRelatedComponent",
    "ProductComponentGroup",
    "AttributeBasedAdjRule",
    "ProductAttributeDefinition",
    "ProductQualification",
    "ProductDisqualification",
    "ProductCategoryProduct",
    "PriceAdjustmentTier",
    "PriceAdjustmentSchedule",
    "PriceBookEntryDerivedPrice",
    "RateCardEntry",
    "UsageEntitlementEntry",
    "ProductUsageResourcePolicy",
    "UsageResourcePolicy",
    "ProductUsageGrant",
    "ProductUsageResource",
    "UsageResourceBillingPolicy",
    "UsageResource",
    "UsageEntitlementBucket",
    "TransactionUsageEntitlement",
    "UsageEntitlementAccount",
    "AssetActionSource",
    "OrderItem",
    "Order",
    "PricebookEntry",
    "ProductSellingModelOption",
    "Product2",
]

OPTIONAL_DELETE_SEQUENCE = ["Account"]

BEST_EFFORT_OBJECTS = {"AssetActionSource", "Account"}


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description=(
            "Clean a Salesforce Revenue Cloud development org by deleting "
            "Product2 records and dependent Revenue Cloud data in "
            "dependency-safe order."
        )
    )
    parser.add_argument(
        "--target-org",
        required=True,
        help="Salesforce CLI alias or username for the target org.",
    )
    parser.add_argument(
        "--include-accounts",
        action="store_true",
        help="Also attempt Account deletion after product cleanup.",
    )
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="Preview counts and planned actions without changing org data.",
    )
    parser.add_argument(
        "--wait-minutes",
        type=int,
        default=20,
        help="Minutes to wait for each Bulk API delete job. Default: 20.",
    )
    parser.add_argument(
        "--max-passes",
        type=int,
        default=6,
        help="Maximum cleanup passes for dependency chains. Default: 6.",
    )
    parser.add_argument(
        "--summary-output",
        help="Optional path to write the JSON summary.",
    )
    return parser.parse_args()


def run_sf_json(args: list[str], check: bool = False) -> tuple[int, dict | None, str]:
    cmd = ["sf", *args, "--json"]
    result = subprocess.run(cmd, capture_output=True, text=True)
    payload = None
    try:
        payload = json.loads(result.stdout) if result.stdout.strip() else None
    except json.JSONDecodeError:
        payload = None
    if check and result.returncode != 0:
        raise RuntimeError(result.stderr.strip() or result.stdout.strip() or "sf command failed")
    message = result.stderr.strip() or result.stdout.strip()
    return result.returncode, payload, message


def run_sf(args: list[str]) -> tuple[int, str]:
    cmd = ["sf", *args]
    result = subprocess.run(cmd, capture_output=True, text=True)
    return result.returncode, (result.stderr.strip() or result.stdout.strip())


class CleanupRunner:
    def __init__(self, target_org: str, dry_run: bool, include_accounts: bool, wait_minutes: int):
        self.target_org = target_org
        self.dry_run = dry_run
        self.include_accounts = include_accounts
        self.wait_minutes = wait_minutes
        self.object_exists_cache: dict[str, bool] = {}
        self.summary: dict = {
            "target_org": target_org,
            "dry_run": dry_run,
            "include_accounts": include_accounts,
            "delete_sequence": DELETE_SEQUENCE + (OPTIONAL_DELETE_SEQUENCE if include_accounts else []),
            "status_transitions": [
                {"object": obj, "field": field, "target_value": target}
                for obj, field, target in STATUS_TRANSITIONS
            ],
            "status_update_counts": {},
            "planned_status_update_counts": {},
            "deleted_counts": {},
            "planned_delete_counts": {},
            "remaining_counts": {},
            "passes": [],
            "notes": [],
        }

    def object_exists(self, object_name: str) -> bool:
        if object_name in self.object_exists_cache:
            return self.object_exists_cache[object_name]
        code, _, _ = run_sf_json(
            ["sobject", "describe", "--target-org", self.target_org, "--sobject", object_name]
        )
        exists = code == 0
        self.object_exists_cache[object_name] = exists
        return exists

    def query_records(self, object_name: str, fields: list[str]) -> list[dict]:
        if not self.object_exists(object_name):
            return []
        soql = f"SELECT {', '.join(fields)} FROM {object_name}"
        code, payload, _ = run_sf_json(
            ["data", "query", "--target-org", self.target_org, "--query", soql]
        )
        if code != 0 or not payload:
            return []
        return payload.get("result", {}).get("records", [])

    def query_ids(self, object_name: str) -> list[str]:
        return [record["Id"] for record in self.query_records(object_name, ["Id"]) if "Id" in record]

    def write_id_csv(self, ids: list[str], directory: Path, object_name: str) -> Path:
        csv_path = directory / f"{object_name}.csv"
        with csv_path.open("w", newline="") as handle:
            writer = csv.writer(handle, lineterminator="\n")
            writer.writerow(["Id"])
            for record_id in ids:
                writer.writerow([record_id])
        return csv_path

    def update_status(self, object_name: str, field_name: str, target_value: str) -> int:
        records = self.query_records(object_name, ["Id", field_name])
        if not records:
            return 0
        changed = 0
        for record in records:
            record_id = record.get("Id")
            current_value = record.get(field_name)
            if not record_id or current_value == target_value:
                continue
            if self.dry_run:
                changed += 1
                continue
            code, _ = run_sf(
                [
                    "data",
                    "update",
                    "record",
                    "--target-org",
                    self.target_org,
                    "--sobject",
                    object_name,
                    "--record-id",
                    record_id,
                    "--values",
                    f"{field_name}={target_value}",
                ]
            )
            if code == 0:
                changed += 1
        if changed:
            key = f"{object_name}.{field_name}->{target_value}"
            bucket = "planned_status_update_counts" if self.dry_run else "status_update_counts"
            self.summary[bucket][key] = self.summary[bucket].get(key, 0) + changed
        return changed

    def delete_object(self, object_name: str, workdir: Path) -> dict:
        before_ids = self.query_ids(object_name)
        before_count = len(before_ids)
        result = {
            "object": object_name,
            "before": before_count,
            "deleted": 0,
            "remaining": before_count,
            "attempted": before_count,
            "message": "",
        }
        if before_count == 0:
            return result
        if self.dry_run:
            result["deleted"] = before_count
            result["remaining"] = before_count
            self.summary["planned_delete_counts"][object_name] = (
                self.summary["planned_delete_counts"].get(object_name, 0) + before_count
            )
            return result

        csv_path = self.write_id_csv(before_ids, workdir, object_name)
        code, message = run_sf(
            [
                "data",
                "delete",
                "bulk",
                "--target-org",
                self.target_org,
                "--sobject",
                object_name,
                "--file",
                str(csv_path),
                "--wait",
                str(self.wait_minutes),
                "--line-ending",
                "LF",
            ]
        )
        after_ids = self.query_ids(object_name)
        after_count = len(after_ids)
        result["deleted"] = max(before_count - after_count, 0)
        result["remaining"] = after_count
        result["message"] = message if code != 0 else ""
        if result["deleted"]:
            self.summary["deleted_counts"][object_name] = (
                self.summary["deleted_counts"].get(object_name, 0) + result["deleted"]
            )
        return result

    def run(self, max_passes: int) -> dict:
        delete_sequence = list(DELETE_SEQUENCE)
        if self.include_accounts:
            delete_sequence.extend(OPTIONAL_DELETE_SEQUENCE)

        with tempfile.TemporaryDirectory(prefix="rc-dev-org-cleanup-") as temp_dir:
            workdir = Path(temp_dir)
            for pass_number in range(1, max_passes + 1):
                pass_summary = {
                    "pass": pass_number,
                    "status_updates": {},
                    "deletes": [],
                }
                progress_made = False

                for object_name, field_name, target_value in STATUS_TRANSITIONS:
                    changed = self.update_status(object_name, field_name, target_value)
                    if changed:
                        progress_made = True
                        pass_summary["status_updates"][
                            f"{object_name}.{field_name}->{target_value}"
                        ] = changed

                for object_name in delete_sequence:
                    result = self.delete_object(object_name, workdir)
                    if result["before"] or result["deleted"] or result["remaining"]:
                        pass_summary["deletes"].append(result)
                    if result["deleted"]:
                        progress_made = True

                self.summary["passes"].append(pass_summary)

                remaining_products = len(self.query_ids("Product2"))
                if remaining_products == 0 and not progress_made:
                    break
                if not progress_made:
                    self.summary["notes"].append(
                        "Stopped because a full pass made no further progress."
                    )
                    break

        self.finalize(delete_sequence)
        return self.summary

    def finalize(self, delete_sequence: list[str]) -> None:
        tracked_objects = set(delete_sequence)
        tracked_objects.update(obj for obj, _, _ in STATUS_TRANSITIONS)
        tracked_objects.update(BEST_EFFORT_OBJECTS)

        for object_name in sorted(tracked_objects):
            self.summary["remaining_counts"][object_name] = len(self.query_ids(object_name))

        deleted_counts = self.summary["deleted_counts"]
        self.summary["totals"] = {
            "objects_deleted_from": sum(1 for count in deleted_counts.values() if count > 0),
            "records_deleted": sum(deleted_counts.values()),
            "status_changes_applied": sum(self.summary["status_update_counts"].values()),
        }
        if self.dry_run:
            planned_delete_counts = self.summary["planned_delete_counts"]
            self.summary["totals"]["objects_planned_for_delete"] = sum(
                1 for count in planned_delete_counts.values() if count > 0
            )
            self.summary["totals"]["records_planned_for_delete"] = sum(
                planned_delete_counts.values()
            )
            self.summary["totals"]["status_changes_planned"] = sum(
                self.summary["planned_status_update_counts"].values()
            )

        if self.summary["remaining_counts"].get("AssetActionSource", 0):
            self.summary["notes"].append(
                "AssetActionSource often remains because some orgs do not grant delete access."
            )
        if self.summary["remaining_counts"].get("Account", 0):
            self.summary["notes"].append(
                "Accounts can remain when portal users, cases, or entitlements protect them."
            )
        if self.summary["remaining_counts"].get("Product2", 0) == 0:
            self.summary["notes"].append("Product cleanup reached Product2 = 0.")


def main() -> int:
    args = parse_args()
    runner = CleanupRunner(
        target_org=args.target_org,
        dry_run=args.dry_run,
        include_accounts=args.include_accounts,
        wait_minutes=args.wait_minutes,
    )
    summary = runner.run(max_passes=args.max_passes)

    output = json.dumps(summary, indent=2, sort_keys=True)
    if args.summary_output:
        output_path = Path(args.summary_output)
        output_path.write_text(output + "\n")
    print(output)
    return 0


if __name__ == "__main__":
    sys.exit(main())
