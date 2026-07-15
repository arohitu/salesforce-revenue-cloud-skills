---
name: revenue-cloud-dev-org-cleanup
description: Use this skill when the user wants to clean or reset a Salesforce Revenue Cloud development org by deleting Product2 records and the dependent quotes, opportunities, orders, price book entries, usage records, and related catalog data in dependency-safe order. Use it for sandbox/dev-org reset, product purge, demo data cleanup, or "delete all products" requests, even when the user describes blockers instead of naming the objects. This skill covers core Revenue Cloud objects and usage-management records, not Salesforce CPQ SBQQ__ objects.
---

# Revenue Cloud Dev Org Cleanup

Use this skill for destructive cleanup of a connected Salesforce Revenue Cloud
dev org. Prefer the bundled script so the delete order, status transitions,
retries, and machine-readable summary stay consistent.

## Safety Rules

- Only run this skill when the user explicitly asked for destructive cleanup,
  reset, purge, or deletion.
- Confirm the target org alias unless it is already clear in the conversation.
- Do not use this skill for Salesforce CPQ / Steelbrick (`SBQQ__*`) cleanup.
- If the user wants an impact preview, run the script with `--dry-run` first.
- Treat access-controlled leftovers such as portal-user-backed Accounts or
  undeletable `AssetActionSource` records as non-fatal unless the user
  explicitly asks to keep digging.

## Default Workflow

1. Confirm whether the user wants:
   - product-focused cleanup, or
   - broader cleanup that also attempts `Account` deletion.
2. Read `references/cleanup-order.md` before executing. It explains the delete
   order, status changes, retries, and known blocker patterns.
3. From the skill root, run:

```bash
python3 scripts/cleanup_revenue_cloud_dev_org.py --target-org <alias> --summary-output cleanup-summary.json
```

4. Add flags as needed:
   - preview only: `--dry-run`
   - also try Accounts: `--include-accounts`
   - more retries for tangled usage data: `--max-passes 8`
5. If the script reports that `Product2` is still not zero, review the
   `remaining_counts` and `notes` fields in the JSON summary before attempting
   extra manual deletes.

## Required Report Back

When asked to use this skill, always report back with the number of records and
objects from which deletion was done.

Use this response shape:

```markdown
Cleanup summary for `<alias>`:

- Objects deleted from: <count>
- Records deleted: <count>
- Status changes applied: <count>
- Key cleared objects: <comma-separated object names>
- Remaining blockers or protected leftovers: <object=count, or `none`>
```

If the user asked for a dry run, replace deleted counts with planned counts and
say that no records were actually deleted.

## Available Files

- `scripts/cleanup_revenue_cloud_dev_org.py` — executes the cleanup and writes a
  JSON summary.
- `references/cleanup-order.md` — dependency-safe cleanup order and blocker
  notes.
- `evals/evals.json` — starter eval prompts for testing the skill behavior.

## Script Usage

Run the help text if you need the exact interface:

```bash
python3 scripts/cleanup_revenue_cloud_dev_org.py --help
```

Prefer the script over ad hoc SOQL + delete sequences because the script:

- updates status-controlled objects before deletion,
- retries multi-pass usage-entitlement chains,
- keeps optional `Account` deletion separate from product purge,
- emits a stable JSON summary for the final user-facing report.

## Boundary

This skill targets core Salesforce Revenue Cloud / Agentforce Revenue
Management dev org cleanup. It is not for Salesforce CPQ (`SBQQ__*`) object
cleanup, and it should not be used as a production-data purge playbook.
