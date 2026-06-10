# PCM Architecture

PCM is the *definition* layer of Salesforce Revenue Cloud / Agentforce Revenue Management / Revenue Cloud Advanced / Revenue Cloud Billing. It models what the company sells. Other modules consume PCM records — they don't define them.

## Product family boundary

Revenue Cloud / Agentforce Revenue Management is the newer core-platform product family. It uses standard/core Salesforce objects and unnamespaced APIs such as `Product2`, `Quote`, `QuoteLineItem`, `ProductClassification`, `ProductRelatedComponent`, and `ProductComponentGroup`.

Do **not** default to legacy managed-package Salesforce CPQ (`SBQQ__`) or legacy Salesforce Billing (`BLNG__`) objects, fields, package behavior, or data model assumptions. Use those legacy package models only when the user explicitly says they are working with Salesforce CPQ or managed-package Billing.

## What PCM owns

- **Catalogs** of products organized into **categories**.
- **Products** (`Product2`) — simple, bundled, or variation.
- **Dynamic attributes** describing products (color, size, storage, etc.).
- **Product classifications** — reusable attribute templates.
- **Qualification / disqualification rules** — when a product or category is shown.
- **Selling models** — how a product is sold (one-time, term, evergreen).
- **Product Discovery** — the browse / search / guided experience that surfaces products to a user.

## What PCM does NOT own

- Prices, rate cards, price books → **Salesforce Pricing**.
- Runtime configurator validation, constraint rules at sell time → **Product Configurator**.
- Quotes, orders, line creation → **Transaction Management**.
- Approvals on quotes → **Advanced Approvals**.
- Invoicing, billing schedules, revenue recognition → **Billing**.
- Subscription / asset lifecycle, ramp orchestration → **Dynamic Revenue Orchestrator**.

PCM hands records off via well-known FK columns (`Product2Id`, `PricebookEntry`, etc.) and Salesforce platform events.

## Core component map

```
                ┌─────────────────────────────┐
                │         Catalog             │
                │  (Catalog object)           │
                └──────────────┬──────────────┘
                               │ 1..N
                ┌──────────────▼──────────────┐
                │       ProductCategory        │
                │  (hierarchical, ≤5 levels)   │
                └──────────────┬──────────────┘
                               │ N..M (via ProductCategoryProduct)
                ┌──────────────▼──────────────┐
   ┌────────────│         Product2             │────────────┐
   │            │  Type: simple | Bundle |     │            │
   │            │       VariationParent |      │            │
   │            │       Variation             │            │
   │            │  BasedOnId → Classification  │            │
   │            └──────────────────────────────┘            │
   │                                                         │
   ▼ inherits attributes                                    ▼ has selling models
ProductClassification                              ProductSellingModelOption
   │                                                ├── ProductSellingModel
   │ ProductClassificationAttr                        (OneTime / TermDefined /
   │   └── AttributeDefinition                        Evergreen, term + unit)
   │       ├── AttributePicklist
   │       └── AttributePicklistValue
   │
   ▼ overrides per product
ProductAttributeDefinition

       Visibility layer
       ────────────────
ProductQualification           ProductCategoryQualification
ProductDisqualification        ProductCategoryDisqual
   (decision-table driven; default state is "qualified")

       Bundle structure (only when Product2.Type = 'Bundle')
       ────────────────────────────────────────────────────
ProductRelatedComponent ── grouped by ──> ProductComponentGroup
       │                                      │
       ▼                                      ▼
ProductRelComponentOverride          ProductComponentGrpOverride
       (per-bundle cardinality, scoped by OverrideContextId = root product)
```

## Object map by purpose

| Purpose | Objects |
|---|---|
| Container | `Catalog` |
| Hierarchy | `ProductCategory`, `ProductCategoryProduct` |
| Product | `Product2` |
| Templates | `ProductClassification`, `ProductClassificationParent`, `ProductClassificationAttr` |
| Attributes | `AttributeDefinition`, `AttributePicklist`, `AttributePicklistValue`, `AttributeCategory`, `AttributeCategoryAttribute`, `ProductAttributeDefinition`, `AttrPicklistExcludedValue` |
| Bundle structure | `ProductRelatedComponent`, `ProductComponentGroup`, `ProductRelationshipType` |
| Bundle overrides | `ProductRelComponentOverride`, `ProductComponentGrpOverride` |
| Variants | `Product2` (`Type = VariationParent` or `Variation`), variation-attribute relationships |
| Visibility | `ProductQualification`, `ProductDisqualification`, `ProductCategoryQualification`, `ProductCategoryDisqual` |
| Selling models | `ProductSellingModel`, `ProductSellingModelOption`, `ProductRampSegment` |
| Industry specs | `ProductSpecificationType`, `ProductSpecificationRecType` |
| Settings | `ProductCatalogManagementSettings`, `ProductDiscoverySettings` (Metadata API) |

## API surfaces

- **REST/SOAP API** — CRUD on every PCM object.
- **Tooling API** — metadata-style access to settings and specification types.
- **Metadata API** — `ProductCatalogManagementSettings`, `ProductDiscoverySettings`, `ProductSpecificationType`, `ProductSpecificationRecType`.
- **Bulk Product Details API** — up to 100 product IDs per request.
- **Connect REST APIs** — Product Discovery search and Browse Catalogs.

Most PCM objects appeared in **API v60.0**. Newer arrivals: `AttrPicklistExcludedValue` (v61), `ProductRampSegment` (v62), `ProductComponentGroup.ParentGroupId` (v62), `ProductCategory.IsNavigational` (v62), `Product2.UsageModelType` (v62). Verify the org's API version before assuming an object/field exists.

## Data flow at runtime

1. User opens **Browse Catalogs** on a quote/order.
2. The default `Catalog` (from Product Discovery Settings) loads — or the user picks one if multi-catalog is enabled.
3. The qualification procedure (optional) runs against the user/account context, filtering categories and products via the `IsQualified` / `IsDisqualified` outputs.
4. Products surface in list/tile view; attributes, images, and bundle details render.
5. The user picks a product; if it's a bundle and `ConfigureDuringSale = 'Allowed'`, the **Product Configurator** takes over.
6. The configured selection plus the chosen `ProductSellingModelOption` is handed to **Salesforce Pricing**, which produces line prices.
7. Lines are written to the quote/order by **Transaction Management**.

PCM's job is steps 1–4 (and ensuring 5 has the right model).
