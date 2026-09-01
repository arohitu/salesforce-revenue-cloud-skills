# Salesforce Pricing Business APIs

Perform pricing request, create context instance, sync pricing data, and manage pricing recipes and pricing waterfall details by using Salesforce Pricing Business APIs. This table lists the available Salesforce Pricing resources.

| Resource | Description |
| --- | --- |
| /connect/core-pricing/price-contexts/contextid (POST) | Perform a pricing request by using the instance ID of a context. |
| /connect/core-pricing/pricing (POST) | Create and hydrate context instance in a single request. Provide a comprehensive response that contains final pricing details per line items and related errors, if any. |
| /connect/core-pricing/sync/pricingSyncOrigin (GET) | Sync pricing data to ensure that the lookup tables contain the latest pricing data. |
| /connect/core-pricing/recipe (GET) | Get the mapping details of pricing recipes to the associated pricing recipe table. |
| /connect/core-pricing/revenue/pricing-recipe/valid-elements (GET) | Get the list of valid pricing element type API names for a given Pricing Usage Sub Type. |
| /connect/core-pricing/revenue/pricing-recipe/clone (POST) | Clone a pricing recipe with all its associated pricing recipe table mappings. |
| /connect/core-pricing/recipe/mapping (POST) | Create a mapping between the pricing recipe and the Decision Tables. Post recipes with lookup tables or procedures. |
| /connect/core-pricing/versioned-revise-details (POST) | Create revisions of a pricing request with versions for adjustment entities. |
| /connect/core-pricing/waterfall/lineItemId/executionId (GET) | Get the persisted price waterfall that stores the process logs. Price waterfall provides insights into every step of the pricing process. |
| /connect/core-pricing/waterfall (POST) | Create a log of price waterfall. Price waterfall provides insights into every step of the pricing process. |
| /connect/core-pricing/pbeDerivedPricingSourceProduct (POST) | Get the source product for the Price Book Entry (PBE) derived pricing. |
| /connect/core-pricing/apiexecutionlogs/executionId (GET) | Get the log details of a pricing API execution record by using the execution ID. |
| /connect/core-pricing/pricing-process-execution/executionId (GET) | Get the execution details of a pricing process by using the execution ID. |
| /connect/core-pricing/pricing-process-execution/lineitems/executionId/executionType (GET) | Get the pricing execution details for the line items of a pricing process by using the execution ID and execution type. |
| /connect/core-pricing/simulationInputVariablesWithData (GET) | Get details of the pricing simulation input variables along with associated data. |

This section lists the available Procedure Plan Definition-related resources. Use procedure plan definitions to define criteria for all pricing process-related requirements in one central location, and to set up the procedures based on these requirements.

| Resource | Description |
| --- | --- |
| /connect/procedure-plan-definitions (GET, POST) | Get the records of procedure plan definitions. Additionally, create a record of a procedure plan definition. |
| /connect/procedure-plan-definitions/procedurePlanDefinitionId (GET, PATCH, DELETE) | Get, update, or delete a procedure plan definition record by using the record ID. |
| /connect/procedure-plan-definitions/evaluate (POST) | Evaluate a procedure plan definition based on a primary object to check for prerequisites such as usage type and context mapping details. |
| /connect/procedure-plan-definitions/evaluate/procedurePlanDefinitionName (POST) | Evaluate a procedure plan definition based on the name of a definition to check for prerequisites such as usage type and context mapping details. |
| /connect/procedure-plan-definitions/procedurePlanDefinitionId/version (POST) | Create records of a procedure plan version with details. |
| /connect/procedure-plan-definitions/versions/procedurePlanVersionId (GET, PATCH, DELETE) | Get, update, or delete a procedure plan definition version record by using the record ID. |

Learn more about the available Salesforce Pricing resources.
- **Request Bodies**
Learn more about the available Salesforce Pricing API request bodies.
- **Response Bodies**
Learn more about the available Salesforce Pricing API response bodies.

**See also**

Connect REST API Developer Guide: Introduction

## Resources

Learn more about the available Salesforce Pricing resources.
- **PBE Derived Pricing (POST)**
Get the source product for the Price Book Entry (PBE) derived pricing.
- **Price Context (POST)**
Perform a pricing request by using the instance ID of a context.
- **Pricing (POST)**
Create and hydrate context instance in a single request. Provide a comprehensive response that contains final pricing details per line items and related errors, if any.
- **API Execution Logs (GET)**
Get the log details of a pricing API execution record by using the execution ID.
- **Pricing Process Execution (GET)**
Get the execution details of a pricing process by using the execution ID.
- **Pricing Process Execution for Line Items (GET)**
Get the pricing execution details for the line items of a pricing process by using the execution ID and execution type.
- **Pricing Data Sync (GET)**
Sync pricing data to ensure that the lookup tables contain the latest pricing data.
- **Pricing Recipe (GET)**
Get the mapping details of pricing recipes to the associated pricing recipe table.
- **Pricing Recipe Valid Elements (GET)**
Get the list of valid pricing element type API names for a given Pricing Usage Sub Type.
- **Pricing Recipe Clone (POST)**
Clone a pricing recipe with all its associated pricing recipe table mappings.
- **Pricing Recipe Mapping (POST)**
Create a mapping between the pricing recipe and the Decision Tables. Post recipes with lookup tables or procedures.
- **Pricing Versioned Revision Details (POST)**
Create revisions of a pricing request with versions for adjustment entities.
- **Pricing Waterfall (GET)**
Get the persisted price waterfall that stores the process logs. Price waterfall provides insights into every step of the pricing process.
- **Pricing Waterfall (POST)**
Create a log of price waterfall. Price waterfall provides insights into every step of the pricing process.
- **Procedure Plan Definitions (GET, POST)**
Get the records of procedure plan definitions. Additionally, create a record of a procedure plan definition.
- **Procedure Plan Definition By ID (GET, PATCH, DELETE)**
Get, update, or delete a procedure plan definition record by using the record ID.
- **Procedure Plan Evaluation By Object (POST)**
Evaluate a procedure plan definition based on a primary object to check for prerequisites such as usage type and context mapping details.
- **Procedure Plan Evaluation By Definition Name (POST)**
Evaluate a procedure plan definition based on the name of a definition to check for prerequisites such as usage type and context mapping details.
- **Procedure Plan Version (POST)**
Create records of a procedure plan version with details.
- **Procedure Plan Version Details (GET, PATCH, DELETE)**
Get, update, or delete a procedure plan definition version record by using the record ID.
- **Pricing Simulation Input Variables With Data (GET)**
Get details of the pricing simulation input variables along with associated data.

### PBE Derived Pricing (POST)

Get the source product for the Price Book Entry (PBE) derived pricing.

**Resource**

`/connect/core-pricing/pbeDerivedPricingSourceProduct`

**Resource example**

`https://yourInstance.salesforce.com/services/data/v68.0/connect/core-pricing/pbeDerivedPricingSourceProduct`

**Available version**

61.0

**HTTP methods**

POST

**Request body for POST**

**JSON example**

```json
{
  "productId": "01txx0000006i2SAAQ",
  "pricebookEntryId": "01uxx0000008yYcAAI",
  "effectiveFrom": "2020-01-01T22:53:20.000Z",
  "effectiveTo": "2021-01-01T22:53:20.000Z"
}
```

**Properties**

| Name | Type | Description | Required/Optional | Available Version |
| --- | --- | --- | --- | --- |
| effectiveFrom | String | Date from when the price book entry is effective. | Required | 61.0 |
| effectiveTo | String | Date until when the price book entry is effective. | Required | 61.0 |
| pricebookEntryId | String | ID of the price book entry. | Required | 61.0 |
| productId | String | ID of the price book. | Required | 61.0 |

**Response body for POST**

PBE Derived Pricing

### Price Context (POST)

Perform a pricing request by using the instance ID of a context. If price waterfall is disabled from Salesforce Pricing Setup in your org, this API doesn't return the waterfall details. You can use the Price Waterfall API to retrieve the waterfall details if price waterfall persistence is enabled in Salesforce Pricing Setup.

**Resource**

`/connect/core-pricing/price-contexts/contextid`

**Resource example**

`https://yourInstance.salesforce.com/services/data/v68.0/connect/core-pricing/price-contexts/0U3RM00000000SR0AY`

**Available version**

60.0

**HTTP methods**

POST

**Request body for POST**

**JSON example**

```json
{
"configurationOverrides": {
"skipWaterfall": true,
"useSessionScopedContext": true,
"persistContext": true,
"taggedData": false
}
"procedureName": "ES1"
}
```

**Properties**

| Name | Type | Description | Required/Optional | Available Version |
| --- | --- | --- | --- | --- |
| configurationOverrides | Configuration Override Input | Parameters to override pricing configuration. | Optional | 60.0 |
| procedureName | String | Name of the pricing procedure. | Optional | 60.0 |

**Response body for POST**

Pricing Response

### Pricing (POST)

Create and hydrate context instance in a single request. Provide a comprehensive response that contains final pricing details per line items and related errors, if any. If price waterfall is disabled from Salesforce Pricing Setup in your org, this API doesn't return the waterfall details. You can use the Price Waterfall API to retrieve the waterfall details if price waterfall persistence is enabled in Salesforce Pricing Setup.

**Resource**

`/connect/core-pricing/pricing`

**Resource example**

`https://yourInstance.salesforce.com/services/data/v68.0/connect/core-pricing/pricing`

**Available version**

60.0

**Requires Chatter**

No

**HTTP methods**

POST

**Request body for POST**

**JSON example**

```json
{
  "contextDefinitionId": "11Oxx0000006PdxEAE",
  "contextMappingId": "11jxx0000004LDDAA2",
  "jsonDataString": {
    "Cart": [
      {
        "id": "cart_1001",
        "cart_id": "cart_1001",
        "PriceBookId": "PriceBookId_1001",
        "businessObjectType": "Cart",
        "CartItem": [
          {
            "id": "lineItem_1001",
            "line_item_id": "lineItem_1001",
            "Quantity": 7,
            "PriceType": "OneTime",
            "Frequency": "",
            "UOM": "",
            "businessObjectType": "CartItem",
            "product_id": "01txx0000006i44AAA",
            "UnitPrice": 6.8,
            "NetUnitPrice": 0,
            "Attribute": [
              {
                "name": "Color",
                "code": "RED",
                "isPriceImpacting": true,
                "businessObjectType": "Attribute",
                "id": "Attribute_1001",
                "attribute_id": "Attribute_1001"
              },
              {
                "name": "Size",
                "code": "10INCH",
                "isPriceImpacting": true,
                "businessObjectType": "Attribute",
                "id": "Attribute_1002",
                "attribute_id": "Attribute_1002"
              }
            ]
          },
          {
            "id": "lineItem_1002",
            "line_item_id": "lineItem_1002",
            "quantity": 3,
            "PriceType": "OneTime",
            "Frequency": "",
            "UOM": "",
            "businessObjectType": "CartItem",
            "product_id": "01txx0000006i2SAAQ",
            "unitprice": 6,
            "NetUnitPrice": 0,
            "Attribute": [
              {
                "name": "Color",
                "code": "BLUE",
                "isPriceImpacting": true,
                "businessObjectType": "Attribute",
                "id": "Attribute_1003",
                "attribute_id": "Attribute_1003"
              },
              {
                "name": "Size",
                "code": "6INCH",
                "isPriceImpacting": true,
                "businessObjectType": "Attribute",
                "id": "Attribute_1004",
                "attribute_id": "Attribute_1004"
              }
            ]
          }
        ]
      }
    ]
  },
  "pricingProcedureId": "9QMxx0000004CKKGA2",
  "configurationOverrides": {
    "skipWaterfall": true,
    "useSessionScopedContext": true,
    "persistContext": true,
    "referenceKey": "referenceKey-12345",
    "displayContext": false,
    "taggedData": false,
    "isHighVolumeLineItems": false
  }
}
```

**Properties**

| Name | Type | Description | Required/Optional | Available Version |
| --- | --- | --- | --- | --- |
| configurationOverrides | Configuration Override Input | Parameters to override the pricing configuration. | Optional | 60.0 |
| contextDefinitionId | String | ID of the context definition that defines the structure of the input data. | Required | 60.0 |
| contextMappingId | String | ID of the context mapping that maps the input data to the context instance. | Required | 60.0 |
| jsonDataString | String | Data to hydrate the context, which must be in JSON format and passed as String. Pass the JSON data as String by using the stringify() method to convert the object to string. The keys in the jsonDataString property | Required | 60.0 |

| Name | Type | Description | Required/Optional | Available Version |
| --- | --- | --- | --- | --- |
| pricingProcedureId | String | ID or API name of the pricing procedure used for calculating the prices. A pricing procedure is represented as an Expression Set Definition in the system. If you’re an Experience Cloud user, specify the name of the pricing procedure. | Optional | 60.0 |

**Response body for POST**

Pricing Output

### API Execution Logs (GET)

Get the log details of a pricing API execution record by using the execution ID.

**Resource**

`/connect/core-pricing/apiexecutionlogs/executionId`

**Resource example**

`https://yourInstance.salesforce.com/services/data/v68.0/connect/core-pricing/apiexecutionlogs/29646938297972`

**Available version**

63.0

**HTTP methods**

GET

**Path parameter for GET**

| Name | Type | Description | Required/Optional | Available Version |
| --- | --- | --- | --- | --- |
| executionId | String | ID of the pricing process execution record. | Required | 63.0 |

**Response body for GET**

Pricing Execution Waterfall Response

### Pricing Process Execution (GET)

Get the execution details of a pricing process by using the execution ID.

**Resource**

`/connect/core-pricing/pricing-process-execution/executionId`

**Resource example**

`https://yourInstance.salesforce.com/services/data/v68.0/connect/core-pricing/pricing-process-execution/29646938297972`

**Available version**

63.0

**HTTP methods**

GET

**Path parameter for GET**

| Name | Type | Description | Required/Optional | Available Version |
| --- | --- | --- | --- | --- |
| executionId | String | ID of the pricing process execution record. The ID is generated each time a pricing process is executed. | Required | 63.0 |

**Query parameter for GET**

| Name | Type | Description | Required/Optional | Available Version |
| --- | --- | --- | --- | --- |
| executionType | String | Type of execution that's defined internally within the pricing API. Valid values are: - API_Execution - Discovery —Discovery procedure - Discovery_Line —Discovery procedure for the line items. - Pricing —Pricing procedure - Pricing_Line —Pricing procedure for the line items. If the executionType parameter isn't specified, the API retrieves records for all the execution types that are associated with the specified execution ID. | Optional | 63.0 |

**Response body for GET**

Pricing Process Execution Response

### Pricing Process Execution for Line Items (GET)

Get the pricing execution details for the line items of a pricing process by using the execution ID and execution type.

**Resource**

`/connect/core-pricing/pricing-process-execution/lineitems/executionId/executionType`

**Resource example**

`https://yourInstance.salesforce.com/services/data/v68.0/connect/core-pricing/pricing-process-execution/lineitems/29646938297972/Pricing_Line`

**Available version**

63.0

**HTTP methods**

GET

**Path parameters for GET**

| Name | Type | Description | Required/Optional | Available Version |
| --- | --- | --- | --- | --- |
| executionId | String | ID of the pricing process execution record. | Required | 63.0 |
| executionType | String | Type of the execution that's defined internally within the pricing API. Valid values are: - Pricing_Line - Discovery_Line | Required | 63.0 |

**Response body for GET**

Pricing Process Execution Details for Line Items

### Pricing Data Sync (GET)

Sync pricing data to ensure that the lookup tables contain the latest pricing data. To partially synchronize pricing data, use the Decision Table Refresh Action in a Flow. See Decision Table Refresh Action.

**Resource**

`/connect/core-pricing/sync/pricingSyncOrigin`

**Resource example**

`https://yourInstance.salesforce.com/services/data/v68.0/connect/core-pricing/sync/syncData`
This example shows a sample resource to filter by pricing recipe.
`https://yourInstance.salesforce.com/services/data/v68.0/connect/core-pricing/sync/syncData?pricingRecipeId=12Gxx0000005IzhEAE`

**Available version**

60.0

**HTTP methods**

GET

**Request parameters for GET**

| Name | Type | Description | Required/Optional | Available Version |
| --- | --- | --- | --- | --- |
| pricingRecipeId | String | ID of the pricing recipe whose decision tables you want to sync. If not specified, the default pricing recipe is used. | Optional | 67.0 |

**Response body for GET**

Pricing Generic Response

### Pricing Recipe (GET)

Get the mapping details of pricing recipes to the associated pricing recipe table.

**Resource**

`/connect/core-pricing/recipe`

**Resource example**

`https://yourInstance.salesforce.com/services/data/v68.0/connect/core-pricing/recipe`

**Available version**

60.0

**HTTP methods**

GET

**Response body for GET**

Pricing Recipe Response

### Pricing Recipe Valid Elements (GET)

Get the list of valid pricing element type API names for a given Pricing Usage Sub Type.

**Resource**

`/connect/core-pricing/revenue/pricing-recipe/valid-elements`

**Resource example**

`https://yourInstance.salesforce.com/services/data/v68.0/connect/core-pricing/revenue/pricing-recipe/valid-elements?pricingUsageSubType=RevenueCloud`

**Available version**

68.0

**HTTP methods**

GET

**Request parameters for GET**

| Name | Type | Description | Required/Optional | Available Version |
| --- | --- | --- | --- | --- |
| pricingUsageSubType | String | Pricing usage subtype to retrieve the valid element types for. Must match an entry in the PricingUsageSubType picklist. For example, RevenueCloud , Loyalty , LifeSciences , and Commercial . | Required | 68.0 |

**Response body for GET**

Pricing Recipe Valid Elements

### Pricing Recipe Clone (POST)

Clone a pricing recipe with all its associated pricing recipe table mappings.

**Resource**

`/connect/core-pricing/revenue/pricing-recipe/clone`

**Resource example**

`https://yourInstance.salesforce.com/services/data/v68.0/connect/core-pricing/revenue/pricing-recipe/clone`

**Available version**

68.0

**HTTP methods**

POST

**Request body for POST**

**JSON example**

```json
{
  "recordId": "0ClxX0000004CxWACU",
  "newPricingRecipeApiName": "Cloned_Recipe",
  "newPricingRecipeName": "Cloned Recipe",
  "pricingUsageSubType": "Loyalty"
}
```

**Properties**

