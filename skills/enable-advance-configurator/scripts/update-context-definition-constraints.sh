#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<EOF
Usage: $(basename "$0") --target-org ALIAS --context-definition-name NAME [--work-dir DIR] [--dry-run | --confirm]

Retrieve a Sales Transaction context definition from the org and idempotently add
ConstraintEngineNodeStatus attributes and entity mappings for Advanced Configurator.

Options:
  --target-org ALIAS              Required sf org alias/username
  --context-definition-name NAME  Required context definition API name (e.g. RLM_SalesTransactionContext)
  --work-dir DIR                  Working directory for retrieve output (default: ./build/adv-config-context)
  --dry-run                       Retrieve and report planned changes; do not deploy
  --confirm                       Retrieve, update if needed, and deploy the context definition file
  --help                          Show this help

Adds (when missing):
  1. SalesTransactionItem context attribute: ConstraintEngineNodeStatus__c
  2. AssetActionSource context attribute: AssetConstraintEngineNodeStatus__c
  3. OrderEntitiesMapping: SalesTransactionItem -> OrderItem.ConstraintEngineNodeStatus__c
  4. QuoteEntitiesMapping: SalesTransactionItem -> QuoteLineItem.ConstraintEngineNodeStatus__c
  5. AssetEntitiesMapping: AssetActionSource -> AssetActionSource.ConstraintEngineNodeStatus__c

Does NOT add AssetToSalesTransactionMapping (manual checkpoint).
Only the single context definition file is deployed; no bulk/noisy redeploy.
EOF
}

TARGET_ORG=""
CONTEXT_DEFINITION_NAME=""
WORK_DIR="./build/adv-config-context"
DRY_RUN=false
CONFIRM=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --target-org) TARGET_ORG="$2"; shift 2 ;;
    --context-definition-name) CONTEXT_DEFINITION_NAME="$2"; shift 2 ;;
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
[[ -n "$CONTEXT_DEFINITION_NAME" ]] || { echo "Error: --context-definition-name is required" >&2; usage; exit 1; }
if [[ "$DRY_RUN" == true && "$CONFIRM" == true ]]; then
  echo "Error: use only one of --dry-run or --confirm" >&2
  exit 1
fi
if [[ "$DRY_RUN" == false && "$CONFIRM" == false ]]; then
  echo "Error: choose --dry-run or --confirm" >&2
  exit 1
fi

field_exists() {
  local object_name="$1"
  local field_name="$2"
  sf sobject describe --sobject "$object_name" --target-org "$TARGET_ORG" --json \
    | jq -e --arg fn "$field_name" '.result.fields | map(.name) | index($fn) != null' >/dev/null
}

MISSING_FIELDS=()
field_exists "QuoteLineItem" "ConstraintEngineNodeStatus__c" || MISSING_FIELDS+=("QuoteLineItem.ConstraintEngineNodeStatus__c")
field_exists "OrderItem" "ConstraintEngineNodeStatus__c" || MISSING_FIELDS+=("OrderItem.ConstraintEngineNodeStatus__c")
field_exists "AssetActionSource" "ConstraintEngineNodeStatus__c" || MISSING_FIELDS+=("AssetActionSource.ConstraintEngineNodeStatus__c")

