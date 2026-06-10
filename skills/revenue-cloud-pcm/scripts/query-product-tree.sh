#!/usr/bin/env bash
#
# query-product-tree.sh
#
# Given a Product2.Id of a bundle, prints the bundle's structure: name, type,
# component groups, components, attribute count, classification linkage. Use
# this to validate a bundle was modeled correctly before deploying.
#
# Output is JSON on stdout (always); a human-readable tree is printed to stderr
# unless --quiet is set.

set -euo pipefail

usage() {
  cat <<EOF
Usage: $(basename "$0") --product-id ID [--target-org ALIAS] [--quiet]

Required:
  --product-id ID      The Product2.Id of the bundle (15- or 18-char).

Options:
  --target-org ALIAS   sf CLI org alias. Defaults to default org.
  --quiet              Only emit JSON to stdout; no tree on stderr.
  --help               Print this and exit.

Output (stdout):
  JSON: { "product": {...}, "groups": [...], "components": [...],
          "attribute_count": N, "based_on": "<classification>" }

Exit codes:
  0  success
  1  bad arguments / product not found
  2  sf CLI missing or not authenticated
EOF
}

PRODUCT_ID=""
TARGET_ORG=""
QUIET=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --product-id) PRODUCT_ID="$2"; shift 2 ;;
    --target-org) TARGET_ORG="$2"; shift 2 ;;
    --quiet)      QUIET=1; shift ;;
    --help|-h)    usage; exit 0 ;;
    *)            echo "Unknown argument: $1" >&2; usage; exit 1 ;;
  esac
done

[[ -z "$PRODUCT_ID" ]] && { echo "Error: --product-id required" >&2; usage; exit 1; }

command -v sf >/dev/null 2>&1 || {
  echo "Error: 'sf' CLI not found on PATH" >&2; exit 2;
}
command -v jq >/dev/null 2>&1 || {
  echo "Error: 'jq' required for JSON shaping" >&2; exit 2;
}

ORG_FLAG=()
[[ -n "$TARGET_ORG" ]] && ORG_FLAG=(--target-org "$TARGET_ORG")

soql() {
  sf data query --query "$1" "${ORG_FLAG[@]}" --json 2>/dev/null \
    | jq '.result.records'
}

product_json=$(soql "
  SELECT Id, Name, ProductCode, Type, ConfigureDuringSale, IsActive,
         BasedOnId, BasedOn.Name
  FROM Product2 WHERE Id = '${PRODUCT_ID}'
" | jq '.[0]')

[[ "$product_json" == "null" || -z "$product_json" ]] && {
  echo "Error: Product2 ${PRODUCT_ID} not found in org" >&2; exit 1;
}

groups_json=$(soql "
  SELECT Id, Name, MinBundleComponents, MaxBundleComponents, Sequence
  FROM ProductComponentGroup
  WHERE Id IN (
    SELECT ProductComponentGroupId FROM ProductRelatedComponent
    WHERE ParentProductId = '${PRODUCT_ID}'
  ) ORDER BY Sequence")

components_json=$(soql "
  SELECT Id, ChildProductId, ChildProduct.Name, ChildProduct.ProductCode,
         ChildProductClassificationId, ChildProductClassification.Name,
         ProductComponentGroupId, ProductComponentGroup.Name,
         Quantity, MinQuantity, MaxQuantity,
         IsComponentRequired, IsDefaultComponent, IsQuantityEditable,
         QuoteVisibility, Sequence
  FROM ProductRelatedComponent
  WHERE ParentProductId = '${PRODUCT_ID}'
  ORDER BY ProductComponentGroup.Sequence, Sequence")

attr_count=$(sf data query --query "
  SELECT COUNT() FROM ProductAttributeDefinition WHERE Product2Id = '${PRODUCT_ID}'
" "${ORG_FLAG[@]}" --json | jq '.result.totalSize')

# Tree to stderr
if [[ "$QUIET" -eq 0 ]]; then
  echo "─── Product ────────────────────────────────────" >&2
  echo "$product_json" | jq -r '
    "  Name: \(.Name) [\(.ProductCode // "no SKU")]
  Type: \(.Type // "simple")  Configure: \(.ConfigureDuringSale // "None")  Active: \(.IsActive)
  Based on: \(.BasedOn.Name // "(none)")"' >&2
  echo "─── Groups (\($((${#groups_json}>0?$(echo "$groups_json"|jq length):0)))) ────────────────" >&2
  echo "$groups_json" | jq -r '.[] | "  • \(.Name)  cardinality \(.MinBundleComponents // "-")..\(.MaxBundleComponents // "-")"' >&2
  echo "─── Components ─────────────────────────────────" >&2
  echo "$components_json" | jq -r '.[] |
    "  • [\(.ProductComponentGroup.Name // "no-group")] " +
    (if .ChildProduct.Name then
       "\(.ChildProduct.Name) [\(.ChildProduct.ProductCode // "")]"
     else
       "[dyn] classification: \(.ChildProductClassification.Name)"
     end) +
    "  qty \(.Quantity // 1) (\(.MinQuantity // 0)..\(.MaxQuantity // "-"))" +
    (if .IsComponentRequired then " required" else "" end) +
    (if .IsDefaultComponent  then " default"  else "" end)' >&2
  echo "─── Attributes ────────────────────────────────" >&2
  echo "  count: ${attr_count}" >&2
fi

# JSON to stdout
jq -n --argjson p "$product_json" --argjson g "$groups_json" \
      --argjson c "$components_json" --argjson n "$attr_count" '
  {product: $p, groups: $g, components: $c, attribute_count: $n,
   based_on: ($p.BasedOn.Name // null)}'
