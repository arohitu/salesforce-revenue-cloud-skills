# Product Variants

Variants group related products that share an identity but differ on a few attributes (size, color, storage). Instead of N standalone products with no link, you have one **variation parent** umbrella record and N purchasable **variation product** children.

## Variation Parent

A non-purchasable `Product2` whose role is to group its variants.

- `Product2.Type = 'VariationParent'`.
- Stores info shared by all variants (description, marketing content, hero attributes).
- Not orderable; users cannot quote it directly.

## Variation Product

A purchasable `Product2` that represents one specific combination of variation attributes.

- `Product2.Type = 'Variation'`.
- Linked to its parent (via the variation relationship; the link is set up through Product Variants UI, which manages the underlying records).
- **Each variation has a unique `ProductCode` (SKU)** — required for inventory, pricing, and revenue tracking.

## Variation Attribute Set

A logical grouping of up to **5 attributes** that defines what makes each variant unique. Attached to the variation parent.

Example for a phone:
```
Variation Parent: "Acme Phone Pro"
  Variation Attribute Set:
    ├── Color   (Red, Green, Blue)
    ├── Storage (128 GB, 256 GB, 512 GB)
    └── Network (5G, 4G)

  Variation Products (one per combination, only purchasable ones):
    ├── Acme Phone Pro — Red, 128 GB, 5G       SKU PHN-PRO-R-128-5G
    ├── Acme Phone Pro — Red, 256 GB, 5G       SKU PHN-PRO-R-256-5G
    ├── Acme Phone Pro — Blue, 128 GB, 5G      SKU PHN-PRO-B-128-5G
    └── …
```

You don't need to create the cartesian product — only the combinations that are actually sold.

## When to use variants vs classifications

| Scenario | Use |
|---|---|
| Many products share attribute *types* but each has its own SKU (T-shirt sizes, phone storage tiers, paint colors) | **Variants** |
| Many products share attribute *types* and a runtime configurator picks values per quote (no separate SKU per combination) | **Classification + dynamic attributes** |
| You need separate inventory, pricing, or revenue per combination | **Variants** |
| You need a single product whose price/behavior changes based on user-selected attributes | **Classification** |

Rule of thumb: **separate SKUs per combination → variants. Single SKU with runtime choices → classification.**

## Setup

1. **Enable Product Variants** in Setup → Product Discovery Settings.
2. If the org uses indexed search, **reindex products** after enabling.
3. Use the Product Variants UI on the parent product to define the variation attribute set and create child variation products.
4. Each variant inherits the parent's category assignments unless you explicitly assign categories on the variant.

## Limits

- **5 attributes per variation attribute set.**
- The number of variation products is bounded only by overall product limits, but practical performance starts to degrade past a few hundred per parent — group catalogs accordingly.

## Gotchas

- **Variation products without unique SKUs** break inventory and revenue reporting. Validate before deploy.
- **Indexed search out of date**: a variant that exists but doesn't show up in Browse Catalogs is almost always a missing reindex.
- **Cannot mix**: a `Product2` is either `VariationParent`, `Variation`, `Bundle`, or simple. You cannot make a variation product also a bundle parent.
- **Variation parent not orderable**: users sometimes assume the parent is a sellable SKU. It's not — surface only the variation children in quotes/orders.
