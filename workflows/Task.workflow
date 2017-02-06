<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Send_Feedback_email_to_RSM</fullName>
        <description>Send Feedback email to RSM</description>
        <protected>false</protected>
        <recipients>
            <type>creator</type>
        </recipients>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>noreply@silver-peak.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/RSM_Meeting_Request_Feedback</template>
    </alerts>
    <alerts>
        <fullName>Send_an_email_to_BDR</fullName>
        <description>Send an email to BDR</description>
        <protected>false</protected>
        <recipients>
            <type>creator</type>
        </recipients>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <recipient>mmartin@silver-peak.com</recipient>
            <type>user</type>
        </recipients>
        <senderAddress>noreply@silver-peak.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/Send_an_email_to_BDR_for_reschedule</template>
    </alerts>
    <fieldUpdates>
        <fullName>DB4SF__Update_Task_Status_on_Expiry</fullName>
        <description>update task status to be set to Expired</description>
        <field>Status</field>
        <literalValue>Expired</literalValue>
        <name>Update Task Status on Expiry</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>NewBDROverdueDate</fullName>
        <field>IsTaskFeedbackSent__c</field>
        <literalValue>1</literalValue>
        <name>NewBDROverdueDate</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>NewBDRDueDateOverdue</fullName>
        <active>true</active>
        <criteriaItems>
            <field>Task.Subject</field>
            <operation>equals</operation>
            <value>New BDR Meeting</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>NewBDROverdueDate</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>Task.ActivityDate</offsetFromField>
            <timeLength>1</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>RSM No Show update</fullName>
        <actions>
            <name>Send_an_email_to_BDR</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <formula>AND( 
OR(LastModifiedBy.Profile.Name == &quot;1.1- Regional Sales Manager&quot;, LastModifiedBy.Profile.Name == &quot;1.4- Intl Regional Sales Manager&quot; )
,CONTAINS(Subject,&quot;New BDR Meeting&quot;), 
ISPICKVAL( Meeting_Rating__c,&quot;No Show/Cancelled&quot;) )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Send New BDR Feedback</fullName>
        <actions>
            <name>Send_Feedback_email_to_RSM</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Task.Subject</field>
            <operation>equals</operation>
            <value>New BDR Meeting</value>
        </criteriaItems>
        <criteriaItems>
            <field>Task.IsNewBDRTaskComplete__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Task.IsTaskFeedbackSent__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