| Name | Type | Description | Required/Optional | Available Version |
| --- | --- | --- | --- | --- |
| newPricingRecipeApiName | String | API name of the cloned pricing recipe. | Required | 68.0 |
| newPricingRecipeName | String | Name for the cloned pricing recipe. | Required | 68.0 |
| pricingUsageSubType | String | Pricing usage subtype of the cloned pricing recipe. If unspecified, the value from the source pricing recipe is used. | Optional | 68.0 |
| recordId | String | ID of the source pricing recipe to clone. | Required | 68.0 |

**Response body for POST**

Pricing Recipe Clone

### Pricing Recipe Mapping (POST)

Create a mapping between the pricing recipe and the Decision Tables. Post recipes with lookup tables or procedures.

**Resource**

`/connect/core-pricing/recipe/mapping`

**Resource example**

`https://yourInstance.salesforce.com/services/data/v68.0/connect/core-pricing/recipe/mapping`

**Available version**

60.0

**HTTP methods**

POST

**Request body for POST**

**JSON example**

```json
{
"recipeId" : "12Gxx0000005J9MEAU",
"pricingRecipeLookUpTableInputRepresentations": [
{
lookupId: "12Gxx0000005J9MEAU",
pricingComponentType: "CustomDiscount"
},
{
lookupId: "12Gxx0000005J9MEAU",
pricingComponentType: "CustomDiscount"
}
],
"pricingRecipeProcedureInputRepresentation" : {
"procedureId" : "9QLxx0000004C92GAE"
}
}
```

**Properties**

| Name | Type | Description | Required/Optional | Available Version |
| --- | --- | --- | --- | --- |
| pricingRecipeLookUpTableInputRepresentations | Pricing Recipe LookUp Table Input [] | Input representation of the recipe mapping. | Required | 60.0 |
| pricingRecipeProcedureInputRepresentation | Pricing Recipe Procedure Input | Input representation of the procedure that’s used in the pricing recipe. | Required | 60.0 |
| recipeId | String | ID of the pricing recipe. | Required | 60.0 |

**Response body for POST**

Pricing Recipe Post

### Pricing Versioned Revision Details (POST)

Create revisions of a pricing request with versions for adjustment entities.

**Resource**

`/connect/core-pricing/versioned-revise-details`

**Resource example**

`https://yourInstance.salesforce.com/services/data/v68.0/connect/core-pricing/versioned-revise-details`

**Available version**

60.0

**HTTP methods**

POST

**Request body for POST**

**JSON example**

This example shows the input for versioned revision details for attribute-based adjustment.

```json
{
"entityName":"AttributeBasedAdjustment",
"id":"entityId",
"priceAdjustmentId":"priceAdjustmentScheduleId",
"productId":"ProductId",
"productSellingModelId":"PsmId",
"adjustmentType":"AdjustmentType",
"adjustmentValue":"AdjustmentValue(Numeric)"",
"effectiveFrom":"EffectiveFrom date",
"effectiveTo":"EffectiveTo Date",
"additionalFieldsToValueMap":{
"attributeBasedAdjRuleId":"AttributeBasedAdjRuleId"
}
}
```

This example shows the input for versioned revision details for bundle-based adjustment.

```json
{
  "entityName": "BundleBasedAdjustment",
  "id": "entityId",
  "priceAdjustmentScheduleId": "priceAdjustmentScheduleId",
  "productId": "ProductId",
  "productSellingModelId": "PsmId",
  "adjustmentType": "AdjustmentType",
  "adjustmentValue": "AdjustmentValue(Numeric)",
  "effectiveFrom": "EffectiveFrom date",
  "effectiveTo": "EffectiveTo Date",
  "additionalFieldsToValueMap": {
    "rootBundleId": "RootBundleId",
    "parentProductId": "ParentProductId"
  }
}
```

**Properties**

| Name | Type | Description | Required/Optional | Available Version |
| --- | --- | --- | --- | --- |
| additionalFieldsToValueMap | Map<String, String> | Map containing the additional fields specific to the entity. | Optional | 60.0 |
| adjustmentType | String | Adjustment type such as, percentage, amount, or override. | Required | 60.0 |
| adjustmentValue | String | Value for the adjustment. | Required | 60.0 |
| effectiveFrom | String | Date from when the adjustment is effective. | Required | 60.0 |
| effectiveTo | String | Date until when the adjustment is effective. | Optional | 60.0 |
| entityName | String | Name of the entity such as AttributeBasedAdjustment entity or BundleBasedAdjustment entity. | Required | 60.0 |

| Name | Type | Description | Required/Optional | Available Version |
| --- | --- | --- | --- | --- |
| id | String | ID of the record. | Required | 60.0 |
| priceAdjustmentScheduleId | String | ID of the price adjustment schedule record. | Required | 60.0 |
| productId | String | Product ID of the record. | Required | 60.0 |
| productSellingModelId | String | Product selling model ID associated to the record. | Optional | 60.0 |

**Response body for POST**

Pricing Versioned Revision Details

### Pricing Waterfall (GET)

Get the persisted price waterfall that stores the process logs. Price waterfall provides insights into every step of the pricing process. If price waterfall persistence is disabled from Salesforce Pricing Setup in your org, this API doesn't return the waterfall details. You can view the waterfall details in the Pricing API or Price Context API response if price waterfall is enabled in Salesforce Pricing Setup. Advanced Price Logs You can set up advanced price logs to capture exception details for complex pricing elements. The API response captures input and output values to trace any exceptions. Refer to the diagnostic data available in the price waterfall details to identify and fix performance issues. See Advanced Price Logs.

**Resource**

`/connect/core-pricing/waterfall/lineItemId/executionId`

**Resource example**

`https://yourInstance.salesforce.com/services/data/v68.0/connect/core-pricing/waterfall/Gold/2yHdNNEFOZr9jAe4gHS7?tagsToFilter=UnitPrice`

**Available version**

60.0

**HTTP methods**

GET

**Query parameters**

| Name | Type | Description | Required/Optional | Available Version |
| --- | --- | --- | --- | --- |
| tagsToFilter | String | Comma-separated tags to filter. | Optional | 61.0 |
| usageType | String | Usage type of the waterfall log record. Valid values are: | Optional | 62.0 |

**Response body for GET**

Line Item Waterfall Response

### Pricing Waterfall (POST)

Create a log of price waterfall. Price waterfall provides insights into every step of the pricing process.

**Resource**

`/connect/core-pricing/waterfall`

**Resource example**

`https://yourInstance.salesforce.com/services/data/v68.0/connect/core-pricing/waterfall`

**Available version**

60.0

**HTTP methods**

POST

**Request body for POST**

**JSON example**

```json
{
  "currencyCode": "USD",
  "executionEndTimestamp": "2023-07-31T20:11:29.625Z",
  "executionId": "executionId1",
  "executionStartTimestamp": null,
  "lineItemId": "item1",
  "output": {
    "Subtotal": 38.25,
    "ListPrice": 10,
    "NetUnitPrice": 7.65
  },
  "waterfall": [
    {
      "fieldToTagNameMapping": {
        "Product2Id": "ItemProduct",
        "Subtotal": "Subtotal",
        "Pricebook2Id": "Pricebook",
        "Quantity": "ItemQuantity",
        "LineItemId": "SalesTransactionSource",
        "ListPrice": "ItemListPrice"
      },
      "inputParameters": {
        "Product2Id": "01txx0000006i44AAA",
        "Pricebook2Id": "01sxx0000005q9xAAA",
        "Quantity": 5,
        "LineItemId": "item1"
      },
      "outputParameters": {
        "Subtotal": 50,
        "ListPrice": 10
      },
      "pricingElement": {
        "adjustments": [
          {
            "AdjustmentValue": "95.00",
            "AdjustmentType": "Amount"
          }
        ],
        "description": null,
        "elementType": "ListPrice",
        "name": "List Price"
      },
      "sequence": 1
    },
    {
      "fieldToTagNameMapping": {
        "PriceAdjustmentScheduleId": "ItemDescription",
        "NetUnitPrice": "ItemNetUnitPrice",
        "Product2Id": "ItemProduct",
        "LowerBound": "ItemQuantity",
        "UpperBound": "ItemQuantity",
        "Subtotal": "Subtotal",
        "Quantity": "ItemQuantity",
        "LineItemId": "SalesTransactionSource",
        "InputUnitPrice": "ItemListPrice"
      },
      "inputParameters": {
        "PriceAdjustmentScheduleId": "84Xxx0000004CGSEA2",
        "Product2Id": "01txx0000006i44AAA",
        "LowerBound": 5,
        "UpperBound": 5,
        "Quantity": 5,
        "LineItemId": "item1",
        "InputUnitPrice": 10
      },
      "outputParameters": {
        "NetUnitPrice": 8.5,
        "Subtotal": 42.5
      },
      "pricingElement": {
        "adjustments": [
          {
            "AdjustmentValue": "15.00",
            "AdjustmentType": "Percentage"
          }
        ],
        "description": null,
        "elementType": "VolumeDiscount",
        "name": "Volume Discount"
      },
      "sequence": 2
    }
  ]
}
```

**Properties**

| Name | Type | Description | Required/Optional | Available Version |
| --- | --- | --- | --- | --- |
| contextDefinitionVersionId | String | Context definition version ID of the pricing procedure. | Optional | 60.0 |
| contextMappingId | String | Context mapping ID of the pricing procedure. | Optional | 60.0 |
| currencyCode | String | Currency code such as, USD or INR. | Optional | 60.0 |
| executionEndTimestamp | String | End timestamp of procedure execution. | Optional | 60.0 |
| executionId | String | Execution ID for a particular execution of a pricing procedure. | Required | 60.0 |
| executionStartTimestamp | String | Start timestamp of procedure execution. | Optional | 60.0 |
| lineItemId | String | Line item ID for which the price is being calculated. | Required | 60.0 |
| output | Map<String, Object> | Output of the pricing procedure. | Optional | 60.0 |
| waterfall | Pricing Waterfall Input [] | Details of the pricing waterfall. | Required | 60.0 |

**Response body for POST**

Pricing Generic Response

### Procedure Plan Definitions (GET, POST)

Get the records of procedure plan definitions. Additionally, create a record of a procedure plan definition.

**Resource**

`/connect/procedure-plan-definitions`

**Resource example**

`https://yourInstance.salesforce.com/services/data/v68.0/connect/`
procedure-plan-definitions?isTemplate=true

**Available version**

62.0

**HTTP methods**

GET, POST

**Request parameters for GET**

| Name | Type | Description | Required/Optional | Available Version |
| --- | --- | --- | --- | --- |
| isTemplate | Boolean | Indicates whether to return a list of file-based definitions (true) or not (false). This API request returns a list of database-based definitions, by default. | Optional | 62.0 |

**Response body for GET**

Procedure Plan Definitions

**Request body for POST**

**JSON example**

This example shows a sample request to create a procedure plan definition record by using the Procedure Plan Definitions (POST) API.

```json
{
  "description": "Definition for Quote",
  "developerName": "Quote_Definition_Sample",
  "name": "Quote_Definition_Sample",
  "processType": "Default",
  "primaryObject": "BusinessHours",
  "procedurePlanDefinitionVersions": [
    {
      "active": false,
      "contextDefinition": "SalesTransactionContext__stdctx",
      "readContextMapping": "QuoteEntitiesMapping",
      "saveContextMapping": "QuoteEntitiesMapping",
      "effectiveFrom": "2024-07-15T10:15:30.000Z",
      "developerName": "Quote_Definition_V1",
      "rank": 1
    }
  ]
}
```

**Properties**

| Name | Type | Description | Required/Optional | Available Version |
| --- | --- | --- | --- | --- |
| description | String | Description of the procedure plan definition. | Optional | 62.0 |
| developerName | String | Developer name of the procedure plan definition. | Required if you’re invoking the Procedure Plan Definitions API (POST) . | 62.0 |
| name | String | Name of the procedure plan definition. | Optional | 62.0 |
| primaryObject | String | Source object that’s used to create a procedure with rule-based criteria. This property value must be a valid object name and must be unique in the ProcedurePlanDefinition object. | Required if you’re invoking the Procedure Plan Definitions API (POST) and if you’re creating a procedure with rule-based criteria. | 62.0 |
| procedurePlanDefinitionVersions | Procedure Plan Definition Version Input [] | List of versions of a procedure plan definition. | Required | 62.0 |
| processType | String | Specifies the business processes that need a procedure plan for each sObject and definition. Valid values are: - Billing - DRO - DeepClone - ProductDiscovery - Revenue Cloud These values can be used based on the available license. If unspecified, the value is set to Default . | Required | 63.0 |
| recordId | String | ID of the procedure plan definition record. | Required if you’re invoking the Procedure Plan Definition By ID API (PATCH) . | 62.0 |
| subType | String | Specifies the vertical or cloud-specific subclassification for the procedure plan definition. | Optional | 68.0 |

**Response body for POST**

Procedure Plan Generic

### Procedure Plan Definition By ID (GET, PATCH, DELETE)

Get, update, or delete a procedure plan definition record by using the record ID.

**Resource**

`/connect/procedure-plan-definitions/procedurePlanDefinitionId`
The procedurePlanDefinitionId property value is the ID or name of the procedure plan definition record to perform the request for.

**Resource example**

`https://yourInstance.salesforce.com/services/data/v68.0/connect/procedure-plan-definitions/1FNxx0000004EsOGAU`

**Available version**

62.0

**HTTP methods**

DELETE, GET, PATCH You can delete a procedure plan definition only if it doesn't include any active procedure plan version.

**Response body for GET**

Procedure Plan Definition

**Request body for PATCH**

**JSON example**

This example shows a sample request to update a procedure plan definition by using the Procedure Plan Definition By ID (PATCH) API.
> **Note:** The properties that aren't specified in the input are deleted when updating the record.

```json
{
  "description": "Default definition patch update",
  "developerName": "Quote_Definition",
  "name": "Quote_Definition",
  "primaryObject": "Quote",
  "recordId": "1FNxx0000004EsOGAU"
}
```

**Properties**

| Name | Type | Description | Required/Optional | Available Version |
| --- | --- | --- | --- | --- |
| description | String | Description of the procedure plan definition. | Optional | 62.0 |
| developerName | String | Developer name of the procedure plan definition. | Required if you’re invoking the Procedure Plan | 62.0 |

| Name | Type | Description | Required/Optional | Available Version |
| --- | --- | --- | --- | --- |
|  |  |  | Optional Definitions API (POST) . | Version |
| name | String | Name of the procedure plan definition. | Optional | 62.0 |
| primaryObject | String | Source object that’s used to create a procedure with rule-based criteria. This property value must be a valid object name and must be unique in the ProcedurePlanDefinition object. | Required if you’re invoking the Procedure Plan Definitions API (POST) and if you’re creating a procedure with rule-based criteria. | 62.0 |
| procedurePlanDefinitionVersions | Procedure Plan Definition Version Input [] | List of versions of a procedure plan definition. | Required | 62.0 |
| processType | String | Specifies the business processes that need a procedure plan for each sObject and definition. Valid values are: - Billing - DRO - DeepClone - ProductDiscovery - Revenue Cloud These values can be used based on the available license. If unspecified, the value is set to Default . | Required | 63.0 |
| recordId | String | ID of the procedure plan definition record. | Required if you’re invoking the Procedure Plan Definition By ID API (PATCH) . | 62.0 |
| subType | String | Specifies the vertical or cloud-specific subclassification for the procedure plan definition. | Optional | 68.0 |

**Response body for PATCH**

Procedure Plan Definition

### Procedure Plan Evaluation By Object (POST)

Evaluate a procedure plan definition based on a primary object to check for prerequisites such as usage type and context mapping details.

**Resource**

`/connect/procedure-plan-definitions/evaluate`

**Resource example**

`https://yourInstance.salesforce.com/services/data/v68.0/connect/`
procedure-plan-definitions/evaluate

**Available version**

62.0

**HTTP methods**

POST

**Request body for POST**

**JSON example**

This example shows a sample request to evaluate a procedure plan definition by using a primary object.

```json
{
  "idList": [
    "a01DU000000BylcYAC"
  ],
  "evaluationDate": "2024-07-08T10:15:30.000Z",
  "processType": "Default",
  "sectionType": [
    "PricingProcedure"
  ],
  "subSectionType": [
    "Revenue"
  ]
}
```

**Properties**

| Name | Type | Description | Required/Optional | Available Version |
| --- | --- | --- | --- | --- |
| evaluationDate | String | Date when the evaluation is applicable. This property value must be within the date range when the procedure plan definition is effective. | Required | 62.0 |
| idList | String[] | List of record IDs of the procedure plan definitions to be evaluated. | Required only if you’re invoking the Procedure Plan Evaluation By Object (POST) API . | 62.0 |
| processType | String | Specifies the business processes that need a procedure plan for each sObject and definition. Valid values based on the available are: - Billing - DRO | Optional | 63.0 |

| Name | Type | Description | Required/Optional | Available Version |
| --- | --- | --- | --- | --- |
| sectionType | String[] | Name of section to be evaluated. Valid values are: - PricingProcedure - ProductDiscoveryProcedure - ProductQualificationProcedure - PricingDiscoveryProcedure - DiscountSpreadServiceProcedure - RatingProcedure - Custom - RatingDiscoveryProcedure | Optional | 62.0 |
| subSectionType | String[] | Name of subsection to be evaluated. | Optional | 62.0 |
| subTypeThe combination of theversion. | String sectionType and | Specifies the vertical or cloud-specific subclassification for the procedure plan definition. subSectionType property values must be unique for every procedure plan | Optional | 68.0 |

**Response body for POST**

Procedure Plan Evaluation Response

### Procedure Plan Evaluation By Definition Name (POST)

Evaluate a procedure plan definition based on the name of a definition to check for prerequisites such as usage type and context mapping details.

**Resource**

`/connect/procedure-plan-definitions/evaluate/procedurePlanDefinitionName`

**Resource example**

`https://yourInstance.salesforce.com/services/data`
/v68.0/connect/procedure-plan-definitions/evaluate/Sample_Definition

**Available version**

62.0

**HTTP methods**

POST

**Request body for POST**

**JSON example**

This example shows a sample request to evaluate a procedure plan definition by using a definition name.

```json
{
  "evaluationDate": "2024-07-08T10:15:30.000Z",
  "processType": "Default",
  "sectionType": [
    "PricingProcedure"
  ],
  "subSectionType": [
    "Revenue"
  ]
}
```

**Properties**

