<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Add_underscore_to_nickname</fullName>
        <field>CommunityNickname</field>
        <formula>&quot;_&quot;&amp;CommunityNickname</formula>
        <name>Add underscore to nickname</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Username_Update_for_Portal_when_Inactive</fullName>
        <description>Adds &quot;_&quot; to start of username when a customer portal user becomes inactive.</description>
        <field>Username</field>
        <formula>&quot;_&quot; &amp; Username</formula>
        <name>Username Update for Portal when Inactive</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Underscore Added to Username when Customer Portal User Becomes Inactive</fullName>
        <actions>
            <name>Add_underscore_to_nickname</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Username_Update_for_Portal_when_Inactive</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>User.UserType</field>
            <operation>equals</operation>
            <value>Customer Portal Manager,Customer Portal User,High Volume Portal</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.IsActive</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
