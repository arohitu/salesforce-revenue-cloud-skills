# Build Revenue Cloud Pricing

Use this when the user wants to build or modify Salesforce Revenue Cloud pricing logic.

## Discovery Questions

Ask for:

- Pricing surface: quote/order, product discovery, or headless pricing API.
- Product model: product, price book, product selling model, bundle structure, attributes, quantity tiers, currency, and effective dates.
- Business rule: list price source, adjustment type, eligibility criteria, precedence, override behavior, and expected waterfall.
- Existing artifacts: context definition, pricing recipe, pricing procedure, procedure plan definition, decision tables, price adjustment schedules, and Apex hooks.

## Out-Of-The-Box Design Order

1. Use price books for base selling prices. Ensure products are active price book entries and bundled products use the same price book when required.
2. Use price adjustment schedules for dynamic adjustments:
   - Price Adjustment Tiers for quantity/volume pricing.
   - Attribute Based Adjustments for product attribute or configuration-based pricing.
   - Bundle Based Adjustments for bundle or combined-product pricing.
3. Use decision tables when rules need tabular matching and outputs such as list prices, discounts, tiers, or custom output values.
4. Use pricing recipes to group and map decision tables to pricing component types. Only one pricing recipe can be active for an org.
5. Use a pricing procedure built from pricing elements. Prefer cloning or reusing predefined templates, especially the Revenue Management Default Pricing Procedure.
6. Use a procedure plan when pricing must run in a sequence with context read/save mappings, rule-based procedure selection, or Apex pre/post hooks.
7. Use Apex hooks only for gaps such as external pricing calls, context enrichment before pricing, or output decoration after pricing.

## Pricing Procedure Checklist

- Enable Context Service and use a context definition such as `SalesTransactionContext` or the customer-specific extension.
- Confirm the pricing procedure has usage type `Pricing`.
- Add the relevant pricing elements and map variables to context tags.
- Select decision tables in Lookup Table Details and map input/output variables.
- Select `Include in Output` for at least one element so downstream processing receives pricing values.
- Set rank so the correct active procedure version is chosen.
- Enable Price Waterfall visibility for elements that must be explainable.
- Refresh/sync decision tables after changing price books, discounts, or source object data.
- Simulate before activation. Use simplified input for quick checks and advanced JSON when testing additional variables or full contexts.

## Procedure Plan Checklist

- Use a procedure plan only when orchestration is needed; PST API orchestrates procedure plans.
- Ensure the procedure plan definition and pricing procedure use the same context definition.
- Configure read context mapping to populate the pricing context and save context mapping to persist calculated results.
- Use `Default` resolution when the section always runs the same procedure or Apex class.
- Use `Rule-Based` resolution when criteria select a procedure or hook based on source object fields.
- In the Place Sales Transaction order of execution, pricing runs after hydration, configuration, ARC resolution, and ARC validation.
- During pricing, execution order is pre-pricing Apex hook, pricing logic, post-pricing Apex hook.
- Do not stitch multiple pricing procedures into one plan unless unavoidable. The waterfall shows only the last pricing procedure, derived pricing can miss prior context, and bundle skip-pricing behavior may not persist between procedures.

## Apex Hook Guidance

- Apex pricing hooks implement `RevSignaling.SignalingApexProcessor`.
- Prehooks are for changing context inputs before pricing, such as setting `PartnerUnitPrice`, quantity, discount, or attributes.
- Posthooks are for changing outputs after pricing, such as descriptions, localized price display, or external override behavior.
- External callouts are supported only when Place Sales Transaction is triggered through the Salesforce UI or PST API, not from Apex or Flow, and not when Double Persist mode is enabled.
- Apex hooks run within governor limits. Query only needed tags, avoid DML, and avoid storing large transaction data in memory.
- Prefer `leanerQueryTags` with specific tags for performance. Request `$DmlStatus` as a separate tag when filtering deleted items.

## Common Gotchas

- A context tag cannot have the same name as a decision table label or API name.
- Variables appear in pricing/discovery procedure UI but are not supported in those procedure types; use context tags or constant resources.
- CSV-based decision tables cannot be used with pricing discovery, Attribute-Based Price elements, or Price Tracking Save operations.
- CSV-based decision tables support Datetime, Text, Boolean, and Number input types, not Currency.
- For multicurrency changes involving predefined Salesforce Pricing decision tables, deactivate pricing procedures/decision tables before changing currency setup and reactivate after.
- Runtime users need access to pricing objects and pricing runtime permissions; UI access can still require sharing settings.
