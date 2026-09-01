#!/usr/bin/env bash
#
# call-pricing-apis.sh
# Call a Salesforce Pricing Business API resource (Revenue Cloud / Agentforce Revenue
# Management) with plain curl. Authenticates through the Salesforce CLI (sf) and always
# uses the latest API version the org supports, never below v67.0.
#
# Unlike a single "call everything" smoke test, these resources mix GET/POST and use
# path/query parameters, so you call one resource at a time via --resource.
#
set -euo pipefail

MIN_VERSION="67.0"
PLACEHOLDER_INSTANCE="https://INSTANCE.my.salesforce.com"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
PAYLOAD_DIR="${SKILL_DIR}/payloads"

# Resource registry: "name|method|pathTemplate|minVersion|payloadFile".
# Path tokens in {braces} are filled from --param key=value. Empty payload = no body.
RESOURCES=(
  "pricing|POST|/connect/core-pricing/pricing|60.0|pricing.json"
  "price-context|POST|/connect/core-pricing/price-contexts/{contextId}|60.0|price-context.json"
  "pbe-derived-pricing|POST|/connect/core-pricing/pbeDerivedPricingSourceProduct|61.0|pbe-derived-pricing.json"
  "sync|GET|/connect/core-pricing/sync/{pricingSyncOrigin}|60.0|"
  "recipe|GET|/connect/core-pricing/recipe|60.0|"
  "recipe-valid-elements|GET|/connect/core-pricing/revenue/pricing-recipe/valid-elements|68.0|"
  "recipe-clone|POST|/connect/core-pricing/revenue/pricing-recipe/clone|68.0|recipe-clone.json"
  "recipe-mapping|POST|/connect/core-pricing/recipe/mapping|60.0|recipe-mapping.json"
  "versioned-revise-details|POST|/connect/core-pricing/versioned-revise-details|60.0|versioned-revise-details.json"
  "waterfall-get|GET|/connect/core-pricing/waterfall/{lineItemId}/{executionId}|60.0|"
  "waterfall|POST|/connect/core-pricing/waterfall|60.0|waterfall.json"
  "api-execution-logs|GET|/connect/core-pricing/apiexecutionlogs/{executionId}|63.0|"
  "pricing-process-execution|GET|/connect/core-pricing/pricing-process-execution/{executionId}|63.0|"
  "pricing-process-execution-lineitems|GET|/connect/core-pricing/pricing-process-execution/lineitems/{executionId}/{executionType}|63.0|"
  "simulation-input-variables|GET|/connect/core-pricing/simulationInputVariablesWithData|60.0|"
  "procedure-plan-definitions-get|GET|/connect/procedure-plan-definitions|62.0|"
  "procedure-plan-definitions|POST|/connect/procedure-plan-definitions|62.0|procedure-plan-definition.json"
  "procedure-plan-definition-by-id|GET|/connect/procedure-plan-definitions/{procedurePlanDefinitionId}|62.0|"
  "procedure-plan-evaluate|POST|/connect/procedure-plan-definitions/evaluate|62.0|procedure-plan-evaluate.json"
  "procedure-plan-evaluate-by-name|POST|/connect/procedure-plan-definitions/evaluate/{procedurePlanDefinitionName}|62.0|procedure-plan-evaluate-by-name.json"
  "procedure-plan-version|POST|/connect/procedure-plan-definitions/{procedurePlanDefinitionId}/version|62.0|procedure-plan-version.json"
  "procedure-plan-version-details|GET|/connect/procedure-plan-definitions/versions/{procedurePlanVersionId}|62.0|"
)

# ---- helpers ---------------------------------------------------------------

log() { printf '%s\n' "$*" >&2; }

die() { # die <exit_code> <message>
  local code="$1"; shift
  log "Error: $*"
  exit "$code"
}

# Print the greater of two dotted versions (e.g. 67.0 vs 64.0).
version_max() {
  awk -v a="$1" -v b="$2" 'BEGIN { print (a+0 >= b+0) ? a : b }'
}

# Return 0 if version $1 < version $2.
version_lt() {
  awk -v a="$1" -v b="$2" 'BEGIN { exit (a+0 < b+0) ? 0 : 1 }'
}