| Name | Type | Description | Required/Optional | Available Version |
| --- | --- | --- | --- | --- |
| evaluationDate | String | Date when the evaluation is applicable. This property value must be within the date range when the procedure plan definition is effective. | Required | 62.0 |
| idList | String[] | List of record IDs of the procedure plan definitions to be evaluated. | Required only if you’re invoking the Procedure Plan Evaluation By Object (POST) API . | 62.0 |
| processType | String | Specifies the business processes that need a procedure plan for each sObject and definition. Valid values based on the available are: - Billing - DRO - DeepClone - ProductDiscovery - Revenue Cloud These values can be used based on the available license. If unspecified, the value is set to Default . | Optional | 63.0 |

| Name | Type | Description | Required/Optional | Available Version |
| --- | --- | --- | --- | --- |
| sectionType | String[] | Name of section to be evaluated. Valid values are: - PricingProcedure - ProductDiscoveryProcedure - ProductQualificationProcedure - PricingDiscoveryProcedure - DiscountSpreadServiceProcedure - RatingProcedure - Custom - RatingDiscoveryProcedure | Optional | 62.0 |
| subSectionType | String[] | Name of subsection to be evaluated. | Optional | 62.0 |
| subTypeThe combination of theversion. | String sectionType and | Specifies the vertical or cloud-specific subclassification for the procedure plan definition. subSectionType property values must be unique for every procedure plan | Optional | 68.0 |

**Response body for POST**

Procedure Plan Evaluation Response

### Procedure Plan Version (POST)

Create records of a procedure plan version with details.

**Resource**

`/connect/procedure-plan-definitions/procedurePlanDefinitionId/version`

**Resource example**

`https://yourInstance.salesforce.com/services/data/v68.0/connect/`
procedure-plan-definitions/1FNxx0000004EsOGAU/version

**Available version**

62.0

**HTTP methods**

POST

**Request body for POST**

**JSON example**

```json
{
  "active": false,
  "developerName": "sample_version_input",
  "effectiveFrom": "2024-07-09T00:00:00.000Z",
  "contextDefinition": "SalesTransactionContext__stdctx",
  "procedurePlanSections": [
    {
      "isInherited": false,
      "procedurePlanOptions": [
        {
          "saveContextMapping": "AssetToSalesTransactionMapping",
          "expressionSetDefinition": "9QAZ60000004ECOOA2",
          "expressionSetLabel": "Revenue_Default_Pricing_Procedure",
          "expressionSetApiName": "Revenue Default Pricing Procedure",
          "logic": "1 AND 2 AND 3",
          "priority": 1,
          "procedurePlanCriterion": [
            {
              "conditionSequence": 1,
              "fieldObject": "BillingCountry",
              "fieldPath": "BillingCountry",
              "literalValue": "test",
              "operator": "Equals",
              "dataType": "Text"
            },
            {
              "conditionSequence": 2,
              "fieldObject": "BillingPostalCode",
              "fieldPath": "BillingPostalCode",
              "literalValue": "sample",
              "operator": "Equals",
              "dataType": "Text"
            },
            {
              "conditionSequence": 3,
              "fieldObject": "LastActivityDate",
              "fieldPath": "LastActivityDate",
              "literalValue": "2024-07-14",
              "operator": "LessThan",
              "dataType": "Date"
            }
          ]
        }
      ],
      "resolutionType": "RuleBased",
      "sectionType": "PricingProcedure",
      "sequence": 1,
      "subSectionType": "PricingProcedure",
      "recordId": "1FRZ60000008OIAOA2"
    }
  ],
  "rank": 1,
  "readContextMapping": "ProductDiscoveryContextMapping",
  "saveContextMapping": "OrderEntitiesMapping"
}
```

> **Note:** The properties that aren't specified in the input are deleted when updating the record.

**Properties**

| Name | Type | Description | Required/Optional | Available Version |
| --- | --- | --- | --- | --- |
| active | Boolean | Indicates whether this procedure plan definition version is active (true) or not (false). You can’t edit or delete a procedure plan version that’s in the active state. | Required | 62.0 |
| contextDefinition | String | Context definition that’s associated with the procedure plan definition version record. | Required | 62.0 |
| developerName | String | Unique developer name of the procedure plan definition version. | Required | 62.0 |
| effectiveFrom | String | Date and time from when the procedure plan definition version comes into effect. | Required | 62.0 |
| effectiveTo | String | Date and time from when the procedure plan definition version is no longer in effect. | Required | 62.0 |
| inheritedFrom | String | Template this procedure plan definition version is created from. | This property is read-only. | 62.0 |
| procedurePlanSections | Procedure Plan Section Input [] | Procedure setup sections for a procedure plan definition. Each section enables the setup of a procedure type by using a rule-based criteria. Keep these considerations in mind when you modify this property. - You can edit or delete a procedure plan section if it isn’t associated with an active procedure plan version. - You can create a procedure plan section with rule-based resolution type if the primary object isn’t empty in the definition. | Required | 62.0 |
| rank | Integer | Current rank of the procedure plan definition version that’s used to decide | Required | 62.0 |

| Name | Type | Description | Required/Optional | Available Version |
| --- | --- | --- | --- | --- |
| readContextMapping | String | Mapping that’s used to read data from the mapped object and populate the context definition. This property value must be associated with a context definition. | Optional | 62.0 |
| recordId | String | ID of the procedure plan definition version record. | Required | 62.0 |
| saveContextMapping | String | Mapping that’s used to save data from the context definition and populate the mapped object. This property value must be associated with a context definition. | Optional | 62.0 |
| status | String | Status of the procedure plan definition version record. | Optional | 62.0 |

**Response body for POST**

Procedure Plan Generic

### Procedure Plan Version Details (GET, PATCH, DELETE)

Get, update, or delete a procedure plan definition version record by using the record ID.

**Resource**

`/connect/procedure-plan-definitions/versions/procedurePlanVersionId`
The procedurePlanVersionId property value is the ID or name of the procedure plan version record to perform the request for.

**Resource example**

`https://yourInstance.salesforce.com/services/data/v68.0/connect/`
procedure-plan-definitions/versions/1Cvxx0000004E1ACAU

**Available version**

62.0

**HTTP methods**

DELETE, GET, PATCH You can't delete a procedure plan version if it's the only procedure plan version in a procedure plan definition.

**Response body for GET**

Procedure Plan Definition Version

**Request body for PATCH**

**JSON example**

```json
{
  "active": false,
  "developerName": "sample_version_input",
  "effectiveFrom": "2024-07-09T00:00:00.000Z",
  "contextDefinition": "SalesTransactionContext__stdctx",
  "procedurePlanSections": [
    {
      "isInherited": false,
      "procedurePlanOptions": [
        {
          "saveContextMapping": "AssetToSalesTransactionMapping",
          "expressionSetDefinition": "9QAZ60000004ECOOA2",
          "expressionSetLabel": "Revenue_Default_Pricing_Procedure",
          "expressionSetApiName": "Revenue Default Pricing Procedure",
          "logic": "1 AND 2 AND 3",
          "priority": 1,
          "procedurePlanCriterion": [
            {
              "conditionSequence": 1,
              "fieldObject": "BillingCountry",
              "fieldPath": "BillingCountry",
              "literalValue": "test",
              "operator": "Equals",
              "dataType": "Text"
            },
            {
              "conditionSequence": 2,
              "fieldObject": "BillingPostalCode",
              "fieldPath": "BillingPostalCode",
              "literalValue": "sample",
              "operator": "Equals",
              "dataType": "Text"
            },
            {
              "conditionSequence": 3,
              "fieldObject": "LastActivityDate",
              "fieldPath": "LastActivityDate",
              "literalValue": "2024-07-14",
              "operator": "LessThan",
              "dataType": "Date"
            }
          ]
        }
      ],
      "resolutionType": "RuleBased",
      "sectionType": "PricingProcedure",
      "sequence": 1,
      "subSectionType": "PricingProcedure",
      "recordId": "1FRZ60000008OIAOA2"
    }
  ],
  "rank": 1,
  "readContextMapping": "ProductDiscoveryContextMapping",
  "saveContextMapping": "OrderEntitiesMapping"
}
```

> **Note:** The properties that aren't specified in the input are deleted when updating the record.

**Properties**

| Name | Type | Description | Required/Optional | Available Version |
| --- | --- | --- | --- | --- |
| active | Boolean | Indicates whether this procedure plan definition version is active (true) or not (false). You can’t edit or delete a procedure plan version that’s in the active state. | Required | 62.0 |
| contextDefinition | String | Context definition that’s associated with the procedure plan definition version record. | Required | 62.0 |
| developerName | String | Unique developer name of the procedure plan definition version. | Required | 62.0 |
| effectiveFrom | String | Date and time from when the procedure plan definition version comes into effect. | Required | 62.0 |
| effectiveTo | String | Date and time from when the procedure plan definition version is no longer in effect. | Required | 62.0 |
| inheritedFrom | String | Template this procedure plan definition version is created from. | This property is read-only. | 62.0 |
| procedurePlanSections | Procedure Plan Section Input [] | Procedure setup sections for a procedure plan definition. Each section enables the setup of a procedure type by using a rule-based criteria. Keep these considerations in mind when you modify this property. - You can edit or delete a procedure plan section if it isn’t associated with an active procedure plan version. - You can create a procedure plan section with rule-based resolution type if the primary object isn’t empty in the definition. | Required | 62.0 |
| rank | Integer | Current rank of the procedure plan definition version that’s used to decide | Required | 62.0 |

| Name | Type | Description | Required/Optional | Available Version |
| --- | --- | --- | --- | --- |
| readContextMapping | String | Mapping that’s used to read data from the mapped object and populate the context definition. This property value must be associated with a context definition. | Optional | 62.0 |
| recordId | String | ID of the procedure plan definition version record. | Required | 62.0 |
| saveContextMapping | String | Mapping that’s used to save data from the context definition and populate the mapped object. This property value must be associated with a context definition. | Optional | 62.0 |
| status | String | Status of the procedure plan definition version record. | Optional | 62.0 |

**Response body for PATCH**

Procedure Plan Generic

### Pricing Simulation Input Variables With Data (GET)

Get details of the pricing simulation input variables along with associated data.

**Resource**

`/connect/core-pricing/simulationInputVariablesWithData`

**Resource example**

`https://yourInstance.salesforce.com/services/data/v68.0/connect/core-pricing/simulationInputVariablesWithData?expressionSetVersionId=9QMxx0000004CDsGAM&entityId=0Q0xx0000004C92CAE&contextDefinitionId=SalesTransactionContext__stdctx&contextMappingId=QuoteEntitiesMapping`

**Available version**

64.0

**HTTP methods**

GET

**Request parameters for GET**

| Name | Type | Description | Required/Optional | Available Version |
| --- | --- | --- | --- | --- |
| contextDefinitionId | String | ID or developer name of the context definition. | Required | 64.0 |

| Name | Type | Description | Required/Optional | Available Version |
| --- | --- | --- | --- | --- |
| contextMappingId | String | ID or name of the context mapping that's used. | Required | 64.0 |
| entityId | String | ID of a quote or an order. | Required | 64.0 |
| expressionSetVersionId | String | ID of the expression set that starts with 9QM . | Required | 64.0 |

**Response body for GET**

Pricing Simulation Input Variables With Data

## Request Bodies

Learn more about the available Salesforce Pricing API request bodies.
Adjustment Details Input Input representation of the adjustment details.
Configuration Override Input Input representation of the details to override for a Pricing API configuration.
PBE Derived Pricing Input Input representation of the request to get the source product for the Price Book Entry (PBE) derived pricing.
Pricing Input Input representation of the details of a Pricing API request.
Pricing Recipe Clone Input Input representation to clone a pricing recipe.
Pricing Recipe Input Input representation to set up a pricing recipe page.
Pricing Recipe LookUp Table Input Input representation of the lookup tables for the setup page recipe.
Pricing Recipe Procedure Input Input representation of the procedure for the setup page recipe.
Pricing Request Input Input representation of a pricing request.
Pricing Versioned Revision Details Input Input representation of the versioned revision details.
Pricing Waterfall Input Input representation of the pricing waterfall details.
Pricing Waterfall Log Input Input representation of the request to create an explainability action log.
Procedure Plan Criterion Input Input representation of the details of a procedure plan criterion.
Procedure Plan Definition Input Input representation of the details of a procedure plan definition.
Procedure Plan Definition Version Input Input representation of the details of a procedure plan definition version.
Procedure Plan Evaluation Input Input representation of the details used to evaluate a procedure plan definition.
Procedure Plan Section Input Input representation of the details of a procedure plan section.
Procedure Plan Option Input Input representation of the details of a procedure plan option.

### Adjustment Details Input

Input representation of the adjustment details.

**JSON example**

```json
"pricingElement": {
"adjustments": [{
"AdjustmentValue": "15.00",
"AdjustmentType": "Percentage"
}],
"description": null,
"elementType": "VolumeDiscount",
"name": "Volume Discount"
}
```

**Properties**

| Name | Type | Description | Required/Optional | Available Version |
| --- | --- | --- | --- | --- |
| adjustments | Map<String, Object>[] | Details of the pricing element. | Optional | 60.0 |
| description | String | Description of the pricing element. | Optional | 60.0 |
| elementType | String | Type of the pricing element. | Optional | 60.0 |
| name | String | Name of the pricing element. | Optional | 60.0 |

### Configuration Override Input

Input representation of the details to override for a Pricing API configuration.

**JSON example**

```json
"configurationOverrides": {
"skipWaterfall": true,
"useSessionScopedContext": true,
"persistContext": true,
"referenceKey": "referenceKey-12345",
"displayContext" : false,
"taggedData": false,
"isHighVolumeLineItems": false
}
```

**Properties**

| Name | Type | Description | Required/Optional | Available Version |
| --- | --- | --- | --- | --- |
| discoveryProcedure | String | Name of the discovery procedure to use to fetch the details of assets. | Optional | 61.0 |
| displayContext | Boolean | Indicates whether the context structure for pricing must be displayed (true) or not (false). | Optional | 61.0 |
| isHighVolumeLineItems | Boolean | Indicates whether the pricing API returns pricing details for more than 100 line items (true) or not (false). | Optional | 63.0 |
| persistContext | Boolean | Indicates whether the context must be persisted as per the mapping (true) or not (false). If set to true , the user must have edit access to all sObject fields used in the context mapping. | Optional | 60.0 |
| referenceKey | String | Reference ID that a consuming workstream provides in the API to search for specific logs in the Pricing Operations Console. | Optional | 63.0 |
| skipDiscovery | Boolean | Indicates whether the discovery procedure must be skipped (true) or not (false). | Optional | 61.0 |
| skipWaterfall | Boolean | Indicates whether the price waterfall must be skipped in the output response (true) or not (false). | Optional | 60.0 |
| taggedData | Boolean | Indicates whether the JSON data string can specify tags in the input instead of attributes (true) or not (false). | Optional | 60.0 |
| useSessionScopedContext | Boolean | Indicates whether a session scoped context must be created (true) or request scoped context (false). The default is false . | Optional | 60.0 |

### PBE Derived Pricing Input

Input representation of the request to get the source product for the Price Book Entry (PBE) derived pricing.

**JSON example**

```json
{
  "productId": "01txx0000006i2SAAQ",
  "pricebookEntryId": "01uxx0000008yYcAAI",
  "effectiveFrom": "2020-01-01T22:53:20.000Z",
  "effectiveTo": "2021-01-01T22:53:20.000Z"
}
```

**Properties**

| Name | Type | Description | Required/Optional | Available Version |
| --- | --- | --- | --- | --- |
| effectiveFrom | String | Date from when the price book entry is effective. | Required | 61.0 |
| effectiveTo | String | Date until when the price book entry is effective. | Required | 61.0 |
| pricebookEntryId | String | ID of the price book entry. | Required | 61.0 |
| productId | String | ID of the price book. | Required | 61.0 |

### Pricing Input

Input representation of the details of a Pricing API request.

**JSON example**

```json
{
  "contextDefinitionId": "11Oxx0000006PdxEAE",
  "contextMappingId": "11jxx0000004LDDAA2",
  "jsonDataString": {
    "Cart": [
      {
        "id": "cart_1001",
        "cart_id": "cart_1001",
        "PriceBookId": "PriceBookId_1001",
        "businessObjectType": "Cart",
        "CartItem": [
          {
            "id": "lineItem_1001",
            "line_item_id": "lineItem_1001",
            "Quantity": 7,
            "PriceType": "OneTime",
            "Frequency": "",
            "UOM": "",
            "businessObjectType": "CartItem",
            "product_id": "01txx0000006i44AAA",
            "UnitPrice": 6.8,
            "NetUnitPrice": 0,
            "Attribute": [
              {
                "name": "Color",
                "code": "RED",
                "isPriceImpacting": true,
                "businessObjectType": "Attribute",
                "id": "Attribute_1001",
                "attribute_id": "Attribute_1001"
              },
              {
                "name": "Size",
                "code": "10INCH",
                "isPriceImpacting": true,
                "businessObjectType": "Attribute",
                "id": "Attribute_1002",
                "attribute_id": "Attribute_1002"
              }
            ]
          },
          {
            "id": "lineItem_1002",
            "line_item_id": "lineItem_1002",
            "quantity": 3,
            "PriceType": "OneTime",
            "Frequency": "",
            "UOM": "",
            "businessObjectType": "CartItem",
            "product_id": "01txx0000006i2SAAQ",
            "unitprice": 6,
            "NetUnitPrice": 0,
            "Attribute": [
              {
                "name": "Color",
                "code": "BLUE",
                "isPriceImpacting": true,
                "businessObjectType": "Attribute",
                "id": "Attribute_1003",
                "attribute_id": "Attribute_1003"
              },
              {
                "name": "Size",
                "code": "6INCH",
                "isPriceImpacting": true,
                "businessObjectType": "Attribute",
                "id": "Attribute_1004",
                "attribute_id": "Attribute_1004"
              }
            ]
          }
        ]
      }
    ]
  },
  "pricingProcedureId": "9QMxx0000004CKKGA2",
  "configurationOverrides": {
    "skipWaterfall": true,
    "useSessionScopedContext": true,
    "persistContext": true,
    "referenceKey": "referenceKey-12345",
    "displayContext": false,
    "taggedData": false,
    "isHighVolumeLineItems": false
  }
}
```

**Properties**

