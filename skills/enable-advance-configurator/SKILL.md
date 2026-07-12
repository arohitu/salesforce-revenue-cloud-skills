---
name: enable-advance-configurator
description: Enable and set up Salesforce Revenue Cloud Advanced Configurator (Constraint Rules Engine) in a connected org. Use when the user asks to enable Advanced Configurator, configure Constraint Rules Engine, create TransactionProcessingType records with RuleEngine=AdvancedConfigurator, deploy ConstraintEngineNodeStatus fields and triggers, update Sales Transaction context definitions, enable Revenue Settings via metadata, or run setup with sf CLI and bundled scripts.
disable-model-invocation: true
---

# Enable Advance Configurator

Use this skill to enable and validate Salesforce Revenue Cloud Advanced Configurator (Constraint Rules Engine) in a connected org with a safe, stepwise workflow.

This skill combines:

- automation via `sf` and bundled scripts
- retrieve-then-update for existing org metadata (settings, layouts)
- guarded deploy and Tooling API creation steps (`--dry-run` first, then explicit `--confirm`)
- explicit user confirmation before irreversible steps

Source of truth: this skill and `references/setup-workflow.md`.

## Platform note

Bundled scripts are bash. On Windows, run them via **Git Bash** or **WSL**. The agent may also run equivalent `sf` commands directly in PowerShell when scripts are unavailable.

## Default workflow

1. Confirm the target org alias. If missing, ask for it. Only use the Salesforce CLI default org after saying that clearly.
2. Run prereq checks:
   - `bash scripts/check-advanced-configurator-prereqs.sh --target-org <alias>`
3. Assign the designer permission set if not already assigned:
   - `sf org assign permset --name AdvancedConfiguratorDesigner --target-org <alias>`
4. Generate deployable metadata (fields, triggers, optional FLS permission set):
   - `bash scripts/prepare-advanced-configurator-source.sh --out-dir build/adv-config-source`
5. Validate deployment in dry-run mode:
   - `bash scripts/deploy-advanced-configurator-source.sh --target-org <alias> --source-dir build/adv-config-source/force-app/main/default --dry-run`
6. Deploy fields/triggers/FLS only after explicit user confirmation:
   - `bash scripts/deploy-advanced-configurator-source.sh --target-org <alias> --source-dir build/adv-config-source/force-app/main/default --confirm`
7. Enable Revenue Settings via metadata (retrieve from org first, then update):
   - `bash scripts/enable-advanced-configurator-settings.sh --target-org <alias> --dry-run`
   - `bash scripts/enable-advanced-configurator-settings.sh --target-org <alias> --confirm`
   - If metadata deploy fails, ask the user to flip toggles manually in Setup > Revenue Settings.
8. Create or reuse `TransactionProcessingType` with `RuleEngine=AdvancedConfigurator` (only after step 7 enables transaction processing):
   - `bash scripts/create-advanced-configurator-tpt.sh --target-org <alias> --dry-run`
   - `bash scripts/create-advanced-configurator-tpt.sh --target-org <alias> --confirm`
9. Update Quote and Order layouts with Sales Transaction Type field (retrieve-then-update):
   - `bash scripts/update-quote-order-layouts.sh --target-org <alias> --dry-run`
   - `bash scripts/update-quote-order-layouts.sh --target-org <alias> --confirm`
10. Update the Sales Transaction context definition with constraint attributes and entity mappings (**last setup step**; after custom fields, settings, TPT, and layouts):
   - Ask the user for the context definition API name (e.g. `RLM_SalesTransactionContext`).
   - `bash scripts/update-context-definition-constraints.sh --target-org <alias> --context-definition-name <name> --dry-run`
   - `bash scripts/update-context-definition-constraints.sh --target-org <alias> --context-definition-name <name> --confirm`
   - Whether deployment succeeds or fails, ask the user to open the context definition in Setup and manually verify the attributes, entity mappings, and activation. If deployment failed, ask the user to complete the changes manually.
   - Remind user that **AssetToSalesTransactionMapping** remains a manual checkpoint.
11. Run final verification and report what is done vs still manual:
    - `bash scripts/verify-advanced-configurator-setup.sh --target-org <alias> --context-definition-name <name>`

## Retrieve-then-update rules

- **Always retrieve** existing `IndustriesConstraints`, `RevenueManagement`, layouts, and context definitions from the org before editing.
- **Never deploy** bulk `Settings` retrieve output — deploy only the two changed settings files.
- **Deploy only** the single context definition file after surgical constraint updates — never redeploy noisy bulk retrieve output.
- **Generate fresh** metadata only for net-new artifacts (custom fields, triggers).

## Manual checkpoints (never skip)

- Require explicit user confirmation before live deploy, settings deploy, TPT creation, context definition deploy, and layout deploy.
- Remind user that enabling transaction processing (`enableTransactionProcessor`) is **irreversible**.
- Remind user that selecting a default transaction processing type can be irreversible after enablement.
- If metadata settings deploy fails, fall back to manual Setup > Revenue Settings toggles and wait for user confirmation.

## Available scripts

- `scripts/check-advanced-configurator-prereqs.sh`: validates CLI/auth, object support, and current org readiness.
- `scripts/prepare-advanced-configurator-source.sh`: generates deployable metadata and Apex triggers into a local output folder.
- `scripts/deploy-advanced-configurator-source.sh`: deploys generated metadata with dry-run and confirmation gates.
- `scripts/enable-advanced-configurator-settings.sh`: retrieve-update-deploy `IndustriesConstraints` and `RevenueManagement` settings.
- `scripts/create-advanced-configurator-tpt.sh`: creates or reuses an `AdvancedConfigurator` transaction processing type using Tooling API.
- `scripts/update-context-definition-constraints.sh`: retrieve-update-deploy constraint attributes and entity mappings on a context definition.
- `scripts/update-quote-order-layouts.sh`: retrieve-update-deploy Quote and Order layouts with `SalesTransactionTypeId`.
- `scripts/verify-advanced-configurator-setup.sh`: post-setup verification and manual reminder output.

All scripts support `--help`. Keep outputs structured and avoid exposing access tokens in responses.

## When to read references

- Read `references/setup-workflow.md` before first run, and whenever the user asks why each step is required.
- Read `references/context-definition-changes.md` for exact XML blocks and manual checkpoints.
- Re-check `references/setup-workflow.md` if behavior in the org differs from the expected setup sequence.

## Partial automation / manual checkpoints

Context definition updates are **partially automated**:

- **Automated:** retrieve context definition by API name, add `ConstraintEngineNodeStatus__c` / `AssetConstraintEngineNodeStatus__c` attributes, and Quote/Order/Asset entity mappings (idempotent, surgical deploy).
- **Manual:** `AssetToSalesTransactionMapping` cross-attribute mapping (org-specific).
- **Manual:** activate the context definition version in Setup when required.
- **Always:** after attempting context definition deploy (success or failure), ask the user to manually open Setup and verify attributes, mappings, and activation.

Ask the user for the context definition API name before running the context definition script. Do not claim setup is fully complete until the user confirms manual verification and any required manual checkpoints.

## Boundaries

- Do not run live deployment or Tooling API mutation without explicit user confirmation.
- Do not create TPT before `enableTransactionProcessor` is enabled (TPT Tooling API is unavailable until then).
- Do not include bearer tokens in logs, files, or final answers.
