# Pricing Elements And Decision Tables

Use this reference when tracing an expression set step, pricing element, formula, lookup, or aggregation.

## Pricing Elements

Pricing elements are the executable steps inside expression sets. Common elements include:

- List price lookup: finds the base price for a product.
- Volume or tier discount: applies quantity or tier-based discounts.
- Manual discount: applies user-entered discount values.
- Attribute-based adjustment: changes price based on configured product or line attributes.
- Bundle-based pricing: handles parent/child or package pricing.
- Proration: adjusts price for partial terms or dates.
- Subscription pricing: handles recurring pricing and billing periods.
- Formula-based pricing: calculates values from variables and constants.
- Price adjustment matrix: performs multi-parameter decision-table lookup.
- List operation: filters or transforms line collections.
- Assignment: copies or maps values between variables.
- Aggregation: sums, averages, mins, or maxes values across lines.
- Rounding: applies precision and rounding rules.
- Price propagation: moves values through parent/child hierarchy.
- Stop pricing: halts pricing when a condition is met.

## Decision Table Shape

Decision tables usually have:

- Input parameters: fields used for matching.
- Output parameters: values returned by the lookup.
- Operators: equals, range, greater than, less than, or other matching logic.
- Required flags: whether missing input invalidates or broadens the lookup.
- Condition criteria: how inputs combine, such as `1 AND 2 AND 3`.
- Data source: often a custom object or single sObject.
- Active status and versioning.

## Lookup Trace

When a decision table affects a field:

1. Identify the pricing element step that invokes the lookup.
2. List every input variable passed into the lookup.
3. Map each input variable to the decision-table input field.
4. Confirm the runtime values are non-null and correctly typed.
5. Confirm the operator and condition criteria.
6. Identify returned output fields.
7. Map returned output fields to expression-set variables.
8. Trace those output variables to formulas, assignments, aggregations, or persistence.

## Querying And Invoking Decision Tables

When source metadata is not enough, verify the active decision table in the Salesforce org. Revenue Cloud pricing decision tables can be discovered with SOQL and invoked through the Business Rules Engine Connect API.

### 1. Discover The Decision Table

Use SOQL to find the active decision table and its runtime Id:

```soql
SELECT Id, DeveloperName, MasterLabel, Type, Status, SourceObject,
       ExecutionType, UsageType, RefreshStatus
FROM DecisionTable
WHERE DeveloperName = '<DecisionTableDeveloperName>'
```

Check:

- `Id`: required by the lookup API URL.
- `DeveloperName`: API/developer name used by metadata and expression sets.
- `Status`: should be active for runtime pricing.
- `SourceObject`: backing object that stores table rows.
- `ExecutionType`: runtime engine, often high-performance lookup.
- `UsageType`: confirms whether it is used for pricing.
- `RefreshStatus`: indicates whether decision-table data is refreshed and usable.

### 2. Find The Dataset Link Name

The Connect API request needs `datasetLinkName`, not just the decision table developer name. In SFDX source, dataset links are usually under:

```text
force-app/main/default/decisionTableDatasetLinks/*.decisionTableDatasetLink-meta.xml
```

Common naming pattern:

```text
<DecisionTableDeveloperName>_Default
```

Always verify the actual dataset link metadata or org configuration.

### 3. Invoke The Decision Table Lookup API

Use the Business Rules Engine Connect API:

```http
POST /services/data/v<version>/connect/business-rules/decision-table/lookup/<decisionTableId>
Authorization: Bearer <access_token>
Content-Type: application/json
```

Request body pattern:

```json
{
  "datasetLinkName": "<DecisionTableDeveloperName>_Default",
  "conditions": [
    {
      "conditionsList": [
        {
          "fieldName": "<Input_Field_1__c>",
          "value": "<runtime value>",
          "operator": "Equals"
        },
        {
          "fieldName": "<Input_Field_2__c>",
          "value": 5,
          "operator": "GreaterOrEqual"
        }
      ]
    }
  ]
}
```

Example for a volume-based price lookup:

```json
{
  "datasetLinkName": "RCA_VolumeBasedPrices_Default",
  "conditions": [
    {
      "conditionsList": [
        {
          "fieldName": "RCA_BundleProduct__c",
          "value": "01t000000000000AAA",
          "operator": "Equals"
        },
        {
          "fieldName": "RCA_PricingScheme__c",
          "value": "Named Users",
          "operator": "Equals"
        },
        {
          "fieldName": "RCA_ComponentProduct__c",
          "value": "01t000000000001AAA",
          "operator": "Equals"
        },
        {
          "fieldName": "RCA_PriceBook__c",
          "value": "01s000000000000AAA",
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

The response returns `outputs`. A successful single match typically includes:

```json
{
  "outputs": [
    {
      "errorCode": null,
      "errorMessage": null,
      "outcomeList": [
        {
          "values": {
            "RCA_RLFPercentage__c": "0.200",
            "RCA_SubscriptionPercentage__c": "0.450",
            "RCA_UnitPrice__c": "23043.04",
            "RCA_BandPrice__c": "153620.30",
            "RCA_BandLowerBound__c": "5"
          }
        }
      ],
      "outcomeType": "Single Match",
      "successStatus": true
    }
  ]
}
```

Use the returned `values` as the decision table outputs. Then trace each returned field back to the pricing element output variables and downstream expression-set formulas or assignments.

### 4. Compare API Conditions With Expression Set Inputs

The API body should mirror what the pricing element passes at runtime:

- `fieldName` should match the decision-table input parameter field.
- `operator` should match the decision-table operator.
- `value` should be the runtime context value after hydration, Apex pre-hooks, attribute flattening, and formula preparation.
- Range conditions often require two predicates, such as lower-bound `GreaterOrEqual` and upper-bound `LessThan`.

If the API call returns a different result than pricing, the mismatch is usually in runtime input preparation, active decision table/version, dataset link, or procedure sequence.

## Duplicate Or Wrong Lookup Results

Do not assume duplicate lookup errors are caused only by duplicate rows. They can also occur when a required lookup key is missing at runtime. For example:

```text
Expected key: Product + PriceBook + PricingScheme + Attribute
Runtime key:  Product + PriceBook + PricingScheme + null
Result: multiple rows match because the lookup is under-specified
```

If UI pricing works but API pricing fails, inspect runtime context values. The UI path may have hydrated or normalized values that the API path did not prepare.

## Formula And Aggregation Trace

For formula steps:

- Capture all input variables.
- Identify constants and fallback logic.
- Check null, zero, and division behavior.
- Confirm output variable name and data type.

For aggregation steps:

- Identify the collection being aggregated.
- Identify filters applied before aggregation.
- Identify function: sum, average, min, max, or count.
- Confirm whether it aggregates list price, sales amount, cost, margin, or another component.
- Confirm whether the output is header-level or line-level.

## Evidence To Include

In the final report, include concise evidence:

- Step name and action type.
- Output variable.
- Decision table name and input/output parameters.
- Formula expression or aggregation function.
- Context tag that receives the result.
