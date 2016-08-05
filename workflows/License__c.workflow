<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Notify_Customer_that_license_key_has_been_renewed</fullName>
        <ccEmails>notifications@silver-peak.com</ccEmails>
        <description>Notify Customer that license key has been renewed</description>
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
            <type>campaignMemberDerivedOwner</type>
        </recipients>
        <recipients>
            <field>Contact_for_Notification__c</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>notifications@silver-peak.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>POC/RenewedVirtualAssetFulfillment</template>
    </alerts>
    <alerts>
        <fullName>Notify_License_Contact_of_New_Key</fullName>
        <ccEmails>notifications@silver-peak.com</ccEmails>
        <description>Notify License Contact of New Key</description>
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
            <field>Contact_for_Notification__c</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>notifications@silver-peak.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Support/NewGMSLicemseFulfillment</template>
    </alerts>
    <fieldUpdates>
        <fullName>SetLicNameToRecId</fullName>
        <field>Name</field>
        <formula>Id</formula>
        <name>SetLicNameToRecId</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>RenewalKeyGenerated</fullName>
        <active>false</active>
        <criteriaItems>
            <field>License__c.RenewalKeyGenerated__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>upon renewal license key, send notice for new key</description>
        <triggerType>onCreateOnly</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Notify_Customer_that_license_key_has_been_renewed</name>
                <type>Alert</type>
            </actions>
            <timeLength>1</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>SetLicName</fullName>
        <actions>
            <name>Notify_License_Contact_of_New_Key</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>SetLicNameToRecId</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <formula>and( Name = &apos;123&apos;,  NOT(AssetId__r.Hosted_GMS__c ))</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
