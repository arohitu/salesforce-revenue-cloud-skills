#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<EOF
Usage: $(basename "$0") --target-org ALIAS --source-dir DIR [--dry-run | --confirm]

Deploy generated Advanced Configurator metadata to a Salesforce org.

Options:
  --target-org ALIAS   Required sf org alias/username
  --source-dir DIR     Required source directory (e.g., build/adv-config-source/force-app/main/default)
  --dry-run            Validate deployment only (no org mutation)
  --confirm            Required for live deployment
  --help               Show this help

Exit codes:
  1  invalid arguments
  2  required tools missing
  3  deployment command failed
EOF
}

TARGET_ORG=""
SOURCE_DIR=""
DRY_RUN=false
CONFIRM=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --target-org) TARGET_ORG="$2"; shift 2 ;;
    --source-dir) SOURCE_DIR="$2"; shift 2 ;;
    --dry-run) DRY_RUN=true; shift 1 ;;
    --confirm) CONFIRM=true; shift 1 ;;
    --help|-h) usage; exit 0 ;;
    *) echo "Unknown argument: $1" >&2; usage; exit 1 ;;
  esac
done

command -v sf >/dev/null 2>&1 || { echo "Error: sf CLI not found" >&2; exit 2; }
command -v jq >/dev/null 2>&1 || { echo "Error: jq not found" >&2; exit 2; }

[[ -n "$TARGET_ORG" ]] || { echo "Error: --target-org is required" >&2; usage; exit 1; }
[[ -n "$SOURCE_DIR" ]] || { echo "Error: --source-dir is required" >&2; usage; exit 1; }
[[ -d "$SOURCE_DIR" ]] || { echo "Error: source directory does not exist: $SOURCE_DIR" >&2; exit 1; }

if [[ "$DRY_RUN" == true && "$CONFIRM" == true ]]; then
  echo "Error: use only one of --dry-run or --confirm" >&2
  exit 1
fi
if [[ "$DRY_RUN" == false && "$CONFIRM" == false ]]; then
  echo "Error: choose --dry-run or --confirm" >&2
  exit 1
fi

if [[ "$DRY_RUN" == true ]]; then
  RESULT="$(sf project deploy validate --target-org "$TARGET_ORG" --source-dir "$SOURCE_DIR" --json)" || {
    echo "Deployment validation failed" >&2
    exit 3
  }
  printf "%s" "$RESULT" | jq '{mode:"dry-run",status:.status,result:.result}'
  exit 0
fi

RESULT="$(sf project deploy start --target-org "$TARGET_ORG" --source-dir "$SOURCE_DIR" --json)" || {
  echo "Deployment failed" >&2
  exit 3
}
printf "%s" "$RESULT" | jq '{mode:"confirm",status:.status,result:.result}'
