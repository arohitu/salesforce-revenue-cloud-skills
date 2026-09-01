---
name: revenue-cloud-pricing-apis
description: >
  Reference and call the Salesforce Revenue Cloud (Agentforce Revenue Management)
  Pricing Business APIs - the Connect REST resources under /connect/core-pricing and
  /connect/procedure-plan-definitions. Use when the user wants to price a cart or line
  items, run a pricing procedure/expression set via API, hydrate or reuse a price
  context, sync pricing data to decision tables, read/clone/map pricing recipes, get a
  price waterfall or pricing execution logs, do PBE-derived pricing, create versioned
  adjustment revisions, or create/evaluate/version procedure plans - even when they only
  describe the goal (e.g. "call the pricing API", "get the price for this quote via
  REST", "why did the pricing REST call fail") without naming an endpoint. Covers
  Revenue Cloud, RLM, headless pricing, contextDefinitionId, contextMappingId,
  pricingProcedureId, jsonDataString, and price waterfall. Also calls each resource via
  the bundled curl script. Not for legacy CPQ SBQQ__* or Billing BLNG__* pricing.
---

# Revenue Cloud Pricing Business APIs

Salesforce Revenue Cloud (Agentforce Revenue Management / Revenue Lifecycle Management)
exposes Connect REST resources for pricing under `/connect/core-pricing` and
`/connect/procedure-plan-definitions`. This skill lists every resource and bundles a
curl script that authenticates through the Salesforce CLI and calls each one.

- Base URL pattern: `https://<instance>/services/data/v<version><resource>`
- Auth: OAuth bearer token (`Authorization: Bearer <accessToken>`), obtained from an
  authorized org via `sf org display --json`.
- Source of truth: [docs/Pricing API.md](../../docs/Pricing%20API.md). For the full
  resource catalog, request bodies, and response representations, read
  [references/resources.md](references/resources.md) first; consult the source doc for
  complete nested schemas.

## When to use which resource

- **Price a cart / line items in one call**: `pricing` (`POST /connect/core-pricing/pricing`).
  This is the primary entry point - it creates and hydrates the context and returns
  `pricingResult` per line item plus `pricingResultErrors`.
- **Price against an existing context instance**: `price-context`
  (`POST /connect/core-pricing/price-contexts/{contextId}`).
- **Refresh lookup data before pricing**: `sync` (`GET /connect/core-pricing/sync/{origin}`).
- **Inspect / clone recipes**: `recipe` (GET), `recipe-valid-elements` (GET),
  `recipe-clone` (POST), `recipe-mapping` (POST).
- **Explainability / debugging**: `waterfall-get` (GET), `waterfall` (POST),
  `api-execution-logs` (GET), `pricing-process-execution*` (GET). Waterfall GET needs
  price waterfall persistence enabled in Salesforce Pricing Setup.
- **Orchestration**: `procedure-plan-definitions` (GET/POST), `procedure-plan-evaluate`
  (POST), `procedure-plan-version` (POST), and the by-id/by-name/version-details variants.

See [references/resources.md](references/resources.md) for the full 21-resource catalog
with methods, versions, path/query parameters, payloads, and response bodies.

## API version rule

Always call with the **latest API version the org supports**, and **never below v67.0**.
The bundled script auto-discovers the newest version from `GET /services/data/` and uses
`max(latestOrgVersion, 67.0)`, then bumps to a resource's own minimum where higher (e.g.
recipe clone/valid-elements need v68.0). Any explicit `--api-version` below 67.0 is rejected.

## Gotchas

- `jsonDataString` must be **JSON passed as a String** (stringify the object). Its keys
  must match the `contextMappingId`, and every node needs `businessObjectType` set to the
  mapped sObject (e.g. `Cart`, `CartItem`, `Attribute`). This is the most common cause of
  a `Failed` status.
- `contextDefinitionId` + `contextMappingId` are **required** on `pricing`;
  `pricingProcedureId` is optional (ID or API name of the pricing procedure, which is an
  Expression Set Definition). Experience Cloud users pass the procedure **name**.