| Name | Type | Description | Required/Optional | Available Version |
| --- | --- | --- | --- | --- |
| configurationOverrides | Configuration Override Input | Parameters to override the pricing configuration. | Optional | 60.0 |
| contextDefinitionId | String | ID of the context definition that defines the structure of the input data. | Required | 60.0 |
| contextMappingId | String | ID of the context mapping that maps the input data to the context instance. | Required | 60.0 |
| jsonDataString | String | Data to hydrate the context, which must be in JSON format and passed as String. Pass the JSON data as String by using the stringify() method to convert the object to string. The keys in the jsonDataString property must be in accordance to the contextMappingId property sent in the request. Make sure that the businessObjectType value within this property node is set to the sObject used in the context mappings. | Required | 60.0 |
| pricingProcedureId | String | ID or API name of the pricing procedure used for calculating the prices. A pricing procedure is represented as an Expression Set Definition in the system. | Optional | 60.0 |

### Pricing Recipe Clone Input

Input representation to clone a pricing recipe.

**JSON example**

```json
{
  "recordId": "0ClxX0000004CxWACU",
  "newPricingRecipeApiName": "Cloned_Recipe",
  "newPricingRecipeName": "Cloned Recipe",
  "pricingUsageSubType": "Loyalty"
}
```

**Properties**

| Name | Type | Description | Required/Optional | Available Version |
| --- | --- | --- | --- | --- |
| newPricingRecipeApiName | String | API name of the cloned pricing recipe. | Required | 68.0 |
| newPricingRecipeName | String | Name for the cloned pricing recipe. | Required | 68.0 |
| pricingUsageSubType | String | Pricing usage subtype of the cloned pricing recipe. If unspecified, the value from the source pricing recipe is used. | Optional | 68.0 |
| recordId | String | ID of the source pricing recipe to clone. | Required | 68.0 |

### Pricing Recipe Input

Input representation to set up a pricing recipe page.

**JSON example**

```json
{
"recipeId" : "12Gxx0000005J9MEAU",
"pricingRecipeLookUpTableInputRepresentations": [
{
lookupId: "12Gxx0000005J9MEAU",
pricingComponentType: "CustomDiscount"
},
{
lookupId: "12Gxx0000005J9MEAU",
pricingComponentType: "CustomDiscount"
}
],
"pricingRecipeProcedureInputRepresentation" : {
"procedureId" : "9QLxx0000004C92GAE"
}
}
```

**Properties**

| Name | Type | Description | Required/Optional | Available Version |
| --- | --- | --- | --- | --- |
| pricingRecipeLookUpTableInputRepresentations | Pricing Recipe LookUp Table Input [] | Input representation of the recipe mapping. | Required | 60.0 |
| pricingRecipeProcedureInputRepresentation | Pricing Recipe Procedure Input | Input representation of the procedure that’s used in the pricing recipe. | Required | 60.0 |
| recipeId | String | ID of the pricing recipe. | Required | 60.0 |

### Pricing Recipe LookUp Table Input

Input representation of the lookup tables for the setup page recipe.

**JSON example**

```json
"pricingRecipeLookUpTableInputRepresentations": [
{
lookupId: "12Gxx0000005J9MEAU",
pricingComponentType: "CustomDiscount"
},
{
lookupId: "12Gxx0000005J9MEAU",
pricingComponentType: "CustomDiscount"
}
]
```

**Properties**

| Name | Type | Description | Required/Optional | Available Version |
| --- | --- | --- | --- | --- |
| lookupTableId | String | ID of the decision table. | Optional | 60.0 |
| pricingComponentType | String | Pricing component types such as volume discount, custom discount, attribute-based discount, and bundle-based discount. | Optional | 60.0 |

### Pricing Recipe Procedure Input

Input representation of the procedure for the setup page recipe.

**JSON example**

```json
"pricingRecipeProcedureInputRepresentation" : {
"procedureId" : "9QLxx0000004C92GAE"
}
```

**Properties**

| Name | Type | Description | Required/Optional | Available Version |
| --- | --- | --- | --- | --- |
| procedureId | String | ID of the expression set. | Required | 60.0 |

### Pricing Request Input

Input representation of a pricing request.

**JSON example**

```json
{
"configurationOverrides": {
"skipWaterfall": true,
"useSessionScopedContext": true,
"persistContext": true,
"taggedData": false
}
"procedureName": "ES1"
}
```

**Properties**

| Name | Type | Description | Required/Optional | Available Version |
| --- | --- | --- | --- | --- |
| configurationOverrides | Configuration Override Input | Parameters to override pricing configuration. | Optional | 60.0 |
| procedureName | String | Name of the pricing procedure. | Optional | 60.0 |

### Pricing Versioned Revision Details Input

Input representation of the versioned revision details.

**JSON example**

This example shows the input for versioned revision details for attribute-based adjustment.

```json
{
"entityName":"AttributeBasedAdjustment",
"id":"entityId",
"priceAdjustmentId":"priceAdjustmentScheduleId",
"productId":"ProductId",
"productSellingModelId":"PsmId",
"adjustmentType":"AdjustmentType",
"adjustmentValue":"AdjustmentValue(Numeric)"",
"effectiveFrom":"EffectiveFrom date",
"effectiveTo":"EffectiveTo Date",
"additionalFieldsToValueMap":{
"attributeBasedAdjRuleId":"AttributeBasedAdjRuleId"
}
}
```

This example shows the input for versioned revision details for bundle-based adjustment.

```json
{
  "entityName": "BundleBasedAdjustment",
  "id": "entityId",
  "priceAdjustmentScheduleId": "priceAdjustmentScheduleId",
  "productId": "ProductId",
  "productSellingModelId": "PsmId",
  "adjustmentType": "AdjustmentType",
  "adjustmentValue": "AdjustmentValue(Numeric)",
  "effectiveFrom": "EffectiveFrom date",
  "effectiveTo": "EffectiveTo Date",
  "additionalFieldsToValueMap": {
    "rootBundleId": "RootBundleId",
    "parentProductId": "ParentProductId"
  }
}
```

**Properties**

| Name | Type | Description | Required/Optional | Available Version |
| --- | --- | --- | --- | --- |
| additionalFieldsToValueMap | Map<String, String> | Map containing the additional fields specific to the entity. | Optional | 60.0 |
| adjustmentType | String | Adjustment type such as, percentage, amount, or override. | Required | 60.0 |
| adjustmentValue | String | Value for the adjustment. | Required | 60.0 |
| effectiveFrom | String | Date from when the adjustment is effective. | Required | 60.0 |
| effectiveTo | String | Date until when the adjustment is effective. | Optional | 60.0 |

| Name | Type | Description | Required/Optional | Available Version |
| --- | --- | --- | --- | --- |
| entityName | String | Name of the entity such as AttributeBasedAdjustment entity or BundleBasedAdjustment entity. | Required | 60.0 |
| id | String | ID of the record. | Required | 60.0 |
| priceAdjustmentScheduleId | String | ID of the price adjustment schedule record. | Required | 60.0 |
| productId | String | Product ID of the record. | Required | 60.0 |
| productSellingModelId | String | Product selling model ID associated to the record. | Optional | 60.0 |

### Pricing Waterfall Input

Input representation of the pricing waterfall details.

**JSON example**

```json
"waterfall": [{
"fieldToTagNameMapping": {
"Product2Id": "ItemProduct",
"Subtotal": "Subtotal",
"Pricebook2Id": "Pricebook",
"Quantity": "ItemQuantity",
"LineItemId": "SalesTransactionSource",
"ListPrice": "ItemListPrice"
},
"inputParameters": {
"Product2Id": "01txx0000006i44AAA",
"Pricebook2Id": "01sxx0000005q9xAAA",
"Quantity": 5,
"LineItemId": "item1"
},
"outputParameters": {
"Subtotal": 50,
"ListPrice": 10
},
"pricingElement": {
"adjustments": [{
"AdjustmentValue": "95.00",
"AdjustmentType": "Amount"
}],
"description": null,
"elementType": "ListPrice",
"name": "List Price"
},
"sequence": 1
},
{
"fieldToTagNameMapping": {
"PriceAdjustmentScheduleId": "ItemDescription",
"NetUnitPrice": "ItemNetUnitPrice",
"Product2Id": "ItemProduct",
"LowerBound": "ItemQuantity",
"UpperBound": "ItemQuantity",
"Subtotal": "Subtotal",
"Quantity": "ItemQuantity",
"LineItemId": "SalesTransactionSource",
"InputUnitPrice": "ItemListPrice"
},
"inputParameters": {
"PriceAdjustmentScheduleId": "84Xxx0000004CGSEA2",
"Product2Id": "01txx0000006i44AAA",
"LowerBound": 5,
"UpperBound": 5,
"Quantity": 5,
"LineItemId": "item1",
"InputUnitPrice": 10
},
"outputParameters": {
"NetUnitPrice": 8.5,
"Subtotal": 42.5
},
"pricingElement": {
"adjustments": [{
"AdjustmentValue": "15.00",
"AdjustmentType": "Percentage"
}],
"description": null,
"elementType": "VolumeDiscount",
"name": "Volume Discount"
},
"sequence": 2
}
]
```

**Properties**

| Name | Type | Description | Required/Optional | Available Version |
| --- | --- | --- | --- | --- |
| fieldToTagNameMapping | Map<String, String> | Mappings of field to tag names. | Optional | 60.0 |
| inputParameters | Map<String, Object> | Input parameters of the pricing element. | Optional | 60.0 |
| outputParameters | Map<String, Object> | Output parameters of the pricing element. | Optional | 60.0 |

| Name | Type | Description | Required/Optional | Available Version |
| --- | --- | --- | --- | --- |
| pricingElement | Adjustment Details Input | Details of the pricing element. | Optional | 60.0 |
| sequence | Integer | Sequence of the pricing element execution. | Optional | 60.0 |

### Pricing Waterfall Log Input

Input representation of the request to create an explainability action log.

**JSON example**

```json
{
  "currencyCode": "USD",
  "executionEndTimestamp": "2023-07-31T20:11:29.625Z",
  "executionId": "executionId1",
  "executionStartTimestamp": null,
  "lineItemId": "item1",
  "output": {
    "Subtotal": 38.25,
    "ListPrice": 10,
    "NetUnitPrice": 7.65
  },
  "waterfall": [
    {
      "fieldToTagNameMapping": {
        "Product2Id": "ItemProduct",
        "Subtotal": "Subtotal",
        "Pricebook2Id": "Pricebook",
        "Quantity": "ItemQuantity",
        "LineItemId": "SalesTransactionSource",
        "ListPrice": "ItemListPrice"
      },
      "inputParameters": {
        "Product2Id": "01txx0000006i44AAA",
        "Pricebook2Id": "01sxx0000005q9xAAA",
        "Quantity": 5,
        "LineItemId": "item1"
      },
      "outputParameters": {
        "Subtotal": 50,
        "ListPrice": 10
      },
      "pricingElement": {
        "adjustments": [
          {
            "AdjustmentValue": "95.00",
            "AdjustmentType": "Amount"
          }
        ],
        "description": null,
        "elementType": "ListPrice",
        "name": "List Price"
      },
      "sequence": 1
    },
    {
      "fieldToTagNameMapping": {
        "PriceAdjustmentScheduleId": "ItemDescription",
        "NetUnitPrice": "ItemNetUnitPrice",
        "Product2Id": "ItemProduct",
        "LowerBound": "ItemQuantity",
        "UpperBound": "ItemQuantity",
        "Subtotal": "Subtotal",
        "Quantity": "ItemQuantity",
        "LineItemId": "SalesTransactionSource",
        "InputUnitPrice": "ItemListPrice"
      },
      "inputParameters": {
        "PriceAdjustmentScheduleId": "84Xxx0000004CGSEA2",
        "Product2Id": "01txx0000006i44AAA",
        "LowerBound": 5,
        "UpperBound": 5,
        "Quantity": 5,
        "LineItemId": "item1",
        "InputUnitPrice": 10
      },
      "outputParameters": {
        "NetUnitPrice": 8.5,
        "Subtotal": 42.5
      },
      "pricingElement": {
        "adjustments": [
          {
            "AdjustmentValue": "15.00",
            "AdjustmentType": "Percentage"
          }
        ],
        "description": null,
        "elementType": "VolumeDiscount",
        "name": "Volume Discount"
      },
      "sequence": 2
    }
  ]
}
```

**Properties**

| Name | Type | Description | Required/Optional | Available Version |
| --- | --- | --- | --- | --- |
| contextDefinitionVersionId | String | Context definition version ID of the pricing procedure. | Optional | 60.0 |
| contextMappingId | String | Context mapping ID of the pricing procedure. | Optional | 60.0 |

| Name | Type | Description | Required/Optional | Available Version |
| --- | --- | --- | --- | --- |
| currencyCode | String | Currency code such as, USD or INR. | Optional | 60.0 |
| executionEndTimestamp | String | End timestamp of procedure execution. | Optional | 60.0 |
| executionId | String | Execution ID for a particular execution of a pricing procedure. | Required | 60.0 |
| executionStartTimestamp | String | Start timestamp of procedure execution. | Optional | 60.0 |
| lineItemId | String | Line item ID for which the price is being calculated. | Required | 60.0 |
| output | Map<String, Object> | Output of the pricing procedure. | Optional | 60.0 |
| waterfall | Pricing Waterfall Input [] | Details of the pricing waterfall. | Required | 60.0 |

### Procedure Plan Criterion Input

Input representation of the details of a procedure plan criterion.

**JSON example**

```json
"procedurePlanCriterion": [
{
"conditionSequence": 1,
"fieldObject": "BillingCountry",
"fieldPath": "BillingCountry",
"literalValue": "test",
"operator": "Equals",
"dataType": "Text"
},
{
"conditionSequence": 2,
"fieldObject": "BillingPostalCode",
"fieldPath": "BillingPostalCode",
"literalValue": "sample",
"operator": "Equals",
"dataType": "Text"
},
{
"conditionSequence": 3,
"fieldObject": "LastActivityDate",
"fieldPath": "LastActivityDate",
"literalValue": "2024-07-14",
"operator": "LessThan",
"dataType": "Date"
}
]
```

**Properties**

| Name | Type | Description | Required/Optional | Available Version |
| --- | --- | --- | --- | --- |
| conditionSequence | Integer | Sequence to be followed to process the conditions defined in the procedure plan option. This property value must be unique within a procedure plan option. | Required | 62.0 |
| dataType | String | Data type of the field from the selected object. | Required | 62.0 |
| fieldObject | String | Value of the object field that’s used to resolve the procedure plan option. This property value must belong to the primary object that’s associated with the procedure plan definition, at a maximum two levels up in the hierarchy. | Required | 62.0 |
| fieldPath | String | Path of the field that’s used in a procedure in relation to the object that the field belongs to. The field path must end with the object field that’s associated with the procedure plan criterion. | Required | 62.0 |
| literalValue | String | User-defined value that’s compared to the value of the sObject field value. | Optional | 62.0 |
| operator | String | Operator that’s used by the procedure plan criterion. | Required | 62.0 |
| recordId | String | ID of the procedure plan criterion record. | Required | 62.0 |

### Procedure Plan Definition Input

Input representation of the details of a procedure plan definition.

**JSON example**

This example shows a sample request to create a procedure plan definition record by using the Procedure Plan Definitions (POST) API.

```json
{
  "description": "Definition for Quote",
  "developerName": "Quote_Definition_Sample",
  "name": "Quote_Definition_Sample",
  "processType": "Default",
  "primaryObject": "BusinessHours",
  "procedurePlanDefinitionVersions": [
    {
      "active": false,
      "contextDefinition": "SalesTransactionContext__stdctx",
      "readContextMapping": "QuoteEntitiesMapping",
      "saveContextMapping": "QuoteEntitiesMapping",
      "effectiveFrom": "2024-07-15T10:15:30.000Z",
      "developerName": "Quote_Definition_V1",
      "rank": 1
    }
  ]
}
```

This example shows a sample request to update a procedure plan definition by using the Procedure Plan Definition By ID (PATCH) API.
> **Note:** The properties that aren't specified in the input are deleted when updating the record.

```json
{
  "description": "Default definition patch update",
  "developerName": "Quote_Definition",
  "name": "Quote_Definition",
  "primaryObject": "Quote",
  "recordId": "1FNxx0000004EsOGAU"
}
```

**Properties**

| Name | Type | Description | Required/Optional | Available Version |
| --- | --- | --- | --- | --- |
| description | String | Description of the procedure plan definition. | Optional | 62.0 |
| developerName | String | Developer name of the procedure plan definition. | Required if you’re invoking the Procedure Plan Definitions API (POST) . | 62.0 |
| name | String | Name of the procedure plan definition. | Optional | 62.0 |
| primaryObject | String | Source object that’s used to create a procedure with rule-based criteria. This property value must be a valid object name and must be unique in the ProcedurePlanDefinition object. | Required if you’re invoking the Procedure Plan Definitions API (POST) and if you’re creating a procedure with rule-based criteria. | 62.0 |

| Name | Type | Description | Required/Optional | Available Version |
| --- | --- | --- | --- | --- |
| procedurePlanDefinitionVersions | Procedure Plan Definition Version Input [] | List of versions of a procedure plan definition. | Required | 62.0 |
| processType | String | Specifies the business processes that need a procedure plan for each sObject and definition. Valid values are: - Billing - DRO - DeepClone - ProductDiscovery - Revenue Cloud These values can be used based on the available license. If unspecified, the value is set to Default . | Required | 63.0 |
| recordId | String | ID of the procedure plan definition record. | Required if you’re invoking the Procedure Plan Definition By ID API (PATCH) . | 62.0 |
| subType | String | Specifies the vertical or cloud-specific subclassification for the procedure plan definition. | Optional | 68.0 |

### Procedure Plan Definition Version Input

Input representation of the details of a procedure plan definition version.

**JSON example**

```json
{
  "active": false,
  "developerName": "sample_version_input",
  "effectiveFrom": "2024-07-09T00:00:00.000Z",
  "contextDefinition": "SalesTransactionContext__stdctx",
  "procedurePlanSections": [
    {
      "isInherited": false,
      "procedurePlanOptions": [
        {
          "saveContextMapping": "AssetToSalesTransactionMapping",
          "expressionSetDefinition": "9QAZ60000004ECOOA2",
          "expressionSetLabel": "Revenue_Default_Pricing_Procedure",
          "expressionSetApiName": "Revenue Default Pricing Procedure",
          "logic": "1 AND 2 AND 3",
          "priority": 1,
          "procedurePlanCriterion": [
            {
              "conditionSequence": 1,
              "fieldObject": "BillingCountry",
              "fieldPath": "BillingCountry",
              "literalValue": "test",
              "operator": "Equals",
              "dataType": "Text"
            },
            {
              "conditionSequence": 2,
              "fieldObject": "BillingPostalCode",
              "fieldPath": "BillingPostalCode",
              "literalValue": "sample",
              "operator": "Equals",
              "dataType": "Text"
            },
            {
              "conditionSequence": 3,
              "fieldObject": "LastActivityDate",
              "fieldPath": "LastActivityDate",
              "literalValue": "2024-07-14",
              "operator": "LessThan",
              "dataType": "Date"
            }
          ]
        }
      ],
      "resolutionType": "RuleBased",
      "sectionType": "PricingProcedure",
      "sequence": 1,
      "subSectionType": "PricingProcedure",
      "recordId": "1FRZ60000008OIAOA2"
    }
  ],
  "rank": 1,
  "readContextMapping": "ProductDiscoveryContextMapping",
  "saveContextMapping": "OrderEntitiesMapping"
}
```