usage() {
  cat <<'EOF'
Usage: call-pricing-apis.sh --resource NAME [OPTIONS]

Call one Salesforce Pricing Business API resource (Revenue Cloud / Agentforce Revenue
Management) with curl. Authenticates via the Salesforce CLI (`sf org display --json`)
and uses the latest API version the org supports, floored at v67.0.

Options:
  --resource NAME      Resource to call (required; see --list).
  --target-org ALIAS   Salesforce CLI org alias/username (else the CLI default org).
  --api-version VER    Override the API version (e.g. 68.0). Must be >= 67.0.
                       Default: latest version reported by the org, floored at 67.0.
  --param KEY=VALUE    Fill a path token, e.g. --param contextId=0U3RM... (repeatable).
  --query STRING       Raw query string appended to the URL, e.g.
                       --query 'pricingUsageSubType=RevenueCloud'.
  --payload FILE       JSON body file for POST resources (default: payloads/<name>.json).
  --payload-dir DIR    Directory holding default payloads. Default: <skill>/payloads
  --dry-run            Print the resolved URL and curl command; make no call. Works offline.
  --list               List resources (name, method, path, min version), then exit.
  --output FILE        Write the JSON result line to FILE instead of stdout ("-" = stdout).
  -h, --help           Show this help and exit.

Output:
  One JSON object on stdout, e.g.
    {"resource":"pricing","method":"POST","version":"68.0","url":"...","http_status":200,"ok":true,"response":{...}}
  Diagnostics and progress go to stderr.

Prerequisites:
  Real callouts require the Salesforce CLI (`sf`) with an authorized org, `curl`, and
  `jq`. `--list` and `--dry-run` only require `curl` (and awk). On Windows, run under
  Git Bash or WSL.

Examples:
  call-pricing-apis.sh --list
  call-pricing-apis.sh --resource recipe --target-org myorg
  call-pricing-apis.sh --resource pricing --target-org myorg --payload payloads/pricing.json
  call-pricing-apis.sh --resource recipe-valid-elements --query 'pricingUsageSubType=RevenueCloud' --target-org myorg
  call-pricing-apis.sh --resource waterfall-get --param lineItemId=item1 --param executionId=2636 --target-org myorg
  call-pricing-apis.sh --resource pricing --dry-run

Exit codes:
  0  The callout returned a 2xx status (or --list / --dry-run succeeded).
  2  Invalid arguments or usage error (including unfilled path tokens).
  3  Authentication / Salesforce CLI failure, or version discovery could not proceed.
  4  The callout returned a non-2xx status.
EOF
}

# ---- argument parsing ------------------------------------------------------

TARGET_ORG=""
API_VERSION_OVERRIDE=""
ONLY_RESOURCE=""
QUERY_STRING=""
PAYLOAD_OVERRIDE=""
DRY_RUN="false"
DO_LIST="false"
OUTPUT="-"
declare -a PARAM_KEYS=()
declare -a PARAM_VALS=()

while [[ $# -gt 0 ]]; do
  case "$1" in
    --resource) ONLY_RESOURCE="${2:-}"; shift 2 ;;
    --target-org) TARGET_ORG="${2:-}"; shift 2 ;;
    --api-version) API_VERSION_OVERRIDE="${2:-}"; shift 2 ;;
    --param)
      pair="${2:-}"
      [[ "${pair}" == *=* ]] || die 2 "--param expects KEY=VALUE, got '${pair}'."
      PARAM_KEYS+=("${pair%%=*}")
      PARAM_VALS+=("${pair#*=}")
      shift 2 ;;
    --query) QUERY_STRING="${2:-}"; shift 2 ;;
    --payload) PAYLOAD_OVERRIDE="${2:-}"; shift 2 ;;
    --payload-dir) PAYLOAD_DIR="${2:-}"; shift 2 ;;
    --dry-run) DRY_RUN="true"; shift ;;
    --list) DO_LIST="true"; shift ;;
    --output) OUTPUT="${2:-}"; shift 2 ;;
    -h|--help) usage; exit 0 ;;
    *) die 2 "Unknown argument: $1 (use --help)" ;;
  esac
done

# ---- --list (no dependencies beyond the shell) -----------------------------

if [[ "${DO_LIST}" == "true" ]]; then
  printf '%-38s %-6s %-8s %s\n' "RESOURCE" "METHOD" "MIN_VER" "PATH"
  for entry in "${RESOURCES[@]}"; do
    IFS='|' read -r name method path minver _payload <<<"${entry}"
    printf '%-38s %-6s %-8s %s\n' "${name}" "${method}" "${minver}" "${path}"
  done
  exit 0
fi

# Resolve the selected resource.
[[ -n "${ONLY_RESOURCE}" ]] || die 2 "--resource is required. Run --list to see valid names."

SEL_ENTRY=""
for entry in "${RESOURCES[@]}"; do
  IFS='|' read -r name _ _ _ _ <<<"${entry}"
  [[ "${name}" == "${ONLY_RESOURCE}" ]] && SEL_ENTRY="${entry}"
done
[[ -n "${SEL_ENTRY}" ]] || die 2 "Unknown --resource '${ONLY_RESOURCE}'. Run --list to see valid names."

