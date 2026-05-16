# Field Lineage Workflow

Use this workflow when the user provides a field or price result and asks how it is populated, calculated, or affected by pricing.

## Step 1: Identify The Field

Read object field metadata first.

Check:

- Object name and field API name.
- Data type, scale, precision, formula status, and read-only behavior.
- Whether the field is stored or formula-derived.
- Whether the field is a standard field, custom field, managed field, or local custom field.

If it is a formula field, trace the formula dependencies as well as pricing. Formula fields may display pricing output but not be written by pricing directly.

## Step 2: Find The Context Attribute

Search context definitions for:

- Exact field name.
- Field name without local prefixes.
- Related names used in formulas or labels.
- Header node attributes and line item node attributes.

Check attribute properties:

- `dataType`
- `fieldType`: `input`, `output`, `inputoutput`, or `aggregate`
- context tags
- transient vs persisted behavior

## Step 3: Inspect Context Mapping

Find mappings that connect the sObject field to the context attribute.

Check:

- Mapping title/name.
- Mapping intents: hydration, persistence, association, translation.
- Source object and context node.
- `queryAttribute` or target field.
- Context attribute and context input attribute name.

Interpretation:

- Hydration means object field -> context.
- Persistence means context -> object field.
- Association links parent/child records.
- Translation transforms values between representations.

## Step 4: Search Expression Sets

Search active or relevant expression set versions for the context tag and related variable names.

Inspect:

- Variables with `input=true` or `output=true`.
- Step names, labels, sequence numbers, and parent steps.
- Action types such as `PriceAdjustmentMatrix`, `FormulaBasedPricing`, `GroupingAndAggregatePricing`, `Proration`, `SubscriptionPricing`, `Assignment`, or list operations.
- Step input/output parameters.
- Formulas and constants.
- Conditions and stop-pricing branches.

Do not stop at the first occurrence. A field may be hydrated early, transformed in one procedure, aggregated in another, and persisted only at the end.

## Step 5: Trace Lookup Or Calculation Inputs

For a pricing element:

- Identify its source variables.
- Map element variables to decision-table input fields.
- Confirm required inputs are present in runtime context.
- Trace returned decision-table outputs to expression-set variables.
- Trace formula inputs, constants, and output targets.
- For aggregation, identify the collection, filter criteria, aggregate function, and output variable.

## Step 6: Check Procedure Plan Context

If multiple procedures exist, determine order:

- Apex pre-hook or post-hook.
- Main pricing procedure.
- Component-specific pricing procedures.
- Totals or aggregation procedure.
- Option-level read/save context mappings.

Values can be produced by one procedure and consumed by later procedures. Execution order often explains why a field is blank, overwritten, or stale.

## Step 7: Write The Lineage

Your final answer should separate evidence from inference:

- Evidence: file paths, metadata snippets, org query results, step names, mapping names.
- Inference: likely runtime behavior based on metadata.
- Unknowns: active version or org-only metadata not available in source.

Prefer a short lineage report over a raw dump of metadata.
