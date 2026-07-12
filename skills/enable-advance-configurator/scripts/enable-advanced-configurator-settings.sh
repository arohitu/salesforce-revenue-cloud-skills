#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<EOF
Usage: $(basename "$0") --target-org ALIAS [--work-dir DIR] [--dry-run | --confirm]

Retrieve, update, and deploy Revenue Settings metadata for Advanced Configurator.

Options:
  --target-org ALIAS   Required sf org alias/username
  --work-dir DIR       Working directory for retrieved settings (default: ./build/adv-config-settings)
  --dry-run            Retrieve and show planned changes; do not deploy
  --confirm            Retrieve, update, and deploy settings
  --help               Show this help

Updates:
  - IndustriesConstraints.settings-meta.xml: enableAdvancedConfigurator=true
  - RevenueManagement.settings-meta.xml: enableTransactionProcessor=true

Only these two settings files are deployed. Bulk Settings retrieve output is never deployed.
EOF
}

TARGET_ORG=""
WORK_DIR="./build/adv-config-settings"
DRY_RUN=false
CONFIRM=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --target-org) TARGET_ORG="$2"; shift 2 ;;
    --work-dir) WORK_DIR="$2"; shift 2 ;;
    --dry-run) DRY_RUN=true; shift 1 ;;
    --confirm) CONFIRM=true; shift 1 ;;
    --help|-h) usage; exit 0 ;;
    *) echo "Unknown argument: $1" >&2; usage; exit 1 ;;
  esac
done

command -v sf >/dev/null 2>&1 || { echo "Error: sf CLI not found" >&2; exit 2; }
command -v jq >/dev/null 2>&1 || { echo "Error: jq not found" >&2; exit 2; }

[[ -n "$TARGET_ORG" ]] || { echo "Error: --target-org is required" >&2; usage; exit 1; }
if [[ "$DRY_RUN" == true && "$CONFIRM" == true ]]; then
  echo "Error: use only one of --dry-run or --confirm" >&2
  exit 1
fi
if [[ "$DRY_RUN" == false && "$CONFIRM" == false ]]; then
  echo "Error: choose --dry-run or --confirm" >&2
  exit 1
fi

SETTINGS_DIR="$WORK_DIR/force-app/main/default/settings"
mkdir -p "$SETTINGS_DIR"

sf project retrieve start \
  --metadata "Settings:IndustriesConstraints" "Settings:RevenueManagement" \
  --target-org "$TARGET_ORG" \
  --output-dir "$WORK_DIR" \
  --json >/dev/null

CONSTRAINTS_FILE="$SETTINGS_DIR/IndustriesConstraints.settings-meta.xml"
REVENUE_FILE="$SETTINGS_DIR/RevenueManagement.settings-meta.xml"

[[ -f "$CONSTRAINTS_FILE" ]] || { echo "Error: missing $CONSTRAINTS_FILE after retrieve" >&2; exit 3; }
[[ -f "$REVENUE_FILE" ]] || { echo "Error: missing $REVENUE_FILE after retrieve" >&2; exit 3; }

if grep -q '<enableAdvancedConfigurator>' "$CONSTRAINTS_FILE"; then
  sed -i.bak 's|<enableAdvancedConfigurator>.*</enableAdvancedConfigurator>|<enableAdvancedConfigurator>true</enableAdvancedConfigurator>|' "$CONSTRAINTS_FILE"
else
  sed -i.bak 's|</IndustriesConstraintsSettings>|    <enableAdvancedConfigurator>true</enableAdvancedConfigurator>\n</IndustriesConstraintsSettings>|' "$CONSTRAINTS_FILE"
fi

if grep -q '<enableTransactionProcessor>' "$REVENUE_FILE"; then
  sed -i.bak 's|<enableTransactionProcessor>.*</enableTransactionProcessor>|<enableTransactionProcessor>true</enableTransactionProcessor>|' "$REVENUE_FILE"
else
  sed -i.bak 's|</RevenueManagementSettings>|    <enableTransactionProcessor>true</enableTransactionProcessor>\n</RevenueManagementSettings>|' "$REVENUE_FILE"
fi
rm -f "$CONSTRAINTS_FILE.bak" "$REVENUE_FILE.bak"

PLAN="$(jq -n \
  --arg constraints "$CONSTRAINTS_FILE" \
  --arg revenue "$REVENUE_FILE" \
  '{
    industriesConstraints: { file: $constraints, enableAdvancedConfigurator: true },
    revenueManagement: { file: $revenue, enableTransactionProcessor: true }
  }')"

if [[ "$DRY_RUN" == true ]]; then
  jq -n --argjson plan "$PLAN" '{status:"dry-run", plannedChanges:$plan}'
  exit 0
fi

RESULT="$(sf project deploy start \
  --source-dir "$CONSTRAINTS_FILE" \
  --source-dir "$REVENUE_FILE" \
  --target-org "$TARGET_ORG" \
  --json)" || {
  echo "Settings deployment failed" >&2
  exit 3
}

printf "%s" "$RESULT" | jq --argjson plan "$PLAN" '{status:"deployed", plannedChanges:$plan, deploy:.result}'
