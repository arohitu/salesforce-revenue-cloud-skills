#!/usr/bin/env bash
#
# call-configurator-apis.sh
# POST to every Salesforce Revenue Cloud Product Configurator Business API resource
# using simple curl. Authenticates through the Salesforce CLI (sf) and always uses the
# latest API version the org supports, never below v67.0.
#
set -euo pipefail

MIN_VERSION="67.0"
PLACEHOLDER_INSTANCE="https://INSTANCE.my.salesforce.com"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
PAYLOAD_DIR="${SKILL_DIR}/payloads"

# Resource registry: "name|path|minVersion|payloadFile". All resources use POST.
RESOURCES=(
  "configure|/connect/cpq/configurator/actions/configure|60.0|configure.json"
  "load-instance|/connect/cpq/configurator/actions/load-instance|60.0|load-instance.json"
  "set-instance|/connect/cpq/configurator/actions/set-instance|60.0|set-instance.json"
  "get-instance|/connect/cpq/configurator/actions/get-instance|60.0|get-instance.json"
  "save-instance|/connect/cpq/configurator/actions/save-instance|60.0|save-instance.json"
  "set-product-quantity|/connect/cpq/configurator/actions/set-product-quantity|60.0|set-product-quantity.json"
  "add-nodes|/connect/cpq/configurator/actions/add-nodes|60.0|add-nodes.json"
  "update-nodes|/connect/cpq/configurator/actions/update-nodes|60.0|update-nodes.json"
  "delete-nodes|/connect/cpq/configurator/actions/delete-nodes|60.0|delete-nodes.json"
  "execute-rules|/revenue/product-configurator/rules/actions/execute|67.0|execute-rules.json"
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
Usage: call-configurator-apis.sh [OPTIONS]

POST to the Salesforce Revenue Cloud Product Configurator Business API resources
using curl. Authenticates via the Salesforce CLI (`sf org display --json`) and uses
the latest API version the org supports, floored at v67.0.

Options:
  --target-org ALIAS   Salesforce CLI org alias/username (else the CLI default org).
  --api-version VER    Override the API version (e.g. 67.0). Must be >= 67.0.
                       Default: latest version reported by the org, floored at 67.0.
  --resource NAME      Call only this resource (see --list). Default: all resources.
  --payload-dir DIR    Directory containing <resource>.json payloads.
                       Default: <skill>/payloads
  --dry-run            Print the URL and curl command for each resource; make no calls.
                       Works offline; uses a placeholder host if no org is available.
  --list               List resources and payload files, then exit (no org needed).
  --output FILE        Write JSON result lines to FILE instead of stdout ("-" = stdout).
  -h, --help           Show this help and exit.

Output:
  One JSON object per resource on stdout, e.g.
    {"resource":"configure","version":"67.0","url":"...","http_status":200,"ok":true}
  Diagnostics and progress go to stderr.

Prerequisites:
  Real callouts require the Salesforce CLI (`sf`) with an authorized org, `curl`, and
  `jq`. `--list` and `--dry-run` only require `curl` (and awk). On Windows, run under
  Git Bash or WSL.

Exit codes:
  0  All requested callouts returned a 2xx status (or --list / --dry-run succeeded).
  2  Invalid arguments or usage error.
  3  Authentication / Salesforce CLI failure, or version discovery could not proceed.
  4  One or more callouts returned a non-2xx status.
EOF
}

# ---- argument parsing ------------------------------------------------------

TARGET_ORG=""
API_VERSION_OVERRIDE=""
ONLY_RESOURCE=""
DRY_RUN="false"
DO_LIST="false"
OUTPUT="-"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --target-org) TARGET_ORG="${2:-}"; shift 2 ;;
    --api-version) API_VERSION_OVERRIDE="${2:-}"; shift 2 ;;
    --resource) ONLY_RESOURCE="${2:-}"; shift 2 ;;
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
  printf '%-22s %-52s %-8s %s\n' "RESOURCE" "PATH" "MIN_VER" "PAYLOAD"
  for entry in "${RESOURCES[@]}"; do
    IFS='|' read -r name path minver payload <<<"${entry}"
    printf '%-22s %-52s %-8s %s\n' "${name}" "${path}" "${minver}" "payloads/${payload}"
  done
  exit 0
fi