> **Note:** The properties that aren't specified in the input are deleted when updating the record.

**Properties**

| Name | Type | Description | Required/Optional | Available Version |
| --- | --- | --- | --- | --- |
| active | Boolean | Indicates whether this procedure plan definition version is active (true) or not (false). You can’t edit or delete a procedure plan version that’s in the active state. | Required | 62.0 |

| Name | Type | Description | Required/Optional | Available Version |
| --- | --- | --- | --- | --- |
| contextDefinition | String | Context definition that’s associated with the procedure plan definition version record. | Required | 62.0 |
| developerName | String | Unique developer name of the procedure plan definition version. | Required | 62.0 |
| effectiveFrom | String | Date and time from when the procedure plan definition version comes into effect. | Required | 62.0 |
| effectiveTo | String | Date and time from when the procedure plan definition version is no longer in effect. | Required | 62.0 |
| inheritedFrom | String | Template this procedure plan definition version is created from. | This property is read-only. | 62.0 |
| procedurePlanSections | Procedure Plan Section Input [] | Procedure setup sections for a procedure plan definition. Each section enables the setup of a procedure type by using a rule-based criteria. Keep these considerations in mind when you modify this property. - You can edit or delete a procedure plan section if it isn’t associated with an active procedure plan version. - You can create a procedure plan section with rule-based resolution type if the primary object isn’t empty in the definition. | Required | 62.0 |
| rank | Integer | Current rank of the procedure plan definition version that’s used to decide the sequence of execution of a procedure plan definition version. | Required | 62.0 |
| readContextMapping | String | Mapping that’s used to read data from the mapped object and populate the context definition. This property value must be associated with a context definition. | Optional | 62.0 |
| recordId | String | ID of the procedure plan definition version record. | Required | 62.0 |

| Name | Type | Description | Required/Optional | Available Version |
| --- | --- | --- | --- | --- |
| saveContextMapping | String | Mapping that’s used to save data from the context definition and populate the mapped object. This property value must be associated with a context definition. | Optional | 62.0 |
| status | String | Status of the procedure plan definition version record. | Optional | 62.0 |

### Procedure Plan Evaluation Input

Input representation of the details used to evaluate a procedure plan definition.

**JSON example**

This example shows a sample request to evaluate a procedure plan definition by using a primary object.

```json
{
  "idList": [
    "a01DU000000BylcYAC"
  ],
  "evaluationDate": "2024-07-08T10:15:30.000Z",
  "processType": "Default",
  "sectionType": [
    "PricingProcedure"
  ],
  "subSectionType": [
    "Revenue"
  ]
}
```

This example shows a sample request to evaluate a procedure plan definition by using a definition name.

```json
{
  "evaluationDate": "2024-07-08T10:15:30.000Z",
  "processType": "Default",
  "sectionType": [
    "PricingProcedure"
  ],
  "subSectionType": [
    "Revenue"
  ]
}
```

**Properties**

| Name | Type | Description | Required/Optional | Available Version |
| --- | --- | --- | --- | --- |
| evaluationDate | String | Date when the evaluation is applicable. This property value must be within the date range when the procedure plan definition is effective. | Required | 62.0 |
| idList | String[] | List of record IDs of the procedure plan definitions to be evaluated. | Required only if you’re invoking the Procedure Plan Evaluation By Object (POST) API . | 62.0 |

| Name | Type | Description | Required/Optional | Available Version |
| --- | --- | --- | --- | --- |
| processType | String | Specifies the business processes that need a procedure plan for each sObject and definition. Valid values based on the available are: - Billing - DRO - DeepClone - ProductDiscovery - Revenue Cloud These values can be used based on the available license. If unspecified, the value is set to Default . If a procedure plan definition exist in the org with processType value as null , modify the value to Default . | Optional | 63.0 |
| sectionType | String[] | Name of section to be evaluated. Valid values are: - PricingProcedure - ProductDiscoveryProcedure - ProductQualificationProcedure - PricingDiscoveryProcedure - DiscountSpreadServiceProcedure - RatingProcedure - Custom - RatingDiscoveryProcedure | Optional | 62.0 |
| subSectionType | String[] | Name of subsection to be evaluated. | Optional | 62.0 |
| subTypeThe combination of theversion. | String sectionType and | Specifies the vertical or cloud-specific subclassification for the procedure plan definition. subSectionType property values must be unique for every procedure plan | Optional | 68.0 |

### Procedure Plan Section Input

Input representation of the details of a procedure plan section.

**JSON example**

```json
"procedurePlanSections": [
{
"isInherited": false,
"procedurePlanOptions": [
{
"saveContextMapping": "AssetToSalesTransactionMapping",
"expressionSetDefinition": "9QAZ60000004ECOOA2",
"expressionSetLabel": "Revenute_Default_Pricing_Procedure",
"expressionSetApiName": "Revenue Default Pricing Procedure",
"logic": "1 AND 2 AND 3",
"priority": 1,
"procedurePlanCriterion": [
{
"conditionSequence": 1,
"fieldObject": "BillingCountry",
"fieldPath": "BillingCountry",
"literalValue": "test",
"operator": "Equals",
"dataType": "Text"
},
{
"conditionSequence": 2,
"fieldObject": "BillingPostalCode",
"fieldPath": "BillingPostalCode",
"literalValue": "sample",
"operator": "Equals",
"dataType": "Text"
},
{
"conditionSequence": 3,
"fieldObject": "LastActivityDate",
"fieldPath": "LastActivityDate",
"literalValue": "2024-07-14",
"operator": "LessThan",
"dataType": "Date"
}
]
}
],
"resolutionType": "RuleBased",
"sectionType": "PricingProcedure",
"sequence": 1,
"subSectionType": "PricingProcedure",
"recordId": "1FRZ60000008OIAOA2"
}
]
```

**Properties**

| Name | Type | Description | Required/Optional | Available Version |
| --- | --- | --- | --- | --- |
| isInherited | Boolean | Indicates whether the procedure plan section is inherited from a template (true) or not (false). | This property is read-only. | 62.0 |
| procedurePlanOptions | Procedure Plan Option Input [] | List of procedure plan options that defines a group of criteria. You can edit or delete a procedure plan option only if it isn’t associated with an active procedure plan version. | Required | 62.0 |
| recordId | String | ID of the procedure plan section record. | Required | 62.0 |
| resolutionType | String | Type of resolution used to filter the procedure. You can’t edit this property value if the procedure plan section includes a procedure plan option record. | Required | 62.0 |
| sectionType | String | Type of section. Valid values are: - PricingProcedure - ProductDiscoveryProcedure - ProductQualificationProcedure - PricingDiscoveryProcedure - DiscountSpreadServiceProcedure - RatingProcedure - Custom - RatingDiscoveryProcedure | Required | 62.0 |
| sequence | Integer | Sequence to be followed for the processing of the procedures. This property value must be greater than 0 and must be unique for a procedure plan section associated with a procedure plan version. | Required | 62.0 |
| subSectionType | String | Procedure subsection added to the procedure plan definition. | Required | 62.0 |

### Procedure Plan Option Input

Input representation of the details of a procedure plan option.

**JSON example**

```json
"procedurePlanOptions": [
{
"saveContextMapping": "AssetToSalesTransactionMapping",
"expressionSetDefinition": "9QAZ60000004ECOOA2",
"expressionSetLabel": "Revenute_Default_Pricing_Procedure",
"expressionSetApiName": "Revenue Default Pricing Procedure",
"logic": "1 AND 2 AND 3",
"priority": 1,
"procedurePlanCriterion": [
{
"conditionSequence": 1,
"fieldObject": "BillingCountry",
"fieldPath": "BillingCountry",
"literalValue": "test",
"operator": "Equals",
"dataType": "Text"
},
{
"conditionSequence": 2,
"fieldObject": "BillingPostalCode",
"fieldPath": "BillingPostalCode",
"literalValue": "sample",
"operator": "Equals",
"dataType": "Text"
},
{
"conditionSequence": 3,
"fieldObject": "LastActivityDate",
"fieldPath": "LastActivityDate",
"literalValue": "2024-07-14",
"operator": "LessThan",
"dataType": "Date"
}
]
}
]
```

**Properties**

| Name | Type | Description | Required/Optional | Available Version |
| --- | --- | --- | --- | --- |
| expressionSetApiName | String | API name of the expression set. | Optional | 62.0 |
| expressionSetDefinition | String | Expression set definition that’s associated with this procedure plan option record. | Required | 62.0 |
| expressionSetLabel | String | Label of the expression set that’s associated with this procedure plan option record. | Optional | 62.0 |

| Name | Type | Description | Required/Optional | Available Version |
| --- | --- | --- | --- | --- |
| logic | String | Computation logic for the conditions applied to a procedure plan option. This property value must be blank if the resolution type is default. | Optional | 62.0 |
| priority | Integer | Priority for the specified criteria. This property value must be greater than 0 and must be unique within a procedure plan section. | Required | 62.0 |
| procedurePlanCriterion | Procedure Plan Criterion Input [] | Details of the rule-based criteria for the procedure. You can edit or delete a procedure plan criterion only if it isn’t associated with an active procedure plan version. | Optional | 62.0 |
| readContextMapping | String | Mapping that’s used to read from the mapped object and populate the context definition. This property value must be associated with a context definition. | Optional | 62.0 |
| recordId | String | ID of the procedure plan option record. | Required | 62.0 |
| saveContextMapping | String | Mapping that’s used to save data from the context definition and populate the mapped object. This property value must be associated with a context definition. | Optional | 62.0 |

## Response Bodies

Learn more about the available Salesforce Pricing API response bodies.
Adjustment Details Output representation of a pricing adjustment request.
API Execution Log Response Output representation of the execution log of a pricing waterfall request.
Line Item Waterfall Response Output representation of the line item waterfall response.
PBE Derived Pricing Output representation of the response that includes the source product for the Price Book Entry (PBE) derived pricing.
Pricing Error Response Output representation of the pricing error response.
Pricing Execution Waterfall Response Output representation of the execution process that's associated with a pricing waterfall.
Pricing Generic Response Output representation of a pricing data sync request.
Pricing Output Output representation of a Salesforce pricing request.
Pricing Recipe LookUp Table Response Output representation of a pricing recipe lookup table.
Pricing Recipe Output representation of the pricing recipe information table.
Pricing Recipe Post Output representation of the pricing recipe after the API request.
Pricing Recipe Response Output representation of the pricing recipe.
Pricing Recipe Clone Output representation of the payload for the pricing recipe clone operation.
Pricing Recipe Clone Error Output representation of the error response for the Pricing Recipe Clone API.
Pricing Recipe Valid Elements Output representation containing the list of valid pricing element type API names for a given Pricing Usage Sub Type.
Pricing Response Output representation of the pricing request.
Pricing Result Output representation of the pricing result.
Pricing Result Error Output representation of the pricing result error.
Pricing Versioned Revision Details Output representation of the versioned revision details.
Pricing Waterfall Response Output representation of a pricing waterfall request.
Procedure Plan Criterion Output representation of the details of a procedure plan criterion.
Procedure Plan Definition Output representation of the details of a single procedure plan definition.
Procedure Plan Definition Version Output representation of the version details of a procedure plan definition.
Procedure Plan Definitions Output representation of the details of procedure plan definitions.
Procedure Plan Generic Output representation of the details of the created procedure plan definition record.
Procedure Plan Generic Error Output representation of the error details related to the procedure plan definitions.
Procedure Plan Option Output representation of the details of a procedure plan option.
Procedure Plan Section Output representation of the details of a procedure plan section.
Procedure Plan Section Evaluation Runtime Output representation of the results from the procedure plan evaluation.
Procedure Plan Evaluation Output representation of the evaluation details of a procedure plan definition.
Procedure Plan Evaluation Response Output representation of the evaluation details of a procedure plan definition.
Procedure Plan Evaluation Result Output representation of the evaluation result of a procedure plan definition. Pricing Process Execution Details for Line Items Output representation of the pricing process execution details for the line items along with the error details and response generation status.
Line Item Details Response Output representation of the pricing process execution details for the line items.
Pricing Process Execution Response Output representation of the details of a pricing process execution.
Pricing Process Execution List Output representation of the execution details for different types of the pricing processes.
Pricing Simulation Input Variables With Data Output representation of the pricing simulation variables with data.

### Adjustment Details

Output representation of a pricing adjustment request.

**JSON example**

```json
"pricingElement": {
"adjustments": [{
"adjustmentType": null,
"adjustmentValue": null
}],
"name": "List Price",
"elementType": "ListPrice"
}
```

| Name | Type | Description | Filter Group and Version | Available Version |
| --- | --- | --- | --- | --- |
| adjustments | Map<String, Object>[] | Details of the pricing element. | Small, 60.0 | 60.0 |
| description | String | Description of the pricing element. | Small, 60.0 | 60.0 |
| elementType | String | Type of the pricing element. | Small, 60.0 | 60.0 |
| name | String | Name of the pricing element. | Small, 60.0 | 60.0 |

### API Execution Log Response

Output representation of the execution log of a pricing waterfall request.

**JSON example**

```json
{
"message": {The Pricing API execution was successful.},
"pricingElement": {
"adjustments": [
{
"adjustmentType": null,
"adjustmentValue": null
}
],
"name": "List Price",
"elementType": "ListPrice"
}
}
```

| Name | Type | Description | Filter Group and Version | Available Version |
| --- | --- | --- | --- | --- |
| message | String [] | Message of the API execution. | Small, 63.0 | 63.0 |
| pricingElement | Adjustment Details | Details of the price adjustment of a pricing element. | Small, 63.0 | 63.0 |

### Line Item Waterfall Response

Output representation of the line item waterfall response.

**JSON example**

```json
{
  "currencyCode": "USD",
  "error": null,
  "executionEndTimestamp": "2023-07-31T20:11:29.625Z",
  "executionId": "gdLVwn2x1uats2xWMAjV",
  "executionStartTimestamp": null,
  "lineItemId": "item1",
  "success": true,
  "usageType": "Pricing",
  "output": {
    "quantity": "10",
    "netUnitPrice": "10",
    "subtotal": "100"
  },
  "waterfall": []
}
```

This sample response includes diagnostic data if you've enabled Advanced Logging settings under Salesforce Pricing from Setup.

