# Advanced Configurator Setup Workflow

Operational reference for enabling Advanced Configurator (Constraint Rules Engine) in a Revenue Cloud org.

## 1) Required metadata and logic

### Custom field on three objects

Create `ConstraintEngineNodeStatus__c` on:

- `QuoteLineItem`
- `OrderItem`
- `AssetActionSource`

Required shape:

- Label: `Constraint Engine Node Status`
- API name: `ConstraintEngineNodeStatus`
- Type: Long Text Area
- Length: `131072`

Recommended:

- grant visible/edit to relevant internal users and communities as needed
- do not auto-place the field on page layouts

### Apex triggers

Create before-insert triggers for:

- Quote line items (copy status from latest related `AssetActionSource`)
- Order items (same pattern using `OrderAction`)

The generated script templates use `RCAAdvConfigQuoteLineItemTrigger` and `RCAAdvConfigOrderItemTrigger` to avoid collisions with existing org triggers. Orgs may also use `QuoteItemTrigger` / `OrderItemTrigger`.

### Permission set

Assign `AdvancedConfiguratorDesigner` (Product Configuration Constraints Designer) to the setup user before enabling Advanced Configurator.

Optionally deploy a supplementary FLS permission set (`EnableAdvancedConfiguratorSetup`) for field visibility on the three custom fields.

## 2) Revenue Settings (metadata-automatable)

These Setup UI toggles map to metadata settings. Retrieve from org first, update flags, deploy only the changed files:

| UI toggle | Metadata field | Settings file |
| --- | --- | --- |
| Set Up Configuration Rules and Constraints with Constraints Engine | `enableAdvancedConfigurator = true` | `IndustriesConstraints.settings-meta.xml` |
| Transaction processing for quotes and orders | `enableTransactionProcessor = true` | `RevenueManagement.settings-meta.xml` |

Retrieve command:

```bash
sf project retrieve start --metadata "Settings:IndustriesConstraints" "Settings:RevenueManagement" --target-org <alias>
```

Deploy only the two changed settings files. Do not deploy bulk Settings retrieve output.

**Fallback:** If metadata deploy fails, ask the user to flip toggles manually in Setup > Revenue Settings.

**Critical:** `enableTransactionProcessor` is irreversible once enabled.

## 3) Transaction Processing Type (Tooling API)

**Prerequisite:** `enableTransactionProcessor` must be `true` before the `TransactionProcessingType` Tooling API object is available.

Create or reuse a `TransactionProcessingType` record with:

- `DeveloperName`: `AdvancedConfigurator`
- `MasterLabel`: `AdvancedConfigurator`
- `RuleEngine`: `AdvancedConfigurator`
- `SaveType`: `Standard` (default in script unless overridden)

The skill script supports optional preference fields:

- `PricingPreference`
- `TaxPreference`
- `RatingPreference`

Important: choosing or changing a default transaction type during enablement can be irreversible; require explicit user acknowledgement.

## 4) Layout and user override readiness

If business users need to override transaction type on quote/order:

- retrieve `Quote-Quote Layout` and `Order-Order Layout` from the org
- add `SalesTransactionTypeId` (UI label: **Sales Transaction Type** / Transaction Type)
- deploy layouts only

## 5) Context definition (partially automatable, **last setup step**)

**Prerequisite:** `ConstraintEngineNodeStatus__c` custom fields must exist on `QuoteLineItem`, `OrderItem`, and `AssetActionSource` before updating the context definition.

Ask the user for the active Sales Transaction context definition API name (e.g. `RLM_SalesTransactionContext`).

Retrieve command:

```bash
sf project retrieve start --metadata "ContextDefinition:<name>" --target-org <alias>
```

Script (retrieve-then-update, idempotent):

```bash
bash scripts/update-context-definition-constraints.sh \
  --target-org <alias> \
  --context-definition-name <name> \
  --dry-run

bash scripts/update-context-definition-constraints.sh \
  --target-org <alias> \
  --context-definition-name <name> \
  --confirm
```

Deploy only the single context definition file. Do not bulk-redeploy unrelated metadata.

### Attributes added

| Context node | Attribute API name | fieldType | dataType |
| --- | --- | --- | --- |
| SalesTransactionItem | `ConstraintEngineNodeStatus__c` | inputoutput | string |
| AssetActionSource | `AssetConstraintEngineNodeStatus__c` | inputoutput | string |

### Entity mappings added

| Mapping | Context node | Context attribute | Salesforce object.field |
| --- | --- | --- | --- |
| OrderEntitiesMapping | SalesTransactionItem | `ConstraintEngineNodeStatus__c` | `OrderItem.ConstraintEngineNodeStatus__c` |
| QuoteEntitiesMapping | SalesTransactionItem | `ConstraintEngineNodeStatus__c` | `QuoteLineItem.ConstraintEngineNodeStatus__c` |
| AssetEntitiesMapping | AssetActionSource | `AssetConstraintEngineNodeStatus__c` | `AssetActionSource.ConstraintEngineNodeStatus__c` |

See `references/context-definition-changes.md` for exact XML blocks.

### Manual checkpoints

- **AssetToSalesTransactionMapping** cross-attribute mapping (org-specific; not automated).
- **Activate** the context definition version in Setup when required.
- **Always verify manually:** whether deploy succeeds or fails, ask the user to open the context definition in Setup and confirm attributes, entity mappings, and activation. On failure, ask the user to complete changes manually.

## 6) Verification checklist

Use verification script output plus user confirmation:

- `AdvancedConfiguratorDesigner` permission set assigned to setup user
- all three `ConstraintEngineNodeStatus__c` fields exist
- both triggers exist and are Active (either `RCAAdvConfig*` or `QuoteItemTrigger`/`OrderItemTrigger`)
- `enableAdvancedConfigurator` and `enableTransactionProcessor` settings are enabled
- at least one `TransactionProcessingType` row exists with `RuleEngine = AdvancedConfigurator`
- `SalesTransactionTypeId` on Quote and Order layouts (if override behavior is required)
- context definition constraint attributes and Quote/Order/Asset mappings present (optional `--context-definition-name` on verify script)
- AssetToSalesTransactionMapping completed manually when required
- context definition activated when required

## 7) Remaining manual steps

- AssetToSalesTransactionMapping cross-attribute mapping
- Context definition activation in Setup (when not auto-activated on deploy)
- Default transaction type impact review (selection can be irreversible)
