#!/usr/bin/env bash
#
# describe-pcm-objects.sh
#
# Runs `sf sobject describe` for every Product Catalog Management object and
# writes the JSON schema for each to ./pcm-describe/<Object>.json. Useful for
# confirming which fields and picklist values exist in a specific org/API
# version before authoring queries or load files.
#
# Requires: Salesforce CLI (sf) authenticated to a target org. Read-only.

set -euo pipefail

usage() {
  cat <<EOF
Usage: $(basename "$0") [--target-org ALIAS] [--out DIR]

Options:
  --target-org ALIAS   sf CLI org alias or username. Defaults to default org.
  --out DIR            Output directory. Defaults to ./pcm-describe.
  --help               Print this and exit.

Output:
  A JSON file per PCM object in DIR. Existing files are overwritten.

Exit codes:
  0  success (all objects described, even if some not present in the org)
  1  bad arguments
  2  sf CLI missing or not authenticated
EOF
}

TARGET_ORG=""
OUT_DIR="./pcm-describe"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --target-org) TARGET_ORG="$2"; shift 2 ;;
    --out)        OUT_DIR="$2";    shift 2 ;;
    --help|-h)    usage; exit 0 ;;
    *)            echo "Unknown argument: $1" >&2; usage; exit 1 ;;
  esac
done

if ! command -v sf >/dev/null 2>&1; then
  echo "Error: 'sf' CLI not found on PATH. Install Salesforce CLI." >&2
  exit 2
fi

mkdir -p "$OUT_DIR"

PCM_OBJECTS=(
  AttributeCategory
  AttributeCategoryAttribute
  AttrPicklistExcludedValue
  AttributeDefinition
  AttributePicklist
  AttributePicklistValue
  Catalog
  Product2
  ProductAttributeDefinition
  ProductCategory
  ProductCategoryProduct
  ProductCategoryDisqual
  ProductCategoryQualification
  ProductClassification
  ProductClassificationAttr
  ProductClassificationParent
  ProductComponentGroup
  ProductComponentGrpOverride
  ProductDisqualification
  ProductQualification
  ProductRampSegment
  ProductRelatedComponent
  ProductRelComponentOverride
  ProductRelationshipType
  ProductSellingModel
  ProductSellingModelOption
)

ORG_FLAG=()
[[ -n "$TARGET_ORG" ]] && ORG_FLAG=(--target-org "$TARGET_ORG")

success=0
missing=0
errored=0

for obj in "${PCM_OBJECTS[@]}"; do
  out_file="$OUT_DIR/${obj}.json"
  if sf sobject describe --sobject "$obj" "${ORG_FLAG[@]}" --json \
       > "$out_file" 2> "$OUT_DIR/.${obj}.err"; then
    success=$((success+1))
    rm -f "$OUT_DIR/.${obj}.err"
    echo "ok    $obj" >&2
  else
    if grep -q -i "not.*found\|invalid.*type\|sObject type.*does not exist" \
         "$OUT_DIR/.${obj}.err"; then
      missing=$((missing+1))
      echo "miss  $obj  (not present in org)" >&2
      rm -f "$out_file"
    else
      errored=$((errored+1))
      echo "ERR   $obj  (see $OUT_DIR/.${obj}.err)" >&2
    fi
  fi
done

echo "---" >&2
echo "described: $success, missing: $missing, errored: $errored" >&2

# Emit a summary on stdout so callers can pipe it
printf '{"described":%d,"missing":%d,"errored":%d,"out":"%s"}\n' \
  "$success" "$missing" "$errored" "$OUT_DIR"