if [[ ${#MISSING_FIELDS[@]} -gt 0 ]]; then
  echo "Error: custom fields not found in org ${TARGET_ORG}:" >&2
  printf '  - %s\n' "${MISSING_FIELDS[@]}" >&2
  echo "Deploy ConstraintEngineNodeStatus__c fields before updating the context definition." >&2
  exit 4
fi

CONTEXT_DIR="$WORK_DIR/force-app/main/default/contextDefinitions"
CONTEXT_FILE="$CONTEXT_DIR/${CONTEXT_DEFINITION_NAME}.contextDefinition-meta.xml"
mkdir -p "$CONTEXT_DIR"

sf project retrieve start \
  --metadata "ContextDefinition:${CONTEXT_DEFINITION_NAME}" \
  --target-org "$TARGET_ORG" \
  --output-dir "$WORK_DIR" \
  --json >/dev/null

[[ -f "$CONTEXT_FILE" ]] || {
  echo "Error: context definition file not found after retrieve: $CONTEXT_FILE" >&2
  exit 3
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

has_asset_action_source_attribute() {
  awk '
    /<contextAttributes>/ { block="" }
    /<contextAttributes>/,/<\/contextAttributes>/ { block = block $0 "\n" }
    /<\/contextAttributes>/ {
      if (block ~ /AssetConstraintEngineNodeStatus__c/ && block ~ /inputoutput/ && block !~ /inheritedFrom/) { found=1 }
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

has_order_mapping() {
  mapping_block_has_attribute "OrderEntitiesMapping" \
    "OrderEntitiesMapping/SalesTransactionItem" "ConstraintEngineNodeStatus__c" "OrderItem" "$1"
}

has_quote_mapping() {
  mapping_block_has_attribute "QuoteEntitiesMapping" \
    "QuoteEntitiesMapping/SalesTransactionItem" "ConstraintEngineNodeStatus__c" "QuoteLineItem" "$1"
}

has_asset_mapping() {
  mapping_block_has_attribute "AssetEntitiesMapping" \
    "AssetEntitiesMapping/AssetActionSource" "AssetConstraintEngineNodeStatus__c" "AssetActionSource" "$1"
}

insert_before_line() {
  local file="$1"
  local match="$2"
  local snippet="$3"
  awk -v match="$match" -v snippet="$snippet" '
    index($0, match) && !done {
      n = split(snippet, lines, "\n")
      for (i = 1; i <= n; i++) {
        if (lines[i] != "") print lines[i]
      }
      done = 1
    }
    { print }
  ' "$file" > "${file}.tmp"
  mv "${file}.tmp" "$file"
}

insert_before_context_node_mapping() {
  local file="$1"
  local context_node="$2"
  local mapping_marker="$3"
  local snippet="$4"
  awk -v node="$context_node" -v marker="$mapping_marker" -v snippet="$snippet" '
    $0 ~ ("<contextNode>" node "</contextNode>") {
      getline nextline
      if (index(nextline, marker) && !done) {
        n = split(snippet, lines, "\n")
        for (i = 1; i <= n; i++) {
          if (lines[i] != "") print lines[i]
        }
        done = 1
      }
      print $0
      print nextline
      next
    }
    { print }
  ' "$file" > "${file}.tmp"
  mv "${file}.tmp" "$file"
}

apply_change() {
  local check_fn="$1"
  local apply_fn="$2"
  local label="$3"
  shift 3

  if "$check_fn" "$CONTEXT_FILE"; then
    echo "already_present"
    return 0
  fi

  if [[ "$DRY_RUN" == true ]]; then
    echo "would_add"
    return 0
  fi

  if ! "$apply_fn" "$CONTEXT_FILE" "$@"; then
    echo "Error: failed to apply ${label}; context definition structure may differ from expected pattern" >&2
    exit 5
  fi
  echo "added"
}

apply_sti_attribute() {
  local file="$1"
  local anchor='                <inheritedFrom>SalesTransactionContext__stdctx/version/SalesTransaction/SalesTransactionItem/SalesTransactionItem</inheritedFrom>'
  grep -Fq "$anchor" "$file" || return 1
  insert_before_line "$file" "$anchor" "$STI_ATTRIBUTE_SNIPPET"
  has_sales_transaction_item_attribute "$file"
}

apply_aas_attribute() {
  local file="$1"
  local anchor='                <inheritedFrom>SalesTransactionContext__stdctx/version/Asset/AssetAction/AssetActionSource/AssetActionSourceTag</inheritedFrom>'
  grep -Fq "$anchor" "$file" || return 1
  insert_before_line "$file" "$anchor" "$AAS_ATTRIBUTE_SNIPPET"
  has_asset_action_source_attribute "$file"
}

apply_order_mapping() {
  local file="$1"
  grep -Fq 'SalesTransactionContext__stdctx/version/OrderEntitiesMapping/SalesTransactionItem' "$file" || return 1
  insert_before_context_node_mapping "$file" "SalesTransactionItem" \
    "OrderEntitiesMapping/SalesTransactionItem" "$ORDER_MAPPING_SNIPPET"
  has_order_mapping "$file"
}

apply_quote_mapping() {
  local file="$1"
  grep -Fq 'SalesTransactionContext__stdctx/version/QuoteEntitiesMapping/SalesTransactionItem' "$file" || return 1
  insert_before_context_node_mapping "$file" "SalesTransactionItem" \
    "QuoteEntitiesMapping/SalesTransactionItem" "$QUOTE_MAPPING_SNIPPET"
  has_quote_mapping "$file"
}

apply_asset_mapping() {
  local file="$1"
  grep -Fq 'SalesTransactionContext__stdctx/version/AssetEntitiesMapping/AssetActionSource' "$file" || return 1
  insert_before_context_node_mapping "$file" "AssetActionSource" \
    "AssetEntitiesMapping/AssetActionSource" "$ASSET_MAPPING_SNIPPET"
  has_asset_mapping "$file"
}

read -r -d '' STI_ATTRIBUTE_SNIPPET <<'EOF' || true
            <contextAttributes>
                <contextTags>
                    <title>ConstraintEngineNodeStatus__c</title>
                </contextTags>
                <customMappingAllowed>false</customMappingAllowed>
                <dataType>string</dataType>
                <fieldType>inputoutput</fieldType>
                <key>false</key>
                <title>ConstraintEngineNodeStatus__c</title>
                <transient>false</transient>
                <value>false</value>
            </contextAttributes>
EOF

read -r -d '' AAS_ATTRIBUTE_SNIPPET <<'EOF' || true
            <contextAttributes>
                <contextTags>
                    <title>AssetConstraintEngineNodeStatus__c</title>
                </contextTags>
                <customMappingAllowed>false</customMappingAllowed>
                <dataType>string</dataType>
                <fieldType>inputoutput</fieldType>
                <key>false</key>
                <title>AssetConstraintEngineNodeStatus__c</title>
                <transient>false</transient>
                <value>false</value>
            </contextAttributes>
EOF

read -r -d '' ORDER_MAPPING_SNIPPET <<'EOF' || true
                <contextAttributeMappings>
                    <contextAttrHydrationDetails>
                        <objectName>OrderItem</objectName>
                        <queryAttribute>ConstraintEngineNodeStatus__c</queryAttribute>
                    </contextAttrHydrationDetails>
                    <contextAttribute>ConstraintEngineNodeStatus__c</contextAttribute>
                    <contextInputAttributeName>ConstraintEngineNodeStatus__c</contextInputAttributeName>
                </contextAttributeMappings>
EOF

read -r -d '' QUOTE_MAPPING_SNIPPET <<'EOF' || true
                <contextAttributeMappings>
                    <contextAttrHydrationDetails>
                        <objectName>QuoteLineItem</objectName>
                        <queryAttribute>ConstraintEngineNodeStatus__c</queryAttribute>
                    </contextAttrHydrationDetails>
                    <contextAttribute>ConstraintEngineNodeStatus__c</contextAttribute>
                    <contextInputAttributeName>ConstraintEngineNodeStatus__c</contextInputAttributeName>
                </contextAttributeMappings>
EOF

read -r -d '' ASSET_MAPPING_SNIPPET <<'EOF' || true
                <contextAttributeMappings>
                    <contextAttrHydrationDetails>
                        <objectName>AssetActionSource</objectName>
                        <queryAttribute>ConstraintEngineNodeStatus__c</queryAttribute>
                    </contextAttrHydrationDetails>
                    <contextAttribute>AssetConstraintEngineNodeStatus__c</contextAttribute>
                    <contextInputAttributeName>AssetConstraintEngineNodeStatus__c</contextInputAttributeName>
                </contextAttributeMappings>
EOF

STI_STATUS="$(apply_change has_sales_transaction_item_attribute apply_sti_attribute "SalesTransactionItem attribute")"
AAS_STATUS="$(apply_change has_asset_action_source_attribute apply_aas_attribute "AssetActionSource attribute")"
ORDER_STATUS="$(apply_change has_order_mapping apply_order_mapping "OrderEntitiesMapping")"
QUOTE_STATUS="$(apply_change has_quote_mapping apply_quote_mapping "QuoteEntitiesMapping")"
ASSET_STATUS="$(apply_change has_asset_mapping apply_asset_mapping "AssetEntitiesMapping")"

PLAN="$(jq -n \
  --arg contextDefinition "$CONTEXT_DEFINITION_NAME" \
  --arg sti "$STI_STATUS" \
  --arg aas "$AAS_STATUS" \
  --arg order "$ORDER_STATUS" \
  --arg quote "$QUOTE_STATUS" \
  --arg asset "$ASSET_STATUS" \
  '{
    contextDefinition: $contextDefinition,
    salesTransactionItemAttribute: $sti,
    assetActionSourceAttribute: $aas,
    orderEntitiesMapping: $order,
    quoteEntitiesMapping: $quote,
    assetEntitiesMapping: $asset
  }')"

MANUAL_NOTE="AssetToSalesTransactionMapping not automated"

if [[ "$DRY_RUN" == true ]]; then
  jq -n --argjson plan "$PLAN" --arg manual "$MANUAL_NOTE" \
    '{status:"dry-run", plannedChanges:$plan, manualCheckpoint:$manual}'
  exit 0
fi

if [[ "$STI_STATUS" == "already_present" && "$AAS_STATUS" == "already_present" && \
      "$ORDER_STATUS" == "already_present" && "$QUOTE_STATUS" == "already_present" && \
      "$ASSET_STATUS" == "already_present" ]]; then
  jq -n --argjson plan "$PLAN" --arg manual "$MANUAL_NOTE" \
    '{status:"unchanged", plannedChanges:$plan, manualCheckpoint:$manual}'
  exit 0
fi

RESULT="$(sf project deploy start \
  --source-dir "$CONTEXT_FILE" \
  --target-org "$TARGET_ORG" \
  --json)" || {
  echo "Context definition deployment failed" >&2
  exit 3
}

printf "%s" "$RESULT" | jq --argjson plan "$PLAN" --arg manual "$MANUAL_NOTE" '{
  status:"deployed",
  plannedChanges:$plan,
  manualCheckpoint: ($manual + "; activate context definition in Setup if required"),
  deploy:.result
}'
