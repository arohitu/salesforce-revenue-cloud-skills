---
name: enable-advance-configurator
description: Enable and set up Salesforce Revenue Cloud Advanced Configurator (Constraint Rules Engine) in a connected org. Use when the user asks to enable Advanced Configurator, configure Constraint Rules Engine, create TransactionProcessingType records with RuleEngine=AdvancedConfigurator, deploy required ConstraintEngineNodeStatus fields and triggers, or run setup with sf CLI plus guided manual Revenue Settings toggles.
---

# Enable Advance Configurator

Use this skill to enable and validate Salesforce Revenue Cloud Advanced Configurator (Constraint Rules Engine) in a connected org with a safe, stepwise workflow.

This skill combines:

- automation via `sf` and bundled scripts
- guarded deploy and Tooling API creation steps (`--dry-run` first, then explicit `--confirm`)
- explicit user checkpoints for Salesforce Setup toggles that are UI-based or irreversible

Source of truth for setup details: `docs/enable_adv_config.md`.

## Default workflow

1. Confirm the target org alias. If missing, ask for it. Only use the Salesforce CLI default org after saying that clearly.
2. Run prereq checks first:
   - `bash scripts/check-advanced-configurator-prereqs.sh --target-org <alias>`
3. Tell the user to complete manual Setup toggles, then wait for confirmation:
   - Revenue Settings: turn on **Set Up Configuration Rules and Constraints with Constraints Engine**
   - Revenue Settings: turn on **Transaction processing for quotes and orders** (when TPT-based processing is needed)
4. Generate deployable metadata (fields, triggers, optional permission set):
   - `bash scripts/prepare-advanced-configurator-source.sh --out-dir build/adv-config-source`
5. Validate deployment in dry-run mode:
   - `bash scripts/deploy-advanced-configurator-source.sh --target-org <alias> --source-dir build/adv-config-source --dry-run`
6. Deploy only after explicit user confirmation:
   - `bash scripts/deploy-advanced-configurator-source.sh --target-org <alias> --source-dir build/adv-config-source --confirm`
7. Create or reuse `TransactionProcessingType` with `RuleEngine=AdvancedConfigurator` (dry-run first):
   - `bash scripts/create-advanced-configurator-tpt.sh --target-org <alias> --dry-run`
   - `bash scripts/create-advanced-configurator-tpt.sh --target-org <alias> --confirm`
8. Run final verification and report what is done vs still manual:
   - `bash scripts/verify-advanced-configurator-setup.sh --target-org <alias>`

## Manual checkpoints (never skip)

- Ask user to perform Revenue Settings toggles before attempting end-to-end verification.
- Remind user that selecting a default transaction processing type can be irreversible after enablement.
- Ask user to confirm page layout updates for `Transaction Type` on Quote and Order if sales reps need override behavior.

## Available scripts

- `scripts/check-advanced-configurator-prereqs.sh`: validates CLI/auth, object support, and current org readiness.
- `scripts/prepare-advanced-configurator-source.sh`: generates deployable metadata and Apex triggers into a local output folder.
- `scripts/deploy-advanced-configurator-source.sh`: deploys generated metadata with dry-run and confirmation gates.
- `scripts/create-advanced-configurator-tpt.sh`: creates or reuses an `AdvancedConfigurator` transaction processing type using Tooling API.
- `scripts/verify-advanced-configurator-setup.sh`: post-setup verification and manual reminder output.

All scripts support `--help`. Keep outputs structured and avoid exposing access tokens in responses.

## When to read references

- Read `references/setup-workflow.md` before first run, and whenever the user asks why each step is required.
- Re-check `docs/enable_adv_config.md` if behavior in the org differs from expected setup sequence.

## Boundaries

- Do not claim Revenue Settings toggles are complete unless user confirms they were done in Setup.
- Do not run live deployment or Tooling API mutation without explicit user confirmation.
- Do not include bearer tokens in logs, files, or final answers.
