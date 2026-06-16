# Debug Revenue Cloud Pricing

Use this when a quote, order, product discovery result, or pricing API returns an unexpected price or error.

## Triage Inputs

Ask for:

- Expected price and actual price.
- Quote/order/API execution reference, line item IDs, products, price book, product selling model, currency, quantity, effective dates, and relevant attributes.
- Whether the issue is runtime pricing, product discovery, derived pricing, bundle pricing, promotion/discount, or Apex hook behavior.
- Org access method and whether Salesforce CLI/API access is available.

## Fast Debug Path

1. Reproduce the issue with the smallest representative transaction.
2. Check the Revenue Cloud Operations Console.
3. Review Price Waterfall or persisted waterfall API output.
4. If the waterfall does not explain the issue, ask the user to enable Apex debug logging at `FINEST` for the executing user and reproduce once.
5. Query the Apex log and inspect `RLM_PRICING_BEGIN` and `RLM_PRICING_END`.
6. Compare input context attributes from `RLM_PRICING_BEGIN` with output context attributes from `RLM_PRICING_END` to identify which element, hook, or rule changed the price.

## Decision Table No-Match Or Multiple-Match Errors

When the user sees a pricing error caused by a decision table retrieving zero rows or multiple rows, do not jump to enabling a checkbox/setting that tolerates fallback, first-match, or multiple-match behavior. That can be a technical workaround, but it is rarely the business-preferred requirement. The normal fix is to make the decision table and its runtime inputs return one and only one response for the product and transaction context.

Use this investigation path:

1. Locate the pricing procedure or procedure-plan section that executed for the product.
2. Identify the pricing procedure element that calls the decision table.
3. Determine whether the product reaches that element based on product fields, quote/order fields, line fields, selling model, dates, currency, and any condition criteria on preceding procedure elements.
4. Use the `revenue-cloud-pricing-diagnostics` skill to cross-check the element's input parameters against the context definition and context mappings. Find the source fields that populate each decision table input, not just the context attribute names.
5. Retrieve the actual runtime values for those source fields from the quote, line, product, price book entry, selling model, or other mapped source record.
6. If a decision table input comes from a configurable product attribute, ask the user what attribute values they see or set in the configurator immediately before clicking Save and Exit. Use those values as the Connect API decision table inputs.
7. Call the decision table through the appropriate Connect API/debug endpoint with the same input values to verify whether it returns zero, one, or multiple rows.
8. Recommend a fix based on evidence:
   - If zero rows return, add or adjust the business-valid decision table row, effective dates, conditions, or mapped input value.
   - If multiple rows return, tighten the decision table keys, remove overlapping rows, or add a required disambiguating input that is available in context.
   - If the wrong input values are passed, fix the context mapping, source data, product setup, or procedure element parameter mapping.

Sometimes the input is not a configurable attribute. It may come from a field on `Product2`, `Quote`, `QuoteLineItem`, price book, account, selling model, or another mapped source object. Always trace from the pricing element to the context mapping before deciding which value to pass into the Connect API callout.

## Revenue Cloud Operations Console

Use the Revenue Cloud Operations Console for pricing API execution logs. It records headless pricing and pricing API executions, including discovery and pricing procedures inside API calls.

Check:

- Details tab: status, execution key, API type, endpoint, and reference key.
- Debug Details tab: procedure details, successful and failed line items, element-level messages, and troubleshooting steps.
- Discovery Procedure details for derived pricing or product discovery failures.
- Pricing Procedure details for element-level line item success/failure.

Common findings:

- One line item can fail while others succeed.
- Manual Discount can fail when adjustment type/value inputs are invalid.
- An error status with an empty error log can mean the line item was not executed for pricing.
- Advanced price logs add input values and exception details for complex elements, but should only be enabled during active troubleshooting.

## Price Waterfall

Use waterfall data to explain every calculation step.

- Enable `Activate Price Waterfall for API Responses` for API response waterfalls.
- Enable `Price Waterfall Persistence` to store waterfall process logs.
- Enable `Price Logs Capture` when pricing API execution logs are needed; this automatically enables Price Waterfall and persistence.
- Use advanced price log settings for complex elements such as Attribute-Based Pricing, Derived Pricing, Price Propagation, and Pricing Promotion.
- For API access, the waterfall endpoint is `/connect/core-pricing/waterfall/{lineItemId}/{executionId}` with optional `tagsToFilter` and `usageType=Pricing`.

Inspect each waterfall entry:

- `sequence`
- `pricingElement.name`
- `pricingElement.elementType`
- `inputParameters`
- `outputParameters`
- `fieldToTagNameMapping`
- `diagnosticData`
- `tasksInfo` for parallel execution

## Apex Debug Log Path

When Operations Console and waterfall are insufficient, ask the user to set up debug logs:

1. In Salesforce Setup, open Debug Logs.
2. Add a trace flag for the user that runs pricing.
3. Set Apex Code logging to `FINEST`.
4. Reproduce the pricing action once.
5. Query or retrieve the latest `ApexLog` for that user.

If Salesforce CLI is available, a typical query is:

```bash
sf data query --query "SELECT Id, LogUserId, Operation, StartTime, Status, LogLength FROM ApexLog ORDER BY StartTime DESC LIMIT 10" --target-org <alias>
sf apex log get --log-id <ApexLogId> --target-org <alias> --output-dir ./logs
```

In the log:

- Find `RLM_PRICING_BEGIN`; treat this as the pricing input context attributes.
- Find `RLM_PRICING_END`; treat this as the pricing output context attributes.
- Diff the attributes by line item/context path and focus on tags such as `ListPrice`, `UnitPrice`, `NetUnitPrice`, `Subtotal`, quantity, adjustment values, product, price book, currency, selling model, and custom attributes.
- If Apex hooks are present, correlate hook debug statements with the values immediately before and after the hook execution.

## Root Cause Patterns

- Wrong active pricing procedure: check Product Discovery Settings, Salesforce Pricing Setup, Revenue Settings, and any Procedure Plan Definition.
- Stale decision table data: sync pricing data or refresh the affected decision table.
- Missing or incorrect context mapping: the expected source object field is absent from the context input.
- Decision table ambiguity: duplicate input combinations are not supported; each input combination must resolve to one row.
- Decision table no-match: a required input may be blank, mapped from the wrong source field, or using a configurator attribute value that differs from the user's expected value.
- Inactive or wrong-effective-date artifacts: check price book entry, price adjustment schedule, decision table version, pricing procedure version, and procedure plan version dates/ranks.
- Hidden Apex override: a prehook may alter input before pricing, or a posthook may override output after pricing.
- Procedure sequencing issue: multiple pricing procedures can lose intermediate waterfall visibility or context needed by derived pricing.
- Deleted line items: ensure hook logic requests and filters `$DmlStatus`.

## Debug Output Format

When reporting back, use:

```markdown
## Pricing Trace
- Entry point:
- Line item/product:
- Input context:
- Executed procedure/plan:
- Waterfall elements:
- Apex hooks:
- Output context:

## Finding
[Most likely root cause]

## Fix
[Specific change and how to validate it]
```
