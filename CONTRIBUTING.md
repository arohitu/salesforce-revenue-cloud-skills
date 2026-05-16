# Contributing

Thank you for helping improve Salesforce Revenue Cloud Skills.

This project is intended to provide practical, reusable Agent Skills for Salesforce Revenue Cloud professionals. Contributions should be generic enough to help across different orgs and implementations.

## What To Contribute

Good contributions include:

- New Agent Skills for Salesforce Revenue Cloud workflows.
- Improvements to the Revenue Cloud pricing diagnostics skill.
- Better reference material for context definitions, context mappings, expression sets, decision tables, procedure plans, and Apex hooks.
- Realistic eval prompts and assertions.
- Documentation corrections and clearer examples.

Avoid contributing customer-specific secrets, org IDs, internal URLs, credentials, proprietary pricing data, or project names that cannot be shared publicly.

## Skill Authoring Guidelines

When adding or editing a skill:

- Keep `SKILL.md` concise. Put detailed material in one-level reference files under `references/`.
- Write a clear `description` that says when the skill should be used.
- Use generic Revenue Cloud terminology unless an example explicitly needs a placeholder.
- Do not assume Salesforce CPQ / `SBQQ__*` metadata when the skill is about core Revenue Cloud.
- Prefer workflows and diagnostic methods over one-off answers.
- Add evals for important behavior.

## Suggested Skill Structure

```text
salesforce-revenue-cloud-skills/
├── skill-name/
│   ├── SKILL.md
│   ├── references/
│   │   └── topic.md
│   └── evals/
│       └── evals.json
├── CONTRIBUTING.md
├── LICENSE
└── README.md
```

Scripts are welcome when they remove repeated manual work, but they must be non-interactive, documented, and safe by default.

## Eval Guidelines

Each eval should include:

- A realistic user prompt.
- A short expected-output description.
- Assertions that can be judged from the output.

Prefer evals that test real consultant and developer workflows, such as tracing a field, debugging a missing pricing value, or identifying whether a request belongs to Revenue Cloud or Salesforce CPQ.

## Pull Request Checklist

Before opening a pull request:

- Confirm no customer-specific or sensitive information is included.
- Confirm Markdown links work.
- Validate JSON files such as `skill-name/evals/evals.json`.
- Keep examples generic and reusable.
- Explain why the change improves the kit.

## Code Of Conduct

Be respectful, practical, and specific. This kit is meant to help practitioners reason through complex Revenue Cloud implementations, so examples and corrections should be clear, evidence-based, and safe to share publicly.
