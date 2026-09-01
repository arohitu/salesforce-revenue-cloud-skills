# Salesforce Transaction Management Business API resources - detailed reference

Distilled from the source of truth: [docs/TXN Management APIs.md](../../../docs/TXN%20Management%20APIs.md).
Read the source doc for complete request/response schemas and nested representations.

Conventions:

- URL: `https://<instance>/services/data/v<version><resource>`. The "Available version"
  below is the minimum version the resource was introduced in; always call with the
  latest org version, never below v67.0 (the `--api-version` floor enforced by the script).
- Path tokens in `{braces}` are substituted at call time (script `--param key=value`).
- Query parameters are appended with the script `--query 'key=value&...'`.
- "Response body" names the Connect REST response representation documented in the source.
- Most POST bodies use an **object graph**: a `graph` (or `supplementalGraph`) with a
  `graphId` and a `records[]` array. Each record has `attributes` (`type` = sObject,
  `method` = `POST`/`PATCH`/`DELETE`, optional `id`, `action`, `criteria`) plus field
  values. Reference the id of an as-yet-uncreated record with `@{referenceId.id}`, and a
  group id with `{@GroupId}`.

---

## Asset actions

### 1. Asset Amendment - `POST /connect/revenue-management/assets/actions/amend`

- Description: Initiate and execute the amendment of a quote or an order (add/reduce
  quantity, change terms) from existing assets.
- Available version: 62.0
- Special access: `InitiateAmend` API permission set.
- Payload: [payloads/amend.json](../payloads/amend.json). Required: `assetIds[]`,
  `amendmentStartDate`, `outputRecordType`, `quantityChange`. Optional: `contractId`,
  `opportunityId`, `outputRecordId`.
- Response body: Amendment.
- Consideration: For **usage products**, set `outputRecordType` to `Quote` and use a
  two-step flow (create amendment quote, then create order from it). Direct-to-Order is
  not supported for usage assets.

### 2. Asset Cancellation - `POST /connect/revenue-management/assets/actions/cancel`

- Description: Initiate and execute the cancellation of an asset.
- Available version: 62.0
- Special access: `InitiateCancellation` API permission set.
- Payload: [payloads/cancel.json](../payloads/cancel.json). Required: `assetIds[]`,
  `cancellationDate`, `outputRecordType`. All assets in a request must belong to the same
  price book.
- Response body: Cancellation.

### 3. Asset Renewal - `POST /connect/revenue-management/assets/actions/renew`

- Description: Initiate and execute the renewal of an asset.
- Available version: 62.0
- Special access: `InitiateRenewal` API permission set.
- Payload: [payloads/renew.json](../payloads/renew.json). Required: `assetIds[]`,
  `outputRecordType`. Optional: `renewalStartDate`/`renewalEndDate` (start date required
  for early renewals and renewing expired assets), `contractId`, `opportunityId`,
  `outputRecordId`.
- Response body: Renewal.

### 4. Initiate Swap - `POST /revenue/transaction-management/assets/actions/swap`

- Description: Exchange one product for another (net-zero order total where applicable).
  Creates an amendment quote/order with swap-specific asset actions linking swapped-from
  and swapped-to assets.
- Available version: 66.0
- Payload: [payloads/swap.json](../payloads/swap.json). Required: `swapStartDate`,
  `outputRecordType`, `swapGroups` (each group has an `outGroup.swapAssets[]` and an
  `inGroup` object graph). Optional: `contractId`, `opportunityId`.
- Response body: Initiate Swap Response.

### 5. Initiate Upgrade - `POST /revenue/transaction-management/assets/actions/upgrade`

- Description: Move a lower-tier product to a higher-tier product. Tracked as an upgrade
  request with linked asset actions.
- Available version: 66.0
- Payload: [payloads/upgrade.json](../payloads/upgrade.json). Same shape as swap
  (`swapStartDate`, `outputRecordType`, `swapGroups`).
- Response body: Initiate Upgrade Response.

### 6. Initiate Downgrade - `POST /revenue/transaction-management/assets/actions/downgrade`

- Description: Move to a lower-tier or lower-value product. Tracked as a downgrade request
  with downgrade-specific asset actions.
- Available version: 66.0
- Payload: [payloads/downgrade.json](../payloads/downgrade.json). Same shape as swap.
- Response body: Initiate Downgrade Response.

---

## Sales transaction (quotes & orders)

### 7. Place Sales Transaction - `POST /connect/rev/sales-transaction/actions/place`

- Description: The primary entry point. Create a quote or an order with integrated pricing,
  configuration, and tax; update it; and insert/delete line items to calculate estimated
  tax.