```json
{
  "apiExecutionId": "395526033950891",
  "contextDefinitionVersionId": "11OSG000000Eiu12AC",
  "contextMappingId": "11jSG00001YqfHVYAZ",
  "currencyCode": "USD",
  "executionEndTimestamp": "2026-02-17T10:43:46.197Z",
  "executionId": "395527509949481",
  "executionStartTimestamp": "2026-02-17T10:43:44.063Z",
  "id": "0QLSG000001OXv84AG",
  "lineItemId": "0QLSG000001OXv84AG",
  "output": {
    "NetUnitPrice": 20,
    "TotalSubscriptionPrice": 40,
    "Subtotal": 40,
    "diagnosticData": {
      "lineItemId": "0QLSG000001OXv84AG",
      "exceptionDetails": {},
      "inputParams": {
        "ContributingNetUnitPrice": [
          100
        ],
        "ContributingSubTotal": [
          100
        ],
        "DerivedFormula": [
          "PERCENTAGE(ListPrice,10)",
          "PERCENTAGE(ListPrice,10)"
        ],
        "PRODUCT_REFERENCE_IDS": null,
        "Subtotal": 40,
        "Quantity": 2,
        "TransactionalListPrice": 0,
        "ContractId": null,
        "CurrencyIsoCode": "USD",
        "ContributingSource": [
          "Product",
          "Product"
        ],
        "isDerivedProcessed": true,
        "IsDerived": true,
        "NetUnitPrice": 20,
        "ContributingId": [
          "02iSG000001fenKYAQ",
          "0QLSG000001OXv74AG"
        ],
        "HeaderTotal": 100,
        "ContributingScope": [
          "NonTransactional",
          "Transactional"
        ],
        "Non-TransactionalListPrice": [
          100
        ],
        "ContributingProduct": [
          "01tSG00000CC6NhYAL",
          "01tSG00000CC6NhYAL"
        ],
        "LineItemId": "0QLSG000001OXv84AG",
        "hasError": false,
        "lineItemDetailId": "0QLSG000001OXv84AG",
        "lineItemDetailIndex": 1
      },
      "contributorCount": 2,
      "contributingLines": [
        {
          "ContributingNetUnitPrice": 100,
          "DerivedFormula": "PERCENTAGE(ListPrice,10)",
          "ContributingSubTotal": 100,
          "ContributingId": "0QLSG000001OXv84AG",
          "ContributingScope": "NonTransactional",
          "HeaderTotal": 100,
          "isSkipped": false,
          "Non-TransactionalListPrice": 100,
          "ContributingProduct": "01tSG00000CC6NhYAL",
          "TransactionalListPrice": 0,
          "hasError": false,
          "ContributingSource": "Product"
        },
        {
          "ContributingNetUnitPrice": null,
          "DerivedFormula": "PERCENTAGE(ListPrice,10)",
          "ContributingSubTotal": null,
          "ContributingId": "0QLSG000001OXv84AG",
          "ContributingScope": "Transactional",
          "HeaderTotal": 100,
          "isSkipped": false,
          "Non-TransactionalListPrice": null,
          "ContributingProduct": "01tSG00000CC6NhYAL",
          "TransactionalListPrice": 0,
          "hasError": false,
          "ContributingSource": "Product"
        }
      ]
    },
    "isParallelExecution": true,
    "SubscriptionNetUnitPrice": 20,
    "section-1-output": 40,
    "section-0-output": 40
  },
  "success": true,
  "usageType": "Pricing",
  "waterfall": [
    {
      "fieldToTagNameMapping": {
        "ContributingNetUnitPrice": "ContributorUnitPrice",
        "ContributingSubTotal": "ContributorTotalPrice",
        "DerivedFormula": "ContributorFormulaInput",
        "Subtotal": "ItemNetTotalPrice",
        "Quantity": "LineItemQuantity",
        "TransactionalListPrice": "ListPrice",
        "ContractId": "ItemContract",
        "CurrencyIsoCode": "CurrencyIsoCode",
        "PriceWaterfall": "price_water_fall",
        "ContributingSource": "ContributorSource",
        "IsDerived": "DerivedPricingAttribute",
        "NetUnitPrice": "NetUnitPrice",
        "ContributingId": "Contributor",
        "ContributingScope": "ContributorScope",
        "HeaderTotal": "TotalAmount",
        "Non-TransactionalListPrice": "ContributorListPrice",
        "ContributingProduct": "ContributorProduct",
        "LineItemId": "LineItem"
      },
      "hideWaterfall": false,
      "inputParameters": {
        "ContributingNetUnitPrice": [
          100
        ],
        "ContributingSubTotal": [
          100
        ],
        "DerivedFormula": [
          "PERCENTAGE(ListPrice,10)",
          "PERCENTAGE(ListPrice,10)"
        ],
        "Quantity": 2,
        "TransactionalListPrice": 0,
        "ContractId": null,
        "CurrencyIsoCode": "USD",
        "ContributingSource": [
          "Product",
          "Product"
        ],
        "IsDerived": true,
        "ContributingId": [
          "02iSG000001fenKYAQ",
          "0QLSG000001OXv74AG"
        ],
        "HeaderTotal": 100,
        "ContributingScope": [
          "NonTransactional",
          "Transactional"
        ],
        "Non-TransactionalListPrice": [
          100
        ],
        "diagnosticData": {
          "lineItemId": "0QLSG000001OXv84AG",
          "exceptionDetails": {},
          "inputParams": {
            "ContributingNetUnitPrice": [
              100
            ],
            "ContributingSubTotal": [
              100
            ],
            "DerivedFormula": [
              "PERCENTAGE(ListPrice,10)",
              "PERCENTAGE(ListPrice,10)"
            ],
            "PRODUCT_REFERENCE_IDS": null,
            "Subtotal": 40,
            "Quantity": 2,
            "TransactionalListPrice": 0,
            "ContractId": null,
            "CurrencyIsoCode": "USD",
            "ContributingSource": [
              "Product",
              "Product"
            ],
            "isDerivedProcessed": true,
            "IsDerived": true,
            "NetUnitPrice": 20,
            "ContributingId": [
              "02iSG000001fenKYAQ",
              "0QLSG000001OXv74AG"
            ],
            "HeaderTotal": 100,
            "ContributingScope": [
              "NonTransactional",
              "Transactional"
            ],
            "Non-TransactionalListPrice": [
              100
            ],
            "ContributingProduct": [
              "01tSG00000CC6NhYAL",
              "01tSG00000CC6NhYAL"
            ],
            "LineItemId": "0QLSG000001OXv84AG",
            "hasError": false,
            "lineItemDetailId": "0QLSG000001OXv84AG",
            "lineItemDetailIndex": 1
          },
          "contributorCount": 2,
          "contributingLines": [
            {
              "ContributingNetUnitPrice": 100,
              "DerivedFormula": "PERCENTAGE(ListPrice,10)",
              "ContributingSubTotal": 100,
              "ContributingId": "0QLSG000001OXv84AG",
              "ContributingScope": "NonTransactional",
              "HeaderTotal": 100,
              "isSkipped": false,
              "Non-TransactionalListPrice": 100,
              "ContributingProduct": "01tSG00000CC6NhYAL",
              "TransactionalListPrice": 0,
              "hasError": false,
              "ContributingSource": "Product"
            },
            {
              "ContributingNetUnitPrice": null,
              "DerivedFormula": "PERCENTAGE(ListPrice,10)",
              "ContributingSubTotal": null,
              "ContributingId": "0QLSG000001OXv84AG",
              "ContributingScope": "Transactional",
              "HeaderTotal": 100,
              "isSkipped": false,
              "Non-TransactionalListPrice": null,
              "ContributingProduct": "01tSG00000CC6NhYAL",
              "TransactionalListPrice": 0,
              "hasError": false,
              "ContributingSource": "Product"
            }
          ]
        },
        "ContributingProduct": [
          "01tSG00000CC6NhYAL",
          "01tSG00000CC6NhYAL"
        ],
        "LineItemId": "0QLSG000001OXv84AG"
      },
      "outputParameters": {
        "Subtotal": 40,
        "diagnosticData": {
          "lineItemId": "0QLSG000001OXv84AG",
          "exceptionDetails": {},
          "inputParams": {
            "ContributingNetUnitPrice": [
              100
            ],
            "ContributingSubTotal": [
              100
            ],
            "DerivedFormula": [
              "PERCENTAGE(ListPrice,10)",
              "PERCENTAGE(ListPrice,10)"
            ],
            "PRODUCT_REFERENCE_IDS": null,
            "Subtotal": 40,
            "Quantity": 2,
            "TransactionalListPrice": 0,
            "ContractId": null,
            "CurrencyIsoCode": "USD",
            "ContributingSource": [
              "Product",
              "Product"
            ],
            "isDerivedProcessed": true,
            "IsDerived": true,
            "NetUnitPrice": 20,
            "ContributingId": [
              "02iSG000001fenKYAQ",
              "0QLSG000001OXv74AG"
            ],
            "HeaderTotal": 100,
            "ContributingScope": [
              "NonTransactional",
              "Transactional"
            ],
            "Non-TransactionalListPrice": [
              100
            ],
            "ContributingProduct": [
              "01tSG00000CC6NhYAL",
              "01tSG00000CC6NhYAL"
            ],
            "LineItemId": "0QLSG000001OXv84AG",
            "hasError": false,
            "lineItemDetailId": "0QLSG000001OXv84AG",
            "lineItemDetailIndex": 1
          },
          "contributorCount": 2,
          "contributingLines": [
            {
              "ContributingNetUnitPrice": 100,
              "DerivedFormula": "PERCENTAGE(ListPrice,10)",
              "ContributingSubTotal": 100,
              "ContributingId": "0QLSG000001OXv84AG",
              "ContributingScope": "NonTransactional",
              "HeaderTotal": 100,
              "isSkipped": false,
              "Non-TransactionalListPrice": 100,
              "ContributingProduct": "01tSG00000CC6NhYAL",
              "TransactionalListPrice": 0,
              "hasError": false,
              "ContributingSource": "Product"
            },
            {
              "ContributingNetUnitPrice": null,
              "DerivedFormula": "PERCENTAGE(ListPrice,10)",
              "ContributingSubTotal": null,
              "ContributingId": "0QLSG000001OXv84AG",
              "ContributingScope": "Transactional",
              "HeaderTotal": 100,
              "isSkipped": false,
              "Non-TransactionalListPrice": null,
              "ContributingProduct": "01tSG00000CC6NhYAL",
              "TransactionalListPrice": 0,
              "hasError": false,
              "ContributingSource": "Product"
            }
          ]
        },
        "NetUnitPrice": 20
      },
      "pricingElement": {
        "adjustments": [
          {
            "NetUnitPrice": 10,
            "ContributingId": "02iSG000001fenKYAQ",
            "ContributingScope": "NonTransactional",
            "ContributingProduct": "01tSG00000CC6NhYAL",
            "ContributingSource": "Product"
          },
          {
            "NetUnitPrice": 10,
            "ContributingId": "0QLSG000001OXv74AG",
            "ContributingScope": "Transactional",
            "ContributingProduct": "01tSG00000CC6NhYAL",
            "ContributingSource": "Product"
          }
        ],
        "elementType": "DerivedPricing",
        "name": "Derived Price"
      },
      "profileAccess": [],
      "sequence": 3,
      "tasksInfo": [
        {
          "executionEndTimestamp": "2026-02-17T10:43:46.077280883Z",
          "executionStartTimestamp": "2026-02-17T10:43:46.037719198Z",
          "taskName": "DerivedPrice-DerivedCalculate"
        },
        {
          "executionEndTimestamp": "2026-02-17T10:43:45.657762503Z",
          "executionStartTimestamp": "2026-02-17T10:43:45.657283237Z",
          "taskName": "DerivedPrice-UpdateCalculationPayload"
        }
      ]
    }
  ]
}
```

| Name | Type | Description | Filter Group and Version | Available Version |
| --- | --- | --- | --- | --- |
| contextDefinitionVersionId | String | Context definition version ID of the pricing procedure. | Small, 60.0 | 60.0 |
| contextMappingId | String | Context mapping ID of the record. | Small, 60.0 | 60.0 |
| currencyCode | String | Currency code. For example, USD or INR. | Small, 60.0 | 60.0 |
| error | Pricing Error Response | Details of any errors. | Small, 60.0 | 60.0 |
| executionEndTimestamp | String | End timestamp of procedure execution. | Small, 60.0 | 60.0 |
| executionId | String | Execution ID of a particular execution of a pricing procedure. | Small, 60.0 | 60.0 |
| executionStartTimestamp | String | Start timestamp of procedure execution. | Small, 60.0 | 60.0 |
| lineItemId | String | Line item ID for which the price is being calculated. | Small, 60.0 | 60.0 |
| output | Map<String, Object> | Output of the pricing procedure. | Small, 60.0 | 60.0 |
| success | Boolean | Indicates whether the API request is successful (true) or not (false). | Small, 60.0 | 60.0 |
| usageType | String | Usage type of the waterfall log record. | Small, 62.0 | 62.0 |
| waterfall | Pricing Waterfall Response [] | Details of the price waterfall. | Small, 60.0 | 60.0 |

### PBE Derived Pricing

Output representation of the response that includes the source product for the Price Book Entry (PBE) derived pricing.

**JSON example**

```json
{
  "productId": "01txx0000006i2SAAQ",
  "pricebookEntryId": "01uxx0000008yYcAAI",
  "effectiveFrom": "2020-01-01T22:53:20.000Z",
  "effectiveTo": "2021-01-01T22:53:20.000Z"
}
```

| Name | Type | Description | Filter Group and Version | Available Version |
| --- | --- | --- | --- | --- |
| error | Pricing Error Response [] | Displays the error while processing the request. | Small, 61.0 | 61.0 |
| isSuccess | Boolean | Indicates whether the request is successful (true) or not (false). | Small, 61.0 | 61.0 |
| sourceProceductId | String | ID of the source product. | Small, 61.0 | 61.0 |

### Pricing Error Response

Output representation of the pricing error response.

| Name | Type | Description | Filter Group and Version | Available Version |
| --- | --- | --- | --- | --- |
| errorCode | String | Indicates the error code. | Small, 60.0 | 60.0 |
| message | String | Specifies the message stating the reason for the error, if any. | Small, 60.0 | 60.0 |

### Pricing Execution Waterfall Response

Output representation of the execution process that's associated with a pricing waterfall.

**JSON example**

```json
{
"apiEndpoint": "/connect/core-pricing/pricing",
"apiExecutionId": "263369316770986",
"apiExecutionLogRepresentationList": [
{
"message": [
"The Pricing API couldn't be run. Try again, and if the issue persists, ask your
admin for help."
]
}
],
"currencyCode": "USD",
"executionId": "263369316895959",
"id": "263369316895960",
"lineItemId": null,
"referenceKey": "referenceKey-ABCD",
"success": false,
"usageType": "Api_Execution"
}
```

| Name | Type | Description | Filter Group and Version | Available Version |
| --- | --- | --- | --- | --- |
| apiEndpoint | String | API endpoint that ran during the pricing request. | Small, 63.0 | Small, 63.0 |
| apiExecutionId | String | Unique execution ID that's generated each time a pricing API is executed. | Small, 63.0 | Small, 63.0 |
| apiExecutionLogRepresentationList | API Execution Log Response [] | List of API execution logs. | Small, 63.0 | 63.0 |
| currencyCode | String | Currency code that’s stored in each API log record for the pricing execution. | Small, 67.0 | Small, 67.0 |
| error | Pricing Error Response | Error details of the pricing execution process. | Small, 63.0 | Small, 63.0 |
| executionId | String | Unique ID that's generated each time a pricing process is executed. | Small, 63.0 | Small, 63.0 |
| id | String | Unique record ID of the waterfall response. | Small, 65.0 | Small, 65.0 |
| lineItemId | String | Unique ID of the line item that's associated with this pricing execution. | Small, 59.0 | Small, 59.0 |
| referenceKey | String | The reference ID that a consuming workstream provides in the API to search for the specific logs in the Pricing Operations Console. | Small, 63.0 | Small, 63.0 |
| success | Boolean | Indicates whether the API execution is successful (true) or not (false). | Small, 63.0 | Small, 63.0 |
| usageType | String | Usage type of the API execution. | Small, 63.0 | Small, 63.0 |

### Pricing Generic Response

Output representation of a pricing data sync request.

**JSON example**

```json
{
  "success": true
}
```

| Name | Type | Description | Filter Group and Version | Available Version |
| --- | --- | --- | --- | --- |
| error | Pricing Error Response | Details from the pricing error response. | Small, 60.0 | 60.0 |

| Name | Type | Description | Filter Group and Version | Available Version |
| --- | --- | --- | --- | --- |
| success | Boolean | Indicates whether the request is successful (true) or not (false). | Small, 60.0 | 60.0 |

### Pricing Output

Output representation of a Salesforce pricing request.

**JSON example**

```json
{
"apiExecutionId": "612228038743152",
"pricingExecutionId": "612229738898095",
"pricingResult": {
"subtotal": [
{
"dataPath": [
"cart_1001",
"lineItem_1002"
],
"value": 300.0,
"errors": [],
"isSuccess": true
},
{
"dataPath": [
"cart_1001",
"lineItem_1001"
],
"value":400.0,
"errors": [],
"isSuccess": true
}
],
"netunitprice": [
{
"dataPath": [
"cart_1001",
"lineItem_1002"
],
"value": xx,
"errors": [],
"isSuccess": true
},
{
"dataPath": [
"cart_1001",
"lineItem_1001"
],
"value": xx,
"errors": [],
"isSuccess": true
}
]
},
"pricingResultErrors": [],
"status": "Completed",
}
```

| Name | Type | Description | Filter Group and Version | Available Version |
| --- | --- | --- | --- | --- |
| apiExecutionId | String | Unique ID that's generated each time a pricing API is executed. | Small, 63.0 | 63.0 |
| error | Pricing Error Response | Displays the error encountered when the request is processed. For example, a pricing procedure isn’t found. | Small, 60.0 | 60.0 |
| pricingExecutionId | String | Unique ID that's generated each time a pricing process is executed. | Small, 63.0 | 63.0 |
| pricingResult | Pricing Result | Represents the outcomes associated with the output tags defined in the contextual definition for which the pricing engine establishes values. The initial attribute name is substituted for the output tag's designation. For instance, if the original attribute name specified in the Context Definition is "Subtotal," but during contextual setup, the output tag is denoted as "Total Price," the API output exhibits the initial attribute name "Subtotal" in the response. | Small, 60.0 | 60.0 |
| pricingResultErrors | Pricing Result Error[] | Errors from the pricing request, if any. | Small, 60.0 | 60.0 |
| status | String | Status of the pricing request. Valid values are: - Completed — Pricing is completed for all the line items. - Partially Completed — Pricing is completed for some line items. - Failed — Pricing isn’t completed for the line items. | Small, 60.0 | 60.0 |

### Pricing Recipe LookUp Table Response

Output representation of a pricing recipe lookup table.

**JSON example**

```json
"decisionTables": [
{
"id": "0lDxx00000000T3EAI",
"isInternal": true,
"pricingComponentType": "ListPrice"
},
{
"id": "0lDxx00000000T4EAI",
"isInternal": true,
"pricingComponentType": "VolumeDiscount"
},
{
"id": "0lDxx00000000HlEAI",
"isInternal": false,
"pricingComponentType": "CustomDiscount"
}
]
```

| Name | Type | Description | Filter Group and Version | Available Version |
| --- | --- | --- | --- | --- |
| id | String | ID of the pricing recipe table mapping. | Small, 60.0 | 60.0 |
| isInternal | Boolean | Indicates if the decision table is available (true) or not (false). | Small, 60.0 | 60.0 |
| pricingComponentType | String | Price component types such as, custom discount, volume discount, attribute-based discount, bundle-based discount, and list price. | Small, 60.0 | 60.0 |

### Pricing Recipe

Output representation of the pricing recipe information table.

**JSON example**

```json
"recipes": [
{
"active": false,
"createdBy": "autoproc@00dxx0000006gmjea2",
"createdOn": "2023-07-15T13:12:38.000Z",
"decisionTables": [
{
"id": "0lDxx00000000T3EAI",
"isInternal": true,
"pricingComponentType": "ListPrice"
},
{
"id": "0lDxx00000000T4EAI",
"isInternal": true,
"pricingComponentType": "VolumeDiscount"
},
{
"id": "0lDxx00000000HlEAI",
"isInternal": false,
"pricingComponentType": "CustomDiscount"
}
],
"developerName": "NGPDefaultRecipe",
"id": "12Gxx0000005Ka4EAE",
"name": "NGPDefaultRecipe",
"procedureCreatedBy": "",
"procedureCreatedOn": "2023-09-19T11:39:18.983Z",
"procedureId": "",
"procedureName": ""
}]
```

| Name | Type | Description | Filter Group and Version | Available Version |
| --- | --- | --- | --- | --- |
| active | Boolean | Indicates whether the recipe is active (true) or not (false). | Small, 60.0 | 60.0 |
| createdBy | String | Details on who created the recipe. | Small, 60.0 | 60.0 |
| createdOn | String | Date when the recipe was created. | Small, 60.0 | 60.0 |
| decisionTables | Pricing Recipe LookUp Table Response [] | Decision tables linked to the recipe. | Small, 60.0 | 60.0 |
| developerName | String | API name of the recipe. | Small, 60.0 | 60.0 |
| id | String | ID of the recipe. | Small, 60.0 | 60.0 |
| name | String | Name of the recipe. | Small, 60.0 | 60.0 |
| procedureCreatedBy | String | Details on who created the procedure. | Small, 60.0 | 60.0 |
| procedureCreatedOn | String | Date when the procedure was created. | Small, 60.0 | 60.0 |
| procedureId | String | ID of the procedure. | Small, 60.0 | 60.0 |
| procedureName | String | Name of the procedure. | Small, 60.0 | 60.0 |

