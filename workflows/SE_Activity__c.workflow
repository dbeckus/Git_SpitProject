<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>SETypeUpdate</fullName>
        <description>Update the last update flag on an SE Activity if the type is not Status Update set ot false</description>
        <field>Latest_Update__c</field>
        <literalValue>0</literalValue>
        <name>SE Type Update</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Uncheck Flag</fullName>
        <actions>
            <name>SETypeUpdate</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>SE_Activity__c.Type__c</field>
            <operation>notEqual</operation>
            <value>Health Update</value>
        </criteriaItems>
        <description>Uncheck Last Update Flag</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
