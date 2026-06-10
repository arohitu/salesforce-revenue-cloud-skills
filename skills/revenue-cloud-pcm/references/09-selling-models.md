# Selling Models

Selling models define **how** a product is sold: one-time purchase, fixed-term subscription, or evergreen subscription. They are reusable templates linked to products via `ProductSellingModelOption`.

## ProductSellingModel

| Field | Type | Notes |
|---|---|---|
| `Name` | String | Human-readable name. |
| `SellingModelType` | Picklist | `OneTime`, `TermDefined`, `Evergreen`. |
| `PricingTerm` | Number | Duration (e.g., `12`). Required for `TermDefined` and `Evergreen`. |
| `PricingTermUnit` | Picklist | `Years`, `Months`, etc. Required when `PricingTerm` is set. |
| `Status` | Picklist | `Draft` / `Active` / `Inactive`. |

### One-Time

A purchase, not a subscription. No term, no renewal.

### Term Defined

A subscription with a fixed end date. Has `PricingTerm` + `PricingTermUnit`. Optional `Automatically Renew Asset by Default` flag drives whether assets renew automatically when the term ends.

### Evergreen

A recurring subscription with no fixed end — runs until the user cancels. Also has `PricingTerm` + `PricingTermUnit`, which define the billing/period cadence rather than a stop date.

## ProductSellingModelOption

The junction that links a `Product2` to a `ProductSellingModel`. A product can be sold under multiple selling models — e.g., monthly *and* annual subscription.

| Field | Type | Notes |
|---|---|---|
| `Product2Id` | Lookup → Product2 | The product. |
| `ProductSellingModelId` | Lookup → ProductSellingModel | The model. |
| `IsDefault` | Boolean | Default model for this product. **Only one option per product can be `IsDefault = true`**. |
| `ProrationPolicy` | Picklist | How proration is handled when a customer starts mid-period. |

### Proration policies

`ProrationPolicy` controls what happens when a customer starts mid-period:

- `Standard` — customer pays only for subscribed time; leftover amount is added to the start of the next subscription cycle.
- (Org-extensible) — the picklist can be extended via picklist value sets.

The selling model's proration policy passes through to the order line and downstream Billing.

## Auto-renewal

`Automatically Renew Asset by Default` (a flag on the selling model or option, depending on org configuration) determines whether the asset auto-renews when the term ends. Reps can edit this on quote/order line items; it carries through from quote → order.

## ProductRampSegment (v62+)

Used when a product is part of a **ramp deal** — terms, volumes, and commitments that change over phases of the contract.

| Field | Type | Notes |
|---|---|---|
| `ProductId` | Lookup → Product2 | The product. **Required.** |
| `ProductSellingModelId` | Lookup → ProductSellingModel | Selling model. **Required.** |
| `SegmentType` | Picklist | `Custom`, `FreeTrial`, `Yearly` (default). |
| `TrialDuration` | Number | For `FreeTrial`. |
| `DurationType` | Picklist | `Days`, `Months` (for free trial). |

`Product2.CanRamp` must be `true` for a product to participate in ramp segments.

## When to use which model

| Scenario | Selling model |
|---|---|
| Hardware sale | `OneTime` |
| Annual SaaS contract with auto-renewal | `TermDefined` (term = 1, unit = Years, auto-renew = true) |
| Monthly subscription, cancel anytime | `Evergreen` (term = 1, unit = Months) |
| Multi-year contract with year-over-year price increases | `TermDefined` + `ProductRampSegment` rows |
| Free trial leading into paid plan | Two products linked via runtime flow; or one selling model with `ProductRampSegment` of type `FreeTrial` |

## Limits / behavior

- **Selling models are optional.** PCM works without them; they're required only if you sell anything subscription-like.
- A product without `ProductSellingModelOption` rows defaults to a one-time sale at runtime if pricing is set up that way.
- A product with multiple options shows the user a model picker at quote time.
- Status transitions on `ProductSellingModel`: `Draft → Active → Inactive`. **Cannot revert** to `Draft` once moved out of it.

## Recipe — annual subscription with monthly option

```sql
-- Annual model
INSERT INTO ProductSellingModel
  (Name, SellingModelType, PricingTerm, PricingTermUnit, Status)
VALUES ('Annual Subscription', 'TermDefined', 1, 'Years', 'Active');

-- Monthly evergreen
INSERT INTO ProductSellingModel
  (Name, SellingModelType, PricingTerm, PricingTermUnit, Status)
VALUES ('Monthly Subscription', 'Evergreen', 1, 'Months', 'Active');

-- Link to product, annual is default
INSERT INTO ProductSellingModelOption
  (Product2Id, ProductSellingModelId, IsDefault, ProrationPolicy)
VALUES (:ProductId, :AnnualModelId, true,  'Standard'),
       (:ProductId, :MonthlyModelId, false, 'Standard');
```

## Recipe — three-year ramp deal

```sql
-- Mark the product as ramp-capable
UPDATE Product2 SET CanRamp = true WHERE Id = :ProductId;

-- Create three yearly ramp segments
INSERT INTO ProductRampSegment
  (ProductId, ProductSellingModelId, SegmentType, Name)
VALUES (:ProductId, :ThreeYearModelId, 'Yearly', 'Year 1'),
       (:ProductId, :ThreeYearModelId, 'Yearly', 'Year 2'),
       (:ProductId, :ThreeYearModelId, 'Yearly', 'Year 3');
```

The actual term and volume per segment are configured in the ramp deal flow at quote time — see the Ramp Deals module.
