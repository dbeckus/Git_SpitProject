<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Send_Email_when_POC</fullName>
        <ccEmails>tek-talk@silver-peak.com</ccEmails>
        <description>Send Email when POC is completed to tek-talk@silver-peak.com</description>
        <protected>false</protected>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/POC_Summary_Report</template>
    </alerts>
    <fieldUpdates>
        <fullName>Clear_Email_Sending_for_POC</fullName>
        <field>Email_Sending__c</field>
        <literalValue>0</literalValue>
        <name>Clear Email Sending for POC</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>POCCompleteNotice</fullName>
        <actions>
            <name>Send_Email_when_POC</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Clear_Email_Sending_for_POC</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>POC_Summary__c.Email_Sending__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>This workflow is replaced by another trigger on POC Summary. Can be removed.</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
