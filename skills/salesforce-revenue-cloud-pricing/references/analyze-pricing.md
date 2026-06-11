# Analyze Implemented Pricing Logic

Use this when the user asks what pricing logic is implemented or why a price was calculated a certain way.

## Evidence To Collect

Collect the smallest useful set of evidence:

- Active pricing procedure names from Product Discovery Settings, Salesforce Pricing Setup, Revenue Settings, or the active Procedure Plan Definition.
- Context definition and read/save context mappings.
- Pricing recipe and associated decision tables.
- Pricing procedure versions, element sequence, element type, rank, profile access, variable/tag mappings, and Include in Output settings.
- Procedure plan sections, phases, resolution type, rule-based criteria, Apex classes, and section order.
- Price Waterfall output or Operations Console price log for a representative execution.
- Apex hook class names and relevant debug logs if the waterfall does not fully explain the result.

## Metadata/API Objects Worth Querying

Use available org tools, Salesforce CLI, API, metadata retrievals, or user-provided exports. Useful artifacts include:

- `PricingRecipe`
- `PricingRecipeTableMapping`
- Decision tables and lookup table definitions
- `ExpressionSetDefinition` and expression set versions for pricing procedures
- Procedure plan definitions, versions, sections, options, and criteria
- `IndustriesPricingSettings` for settings such as `enableSalesforcePricing`, `enableDebugPriceLogs`, `enablePricingWaterfall`, `enablePricingWaterfallPersistence`, and `enablePricingProcParallelization`
- Price book, price book entry, price adjustment schedule, price adjustment tier, attribute based adjustment, bundle based adjustment, product, product selling model, and related records
- `PricingAPIExecution` and `PricingProcessExecution` records when price logs are enabled
- `ApexClass` and `ApexLog` for Apex hook implementation and runtime behavior

## Trace The Pricing Logic

1. Start with the entry point and active artifact:
   - Product discovery uses the Product Discovery Settings pricing procedure.
   - Headless pricing uses the Salesforce Pricing Setup pricing procedure.
   - Quote/order pricing uses Revenue Settings or a Procedure Plan Definition when orchestration is enabled.
2. Identify context data:
   - Which source object fields are read into the context?
   - Which tags are available to pricing elements?
   - Which calculated tags are saved back?
3. Walk the pricing procedure in execution order:
   - Pricing Setting initializes standard values.
   - List Price determines base/list price.
   - Price Adjustment Matrix, volume, attribute, bundle, promotion, manual discount, derived pricing, price tracking, and other elements adjust or compute values.
   - Include only elements that are actually active and matched by criteria/rank/effective date.
4. Match each element to its decision table/recipe mapping and identify input variables, output variables, and adjustment type/value.
5. If a procedure plan exists, place the pricing procedure inside the section order and account for pre/post Apex hooks.
6. Use waterfall or `RLM_PRICING_BEGIN`/`RLM_PRICING_END` logs to verify runtime input/output values.

## Explain The Result

Return a concise, evidence-backed explanation:

```markdown
## Pricing Logic Summary
[One paragraph explaining the active pricing path.]

## Execution Path
- Entry point:
- Context definition:
- Procedure plan:
- Pricing procedure:
- Recipe/decision tables:
- Apex hooks:

## Calculation Trace
- Step 1:
- Step 2:
- Step 3:

## Data Dependencies
- Products/price books:
- Attributes/quantities/currency:
- Effective dates/ranks:

## Risks Or Gaps
- [Missing evidence, stale data risk, hidden hook, disabled logs, etc.]
```

## Interpretation Rules

- Treat waterfall output as the strongest evidence for what actually ran.
- Treat metadata as design intent; verify with a runtime execution when possible.
- If `RLM_PRICING_BEGIN` and `RLM_PRICING_END` disagree with metadata expectations, prioritize the log values and investigate hooks, context mappings, active versions, and runtime data freshness.
- If multiple active versions could match, rank decides which procedure version is chosen.
- If multiple pricing procedures run in sequence, expect incomplete intermediate visibility in the final waterfall.