- Available version: 63.0
- Payload: [payloads/place-sales-transaction.json](../payloads/place-sales-transaction.json).
  Key properties: `graph` (required if `contextDetails` is not given) or `contextDetails`
  (required if `graph` is not given); `pricingPref` (`Force`/`Skip`/`System`, default
  `System`); `taxPref` (`Skip`); `catalogRatesPref` (`Fetch`/`Skip`, default `Skip`);
  `configurationPref`; `groupRampAction` (group-ramp operations).
- Response body: Place Sales Transaction (runs asynchronously; see resource 10 for errors).
- Considerations: up to 1000 line items and 3000 line-item attributes per quote/order;
  does **not** create amendment/renewal/cancellation records (use resources 1-3); the
  quote header is committed first, so a later component failure does not roll it back;
  set `AssociatedQuantScaleMethod` = `Proportional` for predictable bundle-child quantity.

### 8. Place Order (deprecated) - `POST /commerce/sales-orders/actions/place`

- Description: Place/update orders with pricing, configuration, and validation. Max 300
  line items.
- Available version: 60.0. **Deprecated as of v63.0 - use Place Sales Transaction.**
- Special access: `PlaceOrder` API permission set.
- Payload: [payloads/place-order.json](../payloads/place-order.json)
  (`graph`, `pricingPref`, `configurationInput`, `configurationOptions`, `catalogRatesPref`).
- Response body: Place Order.

### 9. Place Quote (deprecated) - `POST /commerce/quotes/actions/place`

- Description: Create/update a quote and insert/update/delete quote line items. Max 300
  line items.
- Available version: 60.0. **Deprecated as of v63.0 - use Place Sales Transaction.**
- Special access: Create on Quotes user permission.
- Payload: [payloads/place-quote.json](../payloads/place-quote.json).
- Response body: Place Quote.

### 10. Retrieve Sales Transaction API Errors - `GET /connect/revenue/transaction-management/sales-transactions/actions/place/{trackerId}/errors`

- Description: Retrieve asynchronous error details (blocking errors and a retryable
  payload) for a Place Sales Transaction request. Does not return non-blocking warnings.
- Available version: 66.0
- Path token: `trackerId` (from the Place Sales Transaction response).
- Query (optional): `includeRetryablePayload` (`true`/`false`, default `false`).
- Response body: Sales Transaction Async Error (includes `rollbackedReferenceIds`).

### 11. Place Supplemental Transaction - `POST /connect/rev/sales-transaction/actions/place-supplemental-transaction`

- Description: Create a supplemental/change order after an order is submitted for
  processing (e.g. during fulfillment).
- Available version: 64.0
- Payload: [payloads/place-supplemental-transaction.json](../payloads/place-supplemental-transaction.json).
  Required: `relatedSalesTransactionId`. Optional: `pricingPref`, `supplementalGraph`
  (records must use `PATCH` with the original order/order-item `id`).
- Response body: Supplemental Transaction.
- Considerations: original order must not be assetized; if Billing is enabled, it must not
  be billed; if DRO is enabled, it must not have passed the point-of-no-return milestone.

### 12. Clone Sales Transaction - `POST /connect/rev/sales-transaction/actions/clone`

- Description: Clone a sales transaction or one of its records (Quote, QuoteLineItem,
  QuoteLineGroup, Order, OrderItem, OrderItemGroup) with related records and configurations.
- Available version: 64.0
- Payload: [payloads/clone.json](../payloads/clone.json). Required: `recordIds` (a single
  record id only) and `salesTransactionId`. Optional: `options.lineScope` = `AllLines`
  (clone all lines in the last ramp segment).
- Response body: Clone Sales Transaction.

### 13. Read Sales Transaction - `POST /connect/revenue/transaction-management/sales-transactions/actions/read`

- Description: Retrieve sales transaction data efficiently from an initialized or hydrated
  context.
- Available version: 65.0
- Payload: [payloads/read-sales-transaction.json](../payloads/read-sales-transaction.json).
  Required: `contextId`. Optional: `queryTags[]`, `sobjectFieldMap` (empty list = all
  fields), `filters[]`.
- Response body: Read Sales Transaction.

### 14. Instant Pricing - `POST /industries/cpq/quotes/actions/get-instant-price`

- Description: Fetch instant pricing on the quote/order line data grid and summary.
  Creates a context if `contextId` is omitted, or updates the existing one. Supports
  grouping of lines.
