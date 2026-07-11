# Product Configurator API resources - detailed reference

Distilled from the source of truth:
[output-md/Product Configurator APIs.md](../../../../output-md/Product%20Configurator%20APIs.md).
Read the source doc for complete request/response schemas and nested representations.

Conventions:
- All resources use HTTP **POST**.
- URL: `https://<instance>/services/data/v<version><resource>`. The "Available version"
  below is the minimum version the resource was introduced in; always call with the
  latest org version and never below v67.0.
- "Response body" names the Connect REST response representation documented in the source.

---

## 1. Configuration - `/connect/cpq/configurator/actions/configure`

- Description: Retrieve and update a product's configuration from a configurator. Execute
  configuration rules and notify users of violations for changes to product bundle,
  attributes, or product quantity within a bundle. Also returns pricing for the bundle.
- Resource example: `.../services/data/v67.0/connect/cpq/configurator/actions/configure`
- Available version: 60.0
- Payload: [payloads/configure.json](../payloads/configure.json)
- Response body: Configuration Details

Request example (initiate a context from a transaction ID):

```json
{
  "transactionLineId": "0QLDE000000IBXw4AO",
  "transactionId": "0Q0xx0000000001GAA",
  "correlationId": "c95246d4-102c-4ecd-a263-f74ac525d1e5",
  "configuratorOptions": { "executePricing": true, "returnProductCatalogData": true },
  "qualificationContext": { "accountId": "001xx0000000001AAA", "contactId": "003xx00000000D7AAI" }
}
```

The resource also accepts `addedNodes`, `updatedNodes`, `deletedNodes`,
`transactionContextId`, and `contextResponseType` to add/update/delete nodes in an
existing context (see source doc for the full example).

Properties:

| Name | Type | Description | Required/Optional | Version |
| --- | --- | --- | --- | --- |
| addedNodes | Configurator Added Node Input[] | List of added context nodes passed to the configurator. | Optional | 60.0 |
| configuratorOptions | Configurator Options Input[] | Options to pass to the configurator. | Optional | 60.0 |
| contextResponseType | String | Type of transaction context response: `Delta`, `Full`, `None`, `Product`. | Required for large sales transactions (>1000 and <15K line items) | 65.0 |
| correlationId | String | ID specified for traceability of logs. | Optional | 60.0 |
| deletedNodes | Configurator Deleted Node Input[] | List of deleted context nodes. | Optional | 60.0 |
| qualificationContext | User Context Input[] | Account ID, contact ID, and context ID used for qualification rules. | Optional | 60.0 |
| transactionContextId | String | ID of the transaction context. | Optional | 60.0 |
| transactionId | String | ID of the sales transaction being configured (Quote/Order). | Required | 60.0 |
| transactionLineId | String | ID of the top-level line item being configured. | Optional | 60.0 |
| updatedNodes | Configurator Updated Node Input[] | List of updated context nodes. | Optional | 60.0 |

---

## 2. Configuration Load Instance - `/connect/cpq/configurator/actions/load-instance`

- Description: Create a session for the configuration instance using the transaction ID.
  Returns a session ID that includes results of configuration rules, qualification rules,
  and pricing management.
- Resource example: `.../services/data/v67.0/connect/cpq/configurator/actions/load-instance`
- Available version: 60.0
- Payload: [payloads/load-instance.json](../payloads/load-instance.json)
- Response body: Configuration Load Instance

Properties:

| Name | Type | Description | Required/Optional | Version |
| --- | --- | --- | --- | --- |
| configuratorOptions | Configurator Options Input | List of configurator options to execute. | Optional | 60.0 |
| contextMappingId | String | ID of the context mapping record. | Optional | 60.0 |
| qualificationContext | User Context Input | Context details used for qualification rules. | Optional | 60.0 |
| transactionId | String | Transaction ID of the header entity used to create a session (e.g. Quote/Order). | Required | 60.0 |

---

## 3. Configuration Set Instance - `/connect/cpq/configurator/actions/set-instance`

- Description: Set a product configuration instance. Used when the configuration instance
  is in a different database than Salesforce while product catalog management data is in
  Salesforce.
- Resource example: `.../services/data/v67.0/connect/cpq/configurator/actions/set-instance`
- Available version: 60.0
- Payload: [payloads/set-instance.json](../payloads/set-instance.json)
- Response body: Configuration Set Instance

Properties:

| Name | Type | Description | Required/Optional | Version |
| --- | --- | --- | --- | --- |
| configuratorOptions | Configurator Options Input | List of configurator options to execute. | Optional | 60.0 |
| contextMappingId | String | ID of the context mapping record. | Required | 60.0 |
| qualificationContext | User Context Input | Context details used for qualification rules. | Optional | 60.0 |
| transaction | String | Transaction JSON payload representing an object in an external system, used to create a session. | Required | 60.0 |

---

## 4. Configuration Get Instance - `/connect/cpq/configurator/actions/get-instance`

- Description: Fetch the JSON representation of a product configuration to display in the
  Salesforce UI or save to an external system.
- Resource example: `.../services/data/v67.0/connect/cpq/configurator/actions/get-instance`
- Available version: 60.0
- Payload: [payloads/get-instance.json](../payloads/get-instance.json)
- Response body: Configuration Get Instance

Properties:

| Name | Type | Description | Required/Optional | Version |
| --- | --- | --- | --- | --- |
| contextId | String | Transaction context ID of the configuration instance to fetch. | Required | 60.0 |

---

## 5. Configuration Save Instance - `/connect/cpq/configurator/actions/save-instance`

- Description: Save a configuration instance after a successful product configuration
  (e.g. save changes to the quote line item used to load the configuration).
- Resource example: `.../services/data/v67.0/connect/cpq/configurator/actions/save-instance`
- Available version: 60.0
- Payload: [payloads/save-instance.json](../payloads/save-instance.json)
- Response body: Configuration Save Instance

Properties:

| Name | Type | Description | Required/Optional | Version |
| --- | --- | --- | --- | --- |
| contextId | String | Transaction context ID of the configuration instance to save. | Required | 60.0 |

---

## 6. Product Set Quantity - `/connect/cpq/configurator/actions/set-product-quantity`

- Description: Set the quantity of a product through the runtime system.
- Resource example: `.../services/data/v67.0/connect/cpq/configurator/actions/set-product-quantity`
- Available version: 60.0
- Payload: [payloads/set-product-quantity.json](../payloads/set-product-quantity.json)
- Response body: Product Quantity Set Configurator

Properties:

| Name | Type | Description | Required/Optional | Version |
| --- | --- | --- | --- | --- |
| configuratorOptions | Configurator Options Input | List of configuration options to execute. | Optional | 60.0 |
| contextId | String | ID of the context object being considered. | Required | 60.0 |
| qualificationContext | User Context Input | Context details used for qualification rules. | Optional | 60.0 |
| quantity | Integer | Value of the product quantity. | Required | 60.0 |
| transactionLinePath | String[] | Path to the line item where the quantity update is applied (e.g. `Quote.QuoteLineItem.Quantity`). | Required | 60.0 |

---

## 7. Configurator Add Nodes - `/connect/cpq/configurator/actions/add-nodes`

- Description: Add a node to the context through the runtime system without using the
  Salesforce UI.
- Resource example: `.../services/data/v67.0/connect/cpq/configurator/actions/add-nodes`
- Available version: 60.0
- Payload: [payloads/add-nodes.json](../payloads/add-nodes.json)
- Response body: Configurator Add Nodes

Properties:

| Name | Type | Description | Required/Optional | Version |
| --- | --- | --- | --- | --- |
| addedNodes | Configurator Added Node Input[] | List of the nodes to be added. | Required | 60.0 |
| configuratorOptions | Configurator Options Input | List of the configuration options to execute. | Optional | 60.0 |
| contextId | String | ID of the context object being considered. | Required | 60.0 |
| qualificationContext | User Context Input | Context details used for qualification rules. | Optional | 60.0 |

---

## 8. Configurator Update Nodes - `/connect/cpq/configurator/actions/update-nodes`

- Description: Update nodes in a product configuration.
- Resource example: `.../services/data/v67.0/connect/cpq/configurator/actions/update-nodes`
- Available version: 60.0
- Payload: [payloads/update-nodes.json](../payloads/update-nodes.json)
- Response body: Configurator Update Nodes

Properties:

| Name | Type | Description | Required/Optional | Version |
| --- | --- | --- | --- | --- |
| configuratorOptions | Configurator Options Input | List of the configuration options to execute. | Optional | 60.0 |
| contextId | String | ID of the context object being considered. | Required | 60.0 |
| qualificationContext | User Context Input | Context details used for qualification rules. | Optional | 60.0 |
| updatedNodes | Configurator Updated Node Input[] | List of the nodes to be updated. | Required | 60.0 |

---

## 9. Configurator Delete Nodes - `/connect/cpq/configurator/actions/delete-nodes`

- Description: Delete nodes from a product configuration.
- Resource example: `.../services/data/v67.0/connect/cpq/configurator/actions/delete-nodes`
- Available version: 60.0
- Payload: [payloads/delete-nodes.json](../payloads/delete-nodes.json)
- Response body: Configurator Delete Nodes

Properties:

| Name | Type | Description | Required/Optional | Version |
| --- | --- | --- | --- | --- |
| configuratorOptions | Configurator Options Input | List of the configuration options to execute. | Optional | 60.0 |
| contextId | String | ID of the context object being considered. | Required | 60.0 |
| deletedNodes | Configurator Deleted Node Input[] | List of the nodes to be deleted. | Required | 60.0 |
| qualificationContext | User Context Input | Context details used for qualification rules. | Optional | 60.0 |

---

## 10. Config Rules - `/revenue/product-configurator/rules/actions/execute`

- Description: Run rules for a specific quote or order based on a context ID or
  transaction ID.
- Resource example: `.../services/data/v67.0/revenue/product-configurator/rules/actions/execute`
- Available version: 67.0
- Payload: [payloads/execute-rules.json](../payloads/execute-rules.json)
- Response body: Configuration Rule Response

Properties:

| Name | Type | Description | Required/Optional | Version |
| --- | --- | --- | --- | --- |
| ruleOptions | Config Rule Options Input[] | Options to run specific steps in rules. | Optional | 67.0 |
| transactionContextId | String | ID of the sales transaction context instance. | Required if `transactionId` isn't specified. | 67.0 |
| transactionId | String | ID of the quote or order. | Required if `transactionContextId` isn't specified. | 67.0 |
