<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Notify_SVP_when_VP_changes_forecast</fullName>
        <description>Notify SVP when VP&apos;s change their forecast</description>
        <protected>false</protected>
        <recipients>
            <recipient>SVPSales</recipient>
            <type>role</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Sales/ForecastChange</template>
    </alerts>
    <rules>
        <fullName>Forecast Changes</fullName>
        <actions>
            <name>Notify_SVP_when_VP_changes_forecast</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <description>Trigger on any forecast change by someone who reports to Arturo</description>
        <formula>AND(OR( 
 ISCHANGED( Amount__c ) ,
 ISCHANGED( MRAmount__c )),
 $User.ManagerId =&apos;00550000001DAMk&apos;)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