- Available version: 60.0
- Payload: [payloads/instant-pricing.json](../payloads/instant-pricing.json).
  Required: `records` (Object with Reference Input). Optional: `contextId`,
  `correlationId`. Grouping uses `QuoteLineGroup` records with `action` = `GroupBy` /
  `GroupAll` / `Ungroup` / `DeleteGroup`.
- Response body: Instant Pricing.

---

## Promotions

### 15. Create Promotions - `GET, POST, PUT /global-promotions-management/promotions`

- Description: Create/read/update promotions and rewards based on a product selling model
  template.
- Available version: 66.0
- Methods: `POST` (default), `GET`, `PUT` (use `--method`).
- Payload (POST/PUT): [payloads/create-promotion.json](../payloads/create-promotion.json)
  (`promotionDetails`, `rules[]`). See the Promotions Creation API reference for the full
  schema.

### 16. Get Eligible Promotions - `POST /revenue/transaction-management/sales-transactions/actions/get-eligible-promotions`

- Description: Get eligible promotions for specific line items in a quote or order. The
  object type is auto-determined from the sales transaction id.
- Available version: 66.0
- Payload: [payloads/eligible-promotions.json](../payloads/eligible-promotions.json).
  Required: `lineItemIds[]`, `salesTransactionId`.
- Response body: Get Eligible Promotions.

---

## Ramp deals (line ramps)

Ramp-deal create/update/delete return an updated **context and context id**. You must then
call **Place Sales Transaction** (resource 7) with that context id to persist the ramp
changes. These resources apply to **line ramps**; for **group ramps**, use Place Sales
Transaction with `groupRampAction` instead.

### 17. Create Ramp Deal - `POST /connect/revenue-management/sales-transaction-contexts/{resourceId}/actions/ramp-deal-create`

- Description: Create ramp segments for a term-defined product on a line.
- Available version: 62.0
- Path token: `resourceId` (quote line item, order item, or context id).
- Payload: [payloads/ramp-deal-create.json](../payloads/ramp-deal-create.json).
  Required: `transactionId`, `transactionLineId`, `subscriptionTerm`, `subscriptionTermUnit`
  (`MONTHS`), `segmentType` (`FREE_TRIAL`/`CUSTOM`/`YEARLY`). Optional: `trialTerm`,
  `trialTermUnit` (`DAYS`, required if `trialTerm` set), `executionSettings`.
- Response body: Ramp Deal Service.

### 18. Update Ramp Deal - `POST /connect/revenue-management/sales-transaction-contexts/{resourceId}/actions/ramp-deal-update`

- Description: Modify ramp segments (quantity, discount, or dates), or add/delete custom
  segments.
- Available version: 62.0
- Path token: `resourceId` (context id).
- Payload: [payloads/ramp-deal-update.json](../payloads/ramp-deal-update.json).
  Required: `addedNodes`, `updatedNodes`, `deletedNodes` (each a Context Node with a
  `contextNodePath` of `[contextId, transactionId, lineId]`). Optional: `executionSettings`.
- Response body: Ramp Deal Service.

### 19. Delete Ramp Deal - `POST /connect/revenue-management/sales-transaction-contexts/{resourceId}/actions/ramp-deal-delete`

- Description: Delete ramp segments to convert a ramped product back to a single line.
- Available version: 62.0
- Path token: `resourceId` (context id).
- Payload: [payloads/ramp-deal-delete.json](../payloads/ramp-deal-delete.json).
  Required: `rampDealIds[]`.
- Response body: Ramp Deal Service.

### 20. View Ramp Deal - `GET /connect/revenue-management/sales-transaction-contexts/{resourceId}/actions/ramp-deal-view`

- Description: View the ramp segments for a quote line item or order item.
- Available version: 62.0
- Path token: `resourceId` (quote line item, order item, or context id).
- Query (required): `transactionId`, `transactionLineId`.
- Response body: Ramp Deal Service.

---

## Object graph reference-resolution cheatsheet

- `attributes.type` - the sObject API name (e.g. `Quote`, `QuoteLineItem`,
  `QuoteLineItemAttribute`, `Order`, `OrderItem`, `OrderItemGroup`, `QuoteLineGroup`,
  `QuoteLineRelationship`).
- `attributes.method` - `POST` (insert), `PATCH` (update, needs `id`), `DELETE`
  (needs `id`).
- `@{referenceId.id}` - resolves to the id of another record created in the same request.
- `attributes.action` + `criteria` - grouping operations on group sObjects
  (`GroupBy`, `GroupAll`, `Ungroup`, `DeleteGroup`).
- Sample ids in `payloads/*.json` are placeholders - replace them with real org ids
  before calling a live org.
