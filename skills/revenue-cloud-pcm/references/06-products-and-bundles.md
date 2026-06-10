# Products and Bundles

This is the largest reference because product modeling is the heart of PCM. Read top-to-bottom if you're unfamiliar; otherwise jump to the section you need.

## Product2 — PCM-relevant fields

`Product2` is the standard Salesforce product object. PCM adds and uses the following:

| Field | Type | Notes |
|---|---|---|
| `Name` | String | Product name. |
| `ProductCode` | String | SKU. |
| `Description` | Textarea | End-user description. |
| `IsActive` | Boolean | Inactive products do not surface. |
| `Type` | Picklist | `(blank)` = simple, `Bundle` = bundle parent, `VariationParent`, `Variation`. **The runtime treats components as a bundle only when this is `Bundle`.** |
| `ConfigureDuringSale` | Picklist | `Allowed` (configurable bundle), `Not Allowed` (static bundle), `None` (simple product). |
| `BasedOnId` | Lookup → ProductClassification | The classification this product inherits from. **Set this for attribute inheritance.** |
| `AvailabilityDate` | DateTime | When the product is first available. |
| `DiscontinuedDate` | DateTime | When the product stops being orderable. |
| `EndOfLifeDate` | DateTime | When the product is no longer supported. |
| `CanRamp` | Boolean | Whether terms can ramp at runtime (used with `ProductRampSegment`). |
| `HelpText` | Textarea | Runtime help. |
| `DecompositionScope` | Picklist | (v61+) Number of fulfillment order line items generated. |
| `FulfillmentQtyCalcMethod` | Picklist | (v61+) Whether quantity is always one or aggregated. |
| `UsageModelType` | Picklist | (v62+) `Anchor` or `Pack`. |
| `IsSoldOnlyWithOtherProducts` | Boolean | Cannot be sold alone — must be a bundle component. |
| `SpecificationType` | String | Industry specification key (works with `ProductSpecificationType`). |

## Simple product

`Type` blank, `ConfigureDuringSale = 'None'`, `BasedOnId` optional. Single SKU sold by itself.

## Static bundle

`Type = 'Bundle'`, `ConfigureDuringSale = 'Not Allowed'`. All components are always included; the user does not pick. Component groups are **optional** — you can put `ProductRelatedComponent` rows directly on the parent.

## Configurable bundle

`Type = 'Bundle'`, `ConfigureDuringSale = 'Allowed'`. Users pick from groups at runtime. **`ProductComponentGroup` rows are required** — every `ProductRelatedComponent` must belong to a group.

## ProductRelatedComponent (PRC)

The line item linking a child product to a bundle parent.

| Field | Notes |
|---|---|
| `ParentProductId` | The bundle parent. |
| `ChildProductId` | The component product. |
| `ChildProductClassificationId` | (Alternative to `ChildProductId`) — picks up all products of a classification dynamically at runtime. |
| `ProductComponentGroupId` | Which group this line belongs to (required for configurable bundles). |
| `ProductRelationshipTypeId` | Defines the role (e.g., `BundleComponent`). |
| `Quantity` | Default quantity. |
| `MinQuantity` / `MaxQuantity` | Bounds. |
| `IsQuantityEditable` | Whether the user can change quantity at runtime. |
| `IsComponentRequired` | Required to ship with the bundle. |
| `IsDefaultComponent` | Pre-selected at runtime. |
| `DoesBundlePriceIncludeChild` | Whether parent price already includes this child's price. |
| `Sequence` | Display order. |
| `QuoteVisibility` | `Always`, `Never`, `TransactionLineEditorOnly`, `QuoteDocumentOnly`. |
| `QuantityScaleMethod` | `None`, `Constant`, `Proportional`. Drives whether quantity scales with parent quantity. |

**Dynamic option:** point `ChildProductClassificationId` at a classification and at runtime, every active product based on that classification appears as a selectable option in the group.

## ProductComponentGroup

Sections within a bundle ("Choose phone", "Choose plan", etc.).

| Field | Notes |
|---|---|
| `Name` | Group name shown to users. |
| `Description` | Help text for the section. |
| `MinBundleComponents` / `MaxBundleComponents` | Cardinality of selections within this group. |
| `Sequence` | Render order. |
| `ParentGroupId` | (v62+) Self-lookup for nested groups (limit: 2 levels). |
| `IsConfigurable` | Whether users can configure this group's selections. |

## ProductRelationshipType

Defines the role a component plays.

| Field | Notes |
|---|---|
| `Name`, `Code` | Identifiers. |
| `AssociatedProductRoleCat` | (v61+) `BundleComponent` or `ClassificationComponent`. |

