---
name: revenue-cloud-pricing-diagnostics
description: Use this skill when dissecting pricing in Salesforce Revenue Cloud, Agentforce Revenue Management, Revenue Cloud Advanced, or Revenue Cloud Billing implementations built on core Salesforce objects such as Quote, Quote Line, Order, Product2, and ProductClassification. Use it to trace how a price, total, discount, exchange rate, or pricing field is calculated through context definitions, mappings, expression sets, pricing elements, decision tables, procedure plans, or Apex pricing hooks. Do not use it for legacy managed-package Salesforce CPQ/SBQQ or Salesforce Billing/BLNG analysis.
---

# Revenue Cloud Pricing Diagnostics

Use this skill to analyze pricing implementations for Salesforce Revenue Cloud, Agentforce Revenue Management, Revenue Cloud Advanced, and Revenue Cloud Billing on core Salesforce objects. This is not the legacy managed-package model from Salesforce CPQ / Steelbrick CPQ or Salesforce Billing. Do not start from `SBQQ__*` or `BLNG__*` objects, CPQ price rules, CPQ product rules, CPQ discount schedules, quote calculator plugins, or legacy Billing package objects unless the user explicitly asks for legacy managed-package analysis instead of Revenue Cloud.

## Default Workflow

When the user asks how a pricing field is populated, why a price changed, or how pricing logic works:

1. Identify the commercial object and field: Quote, Quote Line, Order, Order Item, Contract, Asset, or another mapped object. In an SFDX project, fields are usually under `force-app/main/default/objects/<ObjectApiName>/fields/<FieldApiName>.field-meta.xml`. Inspect XML tags such as `<fullName>`, `<type>`, `<formula>`, `<formulaTreatBlanksAs>`, `<precision>`, `<scale>`, and `<required>`.
2. Read the field metadata. Determine whether it is stored, formula, standard, custom, read-only, or calculated elsewhere. If the field is a formula, trace the fields referenced in `<formula>` before assuming pricing writes to it directly.
3. Find matching context attributes and context tags in context definitions. In SFDX source, these are usually under `force-app/main/default/contextDefinitions/*.contextDefinition-meta.xml`. Inspect `<contextNodes>`, `<contextAttributes>`, `<title>`, `<dataType>`, `<fieldType>`, `<transient>`, and `<contextTags><title>...`.
4. Inspect context mappings for hydration and persistence in the same context definition metadata. Look under `<contextMappings>`, `<contextMappingIntents><mappingIntent>`, `<contextNodeMappings>`, `<contextAttributeMappings>`, `<contextAttrHydrationDetails>`, `<objectName>`, `<queryAttribute>`, `<contextAttribute>`, `<contextInputAttributeName>`, `<contextNode>`, and `<object>`.
5. Search expression set versions for the context tag, variable, output parameter, assignment, formula, aggregation, list operation, matrix lookup, or stop-pricing step. In SFDX source, pricing procedures are usually under `force-app/main/default/expressionSetVersion/*.expressionSetVersion-meta.xml`. Inspect `<variables>`, `<name>`, `<input>`, `<output>`, `<dataType>`, `<steps>`, `<actionType>`, `<customElement>`, `<parameters>`, `<sequenceNumber>`, `<parentStep>`, and `<stepType>`.
6. Inspect pricing elements and decision table references. Decision tables are usually under `force-app/main/default/decisionTables/*.decisionTable-meta.xml`, with dataset links under `force-app/main/default/decisionTableDatasetLinks/*.decisionTableDatasetLink-meta.xml`. Confirm `<decisionTableParameters>`, `<fieldName>`, `<usage>`, `<operator>`, `<sequence>`, `<isRequired>`, condition criteria, outputs, backing object/source, and active status.
7. Identify procedure-plan sequence when available. Procedure-plan deployable metadata may not exist in source; if absent, query the org for `ProcedurePlanDefinition`, `ProcedurePlanDefinitionVersion`, `ProcedurePlanSection`, and `ProcedurePlanOption`. Apex hooks referenced by procedure plans are usually under `force-app/main/default/classes/<ClassName>.cls`.
8. Produce a lineage report with evidence, likely failure points, and focused next checks.

## When To Load References

- Read `references/architecture.md` when the agent needs the core Revenue Cloud mental model or must explain why this is not legacy CPQ/SBQQ or Billing/BLNG.
- Read `references/field-lineage-workflow.md` for any request that starts from a field, price component, total, discount, exchange rate, or formula result.
- Read `references/procedure-plans.md` when multiple pricing procedures, Apex hooks, or execution order may affect the result.
- Read `references/pricing-elements-and-decision-tables.md` when a value comes from a pricing element, expression set step, lookup table, formula, or aggregation.
- Read `references/troubleshooting.md` when pricing differs between UI/API, a lookup returns duplicates/no rows, a value is missing after pricing, or persistence fails.

## Gotchas

- Revenue Cloud pricing for Agentforce Revenue Management / Revenue Cloud Advanced / Revenue Cloud Billing is core-platform and context-driven, not managed-package `SBQQ__*` or `BLNG__*` logic.
- Revenue Cloud expression sets work with context tags and variables, not direct sObject fields.
- Context mappings are the bridge between sObject fields and context attributes. A field can exist on Quote and still be invisible to pricing if the mapping or tag is missing.
- A calculated expression set output will not write back unless the context attribute supports output and the save/persistence mapping includes the target field.
- Decision table duplicate-match errors can be caused by incomplete runtime lookup keys, not only duplicate data.
- UI pricing and API pricing can prepare context differently. Validate the runtime pricing context, not just the request payload.
- Apex pre-hooks should prepare context, not become a second pricing engine. Prefer lean context reads, bulk updates, and no DML inside pricing hooks.
- Procedure-plan metadata may not be deployed in source. Query the active org when the active sequence matters.

## Output Template

Use this structure for field or pricing-dissection answers:

```markdown
# Pricing Lineage: [Field or Price Result]

## Summary
[One-paragraph explanation of how the value is populated or affected.]

## Lineage
- sObject field:
- Context attribute/tag:
- Context mapping:
- Expression set/procedure:
- Pricing element or step:
- Decision table or formula:
- Procedure-plan sequence:
- Persistence/writeback path:

## Evidence
[Short file references, metadata snippets, or org query results.]

## Failure Points
[Most likely reasons the value is missing, wrong, or different between UI/API.]

## Next Checks
[Focused next actions if evidence is incomplete.]
```

## Boundary

If the repo or org is legacy Salesforce CPQ / Steelbrick CPQ or legacy Salesforce Billing, tell the user this skill is not the right diagnostic model and switch to the appropriate managed-package analysis. Evidence includes `SBQQ__*` objects, `BLNG__*` objects, CPQ price rules, CPQ product rules, CPQ discount schedules, quote calculator plugin code, or legacy Billing package automation.
