#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<EOF
Usage: $(basename "$0") --decision-table-id ID [--target-org ALIAS] [--dataset-link-name NAME]

Inspect DecisionTableParameter metadata and emit a payload skeleton.

Options:
  --decision-table-id ID      DecisionTable Id, commonly starts with 0lD.
  --target-org ALIAS          sf CLI org alias or username. Defaults to default org.
  --dataset-link-name NAME    Include this datasetLinkName in the suggested payload.
  --help                      Print this help.
EOF
}

DECISION_TABLE_ID=""
TARGET_ORG=""
DATASET_LINK_NAME=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --decision-table-id) DECISION_TABLE_ID="$2"; shift 2 ;;
    --target-org) TARGET_ORG="$2"; shift 2 ;;
    --dataset-link-name) DATASET_LINK_NAME="$2"; shift 2 ;;
    --help|-h) usage; exit 0 ;;
    *) echo "Unknown argument: $1" >&2; usage; exit 1 ;;
  esac
done

[[ -z "$DECISION_TABLE_ID" ]] && { echo "Error: --decision-table-id is required" >&2; usage; exit 1; }

command -v sf >/dev/null 2>&1 || { echo "Error: sf CLI not found" >&2; exit 2; }
command -v jq >/dev/null 2>&1 || { echo "Error: jq is required" >&2; exit 2; }

ORG_FLAG=()
[[ -n "$TARGET_ORG" ]] && ORG_FLAG=(--target-org "$TARGET_ORG")

has_field() {
  jq -e --arg f "$1" '.result.fields[] | select(.name == $f)' "$DESCRIBE_FILE" >/dev/null
}

TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT
DESCRIBE_FILE="$TMP_DIR/DecisionTableParameter.describe.json"

sf sobject describe --sobject DecisionTableParameter "${ORG_FLAG[@]}" --json > "$DESCRIBE_FILE"

FIELDS=(Id)
for candidate in \
  Name DeveloperName MasterLabel DecisionTableId FieldName FieldApiName \
  ParameterName ParameterType Direction DataType Operator IsRequired \
  IsInput IsOutput SourceObject Sequence SortOrder DisplayOrder; do
  if has_field "$candidate"; then
    FIELDS+=("$candidate")
  fi
done

SELECT_FIELDS="$(IFS=, ; echo "${FIELDS[*]}")"

PARAM_QUERY="
SELECT ${SELECT_FIELDS}
FROM DecisionTableParameter
WHERE DecisionTableId = '${DECISION_TABLE_ID}'
ORDER BY Name
"

TABLE_QUERY="
SELECT Id, DeveloperName, MasterLabel, Type, Status, SourceObject,
       ExecutionType, UsageType, RefreshStatus
FROM DecisionTable
WHERE Id = '${DECISION_TABLE_ID}'
LIMIT 1
"

params_json="$(sf data query --query "$PARAM_QUERY" "${ORG_FLAG[@]}" --json | jq '.result.records | map(del(.attributes))')"
table_json="$(sf data query --query "$TABLE_QUERY" "${ORG_FLAG[@]}" --json | jq '.result.records[0] | del(.attributes)')"

jq -n \
  --argjson table "$table_json" \
  --argjson params "$params_json" \
  --arg datasetLinkName "$DATASET_LINK_NAME" '
  def val($o; $names):
    reduce $names[] as $n (null; if . == null and ($o[$n] != null) then $o[$n] else . end);
  def text($v): ($v // "" | tostring | ascii_downcase);
  def field_name($p):
    val($p; ["FieldName","FieldApiName","ParameterName","DeveloperName","Name"]);
  def operator($p): ($p.Operator // "Equals");
  def looks_output($p):
    (text($p.ParameterType) | contains("output")) or
    (text($p.Direction) | contains("output")) or
    ($p.IsOutput == true);
  def looks_input($p):
    ($p.IsInput == true) or
    ((text($p.ParameterType) | contains("input")) and (looks_output($p) | not)) or
    ((text($p.Direction) | contains("input")) and (looks_output($p) | not));
  def input_params:
    ($params | map(select(looks_input(.)))) as $classified
    | if ($classified | length) > 0
      then $classified
      else ($params | map(select((looks_output(.) | not))))
      end;
  {
    decisionTable: $table,
    parameters: $params,
    inferredInputs: (input_params | map({
      fieldName: field_name(.),
      dataType: (.DataType // null),
      operator: operator(.),
      required: (.IsRequired // null),
      sourceObject: (.SourceObject // null)
    })),
    suggestedPayload: (
      {
        conditions: [
          {
            conditionsList: (
              input_params
              | map({
                  fieldName: field_name(.),
                  value: null,
                  operator: operator(.)
                })
            )
          }
        ]
      }
      | if $datasetLinkName != "" then . + {datasetLinkName: $datasetLinkName} else . end
    )
  }'
