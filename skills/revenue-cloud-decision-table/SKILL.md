---
name: revenue-cloud-decision-table
description: Finds and verifies Salesforce Revenue Cloud Decision Tables. Use when users need to locate a Decision Table Id, discover required Decision Table inputs, build conditionsList payloads, invoke business-rules decision-table lookup APIs, validate pricing lookup outcomes, or debug datasetLinkName and INVALID_AUTH_HEADER issues.
---

# Revenue Cloud Decision Table

Use this skill to find a Salesforce Revenue Cloud Decision Table, determine the inputs needed to invoke it, collect missing runtime values, and verify what the table returns from the org.

## Default Workflow

1. Identify the target org alias or username. If missing, ask for it or use the Salesforce CLI default org only after saying so.
2. Find the Decision Table Id from the user's table name, developer name, label, pricing component, or business scenario.
3. Inspect the table metadata and parameters to identify input fields, output fields, operators, and whether a dataset link name is required.
4. Build a `conditions` payload. If runtime values are missing, ask the user for only the missing input values; otherwise infer them from provided quote/order/product/pricing context.
5. Invoke the table through the Connect REST API and report the returned `outcomeList[].values`, `outcomeType`, `successStatus`, and any errors.
6. Compare the outcome with the user's expected pricing behavior and call out mismatched inputs, wrong dataset link, inactive table, stale refresh status, or auth problems.

## Helper Scripts

The scripts require Salesforce CLI `sf`, `jq`, and an authenticated target org.

- `scripts/find-decision-table.sh`: finds candidate Decision Tables by search text or developer name.
- `scripts/inspect-decision-table-inputs.sh`: queries `DecisionTableParameter` metadata and emits a payload skeleton with `null` values for inputs the agent must fill.
- `scripts/invoke-decision-table.sh`: uses `sf org display` to get the org instance URL and access token, then posts a payload to the Decision Table invocation endpoint.

Run scripts from this skill folder or pass their full path:

```bash
.cursor/skills/revenue-cloud-decision-table/scripts/find-decision-table.sh --target-org <alias> --search "Volume"
.cursor/skills/revenue-cloud-decision-table/scripts/inspect-decision-table-inputs.sh --target-org <alias> --decision-table-id 0lD...
.cursor/skills/revenue-cloud-decision-table/scripts/invoke-decision-table.sh --target-org <alias> --decision-table-id 0lD... --payload-file payload.json
```

Never write real access tokens to files or include them in final answers.

## Finding The Decision Table Id

Use the script first when Salesforce CLI access is available:

```bash
scripts/find-decision-table.sh --target-org <alias> --search "<name or label>"
```

If scripting is not available, use SOQL:

```soql
SELECT Id, DeveloperName, MasterLabel, Type, Status, SourceObject,
       ExecutionType, UsageType, RefreshStatus
FROM DecisionTable
WHERE DeveloperName = '<DecisionTableDeveloperName>'
```

For fuzzy discovery, search `DeveloperName` and `MasterLabel` with `LIKE`. Confirm:
- `Id` is the runtime id used in the URL.
- `Status` is active for runtime pricing.
- `UsageType` and `Type` match the pricing/business scenario.
- `RefreshStatus` indicates data is usable.
- `SourceObject` matches the expected backing table data.

## Identifying Inputs

Use:

```bash
scripts/inspect-decision-table-inputs.sh --target-org <alias> --decision-table-id <0lD...>
```

Read the returned `suggestedPayload`. Replace every `null` value with a runtime value. If the script cannot classify parameters cleanly, inspect `parameters` and ask the user for values for input-like fields. Use the source quote, order, product, price book, pricing scheme, quantity, tier, and attribute values when the user already provided them.

Request only the missing values, for example:

