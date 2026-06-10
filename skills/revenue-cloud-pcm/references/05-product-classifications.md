# Product Classifications

A **product classification** is a reusable template of attributes. Every product based on a classification automatically inherits that template's attributes — so you define attributes once and apply them to many products.

Think of it as the "type system" for the catalog.

## ProductClassification

| Field | Type | Notes |
|---|---|---|
| `Code` | String(80) | Unique alphanumeric identifier. Required. |
| `Name` | String | Template name. Required. |
| `Status` | Picklist | `Draft` / `Active` / `Inactive`. Defaults to `Draft`. |
| `OwnerId` | Lookup | Group or User. |

Lifecycle:
- Created in `Draft`.
- Promoted to `Active` to be usable.
- `Inactive` retires it; **cannot revert to `Draft`** once set to Active or Inactive.
- **Cannot delete** an active classification that has products linked. Set to `Inactive` and detach products first.

## ProductClassificationParent (hierarchy)

Establishes a parent → child relationship between classifications. Subclassifications inherit all parent attributes; they can add unique attributes and override inherited ones.

| Field | Notes |
|---|---|
| `ParentClassificationId` | The parent template. |
| `ChildProductClassificationId` | The subclassification. |

Hierarchy limits: **3 levels deep**, parent can have **5 child nodes per level**.

```
Mobile Devices                (root template — common attributes: brand, weight)
  ├── Smartphones             (adds: storage, screen size, OS)
  │     ├── Pro Phones        (adds: cellular bands, dust rating)
  │     └── Lite Phones
  └── Tablets                 (adds: stylus support)
```

A product based on `Pro Phones` inherits attributes from `Pro Phones` + `Smartphones` + `Mobile Devices`.

## ProductClassificationAttr — what each attribute looks like on the template

Defined in detail in `04-attributes.md`. Key callouts here:

- The classification-attribute is the **default** for any product based on the classification.
- Per-product overrides go on `ProductAttributeDefinition` and point back via `ProductClassificationAttributeId` and optionally `OverriddenProductAttributeDefinitionId`.
- A subclassification override adds another `ProductClassificationAttr` row whose `ProductClassificationId` is the child and whose `AttributeDefinitionId` matches the parent's — runtime resolves to the most specific.

## How a product picks up classification attributes

```
Product2.BasedOnId  ──→  ProductClassification (the template)
                              │
                              │ ProductClassificationAttr (×N)
                              ▼
                          AttributeDefinition (×N)

   At runtime the configurator merges:
     parent classification attrs
     + child classification attrs (overrides)
     + per-product ProductAttributeDefinition (overrides)
     - AttrPicklistExcludedValue (filtered values)
```

**Without `Product2.BasedOnId` set, no inheritance happens.** This is the #1 reason "my product isn't showing the right attributes" — the link is missing.

## When to use classifications vs per-product attributes

| Scenario | Approach |
|---|---|
| Many products share the same attributes | Classification |
| Hierarchy of products with progressive specialization | Parent + child classifications |
| One-off attribute on a single product | `ProductAttributeDefinition` directly on `Product2` |
| Same attribute, different default per product | Inherit from classification; override default on `ProductAttributeDefinition` |
| Same picklist attribute, different allowed values per product | Inherit; add `AttrPicklistExcludedValue` |

## Limits

- **Up to 10,000 products per classification.**
- **3 levels deep** for classification hierarchy.
- **5 children per node**.
- An inactive classification cannot be assigned to new products.
- A classification cannot be deleted while products reference it.

## Recipe — phone classifications

```sql
-- Root template
INSERT INTO ProductClassification (Name, Code, Status)
VALUES ('Mobile Devices', 'MOBILE_DEVICES', 'Active');

-- Subclassification for smartphones
INSERT INTO ProductClassification (Name, Code, Status)
VALUES ('Smartphones', 'SMARTPHONES', 'Active');

INSERT INTO ProductClassificationParent
  (ParentClassificationId, ChildProductClassificationId)
VALUES (:MobileDevicesId, :SmartphonesId);

-- Attach attributes (storage, color)
INSERT INTO ProductClassificationAttr
  (ProductClassificationId, AttributeDefinitionId,
   IsRequired, DisplayType, Sequence, Status)
VALUES (:SmartphonesId, :StorageAttrId, true,  'ComboBox',    10, 'Active'),
       (:SmartphonesId, :ColorAttrId,   true,  'RadioButton', 20, 'Active');

-- Link a product to the template — this is what triggers inheritance
UPDATE Product2 SET BasedOnId = :SmartphonesId WHERE Id = :ProductId;
```
