<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Send_Shipment_Information_to_Account_Owner</fullName>
        <ccEmails>notifications@silver-peak.com</ccEmails>
        <description>Send Shipment Information to Account Owner</description>
        <protected>false</protected>
        <recipients>
            <recipient>Systems Engineer</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <field>Shipment_Contact__c</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <field>AccountOwnerEmail__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>Email__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>Secondary_Email__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>Third_Email__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>notifications@silver-peak.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/Shipment_Notification</template>
    </alerts>
    <fieldUpdates>
        <fullName>Enable_Send_Email_Flag</fullName>
        <field>Send_Email__c</field>
        <literalValue>1</literalValue>
        <name>Enable Send Email Flag</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>SetThirdEmail</fullName>
        <description>use the third email and copy down the TR email from the PO</description>
        <field>Third_Email__c</field>
        <formula>IF (NOT(ISBLANK(PurchaseOrder__r.Technical_Resposible_Email__c)),PurchaseOrder__r.Technical_Resposible_Email__c,Third_Email__c)</formula>
        <name>SetThirdEmail</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>Send Tracking Information</fullName>
        <actions>
            <name>SetThirdEmail</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Shipment__c.SendTrackingInformation__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Send_Shipment_Information_to_Account_Owner</name>
                <type>Alert</type>
            </actions>
            <timeLength>1</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>TriggerVXVRXFulfillmentEmail</fullName>
        <active>true</active>
        <formula>AND(  NOT(ISNULL(Name)),  NOT(ISNULL( Shipment_Contact__c )),  NOT(Send_Email__c ), IsVirtualShipment__c  )</formula>
        <triggerType>onCreateOnly</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Enable_Send_Email_Flag</name>
                <type>FieldUpdate</type>
            </actions>
            <timeLength>1</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
</Workflow>
