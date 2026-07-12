
# Create Custom Field and Define Apex Triggers

Create the necessary custom fields and define Apex triggers on the Quote Line Item and Order Product (OrderItem) objects.

## Create the ConstraintEngineNodeStatus Custom Field

Create a custom field on the Quote Line Item, Order Product, and Asset Action Source objects to store data that Constraint Rules Engine uses for internal processing.

Go to the object management settings of these objects, and create a custom field with these values:

1.  Select **Text Area (Long)** as the data type.
2.  Enter Constraint Engine Node Status as the field label.
3.  Enter 131072 as the length.
4.  Enter ConstraintEngineNodeStatus as the field name.
5.  Select **Visible** access and deselect **Read-Only** access for the profiles of the users who'll use Constraint Rules Engine, and Customer Community and Partner Community users.
6.  Deselect the page layouts.


## Define Apex Triggers for Quote and Order Line Items

Define triggers for the Quote Line Item and Order Product (OrderItem) objects by using Apex code.

Use this Apex code for the Quote Line Item object.

```java
trigger QuoteItemTrigger on QuoteLineItem (before insert) {
   //collect QuoteActionIds 
   Set<Id> quoteActionIds = new Set<Id>();
   
   for (QuoteLineItem qi : Trigger.new) {
   if (qi.QuoteActionId != null && qi.ConstraintEngineNodeStatus__c == null) {
   quoteActionIds.add(qi.QuoteActionId);
   }
   }
   
   if (!quoteActionIds.isEmpty()) {
   // Step 1: Get QuoteAction → SourceAsset
   Map<Id, Id> quoteActionToAssetId = new Map<Id, Id>();
   for (QuoteAction qAction : [
   SELECT Id, SourceAssetId 
   FROM QuoteAction 
   WHERE SourceAssetId != null 
   AND Id IN :quoteActionIds
   ]) {
   quoteActionToAssetId.put(qAction.Id, qAction.SourceAssetId);
   }
   
   // Step 2: Get AssetActions
   List<AssetAction> assetActions = [
   SELECT Id, AssetId, ActionDate 
   FROM AssetAction 
   WHERE AssetId IN :quoteActionToAssetId.values()
   ];
   
   // Step 3: Get latest AssetAction per Asset
   Map<Id, AssetAction> assetIdToLatestAction = new Map<Id, AssetAction>();
   for (AssetAction aAction : assetActions) {
   AssetAction existing = assetIdToLatestAction.get(aAction.AssetId);
   if (existing == null || aAction.ActionDate > existing.ActionDate) {
   assetIdToLatestAction.put(aAction.AssetId, aAction);
   }
   }
   
   // Step 4: Get related AssetActionSource records
   Map<Id, Id> assetIdToActionId = new Map<Id, Id>();
   for (Id assetId : assetIdToLatestAction.keySet()) {
   assetIdToActionId.put(assetId, assetIdToLatestAction.get(assetId).Id);
   }
   
   List<AssetActionSource> assetActionSources = [
   SELECT ConstraintEngineNodeStatus__c, AssetAction.AssetId 
   FROM AssetActionSource 
   WHERE AssetActionId IN :assetIdToActionId.values() ORDER BY CreatedDate DESC
   ];
   // Step 5: Map AssetId → Status
   Map<Id, String> assetIdToStatus = new Map<Id, String>();
   for (AssetActionSource actionSource : assetActionSources) {
   if (!assetIdToStatus.containsKey(actionSource.AssetAction.AssetId) && 
   actionSource.ConstraintEngineNodeStatus__c != null) {
   assetIdToStatus.put(
   actionSource.AssetAction.AssetId, 
   actionSource.ConstraintEngineNodeStatus__c
   );
   }
   }
   List<QuoteLineItem> toUpdate = new List<QuoteLineItem>();
   // Step 6: Set ConstraintEngineNodeStatus__c directly on Trigger.new records
   for (QuoteLineItem qi : Trigger.new) {            
   if (qi.QuoteActionId != null && qi.ConstraintEngineNodeStatus__c == null) {
   Id assetId = quoteActionToAssetId != null ? quoteActionToAssetId.get(qi.QuoteActionId) : null;
   if (assetId != null && assetIdToStatus != null) {
   String status = assetIdToStatus.get(assetId);
   if (status != null) {
   qi.ConstraintEngineNodeStatus__c = status;
   }
   }
   }
   }
   }
   }
```

Use this Apex code for the Order Product (OrderItem) object.

