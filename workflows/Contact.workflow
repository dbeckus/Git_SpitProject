<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Contact_Send_Partner_Contact_Welcome_Template</fullName>
        <description>Contact: Send Partner Contact Welcome Template</description>
        <protected>false</protected>
        <recipients>
            <field>Email</field>
            <type>email</type>
        </recipients>
        <senderAddress>silverpeakinfo@silver-peak.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Partner_Account_Templates/Partner_Contact_Welcome</template>
    </alerts>
    <alerts>
        <fullName>Email_Self_Registration_has_been_Enabled</fullName>
        <description>Email - Self Registration has been Enabled</description>
        <protected>false</protected>
        <recipients>
            <field>Email</field>
            <type>email</type>
        </recipients>
        <senderAddress>notifications@silver-peak.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Support/SelfServiceNewUserLoginRegisteration</template>
    </alerts>
    <alerts>
        <fullName>Partner_Role_Updated_On_Contact</fullName>
        <description>Partner Role Updated On Contact</description>
        <protected>false</protected>
        <recipients>
            <recipient>dbeckus@silver-peak.com</recipient>
            <type>user</type>
        </recipients>
        <senderAddress>silverpeakinfo@silver-peak.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/Partner_Role_Updated_On_Contact</template>
    </alerts>
    <fieldUpdates>
        <fullName>Contact_ISR_Notes</fullName>
        <field>ISR_Notes__c</field>
        <formula>&quot;------&quot; &amp; LEFT( $User.FirstName,1) &amp; &quot; &quot; &amp; $User.LastName &amp; &quot;: &quot; &amp; TEXT(Today()) &amp; &quot;------&quot; &amp; BR() &amp;
ISR_Notes__c</formula>
        <name>Contact ISR Notes</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Contact_Sales_Rejected_Date_Time_Stamp</fullName>
        <field>Sales_Rejected_Comments__c</field>
        <formula>&quot;------&quot; &amp; LEFT( $User.FirstName,1) &amp; &quot; &quot; &amp; $User.LastName &amp; &quot;: &quot; &amp; TEXT(Today()) &amp; &quot;------&quot; &amp; BR() &amp; 
Sales_Rejected_Comments__c</formula>
        <name>Contact Sales Rejected Date Time Stamp</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Contact_Owner_GEO</fullName>
        <field>GEO__c</field>
        <formula>IF(ISBLANK(Owner.GEO_Region__c ),&apos;&apos;,Owner.GEO_Region__c)</formula>
        <name>Update Contact Owner GEO</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Email_OptOut_Contact</fullName>
        <field>HasOptedOutOfEmail</field>
        <literalValue>1</literalValue>
        <name>Update Email OptOut-Contact</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_lead_source_to_deal_reg</fullName>
        <field>LeadSource</field>
        <literalValue>Deal Registration</literalValue>
        <name>Update lead source to deal reg</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Add Date Time Stamp On Screening Notes</fullName>
        <actions>
            <name>Contact_ISR_Notes</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>AND(  ISChanged(ISR_Notes__c ),  LEN(ISR_Notes__c)&gt;0   )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Contact Add Date Time Stamp On Sales Rejected Comments</fullName>
        <actions>
            <name>Contact_Sales_Rejected_Date_Time_Stamp</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>AND(  ISChanged( Sales_Rejected_Comments__c ),  LEN(Sales_Rejected_Comments__c )&gt;0   )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Contact%3A Allow Partner Portal Self Registration %3D True</fullName>
        <actions>
            <name>Contact_Send_Partner_Contact_Welcome_Template</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Contact.CanAllowPartnerPortalSelfReg__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Account.IsPartner</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Contact%3A Contact Role Task Reminders</fullName>
        <actions>
            <name>Reminder_Set_Contact_Role_on_Opportunity</name>
            <type>Task</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Contact.Lead_Status__c</field>
            <operation>equals</operation>
            <value>Converted into Existing Opportunity</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Email Opt Out to True for GDPR Countries-Contact</fullName>
        <actions>
            <name>Update_Email_OptOut_Contact</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Contact.Is_GDPR_Country__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Contact.CreatedById</field>
            <operation>notEqual</operation>
            <value>Demand Generation</value>
        </criteriaItems>
        <criteriaItems>
            <field>Contact.Converted_from_Lead__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <description>Set Email Opt Out to true for GDPR Countries based on Patch</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Partner Role is Populated</fullName>
        <actions>
            <name>Partner_Role_Updated_On_Contact</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Contact.Partner_Role__c</field>
            <operation>notEqual</operation>
            <value>,User</value>
        </criteriaItems>
        <description>Alert to Admin that a User has been assigned a Manager or Executive Role</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Restrict updating deal reg lead source</fullName>
        <actions>
            <name>Update_lead_source_to_deal_reg</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>If the lead source is Deal Reg and Cloudingo tries to update it with different value, update it back to Deal Reg</description>
        <formula>AND(ISCHANGED(LeadSource),
    TEXT(PRIORVALUE(LeadSource)) = &apos;Deal Registration&apos;,
    $User.Id= &apos;005380000057EOB&apos;)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Update Contact GEO</fullName>
        <actions>
            <name>Update_Contact_Owner_GEO</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>ISCHANGED(OwnerId )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>UponSetForSelfRegister</fullName>
        <actions>
            <name>Email_Self_Registration_has_been_Enabled</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>When a contact is enabled for self registration, this rule sends them an introduction email</description>
        <formula>CanAllowPortalSelfReg =True</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>UponTransferToPipeline</fullName>
        <active>false</active>
        <formula>OwnerId =&apos;00550000001DH8p&apos;</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <tasks>
        <fullName>Reminder_Set_Contact_Role_on_Opportunity</fullName>
        <assignedToType>creator</assignedToType>
        <description>Please remember to add this contact as a contact role on the existing opportunity.</description>
        <dueDateOffset>1</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>Not Started</status>
        <subject>Reminder: Set Contact Role on Opportunity</subject>
    </tasks>
</Workflow>
