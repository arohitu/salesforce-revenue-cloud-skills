---
name: revenue-cloud-txn-management-apis
description: >
  Reference and call the Salesforce Revenue Cloud (Agentforce Revenue Management)
  Transaction Management Business APIs - the Connect REST Quote & Order Capture resources
  that place quotes and orders, amend/renew/cancel/swap/upgrade/downgrade assets, fetch
  instant pricing, clone or read a sales transaction, create supplemental/change orders,
  manage ramp deals, and get or create promotions. Use when the user wants to create or
  update a quote or order via REST, price a quote/order line data grid, run an asset
  action, build a sales-transaction object graph, or debug an asynchronous Place Sales
  Transaction error - even when they only describe the goal (e.g. "place this order over
  the API", "amend this asset", "why did my place quote call fail") without naming an
  endpoint. Covers RLM, headless quoting/ordering, object graphs, ramp deals, and
  contextId/trackerId/graphId, and calls each resource via the bundled curl script. Not
  for legacy CPQ SBQQ__* or Billing BLNG__* quoting.
---

# Revenue Cloud Transaction Management Business APIs

Salesforce Revenue Cloud (Agentforce Revenue Management / Revenue Lifecycle Management)
exposes Connect REST resources for Quote & Order Capture ("Transaction Management"). Use
them to create and price quotes and orders, run asset actions, manage ramp deals, and
handle promotions. This skill lists every resource and bundles a curl script that
authenticates through the Salesforce CLI and calls each one.

- Base URL pattern: `https://<instance>/services/data/v<version><resource>`
- Auth: OAuth bearer token (`Authorization: Bearer <accessToken>`), obtained from an
  authorized org via `sf org display --json`.
- Source of truth: [docs/TXN Management APIs.md](../../docs/TXN%20Management%20APIs.md). For
  the full resource catalog, request bodies, and response representations, read
  [references/resources.md](references/resources.md) first; consult the source doc for
  complete nested schemas.

## When to use which resource

- **Create or update a quote/order (the default entry point)**: `place-sales-transaction`
  (`POST /connect/rev/sales-transaction/actions/place`). It runs pricing, configuration,
  and tax in one call. The older `place-order` and `place-quote` are **deprecated as of
  v63.0** - prefer this resource.
- **Price a line data grid without committing a full transaction**: `instant-pricing`
  (`POST .../get-instant-price`) - creates or updates a context and can group lines.
- **Asset actions**: `asset-amend`, `asset-cancel`, `asset-renew` (add/reduce, cancel,
  renew) and `initiate-swap` / `initiate-upgrade` / `initiate-downgrade` (product moves).
- **Ramp deals (line ramps)**: `ramp-deal-create` / `-update` / `-delete` / `-view`. These
  return a context id you then pass to `place-sales-transaction` to persist. For group
  ramps, use `place-sales-transaction` with `groupRampAction` instead.
- **Copy or inspect a transaction**: `clone-sales-transaction`, `read-sales-transaction`.
- **After submission**: `place-supplemental-transaction` (change orders during fulfillment).
- **Debug an async place**: `sales-transaction-errors`
  (`GET .../place/{trackerId}/errors`).
- **Promotions**: `create-promotions` (GET/POST/PUT), `get-eligible-promotions`.

See [references/resources.md](references/resources.md) for the full 20-resource catalog
with methods, versions, path/query parameters, payloads, and response bodies.

## API version rule

Always call with the **latest API version the org supports**, and **never below v67.0**.
The bundled script auto-discovers the newest version from `GET /services/data/` and uses
`max(latestOrgVersion, 67.0)`, then bumps to a resource's own minimum where higher. Any
explicit `--api-version` below 67.0 is rejected.

## Gotchas

- Most POST bodies are an **object graph**: `graph.records[]`, each with
  `attributes.type` (sObject), `attributes.method` (`POST`/`PATCH`/`DELETE`), and field
  values. Reference an as-yet-uncreated record's id with `@{referenceId.id}` and a group
  with `{@GroupId}`. `PATCH`/`DELETE` records need `attributes.id`. This is the most
  common source of "record not found"/reconciliation errors.
- **Place Sales Transaction runs asynchronously.** A 2xx from the place call only means it
  was accepted. Take the returned tracker id and call `sales-transaction-errors` with
  `--param trackerId=...` (add `--query 'includeRetryablePayload=true'`) to see blocking
  errors and the retryable payload. It does not return non-blocking config/tax warnings.
- `place-sales-transaction` needs **either** `graph` **or** `contextDetails`, not neither.
  It does **not** create amendment/renewal/cancellation records - use the asset actions.
  The quote header commits first, so a later component failure won't roll it back.
- Ramp-deal create/update/delete only **stage** changes and return a context id; nothing
  persists until you call `place-sales-transaction` with that context id.
- Asset actions need permission sets: `InitiateAmend`, `InitiateCancellation`,
  `InitiateRenewal`. For **usage products**, amend with `outputRecordType: "Quote"` and a
  two-step quote-then-order flow; direct-to-Order is unsupported and can fail activation.
- `swap` / `upgrade` / `downgrade` share the same `swapGroups` body shape (an `outGroup`
  of assets swapped out and an `inGroup` object graph swapped in).
- `clone-sales-transaction` takes a **single** record id in `recordIds` plus the parent
  `salesTransactionId`.
- These resources mix **GET/POST/PUT** and several use **path parameters** (`{resourceId}`,
  `{trackerId}`), so call one resource at a time with `--resource` (and `--param`/`--query`
  /`--method`), not a bulk "call everything" run.
- Sample ids in `payloads/*.json` are placeholders - replace them with real org ids
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
# List every resource with its methods, min version, and path (no org needed)
bash scripts/call-txn-management-apis.sh --list

# Preview the resolved URL and curl command without calling the org
bash scripts/call-txn-management-apis.sh --resource place-sales-transaction --dry-run

# Create a quote/order (edit payloads/place-sales-transaction.json with real ids first)
bash scripts/call-txn-management-apis.sh --resource place-sales-transaction --target-org myorg

# Debug an async place by its tracker id
bash scripts/call-txn-management-apis.sh --resource sales-transaction-errors \
  --param trackerId=16PRM0000004DBq --query 'includeRetryablePayload=true' --target-org myorg

# Path + query resource (view a ramp deal)
bash scripts/call-txn-management-apis.sh --resource ramp-deal-view \
  --param resourceId=0QLxx0000004CSOGA2 \
  --query 'transactionId=0Q0xx0000004CDxCAM&transactionLineId=0QLxx0000004CSOGA2' --target-org myorg

# Multi-method resource
bash scripts/call-txn-management-apis.sh --resource create-promotions --method GET --target-org myorg
```

Run `bash scripts/call-txn-management-apis.sh --help` for all flags and exit codes.

## Workflow for calling a live org

1. Pick the resource for the goal (see "When to use which resource").
2. For POST/PUT resources, edit the matching `payloads/*.json` with real ids and build the
   object graph (correct `type`/`method`, `@{...}` references, group actions).
3. For path/query resources, gather the ids and pass `--param key=value` / `--query`.
4. `--dry-run` first to confirm the URL, effective version (>= v67.0), method, and payload.
5. Run without `--dry-run`. Inspect the JSON result line on stdout.
6. For `place-sales-transaction`, don't stop at the 2xx: capture the tracker id and call
   `sales-transaction-errors` to confirm the records actually persisted (it is async). On
   any failure, read the response body and cross-check against
   [references/resources.md](references/resources.md) and the source doc.

## Available scripts

- **`scripts/call-txn-management-apis.sh`** - Auth via `sf`, auto-select latest API version
  (floored at v67.0, bumped per resource), and call one resource by name. Supports
  `--list`, `--dry-run`, `--resource`, `--method`, `--param`, `--query`, `--payload`,
  `--target-org`, `--api-version`, `--payload-dir`, `--output`. Emits one JSON result line
  to stdout.

## Related skills

- `revenue-cloud-pricing-apis` - the Pricing Business APIs (`/connect/core-pricing`).
- `revenue-cloud-config-apis` - the Product Configurator Business APIs.
- `salesforce-revenue-cloud-pricing` - design/build/debug pricing procedures and recipes.
- `revenue-cloud-pricing-diagnostics` - trace how a specific pricing field is calculated.
