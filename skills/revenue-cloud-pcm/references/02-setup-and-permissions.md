# Setup and Permissions

## Supported products and editions

| Product | Editions |
|---|---|
| Automotive Cloud | Enterprise, Unlimited, Developer |
| Energy & Utilities Cloud | Enterprise, Performance, Unlimited |
| Financial Services Cloud | Professional, Enterprise, Unlimited |
| Health Cloud | Enterprise, Unlimited |
| Life Sciences Cloud | Enterprise, Unlimited |
| Loyalty Management | Enterprise, Performance, Developer, Unlimited |
| Manufacturing Cloud | Enterprise, Unlimited |
| Unified Catalog | (any of the above) |

PCM is available only in **Lightning Experience**.

## Permission sets

PCM ships four prebuilt permission sets. Compose them via permission set groups; do not clone profiles.

| Permission set | Audience | Grants |
|---|---|---|
| **ProductCatalogManagementDesigner** | Catalog admins, product designers | Setup, design, full CRUD on PCM objects |
| **ProductCatalogManagementViewer** | Sales agents, internal browse users | Read access to catalogs/products |
| **ProductCatalogManagementCustomerCommunityUser** | Customer community users | Browse + buy on Experience Cloud sites |
| **ProductCatalogManagementPartnerCommunityUser** | Partner community users | Browse + sell on Experience Cloud sites |

Plus the **Product Catalog Management Permission Set License** (PSL) needed before any of these permission sets can be assigned.

## Personas

| Persona | Job | Typical permission set |
|---|---|---|
| Salesforce Admin | Org config, deployments, settings | Full admin (System Administrator) |
| Catalog Admin | Owns the catalog: structure, taxonomy, qualification rules | Designer |
| Product Designer | Defines products, classifications, attributes, bundles | Designer |
| Product Discovery Admin | Configures Product Discovery, search index, default catalog | Designer + Product Discovery Settings access |
| Sales Agent (internal) | Browses catalogs, builds quotes | Viewer |
| Customer Community User | Self-serve browse/buy | CustomerCommunityUser |
| Partner Community User | Sells on behalf of customers | PartnerCommunityUser |

## Setup checklist (new org)

1. **License**: confirm Product Catalog Management PSL is provisioned. Without the PSL the permission sets cannot be assigned.
2. **Assign permission sets** to the right personas via permission set groups. Use **muting permission sets** if you need to remove a permission inside a group rather than cloning.
3. **Page layouts**: enable PCM-specific fields on `Product2` (e.g., `Type`, `BasedOnId`, `ConfigureDuringSale`, `AvailabilityDate`, `DiscontinuedDate`, `EndOfLifeDate`, `CanRamp`, `DecompositionScope`, `FulfillmentQtyCalcMethod`, `UsageModelType`). Set field-level security per persona.
4. **Org-wide defaults** for PCM objects: typically Public Read/Write for designers, Public Read-only for viewers. Adjust per company policy.
5. **Custom fields**: PCM objects accept custom fields; useful for industry-specific taxonomy.
6. **Product Discovery Settings** (Setup → Product Discovery): pick the default catalog, qualification procedure (optional), pricing procedure (optional), search mode, and enable Product Variants if needed.
7. **Translation**: if multi-language is required, enable the Translation Workbench and reindex products after data translations.

## Common setup errors

- **Permission set not assignable**: PSL not provisioned. File a Salesforce case to enable PCM.
- **`Product2.Type` picklist missing 'Bundle' value**: PCM PSL not active for this user, or org is on an API version < 60.
- **Browse Catalogs button missing**: default catalog not set, or the user's permission set group does not include the Viewer permission set.
- **Search returns nothing after bulk import**: search index has not been rebuilt. Trigger a reindex from Product Discovery Settings.
- **Multi-currency confusion**: `Product2` follows the org's currency model; selling models and pricing handle FX. Don't try to put currency on PCM objects.