# Validate --resource early.
if [[ -n "${ONLY_RESOURCE}" ]]; then
  found="false"
  for entry in "${RESOURCES[@]}"; do
    IFS='|' read -r name _ _ _ <<<"${entry}"
    [[ "${name}" == "${ONLY_RESOURCE}" ]] && found="true"
  done
  [[ "${found}" == "true" ]] || die 2 "Unknown --resource '${ONLY_RESOURCE}'. Run --list to see valid names."
fi

# Validate an explicit version override against the v67.0 floor.
if [[ -n "${API_VERSION_OVERRIDE}" ]]; then
  if version_lt "${API_VERSION_OVERRIDE}" "${MIN_VERSION}"; then
    die 2 "--api-version ${API_VERSION_OVERRIDE} is below the required minimum of v${MIN_VERSION}."
  fi
fi

# curl and awk are always required.
command -v curl >/dev/null 2>&1 || die 3 "curl not found on PATH."
command -v awk  >/dev/null 2>&1 || die 3 "awk not found on PATH."

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

# ---- output sink -----------------------------------------------------------

emit() { # emit a single line to the chosen sink
  if [[ "${OUTPUT}" == "-" ]]; then
    printf '%s\n' "$1"
  else
    printf '%s\n' "$1" >>"${OUTPUT}"
  fi
}

[[ "${OUTPUT}" != "-" ]] && : >"${OUTPUT}"

# ---- callouts --------------------------------------------------------------

overall_rc=0
called=0

for entry in "${RESOURCES[@]}"; do
  IFS='|' read -r name path minver payload <<<"${entry}"
  [[ -n "${ONLY_RESOURCE}" && "${name}" != "${ONLY_RESOURCE}" ]] && continue

  # Never call a resource below its documented minimum, nor below the global floor.
  eff_version="$(version_max "${API_VERSION}" "${minver}")"
  url="${INSTANCE_URL}/services/data/v${eff_version}${path}"
  payload_path="${PAYLOAD_DIR}/${payload}"

  if [[ ! -f "${payload_path}" ]]; then
    log "Skipping ${name}: payload not found at ${payload_path}"
    emit "{\"resource\":\"${name}\",\"version\":\"${eff_version}\",\"url\":\"${url}\",\"http_status\":0,\"ok\":false,\"error\":\"payload_not_found\"}"
    overall_rc=4
    continue
  fi

  called=$((called + 1))

  if [[ "${DRY_RUN}" == "true" ]]; then
    log "[dry-run] ${name} -> POST ${url}"
    log "          curl -sS -X POST -H 'Authorization: Bearer ***' -H 'Content-Type: application/json' --data @${payload_path} '${url}'"
    emit "{\"resource\":\"${name}\",\"version\":\"${eff_version}\",\"url\":\"${url}\",\"payload\":\"payloads/${payload}\",\"dry_run\":true}"
    continue
  fi

  log "Calling ${name} (v${eff_version})..."
  body_file="$(mktemp)"
  http_status="$(curl -sS -o "${body_file}" -w '%{http_code}' \
    -X POST \
    -H "Authorization: Bearer ${ACCESS_TOKEN}" \
    -H "Content-Type: application/json" \
    --data "@${payload_path}" \
    "${url}" 2>/dev/null || true)"

  body="$(cat "${body_file}" 2>/dev/null || true)"
  rm -f "${body_file}" 2>/dev/null || true

  ok="false"
  if [[ "${http_status}" =~ ^2[0-9][0-9]$ ]]; then
    ok="true"
  else
    overall_rc=4
  fi

  # Attach the response as parsed JSON when valid, else as an escaped string.
  if printf '%s' "${body}" | jq -e . >/dev/null 2>&1; then
    emit "$(jq -nc --arg r "${name}" --arg v "${eff_version}" --arg u "${url}" \
      --argjson s "${http_status:-0}" --argjson ok "${ok}" --argjson b "${body}" \
      '{resource:$r,version:$v,url:$u,http_status:$s,ok:$ok,response:$b}')"
  else
    emit "$(jq -nc --arg r "${name}" --arg v "${eff_version}" --arg u "${url}" \
      --argjson s "${http_status:-0}" --argjson ok "${ok}" --arg b "${body}" \
      '{resource:$r,version:$v,url:$u,http_status:$s,ok:$ok,response_text:$b}')"
  fi
done

if [[ "${called}" -eq 0 ]]; then
  die 2 "No resources selected to call."
fi

log "Done. Called ${called} resource(s)."
exit "${overall_rc}"
