#!/usr/bin/env bash
#
# check-orphans.sh
#
# Finds common PCM modeling defects:
#   1. Bundles (Product2.Type='Bundle') with zero ProductRelatedComponent rows
#   2. Configurable bundles whose components are not assigned to any group
#   3. Active classifications with no products linked via Product2.BasedOnId
#   4. Qualification / disqualification rules whose effective window is closed
#   5. ProductRelComponentOverride rows whose OverrideContextId no longer exists
#   6. ProductCategoryProduct rows whose product or category is inactive/deleted
#
# Output: JSON report on stdout. Human summary on stderr unless --quiet.

set -euo pipefail

usage() {
  cat <<EOF
Usage: $(basename "$0") [--target-org ALIAS] [--quiet]

Exit codes:
  0  no orphans found
  3  orphans found (still exits 0 by default; use --strict to make this fail)
  1  bad arguments
  2  sf CLI / jq missing
EOF
}

TARGET_ORG=""
QUIET=0
STRICT=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --target-org) TARGET_ORG="$2"; shift 2 ;;
    --quiet)      QUIET=1; shift ;;
    --strict)     STRICT=1; shift ;;
    --help|-h)    usage; exit 0 ;;
    *)            echo "Unknown: $1" >&2; usage; exit 1 ;;
  esac
done

command -v sf >/dev/null 2>&1 || { echo "sf CLI not found" >&2; exit 2; }
command -v jq >/dev/null 2>&1 || { echo "jq required" >&2; exit 2; }

ORG_FLAG=()
[[ -n "$TARGET_ORG" ]] && ORG_FLAG=(--target-org "$TARGET_ORG")

q() {
  sf data query --query "$1" "${ORG_FLAG[@]}" --json 2>/dev/null \
    | jq '.result.records'
}

# 1. Bundles with no components
empty_bundles=$(q "
  SELECT Id, Name, ProductCode FROM Product2
  WHERE Type = 'Bundle' AND Id NOT IN (
    SELECT ParentProductId FROM ProductRelatedComponent
  )")

# 2. Configurable bundles with components missing groups
ungrouped=$(q "
  SELECT Id, ParentProductId, ParentProduct.Name, ChildProductId, ChildProduct.Name
  FROM ProductRelatedComponent
  WHERE ProductComponentGroupId = NULL
    AND ParentProduct.ConfigureDuringSale = 'Allowed'")

# 3. Active classifications with no products
unused_classifications=$(q "
  SELECT Id, Name, Code FROM ProductClassification
  WHERE Status = 'Active' AND Id NOT IN (
    SELECT BasedOnId FROM Product2 WHERE BasedOnId != NULL
  )")

# 4. Expired qualification/disqualification rules
expired_qual=$(q "
  SELECT Id, ProductId, Product.Name, EffectiveFromDate, EffectiveToDate
  FROM ProductQualification
  WHERE EffectiveToDate != NULL AND EffectiveToDate < TODAY")
expired_disqual=$(q "
  SELECT Id, ProductId, Product.Name, EffectiveFromDate, EffectiveToDate
  FROM ProductDisqualification
  WHERE EffectiveToDate != NULL AND EffectiveToDate < TODAY")

# 5. Orphan overrides — context product missing or inactive
orphan_overrides=$(q "
  SELECT Id, OverrideContextId
  FROM ProductRelComponentOverride
  WHERE OverrideContextId NOT IN (
    SELECT Id FROM Product2 WHERE IsActive = true
  )")

# 6. Orphan category-product joins
orphan_pcp=$(q "
  SELECT Id, ProductId, ProductCategoryId
  FROM ProductCategoryProduct
  WHERE ProductId NOT IN (SELECT Id FROM Product2 WHERE IsActive = true)")

count() { echo "$1" | jq 'length'; }
total=0
for j in "$empty_bundles" "$ungrouped" "$unused_classifications" \
         "$expired_qual" "$expired_disqual" "$orphan_overrides" "$orphan_pcp"; do
  n=$(count "$j"); total=$((total + n))
done

result=$(jq -n \
  --argjson eb "$empty_bundles" \
  --argjson ug "$ungrouped" \
  --argjson uc "$unused_classifications" \
  --argjson eq "$expired_qual" \
  --argjson ed "$expired_disqual" \
  --argjson oo "$orphan_overrides" \
  --argjson op "$orphan_pcp" \
  --argjson t "$total" '
  {
    total_orphans:$t,
    empty_bundles:$eb,
    ungrouped_components_in_configurable_bundles:$ug,
    unused_active_classifications:$uc,
    expired_qualifications:$eq,
    expired_disqualifications:$ed,
    orphan_component_overrides:$oo,
    orphan_category_product_joins:$op
  }')

if [[ "$QUIET" -eq 0 ]]; then
  {
    echo "─── PCM Orphan Report ──────────────────"
    echo "  empty bundles                 $(count "$empty_bundles")"
    echo "  ungrouped configurable comps  $(count "$ungrouped")"
    echo "  unused active classifications $(count "$unused_classifications")"
    echo "  expired qualifications        $(count "$expired_qual")"
    echo "  expired disqualifications     $(count "$expired_disqual")"
    echo "  orphan component overrides    $(count "$orphan_overrides")"
    echo "  orphan category-product joins $(count "$orphan_pcp")"
    echo "  ────────────────────────"
    echo "  total                          $total"
  } >&2
fi

echo "$result"

if [[ "$total" -gt 0 && "$STRICT" -eq 1 ]]; then
  exit 3
fi
