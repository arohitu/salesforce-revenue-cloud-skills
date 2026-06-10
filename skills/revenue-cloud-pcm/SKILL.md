---
name: revenue-cloud-pcm
description: >-
  Salesforce Revenue Cloud Product Catalog Management (PCM) master data on core
  Salesforce objects for Agentforce Revenue Management, Revenue Cloud Advanced,
  and Revenue Cloud Billing. Use for any lookup, query, design, build, export,
  import, migration, CSV, sandbox load, troubleshooting, or analysis involving
  catalogs, categories, products, bundles, classifications, dynamic attributes,
  picklists, qualification/disqualification, selling models, Product Discovery,
  Product2, ProductCatalog, ProductCategory, ProductCategoryProduct,
  AttributeDefinition, AttributePicklist, AttributePicklistValue,
  AttributeCategory, AttributeCategoryAttribute, AttrPicklistExcludedValue,
  ProductClassification, ProductClassificationAttr, ProductClassificationParent,
  ProductAttributeDefinition, ProductRelatedComponent, ProductComponentGroup,
  ProductComponentGrpOverride, ProductRelComponentOverride,
  ProductRelationshipType, ProductQualification, ProductDisqualification,
  ProductCategoryQualification, ProductCategoryDisqual, ProductSellingModel,
  ProductSellingModelOption, ProductRampSegment, ProductSpecificationType, or
  ProductSpecificationRecType. Do not drift to legacy Salesforce CPQ SBQQ__ or
  legacy Salesforce Billing BLNG__ managed-package patterns unless explicitly
  requested.
license: MIT
metadata:
  author: Rohit Radhakrishnan
  version: 1.0.0
  domain: salesforce-revenue-cloud
  module: product-catalog-management
---

# Salesforce Product Catalog Management (PCM)

You are helping with Salesforce **Product Catalog Management** in **Salesforce Revenue Cloud / Agentforce Revenue Management / Revenue Cloud Advanced / Revenue Cloud Billing**. This is the newer core-platform product family that uses standard/core Salesforce objects such as `Product2`, `Quote`, `QuoteLineItem`, `ProductClassification`, and related PCM objects. Do **not** drift into legacy managed-package Salesforce CPQ (`SBQQ__`) or legacy Salesforce Billing (`BLNG__`) patterns unless the user explicitly asks for those products.

PCM models the company's product portfolio — catalogs, categories, products, bundles, dynamic attributes, classifications, qualification rules, selling models, and the Product Discovery experience.

This file is your routing layer. It contains the gotchas you must always remember and a map of when to load which reference. **Do not try to answer detailed PCM questions from this file alone — load the right reference first.**

## Always-true gotchas (never forget these)

These are the corrections most agents need before they can be useful in PCM. Internalize them:

1. **Bundles use a TWO-table structure, not one.** A configurable bundle has both `ProductRelatedComponent` (the line linking a child to a parent) **and** `ProductComponentGroup` (the section the line belongs to). Static bundles can skip groups; configurable bundles cannot. Don't model a bundle without thinking through both.
2. **Attributes can be attached at TWO levels.** `ProductClassificationAttr` defines the *template* attribute on a classification. `ProductAttributeDefinition` is the *instance* attached to a specific `Product2`. A product based on a classification inherits its attributes; you only create a `ProductAttributeDefinition` when overriding an inherited attribute on a specific product or adding a one-off attribute. Confusing these two is the most common PCM modeling error.
3. **Qualification rules default to `qualified`.** A product or category with NO qualification/disqualification record is visible. Qualification beats disqualification when both apply. Don't write a rule "to make it visible" — write a rule to *restrict* visibility.
4. **`ProductSellingModel` is its own object, not a Product2 picklist.** Pricing term length and unit live on `ProductSellingModel`. A product is linked to one or more selling models via `ProductSellingModelOption`. Pricing (rates, books) lives in a separate Salesforce Pricing module — do NOT try to put price on Product2 directly for PCM-driven flows.
5. **`Product2.Type = 'Bundle'` is the switch that turns a product into a bundle.** Without it, `ProductRelatedComponent` rows pointing to it will not be treated as bundle components by the runtime. Also set `ConfigureDuringSale` correctly: `Allowed` (configurable), `Not Allowed` (static), or `None` (simple product).
6. **`Product2.BasedOnId` (the classification link) is what makes a product inherit attributes.** Setting `BasedOnId` is mandatory before you can rely on classification-driven attributes; without it, you have to attach every attribute via `ProductAttributeDefinition` directly.
7. **Catalogs and categories are time-bounded.** `EffectiveStartDate` / `EffectiveEndDate` on `Catalog`, and `EffectiveFromDate` / `EffectiveToDate` on qualification/disqualification rules. A "missing" product in Product Discovery is most often an expired effective-window, not a permission or rule problem.
8. **API version matters.** Most PCM objects appear in API v60.0+. Some (`ProductRampSegment`, `IsNavigational`, `ProductComponentGroup.ParentGroupId`, `Product2.UsageModelType`) are v62.0+. `AttrPicklistExcludedValue` is v61.0+. Check the API version of the org before assuming an object exists.
9. **PCM is not standalone.** It hands records off to Salesforce Pricing, Product Configurator, Transaction Management, and Billing. A "wrong" PCM model often shows up as a downstream pricing or configurator error. When debugging, identify which module is actually emitting the error before changing PCM.
10. **Permission set groups, not profiles.** PCM ships permission sets: `ProductCatalogManagementDesigner`, `ProductCatalogManagementViewer`, plus community variants. Compose them via permission set groups; do not clone profiles.
11. **Describe the org before data migration or bulk lookup work.** Object and field API names vary by org/version: catalogs may expose as `ProductCatalog` rather than `Catalog`, and `AttributePicklistValue` may use `PicklistId` rather than `AttributePicklistId`.
12. **This is not legacy managed-package CPQ/Billing.** Revenue Cloud / Agentforce Revenue Management uses core objects and unnamespaced APIs for PCM. Avoid `SBQQ__` CPQ and `BLNG__` Billing assumptions, fields, and object names unless the user explicitly says they are working on those legacy managed packages.

