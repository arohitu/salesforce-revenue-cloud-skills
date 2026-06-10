# PCM Limits

Hard and soft limits to plan against. Hitting these mid-deploy is the most common cause of "it works in dev, fails in prod."

## Catalog and category

| Limit | Value |
|---|---|
| Category hierarchy depth | **5 levels** (excluding root) |
| Products per category | **100,000** |
| Catalogs per product (multi-catalog) | Unbounded by limit; bounded by `ProductCategoryProduct` row count |

## Classification

| Limit | Value |
|---|---|
| Classification hierarchy depth | **3 levels** |
| Children per classification node | **5** |
| Products per classification | **10,000** |

## Attributes

| Limit | Value |
|---|---|
| Dynamic attributes per simple/bundle product | **200** |
| Attribute overrides per bundle hierarchy | **600** total |
| Attributes per variation attribute set | **5** |
| Attribute states allowing assignment | Only `Active` |

## Bundles

| Limit | Value |
|---|---|
| Bundle hierarchy depth | **3 levels** |
| Children per bundle node | **5** |
| Recommended components per hierarchy | **≤200** (performance) |
| `ProductRelComponentOverride` per bundle hierarchy | **10** |
| `ProductComponentGrpOverride` per bundle hierarchy | **10** |
| Component group nesting depth | **2 levels** |

## Search and indexing

| Limit | Value |
|---|---|
| Indexed products (default) | **1,000,000** |
| Indexed products (with Salesforce-approved increase) | up to **20,000,000** |
| Partial indexing (subset for special use) | **2,000** |
| Searchable + filterable fields combined | **87** |
| Display fields in Product Discovery (beyond default) | **3** |

## API surfaces

| Limit | Value |
|---|---|
| Bulk Product Details API request | **100 product IDs** per call |
| Decision Table — Standard | **<100,000 records** |
| Decision Table — Advanced | required if **>100,000 records** |

## Pricing-related

| Limit | Value |
|---|---|
| Decimal places for unit-level pricing | **6** |
| Standard fields | use platform defaults |

## Practical sizing rules of thumb

- **Configurable bundles**: keep components per hierarchy under 100 for fast configurator load. Bundles approaching 200 components feel sluggish even on Indexed search.
- **Categories**: hierarchies past 4 levels become hard to navigate; stay shallow.
- **Classifications**: a single classification with 10k products is the hard cap, but past ~2k products consider whether subclassifications would split the load.
- **Attributes**: attribute count past 50 on a single product hurts configurator UX even though the limit is 200.
- **Search**: switch to indexed search before the catalog reaches 5,000 products.
