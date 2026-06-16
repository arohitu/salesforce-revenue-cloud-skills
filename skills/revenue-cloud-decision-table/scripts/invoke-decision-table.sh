#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<EOF
Usage: $(basename "$0") --decision-table-id ID (--payload-file FILE | --payload-json JSON) [options]

Invoke a Salesforce Decision Table through the Connect REST API.

Options:
  --decision-table-id ID      DecisionTable Id, commonly starts with 0lD.
  --payload-file FILE         JSON request body file.
  --payload-json JSON         JSON request body string.
  --target-org ALIAS          sf CLI org alias or username. Defaults to default org.
  --api-version VERSION       API version, with or without "v". Defaults to v66.0.
  --legacy-lookup             Use /decision-table/<id> instead of /decision-table/lookup/<id>.
  --help                      Print this help.
EOF
}

DECISION_TABLE_ID=""
PAYLOAD_FILE=""
PAYLOAD_JSON=""
TARGET_ORG=""
API_VERSION="v66.0"
LEGACY_LOOKUP=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --decision-table-id) DECISION_TABLE_ID="$2"; shift 2 ;;
    --payload-file) PAYLOAD_FILE="$2"; shift 2 ;;
    --payload-json) PAYLOAD_JSON="$2"; shift 2 ;;
    --target-org) TARGET_ORG="$2"; shift 2 ;;
    --api-version) API_VERSION="$2"; shift 2 ;;
    --legacy-lookup) LEGACY_LOOKUP=1; shift ;;
    --help|-h) usage; exit 0 ;;
    *) echo "Unknown argument: $1" >&2; usage; exit 1 ;;
  esac
done

[[ -z "$DECISION_TABLE_ID" ]] && { echo "Error: --decision-table-id is required" >&2; usage; exit 1; }
if [[ -z "$PAYLOAD_FILE" && -z "$PAYLOAD_JSON" ]]; then
  echo "Error: provide --payload-file or --payload-json" >&2
  usage
  exit 1
fi
if [[ -n "$PAYLOAD_FILE" && -n "$PAYLOAD_JSON" ]]; then
  echo "Error: use only one of --payload-file or --payload-json" >&2
  usage
  exit 1
fi

command -v sf >/dev/null 2>&1 || { echo "Error: sf CLI not found" >&2; exit 2; }
command -v jq >/dev/null 2>&1 || { echo "Error: jq is required" >&2; exit 2; }
command -v curl >/dev/null 2>&1 || { echo "Error: curl is required" >&2; exit 2; }

ORG_FLAG=()
[[ -n "$TARGET_ORG" ]] && ORG_FLAG=(--target-org "$TARGET_ORG")

case "$API_VERSION" in
  v*) ;;
  *) API_VERSION="v${API_VERSION}" ;;
esac

TMP_PAYLOAD=""
if [[ -n "$PAYLOAD_FILE" ]]; then
  [[ -f "$PAYLOAD_FILE" ]] || { echo "Error: payload file not found: $PAYLOAD_FILE" >&2; exit 1; }
  jq empty "$PAYLOAD_FILE"
  DATA_ARG=(--data @"$PAYLOAD_FILE")
else
  TMP_PAYLOAD="$(mktemp)"
  trap 'rm -f "$TMP_PAYLOAD"' EXIT
  printf "%s" "$PAYLOAD_JSON" > "$TMP_PAYLOAD"
  jq empty "$TMP_PAYLOAD"
  DATA_ARG=(--data @"$TMP_PAYLOAD")
fi

org_json="$(sf org display "${ORG_FLAG[@]}" --verbose --json)"
instance_url="$(printf "%s" "$org_json" | jq -r '.result.instanceUrl // empty')"
access_token="$(printf "%s" "$org_json" | jq -r '.result.accessToken // empty')"

[[ -n "$instance_url" ]] || { echo "Error: could not determine instanceUrl from sf org display" >&2; exit 2; }
[[ -n "$access_token" ]] || { echo "Error: could not obtain accessToken from sf org display; re-authenticate the org" >&2; exit 2; }

if [[ "$LEGACY_LOOKUP" -eq 1 ]]; then
  path="/services/data/${API_VERSION}/connect/business-rules/decision-table/${DECISION_TABLE_ID}"
else
  path="/services/data/${API_VERSION}/connect/business-rules/decision-table/lookup/${DECISION_TABLE_ID}"
fi

curl --silent --show-error --request POST \
  "${instance_url}${path}" \
  --header "Authorization: Bearer ${access_token}" \
  --header "Content-Type: application/json" \
  "${DATA_ARG[@]}" \
  | jq .
