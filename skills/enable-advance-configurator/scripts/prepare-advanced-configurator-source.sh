#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<EOF
Usage: $(basename "$0") [--out-dir DIR] [--no-permission-set]

Generate deployable Salesforce source for Advanced Configurator setup.

Options:
  --out-dir DIR           Output directory (default: ./build/adv-config-source)
  --no-permission-set     Skip creating permission set metadata
  --help                  Show this help
EOF
}

OUT_DIR="./build/adv-config-source"
CREATE_PERMISSION_SET=true

while [[ $# -gt 0 ]]; do
  case "$1" in
    --out-dir) OUT_DIR="$2"; shift 2 ;;
    --no-permission-set) CREATE_PERMISSION_SET=false; shift 1 ;;
    --help|-h) usage; exit 0 ;;
    *) echo "Unknown argument: $1" >&2; usage; exit 1 ;;
  esac
done

BASE="$OUT_DIR/force-app/main/default"
mkdir -p "$BASE/objects/QuoteLineItem/fields"
mkdir -p "$BASE/objects/OrderItem/fields"
mkdir -p "$BASE/objects/AssetActionSource/fields"
mkdir -p "$BASE/triggers"
mkdir -p "$BASE/permissionsets"

for object in QuoteLineItem OrderItem AssetActionSource; do
  cat > "$BASE/objects/$object/fields/ConstraintEngineNodeStatus__c.field-meta.xml" <<'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<CustomField xmlns="http://soap.sforce.com/2006/04/metadata">
    <fullName>ConstraintEngineNodeStatus__c</fullName>
    <externalId>false</externalId>
    <label>Constraint Engine Node Status</label>
    <length>131072</length>
    <required>false</required>
    <trackTrending>false</trackTrending>
    <type>LongTextArea</type>
    <visibleLines>3</visibleLines>
</CustomField>
EOF
done

cat > "$BASE/triggers/RCAAdvConfigQuoteLineItemTrigger.trigger" <<'EOF'
trigger RCAAdvConfigQuoteLineItemTrigger on QuoteLineItem (before insert) {
    Set<Id> quoteActionIds = new Set<Id>();
    for (QuoteLineItem qi : Trigger.new) {
        if (qi.QuoteActionId != null && qi.ConstraintEngineNodeStatus__c == null) {
            quoteActionIds.add(qi.QuoteActionId);
        }
    }
    if (quoteActionIds.isEmpty()) return;

    Map<Id, Id> quoteActionToAssetId = new Map<Id, Id>();
    for (QuoteAction qa : [
        SELECT Id, SourceAssetId
        FROM QuoteAction
        WHERE Id IN :quoteActionIds AND SourceAssetId != null
    ]) {
        quoteActionToAssetId.put(qa.Id, qa.SourceAssetId);
    }
    if (quoteActionToAssetId.isEmpty()) return;

    Map<Id, AssetAction> latestByAsset = new Map<Id, AssetAction>();
    for (AssetAction aa : [
        SELECT Id, AssetId, ActionDate
        FROM AssetAction
        WHERE AssetId IN :quoteActionToAssetId.values()
    ]) {
        AssetAction existing = latestByAsset.get(aa.AssetId);
        if (existing == null || aa.ActionDate > existing.ActionDate) {
            latestByAsset.put(aa.AssetId, aa);
        }
    }
    if (latestByAsset.isEmpty()) return;

    Set<Id> latestActionIds = new Set<Id>();
    for (AssetAction aa : latestByAsset.values()) latestActionIds.add(aa.Id);

    Map<Id, String> statusByAsset = new Map<Id, String>();
    for (AssetActionSource src : [
        SELECT ConstraintEngineNodeStatus__c, AssetAction.AssetId
        FROM AssetActionSource
        WHERE AssetActionId IN :latestActionIds
        ORDER BY CreatedDate DESC
    ]) {
        Id assetId = src.AssetAction.AssetId;
        if (!statusByAsset.containsKey(assetId) && src.ConstraintEngineNodeStatus__c != null) {
            statusByAsset.put(assetId, src.ConstraintEngineNodeStatus__c);
        }
    }

    for (QuoteLineItem qi : Trigger.new) {
        if (qi.QuoteActionId == null || qi.ConstraintEngineNodeStatus__c != null) continue;
        Id assetId = quoteActionToAssetId.get(qi.QuoteActionId);
        if (assetId != null && statusByAsset.containsKey(assetId)) {
            qi.ConstraintEngineNodeStatus__c = statusByAsset.get(assetId);
        }
    }
}
EOF

cat > "$BASE/triggers/RCAAdvConfigQuoteLineItemTrigger.trigger-meta.xml" <<'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<ApexTrigger xmlns="http://soap.sforce.com/2006/04/metadata">
    <apiVersion>63.0</apiVersion>
    <status>Active</status>