```text
I found RCA_VolumeBasedPrices with these required inputs:
RCA_BundleProduct__c, RCA_ComponentProduct__c, RCA_PriceBook__c, RCA_PricingScheme__c, RCA_LowerBound__c, RCA_UpperBound__c.
Please provide values for RCA_ComponentProduct__c and RCA_PriceBook__c.
```

## Invocation Endpoint

Use Decision Table Invocation unless the user specifically asks for the legacy lookup endpoint:

```http
POST https://<instance>.salesforce.com/services/data/v66.0/connect/business-rules/decision-table/lookup/<decisionTableId>
Authorization: Bearer <access_token>
Content-Type: application/json
```

Use API version `58.0` or later; prefer the org's current supported version. The legacy Decision Table Lookup resource is:

```http
POST /services/data/v55.0/connect/business-rules/decision-table/<decisionTableId>
```

## Payload Pattern

```json
{
  "datasetLinkName": "RCA_VolumeBasedPrices_Default",
  "conditions": [
    {
      "conditionsList": [
        {
          "fieldName": "RCA_BundleProduct__c",
          "value": "01tVc00000CojkbIAB",
          "operator": "Equals"
        },
        {
          "fieldName": "RCA_LowerBound__c",
          "value": 5,
          "operator": "GreaterOrEqual"
        },
        {
          "fieldName": "RCA_UpperBound__c",
          "value": 5,
          "operator": "LessThan"
        }
      ]
    }
  ]
}
```

Rules:
- `conditions` is required.
- `datasetLinkName` is optional, but include the dataset link API name when the table uses one. Common naming is `<DecisionTableDeveloperName>_Default`; verify where possible.
- `fieldName` must match the Decision Table input field API name.
- `value` must use the correct JSON type: numbers unquoted, booleans as booleans, strings quoted.
- `operator` is optional and overrides the table's configured operator when supplied.
- Add `sourceObject` when a dataset link maps multiple source objects and the field is ambiguous.

Common operators: `Equals`, `NotEquals`, `GreaterThan`, `GreaterOrEqual`, `LessThan`, `LessOrEqual`, `Matches`, `ExistsIn`, `DoesNotExistIn`.

## Verify The Return

After invoking, inspect:

```json
{
  "errorCode": null,
  "errorMessage": null,
  "outcomeList": [
    {
      "values": {
        "RCA_UnitPrice__c": "23043.04"
      }
    }
  ],
  "outcomeType": "Single Match",
  "successStatus": true
}
```

Some invocation responses wrap outcomes in `outputs[]`; handle both a direct Decision Table Outcome and an `outputs` array. Treat `outcomeList[].values` as the returned table outputs.

Report the verification as:

```markdown
Decision Table: <DeveloperName> (`<Id>`)
Inputs tested: <field=value, ...>
Outcome type: <Single Match|Multiple Matches|...>
Returned values: <key outputs>
Status: <success or errorCode/errorMessage>
```

## Troubleshooting

For `INVALID_AUTH_HEADER`:
- Confirm the actual HTTP header is `Authorization: Bearer <access_token>`.
- Replace placeholders such as `{{your_access_token_here}}`; do not include braces in the header value.
- Ensure the token belongs to the same Salesforce instance used in the request URL.
- Refresh expired tokens and confirm the user has API and Decision Table access.

For no match or wrong match:
- Confirm the Decision Table is active and refreshed.
- Verify `datasetLinkName` is an API name, not a label.
- Check input field API names, operators, value types, and source object mapping.
- For ranges, validate inclusive/exclusive operator pairs such as `GreaterOrEqual` with `LessThan`.
- Compare the API payload to runtime pricing context values after hydration, Apex hooks, attribute flattening, and formula preparation.

## Apex Alternative

Inside Salesforce Apex, use `ConnectApi.DecisionTableInput`, add `ConnectApi.DecisionTableCondition` values, optionally set `input.datasetLinkName`, and call:

```apex
ConnectApi.DecisionTableOutcome output =
    ConnectApi.DecisionTable.execute(decisionTableId, input);
```
