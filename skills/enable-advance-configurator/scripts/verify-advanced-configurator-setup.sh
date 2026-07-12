#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<EOF
Usage: $(basename "$0") --target-org ALIAS

Verify Advanced Configurator setup artifacts and print manual checklist reminders.

Options:
  --target-org ALIAS   Required sf org alias/username
  --help               Show this help
EOF
}

TARGET_ORG=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    --target-org) TARGET_ORG="$2"; shift 2 ;;
    --help|-h) usage; exit 0 ;;
    *) echo "Unknown argument: $1" >&2; usage; exit 1 ;;
  esac
done

command -v sf >/dev/null 2>&1 || { echo "Error: sf CLI not found" >&2; exit 2; }
command -v jq >/dev/null 2>&1 || { echo "Error: jq not found" >&2; exit 2; }

[[ -n "$TARGET_ORG" ]] || { echo "Error: --target-org is required" >&2; usage; exit 1; }

field_exists() {
  local object_name="$1"
  local field_name="$2"
  sf sobject describe --sobject "$object_name" --target-org "$TARGET_ORG" --json \
    | jq -e --arg fn "$field_name" '.result.fields | map(.name) | index($fn) != null' >/dev/null
}

QUOTE_FIELD=false
ORDER_FIELD=false
ASSET_SOURCE_FIELD=false
if field_exists "QuoteLineItem" "ConstraintEngineNodeStatus__c"; then QUOTE_FIELD=true; fi
if field_exists "OrderItem" "ConstraintEngineNodeStatus__c"; then ORDER_FIELD=true; fi
if field_exists "AssetActionSource" "ConstraintEngineNodeStatus__c"; then ASSET_SOURCE_FIELD=true; fi

TRIGGERS="$(sf data query --use-tooling-api --target-org "$TARGET_ORG" --json --query \
"SELECT Name, TableEnumOrId, Status FROM ApexTrigger WHERE Name IN ('RCAAdvConfigQuoteLineItemTrigger','RCAAdvConfigOrderItemTrigger')")"

TPTS="$(sf data query --use-tooling-api --target-org "$TARGET_ORG" --json --query \
"SELECT Id, DeveloperName, MasterLabel, RuleEngine FROM TransactionProcessingType WHERE RuleEngine = 'AdvancedConfigurator'")"

PERMSET="$(sf data query --target-org "$TARGET_ORG" --json --query \
"SELECT Id, Name, Label FROM PermissionSet WHERE Name = 'EnableAdvancedConfiguratorSetup' LIMIT 1")"

jq -n \
  --argjson quoteField "$QUOTE_FIELD" \
  --argjson orderField "$ORDER_FIELD" \
  --argjson assetSourceField "$ASSET_SOURCE_FIELD" \
  --argjson triggers "$(printf "%s" "$TRIGGERS" | jq '.result.records | map(del(.attributes))')" \
  --argjson tpts "$(printf "%s" "$TPTS" | jq '.result.records | map(del(.attributes))')" \
  --argjson permissionSet "$(printf "%s" "$PERMSET" | jq '.result.records | map(del(.attributes))')" \
  '{
    status: "ok",
    checks: {
      quoteLineItemField: $quoteField,
      orderItemField: $orderField,
      assetActionSourceField: $assetSourceField,
      triggers: $triggers,
      advancedConfiguratorTransactionProcessingTypes: $tpts,
      setupPermissionSet: $permissionSet
    },
    manualChecklist: [
      "Confirm Revenue Settings toggle: Set Up Configuration Rules and Constraints with Constraints Engine",
      "Confirm Revenue Settings toggle: Transaction processing for quotes and orders",
      "Confirm Transaction Type field is on Quote and Order layouts when user override is required",
      "Confirm default transaction type impact is reviewed (selection can be irreversible)"
    ]
  }'
