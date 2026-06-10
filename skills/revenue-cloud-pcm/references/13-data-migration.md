# PCM Data Migration

Use this reference when exporting or loading Revenue Cloud PCM master data for a catalog, bundle product list, or sandbox-to-sandbox migration.

## Accepted inputs

Support either input mode:

1. **Catalog input** — catalog name, code, or id. Resolve the catalog, then collect `ProductCategory` and `ProductCategoryProduct` records to find directly assigned products.
2. **Bundle product input** — one or more `Product2` ids/codes/names where `Type = 'Bundle'`. Treat these products as the starting roots even if no catalog was provided.

Always record the input mode in the migration manifest.

## First step: inspect the org schema

Do not assume exact API names from generic docs. Before writing SOQL or load payloads:

1. Run describes for all PCM objects in scope.
2. Confirm whether the catalog object is `ProductCatalog` or `Catalog`. In Revenue Cloud orgs, prefer `ProductCatalog` when available.
3. Confirm the parent lookup on `AttributePicklistValue`. Some orgs expose `PicklistId`; others may expose `AttributePicklistId`.
4. Drop or remap fields that are not createable/updateable in the target org.

## Bundle graph expansion

Starting from catalog products or supplied bundle products:

1. Query `ProductRelatedComponent WHERE ParentProductId IN (...)`.
2. Add every `ChildProductId` as a child product.
3. Add every `ChildProductClassificationId` as a dynamic child classification.
4. Add each `ProductComponentGroupId` and `ProductRelationshipTypeId`.
5. If any child product is also `Type = 'Bundle'`, recurse by querying its `ProductRelatedComponent` rows.
6. Continue until no new parent bundle products are discovered.

`ProductRelatedComponent` can point to either a concrete product or a classification. Do not require both:

```sql
SELECT Id, ParentProductId, ChildProductId, ChildProductClassificationId,
       ProductComponentGroupId, ProductRelationshipTypeId,
       Quantity, MinQuantity, MaxQuantity, Sequence,
       IsComponentRequired, IsDefaultComponent, IsQuantityEditable,
       QuoteVisibility
FROM ProductRelatedComponent
WHERE ParentProductId IN :bundleProductIds
```

## Classification expansion

Include classifications from both sources:

- `Product2.BasedOnId` for every exported product.
- `ProductRelatedComponent.ChildProductClassificationId` for dynamic bundle options.

Then include related records:

- `ProductClassification`
- `ProductClassificationParent`, if the org exposes it
- `ProductClassificationAttr`
- attribute definitions and picklist data referenced by those classification attributes

## Attribute objects

For migration packages, attribute foundation records are often shared master data rather than strictly catalog-only data.

Recommended default:

- Export the reusable foundation set:
  - `AttributeDefinition`
  - `AttributePicklist`
  - `AttributePicklistValue`
  - `AttributeCategory`
  - `AttributeCategoryAttribute`
- Export scoped attach/override rows only when their owner is in the package:
  - `ProductClassificationAttr` for exported classifications
  - `ProductAttributeDefinition` only when its `Product2Id` is an exported product
  - `AttrPicklistExcludedValue` only when its `AttributeId` points to an exported `ProductClassificationAttr` or exported `ProductAttributeDefinition`

If `ProductAttributeDefinition` rows exist but their products are outside the migration product set, do not load them. Either expand the product set first or document them as out of scope.

## Catalog and category records

For catalog input:

1. Export the resolved `ProductCatalog`/`Catalog` record.
2. Export all `ProductCategory` rows under the catalog, preserving `ParentCategoryId`.
3. Export `ProductCategoryProduct` rows for those categories.

For bundle-only input:

- Do not invent catalog/category records.
- Export product and bundle structure records only, unless the user also asks to attach them to a catalog.

## Related product records

For every exported product, include:

- `Product2`
- `ProductSellingModelOption`
- `ProductRampSegment`, if present
- `ProductQualification` / `ProductDisqualification`, if present
- bundle rows where the product is a parent or child and belongs to the expanded graph

