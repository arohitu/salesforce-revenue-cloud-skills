# PCM Object Reference

Field-level reference for every PCM object. Tables omit standard audit fields (`CreatedById`, `CreatedDate`, `LastModifiedById`, `LastModifiedDate`, `SystemModstamp`, `IsDeleted`, `LastReferencedDate`, `LastViewedDate`) — assume they are present on every object.

All listed objects support `create, delete, describeLayout, describeSObjects, getDeleted, getUpdated, query, retrieve, search, undelete, update, upsert` unless noted. API version reflects when the object was first available.

## Index

- [AttributeCategory](#attributecategory)
- [AttributeCategoryAttribute](#attributecategoryattribute)
- [AttrPicklistExcludedValue](#attrpicklistexcludedvalue)
- [AttributeDefinition](#attributedefinition)
- [AttributePicklist](#attributepicklist)
- [AttributePicklistValue](#attributepicklistvalue)
- [Catalog](#catalog) (also called ProductCatalog)
- [Product2](#product2) (PCM-specific fields)
- [ProductAttributeDefinition](#productattributedefinition)
- [ProductCatalogManagementSettings](#productcatalogmanagementsettings) (Metadata API)
- [ProductCategory](#productcategory)
- [ProductCategoryProduct](#productcategoryproduct)
- [ProductCategoryDisqual](#productcategorydisqual)
- [ProductCategoryQualification](#productcategoryqualification)
- [ProductClassification](#productclassification)
- [ProductClassificationAttr](#productclassificationattr)
- [ProductClassificationParent](#productclassificationparent)
- [ProductComponentGroup](#productcomponentgroup)
- [ProductComponentGrpOverride](#productcomponentgrpoverride)
- [ProductDisqualification](#productdisqualification)
- [ProductDiscoverySettings](#productdiscoverysettings) (Metadata API)
- [ProductQualification](#productqualification)
- [ProductRampSegment](#productrampsegment)
- [ProductRelatedComponent](#productrelatedcomponent)
- [ProductRelComponentOverride](#productrelcomponentoverride)
- [ProductRelationshipType](#productrelationshiptype)
- [ProductSellingModel](#productsellingmodel)
- [ProductSellingModelOption](#productsellingmodeloption)
- [ProductSpecificationRecType](#productspecificationrectype) (Metadata API)
- [ProductSpecificationType](#productspecificationtype) (Metadata API)

---

## AttributeCategory

A logical grouping of reusable attributes. API v60+.

| Field | Type | Required | Description |
|---|---|---|---|
| `Code` | String(80) | Yes | Unique alphanumeric code. Supports `@!-<>*?+=%#()/\&'£€$"`. |
| `Description` | Textarea | No | Design-time description. |
| `Name` | String(80) | Yes | Display name. |
| `OwnerId` | Reference (Group/User) | No | Owner. |

## AttributeCategoryAttribute

Junction: `AttributeCategory` ↔ `AttributeDefinition`. API v60+.

| Field | Type | Required | Description |
|---|---|---|---|
| `AttributeCategoryId` | Lookup → AttributeCategory | Yes | The category. |
| `AttributeDefinitionId` | Lookup → AttributeDefinition | Yes | The attribute. |
| `Name` | String(80) | Yes | Auto-numbered name. |
| `OwnerId` | Reference (Group/User) | No | Owner. |

## AttrPicklistExcludedValue

Excludes a picklist value for a specific classification or product attribute. API v61+.

| Field | Type | Required | Description |
|---|---|---|---|
| `AttributeId` | Polymorphic → ProductClassificationAttr / ProductAttributeDefinition | Yes | Which attachment to constrain. |
| `AttributePicklistValueId` | Lookup → AttributePicklistValue | Yes | The value to exclude. |
| `Name` | String | Yes | Auto-numbered. |
| `OwnerId` | Reference | No | Owner. |

## AttributeDefinition

The core, reusable attribute definition. API v60+.

| Field | Type | Required | Description |
|---|---|---|---|
| `Name` | String | Yes | Internal name. |
| `Label` | String | No | Display name. |
| `DataType` | Picklist | No | `Checkbox`, `Currency` (v61+), `Date`, `Datetime`, `Number`, `Percent` (v61+), `Picklist`, `Text`. |
| `IsActive` | Boolean | No | Only active attributes are usable. |
| `DefaultValue` | String | No | Default value. |
| `HelpText` | Textarea | No | End-user help. |
| `AttributePicklistId` | Lookup → AttributePicklist | No | Required when `DataType = Picklist`. |

## AttributePicklist

Reusable named set of picklist values. API v60+.

| Field | Type | Required | Description |
|---|---|---|---|
| `Name` | String | Yes | Picklist name. |
| `DataType` | Picklist | No | Underlying value type. |
| `Status` | Picklist | No | `Draft`/`Active`/`Inactive`. |

## AttributePicklistValue

A single value in an `AttributePicklist`. API v60+.

| Field | Type | Required | Description |
|---|---|---|---|
| `AttributePicklistId` | Lookup | Yes | Parent picklist. |
| `Name` | String | Yes | Value display name. |
| `Code` | String | No | Code/abbreviation. |
| `Abbreviation` | String | No | Alt label. |
| `Status` | Picklist | No | `Draft`/`Active`/`Inactive`. |
| `IsDefault` | Boolean | No | Default value at design time. |
| `DisplayValue` | String | No | Value shown to end users. |
| `Sequence` | Integer | No | Render order. |

## Catalog

(Also referenced as `ProductCatalog`.) Top-level container. API v60+.

| Field | Type | Required | Description |
|---|---|---|---|
| `Name` | String | Yes | Catalog name. |
| `Code` | String(80) | No | Unique identifier. |
| `Description` | Textarea(255) | No | Description. |
| `EffectiveStartDate` | DateTime | No | Activation date. |
| `EffectiveEndDate` | DateTime | No | End-of-life date. |
| `CatalogType` | Picklist | No | `Sales`, `ServiceProcess`. |

## Product2

PCM extends the standard `Product2`. PCM-relevant fields below. API v60+.

| Field | Type | Required | Description |
|---|---|---|---|
| `Name` | String | Yes | Product name. |
| `ProductCode` | String | No | SKU. |
| `Description` | Textarea | No | End-user description. |
| `IsActive` | Boolean | No | Inactive products are hidden. |
| `Type` | Picklist | No | (blank) = simple, `Bundle`, `VariationParent`, `Variation`. |
| `ConfigureDuringSale` | Picklist | No | `Allowed`, `Not Allowed`, `None`. |
| `BasedOnId` | Lookup → ProductClassification | No | Inherits attributes from this template. |
| `HelpText` | Textarea | No | Runtime help. |
| `AvailabilityDate` | DateTime | No | First available. |
| `DiscontinuedDate` | DateTime | No | Stops being orderable. |
| `EndOfLifeDate` | DateTime | No | No longer supported. |
| `CanRamp` | Boolean | No | Eligible for ramp segments. |
| `IsSoldOnlyWithOtherProducts` | Boolean | No | Cannot be sold alone. |
| `SpecificationType` | String | No | Industry specification key. |
| `DecompositionScope` | Picklist | No | (v61+) Number of fulfillment line items. |
| `FulfillmentQtyCalcMethod` | Picklist | No | (v61+) Quantity is one or aggregated. |
| `UsageModelType` | Picklist | No | (v62+) `Anchor` or `Pack`. |

## ProductAttributeDefinition

Per-product attribute attachment / override. API v60+.

| Field | Type | Required | Description |
|---|---|---|---|
| `Product2Id` | Lookup → Product2 | Yes | The product. |
| `AttributeDefinitionId` | Lookup → AttributeDefinition | Yes | The attribute. |
| `ProductClassificationAttributeId` | Lookup → ProductClassificationAttr | Yes | Classification-level row being overridden. |
| `OverriddenProductAttributeDefinitionId` | Lookup self | No | Specific inherited row being overridden. |
| `OverrideContextId` | Polymorphic → Product2 (root bundle) | No | Bundle scope of the override. |
| `AttributeCategoryId` | Lookup → AttributeCategory | No | Render category. |
| `AttributeNameOverride` | String(255) | No | Display name override. |
| `DefaultValue` | String | No | Default. |
| `Description` | Textarea(32k) | No | Description. |
| `DisplayType` | Picklist | No | `CheckBox`,`ComboBox`,`Date`,`Datetime`,`Number`,`RadioButton`,`Slider`,`Text`,`Toggle`. |
| `HelpText` | Textarea | No | Help. |
| `IsHidden` | Boolean | No | Hidden at runtime. |
| `IsPriceImpacting` | Boolean | No | Affects price. |
| `IsReadOnly` | Boolean | No | Read-only at runtime. |
| `IsRequired` | Boolean | No | User must provide value. |
| `MaximumCharacterCount` | Integer | No | Max length (text). |
| `MaximumValue` | String | No | Max value. |
| `MinimumCharacterCount` | Integer | No | Min length. |
| `MinimumValue` | String | No | Min value. |
| `Name` | String | Yes | Name. |
| `Sequence` | Integer | No | Render order. |
| `Status` | Picklist | No | `Active`/`Draft`/`Inactive`. |
| `StepValue` | String | No | Slider step. |
| `ValueDescription` | Textarea | No | Description of value. |
| `OwnerId` | Reference | No | Owner. |

## ProductCatalogManagementSettings

Metadata API. PCM feature configuration. API v64+.

| Field | Type | Description |
|---|---|---|
| `productDeepCloneContextDefOrgValue` | String | Context definition for deep cloning products. |
| `productDeepCloneExpressionSetOrgValue` | String | Expression set with deep-clone rules. |

## ProductCategory

Hierarchical container inside a catalog. API v60+.

| Field | Type | Required | Description |
|---|---|---|---|
| `Code` | String(80) | No | Unique alphanumeric. |
| `Name` | String | Yes | Category name. |
| `Description` | Textarea | No | Description. |
| `CatalogId` | Lookup → Catalog | Yes | Parent catalog. |
| `ParentCategoryId` | Lookup self | No | Parent category (null = root). |
| `SortOrder` | Number | No | Render order. |
| `ShowInMenu` | Boolean | No | Render in nav menu. |
| `IsNavigational` | Boolean | No | (v62+) Show as breadcrumb. |

## ProductCategoryProduct

Junction: products ↔ categories. API v60+.

| Field | Type | Required | Description |
|---|---|---|---|
| `ProductId` | Lookup → Product2 | Yes | The product. |
| `ProductCategoryId` | Lookup → ProductCategory | Yes | The category. |
| `IsPrimaryCategory` | Boolean | No | Marks the canonical category for this product. |

## ProductCategoryDisqual

Category-level disqualification rule. API v60+.

| Field | Type | Required | Description |
|---|---|---|---|
| `CategoryId` | Lookup → ProductCategory | Yes | Target category. |
| `EffectiveFromDate` | Date | No | Start of rule. |
| `EffectiveToDate` | Date | No | End of rule. |
| `IsDisqualified` | Boolean | No | Set by qualification procedure. |
| `Name` | String | No | Auto-numbered. |
| `Reason` | String | No | Reason. |
| `OwnerId` | Reference | No | Owner. |

## ProductCategoryQualification

Category-level qualification rule. API v60+.

| Field | Type | Required | Description |
|---|---|---|---|
| `CategoryId` | Lookup → ProductCategory | Yes | Target. |
| `EffectiveFromDate` | Date | No | Start. |
| `EffectiveToDate` | Date | No | End. |
| `IsQualified` | Boolean | No | Set by procedure. |
| `Name` | String | No | Auto-numbered. |
| `OwnerId` | Reference | No | Owner. |

## ProductClassification

Reusable attribute template. API v60+.

| Field | Type | Required | Description |
|---|---|---|---|
| `Code` | String(80) | Yes | Unique alphanumeric. |
| `Name` | String(80) | Yes | Template name. |
| `Status` | Picklist | No | `Draft`/`Active`/`Inactive`. |
| `OwnerId` | Reference | No | Owner. |

## ProductClassificationAttr

Attribute attachment on a classification template. API v60+.

| Field | Type | Required | Description |
|---|---|---|---|
| `ProductClassificationId` | Lookup → ProductClassification | Yes | The template. |
| `AttributeDefinitionId` | Lookup → AttributeDefinition | Yes | The attribute. |
| `AttributeCategoryId` | Lookup → AttributeCategory | No | Render under this category. |
| `AttributeNameOverride` | String | No | Display name override. |
| `DefaultValue` | String | No | Default. |
| `Description` | Textarea | No | Description. |
| `DisplayType` | Picklist | No | `CheckBox`,`ComboBox`,`Date`,`Datetime`,`Number`,`RadioButton`,`Slider`,`Text`,`Toggle`. |
| `ExcludedPicklistValues` | Textarea | No | Inline excluded values (legacy; prefer `AttrPicklistExcludedValue`). |
| `HelpText` | Textarea | No | Help. |
| `IsHidden` | Boolean | No | Hidden. |
| `IsPriceImpacting` | Boolean | No | Affects price. |
| `IsReadOnly` | Boolean | No | Read-only. |
| `IsRequired` | Boolean | No | Must have value. |
| `MaximumCharacterCount` | Integer | No | Max length. |
| `MaximumValue` | String | No | Max value. |
| `MinimumCharacterCount` | Integer | No | Min length. |
| `MinimumValue` | String | No | Min value. |
| `Name` | String | Yes | Name. |
| `Sequence` | Integer | No | Render order. |
| `Status` | Picklist | No | `Active`/`Draft`/`Inactive`. |
| `StepValue` | String | No | Slider step. |
| `ValueDescription` | Textarea | No | Description. |
| `OwnerId` | Reference | No | Owner. |

## ProductClassificationParent

Parent → child classification hierarchy. API v60+.

| Field | Type | Required | Description |
|---|---|---|---|
| `ParentClassificationId` | Lookup → ProductClassification | Yes | Parent template. |
| `ChildProductClassificationId` | Lookup → ProductClassification | Yes | Child template. |

## ProductComponentGroup

Section within a configurable bundle. API v62+.

| Field | Type | Required | Description |
|---|---|---|---|
| `Name` | String | Yes | Group name. |
| `Description` | Textarea | No | Section help. |
| `MinBundleComponents` | Integer | No | Min selections. |
| `MaxBundleComponents` | Integer | No | Max selections. |
| `Sequence` | Integer | No | Render order. |
| `ParentGroupId` | Lookup self | No | Nested group parent (max 2 levels). |
| `IsConfigurable` | Boolean | No | Whether the group is user-configurable. |

## ProductComponentGrpOverride

Per-bundle override of group cardinality. API v60+.

| Field | Type | Required | Description |
|---|---|---|---|
| `ProductComponentGroupId` | Lookup → ProductComponentGroup | Yes | The group. |
| `OverrideContextId` | Polymorphic → Product2 (root) | Yes | Bundle scope. |
| `IsExcluded` | Boolean | No | Group removed in this bundle. |
| `MaxBundleComponents` | Integer | No | Override max. |
| `MinBundleComponents` | Integer | No | Override min. |
| `Name` | String | No | Auto-numbered. |
| `OwnerId` | Reference | No | Owner. |

Supported calls do not include `search`.

## ProductDisqualification

Product-level disqualification rule. API v60+.

| Field | Type | Required | Description |
|---|---|---|---|
| `ProductId` | Lookup → Product2 | Yes | Target product. |
| `ParentProductId` | Lookup → Product2 | No | Immediate parent in bundle. |
| `RootProductId` | Lookup → Product2 | No | Top-level bundle. |
| `IsDisqualified` | Boolean | No | Set by procedure. |
| `EffectiveFromDate` | Date | No | Start of rule. |
| `EffectiveToDate` | Date | No | End of rule. |
| `Name` | String | No | Auto-numbered. |
| `Reason` | Textarea | No | Reason. |
| `OwnerId` | Reference | No | Owner. |

## ProductDiscoverySettings

Metadata API. Configures Product Discovery behavior. API v64+.

Settings include: default catalog, qualification procedure, pricing procedure, search mode, indexed search cap, product variants toggle, guided selection toggle, Einstein description toggle, display fields, list/tile default. Accessed only via Metadata API.

## ProductQualification

Product-level qualification rule. API v60+.

| Field | Type | Required | Description |
|---|---|---|---|
| `ProductId` | Lookup → Product2 | Yes | Target product. |
| `ParentProductId` | Lookup → Product2 | No | Immediate parent in bundle. |
| `RootProductId` | Lookup → Product2 | No | Top-level bundle. |
| `IsQualified` | Boolean | No | Set by procedure. |
| `EffectiveFromDate` | Date | No | Start. |
| `EffectiveToDate` | Date | No | End. |
| `Name` | String | No | Auto-numbered. |
| `OwnerId` | Reference | No | Owner. |

## ProductRampSegment

Ramp deal segment. API v62+.

| Field | Type | Required | Description |
|---|---|---|---|
| `ProductId` | Lookup → Product2 | Yes | Product (must have `CanRamp = true`). |
| `ProductSellingModelId` | Lookup → ProductSellingModel | Yes | Selling model. |
| `SegmentType` | Picklist | No | `Custom`, `FreeTrial`, `Yearly` (default). |
| `TrialDuration` | Integer | No | Free-trial length. |
| `DurationType` | Picklist | No | `Days`, `Months`. |
| `Name` | String | No | Auto-numbered. |
| `OwnerId` | Reference | No | Owner. |

## ProductRelatedComponent

Bundle component line. API v60+.

| Field | Type | Required | Description |
|---|---|---|---|
| `ParentProductId` | Lookup → Product2 | Yes | Bundle parent. |
| `ChildProductId` | Lookup → Product2 | No* | Specific child product. |
| `ChildProductClassificationId` | Lookup → ProductClassification | No* | Dynamic child by classification. (*one of `ChildProductId` or `ChildProductClassificationId` is required) |
| `ProductComponentGroupId` | Lookup → ProductComponentGroup | No (Yes for configurable) | Group containing this line. |
| `ProductRelationshipTypeId` | Lookup → ProductRelationshipType | Yes | Role. |
| `Quantity` | Number | No | Default quantity. |
| `MinQuantity` | Number | No | Min quantity. |
| `MaxQuantity` | Number | No | Max quantity. |
| `IsQuantityEditable` | Boolean | No | User can edit. |
| `IsComponentRequired` | Boolean | No | Required to ship. |
| `IsDefaultComponent` | Boolean | No | Pre-selected. |
| `DoesBundlePriceIncludeChild` | Boolean | No | Parent price covers this child. |
| `Sequence` | Integer | No | Render order. |
| `QuoteVisibility` | Picklist | No | `Always`,`Never`,`TransactionLineEditorOnly`,`QuoteDocumentOnly`. |
| `QuantityScaleMethod` | Picklist | No | `None`,`Constant`,`Proportional`. |

## ProductRelComponentOverride

Per-bundle override of a component's cardinality. API v60+.

| Field | Type | Required | Description |
|---|---|---|---|
| `ProductRelatedComponentId` | Lookup → ProductRelatedComponent | Yes | Line being overridden. |
| `OverrideContextId` | Polymorphic → Product2 (root) | Yes | Bundle scope. |
| `IsExcluded` | Boolean | No | Removed in this bundle. |
| `IsComponentRequired` | Boolean | No | Override required. |
| `IsDefaultComponent` | Boolean | No | Override default. |
| `IsQuantityEditable` | Boolean | No | Override editability. |
| `DoesBundlePriceIncludeChild` | Boolean | No | Override price-inclusion. |
| `Quantity` | Number | No | Override quantity. |
| `MaxQuantity` | Number | No | Override max. |
| `MinQuantity` | Number | No | Override min. |
| `QuantityScaleMethod` | Picklist | No | `Constant`,`Proportional`. |
| `Name` | String | No | Auto-numbered. |
| `OwnerId` | Reference | No | Owner. |

## ProductRelationshipType

Defines roles for product relationships. API v60+.

| Field | Type | Required | Description |
|---|---|---|---|
| `Name` | String | Yes | Role name. |
| `Code` | String | No | Role code. |
| `AssociatedProductRoleCat` | Picklist | No | (v61+) `BundleComponent`, `ClassificationComponent`. |

## ProductSellingModel

Defines how a product is sold. API v60+.

| Field | Type | Required | Description |
|---|---|---|---|
| `Name` | String | Yes | Model name. |
| `SellingModelType` | Picklist | Yes | `OneTime`, `TermDefined`, `Evergreen`. |
| `PricingTerm` | Number | Conditional | Required for `TermDefined`/`Evergreen`. |
| `PricingTermUnit` | Picklist | Conditional | `Years`, `Months`, etc. |
| `Status` | Picklist | No | `Draft`/`Active`/`Inactive`. |

## ProductSellingModelOption

Junction: `Product2` ↔ `ProductSellingModel`. API v60+.

| Field | Type | Required | Description |
|---|---|---|---|
| `Product2Id` | Lookup → Product2 | Yes | Product. |
| `ProductSellingModelId` | Lookup → ProductSellingModel | Yes | Model. |
| `IsDefault` | Boolean | No | Default for the product. |
| `ProrationPolicy` | Picklist | No | Proration handling. |

## ProductSpecificationRecType

Metadata API. Links specification types to Product record types. API v60+.

| Field | Type | Required | Description |
|---|---|---|---|
| `DeveloperName` | String(40) | Yes | Unique API name (letters/underscores; cannot end with `_`). |
| `IsCommercial` | Boolean | No | Sold commercially. |
| `Language` | Picklist | No | Locale: `da`,`de`,`en_US`,`es`,`es_MX`,`fi`,`fr`,`it`,`ja`,`ko`,`nl_NL`,`no`,`pt_BR`,`ru`,`sv`,`th`,`zh_CN`,`zh_TW`. |
| `MasterLabel` | String | Yes | Internal display label (not translated). |
| `NamespacePrefix` | String(15) | No | Managed-package namespace. |
| `ProductSpecificationType` | Picklist | Yes | Linked spec type. |
| `RecordTypeId` | Lookup → RecordType | Yes | Product2 record type. |

Supported calls: `create, delete, describeSObjects, query, retrieve, update, upsert`.

## ProductSpecificationType

Metadata API. Industry-specific product specification taxonomy. API v60+.

| Field | Type | Required | Description |
|---|---|---|---|
| `DeveloperName` | String(40) | Yes | Unique API name. |
| `Description` | Textarea | No | Description. |
| `Language` | Picklist | No | Locale (same set as above). |
| `MasterLabel` | String | Yes | Display label. |
| `NamespacePrefix` | String(15) | No | Namespace prefix. |
| `ManageableState` | Picklist | No | `beta`,`deleted`,`deprecated`,`deprecatedEditable`,`installed`,`installedEditable`,`released`,`unmanaged`. |

Supported calls: `create, delete, describeSObjects, query, retrieve, update, upsert`.

---

## Cross-reference index — by relationship

```
Catalog ──< ProductCategory ──< ProductCategory (self)
                                   │
                                   └──< ProductCategoryProduct >── Product2

Product2 ──> ProductClassification (BasedOnId)
ProductClassification ──< ProductClassificationAttr >── AttributeDefinition
ProductClassification ──< ProductClassificationParent >── ProductClassification
AttributeDefinition ──> AttributePicklist ──< AttributePicklistValue

Product2 ──< ProductAttributeDefinition >── AttributeDefinition
ProductAttributeDefinition ──> ProductClassificationAttr  (the inherited row)

AttrPicklistExcludedValue ──> ProductClassificationAttr | ProductAttributeDefinition
AttrPicklistExcludedValue ──> AttributePicklistValue

Product2 (parent) ──< ProductRelatedComponent >── Product2 (child)  | ProductClassification (child)
ProductRelatedComponent ──> ProductComponentGroup
ProductComponentGroup ──> ProductComponentGroup (parent, v62+)
ProductRelatedComponent ──> ProductRelationshipType

ProductRelComponentOverride ──> ProductRelatedComponent
ProductRelComponentOverride ──> Product2 (root, via OverrideContextId)
ProductComponentGrpOverride ──> ProductComponentGroup
ProductComponentGrpOverride ──> Product2 (root, via OverrideContextId)

ProductQualification ──> Product2
ProductDisqualification ──> Product2
ProductCategoryQualification ──> ProductCategory
ProductCategoryDisqual ──> ProductCategory

Product2 ──< ProductSellingModelOption >── ProductSellingModel
Product2 ──< ProductRampSegment >── ProductSellingModel
```
