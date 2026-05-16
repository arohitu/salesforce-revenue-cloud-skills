# Troubleshooting Revenue Cloud Pricing

Use this reference when pricing output is missing, incorrect, different between channels, or difficult to trace.

## Value Missing From Pricing

Check:

- sObject field exists and has expected permissions.
- Context attribute exists.
- Context tag matches expression-set variable name.
- Context mapping hydrates the source field.
- Expression set variable is marked as input if the procedure reads it.
- Runtime context actually contains the value.
- Procedure option uses the expected read mapping.

## Value Calculated But Not Written Back

Check:

- Expression set variable is marked as output.
- Context attribute field type is `output` or `inputoutput`.
- Save or persistence mapping includes the target field.
- Procedure option uses the expected save mapping.
- Target field is writable and not formula-only.
- A later procedure does not overwrite the value.

## Decision Table Returns No Row

Check:

- Every required input parameter is present.
- Input data types match decision-table parameter types.
- Operators match the intended behavior.
- Date, currency, product, pricebook, region, quantity, term, and attribute values match the table.
- Active table/version/source object is being used.
- The row exists in the org data, not only in documentation.

## Duplicate Lookup Error

Duplicate lookup errors can mean the lookup key is incomplete. Inspect the runtime context before changing table data.

Common causes:

- A context tag is null even though the source object field has a value.
- A product attribute exists as a child row but was not flattened into a scalar line-level pricing input.
- Picklist selections are carried as value IDs but the pricing lookup expects text.
- API-created transactions skip UI context preparation steps.
- A pre-hook runs but reads the wrong value slot or writes nulls.

## UI Works But API Fails

Do not compare only the visible quote data or API payload. Compare the runtime pricing context.

Check:

- Attribute rows vs scalar line-level pricing inputs.
- UI configuration behavior that may populate values before pricing.
- API paths that skip or minimize configuration.
- Apex pre-hooks that prepare lookup keys.
- Picklist ID to text resolution.

## Procedure Plan Issues

Check:

- Active procedure plan and version.
- Section sequence.
- Option priority.
- Read/save context mappings at plan and option level.
- Whether Apex pre-hooks are first and post-hooks are last for the relevant process type.
- Whether totals run after component pricing.
- Whether the active org differs from source metadata.

## Apex Hook Issues

Check:

- Does the hook query only the needed context tags?
- Does it handle text, number, date, and picklist value representations correctly?
- Does it bulk collect IDs and query outside loops?
- Does it cache repeated lookups within the transaction?
- Does it update context in bulk?
- Does it avoid DML inside the pricing hook?
- Does it avoid large heap usage from loading full context unnecessarily?

## Report The Likely Root Cause Carefully

Separate these categories:

- Metadata issue: missing mapping, tag, variable, output, or active version.
- Runtime context issue: value absent at pricing time.
- Data issue: decision-table row missing, duplicated, inactive, or mismatched.
- Sequencing issue: procedure order or hook placement.
- Persistence issue: calculated value not written back.
- Channel issue: UI and API prepare context differently.