Do not include pricing math, price books, rate cards, quote/order lines, billing, or assets unless the user explicitly switches to an adjacent module.

## CSV design for remapping

Every CSV should keep the source `Id` and add helper business-key columns for VLOOKUP/remapping. Common helper columns:

- catalog: source id, `Name`, `Code`
- category: category `Code`/`Name`, parent category `Code`/`Name`, catalog `Code`/`Name`
- product: `ProductCode`, `Name`, classification `Code`/`Name`
- classification: `Code`, `Name`
- attribute: `Name`, `Label`, picklist `Name`, category `Code`/`Name`
- bundle: parent product code/name, child product code/name, child classification code/name, component group name/code, relationship type name/code
- selling model: selling model `Name`, product code/name

Never rely on source Salesforce ids as the final target lookup values. Use them only as local source keys for generated mapping files.

## Dependency load order

Use this order as the default target load sequence. Skip objects with no CSV rows or unsupported target schema.

1. `ProductCatalog` / `Catalog`
2. `AttributePicklist`
3. `AttributeCategory`
4. `ProductClassification`
5. `ProductClassificationParent`
6. `ProductSellingModel`
7. `AttributePicklistValue`
8. `AttributeDefinition`
9. `AttributeCategoryAttribute`
10. `ProductCategory`
11. `ProductClassificationAttr`
12. `Product2`
13. `ProductAttributeDefinition`
14. `AttrPicklistExcludedValue`
15. `ProductRelationshipType`
16. `ProductComponentGroup`
17. `ProductRelatedComponent`
18. `ProductComponentGrpOverride`
19. `ProductRelComponentOverride`
20. `ProductSellingModelOption`
21. `ProductRampSegment`
22. `ProductQualification`
23. `ProductDisqualification`
24. `ProductCategoryQualification`
25. `ProductCategoryDisqual`
26. `ProductCategoryProduct`

Self-referential objects may need multiple passes:

- `ProductCategory.ParentCategoryId`
- `ProductClassificationParent`
- `ProductComponentGroup.ParentGroupId`
- `ProductAttributeDefinition.OverriddenProductAttributeDefinitionId`

## Target load contingency

Generated migration folders must be self-contained after export. A target load should not need source org access.

Required package artifacts:

- raw CSVs
- manifest with source org, input mode, record counts, and export timestamp
- analyzed load order
- object/attribute coverage notes
- local source-id to target-id mapping state
- error reports for failed rows
- manual reference override template for org-specific lookups

Common org-specific lookups to document or map manually:

- `RecordTypeId`
- `OwnerId`
- `TaxPolicyId`
- `UnitOfMeasureId`
- `ProrationPolicyId`
- any custom lookup fields on `Product2`

If a load fails, fix the CSV or mapping file and resume from the saved checkpoint. Do not re-export from source unless the package is incomplete.

## Script interface guidance

For real migrations, prefer reusable scripts over ad hoc SOQL and hand-edited CSVs.

Recommended export script interface:

```bash
python3 scripts/export-pcm-migration.py \
  --target-org <source-alias> \
  --out-dir <migration-folder> \
  [--catalog-name <name> | --catalog-id <id> | --catalog-code <code> | --bundle-product-id <id> | --bundle-product-code <code>]
```

Recommended load script interface:

```bash
python3 scripts/load-pcm-migration.py \
  --target-org <target-alias> \
  --in-dir <migration-folder> \
  [--interactive]
```

The export script should write CSVs, a manifest, analyzed load order, object coverage notes, and a manual reference override template. The load script should write checkpoint state, source-id to target-id mappings, row-level error reports, and a final reconciliation report.

## Validation after load

After loading:

1. Query record counts by object and compare with the manifest.
2. Check for orphan lookups in bundle, category, classification, and attribute junction objects.
3. Open representative bundle products and verify component groups and child products/classifications.
4. Open representative products and verify `BasedOnId` and inherited attributes.
5. Validate Browse Catalogs/Product Discovery only after effective dates, product active flags, category links, and qualification rules are correct.