Standard roles ship out of the box; create custom ones only if you have unusual semantics.

## Override objects (per-bundle cardinality)

When the same component appears in multiple bundles but needs different cardinality in each, you don't change the master `ProductRelatedComponent` — you create an override scoped to a specific *root context* (a top-level bundle).

### ProductRelComponentOverride

Per-component cardinality override in a specific bundle context.

| Field | Notes |
|---|---|
| `ProductRelatedComponentId` | The PRC being overridden. |
| `OverrideContextId` | Polymorphic → root `Product2`. The bundle this override applies to. |
| `MinQuantity`, `MaxQuantity`, `Quantity` | Override values. |
| `IsExcluded` | If true, the component is removed in this bundle. |
| `IsComponentRequired`, `IsDefaultComponent`, `IsQuantityEditable` | Override flags. |
| `DoesBundlePriceIncludeChild` | Override flag. |
| `QuantityScaleMethod` | `Constant` or `Proportional`. |

### ProductComponentGrpOverride

Per-group cardinality override in a specific bundle context.

| Field | Notes |
|---|---|
| `ProductComponentGroupId` | The group being overridden. |
| `OverrideContextId` | Polymorphic → root `Product2`. |
| `MinBundleComponents`, `MaxBundleComponents` | Override cardinality. |
| `IsExcluded` | If true, the group disappears in this bundle. |

## Validate Product Definition

A built-in UI action that checks bundle integrity (cardinality consistency, required components present, override scopes valid). Always run before treating a bundle as ready. CLI equivalent: there isn't one — it's a UI-only action today.

## Limits (full table in `references/11-limits.md`)

- **Bundle hierarchy depth:** 3 levels.
- **Bundle children per node:** 5.
- **Recommended components per hierarchy:** ≤200.
- **Component overrides per hierarchy:** 10.
- **Group overrides per hierarchy:** 10.
- **Attribute overrides per bundle:** 600 total.
- **Attributes per simple/bundle product:** 200.
- **Component group nesting:** 2 levels.

## Recipe — configurable phone-and-plan bundle

```sql
-- Parent bundle
INSERT INTO Product2 (Name, ProductCode, Type, ConfigureDuringSale, IsActive)
VALUES ('Phone + Plan Bundle', 'PHN-BNDL', 'Bundle', 'Allowed', true);

-- Two groups: choose phone, choose plan
INSERT INTO ProductComponentGroup
  (Name, Description, MinBundleComponents, MaxBundleComponents, Sequence)
VALUES ('Choose Phone', 'Pick your device', 1, 1, 10),
       ('Choose Plan',  'Pick your plan',   1, 1, 20);

-- Components — phones (dynamic via classification)
INSERT INTO ProductRelatedComponent
  (ParentProductId, ChildProductClassificationId,
   ProductComponentGroupId, ProductRelationshipTypeId,
   Quantity, MinQuantity, MaxQuantity,
   IsComponentRequired, IsDefaultComponent, IsQuantityEditable,
   QuoteVisibility, Sequence)
VALUES (:BundleId, :SmartphonesClassId,
        :ChoosePhoneGroupId, :BundleComponentTypeId,
        1, 1, 1, true, false, false,
        'Always', 10);

-- Components — specific plan products
INSERT INTO ProductRelatedComponent
  (ParentProductId, ChildProductId,
   ProductComponentGroupId, ProductRelationshipTypeId,
   Quantity, MinQuantity, MaxQuantity,
   IsComponentRequired, IsDefaultComponent, IsQuantityEditable,
   QuoteVisibility, Sequence)
VALUES (:BundleId, :BasicPlanId, :ChoosePlanGroupId, :BundleComponentTypeId,
        1, 1, 1, true, true, false, 'Always', 10),
       (:BundleId, :ProPlanId,   :ChoosePlanGroupId, :BundleComponentTypeId,
        1, 1, 1, true, false, false, 'Always', 20);
```

## Diagnose checklist — "my bundle isn't behaving"

1. `Product2.Type = 'Bundle'`?
2. `ConfigureDuringSale` set correctly (`Allowed` for configurable, `Not Allowed` for static)?
3. Configurable bundle: every `ProductRelatedComponent` has a `ProductComponentGroupId`?
4. Group cardinality (`Min/MaxBundleComponents`) is sane (Min ≤ Max)?
5. Component cardinality consistent with the group's? E.g., a required component (Min ≥ 1) in a group with `MinBundleComponents = 0` is contradictory.
6. Overrides scoped to the right `OverrideContextId` (the root bundle, not a sub-bundle)?
7. `ProductRelationshipType` row exists and is active?
8. Run **Validate Product Definition** in the UI.
