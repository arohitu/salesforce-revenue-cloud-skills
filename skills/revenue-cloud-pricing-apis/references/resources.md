# Salesforce Pricing Business API resources - detailed reference

Distilled from the source of truth: [docs/Pricing API.md](../../../docs/Pricing%20API.md).
Read the source doc for complete request/response schemas and nested representations.

Conventions:

- URL: `https://<instance>/services/data/v<version><resource>`. The "Available version"
  below is the minimum version the resource was introduced in; always call with the
  latest org version, never below v67.0 (the `--api-version` floor enforced by the script).
- Path tokens in `{braces}` are substituted at call time (script `--param key=value`).
- Query parameters are appended with the script `--query 'key=value&...'`.
- "Response body" names the Connect REST response representation documented in the source.
- `pricingSyncOrigin`, `pricingUsageSubType`, `executionType`, `processType`, and
  `sectionType` values must match the picklist entries documented in the source doc.

---

## Core pricing

### 1. Pricing - `POST /connect/core-pricing/pricing`

- Description: Create and hydrate a context instance in a single request and return final
  pricing per line item plus any errors. This is the primary "price a cart" entry point.
- Available version: 60.0
- Payload: [payloads/pricing.json](../payloads/pricing.json)
- Response body: Pricing Output (`apiExecutionId`, `pricingExecutionId`, `pricingResult`,
  `pricingResultErrors`, `status`).

Key request properties:

| Name | Type | Required | Notes |
| --- | --- | --- | --- |
| contextDefinitionId | String | Required | Structure of the input data. |
| contextMappingId | String | Required | Maps input data to the context instance. |
| jsonDataString | String | Required | Context data as JSON. Keys must match the context mapping; each node needs `businessObjectType` set to the mapped sObject. Send it stringified (see gotchas). |
| pricingProcedureId | String | Optional | ID or API name of the pricing procedure (an Expression Set Definition). Experience Cloud users pass the name. |
| configurationOverrides | Configuration Override Input | Optional | See below. |

`status` values: `Completed`, `Partially Completed`, `Failed`.

### 2. Price Context - `POST /connect/core-pricing/price-contexts/{contextId}`

- Description: Price against an already-created context instance ID.
- Available version: 60.0
- Path token: `contextId` = the context instance ID returned when the context was created.
- Payload: [payloads/price-context.json](../payloads/price-context.json)
  (`configurationOverrides`, `procedureName`).
- Response body: Pricing Response (`success`, `executionId`, `error`).

### 3. PBE Derived Pricing - `POST /connect/core-pricing/pbeDerivedPricingSourceProduct`

- Description: Get the source product for Price Book Entry (PBE) derived pricing.
- Available version: 61.0
- Payload: [payloads/pbe-derived-pricing.json](../payloads/pbe-derived-pricing.json)
  (`productId`, `pricebookEntryId`, `effectiveFrom`, `effectiveTo` - all required).
- Response body: PBE Derived Pricing (`sourceProceductId`, `isSuccess`, `error`).

### 4. Pricing Data Sync - `GET /connect/core-pricing/sync/{pricingSyncOrigin}`

- Description: Sync pricing data so lookup (decision) tables contain the latest data.
- Available version: 60.0
- Path token: `pricingSyncOrigin` (e.g. `syncData`).
- Query (optional): `pricingRecipeId` - sync only that recipe's decision tables; omit for
  the default recipe.
- Response body: Pricing Generic Response (`success`, `error`).

### 5. Pricing Recipe - `GET /connect/core-pricing/recipe`

- Description: Get pricing recipes and their mapped decision tables.
- Available version: 60.0
- Response body: Pricing Recipe Response (`recipes[]`, `success`).

### 6. Pricing Recipe Valid Elements - `GET /connect/core-pricing/revenue/pricing-recipe/valid-elements`

- Description: List valid pricing element type API names for a Pricing Usage Sub Type.
- Available version: 68.0
- Query (required): `pricingUsageSubType` (e.g. `RevenueCloud`, `Loyalty`, `LifeSciences`,
  `Commercial`).
