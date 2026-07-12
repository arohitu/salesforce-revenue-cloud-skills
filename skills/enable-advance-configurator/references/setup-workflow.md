# Advanced Configurator Setup Workflow

This reference expands the operational steps for enabling Advanced Configurator (Constraint Rules Engine) from `docs/enable_adv_config.md`.

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

The generated script templates use dedicated names to avoid collisions with existing org triggers.

## 2) Revenue Settings toggles (manual)

These are Setup UI actions and must be confirmed by the user:

1. Setup -> Revenue Settings -> turn on **Set Up Configuration Rules and Constraints with Constraints Engine**
2. Setup -> Revenue Settings -> turn on **Transaction processing for quotes and orders** when transaction processing type routing is needed

## 3) Transaction Processing Type (Tooling API)

Create or reuse a `TransactionProcessingType` record with:

- `RuleEngine = AdvancedConfigurator`
- `SaveType = Standard` (default in script unless overridden)

The skill script supports optional preference fields such as:

- `PricingPreference`
- `TaxPreference`
- `RatingPreference`

Important:

- Choosing or changing a default transaction type during enablement can be irreversible; require explicit user acknowledgement.

## 4) Layout and user override readiness (manual)

If business users need to override transaction type on quote/order:

- add `Transaction Type` field to Quote and Order layouts
- confirm field-level visibility and required permissions

## 5) Verification checklist

Use verification script output plus user confirmation:

- required objects are available in target org
- all three `ConstraintEngineNodeStatus__c` fields exist
- both triggers exist and are Active
- at least one `TransactionProcessingType` row exists with `RuleEngine = AdvancedConfigurator`
- user confirms Revenue Settings toggles are on
- user confirms layout updates (if required by process)
