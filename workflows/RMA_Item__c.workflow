<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>NewRMAitemadded</fullName>
        <ccEmails>rmaescalationnotification@silver-peak.com</ccEmails>
        <description>New RMA item added</description>
        <protected>false</protected>
        <recipients>
            <recipient>lquilici@silver-peak.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Support/NewRMACreated</template>
    </alerts>
    <fieldUpdates>
        <fullName>RMA_Item_Update_Email</fullName>
        <field>Contact_Email__c</field>
        <formula>RMA__r.Contact__r.Email</formula>
        <name>RMA Item Update Email</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>RMA_Item_Update_Phone</fullName>
        <field>Contact_Phone__c</field>
        <formula>RMA__r.Contact__r.Phone</formula>
        <name>RMA Item Update Phone</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>SetChassisValue</fullName>
        <description>uses a formula field to determine whether a system is the replacement part number</description>
        <field>Chassis__c</field>
        <formula>IsSystemReplacement__c</formula>
        <name>SetChassisValue</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UnDispatchSystemOrders</fullName>
        <description>for specific countries, systems order can&apos;t be dispatched.</description>
        <field>Status__c</field>
        <literalValue>Initiated</literalValue>
        <name>UnDispatchSystemOrders</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <targetObject>RMA__c</targetObject>
    </fieldUpdates>
    <rules>
        <fullName>RMA -new item added to an RMA</fullName>
        <actions>
            <name>NewRMAitemadded</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>SetChassisValue</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>RMA_Item__c.CreatedById</field>
            <operation>notEqual</operation>
            <value>NULL</value>
        </criteriaItems>
        <criteriaItems>
            <field>RMA_Item__c.CreatedDate</field>
            <operation>equals</operation>
            <value>TODAY</value>
        </criteriaItems>
        <criteriaItems>
            <field>RMA__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>RMA</value>
        </criteriaItems>
        <description>Set Chassis flag when new item is added to an RMA</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>UnDispatchSystemOrders</fullName>
        <actions>
            <name>UnDispatchSystemOrders</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>this rule is used to undispatch RMA&apos;s for countries we do not want systems to go to on replacement automatically</description>
        <formula>AND(
OR( ispickval(ShipToCountry__c, &apos;Argentina&apos;)
, ispickval(ShipToCountry__c, &apos;Mexico&apos;)
, ispickval(ShipToCountry__c, &apos;Hong Kong&apos;)
, ispickval(ShipToCountry__c, &apos;Saudi Arabia&apos;)
, ispickval(ShipToCountry__c, &apos;Indonesia&apos;)
, ispickval(ShipToCountry__c, &apos;Philippines&apos;)
, ispickval(ShipToCountry__c, &apos;Israel&apos;)
),  IsSystemReplacement__c =1
, ispickval( RMA__r.Status__c , &apos;Dispatched&apos;)
 )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Update Email and Phone for Convert to Virtual RMA</fullName>
        <actions>
            <name>RMA_Item_Update_Email</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>RMA_Item_Update_Phone</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>RMA__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>CMA</value>
        </criteriaItems>
        <criteriaItems>
            <field>RMA__c.Type__c</field>
            <operation>equals</operation>
            <value>Convert to Virtual</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
