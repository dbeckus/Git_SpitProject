<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Information_Card_Send_Information_Card_Submitted_for_Approval</fullName>
        <description>Information Card: Send Information Card Submitted for Approval</description>
        <protected>false</protected>
        <recipients>
            <recipient>ewhite@silver-peak.com</recipient>
            <type>user</type>
        </recipients>
        <senderAddress>silverpeakinfo@silver-peak.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Partner_Account_Templates/Information_Card_Submitted_for_Approval</template>
    </alerts>
    <alerts>
        <fullName>Information_Card_Send_To_Primary_Partner_Information_Card_Submitted_Template</fullName>
        <description>Information Card: Send To Primary Partner: Information Card Submitted Template</description>
        <protected>false</protected>
        <recipients>
            <field>RegisteringUserContact__c</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>silverpeakinfo@silver-peak.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Partner_Account_Templates/To_Primary_Partner_Information_Card_Submitted</template>
    </alerts>
    <alerts>
        <fullName>Send_Information_Card_Submitted_for_Approval_cc</fullName>
        <ccEmails>channel@silver-peak.com</ccEmails>
        <description>Send Information Card Submitted for Approval cc</description>
        <protected>false</protected>
        <recipients>
            <recipient>ddalponte@silver-peak.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>mjones@silver-peak.com</recipient>
            <type>user</type>
        </recipients>
        <senderAddress>silverpeakinfo@silver-peak.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Partner_Account_Templates/Information_Card_Submitted_for_Approval</template>
    </alerts>
    <fieldUpdates>
        <fullName>Info_Card_Set_Status_Child_Acct_Created</fullName>
        <field>Status__c</field>
        <literalValue>Child Account Created</literalValue>
        <name>Info Card: Set Status-Child Acct Created</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Info_Card_Set_Status_Submitted</fullName>
        <field>Status__c</field>
        <literalValue>Submitted</literalValue>
        <name>Info Card: Set Status Submitted</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Info_Card_Set_Status_to_Approved</fullName>
        <field>Status__c</field>
        <literalValue>Approved</literalValue>
        <name>Info Card: Set Status to Approved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Info_Card_Set_Status_to_Merged</fullName>
        <field>Status__c</field>
        <literalValue>Merged</literalValue>
        <name>Info Card: Set Status to Merged</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Info_Card_Set_Status_to_Recalled</fullName>
        <field>Status__c</field>
        <literalValue>Recalled</literalValue>
        <name>Info Card: Set Status to Recalled</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Info_Card_Set_Status_to_Rejected</fullName>
        <field>Status__c</field>
        <literalValue>Rejected</literalValue>
        <name>Info Card: Set Status to Rejected</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Information Card%3A Submitted with Primary Partner Contact</fullName>
        <actions>
            <name>Information_Card_Send_To_Primary_Partner_Information_Card_Submitted_Template</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <formula>AND(
ISPICKVAL(Status__c,&quot;Submitted&quot;),
NOT(ISBLANK(PrimaryPartnerContact__c))
)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