```java
trigger OrderItemTrigger on OrderItem  (before insert) {
  //collect orderActionIds
  Set<Id> orderActionIds = new Set<Id>();
 
  for (OrderItem oi : Trigger.new) {
  if (oi.OrderActionId != null && oi.ConstraintEngineNodeStatus__c == null) {
  orderActionIds.add(oi.OrderActionId);
  }
  }
 
  if (!orderActionIds.isEmpty()) {
  // Step 1: Get OrderAction → SourceAsset
  Map<Id, Id> orderActionToAssetId = new Map<Id, Id>();
  for (OrderAction oAction : [
  SELECT Id, SourceAssetId
  FROM OrderAction
  WHERE SourceAssetId != null
  AND Id IN :orderActionIds
  ]) {
  orderActionToAssetId.put(oAction.Id, oAction.SourceAssetId);
  }
 
  // Step 2: Get AssetActions
  List<AssetAction> assetActions = [
  SELECT Id, AssetId, ActionDate
  FROM AssetAction
  WHERE AssetId IN :orderActionToAssetId.values()
  ];
 
  // Step 3: Get latest AssetAction per Asset
  Map<Id, AssetAction> assetIdToLatestAction = new Map<Id, AssetAction>();
  for (AssetAction aAction : assetActions) {
  AssetAction existing = assetIdToLatestAction.get(aAction.AssetId);
  if (existing == null || aAction.ActionDate > existing.ActionDate) {
  assetIdToLatestAction.put(aAction.AssetId, aAction);
  }
  }
 
  // Step 4: Get related AssetActionSource records
  Map<Id, Id> assetIdToActionId = new Map<Id, Id>();
  for (Id assetId : assetIdToLatestAction.keySet()) {
  assetIdToActionId.put(assetId, assetIdToLatestAction.get(assetId).Id);
  }
 
  List<AssetActionSource> assetActionSources = [
  SELECT ConstraintEngineNodeStatus__c, AssetAction.AssetId
  FROM AssetActionSource
  WHERE AssetActionId IN :assetIdToActionId.values() ORDER BY CreatedDate DESC
  ];
  // Step 5: Map AssetId → Status
  Map<Id, String> assetIdToStatus = new Map<Id, String>();
  for (AssetActionSource actionSource : assetActionSources) {
  if (!assetIdToStatus.containsKey(actionSource.AssetAction.AssetId) &&
  actionSource.ConstraintEngineNodeStatus__c != null) {
  assetIdToStatus.put(
  actionSource.AssetAction.AssetId,
  actionSource.ConstraintEngineNodeStatus__c
  );
  }
  }
  List<OrderItem> toUpdate = new List<OrderItem>();
  // Step 6: Set ConstraintEngineNodeStatus__c directly on Trigger.new records
  for (OrderItem oi : Trigger.new) {           
  if (oi.OrderActionId != null && oi.ConstraintEngineNodeStatus__c == null) {
  Id assetId = orderActionToAssetId != null ? orderActionToAssetId.get(oi.OrderActionId) : null;
  if (assetId != null && assetIdToStatus != null) {
  String status = assetIdToStatus.get(assetId);
  if (status != null) {
  oi.ConstraintEngineNodeStatus__c = status;
  }
  }
  }
  }
  }
  }

```

# Enable Constraint Rules Engine and Create Transaction Processing Types

Enable rule designers to create advanced configuration rules and constraints, and help sales reps run the rules for quotes and orders.

| User Permissions Needed |
| --- |
| To set up Constraint Rules Engine: | Product Configuration Constraints Designer permission set |

Note