- Response body: Pricing Recipe Valid Elements (`validPricingElements`, `isSuccess`,
  `errorMessage`).

### 7. Pricing Recipe Clone - `POST /connect/core-pricing/revenue/pricing-recipe/clone`

- Description: Clone a pricing recipe with all its decision table mappings.
- Available version: 68.0
- Payload: [payloads/recipe-clone.json](../payloads/recipe-clone.json) (`recordId`,
  `newPricingRecipeApiName`, `newPricingRecipeName` required; `pricingUsageSubType` optional).
- Response body: Pricing Recipe Clone (`isSuccess`, `newPricingRecipeId`,
  `newPricingRecipeName`, `error`).

### 8. Pricing Recipe Mapping - `POST /connect/core-pricing/recipe/mapping`

- Description: Map a pricing recipe to decision tables and/or a procedure.
- Available version: 60.0
- Payload: [payloads/recipe-mapping.json](../payloads/recipe-mapping.json) (`recipeId`,
  `pricingRecipeLookUpTableInputRepresentations[]`, `pricingRecipeProcedureInputRepresentation`).
- Response body: Pricing Recipe Post (`isSuccess`, `error`).

### 9. Pricing Versioned Revision Details - `POST /connect/core-pricing/versioned-revise-details`

- Description: Create versioned revisions of adjustment entities
  (`AttributeBasedAdjustment`, `BundleBasedAdjustment`).
- Available version: 60.0
- Payload: [payloads/versioned-revise-details.json](../payloads/versioned-revise-details.json).
- Response body: Pricing Versioned Revision Details (`success`, `error`).

### 10. Pricing Waterfall - `GET /connect/core-pricing/waterfall/{lineItemId}/{executionId}`

- Description: Get the persisted price waterfall (step-by-step pricing process log).
  Requires price waterfall persistence enabled in Salesforce Pricing Setup.
- Available version: 60.0
- Path tokens: `lineItemId`, `executionId`.
- Response body: Pricing Waterfall Response / Line Item Waterfall Response.

### 11. Pricing Waterfall - `POST /connect/core-pricing/waterfall`

- Description: Create a price waterfall (explainability action) log.
- Available version: 60.0
- Payload: [payloads/waterfall.json](../payloads/waterfall.json) (`executionId`,
  `lineItemId`, `waterfall[]` required; `currencyCode`, `output`, timestamps optional).
- Response body: Pricing Waterfall Response.

### 12. API Execution Logs - `GET /connect/core-pricing/apiexecutionlogs/{executionId}`

- Description: Get log details of a pricing API execution record.
- Available version: 63.0
- Path token: `executionId` (the `apiExecutionId` from a Pricing Output).
- Response body: Pricing Execution Waterfall Response.

### 13. Pricing Process Execution - `GET /connect/core-pricing/pricing-process-execution/{executionId}`

- Description: Get execution details of a pricing process.
- Available version: 63.0
- Path token: `executionId` (the `pricingExecutionId` from a Pricing Output).
- Query (optional): `executionType` - one of `API_Execution`, `Discovery`,
  `Discovery_Line`, `Pricing`, `Pricing_Line`. Omit to return all types.
- Response body: Pricing Process Execution Response.

### 14. Pricing Process Execution for Line Items - `GET /connect/core-pricing/pricing-process-execution/lineitems/{executionId}/{executionType}`

- Description: Get pricing execution details for the line items of a pricing process.
- Available version: 63.0
- Path tokens: `executionId`, `executionType` (one of `Pricing_Line`, `Discovery_Line`).
- Response body: Pricing Process Execution Details for Line Items.

### 15. Pricing Simulation Input Variables With Data - `GET /connect/core-pricing/simulationInputVariablesWithData`

- Description: Get pricing simulation input variables plus associated data.
- Available version: 60.0
- Response body: Pricing Simulation Input Variables With Data.

