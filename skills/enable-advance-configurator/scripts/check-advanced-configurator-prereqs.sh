#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<EOF
Usage: $(basename "$0") [--target-org ALIAS]

Validate Advanced Configurator setup prerequisites in a Salesforce org.

Options:
  --target-org ALIAS   sf org alias/username. Uses default org if omitted.
  --help               Show this help.

Checks:
  - sf and jq availability
  - authenticated org access
  - latest supported REST API version
  - object/field readiness
  - existing Apex triggers and AdvancedConfigurator TPT records
  - AdvancedConfiguratorDesigner permission set assignment
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
command -v curl >/dev/null 2>&1 || { echo "Error: curl not found" >&2; exit 2; }

ORG_FLAG=()
[[ -n "$TARGET_ORG" ]] && ORG_FLAG=(--target-org "$TARGET_ORG")

ORG_JSON="$(sf org display --verbose --json "${ORG_FLAG[@]}")"
INSTANCE_URL="$(printf "%s" "$ORG_JSON" | jq -r '.result.instanceUrl')"
ACCESS_TOKEN="$(printf "%s" "$ORG_JSON" | jq -r '.result.accessToken')"
USERNAME="$(printf "%s" "$ORG_JSON" | jq -r '.result.username')"
USER_ID="$(printf "%s" "$ORG_JSON" | jq -r '.result.id // .result.userId // empty')"

[[ -n "$INSTANCE_URL" && "$INSTANCE_URL" != "null" ]] || { echo "Error: failed to resolve instanceUrl" >&2; exit 3; }
[[ -n "$ACCESS_TOKEN" && "$ACCESS_TOKEN" != "null" ]] || { echo "Error: failed to resolve accessToken" >&2; exit 3; }

VERSIONS_JSON="$(curl -sS -H "Authorization: Bearer $ACCESS_TOKEN" "$INSTANCE_URL/services/data/")"
LATEST_API_VERSION="$(printf "%s" "$VERSIONS_JSON" | jq -r 'map(.version|tonumber)|max')"

required_field_exists() {
  local object_name="$1"
  local field_name="$2"
  sf sobject describe --sobject "$object_name" --json "${ORG_FLAG[@]}" \
    | jq -e --arg fn "$field_name" '.result.fields | map(.name) | index($fn) != null' >/dev/null
}

tpt_object_available() {
  sf data query --use-tooling-api --json "${ORG_FLAG[@]}" --query \
    "SELECT Id FROM TransactionProcessingType LIMIT 1" >/dev/null 2>&1
}

QUOTE_FIELD=false
ORDER_FIELD=false
ASSET_SOURCE_FIELD=false
TPT_OBJECT=false

if required_field_exists "QuoteLineItem" "ConstraintEngineNodeStatus__c"; then QUOTE_FIELD=true; fi
if required_field_exists "OrderItem" "ConstraintEngineNodeStatus__c"; then ORDER_FIELD=true; fi
if required_field_exists "AssetActionSource" "ConstraintEngineNodeStatus__c"; then ASSET_SOURCE_FIELD=true; fi
if tpt_object_available; then TPT_OBJECT=true; fi

TRIGGERS_JSON="$(sf data query --use-tooling-api --json "${ORG_FLAG[@]}" --query \
"SELECT Id, Name, TableEnumOrId, Status FROM ApexTrigger WHERE TableEnumOrId IN ('QuoteLineItem','OrderItem')")"

TPT_JSON="$(sf data query --use-tooling-api --json "${ORG_FLAG[@]}" --query \
"SELECT Id, DeveloperName, MasterLabel, RuleEngine FROM TransactionProcessingType WHERE RuleEngine = 'AdvancedConfigurator'" 2>/dev/null || echo '{"result":{"records":[]}}')"

DESIGNER_PS_JSON="$(sf data query --json "${ORG_FLAG[@]}" --query \
"SELECT Id, Name, Label FROM PermissionSet WHERE Name = 'AdvancedConfiguratorDesigner' LIMIT 1")"

SETUP_PS_JSON="$(sf data query --json "${ORG_FLAG[@]}" --query \
"SELECT Id, Name, Label FROM PermissionSet WHERE Name = 'EnableAdvancedConfiguratorSetup' LIMIT 1")"

DESIGNER_ASSIGNED=false
DESIGNER_PS_ID="$(printf "%s" "$DESIGNER_PS_JSON" | jq -r '.result.records[0].Id // empty')"
if [[ -n "$DESIGNER_PS_ID" ]]; then
  if [[ -z "$USER_ID" || "$USER_ID" == "null" ]]; then
    USER_ID="$(sf data query --json "${ORG_FLAG[@]}" --query "SELECT Id FROM User WHERE Username = '$USERNAME' LIMIT 1" | jq -r '.result.records[0].Id // empty')"
  fi
  if [[ -n "$USER_ID" ]]; then
    ASSIGN_COUNT="$(sf data query --json "${ORG_FLAG[@]}" --query \
      "SELECT Id FROM PermissionSetAssignment WHERE AssigneeId = '$USER_ID' AND PermissionSetId = '$DESIGNER_PS_ID' LIMIT 1" | jq -r '.result.totalSize')"
    [[ "$ASSIGN_COUNT" != "0" ]] && DESIGNER_ASSIGNED=true
  fi
fi

printf "%s\n" "$TRIGGERS_JSON" | jq --arg user "$USERNAME" \
  --argjson api "$LATEST_API_VERSION" \
  --argjson quoteField "$QUOTE_FIELD" \
  --argjson orderField "$ORDER_FIELD" \
  --argjson assetSourceField "$ASSET_SOURCE_FIELD" \
  --argjson tptObject "$TPT_OBJECT" \
  --argjson designerAssigned "$DESIGNER_ASSIGNED" \
  --argjson tptRecords "$(printf "%s" "$TPT_JSON" | jq '.result.records | map(del(.attributes))')" \
  --argjson designerPermissionSet "$(printf "%s" "$DESIGNER_PS_JSON" | jq '.result.records | map(del(.attributes))')" \
  --argjson setupPermissionSet "$(printf "%s" "$SETUP_PS_JSON" | jq '.result.records | map(del(.attributes))')" \
  '{
    username: $user,
    latestApiVersion: $api,
    readiness: {
      quoteLineItemField: $quoteField,
      orderItemField: $orderField,
      assetActionSourceField: $assetSourceField,
      transactionProcessingTypeObjectAvailable: $tptObject,
      advancedConfiguratorDesignerAssigned: $designerAssigned
    },
    existing: {
      triggers: (.result.records | map(del(.attributes))),
      advancedConfiguratorTransactionProcessingTypes: $tptRecords,
      designerPermissionSet: $designerPermissionSet,
      setupPermissionSet: $setupPermissionSet
    }
  }'