</ApexTrigger>
EOF

cat > "$BASE/triggers/RCAAdvConfigOrderItemTrigger.trigger" <<'EOF'
trigger RCAAdvConfigOrderItemTrigger on OrderItem (before insert) {
    Set<Id> orderActionIds = new Set<Id>();
    for (OrderItem oi : Trigger.new) {
        if (oi.OrderActionId != null && oi.ConstraintEngineNodeStatus__c == null) {
            orderActionIds.add(oi.OrderActionId);
        }
    }
    if (orderActionIds.isEmpty()) return;

    Map<Id, Id> orderActionToAssetId = new Map<Id, Id>();
    for (OrderAction oa : [
        SELECT Id, SourceAssetId
        FROM OrderAction
        WHERE Id IN :orderActionIds AND SourceAssetId != null
    ]) {
        orderActionToAssetId.put(oa.Id, oa.SourceAssetId);
    }
    if (orderActionToAssetId.isEmpty()) return;

    Map<Id, AssetAction> latestByAsset = new Map<Id, AssetAction>();
    for (AssetAction aa : [
        SELECT Id, AssetId, ActionDate
        FROM AssetAction
        WHERE AssetId IN :orderActionToAssetId.values()
    ]) {
        AssetAction existing = latestByAsset.get(aa.AssetId);
        if (existing == null || aa.ActionDate > existing.ActionDate) {
            latestByAsset.put(aa.AssetId, aa);
        }
    }
    if (latestByAsset.isEmpty()) return;

    Set<Id> latestActionIds = new Set<Id>();
    for (AssetAction aa : latestByAsset.values()) latestActionIds.add(aa.Id);

    Map<Id, String> statusByAsset = new Map<Id, String>();
    for (AssetActionSource src : [
        SELECT ConstraintEngineNodeStatus__c, AssetAction.AssetId
        FROM AssetActionSource
        WHERE AssetActionId IN :latestActionIds
        ORDER BY CreatedDate DESC
    ]) {
        Id assetId = src.AssetAction.AssetId;
        if (!statusByAsset.containsKey(assetId) && src.ConstraintEngineNodeStatus__c != null) {
            statusByAsset.put(assetId, src.ConstraintEngineNodeStatus__c);
        }
    }

    for (OrderItem oi : Trigger.new) {
        if (oi.OrderActionId == null || oi.ConstraintEngineNodeStatus__c != null) continue;
        Id assetId = orderActionToAssetId.get(oi.OrderActionId);
        if (assetId != null && statusByAsset.containsKey(assetId)) {
            oi.ConstraintEngineNodeStatus__c = statusByAsset.get(assetId);
        }
    }
}
EOF

cat > "$BASE/triggers/RCAAdvConfigOrderItemTrigger.trigger-meta.xml" <<'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<ApexTrigger xmlns="http://soap.sforce.com/2006/04/metadata">
    <apiVersion>63.0</apiVersion>
    <status>Active</status>
</ApexTrigger>
EOF

if [[ "$CREATE_PERMISSION_SET" == true ]]; then
  cat > "$BASE/permissionsets/EnableAdvancedConfiguratorSetup.permissionset-meta.xml" <<'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<PermissionSet xmlns="http://soap.sforce.com/2006/04/metadata">
    <description>Field visibility for Advanced Configurator setup artifacts.</description>
    <fieldPermissions>
        <editable>true</editable>
        <field>QuoteLineItem.ConstraintEngineNodeStatus__c</field>
        <readable>true</readable>
    </fieldPermissions>
    <fieldPermissions>
        <editable>true</editable>
        <field>OrderItem.ConstraintEngineNodeStatus__c</field>
        <readable>true</readable>
    </fieldPermissions>
    <fieldPermissions>
        <editable>true</editable>
        <field>AssetActionSource.ConstraintEngineNodeStatus__c</field>
        <readable>true</readable>
    </fieldPermissions>
    <hasActivationRequired>false</hasActivationRequired>
    <label>Enable Advanced Configurator Setup</label>
</PermissionSet>
EOF
fi

jq -n \
  --arg outDir "$OUT_DIR" \
  --argjson permissionSet "$CREATE_PERMISSION_SET" \
  '{
    status: "ok",
    outputDirectory: $outDir,
    generated: {
      customFields: [
        "QuoteLineItem.ConstraintEngineNodeStatus__c",
        "OrderItem.ConstraintEngineNodeStatus__c",
        "AssetActionSource.ConstraintEngineNodeStatus__c"
      ],
      triggers: [
        "RCAAdvConfigQuoteLineItemTrigger",
        "RCAAdvConfigOrderItemTrigger"
      ],
      permissionSetCreated: $permissionSet
    }
  }'
