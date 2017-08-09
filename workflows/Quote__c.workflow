<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>DiscountRejected</fullName>
        <description>Discount Rejected</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Sales/DiscountRejected</template>
    </alerts>
    <alerts>
        <fullName>Quote_Approved</fullName>
        <description>Quote Approved</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Sales/DiscountApproved</template>
    </alerts>
    <fieldUpdates>
        <fullName>Change_Quote_Status_To_Pending</fullName>
        <field>Approval_Status__c</field>
        <literalValue>Pending Approval</literalValue>
        <name>Change Quote Status To Pending</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>CheckECApprovalFlag</fullName>
        <field>EC_Approval__c</field>
        <literalValue>1</literalValue>
        <name>CheckECApprovalFlag</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>CondPODefaultTerms</fullName>
        <description>Default Payment Terms language</description>
        <field>PaymentTermInstructions__c</field>
        <formula>&quot;Silver Peak Systems, Inc. provides &quot; +  Opportunity__r.Primary_Partner__r.Name   + &quot; an unconditional right of return until &quot; +  TEXT(Quote_Valid_Until__c) + &quot;.  If  &quot; +  Opportunity__r.Primary_Partner__r.Name  + &quot; has not requested to return the equipment by &quot; + TEXT(Quote_Valid_Until__c) + &quot;, it is deemed that the equipment is accepted by &quot; +  Opportunity__r.Primary_Partner__r.Name   + &quot;.  Payment is due at the later of, 30 days from date of shipment or upon satisfaction of the right of return. If units are purchased, &quot; +  Opportunity__r.Primary_Partner__r.Name   + &quot; will reimburse Silver Peak for any freight, duty and taxes paid to deliver the units to the end customer location.&quot;</formula>
        <name>CondPODefaultTerms</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>FlagAsApproved</fullName>
        <description>Flag this when the approval is made and then unflag only if the percentage is changed</description>
        <field>Approval_Made__c</field>
        <literalValue>1</literalValue>
        <name>FlagAsApproved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>QuoteApproved</fullName>
        <field>Approval_Status__c</field>
        <literalValue>Approved</literalValue>
        <name>QuoteApproved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>QuoteNeedsApproval</fullName>
        <field>Approval_Status__c</field>
        <literalValue>Submitted</literalValue>
        <name>QuoteNeedsApproval</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>QuoteRejected</fullName>
        <field>Approval_Status__c</field>
        <literalValue>Rejected</literalValue>
        <name>QuoteRejected</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ResellerDemoTerms</fullName>
        <description>Update the Payment Instructions when the reseller demo payment terms are selected</description>
        <field>PaymentTermInstructions__c</field>
        <formula>&quot;1.	These units are may not be resold.   &quot; + BR() +
&quot;2.	Software maintenance and support for these units is covered by Silver Peak’s no cost Reseller Maintenance offering. One year of Reseller Maintenance is included with purchase, the contract may be renewed annually at Silver Peak’s discretion.   &quot;  + BR()  +
&quot;3.	Purchaser agrees to notify Silver Peak every time units are installed at a customer site.&quot;</formula>
        <name>ResellerDemoTerms</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>SetQuoteRejected</fullName>
        <description>If the approval threshold is &quot;1&quot; then set the status to rejected and require approval</description>
        <field>Approval_Status__c</field>
        <literalValue>Rejected</literalValue>
        <name>SetQuoteRejected</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Step1Approval</fullName>
        <field>Approval_Status__c</field>
        <literalValue>Approved</literalValue>
        <name>Step1Approval</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UnCheckPrimary</fullName>
        <description>Mark the quote not primary if the dollar amounts don&apos;t add up</description>
        <field>Primary__c</field>
        <literalValue>0</literalValue>
        <name>UnCheckPrimary</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UnFlagApproval</fullName>
        <field>Approval_Made__c</field>
        <literalValue>0</literalValue>
        <name>UnFlagApproval</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UncheckECApprovalFlag</fullName>
        <field>EC_Approval__c</field>
        <literalValue>0</literalValue>
        <name>UncheckECApprovalFlag</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>ApprovalNotRequired</fullName>
        <actions>
            <name>QuoteApproved</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Quote__c.Approval_Required__c</field>
            <operation>equals</operation>
            <value>0</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>ApprovalRequired</fullName>
        <actions>
            <name>SetQuoteRejected</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>UnFlagApproval</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Quote__c.Approval_Required__c</field>
            <operation>equals</operation>
            <value>1</value>
        </criteriaItems>
        <criteriaItems>
            <field>Quote__c.Approval_Made__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>CondPOTerms</fullName>
        <actions>
            <name>CondPODefaultTerms</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Quote__c.PaymentTerm__c</field>
            <operation>equals</operation>
            <value>Cond PO</value>
        </criteriaItems>
        <description>Default language when CondPO is selected as the payment terms</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>PriceChangeAfterApproval</fullName>
        <actions>
            <name>QuoteRejected</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>UnFlagApproval</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>and(
OR(ISCHANGED( Discount_Max__c ),   ISCHANGED( Service_Discount_Max__c ), ISCHANGED( Quote_Discount__c )  ,  ISCHANGED( ConsultingDiscountMax__c )  ,

ISCHANGED(  Value_At_List__c  )  , ISCHANGED(   Quote_Amount_Rollup__c   )  


), Approval_Made__c =True)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>ResleerDemoTerms</fullName>
        <actions>
            <name>ResellerDemoTerms</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Quote__c.PaymentTerm__c</field>
            <operation>equals</operation>
            <value>Reseller Demo</value>
        </criteriaItems>
        <description>Default language when CondPO is selected as the payment terms</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>UnCheckPrimary</fullName>
        <actions>
            <name>UnCheckPrimary</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Quote__c.Matches_Opportunity__c</field>
            <operation>equals</operation>
            <value>1</value>
        </criteriaItems>
        <description>Remove Primary Flag check if the dollar amounts don&apos;t match</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>UncheckECApprovalFlag</fullName>
        <actions>
            <name>UncheckECApprovalFlag</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Quote__c.Approval_Required__c</field>
            <operation>equals</operation>
            <value>1</value>
        </criteriaItems>
        <criteriaItems>
            <field>Quote__c.Approval_Made__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Quote__c.EC_Approval__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Update Opp Owner Manager</fullName>
        <active>false</active>
        <formula>Opportunity__r.OwnerId !=null</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