### Pricing Recipe Post

Output representation of the pricing recipe after the API request.

**JSON example**

```json
{
isSuccess : true
}
```

| Name | Type | Description | Filter Group and Version | Available Version |
| --- | --- | --- | --- | --- |
| error | Pricing Error Response | Details from the pricing error response. | Small, 60.0 | 60.0 |
| isSuccess | Boolean | Indicates whether the response was calculated successfully (true) or not (false). | Small, 60.0 | 60.0 |

### Pricing Recipe Response

Output representation of the pricing recipe.

**JSON example**

```json
{
  "recipes": [
    {
      "active": false,
      "createdBy": "autoproc@00dxx0000006gmjea2",
      "createdOn": "2023-07-15T13:12:38.000Z",
      "decisionTables": [
        {
          "id": "0lDxx00000000T3EAI",
          "isInternal": true,
          "pricingComponentType": "ListPrice"
        },
        {
          "id": "0lDxx00000000T4EAI",
          "isInternal": true,
          "pricingComponentType": "VolumeDiscount"
        },
        {
          "id": "0lDxx00000000HlEAI",
          "isInternal": false,
          "pricingComponentType": "CustomDiscount"
        }
      ],
      "developerName": "NGPDefaultRecipe",
      "id": "12Gxx0000005Ka4EAE",
      "name": "NGPDefaultRecipe",
      "procedureCreatedBy": "",
      "procedureCreatedOn": "2023-09-19T11:39:18.983Z",
      "procedureId": "",
      "procedureName": ""
    }
  ],
  "success": true
}
```

| Name | Type | Description | Filter Group and Version | Available Version |
| --- | --- | --- | --- | --- |
| recipes | Pricing Recipe Output Representation [] | Representation of the pricing recipe. | Small, 60.0 | 60.0 |
| success | Boolean | Indicates if the request is successful (true) or not (false). | Small, 60.0 | 60.0 |

### Pricing Recipe Clone

Output representation of the payload for the pricing recipe clone operation.

**JSON example**

```json
{
  "isSuccess": true,
  "newPricingRecipeId": "0ClxX0000004D1AACU",
  "newPricingRecipeName": "Cloned Recipe"
}
```

| Name | Type | Description | Filter Group and Version | Available Version |
| --- | --- | --- | --- | --- |
| error | Pricing Recipe Clone Error | Details of the error encountered during the clone operation, if any. | Big, 68.0 | 68.0 |
| isSuccess | Boolean | Indicates whether the clone operation was successful (true) or not (false). | Big, 68.0 | 68.0 |
| newPricingRecipeId | String | ID of the cloned pricing recipe. | Big, 68.0 | 68.0 |
| newPricingRecipeName | String | Name of the cloned pricing recipe. | Big, 68.0 | 68.0 |

### Pricing Recipe Clone Error

Output representation of the error response for the Pricing Recipe Clone API.

| Name | Type | Description | Filter Group and Version | Available Version |
| --- | --- | --- | --- | --- |
| errorCode | String | Indicates the error code. | Big, 68.0 | 68.0 |
| message | String | Specifies the message stating the reason for the error, if any. | Big, 68.0 | 68.0 |

### Pricing Recipe Valid Elements

Output representation containing the list of valid pricing element type API names for a given Pricing Usage Sub Type.

| Name | Type | Description | Filter Group and Version | Available Version |
| --- | --- | --- | --- | --- |
| errorMessage | String | Error message when the isSuccess property is false. This property value is blank when the isSuccess property is true. | Big, 68.0 | 68.0 |
| isSuccess | Boolean | Indicates whether the request was successful (true) or not (false). | Big, 68.0 | 68.0 |
| validPricingElements | String | List of valid pricing element type API names for the given sub usage type. This property value includes an empty list when the isSuccess property is false. | Big, 68.0 | 68.0 |

### Pricing Response

Output representation of the pricing request.

**JSON example**

```json
{
  "success": true,
  "executionId": "zu81o5hBCrFzyd5LWZk"
}
```

| Name | Type | Description | Filter Group and Version | Available Version |
| --- | --- | --- | --- | --- |
| error | Pricing Error Response | Errors while processing the request, if any. | Small, 60.0 | 60.0 |
| executionId | String | Auto-generated alphanumeric string for correlation to extract async waterfall and context persistence status. | Small, 60.0 | 60.0 |
| success | Boolean | Indicates if the request is successful (true) or not (false). | Small, 60.0 | 60.0 |

### Pricing Result

Output representation of the pricing result.

**JSON example**

```json
"pricingResult": {
"subtotal": [
{
"dataPath": [
"cart_1001",
"lineItem_1002"
],
"value": 300.0,
"errors": [],
"isSuccess": true
},
{
"dataPath": [
"cart_1001",
"lineItem_1001"
],
"value":400.0,
"errors": [],
"isSuccess": true
}
],
"netunitprice": [
{
"dataPath": [
"cart_1001",
"lineItem_1002"
],
"value": xx,
"errors": [],
"isSuccess": true
},
{
"dataPath": [
"cart_1001",
"lineItem_1001"
],
"value": xx,
"errors": [],
"isSuccess": true
}
]
}
```

| Name | Type | Description | Filter Group and Version | Available Version |
| --- | --- | --- | --- | --- |
| dataPath | String | Includes the entire data route for the specific element starting from the root node. The request must include the ID to construct the accurate data route. For example, if a jsonDataString property comprises a Cart [Id = Cart1] and its associated Cart Item [Id = CartItem1], then the data route for CartItem appears as [Cart1, CartItem1]. | Small, 60.0 | 60.0 |

| Name | Type | Description | Filter Group and Version | Available Version |
| --- | --- | --- | --- | --- |
| errors | Pricing Error Response[] | Displays processing errors related to the element as recognized by the data path. | Small, 60.0 | 60.0 |
| isSuccess | Boolean | Displays if processing of the element for the specified data path is successful or not. | Small, 60.0 | 60.0 |
| value | Object | Displays the value of the element into consideration. Element is uniquely identify by the data path. | Small, 60.0 | 60.0 |

### Pricing Result Error

Output representation of the pricing result error.

**JSON example**

```json
"pricingResultErrors": {
"Aggregateprice": [
{
"dataPath": [
"cart_1001",
],
"errors": [
{
"errorCode": "Dummy"
"message":
}
]
}
]
}
```

| Name | Type | Description | Filter Group and Version | Available Version |
| --- | --- | --- | --- | --- |
| dataPath | String[] | Includes the entire data route for the specific element starting from the root node. The request must include the ID to construct the accurate data route. For example, if a jsonDataString property comprises a Cart [Id = Cart1] and its associated Cart Item [Id = CartItem1], then the data route for CartItem appears as [Cart1, CartItem1]. | Small, 60.0 | 60.0 |
| errors | Pricing Error Response | Displays processing errors related to the element as recognized by the data path. | Small, 60.0 | 60.0 |

### Pricing Versioned Revision Details

Output representation of the versioned revision details.

| Name | Type | Description | Filter Group and Version | Available Version |
| --- | --- | --- | --- | --- |
| error | Pricing Error Response | Details from the pricing error response. | Small, 60.0 | 60.0 |
| success | Boolean | Indicates whether the request is successful (true) or not (false). | Small, 60.0 | 60.0 |

### Pricing Waterfall Response

Output representation of a pricing waterfall request.

**JSON example**

```json
{
  "inputParameters": {
    "productId": "01txx0000006i2SAAQ",
    "pricebookId": "01sxx0000005ptpAAA",
    "pricingModelType": "OneTime"
  },
  "fieldToTagNameMapping": {
    "Product2Id": "ItemProduct",
    "Subtotal": "Subtotal",
    "Pricebook2Id": "Pricebook",
    "Quantity": "ItemQuantity",
    "LineItemId": "SalesTransactionSource",
    "ListPrice": "ItemListPrice"
  },
  "sequence": 0,
  "outputParameters": {
    "listPrice": "10"
  },
  "pricingElement": {
    "adjustments": [
      {
        "adjustmentType": null,
        "adjustmentValue": null
      }
    ],
    "name": "List Price"
  }
}
```

| Name | Type | Description | Filter Group and Version | Available Version |
| --- | --- | --- | --- | --- |
| fieldToTagNameMapping | Map<String, String> | Mappings of field to tag names. | Small, 60.0 | 60.0 |

| Name | Type | Description | Filter Group and Version | Available Version |
| --- | --- | --- | --- | --- |
| inputParameters | Map<String, Object> | Parameters of pricing element input. | Small, 60.0 | 60.0 |
| outputParameters | Map<String, Object> | Parameters of pricing element output. | Small, 60.0 | 60.0 |
| pricingElement | Adjustment Details | Details of the price adjustment of a pricing element. | Small, 60.0 | 60.0 |
| sequence | Integer | Sequence of pricing element execution. | Small, 60.0 | 60.0 |

### Procedure Plan Criterion

Output representation of the details of a procedure plan criterion.

**JSON example**

```json
"procedurePlanCriterion": [
{
"conditionSequence": 1,
"dataType": "Text",
"fieldObject": "BillingCountry",
"fieldPath": "BillingCountry",
"isSuccess": true,
"literalValue": "test",
"operator": "Equals",
"recordId": "1FiZ60000004C9cKAE"
},
{
"conditionSequence": 2,
"dataType": "Text",
"fieldObject": "BillingPostalCode",
"fieldPath": "BillingPostalCode",
"isSuccess": true,
"literalValue": "pramit",
"operator": "Equals",
"recordId": "1FiZ60000004C9dKAE"
},
{
"conditionSequence": 3,
"dataType": "Date",
"fieldObject": "LastActivityDate",
"fieldPath": "LastActivityDate",
"isSuccess": true,
"literalValue": "2024-07-14",
"operator": "LessThan",
"recordId": "1FiZ60000004C9eKAE"
}
]
```

| Name | Type | Description | Filter Group and Version | Available Version |
| --- | --- | --- | --- | --- |
| conditionSequence | Integer | Sequence to be followed to process the conditions defined in the procedure plan option. | Small, 62.0 | 62.0 |
| dataType | String | Data type of the field from the selected object. | Small, 62.0 | 62.0 |
| error | Procedure Plan Generic Error [] | Details of the error encountered during the processing of the API request. | Small, 62.0 | 62.0 |
| fieldObject | String | Value of the object field that’s used to resolve the procedure plan option. | Small, 62.0 | 62.0 |
| fieldPath | String | Path of the field that’s used in a procedure in relation to the object that the field belongs to. | Small, 62.0 | 62.0 |
| isSuccess | Boolean | Indicates whether the API request is successful (true) or not (false). | Small, 62.0 | 62.0 |
| literalValue | String | User-defined value that’s compared to the value of the sObject field value. | Small, 62.0 | 62.0 |
| operator | String | Operator that’s used by the procedure plan criterion. | Small, 62.0 | 62.0 |
| recordId | String | ID of the procedure plan criterion record. | Small, 62.0 | 62.0 |

### Procedure Plan Definition

Output representation of the details of a single procedure plan definition.

**JSON example**

This example shows a sample response for the Procedure Plan Definition By ID (GET) request.

```json
{
  "description": "Default Definition",
  "developerName": "Quote_Definition",
  "name": "Quote_Definition",
  "primaryObject": "Quote",
  "procedurePlanDefinitionVersions": [
    {
      "active": false,
      "contextDefinition": "11Oxx0000006PZ7EAM",
      "effectiveFrom": "2024-02-03T10:15:30.000Z",
      "effectiveTo": "2024-02-03T10:15:30.000Z",
      "readContextMapping": "MedicalHistoryMapping",
      "recordId": "1Cvxx0000004E1ACAU",
      "saveContextMapping": "MedicalHistoryMapping",
      "success": true,
      "processType": "Default"
    }
  ],
  "recordId": "1FNxx0000004GkWGAU",
  "processType": "Default",
  "success": true
}
```

This example shows a sample response for the Procedure Plan Definition By ID (PATCH) request.

```json
{
  "procedurePlanDefinitionVersions": [],
  "recordId": "1FNDU00000000EX4AY",
  "processType": "Default",
  "success": true
}
```

| Name | Type | Description | Filter Group and Version | Available Version |
| --- | --- | --- | --- | --- |
| description | String | Description for the procedure plan definition. | Small, 62.0 | 62.0 |
| developerName | String | Developer name of the procedure plan definition. | Small, 62.0 | 62.0 |
| error | Procedure Plan Generic Error [] | Details of the error encountered during the processing of the API request. | Small, 62.0 | 62.0 |
| name | String | Name of the procedure plan definition. | Small, 62.0 | 62.0 |
| primaryObject | String | Object that’s associated with the procedure plan definition. | Small, 62.0 | 62.0 |
| procedurePlanDefinitionVersions | Procedure Plan Definition Version [] | Details of the versions of a procedure plan definition. | Small, 62.0 | 62.0 |
| processType | String | Business processes that's specified that requires a procedure plan for each sObject and definition. | Small, 63.0 | 63.0 |
| recordId | String | ID of the procedure plan definition record. | Small, 62.0 | 62.0 |
| success | Boolean | Indicates whether the API request is successful (true) or not (false). | Small, 62.0 | 62.0 |

### Procedure Plan Definition Version

Output representation of the version details of a procedure plan definition.

**JSON example**

```json
"procedurePlanDefinitionVersions": [
{
"active": false,
"developerName": "sample_test",
"effectiveFrom": "2024-07-09T00:00:00.000Z",
"contextDefinition": "SalesTransactionContext__stdctx",
"procedurePlanSections": [],
"rank": 1,
"readContextMapping": "ProductDiscoveryContextMapping",
"recordId": "1CvZ60000008OIaKAM",
"success": true,
"processType": "Default"
}
]
```

| Name | Type | Description | Filter Group and Version | Available Version |
| --- | --- | --- | --- | --- |
| active | Boolean | Indicates whether the procedure plan definition version is active (true) or not (false). | Small, 62.0 | 62.0 |
| contextDefinition | String | Context definition that’s associated with the procedure plan definition version. | Small, 62.0 | 62.0 |
| developerName | String | Developer name of the procedure plan definition version. | Small, 62.0 | 62.0 |
| effectiveFrom | String | Date and time from when the procedure plan definition version is effective. | Small, 62.0 | 62.0 |
| effectiveTo | String | Date and time until when the procedure plan definition version is effective. | Small, 62.0 | 62.0 |
| error | Procedure Plan Generic Error [] | Details of the error encountered during the processing of the API request. | Small, 62.0 | 62.0 |
| inheritedFrom | String | Name of the template the procedure plan definition is extended from. | Small, 62.0 | 62.0 |
| procedurePlanSections | Procedure Plan Section [] | List of sections of the procedure plan definition that you can organize in any order. Each section must include a procedure or a set of procedures to be executed for a specific criteria. | Small, 62.0 | 62.0 |
| processType | String | Business processes that's specified that requires a procedure plan for each sObject and definition. | Small, 64.0 | 64.0 |
| rank | Integer | Rank or the order of sequence to follow for the processing of the procedure plan definition version. | Small, 62.0 | 62.0 |
| readContextMapping | String | Mapping that’s used to read data from the mapped object and populate the context definition. | Small, 62.0 | 62.0 |

| Name | Type | Description | Filter Group and Version | Available Version |
| --- | --- | --- | --- | --- |
| recordId | String | ID of the procedure plan definition version record. | Small, 62.0 | 62.0 |
| saveContextMapping | String | Mapping that’s used to save data from the context definition and populate the mapped object. | Small, 62.0 | 62.0 |
| success | Boolean | Indicates whether the API request is successful (true) or not (false). | Small, 62.0 | 62.0 |

### Procedure Plan Definitions

Output representation of the details of procedure plan definitions.

**JSON example**

```json
{
  "isSuccess": true,
  "procedurePlanDefinitions": [
    {
      "description": "test description",
      "developerName": "sample_test",
      "name": "sample_test",
      "primaryObject": "Account",
      "procedurePlanDefinitionVersions": [
        {
          "active": false,
          "developerName": "sample_test",
          "effectiveFrom": "2024-07-09T00:00:00.000Z",
          "contextDefinition": "SalesTransactionContext__stdctx",
          "procedurePlanSections": [],
          "rank": 1,
          "readContextMapping": "ProductDiscoveryContextMapping",
          "recordId": "1CvZ60000008OIaKAM",
          "success": true
        }
      ],
      "recordId": "1FNZ60000004CAHOA2",
      "success": true
    },
    {
      "developerName": "PriceAdjustmentSchedule",
      "name": "PriceAdjustmentSchedule",
      "primaryObject": "PriceAdjustmentSchedule",
      "procedurePlanDefinitionVersions": [
        {
          "active": false,
          "developerName": "PriceAdjustmentSchedule",
          "effectiveFrom": "2024-07-10T00:00:00.000Z",
          "contextDefinition": "SalesTransactionContext__stdctx",
          "procedurePlanSections": [],
          "rank": 1,
          "recordId": "1CvZ6000000CaRbKAK",
          "success": true
        }
      ],
      "recordId": "1FNZ6000000CaSAOA0",
      "success": true
    }
  ]
}
```

| Name | Type | Description | Filter Group and Version | Available Version |
| --- | --- | --- | --- | --- |
| error | Procedure Plan Generic Error [] | Details of the error encountered during the processing of the API request. | Small, 62.0 | 62.0 |
| isSuccess | Boolean | Indicates whether the API request is successful (true) or not (false). | Small, 62.0 | 62.0 |
| procedurePlanDefinitions | Procedure Plan Definition [] | Details of a single procedure plan definition. | Small, 62.0 | 62.0 |

### Procedure Plan Generic

Output representation of the details of the created procedure plan definition record.

**JSON example**

This example shows a sample response of the details of a procedure plan definition record, created by using the Procedure Plan
- **Definitions (POST) API.**

```json
{
  "isSuccess": true,
  "recordId": "1FNDU00000000EX4AY"
}
```

| Name | Type | Description | Filter Group and Version | Available Version |
| --- | --- | --- | --- | --- |
| error | Procedure Plan Generic Error [] | Details of the error encountered during the processing of the API request. | Small, 62.0 | 62.0 |
| isSuccess | Boolean | Indicates whether the API request is successful (true) or not (false). | Small, 62.0 | 62.0 |
| recordId | String | ID of the created procedure plan definition record. | Small, 62.0 | 62.0 |

### Procedure Plan Generic Error

Output representation of the error details related to the procedure plan definitions.

