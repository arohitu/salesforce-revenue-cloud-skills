# Attributes

Attributes are the typed properties that describe products (color, storage, billing-cycle, etc.). PCM separates attribute *definitions* from how they're attached to a product or template.

## The four attribute objects

| Object | Role |
|---|---|
| `AttributeDefinition` | The reusable definition: name, data type, default. **One row per logical attribute, period.** |
| `AttributePicklist` | A reusable named set of picklist values. Multiple `AttributeDefinition` rows can share one. |
| `AttributePicklistValue` | A single value in an `AttributePicklist`. |
| `AttributeCategory` + `AttributeCategoryAttribute` | A logical grouping of attributes for design-time organization. Optional but encouraged. |

There are **two attach points** for attributes (this trips up almost every newcomer):

| Attach object | Attaches to | Purpose |
|---|---|---|
| `ProductClassificationAttr` | `ProductClassification` | Attribute on a *template* — every product based on the classification inherits it. |
| `ProductAttributeDefinition` | `Product2` | Attribute on a *specific product* — used when overriding inherited template attribute or adding a one-off. |

Both attach objects support overriding most properties (display type, required, hidden, default value, min/max, picklist value exclusions).

## AttributeDefinition

Key fields:

| Field | Type | Notes |
|---|---|---|
| `Name` | String | Internal name. |
| `Label` | String | User-facing display name. |
| `DataType` | Picklist | `Checkbox`, `Currency` (v61+), `Date`, `Datetime`, `Number`, `Percent` (v61+), `Picklist`, `Text`. |
| `IsActive` | Boolean | **Only active attributes can be attached** to classifications/products. |
| `DefaultValue` | String | Default at design time. |
| `HelpText` | Textarea | End-user help. |

## AttributePicklist + AttributePicklistValue

Define a picklist once, reuse across many attributes.

`AttributePicklist`: `Name`, `DataType`, `Status` (`Draft`/`Active`/`Inactive`).

`AttributePicklistValue`: `Name`, `Code`, `Abbreviation`, `Status`, `IsDefault`, `DisplayValue`, `Sequence`.

To exclude specific values for a particular classification or product use `AttrPicklistExcludedValue` (v61+) — see below.

## AttributeCategory

Pure organizational grouping. Use it when the same set of attributes appears on many products (e.g., "Mobile handset properties").

Linked via `AttributeCategoryAttribute` (junction).

```
AttributeCategory  "Mobile Handset Properties"
  ├── AttributeCategoryAttribute → AttributeDefinition "Color"
  ├── AttributeCategoryAttribute → AttributeDefinition "Storage"
  └── AttributeCategoryAttribute → AttributeDefinition "Screen Size"
```

When you assign an `AttributeCategory` to a `ProductClassification`, every contained attribute is attached at once.

## ProductClassificationAttr (template attachment)

The bridge between `AttributeDefinition` and `ProductClassification`. Each row is one attribute on one template.

| Field | Notes |
|---|---|
| `ProductClassificationId` | Required. Which template. |
| `AttributeDefinitionId` | Required. Which attribute. |
| `AttributeCategoryId` | Optional. Which category to render under. |
| `AttributeNameOverride` | Display the attribute under a different name on this template. |
| `DefaultValue` | Default for products inheriting from this template. |
| `DisplayType` | `CheckBox`, `ComboBox`, `Date`, `Datetime`, `Number`, `RadioButton`, `Slider`, `Text`, `Toggle`. |
| `IsHidden` / `IsReadOnly` / `IsRequired` / `IsPriceImpacting` | Runtime flags. |
| `MinimumValue` / `MaximumValue` | Bounds for numeric/date attributes. |
| `MinimumCharacterCount` / `MaximumCharacterCount` | Bounds for text. |
| `StepValue` | Slider step. |
| `Status` | `Draft` / `Active` / `Inactive`. |
| `Sequence` | Render order. |
| `ExcludedPicklistValues` | Inline excluded picklist values (legacy; prefer `AttrPicklistExcludedValue`). |

## ProductAttributeDefinition (per-product attachment / override)

Attaches an attribute to a specific `Product2`. Used to:
1. Override an attribute inherited from a classification (set `OverriddenProductAttributeDefinitionId` to point at the inherited row).
2. Add a one-off attribute that isn't on any classification.

| Field | Notes |
|---|---|
| `Product2Id` | Required. Which product. |
| `AttributeDefinitionId` | Required. Which attribute. |
| `ProductClassificationAttributeId` | Required. The classification-level attribute being overridden. |
| `OverriddenProductAttributeDefinitionId` | Optional. The specific inherited row, if any. |
| `OverrideContextId` | Polymorphic to root Product2 — used for bundle-scoped overrides. |
| `AttributeCategoryId`, `AttributeNameOverride`, `DefaultValue`, `DisplayType`, `IsHidden`, `IsReadOnly`, `IsRequired`, `IsPriceImpacting`, `MinimumValue`, `MaximumValue`, `MinimumCharacterCount`, `MaximumCharacterCount`, `StepValue`, `Sequence`, `Status`, `HelpText`, `ValueDescription` | Same semantics as on `ProductClassificationAttr`. |

## AttrPicklistExcludedValue (v61+)

Excludes specific picklist values for a `ProductClassificationAttr` or a `ProductAttributeDefinition`.

| Field | Notes |
|---|---|
| `AttributeId` | Polymorphic — `ProductClassificationAttr` or `ProductAttributeDefinition`. |
| `AttributePicklistValueId` | The value to exclude. |

Use case: a "Color" attribute has values Red/Blue/Green/Black. The "Pro" classification excludes Green. The "Lite" classification excludes Black. Same `AttributeDefinition` and `AttributePicklist`, different exclusions.

## Limits

- Up to **200 dynamic attributes per simple or bundle product**.
- Up to **600 attribute overrides per bundle hierarchy** (across all components).
- Up to **5 attributes per variation attribute set** (variants).
- Only **active** attributes can be attached.

## Recipes

### Color picklist reused on many products

```sql
-- Picklist + values
INSERT INTO AttributePicklist (Name, DataType, Status)
VALUES ('Color', 'Picklist', 'Active');

INSERT INTO AttributePicklistValue (AttributePicklistId, Name, Code, Sequence)
VALUES (:PickId, 'Red',   'RED',   10),
       (:PickId, 'Blue',  'BLUE',  20),
       (:PickId, 'Green', 'GREEN', 30),
       (:PickId, 'Black', 'BLACK', 40);

-- Attribute that uses the picklist
INSERT INTO AttributeDefinition
  (Name, Label, DataType, IsActive, AttributePicklistId)
VALUES ('color', 'Color', 'Picklist', true, :PickId);

-- Attach to a classification
INSERT INTO ProductClassificationAttr
  (ProductClassificationId, AttributeDefinitionId,
   IsRequired, DisplayType, Sequence, Status)
VALUES (:ClassificationId, :AttrId, true, 'RadioButton', 10, 'Active');
```

### Override an attribute on one product

```sql
INSERT INTO ProductAttributeDefinition
  (Product2Id, AttributeDefinitionId, ProductClassificationAttributeId,
   OverriddenProductAttributeDefinitionId,
   IsHidden, Status)
VALUES (:Product2Id, :AttrId, :ClassAttrId, :ExistingPADId, true, 'Active');
```

### Exclude a picklist value for a specific classification

```sql
INSERT INTO AttrPicklistExcludedValue
  (AttributeId, AttributePicklistValueId, Name)
VALUES (:ClassAttrId, :GreenValueId, 'Exclude Green for Pro');
```