IFS='|' read -r R_NAME R_METHOD R_PATH R_MINVER R_PAYLOAD <<<"${SEL_ENTRY}"

# Validate an explicit version override against the v67.0 floor.
if [[ -n "${API_VERSION_OVERRIDE}" ]]; then
  if version_lt "${API_VERSION_OVERRIDE}" "${MIN_VERSION}"; then
    die 2 "--api-version ${API_VERSION_OVERRIDE} is below the required minimum of v${MIN_VERSION}."
  fi
fi

# curl and awk are always required.
command -v curl >/dev/null 2>&1 || die 3 "curl not found on PATH."
command -v awk  >/dev/null 2>&1 || die 3 "awk not found on PATH."

# ---- substitute path tokens ------------------------------------------------

RESOLVED_PATH="${R_PATH}"
for i in "${!PARAM_KEYS[@]}"; do
  RESOLVED_PATH="${RESOLVED_PATH//\{${PARAM_KEYS[$i]}\}/${PARAM_VALS[$i]}}"
done

# Any remaining {token} means a required path parameter was not supplied.
if [[ "${RESOLVED_PATH}" == *"{"* ]]; then
  missing="$(printf '%s' "${RESOLVED_PATH}" | grep -o '{[^}]*}' | tr '\n' ' ')"
  die 2 "Missing path parameter(s) for '${R_NAME}': ${missing}Supply with --param key=value."
fi

# ---- authentication (fatal for real runs, best-effort for --dry-run) -------

INSTANCE_URL=""
ACCESS_TOKEN=""
AUTHED="false"

authenticate() {
  command -v sf >/dev/null 2>&1 || return 1
  command -v jq >/dev/null 2>&1 || return 1
  local sf_args=(org display --json)
  [[ -n "${TARGET_ORG}" ]] && sf_args+=(--target-org "${TARGET_ORG}")
  log "Resolving org credentials via: sf ${sf_args[*]}"
  local org_json
  org_json="$(sf "${sf_args[@]}" 2>/dev/null)" || return 1
  INSTANCE_URL="$(printf '%s' "${org_json}" | jq -r '.result.instanceUrl // empty')"
  ACCESS_TOKEN="$(printf '%s' "${org_json}" | jq -r '.result.accessToken // empty')"
  [[ -n "${INSTANCE_URL}" && -n "${ACCESS_TOKEN}" ]] || return 1
  INSTANCE_URL="${INSTANCE_URL%/}"
  return 0
}

if authenticate; then
  AUTHED="true"
else
  if [[ "${DRY_RUN}" == "true" ]]; then
    log "Warning: no authorized org (sf/jq); using placeholder host for dry-run."
    INSTANCE_URL="${PLACEHOLDER_INSTANCE}"
  else
    die 3 "Authentication failed. Requires 'sf' (authorized org) and 'jq'. Authorize with 'sf org login web' or pass --target-org."
  fi
fi

# ---- resolve API version ---------------------------------------------------

if [[ -n "${API_VERSION_OVERRIDE}" ]]; then
  API_VERSION="${API_VERSION_OVERRIDE}"
  log "Using API version v${API_VERSION} (from --api-version)."
elif [[ "${AUTHED}" == "true" ]]; then
  LATEST=""
  if VERSIONS_JSON="$(curl -sS -H "Authorization: Bearer ${ACCESS_TOKEN}" "${INSTANCE_URL}/services/data/" 2>/dev/null)"; then
    LATEST="$(printf '%s' "${VERSIONS_JSON}" | jq -r 'map(.version) | max // empty' 2>/dev/null || true)"
  fi
  if [[ -z "${LATEST}" ]]; then
    log "Warning: could not discover the org's latest API version; falling back to v${MIN_VERSION}."
    API_VERSION="${MIN_VERSION}"
  else
    API_VERSION="$(version_max "${LATEST}" "${MIN_VERSION}")"
    log "Discovered latest org API version v${LATEST}; using v${API_VERSION} (floor v${MIN_VERSION})."
  fi
else
  API_VERSION="${MIN_VERSION}"
  log "No org available; using floor API version v${API_VERSION} for dry-run."
fi

# Never call below the resource's documented minimum, nor below the global floor.
EFF_VERSION="$(version_max "${API_VERSION}" "${R_MINVER}")"

# ---- build URL -------------------------------------------------------------

URL="${INSTANCE_URL}/services/data/v${EFF_VERSION}${RESOLVED_PATH}"
if [[ -n "${QUERY_STRING}" ]]; then
  URL="${URL}?${QUERY_STRING#\?}"
fi

# ---- resolve payload (POST only) -------------------------------------------

