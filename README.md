# Salesforce Revenue Cloud Skills

An open-source kit of Agent Skills for Salesforce Revenue Cloud architects, developers, consultants, and implementation teams.

These skills help agents work across core Salesforce Revenue Cloud topics, including pricing diagnostics and Product Catalog Management (PCM) master data.

## What Are Agent Skills?

Agent Skills are reusable instruction packages that teach AI coding agents how to perform specialized workflows. A skill is usually a folder containing a `SKILL.md` file, plus optional reference documents, scripts, examples, and evals.

Skills work through progressive disclosure:

1. The agent first reads only each skill's name and description.
2. When a user request matches the skill, the agent loads the full `SKILL.md`.
3. The agent can then read supporting reference files only when the task needs them.

This lets agents keep domain expertise available without loading every detail into context for every request.

## Available Skills

### Revenue Cloud Pricing Diagnostics

Path: `skills/revenue-cloud-pricing-diagnostics/`

Use this skill when you want an agent to inspect pricing in Salesforce Revenue Cloud, Agentforce Revenue Management, Revenue Cloud Advanced, or Revenue Cloud Billing implementations built on core Salesforce objects, especially when tracing:

- How a Quote, Quote Line, Order, or pricing field is populated.
- Which context definition, context mapping, or context tag feeds a value.
- Which expression set, pricing element, formula, aggregation, or decision table calculates a value.
- Which procedure plan or Apex pre-hook affects pricing sequence.
- Why pricing differs between UI and API flows.

This skill is for the new core Salesforce Revenue Cloud product family. It is not intended for legacy managed-package Salesforce CPQ / Steelbrick CPQ `SBQQ__*` or legacy Salesforce Billing `BLNG__*` analysis.

### Revenue Cloud Product Catalog Management (PCM)

Path: `skills/revenue-cloud-pcm/`

Use this skill when you want an agent to design, inspect, troubleshoot, export, import, or migrate Salesforce Revenue Cloud PCM master data, especially involving:

- Catalogs, categories, products, and bundle structures.
- Dynamic attributes, picklists, classifications, and product-specific overrides.
- Qualification and disqualification rules for product visibility.
- Selling models, product discovery, and catalog browse behavior.
- PCM object lookups, CSV loads, sandbox loads, and migration planning.

This skill is for core Salesforce Revenue Cloud / Agentforce Revenue Management / Revenue Cloud Advanced / Revenue Cloud Billing PCM objects such as `Product2`, `ProductCatalog`, `ProductCategory`, `ProductClassification`, and `ProductRelatedComponent`. It is not intended for legacy Salesforce CPQ `SBQQ__*` or legacy Salesforce Billing `BLNG__*` managed-package patterns unless explicitly requested.

## Installation

This folder is designed to be copied into any project or agent skill directory.

### Option 1: Install With npx (Recommended)

Use the `rcaskills` CLI to install from GitHub:

```bash
# Install all skills (interactive location prompt)
npx rcaskills add arohitu/salesforce-revenue-cloud-skills
```

```bash
# Install specific skills only
npx rcaskills add arohitu/salesforce-revenue-cloud-skills --skill revenue-cloud-pcm revenue-cloud-pricing-diagnostics
```

```bash
# List available skills in the repository
npx rcaskills add arohitu/salesforce-revenue-cloud-skills --list
```

Behavior:

- Prompts for install target: project `./.agent/skills` or global `~/.agent/skills`.
- Creates `.agent/skills` if missing.
- Interactive multi-select supports arrow keys to navigate, spacebar to select, and enter to install.
- Defaults to all skills selected when `--skill` is not provided.

### Option 2: Clone The Kit

```bash
git clone https://github.com/arohitu/salesforce-revenue-cloud-skills.git
```

Then copy the skill folder into the location your agent uses for skills.

For Cursor, a project-local skill can live under:

```text
.cursor/skills/revenue-cloud-pricing-diagnostics/
.cursor/skills/revenue-cloud-pcm/
```

