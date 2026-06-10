# Revenue Cloud Pricing Architecture

Salesforce Revenue Cloud pricing for Agentforce Revenue Management, Revenue Cloud Advanced, and Revenue Cloud Billing is context-driven and built on core Salesforce objects. Pricing procedures do not operate directly on Salesforce object fields. They operate on a canonical context model that is hydrated from objects, transformed by expression sets, and persisted back through mappings.

## Core Model

```text
sObject fields
  -> context mapping
  -> context definition attributes and tags
  -> expression set variables
  -> pricing elements
  -> decision tables, formulas, and aggregations
  -> expression set outputs
  -> context mapping persistence
  -> sObject fields
```

## Main Components

- Context definitions define the canonical pricing data model. They contain nodes such as transaction header and line items, plus attributes and context tags.
- Context mappings connect Salesforce objects to context nodes and attributes. They support hydration, persistence, association, and translation.
- Expression sets are pricing procedures. They contain variables and ordered steps that implement pricing logic.
- Pricing elements are executable building blocks inside expression sets: list price lookup, matrix lookup, formula, assignment, list operation, aggregation, rounding, propagation, stop pricing, and related operations.
- Decision tables store pricing rules and lookup data. Pricing elements map runtime inputs to decision-table input parameters and return output parameters.
- Procedure plans orchestrate one or more expression sets and Apex hooks in a sequence.
- Apex hooks can prepare or finalize context. In Revenue Cloud procedure plans, Apex logic is commonly used as a pre-hook or post-hook rather than embedded throughout pricing.

## Revenue Cloud Is Not Legacy CPQ Or Billing

Legacy Salesforce CPQ / Steelbrick CPQ uses managed-package constructs such as `SBQQ__QuoteLine__c`, price rules, product rules, discount schedules, and quote calculator plugins. Legacy Salesforce Billing uses managed-package `BLNG__*` constructs. New Salesforce Revenue Cloud uses standard and custom core objects, context definitions, mappings, expression sets, decision tables, and procedure plans. Do not assume `SBQQ__` or `BLNG__` namespace metadata is part of the Revenue Cloud pricing path.

## Naming Pattern

Many implementations use object-field prefixes that do not appear in context tags:

```text
Quote.CustomerPrefix_TotalAmount__c
  <-> Context.TotalAmount__c
  <-> ExpressionSet variable TotalAmount__c
```

This is only a pattern. Always verify the actual context mapping.

## Practical Diagnostic Rule

When diagnosing any price or field, ask:

1. Which object field stores or displays the value?
2. Which context attribute/tag represents it?
3. Which expression set step reads or writes it?
4. Which decision table, formula, aggregation, or Apex hook creates the value?
5. Which mapping persists it back?
