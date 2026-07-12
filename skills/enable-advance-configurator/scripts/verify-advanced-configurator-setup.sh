#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<EOF
Usage: $(basename "$0") --target-org ALIAS [--context-definition-name NAME]

Verify Advanced Configurator setup artifacts and print manual checklist reminders.

Options:
  --target-org ALIAS                 Required sf org alias/username
  --context-definition-name NAME     Optional: retrieve and verify constraint context definition changes
  --help                             Show this help
EOF
}

TARGET_ORG=""
CONTEXT_DEFINITION_NAME=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --target-org) TARGET_ORG="$2"; shift 2 ;;
    --context-definition-name) CONTEXT_DEFINITION_NAME="$2"; shift 2 ;;
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

has_sales_transaction_item_attribute() {
  awk '
    /<contextAttributes>/ { block="" }
    /<contextAttributes>/,/<\/contextAttributes>/ { block = block $0 "\n" }
    /<\/contextAttributes>/ {
      if (block ~ /ConstraintEngineNodeStatus__c/ && block ~ /inputoutput/ && block !~ /inheritedFrom/) { found=1 }
    }
    END { exit(found ? 0 : 1) }
  ' "$1"
}

mapping_block_has_attribute() {
  local mapping_title="$1"
  local mapping_marker="$2"
  local context_attribute="$3"
  local object_name="$4"
  awk -v mapping="$mapping_title" -v marker="$mapping_marker" \
      -v attr="$context_attribute" -v obj="$object_name" '
    /<contextMappings>/ { buf="" }
    /<contextMappings>/,/<\/contextMappings>/ { buf = buf $0 "\n" }
    /<\/contextMappings>/ {
      if (index(buf, "<title>" mapping "</title>") && index(buf, marker) && index(buf, attr) && index(buf, obj)) { found=1 }
      buf=""
    }
    END { exit(found ? 0 : 1) }
  ' "$5"
}

check_context_definition() {
  local name="$1"
  local work_dir="./build/adv-config-verify-context"
  local context_file="$work_dir/force-app/main/default/contextDefinitions/${name}.contextDefinition-meta.xml"

  sf project retrieve start \
    --metadata "ContextDefinition:${name}" \
    --target-org "$TARGET_ORG" \
    --output-dir "$work_dir" \
    --json >/dev/null 2>&1 || return 1

  [[ -f "$context_file" ]] || return 1

  local sti=false aas=false order=false quote=false asset=false
  has_sales_transaction_item_attribute "$context_file" && sti=true
  awk '
    /<contextAttributes>/ { block="" }
    /<contextAttributes>/,/<\/contextAttributes>/ { block = block $0 "\n" }
    /<\/contextAttributes>/ {
      if (block ~ /AssetConstraintEngineNodeStatus__c/ && block ~ /inputoutput/ && block !~ /inheritedFrom/) { found=1 }
    }
    END { exit(found ? 0 : 1) }
  ' "$context_file" && aas=true
  mapping_block_has_attribute "OrderEntitiesMapping" "OrderEntitiesMapping/SalesTransactionItem" \
    "ConstraintEngineNodeStatus__c" "OrderItem" "$context_file" && order=true
  mapping_block_has_attribute "QuoteEntitiesMapping" "QuoteEntitiesMapping/SalesTransactionItem" \
    "ConstraintEngineNodeStatus__c" "QuoteLineItem" "$context_file" && quote=true
  mapping_block_has_attribute "AssetEntitiesMapping" "AssetEntitiesMapping/AssetActionSource" \
    "AssetConstraintEngineNodeStatus__c" "AssetActionSource" "$context_file" && asset=true

  jq -n \
    --arg name "$name" \
    --argjson sti "$sti" \
    --argjson aas "$aas" \
    --argjson order "$order" \
    --argjson quote "$quote" \
    --argjson asset "$asset" \
    '{
      contextDefinition: $name,
      salesTransactionItemAttribute: $sti,
      assetActionSourceAttribute: $aas,
      orderEntitiesMapping: $order,
      quoteEntitiesMapping: $quote,
      assetEntitiesMapping: $asset,
      allConstraintChangesPresent: ($sti and $aas and $order and $quote and $asset)
    }'
}

QUOTE_FIELD=false
ORDER_FIELD=false
ASSET_SOURCE_FIELD=false
TPT_OBJECT=false
if field_exists "QuoteLineItem" "ConstraintEngineNodeStatus__c"; then QUOTE_FIELD=true; fi
if field_exists "OrderItem" "ConstraintEngineNodeStatus__c"; then ORDER_FIELD=true; fi
if field_exists "AssetActionSource" "ConstraintEngineNodeStatus__c"; then ASSET_SOURCE_FIELD=true; fi

tpt_object_available() {
  sf data query --use-tooling-api --target-org "$TARGET_ORG" --json --query \
    "SELECT Id FROM TransactionProcessingType LIMIT 1" >/dev/null 2>&1
}
if tpt_object_available; then TPT_OBJECT=true; fi

TRIGGERS="$(sf data query --use-tooling-api --target-org "$TARGET_ORG" --json --query \
"SELECT Name, TableEnumOrId, Status FROM ApexTrigger WHERE TableEnumOrId IN ('QuoteLineItem','OrderItem')")"

