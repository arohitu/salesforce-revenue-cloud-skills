# Qualification and Disqualification Rules

Qualification rules say "this product/category is eligible for this user/account/context." Disqualification rules say "this product/category is *not* eligible." You use them when product visibility depends on customer attributes (region, segment, owned products, etc.).

## The four rule objects

| Object | Scope | Sense |
|---|---|---|
| `ProductQualification` | Product | Positive — explicit qualification |
| `ProductDisqualification` | Product | Negative — explicit disqualification |
| `ProductCategoryQualification` | Category | Positive |
| `ProductCategoryDisqual` | Category | Negative |

## Default behavior

**No rule = qualified.** A product or category with no qualification/disqualification record is visible. You write a rule to *restrict*, not to *allow*.

## Precedence

Qualification beats disqualification. If both a `ProductQualification` (with `IsQualified = true`) and a `ProductDisqualification` (with `IsDisqualified = true`) match, the product is **qualified** (visible).

This precedence is a deliberate Salesforce design — it lets you write broad disqualification rules and add narrow positive overrides without rewiring everything.

## Schemas

### ProductQualification

| Field | Type | Notes |
|---|---|---|
| `ProductId` | Lookup → Product2 | The product. **Required.** |
| `ParentProductId` | Lookup → Product2 | Immediate parent in bundle hierarchy. |
| `RootProductId` | Lookup → Product2 | Top-level bundle. |
| `IsQualified` | Boolean | Set by the qualification procedure. |
| `EffectiveFromDate` | Date | When the rule starts. |
| `EffectiveToDate` | Date | When the rule ends. |

### ProductDisqualification

Same fields as `ProductQualification` plus:

| Field | Type | Notes |
|---|---|---|
| `IsDisqualified` | Boolean | Set by the qualification procedure. |
| `Reason` | Textarea | Why disqualified. Surfaced to users in some UIs. |

### ProductCategoryQualification

| Field | Type | Notes |
|---|---|---|
| `CategoryId` | Lookup → ProductCategory | **Required.** |
| `IsQualified` | Boolean | |
| `EffectiveFromDate`, `EffectiveToDate` | Date | |

### ProductCategoryDisqual

`CategoryId`, `IsDisqualified`, `Reason`, plus the effective dates.

## Mechanics — how rules are evaluated

Rules don't evaluate themselves. The runtime needs:

1. **Decision Tables** that store the actual criteria. Salesforce ships templates for the four rule objects above. Standard tables handle <100k records; Advanced tables handle >100k.
2. **Context Definitions** that pass user/account/product data into the decision table — typically `ProductDiscoveryContext`, with input nodes (Account, Catalog, Category, CategoryProduct, PricingProduct) and output nodes that include `IsQualified` / `IsDisqualified`.
3. A **Qualification Procedure** (an Expression Set) that wires the context to the decision table and writes the result back to the qualification/disqualification record.
4. The procedure is hooked into **Product Discovery Settings** so it runs when users browse catalogs.

You author all four pieces in setup; the qualification/disqualification *records* are the persisted state, but the *evaluation* happens through the procedure each time a user enters Browse Catalogs.

## Typical patterns

### Pattern 1 — region-based product visibility

- All products visible by default.
- Disqualification rule: products tagged "EU only" disqualify when user account is outside EU.
- Decision table criteria: account country code IN/NOT IN region list.

### Pattern 2 — segment + override

- Disqualification rule: "Pro" tier products are disqualified for `AccountTier = 'Basic'`.
- Qualification rule: explicit positive qualification for `AccountTier = 'Basic' AND HasOptedIntoBeta = true`. Because qualification beats disqualification, those accounts still see Pro products.

### Pattern 3 — time-bound promotional products

- Promotional product has `ProductQualification` with `EffectiveFromDate = 2026-01-01` and `EffectiveToDate = 2026-03-31`. Outside that window, no qualification record matches → if a disqualification rule exists, product is hidden; otherwise visible by default. Pair this with a default disqualification record to make the time bound act like an availability window.

## Effective windows

`EffectiveFromDate` / `EffectiveToDate` are **inclusive**. A rule with `EffectiveFromDate = 2026-01-01` first applies on that date. A rule with `EffectiveToDate = 2026-03-31` last applies that day; on April 1 the rule is no longer active.

Both are nullable — null means "always" on that side.

## Diagnose checklist — "rule doesn't fire"

1. Effective window: is today between `EffectiveFromDate` and `EffectiveToDate`?
2. Is the rule's `IsQualified` / `IsDisqualified` actually set by the qualification procedure? Persist a test record manually with the flag set and see if visibility changes.
3. Is the decision table linked to the right standard object?
4. Is the qualification procedure assigned to the catalog's `Product Discovery Settings`?
5. Is the user's session running with the expected account context? (If running as admin, the account-driven rules may all evaluate to "no match".)
6. For decision tables of advanced type: have you rebuilt the table after editing rules? Standard tables auto-rebuild; advanced tables require an explicit rebuild.

## Recipes

### Disqualify a product after end-of-life date

```sql
INSERT INTO ProductDisqualification
  (ProductId, IsDisqualified, EffectiveFromDate, Reason, Name)
VALUES (:Product2Id, true, '2026-04-01', 'End of life — no longer sold', 'EOL Disqualification');
```

### Qualify a category for a specific window

```sql
INSERT INTO ProductCategoryQualification
  (CategoryId, IsQualified, EffectiveFromDate, EffectiveToDate, Name)
VALUES (:CategoryId, true, '2026-01-01', '2026-12-31', 'Holiday catalog window');
```

## Browse Catalogs behavior

When the user clicks Browse Catalogs:

1. The default catalog loads (or user picks one).
2. The qualification procedure runs, evaluating every category and product in scope.
3. Disqualified records are filtered out unless overridden by qualification.
4. Categories whose products are all filtered out can be hidden via Product Discovery Settings.