## When to load which reference

Read **only** the reference(s) relevant to the current task. Each reference is self-contained.

| User intent | Load |
|---|---|
| "What is PCM?", architecture, how modules connect | `references/01-architecture.md` |
| Editions, license, permission sets, personas, setup | `references/02-setup-and-permissions.md` |
| Catalogs, categories, navigation, hierarchy, default catalog | `references/03-catalogs-and-categories.md` |
| Attribute definitions, picklists, attribute categories, validation | `references/04-attributes.md` |
| Product classifications, attribute templates, inheritance | `references/05-product-classifications.md` |
| Product creation, simple vs bundle, components, cardinality, overrides | `references/06-products-and-bundles.md` |
| Product variants (size/color/storage), variation parents | `references/07-product-variants.md` |
| Qualification / disqualification rules, decision tables, eligibility | `references/08-qualification-rules.md` |
| Selling models (one-time, term-defined, evergreen), proration, ramp | `references/09-selling-models.md` |
| Product Discovery, Browse Catalogs, Guided Selection, search | `references/10-product-discovery.md` |
| Hard limits — sizing, max attrs, max bundle depth, etc. | `references/11-limits.md` |
| Field-level lookup for ANY PCM object (Product2, AttributeDefinition, etc.) | `references/12-object-reference.md` |
| Catalog/bundle migration, CSV export, load order, target-org import | `references/13-data-migration.md` |

When the user's question spans multiple areas (e.g., "build a configurable phone bundle with color and storage attributes"), load multiple references — but only the ones you need.

## Standard workflows

These are the workflows that appear over and over. Follow the named steps; the detailed "how" is in the referenced file.

### Workflow A — Stand up a new product catalog from scratch

1. Confirm editions and permission sets — load `02-setup-and-permissions.md`.
2. Create the `Catalog` record with `EffectiveStartDate`, optional `EffectiveEndDate`, and `CatalogType` — load `03-catalogs-and-categories.md`.
3. Build the category hierarchy under the catalog (max 5 levels deep, excluding root). Set `IsNavigational` for browse paths.
4. Create `AttributeDefinition` records for the attributes the products share. Group them with `AttributeCategory` if reusable — load `04-attributes.md`.
5. Create `ProductClassification` templates and link attributes via `ProductClassificationAttr` — load `05-product-classifications.md`.
6. Create `Product2` records, set `BasedOnId` to the classification — load `06-products-and-bundles.md`.
7. Link products to categories via `ProductCategoryProduct`.
8. Add `ProductSellingModelOption` rows tying each product to one or more `ProductSellingModel`s — load `09-selling-models.md`.
9. Add qualification rules only if you need to restrict visibility — load `08-qualification-rules.md`.
10. Validate via Product Discovery — load `10-product-discovery.md`.

### Workflow B — Build a configurable bundle

1. Create the parent `Product2` with `Type = 'Bundle'` and `ConfigureDuringSale = 'Allowed'`.
2. Create `ProductComponentGroup` rows for each section of the bundle (e.g., "Choose phone", "Choose plan").
3. For each child product, create `ProductRelatedComponent`, setting `ParentProductId`, `ChildProductId`, and `ProductComponentGroupId`. Set `MinQuantity`, `MaxQuantity`, `Quantity`, `IsComponentRequired`, `IsDefaultComponent`, `IsQuantityEditable`, `QuoteVisibility`.
4. If the bundle needs cardinality overrides for a particular root context, create `ProductComponentGrpOverride` (group cardinality) and/or `ProductRelComponentOverride` (component cardinality), tying both to a root `OverrideContextId`.
5. Cap: ≤200 components per bundle hierarchy, ≤600 attribute overrides, ≤10 component or group overrides per bundle. See `references/11-limits.md`.
6. Run **Validate Product Definition** in the UI before treating the bundle as ready.

