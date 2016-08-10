<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Email_Delivered_To_Contact_on_SW_Only_Asset</fullName>
        <ccEmails>notifications@silver-peak.com</ccEmails>
        <description>Email Delivered To Contact on SW Only Asset</description>
        <protected>false</protected>
        <recipients>
            <field>Delivered_To__c</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <type>creator</type>
        </recipients>
        <senderAddress>notifications@silver-peak.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Support/NewSWOnlyAsset</template>
    </alerts>
    <rules>
        <fullName>FulfillSWOnlyAsset</fullName>
        <actions>
            <name>Email_Delivered_To_Contact_on_SW_Only_Asset</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>Delver to contact upon saving</description>
        <formula>OR(and(ISCHANGED( Delivered_To__c ),  ISBLANK( PRIORVALUE( Delivered_To__c  ))), ISNEW() )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