PAYLOAD_PATH=""
if [[ "${R_METHOD}" == "POST" || "${R_METHOD}" == "PATCH" ]]; then
  if [[ -n "${PAYLOAD_OVERRIDE}" ]]; then
    PAYLOAD_PATH="${PAYLOAD_OVERRIDE}"
  elif [[ -n "${R_PAYLOAD}" ]]; then
    PAYLOAD_PATH="${PAYLOAD_DIR}/${R_PAYLOAD}"
  fi
  if [[ -n "${PAYLOAD_PATH}" && ! -f "${PAYLOAD_PATH}" ]]; then
    die 2 "Payload file not found: ${PAYLOAD_PATH} (use --payload FILE)."
  fi
fi

# ---- output sink -----------------------------------------------------------

emit() {
  if [[ "${OUTPUT}" == "-" ]]; then
    printf '%s\n' "$1"
  else
    printf '%s\n' "$1" >>"${OUTPUT}"
  fi
}
[[ "${OUTPUT}" != "-" ]] && : >"${OUTPUT}"

# ---- dry-run ---------------------------------------------------------------

if [[ "${DRY_RUN}" == "true" ]]; then
  log "[dry-run] ${R_NAME} -> ${R_METHOD} ${URL}"
  if [[ -n "${PAYLOAD_PATH}" ]]; then
    log "          curl -sS -X ${R_METHOD} -H 'Authorization: Bearer ***' -H 'Content-Type: application/json' --data @${PAYLOAD_PATH} '${URL}'"
    emit "$(jq -nc --arg r "${R_NAME}" --arg m "${R_METHOD}" --arg v "${EFF_VERSION}" --arg u "${URL}" --arg p "${PAYLOAD_PATH}" \
      '{resource:$r,method:$m,version:$v,url:$u,payload:$p,dry_run:true}' 2>/dev/null || printf '{"resource":"%s","method":"%s","version":"%s","url":"%s","dry_run":true}' "${R_NAME}" "${R_METHOD}" "${EFF_VERSION}" "${URL}")"
  else
    log "          curl -sS -X ${R_METHOD} -H 'Authorization: Bearer ***' '${URL}'"
    emit "$(jq -nc --arg r "${R_NAME}" --arg m "${R_METHOD}" --arg v "${EFF_VERSION}" --arg u "${URL}" \
      '{resource:$r,method:$m,version:$v,url:$u,dry_run:true}' 2>/dev/null || printf '{"resource":"%s","method":"%s","version":"%s","url":"%s","dry_run":true}' "${R_NAME}" "${R_METHOD}" "${EFF_VERSION}" "${URL}")"
  fi
  exit 0
fi

# ---- callout ---------------------------------------------------------------

command -v jq >/dev/null 2>&1 || die 3 "jq not found on PATH (required for real callouts)."

log "Calling ${R_NAME} (${R_METHOD} v${EFF_VERSION})..."
body_file="$(mktemp)"
curl_args=(-sS -o "${body_file}" -w '%{http_code}' -X "${R_METHOD}" -H "Authorization: Bearer ${ACCESS_TOKEN}")
if [[ -n "${PAYLOAD_PATH}" ]]; then
  curl_args+=(-H "Content-Type: application/json" --data "@${PAYLOAD_PATH}")
fi
curl_args+=("${URL}")

http_status="$(curl "${curl_args[@]}" 2>/dev/null || true)"
body="$(cat "${body_file}" 2>/dev/null || true)"
rm -f "${body_file}" 2>/dev/null || true

ok="false"
overall_rc=0
if [[ "${http_status}" =~ ^2[0-9][0-9]$ ]]; then
  ok="true"
else
  overall_rc=4
fi

if printf '%s' "${body}" | jq -e . >/dev/null 2>&1; then
  emit "$(jq -nc --arg r "${R_NAME}" --arg m "${R_METHOD}" --arg v "${EFF_VERSION}" --arg u "${URL}" \
    --argjson s "${http_status:-0}" --argjson ok "${ok}" --argjson b "${body}" \
    '{resource:$r,method:$m,version:$v,url:$u,http_status:$s,ok:$ok,response:$b}')"
else
  emit "$(jq -nc --arg r "${R_NAME}" --arg m "${R_METHOD}" --arg v "${EFF_VERSION}" --arg u "${URL}" \
    --argjson s "${http_status:-0}" --argjson ok "${ok}" --arg b "${body}" \
    '{resource:$r,method:$m,version:$v,url:$u,http_status:$s,ok:$ok,response_text:$b}')"
fi

log "Done. ${R_NAME} -> HTTP ${http_status:-0}."
exit "${overall_rc}"