| Name | Type | Description | Filter Group and Version | Available Version |
| --- | --- | --- | --- | --- |
| errorCode | String | Code indicating the type of error. | Small, 62.0 | 62.0 |
| message | String | Message stating the reason for the error, if any. | Small, 62.0 | 62.0 |

### Procedure Plan Option

Output representation of the details of a procedure plan option.

**JSON example**

```json
"procedurePlanOptions": [
{
"expressionSetApiName": "Revenue_Mgmt_Default_Pricing_Procedure",
"expressionSetDefinition": "9QAZ60000004ECOOA2",
"expressionSetLabel": "Revenue Management Default Pricing Procedure",
"isSuccess": true,
"logic": "1 AND 2 AND 3",
"primaryObject": "Account",
"priority": 1,
"procedurePlanCriterion": [
{
"conditionSequence": 1,
"dataType": "Text",
"fieldObject": "BillingCountry",
"fieldPath": "BillingCountry",
"isSuccess": true,
"literalValue": "test",
"operator": "Equals",
"recordId": "1FiZ60000004C9cKAE"
},
{
"conditionSequence": 2,
"dataType": "Text",
"fieldObject": "BillingPostalCode",
"fieldPath": "BillingPostalCode",
"isSuccess": true,
"literalValue": "pramit",
"operator": "Equals",
"recordId": "1FiZ60000004C9dKAE"
},
{
"conditionSequence": 3,
"dataType": "Date",
"fieldObject": "LastActivityDate",
"fieldPath": "LastActivityDate",
"isSuccess": true,
"literalValue": "2024-07-14",
"operator": "LessThan",
"recordId": "1FiZ60000004C9eKAE"
}
],
"recordId": "1FYZ6000000000fOAA",
"saveContextMapping": "AssetToSalesTransactionMapping"
}
]
```

| Name | Type | Description | Filter Group and Version | Available Version |
| --- | --- | --- | --- | --- |
| error | Procedure Plan Generic Error [] | Details of the error encountered during the processing of the API request. | Small, 62.0 | 62.0 |
| expressionSetApiName | String | API name of the expression set. | Small, 62.0 | 62.0 |
| expressionSetDefinition | String | Expression set definition that’s associated with this procedure plan option record. | Small, 62.0 | 62.0 |
| expressionSetLabel | String | Label of the expression set that’s associated with this procedure plan option record. | Small, 62.0 | 62.0 |
| isSuccess | Boolean | Indicates whether the API request is successful (true) or not (false). | Small, 62.0 | 62.0 |
| logic | String | Computation logic for the conditions applied to a procedure plan option. | Small, 62.0 | 62.0 |
| primaryObject | String | Source object that’s used to create a procedure with rule-based criteria. | Small, 62.0 | 62.0 |
| priority | Integer | Priority for the specified criteria. | Small, 62.0 | 62.0 |
| procedurePlanCriterion | Procedure Plan Criterion [] | Details of the rule-based criteria for the procedure. | Small, 62.0 | 62.0 |
| readContextMapping | String | Mapping that’s used to read from the mapped object and populate the context definition. | Small, 62.0 | 62.0 |
| recordId | String | ID of the procedure plan option record. | Small, 62.0 | 62.0 |
| saveContextMapping | String | Mapping that’s used to save data from the context definition and populate the mapped object. | Small, 62.0 | 62.0 |

### Procedure Plan Section

Output representation of the details of a procedure plan section.

**JSON example**

```json
"procedurePlanSections": [
{
"isInherited": false,
"isSuccess": true,
"procedurePlanOptions": [
{
"expressionSetApiName": "Revenue_Mgmt_Default_Pricing_Procedure",
"expressionSetDefinition": "9QAZ60000004ECOOA2",
"expressionSetLabel": "Revenue Management Default Pricing Procedure",
"isSuccess": true,
"logic": "1 AND 2 AND 3",
"primaryObject": "Account",
"priority": 1,
"procedurePlanCriterion": [
{
"conditionSequence": 1,
"dataType": "Text",
"fieldObject": "BillingCountry",
"fieldPath": "BillingCountry",
"isSuccess": true,
"literalValue": "test",
"operator": "Equals",
"recordId": "1FiZ60000004C9cKAE"
},
{
"conditionSequence": 2,
"dataType": "Text",
"fieldObject": "BillingPostalCode",
"fieldPath": "BillingPostalCode",
"isSuccess": true,
"literalValue": "pramit",
"operator": "Equals",
"recordId": "1FiZ60000004C9dKAE"
},
{
"conditionSequence": 3,
"dataType": "Date",
"fieldObject": "LastActivityDate",
"fieldPath": "LastActivityDate",
"isSuccess": true,
"literalValue": "2024-07-14",
"operator": "LessThan",
"recordId": "1FiZ60000004C9eKAE"
}
],
"recordId": "1FYZ6000000000fOAA",
"saveContextMapping": "AssetToSalesTransactionMapping"
}
],
"recordId": "1FRZ60000008OIAOA2",
"resolutionType": "RuleBased",
"sectionType": "PricingProcedure",
"sequence": 1,
"subSectionType": "PricingProcedure"
}
]
```

| Name | Type | Description | Filter Group and Version | Available Version |
| --- | --- | --- | --- | --- |
| error | Procedure Plan Generic Error [] | Details of the error encountered during the processing of the API request. | Small, 62.0 | 62.0 |
| isInherited | Boolean | Indicates whether the procedure plan section is inherited from a template (true) or not (false). | Small, 62.0 | 62.0 |
| isSuccess | Boolean | Indicates whether the API request is successful (true) or not (false). | Small, 62.0 | 62.0 |
| procedurePlanOptions | Procedure Plan Option [] | List of procedure plan options. | Small, 62.0 | 62.0 |
| recordId | String | ID of the procedure plan option record. | Small, 62.0 | 62.0 |
| resolutionType | String | Type of resolution that’s used to filter the procedure. | Small, 62.0 | 62.0 |
| sectionType | String | Type of section. Valid values are: - PricingProcedure - ProductDiscoveryProcedure - ProductQualificationProcedure - PricingDiscoveryProcedure - DiscountSpreadServiceProcedure - RatingProcedure - Custom - RatingDiscoveryProcedure | Small, 62.0 | 62.0 |
| sequence | Integer | Sequence that’s followed for the processing of the procedures. | Small, 62.0 | 62.0 |
| subSectionType | String | Subsection that’s added to the procedure plan definition. | Small, 62.0 | 62.0 |

### Procedure Plan Section Evaluation Runtime

Output representation of the results from the procedure plan evaluation.

**JSON example**

```json
"procedurePlanSections": [
{
"expressionSetApiName": "pricingProcedure_usageType_3",
"expressionSetDefinitionId": "9QAZ60000004Ef6OAE",
"expressionSetLabel": "pricingProcedure_usageType_3",
"sectionType": "PricingProcedure",
"sequence": 1,
"subSectionType": "Section1",
"usageType": "DefaultPricing"
},
{
"expressionSetApiName": "productQualification_usageType_3",
"expressionSetDefinitionId": "9QAZ60000004EfFOAU",
"expressionSetLabel": "productQualification_usageType_3",
"sectionType": "ProductQualificationProcedure",
"sequence": 3,
"subSectionType": "Section2",
"usageType": "ProductQualification"
},
{
"expressionSetApiName": "rating_usageType_2",
"expressionSetDefinitionId": "9QAZ60000004EfHOAU",
"expressionSetLabel": "rating_usageType_2",
"sectionType": "RatingProcedure",
"sequence": 2,
"subSectionType": "Section3",
"usageType": "DefaultRating"
}
]
```

| Name | Type | Description | Filter Group and Version | Available Version |
| --- | --- | --- | --- | --- |
| expressionSetApiName | String | API name of the expression set. | Small, 62.0 | 62.0 |
| expressionSetDefinitionId | String | ID of the expression set definition. | Small, 62.0 | 62.0 |
| expressionSetLabel | String | Label of the expression set. | Small, 62.0 | 62.0 |
| readContextMapping | String | Mapping that’s used to read data from the mapped object and populate the context definition. | Small, 62.0 | 62.0 |
| saveContextMapping | String | Mapping that’s used to save data from the context definition and populate the mapped object. | Small, 62.0 | 62.0 |
| sectionType | String | Name of the evaluated section. Valid values are: - PricingProcedure - ProductDiscoveryProcedure - ProductQualificationProcedure - PricingDiscoveryProcedure - DiscountSpreadServiceProcedure - RatingProcedure - Custom | Small, 62.0 | 62.0 |

| Name | Type | Description | Filter Group and Version | Available Version |
| --- | --- | --- | --- | --- |
|  |  | - RatingDiscoveryProcedure |  |  |
| sequence | Integer | Sequence that’s followed for the processing of the procedures. | Small, 62.0 | 62.0 |
| subSectionType | String | Name of the evaluated subsection. | Small, 62.0 | 62.0 |
| usageType | String | Usage type of the procedure. | Small, 62.0 | 62.0 |

### Procedure Plan Evaluation

Output representation of the evaluation details of a procedure plan definition.

**JSON example**

```json
"procedurePlanEvaluations":[
{
"errorMessage":"",
"id":"a01DU000000BylcYAC",
"isSuccess":true,
"primaryObject":"SignallingCustomEvaluation__c",
"result":{
"contextDefinition":"11ODU00000008Sw2AI",
"procedurePlanSections":[]
}
}
]
```

| Name | Type | Description | Filter Group and Version | Available Version |
| --- | --- | --- | --- | --- |
| errorMessage | String | Message indicating the error details, if any. | Small, 62.0 | 62.0 |
| id | String | ID of the object used for evaluation. | Small, 62.0 | 62.0 |
| isSuccess | Boolean | Indicates whether the API request is successful (true) or not (false). | Small, 62.0 | 62.0 |
| primaryObject | String | Name of the object used for evaluation. | Small, 62.0 | 62.0 |
| result | Procedure Plan Evaluation Result [] | Results from the procedure plan evaluation. | Small, 62.0 | 62.0 |

### Procedure Plan Evaluation Response

Output representation of the evaluation details of a procedure plan definition.

**JSON example**

```json
{
  "isSuccess": true,
  "procedurePlanEvaluations": [
    {
      "errorMessage": "",
      "id": "a01DU000000BylcYAC",
      "isSuccess": true,
      "primaryObject": "SignallingCustomEvaluation__c",
      "result": {
        "contextDefinition": "11ODU00000008Sw2AI",
        "procedurePlanSections": []
      }
    }
  ]
}
```

| Name | Type | Description | Filter Group and Version | Available Version |
| --- | --- | --- | --- | --- |
| errorMessage | String | Message indicating the error details, if any. | Small, 62.0 | 62.0 |
| isSuccess | Boolean | Indicates whether the API request is successful (true) or not (false). | Small, 62.0 | 62.0 |
| procedurePlanDefinitionName | String | Name of the procedure plan definition. | Small, 62.0 | 62.0 |
| procedurePlanEvaluations | Procedure Plan Evaluation [] | Evaluation details of the procedure plan. | Small, 62.0 | 62.0 |

### Procedure Plan Evaluation Result

Output representation of the evaluation result of a procedure plan definition.

**JSON example**

```json
"result":{
"contextDefinition":"11ODU00000008Sw2AI",
"procedurePlanSections":[]
}
```

| Name | Type | Description | Filter Group and Version | Available Version |
| --- | --- | --- | --- | --- |
| contextDefinition | String | Context definition that’s associated with the procedure plan evaluation. | Small, 62.0 | 62.0 |
| procedurePlanSections | Procedure Plan Section Evaluation Runtime [] | Results from the procedure plan evaluation. | Small, 62.0 | 62.0 |

### Pricing Process Execution Details for Line Items

Output representation of the pricing process execution details for the line items along with the error details and response generation status.

**JSON example**

```json
{
  "error": {},
  "isSuccess": true,
  "lineItemDetailsList": [
    {
      "lineItemId": "LineItem1",
      "status": "Success"
    },
    {
      "lineItemId": "LineItem2",
      "status": "Success"
    },
    {
      "lineItemId": "LineItem3",
      "status": "Failure"
    }
  ]
}
```

| Name | Type | Description | Filter Group and Version | Available Version |
| --- | --- | --- | --- | --- |
| error | Pricing Error Response | Error encountered during the processing of the API request. | Small, 63.0 | 63.0 |
| isSuccess | Boolean | Indicates whether the response was generated successfully (true) or not (false). | Small, 63.0 | 63.0 |
| lineItemDetailsList | Line Item Details Response [] | List of the line items for which the pricing process is executed. | Small, 63.0 | 63.0 |

### Line Item Details Response

Output representation of the pricing process execution details for the line items.

**JSON example**

```json
{
  "lineItemDetailsList": [
    {
      "lineItemId": "LineItem1",
      "status": "Success"
    },
    {
      "lineItemId": "LineItem2",
      "status": "Success"
    },
    {
      "lineItemId": "LineItem3",
      "status": "Failure"
    }
  ]
}
```

| Name | Type | Description | Filter Group and Version | Available Version |
| --- | --- | --- | --- | --- |
| lineItemId | String | ID of the line item that the pricing process is executed for. | Small, 63.0 | 63.0 |
| status | String | Specifies whether the pricing process execution for the line item is successful or has failed. Valid values are: - Success - Failure | Small, 63.0 | 63.0 |

### Pricing Process Execution Response

Output representation of the details of a pricing process execution.

**JSON example**

```json
{
  "error": {},
  "isSuccess": true,
  "pricingProcessExecutionList": [
    {
      "executionId": "12345",
      "executionType": "Pricing_Line",
      "executionTypeId": "111_LineItem1",
      "message": "The Pricing API execution was successful.",
      "status": "Success"
    },
    {
      "executionId": "12345",
      "executionType": "Api_Execution",
      "executionTypeId": "333",
      "status": "Partial_Success"
    },
    {
      "executionId": "12345",
      "executionType": "Discovery",
      "executionTypeId": "222",
      "status": "Success"
    },
    {
      "executionId": "12345",
      "executionType": "Pricing",
      "executionTypeId": "111",
      "status": "Failure"
    },
    {
      "executionId": "12345",
      "executionType": "Discovery_Line",
      "executionTypeId": "222_LineItem1",
      "status": "Partial_Success"
    },
    {
      "executionId": "12345",
      "executionType": "Pricing_Line",
      "executionTypeId": "111_LineItem2",
      "status": "Failure"
    }
  ]
}
```

| Name | Type | Description | Filter Group and Version | Available Version |
| --- | --- | --- | --- | --- |
| error | Pricing Error Response | Error encountered during the processing of the API request. | Small, 63.0 | 63.0 |
| isSuccess | Boolean | Indicates whether the response was generated successfully (true) or not (false). | Small, 63.0 | 63.0 |
| pricingProcessExecutionList | Pricing Process Execution List [] | List of the execution details of the pricing process. | Small, 63.0 | 63.0 |

### Pricing Process Execution List

Output representation of the execution details for different types of the pricing processes.

**JSON example**

```json
{
  "pricingProcessExecutionList": [
    {
      "executionId": "12345",
      "executionType": "Pricing_Line",
      "executionTypeId": "111_LineItem1",
      "message": "The Pricing API execution was successful.",
      "status": "Success"
    },
    {
      "executionId": "12345",
      "executionType": "Api_Execution",
      "executionTypeId": "333",
      "status": "Success"
    },
    {
      "executionId": "12345",
      "executionType": "Discovery",
      "executionTypeId": "222",
      "status": "Success"
    },
    {
      "executionId": "12345",
      "executionType": "Pricing",
      "executionTypeId": "111",
      "status": "Failure"
    },
    {
      "executionId": "12345",
      "executionType": "Discovery_Line",
      "executionTypeId": "222_LineItem1",
      "status": "Success"
    },
    {
      "executionId": "12345",
      "executionType": "Pricing_Line",
      "executionTypeId": "111_LineItem2",
      "status": "Failure"
    }
  ]
}
```

| Name | Type | Description | Filter Group and Version | Available Version |
| --- | --- | --- | --- | --- |
| executionId | String | Unique ID that's generated each time a pricing process is executed. | Small, 63.0 | 63.0 |
| executionType | String | Type of the execution that's defined internally within the pricing API. | Small, 63.0 | 63.0 |
| executionTypeId | String | Unique execution type ID that's generated internally for process executions, such as pricing or discovery procedures. | Small, 63.0 | 63.0 |
| message | String | Message that's generated when a pricing process is executed. | Small, 63.0 | 63.0 |
| status | String | Execution process status for a line item. Valid values are: - Failure - Partial_Success —Applies to Pricing and Discovery procedures when execution for some line items fails. - Success | Small, 63.0 | 63.0 |

### Pricing Simulation Input Variables With Data

Output representation of the pricing simulation variables with data.

**JSON example**

```json
{
"error": "",
"simulationInputJsonWithData": "{\"SalesTransaction\": [{\"PriceBooks\":
\"01sxx0000005ptpAAA\",\"SalesTransactionItem\": [{\"LineItemQuantity\":
4,\"ProductSellingModel\": null,\"Product\": \"01txx0000006i2SAAQ\",\"LineItem\":
\"0QLxx0000004C92GAE\"},{\"LineItemQuantity\": 3,\"ProductSellingModel\":
null,\"Product\": \"01txx0000006i2TAAQ\",\"LineItem\": \"0QLxx0000004C93GAE\"}]}]}",
"success": true
}
```

| Name | Type | Description | Filter Group and Version | Available Version |
| --- | --- | --- | --- | --- |
| error | String | Returns the cause of error, if any. For a successful request, this API returns an empty string. | Small, 64.0 | 64.0 |
| simulationInputJsonWithData | String | Resultant simulation input variables with quote or order data such as ID, which was specified in the query parameters. | Small, 64.0 | 64.0 |
| success | Boolean | Indicates whether the request was successful (true) or not (false). | Small, 64.0 | 64.0 |

## Salesforce Pricing Apex Reference

Use built-in Apex classes and interfaces grouped by namespace.
- **RevSignaling Namespace**
The RevSignaling Namespace includes properties and methods to extend the standard procedure plan implementation through custom logic. Using this extension support, you can tailor implementations to your unique requirements.

**See also**

Apex Developer Guide: Getting Started with Apex

## RevSignaling Namespace

The RevSignaling Namespace includes properties and methods to extend the standard procedure plan implementation through custom logic. Using this extension support, you can tailor implementations to your unique requirements.

### Usage

To use this namespace, enable the Procedure Plan Orchestration for Pricing toggle from the Revenue Settings page from Setup.
