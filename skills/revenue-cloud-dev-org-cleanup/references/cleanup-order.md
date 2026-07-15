# Cleanup Order

Use this reference when the user wants a Revenue Cloud dev org reset or a
product purge that must avoid dependency failures.

## Phase 0: Status changes before delete

Some Revenue Cloud objects reject deletion while still active. Change status
first, then delete.

- `Order.Status -> Draft`
- `UsageResourceBillingPolicy.Status -> Draft`
- `UsageResource.Status -> Draft`
- `ProductUsageGrant.Status -> Draft`
- `ProductUsageResource.Status -> Inactive`

## Phase 1: Remove transactional and product-structure children

Delete low-level records before parent commercial records and products.

1. `QuoteLineItem`
2. `OpportunityLineItem`
3. `Quote`
4. `Opportunity`
5. `ProductRelComponentOverride`
6. `ProductComponentGrpOverride`
7. `ProductRelatedComponent`
8. `ProductComponentGroup`
9. `AttributeBasedAdjRule`
10. `ProductAttributeDefinition`
11. `ProductQualification`
12. `ProductDisqualification`
13. `ProductCategoryProduct`
14. `PriceAdjustmentTier`
15. `PriceAdjustmentSchedule`
16. `PriceBookEntryDerivedPrice`
17. `RateCardEntry`
18. `UsageEntitlementEntry`
19. `ProductUsageResourcePolicy`
20. `UsageResourcePolicy`

## Phase 2: Remove usage-management records

These records often block order-item, price-book-entry, or product deletion.

1. `ProductUsageGrant`
2. `ProductUsageResource`
3. `UsageResourceBillingPolicy`
4. `UsageResource`
5. `UsageEntitlementBucket`
6. `TransactionUsageEntitlement`
7. `UsageEntitlementAccount`
8. `AssetActionSource` (best effort only; some orgs block delete access)

## Phase 3: Remove commercial parents and catalog roots

1. `OrderItem`
2. `Order`
3. `PricebookEntry`
4. `ProductSellingModelOption`
5. `Product2`

## Phase 4: Optional account cleanup

Only attempt this when the user explicitly wants broader cleanup beyond product
purge:

1. `Account`

`Account` deletion is commonly blocked by portal users, cases, entitlements, or
other service-management records. These blocks are usually not required to
clear `Product2`.

## Retry Rules

- Run the cleanup in multiple passes until `Product2` reaches zero or no more
  progress is made.
- Usage-entitlement records can form parent-child chains. A first delete pass
  often clears children so the next pass can remove parents.
- Do not fail the whole cleanup just because `AssetActionSource`,
  `UsageResource`, or `UsageResourceBillingPolicy` still have protected records
  after `Product2` is already zero.

## Common Blocker Patterns

- `OrderItem` fails because the parent `Order` is activated. Update
  `Order.Status` to `Draft` first.
- `ProductSellingModelOption` fails while an active `PricebookEntry` still
  exists for the same product/selling-model combination.
- `PricebookEntry` fails while archived order history still references the
  product. Delete `OrderItem` and `Order` first.
- `ProductAttributeDefinition` can fail if price-impacting attributes are still
  tied to `AttributeBasedAdjRule`. Delete the adjustment rules first.
- `Product2` can still delete successfully even if some protected usage records
  remain, as long as the direct product blockers are gone.