TPTS="$(sf data query --use-tooling-api --target-org "$TARGET_ORG" --json --query \
"SELECT Id, DeveloperName, MasterLabel, RuleEngine FROM TransactionProcessingType WHERE RuleEngine = 'AdvancedConfigurator'" 2>/dev/null || echo '{"result":{"records":[]}}')"

DESIGNER_PS="$(sf data query --target-org "$TARGET_ORG" --json --query \
"SELECT Id, Name, Label FROM PermissionSet WHERE Name = 'AdvancedConfiguratorDesigner' LIMIT 1")"

SETUP_PS="$(sf data query --target-org "$TARGET_ORG" --json --query \
"SELECT Id, Name, Label FROM PermissionSet WHERE Name = 'EnableAdvancedConfiguratorSetup' LIMIT 1")"

ORG_JSON="$(sf org display --json --target-org "$TARGET_ORG")"
USERNAME="$(printf "%s" "$ORG_JSON" | jq -r '.result.username')"
USER_ID="$(sf data query --target-org "$TARGET_ORG" --json --query "SELECT Id FROM User WHERE Username = '$USERNAME' LIMIT 1" | jq -r '.result.records[0].Id // empty')"
DESIGNER_PS_ID="$(printf "%s" "$DESIGNER_PS" | jq -r '.result.records[0].Id // empty')"
DESIGNER_ASSIGNED=false
if [[ -n "$USER_ID" && -n "$DESIGNER_PS_ID" ]]; then
  ASSIGN_COUNT="$(sf data query --target-org "$TARGET_ORG" --json --query \
    "SELECT Id FROM PermissionSetAssignment WHERE AssigneeId = '$USER_ID' AND PermissionSetId = '$DESIGNER_PS_ID' LIMIT 1" | jq -r '.result.totalSize')"
  [[ "$ASSIGN_COUNT" != "0" ]] && DESIGNER_ASSIGNED=true
fi

QUOTE_TRIGGER_ACTIVE="$(printf "%s" "$TRIGGERS" | jq '[.result.records[]? | select(.TableEnumOrId=="QuoteLineItem" and .Status=="Active")] | length > 0')"
ORDER_TRIGGER_ACTIVE="$(printf "%s" "$TRIGGERS" | jq '[.result.records[]? | select(.TableEnumOrId=="OrderItem" and .Status=="Active")] | length > 0')"

CONTEXT_CHECKS="null"
if [[ -n "$CONTEXT_DEFINITION_NAME" ]]; then
  CONTEXT_CHECKS="$(check_context_definition "$CONTEXT_DEFINITION_NAME" 2>/dev/null || jq -n \
    --arg name "$CONTEXT_DEFINITION_NAME" \
    '{contextDefinition:$name, retrieved:false, allConstraintChangesPresent:false}')"
fi

jq -n \
  --argjson quoteField "$QUOTE_FIELD" \
  --argjson orderField "$ORDER_FIELD" \
  --argjson assetSourceField "$ASSET_SOURCE_FIELD" \
  --argjson tptObject "$TPT_OBJECT" \
  --argjson quoteTriggerActive "$QUOTE_TRIGGER_ACTIVE" \
  --argjson orderTriggerActive "$ORDER_TRIGGER_ACTIVE" \
  --argjson designerAssigned "$DESIGNER_ASSIGNED" \
  --argjson triggers "$(printf "%s" "$TRIGGERS" | jq '.result.records | map(del(.attributes))')" \
  --argjson tpts "$(printf "%s" "$TPTS" | jq '.result.records | map(del(.attributes))')" \
  --argjson designerPermissionSet "$(printf "%s" "$DESIGNER_PS" | jq '.result.records | map(del(.attributes))')" \
  --argjson setupPermissionSet "$(printf "%s" "$SETUP_PS" | jq '.result.records | map(del(.attributes))')" \
  --argjson contextDefinitionChecks "$CONTEXT_CHECKS" \
  '{
    status: "ok",
    checks: {
      quoteLineItemField: $quoteField,
      orderItemField: $orderField,
      assetActionSourceField: $assetSourceField,
      transactionProcessingTypeObjectAvailable: $tptObject,
      quoteLineItemTriggerActive: $quoteTriggerActive,
      orderItemTriggerActive: $orderTriggerActive,
      advancedConfiguratorDesignerAssigned: $designerAssigned,
      triggers: $triggers,
      advancedConfiguratorTransactionProcessingTypes: $tpts,
      designerPermissionSet: $designerPermissionSet,
      setupPermissionSet: $setupPermissionSet,
      contextDefinition: $contextDefinitionChecks
    },
    manualChecklist: [
      "Confirm enableAdvancedConfigurator is true in IndustriesConstraints settings (or Revenue Settings UI toggle)",
      "Confirm enableTransactionProcessor is true in RevenueManagement settings (irreversible once enabled)",
      "Confirm SalesTransactionTypeId is on Quote and Order layouts when user override is required",
      "Confirm context definition attributes and entity mappings in Setup after deploy attempt (success or failure)",
      "Confirm AssetToSalesTransactionMapping cross-attribute mapping is complete (manual checkpoint)",
      "Confirm context definition is activated in Setup when required",
      "Confirm default transaction type impact is reviewed (selection can be irreversible)"
    ]
  }'
