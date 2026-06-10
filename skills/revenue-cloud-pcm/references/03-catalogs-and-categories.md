# Catalogs and Categories

A catalog is the top-level container. A category organizes the catalog. Products are assigned to categories via a junction.

## Catalog (`Catalog`)

| Field | Type | Notes |
|---|---|---|
| `Code` | String(80) | Unique alphanumeric identifier. Required for upserts. |
| `Description` | Textarea(255) | Design-time description. |
| `EffectiveStartDate` | DateTime | When catalog becomes available. |
| `EffectiveEndDate` | DateTime | When catalog stops being available. |
| `CatalogType` | Picklist | `Sales` or `ServiceProcess`. |
| `Name` | String | Catalog name shown to users. |

**Lifecycle:** A catalog is "live" only inside its effective window. Products outside the window do not surface in Product Discovery even if everything else is configured correctly.

**Multi-catalog:** A product can belong to multiple catalogs simultaneously (via `ProductCategoryProduct` joins to categories in different catalogs). Users switch catalogs from Product Discovery if multi-catalog is enabled in settings.

## ProductCategory

Hierarchical container inside a catalog.

| Field | Type | Notes |
|---|---|---|
| `Code` | String(80) | Unique alphanumeric identifier. |
| `Name` | String | Category name. |
| `Description` | Textarea | Design-time description. |
| `CatalogId` | Lookup → Catalog | Which catalog this category belongs to. |
| `ParentCategoryId` | Lookup → ProductCategory | Self-lookup; null = root. |
| `SortOrder` | Number | Lower values sort first. Sort order: null → negative → zero → positive; ties broken by creation timestamp. |
| `ShowInMenu` | Boolean | Whether to render in navigation menu. |
| `IsNavigational` | Boolean | (v62.0+) Whether category appears as a navigational breadcrumb. |

**Hierarchy limit:** up to **5 levels deep**, excluding the root.

**Per category:** up to **100,000 products** can be assigned.

## ProductCategoryProduct

Junction object linking `Product2` to `ProductCategory`. A product can be in multiple categories (and multiple catalogs).

Key fields:
- `ProductId` — required, lookup to `Product2`.
- `ProductCategoryId` — required, lookup to `ProductCategory`.
- `IsPrimaryCategory` — boolean, marks the canonical category for the product (used by some defaults).

## Recipes

### Create a sales catalog with two-level hierarchy

```sql
-- 1. Catalog
INSERT INTO Catalog (Name, Code, CatalogType, EffectiveStartDate)
VALUES ('Mobile Plans 2026', 'MOBILE-2026', 'Sales', TODAY());

-- 2. Root categories (ParentCategoryId = null)
INSERT INTO ProductCategory (Name, Code, CatalogId, IsNavigational, SortOrder)
VALUES ('Devices', 'DEVICES', :CatalogId, true, 10),
       ('Plans',   'PLANS',   :CatalogId, true, 20);

-- 3. Subcategories
INSERT INTO ProductCategory
  (Name, Code, CatalogId, ParentCategoryId, IsNavigational, SortOrder)
VALUES ('Smartphones', 'SMARTPHONES', :CatalogId, :DevicesId, true, 10),
       ('Tablets',     'TABLETS',     :CatalogId, :DevicesId, true, 20);

-- 4. Assign products
INSERT INTO ProductCategoryProduct (ProductId, ProductCategoryId, IsPrimaryCategory)
VALUES (:Product2Id, :SmartphonesId, true);
```

### Default catalog

Set the default catalog in **Setup → Product Discovery Settings**. The Browse Catalogs button auto-loads it. You can override it per Experience Cloud site.

## Gotchas

- **Categories outside their catalog's effective window** still show in setup but never render in Product Discovery.
- **Navigation rendering**: `IsNavigational = true` is honored only by the Product Discovery components shipped in v62.0+. On older orgs, use `ShowInMenu` and verify in the runtime.
- **Reparenting** a category moves all descendant categories with it (no cascade configuration needed).
- **Sort order ties** are broken by creation timestamp, not by `Name`. If you need stable ordering, set `SortOrder` explicitly on every record.
- **Deletion**: deleting a category with products assigned is allowed but breaks the runtime — clean up `ProductCategoryProduct` rows first.