- A 200 response can still contain per-line-item failures. Check `status`
  (`Completed` / `Partially Completed` / `Failed`) and inspect `pricingResultErrors` and
  each result's `isSuccess` + `errors`, keyed by `dataPath`.
- Waterfall details are only returned when price waterfall is enabled/persisted in
  Salesforce Pricing Setup. If disabled, use the Waterfall GET API separately.
- Use `configurationOverrides.isHighVolumeLineItems: true` for more than 100 line items
  (v63.0+), and `referenceKey` to find the run later in the Pricing Operations Console.
- These resources mix **GET and POST** and several use **path parameters**
  (`{contextId}`, `{executionId}`, `{executionType}`, `{lineItemId}`, plan/version IDs),
  so call one resource at a time with `--resource` (and `--param key=value`), not a bulk
  "call everything" run.
- Procedure plan resources require the **Procedure Plan Orchestration for Pricing** toggle
  (Revenue Settings). PATCH deletes any properties omitted from the body, and you cannot
  edit or delete an **active** procedure plan version.
- Sample IDs in `payloads/*.json` are placeholders - replace them with real org IDs
  before calling a live org.

## Authentication

Authorize an org once with the Salesforce CLI, then reuse it:

```bash
sf org login web --alias myorg
sf org display --json --target-org myorg
```

`sf org display --json` returns `result.instanceUrl` and `result.accessToken`, which the
script uses to build the URL and bearer header.

## Quick start

Prerequisites: Salesforce CLI (`sf`) with an authorized org, `curl`, `jq`, and a Bash
shell (Git Bash or WSL on Windows). `--list` and `--dry-run` work offline.

```bash
# List every resource with its method, min version, and path (no org needed)
bash scripts/call-pricing-apis.sh --list

# Preview the resolved URL and curl command without calling the org
bash scripts/call-pricing-apis.sh --resource pricing --dry-run

# Price a cart (edit payloads/pricing.json with real ids first)
bash scripts/call-pricing-apis.sh --resource pricing --target-org myorg

# GET resources: recipes, and valid elements for a usage subtype
bash scripts/call-pricing-apis.sh --resource recipe --target-org myorg
bash scripts/call-pricing-apis.sh --resource recipe-valid-elements \
  --query 'pricingUsageSubType=RevenueCloud' --target-org myorg

# Path-parameter resources
bash scripts/call-pricing-apis.sh --resource waterfall-get \
  --param lineItemId=item1 --param executionId=263369316895959 --target-org myorg
```

Run `bash scripts/call-pricing-apis.sh --help` for all flags and exit codes.

## Workflow for calling a live org

1. Pick the resource for the goal (see "When to use which resource").
2. For POST resources, edit the matching `payloads/*.json` with real ids
   (`contextDefinitionId`, `contextMappingId`, `pricingProcedureId`, product/PBE ids).
3. For path/query resources, gather the ids and pass `--param key=value` / `--query`.
4. `--dry-run` first to confirm the URL, effective version (>= v67.0), method, and payload.
5. Run without `--dry-run`. Inspect the JSON result line on stdout.
6. On failure, read the response body and cross-check against
   [references/resources.md](references/resources.md) and the source doc. For pricing
   failures, use `api-execution-logs` / `pricing-process-execution` / `waterfall-get`
   with the returned `apiExecutionId` and `pricingExecutionId` to trace the run.

## Available scripts

- **`scripts/call-pricing-apis.sh`** - Auth via `sf`, auto-select latest API version
  (floored at v67.0, bumped per resource), and call one resource by name. Supports
  `--list`, `--dry-run`, `--resource`, `--param`, `--query`, `--payload`, `--target-org`,
  `--api-version`, `--payload-dir`, `--output`. Emits one JSON result line to stdout.

## Related skills

- `salesforce-revenue-cloud-pricing` - design/build/debug pricing procedures and recipes.
- `revenue-cloud-pricing-diagnostics` - trace how a specific pricing field is calculated.
- `revenue-cloud-config-apis` - the Product Configurator Business APIs.
- `revenue-cloud-decision-table` - find and invoke Decision Table lookups.