---

## Procedure plan definitions

Use procedure plan definitions to centralize pricing-process criteria and to orchestrate
which procedures run. Requires the **Procedure Plan Orchestration for Pricing** toggle
(Revenue Settings). Custom orchestration extensions use the Apex `RevSignaling` namespace.

### 16. Procedure Plan Definitions - `GET, POST /connect/procedure-plan-definitions`

- Description: List procedure plan definitions (GET) or create one (POST).
- Available version: 62.0
- POST payload: [payloads/procedure-plan-definition.json](../payloads/procedure-plan-definition.json).
- Response body: Procedure Plan Definitions / Procedure Plan Generic.

### 17. Procedure Plan Definition By ID - `GET, PATCH, DELETE /connect/procedure-plan-definitions/{procedurePlanDefinitionId}`

- Description: Get, update, or delete a procedure plan definition by record ID.
- Available version: 62.0
- Path token: `procedurePlanDefinitionId`.
- Note: On PATCH, properties omitted from the body are deleted from the record.
- Response body: Procedure Plan Definition / Procedure Plan Generic.

### 18. Procedure Plan Evaluation By Object - `POST /connect/procedure-plan-definitions/evaluate`

- Description: Evaluate definitions by primary object to check prerequisites (usage type,
  context mapping).
- Available version: 62.0
- Payload: [payloads/procedure-plan-evaluate.json](../payloads/procedure-plan-evaluate.json)
  (`idList` required for this variant, `evaluationDate` required).
- Response body: Procedure Plan Evaluation Response.

### 19. Procedure Plan Evaluation By Definition Name - `POST /connect/procedure-plan-definitions/evaluate/{procedurePlanDefinitionName}`

- Description: Evaluate a single definition by name.
- Available version: 62.0
- Path token: `procedurePlanDefinitionName`.
- Payload: [payloads/procedure-plan-evaluate-by-name.json](../payloads/procedure-plan-evaluate-by-name.json)
  (no `idList`).
- Response body: Procedure Plan Evaluation Response.

### 20. Procedure Plan Version - `POST /connect/procedure-plan-definitions/{procedurePlanDefinitionId}/version`

- Description: Create a procedure plan version with sections, options, and criteria.
- Available version: 62.0
- Path token: `procedurePlanDefinitionId`.
- Payload: [payloads/procedure-plan-version.json](../payloads/procedure-plan-version.json).
- Response body: Procedure Plan Definition Version / Procedure Plan Generic.

### 21. Procedure Plan Version Details - `GET, PATCH, DELETE /connect/procedure-plan-definitions/versions/{procedurePlanVersionId}`

- Description: Get, update, or delete a procedure plan version by record ID.
- Available version: 62.0
- Path token: `procedurePlanVersionId`.
- Note: You cannot edit or delete an active version. On PATCH, omitted properties are deleted.
- Response body: Procedure Plan Definition Version / Procedure Plan Generic.

---

## Configuration Override Input

Passed as `configurationOverrides` in the Pricing and Price Context requests.

| Name | Type | Description | Version |
| --- | --- | --- | --- |
| skipWaterfall | Boolean | Skip price waterfall in the response. | 60.0 |
| useSessionScopedContext | Boolean | Create a session-scoped context (true) vs request-scoped (false, default). | 60.0 |
| persistContext | Boolean | Persist the context per the mapping. Requires edit access to all mapped sObject fields. | 60.0 |
| taggedData | Boolean | The `jsonDataString` uses tags instead of attributes. | 60.0 |
| displayContext | Boolean | Return the context structure for pricing. | 61.0 |
| discoveryProcedure | String | Discovery procedure name used to fetch asset details. | 61.0 |
| skipDiscovery | Boolean | Skip the discovery procedure. | 61.0 |
| referenceKey | String | Reference ID for locating logs in the Pricing Operations Console. | 63.0 |
| isHighVolumeLineItems | Boolean | Return pricing for more than 100 line items. | 63.0 |