Detail in `references/06-products-and-bundles.md`.

### Workflow C — Add dynamic attributes to a product family

1. Decide: are the attributes shared across many products? If yes, attach via `ProductClassification` (template). If unique to one product, attach directly to `Product2`.
2. Create `AttributeDefinition` rows for each attribute (set `DataType`).
3. For picklist-typed attributes, create `AttributePicklist` and `AttributePicklistValue` rows.
4. Group attributes via `AttributeCategory` + `AttributeCategoryAttribute` if reusable.
5. Attach to template: `ProductClassificationAttr` rows.
6. To exclude specific picklist values for a classification or product, create `AttrPicklistExcludedValue` rows.
7. To override an attribute on a specific product, create `ProductAttributeDefinition` and set `OverriddenProductAttributeDefinitionId`.

Detail in `references/04-attributes.md` and `references/05-product-classifications.md`.

### Workflow D — Diagnose "product is missing from Browse Catalogs"

Check in this order — most common cause first:

1. `Product2.IsActive = true`?
2. `Product2.AvailabilityDate` reached and `DiscontinuedDate` / `EndOfLifeDate` not yet passed?
3. `ProductCategoryProduct` row exists for the catalog category being browsed?
4. `Catalog.EffectiveStartDate` reached, `EffectiveEndDate` not passed?
5. `ProductDisqualification` or `ProductCategoryDisqual` record evaluating to `IsDisqualified = true` for current context?
6. Qualification procedure (if configured) returning false for this user?
7. Product Discovery search index up to date? (After bulk loads, a reindex is required.)
8. User has the right permission set (Viewer at minimum)?

Detail in `references/08-qualification-rules.md` and `references/10-product-discovery.md`.

### Workflow E — Migrate catalog or bundle product data

1. Confirm the input mode: a catalog name/id/code, or one or more bundle `Product2` ids/codes where `Product2.Type = 'Bundle'`.
2. Describe the source org schema before querying, especially `ProductCatalog`/`Catalog` and attribute picklist fields.
3. Expand the product graph through `ProductRelatedComponent`, collecting `ChildProductId` products and `ChildProductClassificationId` classifications. Recurse into child products that are bundles.
4. Include reusable attribute foundation objects (`AttributeDefinition`, `AttributePicklist`, `AttributePicklistValue`, `AttributeCategory`, `AttributeCategoryAttribute`) plus scoped classification/product attribute records.
5. Generate CSVs with source ids and helper business keys for lookup/remapping.
6. Load a target org in analyzed dependency order with checkpointed id mapping. The load package must be usable without source org access after export.

Detail in `references/13-data-migration.md`.

## Available scripts

This skill bundles helper scripts under `scripts/` for inspecting a Salesforce org's PCM data via the Salesforce CLI (`sf`). They require `sf` authenticated to a target org. Reference them only when the user wants to inspect or load real org data.

- **`scripts/describe-pcm-objects.sh`** — Runs `sf sobject describe` for every PCM object and writes the full schemas to `pcm-describe/`. Useful for confirming which fields exist in a specific org/API version before writing queries.
- **`scripts/query-product-tree.sh`** — Given a `Product2.Id` of a bundle, recursively prints the bundle hierarchy with components, groups, and attributes. Use to validate a bundle was modeled correctly.
- **`scripts/list-catalogs.sh`** — Lists every active catalog with categories and product counts. Quick health check after a deploy.
- **`scripts/check-orphans.sh`** — Finds common modeling defects: products with `Type = 'Bundle'` but no components; classifications with no products; qualification rules with expired effective dates.

Each script prints `--help` with usage. They are read-only by default.

For fragile migration/export/import work, prefer a dedicated script over ad hoc SOQL. If adding migration scripts, use relative paths and explicit interfaces such as:

- **`scripts/export-pcm-migration.py`** — Export by `--target-org`, `--catalog-name`/`--catalog-id` or `--bundle-product-id`/`--bundle-product-code`, and `--out-dir`. It should write CSVs, a manifest, analyzed load order, and coverage notes.
- **`scripts/load-pcm-migration.py`** — Load a generated package into a target org with `--target-org`, interactive pauses, checkpointed id mapping, and local error reports. It must not require source org access.

## Things this skill explicitly does NOT cover

These are adjacent modules. If the user crosses into them, say so and stop:

- **Pricing math, price books, rate cards** → Salesforce Pricing module (separate).
- **Quote/order line creation, runtime configurator UI behavior** → Product Configurator + Transaction Management.
- **Billing operations outside PCM master data** (invoicing, billing schedules, revenue recognition) → Revenue Cloud Billing/Billing module.
- **Approval flows on quotes** → Advanced Approvals.
- **Asset and subscription lifecycle after order fulfillment** → Dynamic Revenue Orchestrator.

PCM ends where the product is *defined and discoverable*. Anything past that belongs to a sibling module in the Revenue Cloud core product family. Do not switch to legacy `SBQQ__` or `BLNG__` managed-package behavior unless the user explicitly requests it.
