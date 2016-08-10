<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Email_Self_Registration_has_been_Enabled</fullName>
        <description>Email - Self Registration has been Enabled</description>
        <protected>false</protected>
        <recipients>
            <field>Email</field>
            <type>email</type>
        </recipients>
        <senderAddress>notifications@silver-peak.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Support/SelfServiceNewUserLoginRegisteration</template>
    </alerts>
    <alerts>
        <fullName>Partner_Role_Updated_On_Contact</fullName>
        <ccEmails>Lindsey@snapbi.com</ccEmails>
        <description>Partner Role Updated On Contact</description>
        <protected>false</protected>
        <recipients>
            <recipient>curtisc@silver-peak.com</recipient>
            <type>user</type>
        </recipients>
        <senderAddress>silverpeakinfo@silver-peak.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/Partner_Role_Updated_On_Contact</template>
    </alerts>
    <fieldUpdates>
        <fullName>Contact_ISR_Notes</fullName>
        <field>ISR_Notes__c</field>
        <formula>&quot;------&quot; &amp; LEFT( $User.FirstName,1) &amp; &quot; &quot; &amp; $User.LastName &amp; &quot;: &quot; &amp; TEXT(Today()) &amp; &quot;------&quot; &amp; BR() &amp;
ISR_Notes__c</formula>
        <name>Contact ISR Notes</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Contact_Sales_Rejected_Date_Time_Stamp</fullName>
        <field>Sales_Rejected_Comments__c</field>
        <formula>&quot;------&quot; &amp; LEFT( $User.FirstName,1) &amp; &quot; &quot; &amp; $User.LastName &amp; &quot;: &quot; &amp; TEXT(Today()) &amp; &quot;------&quot; &amp; BR() &amp; 
Sales_Rejected_Comments__c</formula>
        <name>Contact Sales Rejected Date Time Stamp</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <outboundMessages>
        <fullName>BL__ContactUpdate</fullName>
        <apiVersion>8.0</apiVersion>
        <endpointUrl>https://www.boulderlogic.com/Reference/SfdcNotificationBinding.asmx?blns=BL</endpointUrl>
        <fields>Id</fields>
        <includeSessionId>true</includeSessionId>
        <integrationUser>prane@silver-peak.com</integrationUser>
        <name>ContactUpdate</name>
        <protected>false</protected>
        <useDeadLetterQueue>false</useDeadLetterQueue>
    </outboundMessages>
    <rules>
        <fullName>Add Date Time Stamp On Screening Notes</fullName>
        <actions>
            <name>Contact_ISR_Notes</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>AND(  ISChanged(ISR_Notes__c ),  LEN(ISR_Notes__c)&gt;0   )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>BL__ContactUpdate</fullName>
        <actions>
            <name>BL__ContactUpdate</name>
            <type>OutboundMessage</type>
        </actions>
        <active>true</active>
        <formula>ISCHANGED(LastModifiedDate)  &amp;&amp;   BL__SynchWithBoulderLogic__c  == true</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Contact Add Date Time Stamp On Sales Rejected Comments</fullName>
        <actions>
            <name>Contact_Sales_Rejected_Date_Time_Stamp</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>AND(  ISChanged( Sales_Rejected_Comments__c ),  LEN(Sales_Rejected_Comments__c )&gt;0   )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Contact%3A Contact Role Task Reminders</fullName>
        <actions>
            <name>Reminder_Set_Contact_Role_on_Opportunity</name>
            <type>Task</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Contact.Lead_Status__c</field>
            <operation>equals</operation>
            <value>Converted into Existing Opportunity</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Partner Role is Populated</fullName>
        <actions>
            <name>Partner_Role_Updated_On_Contact</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Contact.Partner_Role__c</field>
            <operation>notEqual</operation>
            <value>,User</value>
        </criteriaItems>
        <description>Alert to Admin that a User has been assigned a Manager or Executive Role</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>UponSetForSelfRegister</fullName>
        <actions>
            <name>Email_Self_Registration_has_been_Enabled</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>When a contact is enabled for self registration, this rule sends them an introduction email</description>
        <formula>CanAllowPortalSelfReg =True</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>UponTransferToPipeline</fullName>
        <active>false</active>
        <formula>OwnerId =&apos;00550000001DH8p&apos;</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <tasks>
        <fullName>Reminder_Set_Contact_Role_on_Opportunity</fullName>
        <assignedToType>creator</assignedToType>
        <description>Please remember to add this contact as a contact role on the existing opportunity.</description>
        <dueDateOffset>1</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>Not Started</status>
        <subject>Reminder: Set Contact Role on Opportunity</subject>
    </tasks>
</Workflow>
