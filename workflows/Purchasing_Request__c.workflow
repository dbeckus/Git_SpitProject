<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>MDF_Request_has_Been_Denied_Internal</fullName>
        <description>MDF Request has Been Denied Internal</description>
        <protected>false</protected>
        <recipients>
            <field>Email__c</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>MDF/New_MDF_Request_has_Been_Denied_in_PR_Process_Internal</template>
    </alerts>
    <alerts>
        <fullName>New_PR_Submitted</fullName>
        <description>New PR Submitted</description>
        <protected>false</protected>
        <recipients>
            <recipient>curtisc@silver-peak.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Training/PRApprovalNeeded</template>
    </alerts>
    <alerts>
        <fullName>Notifier_Requester_of_PR_rejection</fullName>
        <description>Notifier Requester of PR rejection</description>
        <protected>false</protected>
        <recipients>
            <field>Email__c</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Training/PRApprovalRejected</template>
    </alerts>
    <alerts>
        <fullName>Notify_Purchasing_of_new_approved_PR</fullName>
        <description>Notify Purchasing of new approved PR</description>
        <protected>false</protected>
        <recipients>
            <field>Email__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <recipient>arule@silver-peak.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>lquilici@silver-peak.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Training/PRApprovedforOrdering</template>
    </alerts>
    <alerts>
        <fullName>Notify_Submitter_of_new_PR</fullName>
        <description>Notify Submitter of new PR created succesfully</description>
        <protected>false</protected>
        <recipients>
            <field>Email__c</field>
            <type>email</type>
        </recipients>
        <senderType>DefaultWorkflowUser</senderType>
        <template>Training/PRReguestSubmittedApprovalNeeded</template>
    </alerts>
    <fieldUpdates>
        <fullName>Approval_Status_to_Draft</fullName>
        <field>Approval_Status__c</field>
        <literalValue>Draft</literalValue>
        <name>Approval Status to Draft</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>SetBudgetApproval</fullName>
        <field>Approval_Status__c</field>
        <literalValue>Budget Approval</literalValue>
        <name>SetBudgetApproval</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>SetFinalApproval</fullName>
        <field>Approval_Status__c</field>
        <literalValue>Final Approval</literalValue>
        <name>SetFinalApproval</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>SetRejectStatus</fullName>
        <field>Approval_Status__c</field>
        <literalValue>Rejected</literalValue>
        <name>SetRejectStatus</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Amount_Increase_to_False</fullName>
        <field>Amount_Increase__c</field>
        <literalValue>0</literalValue>
        <name>Update Amount Increase to False</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>AmountIncreased</fullName>
        <actions>
            <name>SetRejectStatus</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Did the Total Amount go up</description>
        <formula>AND( ISCHANGED( Total_Amount__c ) ,  Amount_Increase__c  = FALSE, PRIORVALUE(Total_Amount__c) &lt; Total_Amount__c,  PRIORVALUE(Total_Amount__c) &gt; 0 )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Increase Amount of PR without Auto-Rejecting PR</fullName>
        <actions>
            <name>Approval_Status_to_Draft</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Purchasing_Request__c.Amount_Increase__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>The will be used so that the Marketing team can increase the PR amount or an already approved PR if they need to and re-submit the PR for approval.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>NewPREnteredonWebform</fullName>
        <actions>
            <name>New_PR_Submitted</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Purchasing_Request__c.CreatedById</field>
            <operation>contains</operation>
            <value>Guest</value>
        </criteriaItems>
        <criteriaItems>
            <field>Purchasing_Request__c.Temporary__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <description>Notify and trigger when a new PR comes in via the webform.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
