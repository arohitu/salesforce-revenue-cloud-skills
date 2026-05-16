# Procedure Plans

Procedure plans orchestrate multiple pricing procedures and Apex hooks. Use this reference when execution order matters or when a field is affected by more than one expression set.

## Concept

A procedure plan is a sequence of sections. Each section contains one or more options. An option is usually an expression set or an Apex class.

```text
Procedure Plan
  -> Active Version
  -> Section 1
       -> Option 1: Apex pre-hook or expression set
  -> Section 2
       -> Option 1: pricing procedure
  -> Section N
       -> Option 1: totals or post-processing
```

Sections run by sequence. Options within a section run by priority.

## What To Query In An Org

When deployable metadata does not contain the procedure plan, query the active org.

Find active plan definitions:

```soql
SELECT Id, DeveloperName, IsActive
FROM ProcedurePlanDefinition
WHERE IsActive = true
```

Find active versions:

```soql
SELECT Id, Rank, IsActive, DefaultSaveContextMapping, DefaultReadContextMapping, ContextDefinition
FROM ProcedurePlanDefinitionVersion
WHERE ProcedurePlanDefinitionId = '<PLAN_ID>'
AND IsActive = true
```

Find sections:

```soql
SELECT Id, Phase, IsInherited, Description, ResolutionType, Sequence, SubSectionType, SectionType
FROM ProcedurePlanSection
WHERE ProcedurePlanVersionId = '<VERSION_ID>'
ORDER BY Sequence ASC
```

Find options:

```soql
SELECT Id, ProcedurePlanSectionId, ExpressionSetApiName, ExpressionSetLabel,
       ApexClassName, Priority, ReadContextMapping, SaveContextMapping
FROM ProcedurePlanOption
WHERE ProcedurePlanSectionId IN (<SECTION_IDS>)
ORDER BY ProcedurePlanSectionId, Priority ASC
```

## What To Inspect

- Active version and rank.
- Context definition used by the plan.
- Default read and save mappings.
- Section sequence and section type.
- Expression set API names and labels.
- Apex class names.
- Option-level read and save mappings.
- Whether a component-specific procedure runs before a totals procedure.

## Apex Hooks

Apex hooks should be treated as context preparation or finalization. For pre-pricing work, the hook should run before pricing procedures. For post-processing, it should run after pricing procedures.

Good pre-hook responsibilities:

- Flatten child attributes into scalar line-level pricing inputs.
- Normalize lookup keys.
- Derive simple context values required before pricing starts.
- Resolve picklist identifiers into lookup-ready values.

Avoid:

- Reimplementing pricing in Apex.
- Loading large portions of context when only a few tags are needed.
- DML inside the pricing transaction.
- External callouts unless the invocation path supports them and latency is acceptable.

## Diagnostic Questions

- Which procedure produces the value?
- Which later procedure consumes or overwrites it?
- Is the active procedure plan in source or only in org configuration?
- Does the option use the expected read/save mapping?
- Is the Apex hook preparing context values that the expression set assumes already exist?
