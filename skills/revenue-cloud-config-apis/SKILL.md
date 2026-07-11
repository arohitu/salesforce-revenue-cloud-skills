---
name: revenue-cloud-config-apis
description: >
  Reference and call the Salesforce Revenue Cloud (Revenue Lifecycle Management)
  Product Configurator Business APIs. Use when working with the CPQ configurator
  Connect REST resources - configuring a product bundle, loading/getting/setting/saving
  a configuration instance, adding/updating/deleting nodes, setting product quantity,
  or running configuration rules - and when the user mentions Revenue Cloud, RLM,
  Product Configurator, CPQ configurator, /connect/cpq/configurator, contextId,
  transactionId, configurator instances, or config rules, even if they don't name
  the exact endpoint. Also use to POST to every configurator resource via the bundled
  curl script.
---

# Revenue Cloud Product Configurator Business APIs

Salesforce Revenue Cloud (Revenue Lifecycle Management) exposes ten Connect REST
resources for product configuration. This skill lists every resource and bundles a
curl script that authenticates through the Salesforce CLI and POSTs to each one.

- Base URL pattern: `https://<instance>/services/data/v<version><resource>`
- Auth: OAuth bearer token (`Authorization: Bearer <accessToken>`), obtained from an
  authorized org via `sf org display --json`.
- Source of truth: [output-md/Product Configurator APIs.md](../../../output-md/Product%20Configurator%20APIs.md).
  For full request bodies, property tables, and response bodies, read
  [references/resources.md](references/resources.md) first; consult the source doc for
  complete schemas.

## API version rule

Always call with the **latest API version the org supports**, and **never below v67.0**.
The bundled script auto-discovers the newest version from `GET /services/data/` and uses
`max(latestOrgVersion, 67.0)`. Any explicit `--api-version` below 67.0 is rejected.

## Gotchas

- These APIs are **stateless** - they don't recall prior user actions between calls
  unless state is explicitly persisted and reloaded. Deselecting a child product and
  later reselecting it is treated as adding a brand-new item; the original line item is
  not restored and a new line item is created.
- Minimum callable version is **v67.0**, even though most resources are available since
  v60.0. `/revenue/product-configurator/rules/actions/execute` requires v67.0+.
- `contextResponseType` on `configure` requires v65.0+ and is intended for large sales
  transactions (>1000 line items, <15K line items).
- `transactionId` = the header entity being configured (Quote/Order). `contextId` /
  `transactionContextId` = the transaction context instance id returned by load/configure.
  Node and quantity resources operate on an existing `contextId`.
- All ten resources use **POST**. Sample IDs in `payloads/*.json` are placeholders -
  replace them with real org IDs before calling a live org.

## Resources

All resources use the POST method.

| Resource | Purpose |
| --- | --- |
| `/connect/cpq/configurator/actions/configure` | Retrieve and update a product's configuration; execute configuration rules, report violations for bundle/attribute/quantity changes, and get pricing for the configured bundle. |
| `/connect/cpq/configurator/actions/load-instance` | Create a session for the configuration instance from a transaction ID; returns a session id with results of configuration rules, qualification rules, and pricing. |
| `/connect/cpq/configurator/actions/set-instance` | Set a configuration instance when the instance lives in a database other than Salesforce while product catalog data is in Salesforce. |
| `/connect/cpq/configurator/actions/get-instance` | Fetch the JSON representation of a product configuration to display in the UI or save to an external system. |
| `/connect/cpq/configurator/actions/save-instance` | Save a configuration instance after a successful product configuration. |
| `/connect/cpq/configurator/actions/set-product-quantity` | Set the quantity of a product through the runtime system. |
| `/connect/cpq/configurator/actions/add-nodes` | Add a node to the context through the runtime system without using the Salesforce UI. |
| `/connect/cpq/configurator/actions/update-nodes` | Update nodes in a product configuration. |
| `/connect/cpq/configurator/actions/delete-nodes` | Delete nodes from a product configuration. |
| `/revenue/product-configurator/rules/actions/execute` | Run rules for a specific quote or order based on a context ID or transaction ID. |

Each resource's URI, available version, request-body example, property table, and
response representation are in [references/resources.md](references/resources.md).

## Authentication

Authorize an org once with the Salesforce CLI, then reuse it:

```bash
sf org login web --alias myorg
sf org display --json --target-org myorg
```

`sf org display --json` returns `result.instanceUrl` and `result.accessToken`, which the
script uses to build the URL and bearer header.

## Quick start - call every resource

Prerequisites: Salesforce CLI (`sf`) with an authorized org, `curl`, `jq`, and a Bash
shell (Git Bash or WSL on Windows).

```bash
# List all ten resources and their payload files (no org needed)
bash scripts/call-configurator-apis.sh --list

# Preview the exact URLs and curl commands without calling the org
bash scripts/call-configurator-apis.sh --dry-run --target-org myorg

# POST to every resource using the bundled sample payloads
bash scripts/call-configurator-apis.sh --target-org myorg

# Call a single resource
bash scripts/call-configurator-apis.sh --target-org myorg --resource configure
```

Run `bash scripts/call-configurator-apis.sh --help` for all flags and exit codes.

## Workflow for calling a live org

1. Edit the relevant `payloads/*.json` with real ids (`transactionId`, `contextId`,
   account/contact ids, product ids).
2. `--dry-run` first to confirm the URL, version (>= v67.0), and payload.
3. Run without `--dry-run`. Inspect the per-resource JSON status lines on stdout.
4. On errors, read the Salesforce response body and cross-check the request against
   [references/resources.md](references/resources.md) and the source doc.

## Available scripts

- **`scripts/call-configurator-apis.sh`** - Auth via `sf`, auto-select latest API version
  (floored at v67.0), and POST to all ten resources (or one via `--resource`). Supports
  `--list`, `--dry-run`, `--target-org`, `--api-version`, `--payload-dir`, `--output`.