For agents that use the open Agent Skills format, copy the folder into that agent's configured skills directory.

### Option 3: Add To An Existing Project

From your project root:

```bash
mkdir -p .cursor/skills
cp -R /path/to/salesforce-revenue-cloud-skills/skills/revenue-cloud-pricing-diagnostics .cursor/skills/
cp -R /path/to/salesforce-revenue-cloud-skills/skills/revenue-cloud-pcm .cursor/skills/
```

Restart or refresh your agent session, then ask the agent to list available skills if your client supports that command.

### Option 4: Use As A Standalone Repo

You can also keep `salesforce-revenue-cloud-skills/` as its own repository and copy or symlink individual skill folders into projects where Revenue Cloud expertise is needed.

## Usage

Once installed, ask your agent Revenue Cloud questions in natural language.

Example prompts:

```text
Help me understand how Quote.RCA_TotalMRRAmount__c is populated by Revenue Cloud pricing.
```

```text
Trace how this pricing field is calculated. Start from the field metadata, then follow context mappings, expression sets, pricing elements, and decision tables.
```

```text
Why does this quote price correctly in the UI but fail through the Place Sales Transaction API with DUPLICATE_VALUE_FOUND_IN_LOOKUP?
```

```text
Find which procedure plan section or pricing procedure writes the final total for this field.
```

```text
Explain how the exchange rate field is looked up and how it impacts quote currency totals.
```

```text
Help me design a Product Catalog Management model for a configurable broadband bundle with dynamic attributes and qualification rules.
```

```text
Why is this product missing from Browse Catalogs? Check catalog/category links, effective dates, qualification rules, and Product Discovery indexing.
```

```text
Create a migration plan for moving a PCM catalog and its bundle products between Salesforce orgs.
```

For pricing diagnostics, the agent should produce a concise lineage report showing the object field, context attribute/tag, context mapping, expression set or pricing step, decision table or formula, procedure-plan sequence, writeback path, and likely failure points.

For PCM work, the agent should ground recommendations in the relevant core objects, relationships, effective dates, qualification rules, bundle structure, migration load order, and org/API-version constraints.

## Skill Quality Notes

Each skill follows the open Agent Skills structure: a root `SKILL.md` with `name` and `description` frontmatter, concise activation instructions, and supporting files loaded only when needed.

For pricing diagnostics, `SKILL.md` stays focused on the default workflow, reference selection, gotchas, output template, and the legacy managed-package CPQ/Billing boundary. Deeper Revenue Cloud details live in `references/`, and quality scenarios live in `evals/evals.json`.

## Repository Structure

```text
.
├── skills/
│   ├── revenue-cloud-pricing-diagnostics/
│   │   ├── SKILL.md
│   │   ├── references/
│   │   │   ├── architecture.md
│   │   │   ├── field-lineage-workflow.md
│   │   │   ├── procedure-plans.md
│   │   │   ├── pricing-elements-and-decision-tables.md
│   │   │   └── troubleshooting.md
│   │   └── evals/
│   │       └── evals.json
│   └── revenue-cloud-pcm/
│       ├── SKILL.md
│       ├── references/
│       │   ├── 01-architecture.md
│       │   ├── 02-setup-and-permissions.md
│       │   ├── 03-catalogs-and-categories.md
│       │   └── ...
│       └── scripts/
│           ├── describe-pcm-objects.sh
│           ├── list-catalogs.sh
│           ├── query-product-tree.sh
│           └── check-orphans.sh
├── CONTRIBUTING.md
├── LICENSE
└── README.md
```

## Contributing

Contributions are welcome. Useful contributions include:

- New Revenue Cloud skills.
- Better field-lineage workflows.
- Additional troubleshooting patterns from real implementations.
- Evals that test skill quality across different Revenue Cloud orgs.
- Documentation improvements.

See [CONTRIBUTING.md](CONTRIBUTING.md) for contribution guidelines.

## License

This project is released under the MIT License. See [LICENSE](LICENSE).