Constraint Rules Engine services aren’t available in Government Cloud or in orgs within the [EU Operating Zone (OZ)](https://help.salesforce.com/s/articleView?id=000395407&language=en_US&type=1). For more information, contact your Salesforce account executive.

## Enable Constraint Rules Engine

Grant users the access to set up product configuration rules by using Constraint Rules Engine.

1.  From Setup, in the Quick find box, enter Revenue Settings, and then select **Revenue Settings**.
2.  Turn on Set Up Configuration Rules and Constraints with Constraints Engine.

## Create Transaction Processing Type Records for Constraint Rules Engine

Create a transaction processing type and specify AdvancedConfigurator as the rule engine.

See [Define Rules Engine with Transaction Processing Types](https://help.salesforce.com/s/articleView?id=ind.product_configurator_specify_which_rule_engine_to_use.htm&language=en_US&type=5).

After you create a transaction processing type, [set up context definitions](https://help.salesforce.com/s/articleView?id=ind.product_configurator_set_up_constraint_engine_context_definitions.htm&language=en_US&type=5).


# Define Rules Engine with Transaction Processing Types

Create Transaction Processing Type records to define the rules engine that you want to use to process configuration rules. Then, specify the default transaction processing type on the Revenue Settings page.

Note Constraint Rules Engine services aren’t available in Government Cloud or in orgs within the [EU Operating Zone (OZ)](https://help.salesforce.com/s/articleView?id=000395407&language=en_US&type=1). For more information, contact your Salesforce account executive.

[Configure the transaction processing type](https://help.salesforce.com/s/articleView?id=ind.qocal_configure_transaction_processing.htm&language=en_US&type=5) with the appropriate RuleEngine value:

*   To use Business Rules Engine, specify StandardConfigurator as the RuleEngine value.
*   To use Constraint Rules Engine, specify AdvancedConfigurator as the RuleEngine value.

Sales reps can’t see the fields in Transaction Processing Type records. If necessary, append the name of the rules engine to the Transaction Processing Type record name.

Set the default transaction processing type only if you plan to use Business Rules Engine. When you enable Constraint Rules Engine, AdvancedConfigurator automatically becomes the default rules engine.

When users create quotes and orders, the Transaction Type field is automatically populated with the default Transaction Processing Type record. The Transaction Type field on a quote or order determines the rule engines that's used to validate product configurations, and to execute configuration rules and constraints.

| Enabled Feature | Rules Engine Used | Conditions |
| --- | --- | --- |
| Only Constraint Rules Engine is enabled | Constraint Rules Engine | Configuration rules are run by using Constraint Rules Engine. |
| Only Business Rules Engine is enabled | Business Rules Engine | StandardConfigurator is specified as the rule engine in the associated Transaction Processing Type record. |
| Only Business Rules Engine is enabled | No rules engine used | There's no Transaction Type value on quotes and orders, or no Rule Engine value on the Transaction Processing Type record. |
| Both rules engines are enabled | Business Rules Engine | StandardConfigurator is specified as the rule engine in the associated Transaction Processing Type record. |
| Both rules engines are enabled | Constraint Rules Engine | StandardConfigurator is not specified as the rule engine in the associated Transaction Processing Type record. |


# Set Up the Transaction Processing Type for Quotes and Orders

Define how Revenue Management processes transactions by selecting a default Transaction Processing Type (TPT).


Set a default processing type for all transactions and define exceptions via the Tooling API. Use these configurations to turn on the Advanced Configurator or skip tax calculations. Help your sales representatives override the default, add the Transaction Type field to quote, and order page layouts.

![Important](https://sf-zdocs-cdn-prod.zoominsoftware.com/tdta-ind-revenue-262-0-0-production-enus/fa9a578d-1297-4311-9932-b6fabf0e9186/images/icon_important.png)

Important Select the default transaction type carefully. This action is irreversible after enablement.

1.  Create a Transaction Processing Type record and specify preferences that use the [TransactionProcessingType Tooling API](https://developer.salesforce.com/docs/atlas.en-us.revenue_lifecycle_management_dev_guide.meta/revenue_lifecycle_management_dev_guide/tooling_api_objects_transactionprocessingtype.htm) a
2.  From Setup, in the Quick Find box, search for and select **Revenue Settings**.
3.  Turn on Transaction processing for quotes and orders.
4.  Add the **Transaction Type** field to quote and order page layouts to provide override capabilities. See [Customize Page Layouts with the Enhanced Page Layout Editor](https://help.salesforce.com/s/articleView?id=platform.layouts_customize_ple.htm&language=en_US&type=5) and [Modify Field Access Settings](https://help.salesforce.com/s/articleView?id=platform.modifying_field_access_settings.htm&language=en_US&type=5).

# TransactionProcessingType

Represents the settings to configure the processing constraints for a request.. This object is available in API version 63.0 and later.

Important

Refer to the Usage section to learn more about creating Transaction Processing Type records based on your requirements. See the [setup details](https://help.salesforce.com/s/articleView?id=ind.product_configurator_specify_which_rule_engine_to_use.htm&language=en_US) to specify the default rule engine on the Revenue Settings page.

## Supported SOAP API Calls

create(), describeSObjects(), query(), retrieve()

## Supported REST API Methods

GET, HEAD, POST, Query

## Fields

> **Supported Editions:**<br>Description<br>
> 
> Type
> 
> string
> 
> Properties
> 
> Create, Filter, Group, Nillable, Sort, Update
> 
> Description
> 
> The description of the transaction processing configuration to help Salesforce admins with configuration in their orgs.
> 
> <br>DeveloperName<br>
> 
> Type
> 
> string
> 
> Properties
> 
> Create, Filter, Group, Sort, Update
> 
> Description
> 
> Required. The unique name of the object in the API. This name can contain only underscores and alphanumeric characters, and must be unique in your org. It must begin with a letter, not include spaces, not end with an underscore, and not contain two consecutive underscores. In managed packages, this field prevents naming conflicts on package installations. With this field, a developer can change the object’s name in a managed package and the changes are reflected in a subscriber’s organization. Label is **Record Type Name**.
> 
> <br>Language<br>
> 
> Type
> 
> picklist
> 
> Properties
> 
> Create, Defaulted on create, Filter, Group, Restricted picklist, Sort, Nillable, Update
> 
> Description
> 
> The language of the TransactionProcessingType object.
> 
> Valid values are:
> 
> *   da—Danish
> *   de—German
> *   en\_US—English
> *   es—Spanish
> *   es\_MX—Spanish (Mexico)
> *   fi—Finnish
> *   fr—French
> *   it—Italian
> *   ja—Japanese
> *   ko—Korean
> *   nl\_NL—Dutch
> *   no—Norwegian
> *   pt\_BR—Portuguese (Brazil)
> *   ru—Russian
> *   sv—Swedish
> *   th—Thai
> *   zh\_CN—Chinese (Simplified)
> *   zh\_TW—Chinese (Traditional)
> 
> <br>MasterLabel<br>
> 
> Type
> 
> string
> 
> Properties
> 
> Create, Filter, Group, Sort, Update
> 
> Description
> 
> The label for the TransactionProcessingType object.
> 
> <br>PricingPreference<br>
> 
> Type
> 
> string
> 
> Properties
> 
> Create, Filter, Group, Nillable, Restricted picklist, Sort, Update
> 
> Description
> 
> Specifies whether to execute the price calculation step for each sales transaction record. Valid values are:
> 
> *   Force—Reprices all lines.
> *   System—Performs a delta pricing request on the unprocessed lines when [Delta Pricing](https://help.salesforce.com/s/articleView?id=ind.qocal_use_delta_pricing_for_quotes_and_orders.htm&language=en_US) is enabled in the org.
> *   Skip—Skips the pricing request on all lines.
> 
> Available in API version 65.0 and later.
> 
> <br>RatingPreference<br>
> 
> Type
> 
> string
> 
> Properties
> 
> Description
> 
> Specifies whether catalog rates are fetched and saved during quote creation. Valid value is Fetch. Use this value to retrieve and save catalog rates for usage resources associated with each sales transaction record. If this value isn't specified, catalog rates aren't saved by default when a quote line item is added to a quote.
> 
> Available in API version 66.0 and later if Rate Management is enabled.
> 
> <br>RuleEngine<br>
> 
> Type
> 
> picklist
> 
> Properties
> 
> Create, Filter, Group, Nillable, Restricted picklist, Sort
> 
> Description
> 
> The rule engine to be used for processing rules.
> 
> Valid values are:
> 
> *   AdvancedConfigurator
> *   StandardConfigurator
> 
> <br>SaveType<br>
> 
> Type
> 
> picklist
> 
> Properties
> 
> Create, Filter, Group, Restricted picklist, Sort, Update
> 
> Description
> 
> Specifies how the transaction results are processed when saved for Salesforce administrators to adjust the user experience as desired. Valid values are:
> 
> *   Standard
> *   Large—Reserved for future use.
> 
> <br>TaxPreference<br>
> 
> Type
> 
> picklist
> 
> Properties
> 
> Create, Filter, Group, Nillable, Restricted picklist, Sort, Update
> 
> Description
> 
> Specifies whether to execute or skip the tax calculation step for each sales transaction record.
> 
> Valid value is Skip. If this value isn't specified, then tax calculation request is performed by default. Available in API version 65.0 and later.

## Usage

Create transaction type records by calling this resource through a POST method.

```
1/services/data/v67.0/tooling/sobjects/TransactionProcessingType
```

Here's a sample payload that specifies the rule engine to use and steps to skip for each sales transaction record.

```
1{
2  "SaveType": "Standard",
3  "Description": "Setup for Transaction Processing Type",
4  "DeveloperName": "SkipPricingAndTaxStep",
5  "MasterLabel": "SkipPricingAndTaxStep",
6  "RuleEngine": "StandardConfigurator",
7  "PricingPreference": "Skip",
8  "TaxPreference": "Skip"
9}
```

Here's a sample payload that specifies a value for rating preference and the steps to skip for each sales transaction record.

```
1{
2  "SaveType": "Standard",
3  "Description": "Setup for Transaction Processing Type",
4  "DeveloperName": "SkipPricingAndTaxStep",
5  "MasterLabel": "SkipPricingAndTaxStep",
6  "RuleEngine": "StandardConfigurator",
7  "PricingPreference": "Skip",
8  "TaxPreference": "Skip",
9  "RatingPreference": "Fetch"
10}
```