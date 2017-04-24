<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Decommission_Hosted_GMS</fullName>
        <ccEmails>notifications@silver-peak.com</ccEmails>
        <ccEmails>ithelp@silver-peak.com</ccEmails>
        <description>Decommission Hosted GMS</description>
        <protected>false</protected>
        <recipients>
            <recipient>curtisc@silver-peak.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>mueno@silver-peak.com</recipient>
            <type>user</type>
        </recipients>
        <senderAddress>notifications@silver-peak.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>POC/HostGMS2bremoved</template>
    </alerts>
    <alerts>
        <fullName>Hosted_GMS_Fulfillment</fullName>
        <ccEmails>notifications@silver-peak.com</ccEmails>
        <description>Hosted GMS Fulfillment</description>
        <protected>false</protected>
        <recipients>
            <type>accountOwner</type>
        </recipients>
        <recipients>
            <recipient>Account Manager</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>Sales Manager</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>Systems Engineer</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <field>ContactId</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <type>creator</type>
        </recipients>
        <senderAddress>notifications@silver-peak.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Support/NewHostedGMSLicemseFulfillment</template>
    </alerts>
    <alerts>
        <fullName>NewVirtualAssetFulfillment</fullName>
        <description>Fulfillment Email to contact when a new Virtual Asset is created for them</description>
        <protected>false</protected>
        <recipients>
            <type>accountOwner</type>
        </recipients>
        <recipients>
            <recipient>Account Manager</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>Systems Engineer</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <field>ContactId</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <type>creator</type>
        </recipients>
        <recipients>
            <recipient>kreichert@silver-peak.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>rmarqueling@silver-peak.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Support/NewVirtualAssetFulfillment</template>
    </alerts>
    <alerts>
        <fullName>NewVirtualAssetFulfillmentv2</fullName>
        <ccEmails>notifications@silver-peak.com</ccEmails>
        <description>Fulfillment Email to contact when a new Virtual Asset is created for them</description>
        <protected>false</protected>
        <recipients>
            <recipient>Account Manager</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>Systems Engineer</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <field>ContactId</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <field>Shipment_Contact__c</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>notifications@silver-peak.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>SubscriptionLicense/VXFulfillmentEmailAtAsset</template>
    </alerts>
    <alerts>
        <fullName>NewVirtualGXVAssetFulfillmentv2</fullName>
        <ccEmails>notifications@silver-peak.com</ccEmails>
        <description>Fulfillment Email to contact when a new GXV Virtual Asset is created for them</description>
        <protected>false</protected>
        <recipients>
            <recipient>Account Manager</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>Systems Engineer</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <field>ContactId</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <field>Shipment_Contact__c</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>notifications@silver-peak.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>POC/NewVirtualGXVAssetFulfillment</template>
    </alerts>
    <alerts>
        <fullName>Notify_Customer_that_license_key_has_been_renewed_on_Asset</fullName>
        <ccEmails>notifications@silver-peak.com</ccEmails>
        <description>Notify Customer that license key has been renewed on Asset</description>
        <protected>false</protected>
        <recipients>
            <type>accountOwner</type>
        </recipients>
        <recipients>
            <recipient>Account Manager</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>Systems Engineer</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <field>ContactId</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <field>Shipment_Contact__c</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>notifications@silver-peak.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Support/RenewedVirtualAssetFulfillment2</template>
    </alerts>
    <alerts>
        <fullName>Notify_Customer_that_license_key_has_been_renewed_on_Unity_Cloud_Asset</fullName>
        <ccEmails>notifications@silver-peak.com</ccEmails>
        <description>Notify Customer that license key has been renewed on Unity Cloud Asset</description>
        <protected>false</protected>
        <recipients>
            <type>accountOwner</type>
        </recipients>
        <recipients>
            <recipient>Account Manager</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>Systems Engineer</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <field>ContactId</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>notifications@silver-peak.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>SubscriptionLicense/NewUnityCloudAssetRenewal</template>
    </alerts>
    <alerts>
        <fullName>Notify_Fulfillment_Team_for_Hosted_GMS</fullName>
        <ccEmails>notifications@silver-peak.com</ccEmails>
        <ccEmails>ithelp@silver-peak.com</ccEmails>
        <description>Notify Fulfillment Team for Hosted GMS</description>
        <protected>false</protected>
        <recipients>
            <recipient>curtisc@silver-peak.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>mueno@silver-peak.com</recipient>
            <type>user</type>
        </recipients>
        <senderAddress>notifications@silver-peak.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>POC/HostGMSCreated</template>
    </alerts>
    <alerts>
        <fullName>Notify_GMS_License_Upgrade</fullName>
        <ccEmails>notifications@silver-peak.com</ccEmails>
        <description>Notify GMS License Upgrade</description>
        <protected>false</protected>
        <recipients>
            <recipient>Account Manager</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>Systems Engineer</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <field>ContactId</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <field>Shipment_Contact__c</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>notifications@silver-peak.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Support/NewGMSLicemseFulfillment</template>
    </alerts>
    <alerts>
        <fullName>SendMarketPlaceFulfillmentEmail</fullName>
        <ccEmails>notifications@silver-peak.com</ccEmails>
        <description>SendMarketPlaceFulfillmentEmail</description>
        <protected>false</protected>
        <recipients>
            <field>ContactId</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>notifications@silver-peak.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Free_Trial_Offer/FulfillmentForMarketplaceTrial</template>
    </alerts>
    <alerts>
        <fullName>SendMarketPlaceFulfillmentEmailEQ</fullName>
        <ccEmails>notifications@silver-peak.com</ccEmails>
        <description>SendMarketPlaceFulfillmentEmailEQ</description>
        <protected>false</protected>
        <recipients>
            <field>ContactId</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>notifications@silver-peak.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Support/EQFulfillmentForMarketplaceTrial</template>
    </alerts>
    <alerts>
        <fullName>SendMarketPlaceFulfillmentEmailVelocity</fullName>
        <ccEmails>notifications@silver-peak.com</ccEmails>
        <description>SendMarketPlaceFulfillmentEmailVelocity</description>
        <protected>false</protected>
        <recipients>
            <field>ContactId</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>notifications@silver-peak.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Support/VelocityFulfillmentForMarketplaceTrial</template>
    </alerts>
    <alerts>
        <fullName>SendMarketPlaceGMSFulfillmentEmail</fullName>
        <ccEmails>notifications@silver-peak.com</ccEmails>
        <description>SendMarketPlaceGMSFulfillmentEmail</description>
        <protected>false</protected>
        <recipients>
            <field>ContactId</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>notifications@silver-peak.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Maintenance_Renewals/FulfillmentForGMSMarketplaceTrial</template>
    </alerts>
    <alerts>
        <fullName>SendNonMarketPlaceFulfillmentEmailUnityCloud</fullName>
        <ccEmails>notifications@silver-peak.com</ccEmails>
        <description>SendNonMarketPlaceFulfillmentEmailUnityCloud</description>
        <protected>false</protected>
        <recipients>
            <recipient>Account Manager</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>Systems Engineer</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <field>ContactId</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <field>Shipment_Contact__c</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>notifications@silver-peak.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>SubscriptionLicense/NewUnityCloudAssetFulFillment2</template>
    </alerts>
    <alerts>
        <fullName>SendNonMarketPlaceFulfillmentEmailVelocity</fullName>
        <ccEmails>notifications@silver-peak.com</ccEmails>
        <description>SendNonMarketPlaceFulfillmentEmailVelocity</description>
        <protected>false</protected>
        <recipients>
            <recipient>Account Manager</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>Systems Engineer</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <field>ContactId</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <field>Shipment_Contact__c</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>notifications@silver-peak.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Maintenance_Renewals/VelocityFulfillmentForNONMarketplace</template>
    </alerts>
    <alerts>
        <fullName>Send_Market_Place_Fulfillment_Email_For_AMI</fullName>
        <ccEmails>notifications@silver-peak.com</ccEmails>
        <description>Send Market Place Fulfillment Email For AMI</description>
        <protected>false</protected>
        <recipients>
            <field>ContactId</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>notifications@silver-peak.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Support/AMIFulfillmentForMarketplaceTrial</template>
    </alerts>
    <alerts>
        <fullName>Send_Replacements_Notices</fullName>
        <ccEmails>notifications@silver-peak.com</ccEmails>
        <description>Send Replacements Notices</description>
        <protected>false</protected>
        <recipients>
            <type>accountOwner</type>
        </recipients>
        <recipients>
            <recipient>Account Manager</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>Systems Engineer</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>RMA Notices</recipient>
            <type>caseTeam</type>
        </recipients>
        <recipients>
            <field>ReplaceSNEmail1__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>ReplaceSNEmail2__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>ReplaceSNEmail3__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>notifications@silver-peak.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Support/RMAReplacementInfo</template>
    </alerts>
    <alerts>
        <fullName>X6Mbps_WAN_upgrade_authorization</fullName>
        <ccEmails>notifications@silver-peak.com</ccEmails>
        <ccEmails>tseteam@silver-peak.com</ccEmails>
        <description>Email Alert for when the 6Mbps WAN bandwidth upgrade</description>
        <protected>false</protected>
        <recipients>
            <recipient>Account Manager</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>Case Updates</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>Channel Manager</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>Executive Sponsor</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>Inside Sale Representative</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>Lead Qualifier</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>RMA Notices</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>Sales Manager</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>Sales Rep</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>Systems Engineer</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <field>ContactId</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <field>Shipment_Contact__c</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>notifications@silver-peak.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>DealRegistrations/X6Mbps_WAN_upgrade_authorization</template>
    </alerts>
    <fieldUpdates>
        <fullName>Add_Software_Support_Date</fullName>
        <field>End_of_Software_Support__c</field>
        <formula>DATE( (YEAR( Ship_Date__c   )+ 5) ,MONTH( Ship_Date__c) , DAY( Ship_Date__c) )</formula>
        <name>Add Software Support Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Add_Warranty_End_Date</fullName>
        <field>Warranty_End_Date__c</field>
        <formula>IF((Product2.EC_Term_in_Years__c !=null) ,DATE( (YEAR( Ship_Date__c )+ Product2.EC_Term_in_Years__c) ,MONTH( Ship_Date__c) , DAY( Ship_Date__c) ),null)</formula>
        <name>Add Warranty End Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Add_Warranty_Start_Date</fullName>
        <field>Warranty_Start_Date__c</field>
        <formula>IF((Product2.EC_Term_in_Years__c !=null) ,Ship_Date__c,null)</formula>
        <name>Add Warranty Start Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>AssetEvalEndDate</fullName>
        <description>Sets the Eval End date to 90 from Ship Date</description>
        <field>Evaluation_End_Date__c</field>
        <formula>if(or(ischanged(Ship_Date__c), ISNEW() ), 
if( Or( isblank( POCRequest__r.Target_End_Date__c ), isnull(POCRequest__r.Target_End_Date__c )), IF(ISPICKVAL(POCRequest__r.POC_Type__c,&apos;EdgeConnect&apos;),Ship_Date__c +45,Ship_Date__c +60), POCRequest__r.Target_End_Date__c ), 
Evaluation_End_Date__c )</formula>
        <name>AssetEvalEndDate</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>AssetEvalStartDate</fullName>
        <description>Update the eval start date to be equal to the ship date</description>
        <field>Evaluation_Start_Date__c</field>
        <formula>if(Or(ischanged(Ship_Date__c), ISNEW() ),

if( Or( isblank(POCRequest__r.Actual_Ship_Date__c ), isnull(POCRequest__r.Actual_Ship_Date__c )),  Ship_Date__c, POCRequest__r.Actual_Ship_Date__c), 

Evaluation_Start_Date__c )</formula>
        <name>AssetEvalStartDate</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>AssetWarrEndDate</fullName>
        <description>Sets the Asset Warranty End Date to Ship Date + 365</description>
        <field>Warranty_End_Date__c</field>
        <formula>if(or(ischanged(Ship_Date__c), ISNEW() ),Ship_Date__c  + 365,  Warranty_End_Date__c )</formula>
        <name>AssetWarrEndDate</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>AssetWarrStartDate</fullName>
        <description>Sets the Asset Warranty Start to be equal to Ship Date</description>
        <field>Warranty_Start_Date__c</field>
        <formula>if(or(ischanged(Ship_Date__c), ISNEW() ),Ship_Date__c, Warranty_Start_Date__c )</formula>
        <name>AssetWarrStartDate</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>CPPendingSyncStatus</fullName>
        <field>Cloud_Portal_Sync_Status__c</field>
        <literalValue>Pending</literalValue>
        <name>CPPendingSyncStatus</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>CPSyncStatus</fullName>
        <field>Sync_With_Cloud_Portal__c</field>
        <literalValue>1</literalValue>
        <name>CPSyncStatus</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>CleaEvalEnd</fullName>
        <field>Evaluation_End_Date__c</field>
        <name>CleaEvalEnd</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ClearEvalStart</fullName>
        <field>Evaluation_Start_Date__c</field>
        <name>ClearEvalStart</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ClearGMSNodes</fullName>
        <field>GMS_Nodes__c</field>
        <name>ClearGMSNodes</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ClearSendReplacement</fullName>
        <field>SendReplacementNotice__c</field>
        <literalValue>0</literalValue>
        <name>ClearSendReplacement</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ClearTriggerAutoFulfill</fullName>
        <field>TriggerAutoFulfillEmail__c</field>
        <literalValue>0</literalValue>
        <name>ClearTriggerAutoFulfill</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Clear_Cloud_Portal_Status</fullName>
        <field>Cloud_Portal_Sync_Status__c</field>
        <name>Clear Cloud Portal Status</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Clear_Cloud_Portal_Status_for_Metered</fullName>
        <field>Cloud_Portal_Sync_Status__c</field>
        <name>Clear Cloud Portal Status for Metered</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Clear_GMS_Upgrading</fullName>
        <field>GMS_Upgrading__c</field>
        <literalValue>0</literalValue>
        <name>Clear GMS_Upgrading</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Clear_Sync_Flag</fullName>
        <field>Sync_With_Cloud_Portal__c</field>
        <literalValue>0</literalValue>
        <name>Clear Sync Flag</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Clear_Sync_Flag_for_Metered_Assets</fullName>
        <field>Sync_With_Cloud_Portal__c</field>
        <literalValue>0</literalValue>
        <name>Clear Sync Flag for Metered Assets</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>SetEvalEndDate</fullName>
        <field>Evaluation_End_Date__c</field>
        <formula>today()+91</formula>
        <name>SetEvalEndDate</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>SetEvalStartDate</fullName>
        <field>Evaluation_Start_Date__c</field>
        <formula>today()</formula>
        <name>SetEvalStartDate</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>SetIPAddressFlag</fullName>
        <description>checks the box that the email was sent already</description>
        <field>IPAddressEmailSent__c</field>
        <literalValue>1</literalValue>
        <name>SetIPAddressFlag</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>SetPassword</fullName>
        <field>Password__c</field>
        <formula>( 
if( 
len( 
text(MONTH( License_Expiration__c )) 
) = 1, 
&quot;0&quot;+text(MONTH( License_Expiration__c )), 
text(MONTH( License_Expiration__c )) 
)+ 
if( 
len( 
text(DAY( License_Expiration__c )) 
) = 1, 
&quot;0&quot;+text(DAY( License_Expiration__c )), 
text(DAY( License_Expiration__c )) 
) +  
Right(Text(Year( License_Expiration__c )),2) +
right(Id,4))</formula>
        <name>SetPassword</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>SetSNtoAssetName</fullName>
        <field>SerialNumber</field>
        <formula>Name</formula>
        <name>SetSNtoAssetName</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>SetShipDate</fullName>
        <field>Ship_Date__c</field>
        <formula>today()</formula>
        <name>SetShipDate</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>SetUserName</fullName>
        <field>Username__c</field>
        <formula>&quot;Admin&quot;</formula>
        <name>SetUserName</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Uncheck_Renewal_License_Key_Generated</fullName>
        <field>Renewal_Key_Generated__c</field>
        <literalValue>0</literalValue>
        <name>Uncheck Renewal License Key Generated</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Unity_Uncheck_Renewal_Licen_Key</fullName>
        <field>Renewal_Key_Generated__c</field>
        <literalValue>0</literalValue>
        <name>Unity Uncheck Renewal Licen Key</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>6Mbps WAN upgrade checked</fullName>
        <actions>
            <name>X6Mbps_WAN_upgrade_authorization</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Asset.X6Mbps_WAN_bandwidth_upgrade__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>An email is sent when the 6Mbps WAN bandwidth upgrade checkbox is checked</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>AssetRenewalKeyGenerated</fullName>
        <actions>
            <name>Notify_Customer_that_license_key_has_been_renewed_on_Asset</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Uncheck_Renewal_License_Key_Generated</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Asset.Renewal_Key_Generated__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Asset.Model__c</field>
            <operation>notEqual</operation>
            <value>UNITY CLOUD</value>
        </criteriaItems>
        <description>upon renewal license key, send notice for new key</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>CPUpdateAssets</fullName>
        <actions>
            <name>CPPendingSyncStatus</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>CPSyncStatus</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>AND (  
OR(  BEGINS(Product2.Name,&quot;EC&quot;),  BEGINS(Product2.Name,&quot;UNITY CLOUD&quot;) ), 
 NOT(Product2.Name == &quot;EC-ORCH&quot;), 
 OR( ISPICKVAL(Status,&quot;Customer Subscription Active&quot;), ISPICKVAL(Status,&quot;Customer Subscription&quot;), ISPICKVAL(Status,&quot;Customer Evaluation&quot;),  ISPICKVAL(Status,&quot;Customer Owned&quot;), ISPICKVAL(Status,&quot;Loan&quot;), ISPICKVAL(Status,&quot;Conditional PO&quot;) ),  
 ISPICKVAL(Product2.Family,&quot;Virtual Image&quot;),  
 OR(ISNew(),  ISCHANGED(License_End_Date__c),  ISCHANGED(Bandwidth_Nodes__c),  ISCHANGED(Licenses_Nodes__c),ISCHANGED(Status),ISCHANGED(Contract_Number__c) ) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Check Account key</fullName>
        <active>false</active>
        <criteriaItems>
            <field>Asset.Name</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Clear Sync Flag for Metered Assets</fullName>
        <actions>
            <name>Clear_Cloud_Portal_Status_for_Metered</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Clear_Sync_Flag_for_Metered_Assets</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Account.Service_Provider_Account_Type__c</field>
            <operation>equals</operation>
            <value>Metered,Metered-Orchestrator SP</value>
        </criteriaItems>
        <criteriaItems>
            <field>Asset.Sync_With_Cloud_Portal__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>ClearGMSNodes</fullName>
        <actions>
            <name>ClearGMSNodes</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Asset.GMS_Nodes__c</field>
            <operation>greaterThan</operation>
            <value>1</value>
        </criteriaItems>
        <criteriaItems>
            <field>Product2.Model__c</field>
            <operation>notEqual</operation>
            <value>GX-V</value>
        </criteriaItems>
        <criteriaItems>
            <field>Product2.Product_Category__c</field>
            <operation>notEqual</operation>
            <value>GMS</value>
        </criteriaItems>
        <criteriaItems>
            <field>Product2.Model__c</field>
            <operation>notEqual</operation>
            <value>GX-1000</value>
        </criteriaItems>
        <criteriaItems>
            <field>Product2.Model__c</field>
            <operation>notEqual</operation>
            <value>GX-1100</value>
        </criteriaItems>
        <description>Clear GMS Nodes for non GX products</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>ClearSyncFlagforSPAccount</fullName>
        <actions>
            <name>Clear_Cloud_Portal_Status</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Clear_Sync_Flag</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>AND 
( 
OR(Account.Name =&quot;Silver Peak Systems&quot;,
NOT(ISBLANK(SBQQ__QuoteLine__c ))
), 
Sync_With_Cloud_Portal__c =true, 
IsPICKVAL(Product2.Family ,&quot;Product&quot;), 
BEGINS( Product2.Name ,&quot;EC&quot;) 
)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>EC Hardware Add Warranty Dates</fullName>
        <actions>
            <name>Add_Software_Support_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Add_Warranty_End_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Add_Warranty_Start_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>AND(
ISPICKVAL( Product2.Family,&quot;Product&quot;),
BEGINS(  Product_Name_And_Nodes__c,&quot;EC&quot; ),
ISPICKVAL(Status,&quot;Customer Owned&quot;),
OR(
ISNEW(),
ISCHANGED( Ship_Date__c ),
ISCHANGED(  Product2Id )
)
)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>FulfillmentForVelocity</fullName>
        <active>false</active>
        <description>This is the workflow rule that sends the velocity fulfillment email to the contact</description>
        <formula>AND  (  NOT(ISBLANK(POCRequest__c )),  Key_Generated__c ,  Marketplace_Sourced_Opp__c ==0, DATEVALUE( CreatedDate )== today(), OR(  Model__c==&quot;Velocity&quot;,  Model__c==&quot;VRX-2&quot;, Model__c==&quot;VRX-4&quot;, Model__c==&quot;VRX-6&quot;, Model__c==&quot;VRX-8&quot; )  )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>SendNonMarketPlaceFulfillmentEmailVelocity</name>
                <type>Alert</type>
            </actions>
            <timeLength>1</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>GMSLicenseUpgraded</fullName>
        <actions>
            <name>Notify_GMS_License_Upgrade</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Clear_GMS_Upgrading</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Product2.Product_Category__c</field>
            <operation>equals</operation>
            <value>GMS</value>
        </criteriaItems>
        <criteriaItems>
            <field>Asset.Hosted_GMS__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Asset.GMS_Upgrading__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>Send an email the contact and creator (plus account team and finance) when a GMS asset is upgraded and license key generated</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>GMSmoved2SupportAccount</fullName>
        <active>true</active>
        <description>when the POC is completed the GMS asset is moved the Email Support Contacts account. 30 days later, this notice is sent to remove the asset</description>
        <formula>And(Account.Id =&apos;0015000000bl7iv&apos;, Hosted_GMS__c )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Decommission_Hosted_GMS</name>
                <type>Alert</type>
            </actions>
            <timeLength>1</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Hosted GMS asset was created</fullName>
        <active>true</active>
        <criteriaItems>
            <field>Asset.Hosted_GMS__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Notify_Fulfillment_Team_for_Hosted_GMS</name>
                <type>Alert</type>
            </actions>
            <actions>
                <name>SetPassword</name>
                <type>FieldUpdate</type>
            </actions>
            <actions>
                <name>SetUserName</name>
                <type>FieldUpdate</type>
            </actions>
            <timeLength>1</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>HostedGMSFulfillment</fullName>
        <actions>
            <name>Hosted_GMS_Fulfillment</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>SetIPAddressFlag</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>And(
 Hosted_GMS__c ,
NOT ISBLANK( IP_Address__c ),
NOT( IPAddressEmailSent__c ))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>MarketPlaceGMSTrialFulfillment</fullName>
        <actions>
            <name>SendMarketPlaceGMSFulfillmentEmail</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 AND 2 AND 3 AND 4 AND 5 AND 6</booleanFilter>
        <criteriaItems>
            <field>Asset.Marketplace_Sourced_Opp__c</field>
            <operation>equals</operation>
            <value>1</value>
        </criteriaItems>
        <criteriaItems>
            <field>Asset.Key_Generated__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Asset.CreatedDate</field>
            <operation>equals</operation>
            <value>TODAY</value>
        </criteriaItems>
        <criteriaItems>
            <field>Asset.Model__c</field>
            <operation>equals</operation>
            <value>GX-V</value>
        </criteriaItems>
        <criteriaItems>
            <field>Asset.Model__c</field>
            <operation>notEqual</operation>
            <value>VX-EQ</value>
        </criteriaItems>
        <criteriaItems>
            <field>Asset.Model__c</field>
            <operation>notContain</operation>
            <value>VX-AMI</value>
        </criteriaItems>
        <description>This is the workflow rule that sends the fulfillment email to the contact for with their license keys</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>MarketPlaceTrialFulfillment</fullName>
        <actions>
            <name>SendMarketPlaceFulfillmentEmail</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 AND 2 AND 3 AND 4 AND 5 AND 6 AND 7 AND 8 AND 9 AND 10 AND 11 AND 12 AND 13</booleanFilter>
        <criteriaItems>
            <field>Asset.Marketplace_Sourced_Opp__c</field>
            <operation>equals</operation>
            <value>1</value>
        </criteriaItems>
        <criteriaItems>
            <field>Asset.Key_Generated__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Asset.CreatedDate</field>
            <operation>equals</operation>
            <value>TODAY</value>
        </criteriaItems>
        <criteriaItems>
            <field>Asset.Model__c</field>
            <operation>notEqual</operation>
            <value>Velocity</value>
        </criteriaItems>
        <criteriaItems>
            <field>Asset.Model__c</field>
            <operation>notEqual</operation>
            <value>VX-EQ</value>
        </criteriaItems>
        <criteriaItems>
            <field>Asset.Download_Source__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Asset.Model__c</field>
            <operation>notEqual</operation>
            <value>VX-XEN</value>
        </criteriaItems>
        <criteriaItems>
            <field>Asset.Model__c</field>
            <operation>notEqual</operation>
            <value>VRX-2</value>
        </criteriaItems>
        <criteriaItems>
            <field>Asset.Model__c</field>
            <operation>notEqual</operation>
            <value>VRX-4</value>
        </criteriaItems>
        <criteriaItems>
            <field>Asset.Model__c</field>
            <operation>notEqual</operation>
            <value>VRX-8</value>
        </criteriaItems>
        <criteriaItems>
            <field>Asset.Model__c</field>
            <operation>notEqual</operation>
            <value>GX-V</value>
        </criteriaItems>
        <criteriaItems>
            <field>Asset.Model__c</field>
            <operation>notContain</operation>
            <value>VX-AMI</value>
        </criteriaItems>
        <criteriaItems>
            <field>Asset.Model__c</field>
            <operation>notEqual</operation>
            <value>VRX-6</value>
        </criteriaItems>
        <description>This is the workflow rule that sends the fulfillment email to the contact for with their license keys</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <timeLength>1</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>MarketPlaceTrialFulfillmentAMI</fullName>
        <actions>
            <name>Send_Market_Place_Fulfillment_Email_For_AMI</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Asset.Marketplace_Sourced_Opp__c</field>
            <operation>equals</operation>
            <value>1</value>
        </criteriaItems>
        <criteriaItems>
            <field>Asset.Key_Generated__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Asset.CreatedDate</field>
            <operation>equals</operation>
            <value>TODAY</value>
        </criteriaItems>
        <criteriaItems>
            <field>Asset.Model__c</field>
            <operation>startsWith</operation>
            <value>VX-AMI</value>
        </criteriaItems>
        <description>This is the workflow rule that sends the fulfillment email to the contact when VX-AMI is created and the license is generated</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>MarketPlaceTrialFulfillmentEQ</fullName>
        <actions>
            <name>SendMarketPlaceFulfillmentEmailEQ</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Asset.Marketplace_Sourced_Opp__c</field>
            <operation>equals</operation>
            <value>1</value>
        </criteriaItems>
        <criteriaItems>
            <field>Asset.Key_Generated__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Asset.CreatedDate</field>
            <operation>equals</operation>
            <value>TODAY</value>
        </criteriaItems>
        <criteriaItems>
            <field>Asset.Model__c</field>
            <operation>equals</operation>
            <value>VX-EQ</value>
        </criteriaItems>
        <description>This is the workflow rule that sends the VX-EQ fulfillment email to the contact for with their license keys</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>MarketPlaceTrialFulfillmentVelocity</fullName>
        <actions>
            <name>SendMarketPlaceFulfillmentEmailVelocity</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 AND 2 AND 3 AND (4 OR 5 OR 6 OR 7 OR 8)</booleanFilter>
        <criteriaItems>
            <field>Asset.Marketplace_Sourced_Opp__c</field>
            <operation>equals</operation>
            <value>1</value>
        </criteriaItems>
        <criteriaItems>
            <field>Asset.Key_Generated__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Asset.CreatedDate</field>
            <operation>equals</operation>
            <value>TODAY</value>
        </criteriaItems>
        <criteriaItems>
            <field>Asset.Model__c</field>
            <operation>equals</operation>
            <value>Velocity</value>
        </criteriaItems>
        <criteriaItems>
            <field>Asset.Model__c</field>
            <operation>equals</operation>
            <value>VRX-2</value>
        </criteriaItems>
        <criteriaItems>
            <field>Asset.Model__c</field>
            <operation>equals</operation>
            <value>VRX-4</value>
        </criteriaItems>
        <criteriaItems>
            <field>Asset.Model__c</field>
            <operation>equals</operation>
            <value>VRX-8</value>
        </criteriaItems>
        <criteriaItems>
            <field>Asset.Model__c</field>
            <operation>equals</operation>
            <value>VRX-6</value>
        </criteriaItems>
        <description>This is the workflow rule that sends the velocity fulfillment email to the contact for with their license keys</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>New Unity Cloud Asset</fullName>
        <active>true</active>
        <criteriaItems>
            <field>Product2.Family</field>
            <operation>equals</operation>
            <value>Virtual Image</value>
        </criteriaItems>
        <criteriaItems>
            <field>Asset.Hosted_GMS__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Asset.Marketplace_Sourced_Opp__c</field>
            <operation>equals</operation>
            <value>0</value>
        </criteriaItems>
        <criteriaItems>
            <field>Asset.Model__c</field>
            <operation>equals</operation>
            <value>UNITY CLOUD</value>
        </criteriaItems>
        <description>Unity Cloud Fulfilment</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>SendNonMarketPlaceFulfillmentEmailUnityCloud</name>
                <type>Alert</type>
            </actions>
            <timeLength>1</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>NewVirtualAsset</fullName>
        <actions>
            <name>SetSNtoAssetName</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>NonVelocityFulfillment</description>
        <formula>AND (ISPICKVAL(Product2.Family,&quot;Virtual Image&quot;),  NOT(Hosted_GMS__c),  Marketplace_Sourced_Opp__c ==0,  NOT(CONTAINS(Product2.Model__c , &quot;GX&quot;) ),  OR(  Model__c==&quot;VX-0000&quot;,  Model__c==&quot;VX-1000&quot;,  Model__c==&quot;VX-500&quot;, Model__c==&quot;VX-2000&quot;,  Model__c==&quot;VX-3000&quot;,  Model__c==&quot;VX-4000&quot;, Model__c==&quot;VX-5000&quot;,  Model__c==&quot;VX-6000&quot;,  Model__c==&quot;VX-7000&quot;, Model__c==&quot;VX-8000&quot;,  Model__c==&quot;VX-9000&quot; ),
NOT(TriggerAutoFulfillEmail__c)
)</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>NewVirtualAsset_AutoFulfill</fullName>
        <actions>
            <name>SetSNtoAssetName</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 AND 2 AND 4 AND 3 AND (5 OR 6) AND 7</booleanFilter>
        <criteriaItems>
            <field>Product2.Family</field>
            <operation>equals</operation>
            <value>Virtual Image</value>
        </criteriaItems>
        <criteriaItems>
            <field>Asset.Hosted_GMS__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Product2.Model__c</field>
            <operation>notContain</operation>
            <value>GX</value>
        </criteriaItems>
        <criteriaItems>
            <field>Asset.Marketplace_Sourced_Opp__c</field>
            <operation>equals</operation>
            <value>0</value>
        </criteriaItems>
        <criteriaItems>
            <field>Asset.Model__c</field>
            <operation>equals</operation>
            <value>VX-0000,VX-500,VX-1000,VX-2000,VX-3000</value>
        </criteriaItems>
        <criteriaItems>
            <field>Asset.Model__c</field>
            <operation>equals</operation>
            <value>VX-4000,VX-5000,VX-6000,VX-7000,VX-8000,VX-9000</value>
        </criteriaItems>
        <criteriaItems>
            <field>Asset.TriggerAutoFulfillEmail__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>NonVelocityFulfillment</description>
        <triggerType>onCreateOnly</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>NewVirtualAssetFulfillmentv2</name>
                <type>Alert</type>
            </actions>
            <timeLength>1</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>NewVirtualAsset_Old</fullName>
        <actions>
            <name>SetSNtoAssetName</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <description>NonVelocityFulfillment</description>
        <formula>AND (  NOT(ISBLANK(POCRequest__c )),  ISPICKVAL(Product2.Family,&quot;Virtual Image&quot;),  NOT(Hosted_GMS__c),  Marketplace_Sourced_Opp__c ==0,  NOT(CONTAINS(Product2.Model__c , &quot;GX&quot;) ),  OR(  Model__c==&quot;VX-0000&quot;,  Model__c==&quot;VX-1000&quot;,  Model__c==&quot;VX-500&quot;, Model__c==&quot;VX-2000&quot;,  Model__c==&quot;VX-3000&quot;,  Model__c==&quot;VX-4000&quot;, Model__c==&quot;VX-5000&quot;,  Model__c==&quot;VX-6000&quot;,  Model__c==&quot;VX-7000&quot;, Model__c==&quot;VX-8000&quot;,  Model__c==&quot;VX-9000&quot; ) )</formula>
        <triggerType>onCreateOnly</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>NewVirtualAssetFulfillmentv2</name>
                <type>Alert</type>
            </actions>
            <timeLength>1</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>NewVirtualGXVAsset</fullName>
        <actions>
            <name>SetSNtoAssetName</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Product2.Family</field>
            <operation>equals</operation>
            <value>Virtual Image</value>
        </criteriaItems>
        <criteriaItems>
            <field>Asset.Hosted_GMS__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Product2.Model__c</field>
            <operation>contains</operation>
            <value>GX</value>
        </criteriaItems>
        <criteriaItems>
            <field>Asset.Marketplace_Sourced_Opp__c</field>
            <operation>equals</operation>
            <value>0</value>
        </criteriaItems>
        <description>Send an email the contact and creator (plus account team and finance) when a new virtual asset is crreated and license key generated</description>
        <triggerType>onCreateOnly</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>NewVirtualGXVAssetFulfillmentv2</name>
                <type>Alert</type>
            </actions>
            <timeLength>1</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>SendReplacementNotice</fullName>
        <actions>
            <name>Send_Replacements_Notices</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>ClearSendReplacement</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Asset.SendReplacementNotice__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>when a unit is swapped on a shipment for advance replacement</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>ShipDateTrigger</fullName>
        <actions>
            <name>AssetEvalEndDate</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>AssetEvalStartDate</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>AssetWarrEndDate</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>AssetWarrStartDate</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 AND 2</booleanFilter>
        <criteriaItems>
            <field>Asset.Status</field>
            <operation>equals</operation>
            <value>Customer Evaluation</value>
        </criteriaItems>
        <criteriaItems>
            <field>Product2.Family</field>
            <operation>notEqual</operation>
            <value>Virtual Image</value>
        </criteriaItems>
        <description>fires the field updates looking for shipdate changes</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>ShipDateTrigger-customer</fullName>
        <actions>
            <name>AssetWarrEndDate</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>AssetWarrStartDate</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 AND 2 AND (NOT 3)</booleanFilter>
        <criteriaItems>
            <field>Asset.Status</field>
            <operation>equals</operation>
            <value>Customer Owned,Conditional PO</value>
        </criteriaItems>
        <criteriaItems>
            <field>Product2.Family</field>
            <operation>notEqual</operation>
            <value>Virtual Image</value>
        </criteriaItems>
        <criteriaItems>
            <field>Asset.Product_Name_And_Nodes__c</field>
            <operation>startsWith</operation>
            <value>EC</value>
        </criteriaItems>
        <description>fires the field updates looking for shipdate changes</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>ShipDateTrigger-customer-virtual</fullName>
        <actions>
            <name>CleaEvalEnd</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>ClearEvalStart</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Asset.Status</field>
            <operation>equals</operation>
            <value>Customer Owned</value>
        </criteriaItems>
        <criteriaItems>
            <field>Product2.Family</field>
            <operation>equals</operation>
            <value>Virtual Image</value>
        </criteriaItems>
        <description>fires the field updates for new customer owner virtual assets</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Unity_AssetRenewalKeyGenerated</fullName>
        <actions>
            <name>Notify_Customer_that_license_key_has_been_renewed_on_Unity_Cloud_Asset</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Unity_Uncheck_Renewal_Licen_Key</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Product2.Family</field>
            <operation>equals</operation>
            <value>Virtual Image</value>
        </criteriaItems>
        <criteriaItems>
            <field>Asset.Hosted_GMS__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Asset.Marketplace_Sourced_Opp__c</field>
            <operation>equals</operation>
            <value>0</value>
        </criteriaItems>
        <criteriaItems>
            <field>Asset.Model__c</field>
            <operation>equals</operation>
            <value>UNITY CLOUD</value>
        </criteriaItems>
        <criteriaItems>
            <field>Asset.Renewal_Key_Generated__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>This is created to send out the renewal licence emails for Unity CLOUD INTELLIGENCE PRODUCT</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>manual trigger</fullName>
        <actions>
            <name>ClearTriggerAutoFulfill</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Asset.TriggerAutoFulfillEmail__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>used to manually trigger asset fulfillment
assign proper email alert action 
activate rule and the field value to true on each asset
NOTE: VX, VRX and GX all will have different email rules and need to be handled individually.</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
