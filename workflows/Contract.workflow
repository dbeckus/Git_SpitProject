<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>ContractExpiration</fullName>
        <description>Contract Expiration</description>
        <protected>false</protected>
        <recipients>
            <recipient>lquilici@silver-peak.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Support/ContractExpiration</template>
    </alerts>
    <alerts>
        <fullName>ContractExtended</fullName>
        <ccEmails>notifications@silver-peak.com,renewalsTeam@silver-peak.com</ccEmails>
        <description>Notify Account Manger and Customer when Contract is extended</description>
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
            <field>CustomerSignedId</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <field>Customer_Addl_Notices_2__c</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <field>Customer_Addl_Notices__c</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <field>Reseller_Addl_Notices__c</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>notifications@silver-peak.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>POC/ContractRenewed</template>
    </alerts>
    <fieldUpdates>
        <fullName>contract_expiry</fullName>
        <field>Status</field>
        <literalValue>Expired</literalValue>
        <name>contract_expiry</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Automated New or Renewed Contract notifications</fullName>
        <actions>
            <name>ContractExtended</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <formula>OR(
ISCHANGED( EndDate ) &amp;&amp;  ISPICKVAL( Status , &quot;Activated&quot;),
ISPICKVAL( Status , &quot;Activated&quot;) &amp;&amp; ISPICKVAL( Priorvalue(Status) , &quot;Draft&quot;),
ISPICKVAL( Status , &quot;Activated&quot;) &amp;&amp; ISPICKVAL( Priorvalue(Status) , &quot;Expired&quot;)
)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
