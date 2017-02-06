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
        <fullName>Contract_Set_EC_Total_Contract_Value</fullName>
        <field>SD_WAN_Optimization_Value__c</field>
        <formula>SBQQ__Quote__r.License_Value__c</formula>
        <name>Contract: Set EC Total Contract Value</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Contract_Set_Master_Contract_True</fullName>
        <field>SBQQ__MasterContract__c</field>
        <literalValue>1</literalValue>
        <name>Contract: Set Master Contract = True</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Contract_Set_Status_to_Activated</fullName>
        <field>Status</field>
        <literalValue>Activated</literalValue>
        <name>Contract: Set Status to Activated</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
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
    <rules>
        <fullName>Contract%3A Created from EdgeConnect Quote</fullName>
        <actions>
            <name>Contract_Set_Status_to_Activated</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Set&apos;s actions to occur when contracts are created from an opportunity that is quoting edgeconnect products.</description>
        <formula>AND(  ISPICKVAL(SBQQ__Quote__r.Product_Type__c, &quot;EDGECONNECT&quot;),  NOT(SBQQ__MasterContract__c)  )</formula>
        <triggerType>onCreateOnly</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Contract_Set_Master_Contract_True</name>
                <type>FieldUpdate</type>
            </actions>
            <timeLength>0</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Contract%3A Edited</fullName>
        <actions>
            <name>Contract_Set_EC_Total_Contract_Value</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Contract.CreatedDate</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>Set&apos;s actions to occur when contracts are edited.</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
