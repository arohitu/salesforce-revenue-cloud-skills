# Salesforce Revenue Cloud Skills

An open-source kit of Agent Skills for Salesforce Revenue Cloud architects, developers, consultants, and implementation teams.

The first skill in this kit helps agents dissect Salesforce Revenue Cloud pricing: how fields are populated, how pricing procedures calculate values, how context mappings work, and how decision tables influence final prices.

## What Are Agent Skills?

Agent Skills are reusable instruction packages that teach AI coding agents how to perform specialized workflows. A skill is usually a folder containing a `SKILL.md` file, plus optional reference documents, scripts, examples, and evals.

Skills work through progressive disclosure:

1. The agent first reads only each skill's name and description.
2. When a user request matches the skill, the agent loads the full `SKILL.md`.
3. The agent can then read supporting reference files only when the task needs them.

This lets agents keep domain expertise available without loading every detail into context for every request.

## Available Skills

### Revenue Cloud Pricing Diagnostics

Path: `revenue-cloud-pricing-diagnostics/`

Use this skill when you want an agent to inspect Salesforce Revenue Cloud pricing in a core Revenue Cloud org, especially when tracing:

- How a Quote, Quote Line, Order, or pricing field is populated.
- Which context definition, context mapping, or context tag feeds a value.
- Which expression set, pricing element, formula, aggregation, or decision table calculates a value.
- Which procedure plan or Apex pre-hook affects pricing sequence.
- Why pricing differs between UI and API flows.

This skill is for Salesforce Revenue Cloud / Agentforce Revenue Management. It is not intended for Salesforce CPQ / Steelbrick CPQ `SBQQ__*` analysis.

More Revenue Cloud skills may be added in future versions of this kit.

## Installation

This folder is designed to be copied into any project or agent skill directory.

### Option 1: Clone The Kit

```bash
git clone https://github.com/YOUR-ORG/salesforce-revenue-cloud-skills.git
```

Then copy the skill folder into the location your agent uses for skills.

For Cursor, a project-local skill can live under:

```text
.cursor/skills/revenue-cloud-pricing-diagnostics/
```

For agents that use the open Agent Skills format, copy the folder into that agent's configured skills directory.

### Option 2: Add To An Existing Project

From your project root:

```bash
mkdir -p .cursor/skills
cp -R /path/to/salesforce-revenue-cloud-skills/revenue-cloud-pricing-diagnostics .cursor/skills/
```

Restart or refresh your agent session, then ask the agent to list available skills if your client supports that command.

### Option 3: Use As A Standalone Repo

You can also keep `salesforce-revenue-cloud-skills/` as its own repository and copy or symlink individual skill folders into projects where Revenue Cloud diagnostics are needed.

## Usage

Once installed, ask your agent Revenue Cloud pricing questions in natural language.

Example prompts:

```text
Help me understand how Quote.RCA_TotalACVAmount__c is populated by Revenue Cloud pricing.
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

The agent should produce a concise lineage report showing the object field, context attribute/tag, context mapping, expression set or pricing step, decision table or formula, procedure-plan sequence, writeback path, and likely failure points.

## Repository Structure

```text
.
├── revenue-cloud-pricing-diagnostics/
│   ├── SKILL.md
│   ├── references/
│   │   ├── architecture.md
│   │   ├── field-lineage-workflow.md
│   │   ├── procedure-plans.md
│   │   ├── pricing-elements-and-decision-tables.md
│   │   └── troubleshooting.md
│   └── evals/
│       └── evals.json
├── CONTRIBUTING.md
├── LICENSE
└── README.md
```

## Contributing

Contributions are welcome. Useful contributions include:

- New Revenue Cloud diagnostic skills.
- Better field-lineage workflows.
- Additional troubleshooting patterns from real implementations.
- Evals that test skill quality across different Revenue Cloud orgs.
- Documentation improvements.

See [CONTRIBUTING.md](CONTRIBUTING.md) for contribution guidelines.

## License

This project is released under the MIT License. See [LICENSE](LICENSE).
