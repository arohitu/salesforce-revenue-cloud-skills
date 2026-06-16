---
name: salesforce-revenue-cloud-pricing
description: Helps design, implement, debug, and explain Salesforce Revenue Cloud pricing logic. Use when users ask about Salesforce Pricing, Agentforce Revenue Management pricing procedures, pricing recipes, decision tables, price adjustment schedules, procedure plans, Apex pricing hooks, Price Waterfall, Revenue Cloud Operations Console logs, or unexpected quote/order/product discovery prices.
---

# Salesforce Revenue Cloud Pricing

Use this skill for Salesforce Revenue Cloud and Agentforce Revenue Management pricing work. Prefer out-of-the-box Salesforce Pricing configuration first, then Apex hooks only when declarative pricing cannot express the requirement.

## Route The Request

- Building or changing pricing logic: read `references/build-pricing.md`.
- Debugging an unexpected price, failed pricing API, or quote/order pricing issue: read `references/debug-pricing.md`.
- Debugging a decision table runtime error where lookup returns no row or multiple rows: read `references/debug-pricing.md`, then use the `revenue-cloud-pricing-diagnostics` skill to trace the pricing element inputs and context mappings.
- Analyzing how a price, total, discount, exchange rate, or pricing field is calculated in an existing implementation: use the `revenue-cloud-pricing-diagnostics` skill as the primary workflow, then read `references/analyze-pricing.md` here only for supplemental Salesforce Pricing setup context.
- Explaining what pricing logic is already implemented at a high level: read `references/analyze-pricing.md`.

If the user has not provided enough context, ask for the business scenario, object/process being priced (quote, order, product discovery, headless API), expected result, actual result, relevant product/price book/selling model, org access method, and any pricing procedure/procedure plan names they already know.

## Default Workflow

1. Identify the pricing surface: quote/order runtime pricing, product discovery pricing, headless pricing API, or procedure plan execution.
2. Establish the active entry point:
   - Product Discovery Settings pricing procedure for product discovery list prices.
   - Salesforce Pricing Setup pricing procedure for headless pricing calls.
   - Revenue Settings pricing procedure for quotes and orders.
   - Procedure Plan Definition when Procedure Plan Orchestration for Pricing is enabled.
3. Map the pricing path from data to result: context definition and mappings, decision tables, pricing recipe, pricing procedure elements, procedure plan sections, and optional Apex hooks.
4. Validate with simulation, Price Waterfall, Revenue Cloud Operations Console price logs, or Apex debug logs depending on the task.
5. Report findings as a concise pricing trace: inputs, matching rules/tables, executed elements/hooks, outputs, and likely fix.

## Ground Rules

- Use the same context definition across pricing procedures and procedure plans.
- Prefer predefined Salesforce Pricing artifacts, especially the Revenue Management Default Pricing Procedure, before creating custom procedures.
- Use decision tables and pricing recipes for maintainable rule lookup; do not hardcode rules in Apex unless declarative pricing cannot meet the requirement.
- For decision table ambiguity or no-match errors, the preferred fix is to make the table inputs resolve to exactly one business-valid row. Do not assume the business wants a checkbox/setting that allows fallback, first-match, or multiple-match behavior.
- Ask users to enable advanced/debug logging only during active troubleshooting and to turn it off afterward.
- When Apex hook logic is needed, place prehooks before the Pricing section and posthooks after it; avoid DML in hooks and keep queries narrow.
