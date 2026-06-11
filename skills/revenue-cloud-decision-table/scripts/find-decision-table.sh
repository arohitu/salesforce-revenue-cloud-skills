#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<EOF
Usage: $(basename "$0") [--target-org ALIAS] (--search TEXT | --developer-name NAME)

Find Salesforce DecisionTable records and print JSON.

Options:
  --target-org ALIAS      sf CLI org alias or username. Defaults to default org.
  --search TEXT           Search DeveloperName and MasterLabel.
  --developer-name NAME   Match an exact DecisionTable DeveloperName.
  --limit N               Max records to return. Defaults to 25.
  --help                  Print this help.
EOF
}

TARGET_ORG=""
SEARCH=""
DEVELOPER_NAME=""
LIMIT=25

while [[ $# -gt 0 ]]; do
  case "$1" in
    --target-org) TARGET_ORG="$2"; shift 2 ;;
    --search) SEARCH="$2"; shift 2 ;;
    --developer-name) DEVELOPER_NAME="$2"; shift 2 ;;
    --limit) LIMIT="$2"; shift 2 ;;
    --help|-h) usage; exit 0 ;;
    *) echo "Unknown argument: $1" >&2; usage; exit 1 ;;
  esac
done

if [[ -z "$SEARCH" && -z "$DEVELOPER_NAME" ]]; then
  echo "Error: provide --search or --developer-name" >&2
  usage
  exit 1
fi

command -v sf >/dev/null 2>&1 || { echo "Error: sf CLI not found" >&2; exit 2; }
command -v jq >/dev/null 2>&1 || { echo "Error: jq is required" >&2; exit 2; }

ORG_FLAG=()
[[ -n "$TARGET_ORG" ]] && ORG_FLAG=(--target-org "$TARGET_ORG")

escape_soql() {
  printf "%s" "$1" | sed "s/'/\\\\'/g"
}

if [[ -n "$DEVELOPER_NAME" ]]; then
  VALUE="$(escape_soql "$DEVELOPER_NAME")"
  WHERE="DeveloperName = '${VALUE}'"
else
  VALUE="$(escape_soql "$SEARCH")"
  WHERE="(DeveloperName LIKE '%${VALUE}%' OR MasterLabel LIKE '%${VALUE}%')"
fi

QUERY="
SELECT Id, DeveloperName, MasterLabel, Type, Status, SourceObject,
       ExecutionType, UsageType, RefreshStatus, LastModifiedDate
FROM DecisionTable
WHERE ${WHERE}
ORDER BY DeveloperName
LIMIT ${LIMIT}
"

sf data query --query "$QUERY" "${ORG_FLAG[@]}" --json \
  | jq '{
      totalSize: .result.totalSize,
      records: (.result.records | map(del(.attributes)))
    }'
