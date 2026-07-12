# Context Definition Changes for Advanced Configurator

Exact XML blocks added by `scripts/update-context-definition-constraints.sh` (proven pattern from `RLM_SalesTransactionContext`).

## 1. SalesTransactionItem context attribute

Insert before the `SalesTransactionItem` node `contextTags` block (`SalesTransactionItem/SalesTransactionItem` inheritedFrom anchor):

```xml
            <contextAttributes>
                <contextTags>
                    <title>ConstraintEngineNodeStatus__c</title>
                </contextTags>
                <customMappingAllowed>false</customMappingAllowed>
                <dataType>string</dataType>
                <fieldType>inputoutput</fieldType>
                <key>false</key>
                <title>ConstraintEngineNodeStatus__c</title>
                <transient>false</transient>
                <value>false</value>
            </contextAttributes>
```

## 2. AssetActionSource context attribute

Insert before the `AssetActionSourceTag` `contextTags` block:

```xml
            <contextAttributes>
                <contextTags>
                    <title>AssetConstraintEngineNodeStatus__c</title>
                </contextTags>
                <customMappingAllowed>false</customMappingAllowed>
                <dataType>string</dataType>
                <fieldType>inputoutput</fieldType>
                <key>false</key>
                <title>AssetConstraintEngineNodeStatus__c</title>
                <transient>false</transient>
                <value>false</value>
            </contextAttributes>
```

## 3. OrderEntitiesMapping (SalesTransactionItem → OrderItem)

Insert before the `SalesTransactionItem` / `OrderItem` `contextNodeMappings` closing lines:

```xml
                <contextAttributeMappings>
                    <contextAttrHydrationDetails>
                        <objectName>OrderItem</objectName>
                        <queryAttribute>ConstraintEngineNodeStatus__c</queryAttribute>
                    </contextAttrHydrationDetails>
                    <contextAttribute>ConstraintEngineNodeStatus__c</contextAttribute>
                    <contextInputAttributeName>ConstraintEngineNodeStatus__c</contextInputAttributeName>
                </contextAttributeMappings>
```

Anchor sequence:

```xml
                <contextNode>SalesTransactionItem</contextNode>
                <inheritedFrom>SalesTransactionContext__stdctx/version/OrderEntitiesMapping/SalesTransactionItem</inheritedFrom>
                <object>OrderItem</object>
```

## 4. QuoteEntitiesMapping (SalesTransactionItem → QuoteLineItem)

```xml
                <contextAttributeMappings>
                    <contextAttrHydrationDetails>
                        <objectName>QuoteLineItem</objectName>
                        <queryAttribute>ConstraintEngineNodeStatus__c</queryAttribute>
                    </contextAttrHydrationDetails>
                    <contextAttribute>ConstraintEngineNodeStatus__c</contextAttribute>
                    <contextInputAttributeName>ConstraintEngineNodeStatus__c</contextInputAttributeName>
                </contextAttributeMappings>
```

Anchor sequence:

```xml
                <contextNode>SalesTransactionItem</contextNode>
                <inheritedFrom>SalesTransactionContext__stdctx/version/QuoteEntitiesMapping/SalesTransactionItem</inheritedFrom>
                <object>QuoteLineItem</object>
```

## 5. AssetEntitiesMapping (AssetActionSource → AssetActionSource)

Uses context attribute `AssetConstraintEngineNodeStatus__c` mapped to field `ConstraintEngineNodeStatus__c`:

```xml
                <contextAttributeMappings>
                    <contextAttrHydrationDetails>
                        <objectName>AssetActionSource</objectName>
                        <queryAttribute>ConstraintEngineNodeStatus__c</queryAttribute>
                    </contextAttrHydrationDetails>
                    <contextAttribute>AssetConstraintEngineNodeStatus__c</contextAttribute>
                    <contextInputAttributeName>AssetConstraintEngineNodeStatus__c</contextInputAttributeName>
                </contextAttributeMappings>
```

Anchor sequence:

```xml
                <contextNode>AssetActionSource</contextNode>
                <inheritedFrom>SalesTransactionContext__stdctx/version/AssetEntitiesMapping/AssetActionSource</inheritedFrom>
                <object>AssetActionSource</object>
```

## Manual checkpoint (not automated)

**AssetToSalesTransactionMapping** cross-attribute mapping is org-specific and remains a manual Setup step after running the script.

## Activation

After deploy, activate the context definition version in Setup if the org requires it. The script deploys metadata only; activation may still be manual.

## Idempotency notes

- The script greps/checks each block before insert.
- Only the single context definition file is deployed — never bulk/noisy redeploy of unrelated metadata.
- UI saves may remove `localizationDisabled` elements; automation avoids touching unrelated XML.
