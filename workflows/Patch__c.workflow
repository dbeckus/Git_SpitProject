<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Email_Salesforce_Team_when_a_new_patch_is_created</fullName>
        <description>Email Salesforce Team when a new patch is created</description>
        <protected>false</protected>
        <recipients>
            <recipient>pmusunuru@silver-peak.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Patch_Creation_Email</template>
    </alerts>
    <rules>
        <fullName>Email IT when a new patch is created</fullName>
        <actions>
            <name>Email_Salesforce_Team_when_a_new_patch_is_created</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Patch__c.Active__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>An email is sent out to salesforce team when a new patch is created. This is to make sure the patch is marked GDRP if it belongs to GDPR Country</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
