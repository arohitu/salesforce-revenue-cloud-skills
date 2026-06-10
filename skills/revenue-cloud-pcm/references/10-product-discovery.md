# Product Discovery

Product Discovery is the runtime experience that surfaces the catalog to users — sales reps, customers, partners. It runs as Lightning components on a quote/order page (Browse Catalogs button) and on Experience Cloud sites.

## What it does

- Renders catalogs, categories, and products in list or tile view.
- Runs the **qualification procedure** to filter products/categories per user context.
- Runs the **pricing procedure** (optional) to compute prices alongside the listing.
- Provides search (basic, field-based, or indexed up to 20M products).
- Provides **Guided Product Selection** — a question-driven path that narrows down products.
- Hands off to the **Product Configurator** when a user picks a configurable bundle.

## Configuration entry point

**Setup → Product Discovery Settings.** Settings live on the `ProductDiscoverySettings` Metadata API object.

Key settings:

| Setting | Purpose |
|---|---|
| Default Catalog | The catalog auto-loaded when Browse Catalogs is clicked. |
| Qualification Procedure | An Expression Set / Decision Procedure that evaluates qualification rules. |
| Pricing Procedure | Computes prices at discovery time (optional — without it, pricing is deferred to the configurator/quote). |
| Search Mode | `Basic`, `Field-Based`, or `Indexed`. |
| Indexed Search Cap | Up to 20M products supported. |
| Product Variants | Toggle to enable variants (requires reindex on enable). |
| Guided Product Selection | Toggle. Defines the question flow. |
| Einstein AI Description Generation | Toggle. AI-generated product descriptions for the listing. |
| Display Fields | Up to 3 additional `Product2` fields to show in listings. |
| List vs Tile | Default view; users can switch if both enabled. |

## ProductDiscoveryContext

A specialized context definition that carries data through the qualification and pricing procedures. Standard nodes:

- **Input**: Account, Catalog, Category, CategoryProduct, PricingProduct.
- **Output**: includes `IsQualified` / `IsDisqualified` (used by qualification rules).

Custom nodes can be added if you need to pass additional input (e.g., region, user segment, opportunity stage).

## Browse Catalogs (the runtime button)

Added to standard quote/order pages by Lightning App Builder, or available as a flow override.

Standard flow:
1. User clicks **Browse Catalogs** on a quote.
2. Default catalog loads. (If multi-catalog enabled, user picks.)
3. Qualification procedure runs — filtered category/product list returns.
4. User browses, searches, or invokes Guided Product Selection.
5. User adds product to quote.
6. If product is a configurable bundle: **Product Configurator** flow takes over.
7. Selected lines + selling model are sent to Pricing → Transaction Manager → quote line.

Customizable via Lightning App Builder or Flow Builder; the standard flow is "Discover Products."

## Guided Product Selection

A question-driven flow ("Guide Me" button) that asks the user a series of questions and narrows products down. Implemented via:

- A flow that collects answers.
- Decision tables that map answers to products/categories.
- The qualification procedure (or a sibling procedure) that evaluates the answers.

Use when the catalog is large and customers don't know exactly which product they need.

## Search

| Mode | Use when | Cap |
|---|---|---|
| Basic | Tiny catalogs, dev orgs | <100 products |
| Field-Based | Custom fields searchable, no indexing required | Reasonable for ~10k products |
| Indexed | Large catalogs, fast typeahead, partial-match | Up to 20M products (1M default; contact Support to expand to 20M) |

After bulk imports, **trigger a reindex** from Product Discovery Settings. Without it, new products won't surface in indexed search.

Searchable / filterable fields: combined cap of **87** across all PCM searchable objects.

## Product Discovery Components (Lightning)

Drop these on Lightning App Builder pages or Experience Cloud sites:

- **Product List** — the grid/list of products with filters and search.
- **Product Details** — full detail view (description, images, attributes, pricing).
- **Product Bundle Details** — the configurator-like view for bundle structure.
- **Product Attribute Details** — focused view of a product's dynamic attributes.

## Constraint Rules (preview at discovery time)

Constraint rules from Product Configurator can be evaluated in real time during discovery to disable incompatible products or surface recommendation messages. Non-blocking — the user can still proceed; the warning is informational at the discovery layer. Hard validation happens in the configurator.

## Translation / localization

PCM objects support translation via the Translation Workbench. After translating product/category/attribute data, reindex products to make translated values searchable. Users see content in the language configured on their user record.

## Diagnose checklist — "products don't show in Browse Catalogs"

Walk through this exactly in order:

1. Default catalog set in Product Discovery Settings?
2. User has at least the `ProductCatalogManagementViewer` permission set?
3. `Catalog.EffectiveStartDate` reached, `EffectiveEndDate` not passed?
4. Products have `IsActive = true`, within `AvailabilityDate` / `DiscontinuedDate`?
5. `ProductCategoryProduct` rows exist linking the products to a visible category?
6. Qualification procedure (if configured) is publishing (`IsQualified = true`) for these products in this user's context?
7. No active `ProductDisqualification` overriding (remember qualification beats disqualification, but only when both fire)?
8. Search index up to date? Trigger a reindex after bulk loads.
9. Search mode appropriate for catalog size?

## Recipe — flip a catalog over to indexed search

1. Setup → Product Discovery Settings.
2. Switch Search Mode to `Indexed`.
3. Click "Index Products" to build the initial index.
4. Wait for build to complete (asynchronous).
5. Verify a sample query returns expected results.
6. After any future bulk product import: re-trigger Index Products.

## Custom Discover Products flow with ramp segments

If the org sells ramp deals, the standard Discover Products flow can be cloned/extended in Flow Builder to include a **Select Ramp Segments** screen. Override the default flow in Product Discovery Settings to point at the custom one.
