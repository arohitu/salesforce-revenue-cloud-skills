#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<EOF
Usage: $(basename "$0") --target-org ALIAS [options] [--dry-run | --confirm]

Create or reuse TransactionProcessingType with RuleEngine=AdvancedConfigurator.

Options:
  --target-org ALIAS         Required sf org alias/username
  --developer-name NAME      DeveloperName (default: AdvancedConfiguratorDefault)
  --master-label LABEL       MasterLabel (default: Advanced Configurator Default)
  --description TEXT         Description (default: Advanced Configurator setup)
  --save-type VALUE          SaveType (default: Standard)
  --pricing-preference VAL   Optional PricingPreference
  --tax-preference VAL       Optional TaxPreference
  --rating-preference VAL    Optional RatingPreference
  --api-version XX.X         Override API version
  --dry-run                  Show query and payload; do not mutate org
  --confirm                  Perform create when record does not already exist
  --help                     Show this help
EOF
}

TARGET_ORG=""
DEVELOPER_NAME="AdvancedConfiguratorDefault"
MASTER_LABEL="Advanced Configurator Default"
DESCRIPTION="Advanced Configurator setup"
SAVE_TYPE="Standard"
PRICING_PREFERENCE=""
TAX_PREFERENCE=""
RATING_PREFERENCE=""
API_VERSION=""
DRY_RUN=false
CONFIRM=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --target-org) TARGET_ORG="$2"; shift 2 ;;
    --developer-name) DEVELOPER_NAME="$2"; shift 2 ;;
    --master-label) MASTER_LABEL="$2"; shift 2 ;;
    --description) DESCRIPTION="$2"; shift 2 ;;
    --save-type) SAVE_TYPE="$2"; shift 2 ;;
    --pricing-preference) PRICING_PREFERENCE="$2"; shift 2 ;;
    --tax-preference) TAX_PREFERENCE="$2"; shift 2 ;;
    --rating-preference) RATING_PREFERENCE="$2"; shift 2 ;;
    --api-version) API_VERSION="$2"; shift 2 ;;
    --dry-run) DRY_RUN=true; shift 1 ;;
    --confirm) CONFIRM=true; shift 1 ;;
    --help|-h) usage; exit 0 ;;
    *) echo "Unknown argument: $1" >&2; usage; exit 1 ;;
  esac
done

command -v sf >/dev/null 2>&1 || { echo "Error: sf CLI not found" >&2; exit 2; }
command -v jq >/dev/null 2>&1 || { echo "Error: jq not found" >&2; exit 2; }
command -v curl >/dev/null 2>&1 || { echo "Error: curl not found" >&2; exit 2; }

[[ -n "$TARGET_ORG" ]] || { echo "Error: --target-org is required" >&2; usage; exit 1; }
if [[ "$DRY_RUN" == true && "$CONFIRM" == true ]]; then
  echo "Error: use only one of --dry-run or --confirm" >&2
  exit 1
fi
if [[ "$DRY_RUN" == false && "$CONFIRM" == false ]]; then
  echo "Error: choose --dry-run or --confirm" >&2
  exit 1
fi

ORG_JSON="$(sf org display --verbose --json --target-org "$TARGET_ORG")"
INSTANCE_URL="$(printf "%s" "$ORG_JSON" | jq -r '.result.instanceUrl')"
ACCESS_TOKEN="$(printf "%s" "$ORG_JSON" | jq -r '.result.accessToken')"

if [[ -z "$API_VERSION" ]]; then
  VERSIONS_JSON="$(curl -sS -H "Authorization: Bearer $ACCESS_TOKEN" "$INSTANCE_URL/services/data/")"
  API_VERSION="$(printf "%s" "$VERSIONS_JSON" | jq -r 'map(.version|tonumber)|max')"
fi

safe_dev_name="$(printf "%s" "$DEVELOPER_NAME" | sed "s/'/\\\\'/g")"
EXISTING="$(sf data query --use-tooling-api --json --target-org "$TARGET_ORG" --query \
"SELECT Id, DeveloperName, MasterLabel, RuleEngine FROM TransactionProcessingType WHERE DeveloperName = '$safe_dev_name' LIMIT 1")"

EXISTING_SIZE="$(printf "%s" "$EXISTING" | jq -r '.result.totalSize')"
if [[ "$EXISTING_SIZE" != "0" ]]; then
  printf "%s" "$EXISTING" | jq '{status:"exists", record:(.result.records[0] | del(.attributes))}'
  exit 0
fi

PAYLOAD="$(jq -n \
  --arg dev "$DEVELOPER_NAME" \
  --arg label "$MASTER_LABEL" \
  --arg desc "$DESCRIPTION" \
  --arg save "$SAVE_TYPE" \
  --arg pricing "$PRICING_PREFERENCE" \
  --arg tax "$TAX_PREFERENCE" \
  --arg rating "$RATING_PREFERENCE" \
  '
  {
    DeveloperName: $dev,
    MasterLabel: $label,
    Description: $desc,
    RuleEngine: "AdvancedConfigurator",
    SaveType: $save
  }
  + (if $pricing == "" then {} else {PricingPreference: $pricing} end)
  + (if $tax == "" then {} else {TaxPreference: $tax} end)
  + (if $rating == "" then {} else {RatingPreference: $rating} end)
  ')"

if [[ "$DRY_RUN" == true ]]; then
  jq -n \
    --arg api "$API_VERSION" \
    --arg url "$INSTANCE_URL/services/data/v$API_VERSION/tooling/sobjects/TransactionProcessingType" \
    --argjson payload "$PAYLOAD" \
    '{status:"dry-run", apiVersion:$api, endpoint:$url, payload:$payload}'
  exit 0
fi

RESPONSE="$(curl -sS -X POST \
  -H "Authorization: Bearer $ACCESS_TOKEN" \
  -H "Content-Type: application/json" \
  -d "$PAYLOAD" \
  "$INSTANCE_URL/services/data/v$API_VERSION/tooling/sobjects/TransactionProcessingType")"

printf "%s" "$RESPONSE" | jq '{status:"created", response:.}'
