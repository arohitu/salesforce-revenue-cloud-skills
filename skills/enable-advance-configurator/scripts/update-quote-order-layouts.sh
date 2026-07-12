#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<EOF
Usage: $(basename "$0") --target-org ALIAS [--work-dir DIR] [--dry-run | --confirm]

Retrieve Quote and Order layouts from the org, add SalesTransactionTypeId, and deploy.

Options:
  --target-org ALIAS   Required sf org alias/username
  --work-dir DIR       Working directory for retrieved layouts (default: ./build/adv-config-layouts)
  --dry-run            Retrieve and report whether field needs adding; do not deploy
  --confirm            Retrieve, update if needed, and deploy layouts
  --help               Show this help

Field added: SalesTransactionTypeId (UI label: Sales Transaction Type)
Layouts: Quote-Quote Layout, Order-Order Layout
EOF
}

TARGET_ORG=""
WORK_DIR="./build/adv-config-layouts"
DRY_RUN=false
CONFIRM=false
FIELD="SalesTransactionTypeId"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --target-org) TARGET_ORG="$2"; shift 2 ;;
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
if [[ "$DRY_RUN" == true && "$CONFIRM" == true ]]; then
  echo "Error: use only one of --dry-run or --confirm" >&2
  exit 1
fi
if [[ "$DRY_RUN" == false && "$CONFIRM" == false ]]; then
  echo "Error: choose --dry-run or --confirm" >&2
  exit 1
fi

LAYOUTS_DIR="$WORK_DIR/force-app/main/default/layouts"
mkdir -p "$LAYOUTS_DIR"

sf project retrieve start \
  --metadata "Layout:Quote-Quote Layout" "Layout:Order-Order Layout" \
  --target-org "$TARGET_ORG" \
  --output-dir "$WORK_DIR" \
  --json >/dev/null

add_field_to_layout() {
  local layout_file="$1"
  [[ -f "$layout_file" ]] || return 1

  if grep -q "<field>$FIELD</field>" "$layout_file"; then
    echo "already_present"
    return 0
  fi

  awk -v field="$FIELD" '
    /<layoutSections>/ { in_sections=1 }
    in_sections && /<\/layoutColumns>/ && !added {
      print "            <layoutItems>"
      print "                <behavior>Edit</behavior>"
      print "                <field>" field "</field>"
      print "            </layoutItems>"
      added=1
    }
    { print }
  ' "$layout_file" > "${layout_file}.tmp"
  mv "${layout_file}.tmp" "$layout_file"
  echo "added"
}

QUOTE_LAYOUT="$LAYOUTS_DIR/Quote-Quote Layout.layout-meta.xml"
ORDER_LAYOUT="$LAYOUTS_DIR/Order-Order Layout.layout-meta.xml"

QUOTE_STATUS="$(add_field_to_layout "$QUOTE_LAYOUT" || echo "missing")"
ORDER_STATUS="$(add_field_to_layout "$ORDER_LAYOUT" || echo "missing")"

PLAN="$(jq -n \
  --arg quote "$QUOTE_STATUS" \
  --arg order "$ORDER_STATUS" \
  --arg field "$FIELD" \
  '{
    field: $field,
    quoteLayout: $quote,
    orderLayout: $order
  }')"

if [[ "$DRY_RUN" == true ]]; then
  jq -n --argjson plan "$PLAN" '{status:"dry-run", plannedChanges:$plan}'
  exit 0
fi

if [[ "$QUOTE_STATUS" == "missing" || "$ORDER_STATUS" == "missing" ]]; then
  echo "Error: one or both layouts missing after retrieve" >&2
  exit 3
fi

if [[ "$QUOTE_STATUS" == "already_present" && "$ORDER_STATUS" == "already_present" ]]; then
  jq -n --argjson plan "$PLAN" '{status:"unchanged", plannedChanges:$plan}'
  exit 0
fi

RESULT="$(sf project deploy start \
  --source-dir "$LAYOUTS_DIR" \
  --target-org "$TARGET_ORG" \
  --json)" || {
  echo "Layout deployment failed" >&2
  exit 3
}

printf "%s" "$RESULT" | jq --argjson plan "$PLAN" '{status:"deployed", plannedChanges:$plan, deploy:.result}'
