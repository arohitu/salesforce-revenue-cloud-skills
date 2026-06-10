#!/usr/bin/env bash
#
# list-catalogs.sh
#
# Lists active catalogs in the org with their root categories and product
# counts. Quick health check after a deploy to confirm shape of the catalog.

set -euo pipefail

usage() {
  cat <<EOF
Usage: $(basename "$0") [--target-org ALIAS] [--include-inactive] [--json]

Options:
  --target-org ALIAS    sf CLI org alias.
  --include-inactive    Include catalogs whose effective window is closed.
  --json                Emit JSON only to stdout (no human table).
  --help                Print this and exit.

Exit codes:
  0  success
  1  bad arguments
  2  sf CLI / jq missing
EOF
}

TARGET_ORG=""
INCLUDE_INACTIVE=0
JSON_ONLY=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --target-org)        TARGET_ORG="$2"; shift 2 ;;
    --include-inactive)  INCLUDE_INACTIVE=1; shift ;;
    --json)              JSON_ONLY=1; shift ;;
    --help|-h)           usage; exit 0 ;;
    *)                   echo "Unknown: $1" >&2; usage; exit 1 ;;
  esac
done

command -v sf >/dev/null 2>&1 || { echo "sf CLI not found" >&2; exit 2; }
command -v jq >/dev/null 2>&1 || { echo "jq required" >&2; exit 2; }

ORG_FLAG=()
[[ -n "$TARGET_ORG" ]] && ORG_FLAG=(--target-org "$TARGET_ORG")

WHERE_CLAUSE=""
if [[ "$INCLUDE_INACTIVE" -eq 0 ]]; then
  WHERE_CLAUSE="WHERE (EffectiveStartDate = NULL OR EffectiveStartDate <= TODAY)
                 AND (EffectiveEndDate   = NULL OR EffectiveEndDate   >= TODAY)"
fi

catalogs=$(sf data query --query "
  SELECT Id, Name, Code, CatalogType, EffectiveStartDate, EffectiveEndDate
  FROM Catalog ${WHERE_CLAUSE} ORDER BY Name
" "${ORG_FLAG[@]}" --json | jq '.result.records')

result="[]"
while read -r catId catName catCode catType startD endD; do
  rootCount=$(sf data query --query "
    SELECT COUNT() FROM ProductCategory
    WHERE CatalogId = '${catId}' AND ParentCategoryId = NULL
  " "${ORG_FLAG[@]}" --json | jq '.result.totalSize')
  prodCount=$(sf data query --query "
    SELECT COUNT() FROM ProductCategoryProduct
    WHERE ProductCategory.CatalogId = '${catId}'
  " "${ORG_FLAG[@]}" --json | jq '.result.totalSize')
  result=$(jq --arg id "$catId" --arg n "$catName" --arg c "$catCode" \
              --arg t "$catType" --arg s "$startD" --arg e "$endD" \
              --argjson rc "$rootCount" --argjson pc "$prodCount" '
    . + [{
      Id:$id, Name:$n, Code:$c, CatalogType:$t,
      EffectiveStartDate:$s, EffectiveEndDate:$e,
      root_categories:$rc, products:$pc
    }]' <<<"$result")
done < <(echo "$catalogs" | jq -r '.[] |
  [.Id, (.Name|tostring), (.Code//"-"), (.CatalogType//"-"),
   (.EffectiveStartDate//"-"), (.EffectiveEndDate//"-")] | @tsv')

if [[ "$JSON_ONLY" -eq 0 ]]; then
  printf "%-18s  %-30s  %-12s  %-14s  %5s  %7s\n" \
    "Id" "Name" "Code" "Type" "Roots" "Products" >&2
  echo "$result" | jq -r '.[] | [.Id, .Name, .Code, .CatalogType, .root_categories, .products]
        | @tsv' \
    | awk -F'\t' '{printf "%-18s  %-30s  %-12s  %-14s  %5d  %7d\n", $1,$2,$3,$4,$5,$6}' >&2
fi

echo "$result"
