<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Closed_Won_Less_Than_100_K_Email_Template</fullName>
        <ccEmails>SFDCAllHands@silver-peak.com</ccEmails>
        <description>Closed Won Less Than 100 K Email Template</description>
        <protected>false</protected>
        <recipients>
            <recipient>ddalponte@silver-peak.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>ewhite@silver-peak.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>rbooth@silver-peak.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Sales/LatestLess_Than_100_k_Opportunity</template>
    </alerts>
    <alerts>
        <fullName>Closed_Won_New_and_FO</fullName>
        <ccEmails>SFDCAllHands@silver-peak.com</ccEmails>
        <description>Closed Won New and FO</description>
        <protected>false</protected>
        <recipients>
            <recipient>ddalponte@silver-peak.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>ewhite@silver-peak.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>rbooth@silver-peak.com</recipient>
            <type>user</type>
        </recipients>
        <senderAddress>silverpeakinfo@silver-peak.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Sales/LatestGreater_Than_100_k_Opportunity</template>
    </alerts>
    <alerts>
        <fullName>Commit_Changed</fullName>
        <description>Commit Changed</description>
        <protected>false</protected>
        <recipients>
            <recipient>bbruce@silver-peak.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>chelfer@silver-peak.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>dfarndale@silver-peak.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>enugent@silver-peak.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>fpinto@silver-peak.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>mhemeemea@silver-peak.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>pgilbreath@silver-peak.com</recipient>
            <type>user</type>
        </recipients>
        <senderAddress>notifications@silver-peak.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Sales/Commit_Changed</template>
    </alerts>
    <alerts>
        <fullName>Deal_Reg_Converted</fullName>
        <description>Deal Reg Converted</description>
        <protected>false</protected>
        <recipients>
            <recipient>Channel Manager</recipient>
            <type>accountTeam</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>DealRegistrations/Deal_Registration_Converted</template>
    </alerts>
    <alerts>
        <fullName>Deal_Reg_Converted_Partner</fullName>
        <description>Deal Reg Converted - Partner</description>
        <protected>false</protected>
        <recipients>
            <field>Registering_Partner_Sales_Rep__c</field>
            <type>contactLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>DealRegistrations/Deal_Registration_Converted_Partner</template>
    </alerts>
    <alerts>
        <fullName>EmailFinanceOnRSMSignature</fullName>
        <description>Email finance that RevRec is signed off by RSM</description>
        <protected>false</protected>
        <recipients>
            <recipient>elee@silver-peak.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>kreichert@silver-peak.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>rmarqueling@silver-peak.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>trnguyen@silver-peak.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>tton@silver-peak.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Sales/RevRecSignedByRSM</template>
    </alerts>
    <alerts>
        <fullName>EvalStageChange</fullName>
        <ccEmails>evalrequest@silver-peak.com</ccEmails>
        <description>Eval Stage Change</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <recipient>VPSalesEastern</recipient>
            <type>role</type>
        </recipients>
        <recipients>
            <recipient>VPSalesWestern</recipient>
            <type>role</type>
        </recipients>
        <recipients>
            <recipient>dennis@silver-peak.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>eyeaman@silver-peak.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>jaaron@silver-peak.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>kreichert@silver-peak.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>rmarqueling@silver-peak.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>rtinsley@silver-peak.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <field>Technical_Responsible__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Sales/EvalStageChange</template>
    </alerts>
    <alerts>
        <fullName>NewOpptyopened</fullName>
        <description>New Oppty opened</description>
        <protected>false</protected>
        <recipients>
            <recipient>Account Manager</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>Channel Manager</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>Inside Sale Representative</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>Systems Engineer</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <type>creator</type>
        </recipients>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <recipient>Grade_1_Inside_Sales</recipient>
            <type>role</type>
        </recipients>
        <recipients>
            <recipient>Grade_1_Sales_COMM</recipient>
            <type>role</type>
        </recipients>
        <recipients>
            <recipient>Grade_2_BDR</recipient>
            <type>role</type>
        </recipients>
        <recipients>
            <recipient>Grade_3_Sales_NAM_Central</recipient>
            <type>role</type>
        </recipients>
        <recipients>
            <recipient>Grade_3_Sales_NAM_East</recipient>
            <type>role</type>
        </recipients>
        <recipients>
            <recipient>Grade_3_Sales_NAM_South</recipient>
            <type>role</type>
        </recipients>
        <recipients>
            <recipient>Grade_3_Sales_NAM_West</recipient>
            <type>role</type>
        </recipients>
        <recipients>
            <recipient>InsideSalesMgr</recipient>
            <type>roleSubordinatesInternal</type>
        </recipients>
        <recipients>
            <recipient>afuoss@silver-peak.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>ewhite@silver-peak.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Sales/new_oppty_alert</template>
    </alerts>
    <alerts>
        <fullName>NewOpptyopened_APAC</fullName>
        <description>New Oppty opened-APAC</description>
        <protected>false</protected>
        <recipients>
            <recipient>Account Manager</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>Channel Manager</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>Inside Sale Representative</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>Systems Engineer</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <type>creator</type>
        </recipients>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <recipient>AsiaSouthDirector</recipient>
            <type>role</type>
        </recipients>
        <recipients>
            <recipient>Grade_3_Sales_APAC_ASEAN</recipient>
            <type>role</type>
        </recipients>
        <recipients>
            <recipient>ewhite@silver-peak.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Sales/new_oppty_alert</template>
    </alerts>
    <alerts>
        <fullName>NewOpptyopened_EMEA</fullName>
        <description>New Oppty opened-EMEA</description>
        <protected>false</protected>
        <recipients>
            <recipient>Account Manager</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>Channel Manager</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>Inside Sale Representative</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>Systems Engineer</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <type>creator</type>
        </recipients>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <recipient>Grade_2_Sales_EMEA</recipient>
            <type>role</type>
        </recipients>
        <recipients>
            <recipient>VPSalesEMEA</recipient>
            <type>role</type>
        </recipients>
        <recipients>
            <recipient>ewhite@silver-peak.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Sales/new_oppty_alert</template>
    </alerts>
    <alerts>
        <fullName>NewOpptyopened_LAT</fullName>
        <description>New Oppty opened-LAT</description>
        <protected>false</protected>
        <recipients>
            <recipient>Account Manager</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>Channel Manager</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>Inside Sale Representative</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>Systems Engineer</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <type>creator</type>
        </recipients>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <recipient>VPSalesLAT</recipient>
            <type>role</type>
        </recipients>
        <recipients>
            <recipient>Grade_2_Sales_LATAM</recipient>
            <type>roleSubordinatesInternal</type>
        </recipients>
        <recipients>
            <recipient>ewhite@silver-peak.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Sales/new_oppty_alert</template>
    </alerts>
    <alerts>
        <fullName>New_Opp_Opened_from_Marketplace_inquiry</fullName>
        <description>New Opp Opened from Marketplace inquiry</description>
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
            <type>owner</type>
        </recipients>
        <recipients>
            <field>Technical_Responsible__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Sales/new_oppty_alert_marketplace</template>
    </alerts>
    <alerts>
        <fullName>NotifyOppOwnerReleasedToClose</fullName>
        <description>Notify Oppty Owner when finance releases the rev rec review</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Sales/RevRecReleasedByFinance</template>
    </alerts>
    <alerts>
        <fullName>NotifyVPMarketingtoauthorizeISRcreditonOpportunity</fullName>
        <ccEmails>dbeckus@silver-peak.com</ccEmails>
        <description>Notify VP Marketing to authorize ISR credit on Opportunity</description>
        <protected>false</protected>
        <senderType>CurrentUser</senderType>
        <template>Sales/ISR_new_oppty_alert</template>
    </alerts>
    <alerts>
        <fullName>OpportunityAdvancedfromProspecting</fullName>
        <ccEmails>dbeckus@silver-peak.com</ccEmails>
        <description>Opportunity Advanced from Prospecting</description>
        <protected>false</protected>
        <senderType>CurrentUser</senderType>
        <template>Sales/OptyProspected</template>
    </alerts>
    <alerts>
        <fullName>OpportunityStageChangeEvalORClosedNotWon</fullName>
        <description>Opportunity Stage Change Closed-Not Won</description>
        <protected>false</protected>
        <recipients>
            <recipient>Account Manager</recipient>
            <type>opportunityTeam</type>
        </recipients>
        <recipients>
            <recipient>Channel Manager</recipient>
            <type>opportunityTeam</type>
        </recipients>
        <recipients>
            <recipient>Systems Engineer</recipient>
            <type>opportunityTeam</type>
        </recipients>
        <recipients>
            <recipient>Team Owner</recipient>
            <type>opportunityTeam</type>
        </recipients>
        <recipients>
            <recipient>CEO</recipient>
            <type>role</type>
        </recipients>
        <recipients>
            <recipient>Grade_1_Inside_Sales</recipient>
            <type>role</type>
        </recipients>
        <recipients>
            <recipient>Grade_1_Sales</recipient>
            <type>role</type>
        </recipients>
        <recipients>
            <recipient>Grade_1_Sales_COMM</recipient>
            <type>role</type>
        </recipients>
        <recipients>
            <recipient>Grade_1_Sys_Eng</recipient>
            <type>role</type>
        </recipients>
        <recipients>
            <recipient>Grade_2_BDR</recipient>
            <type>role</type>
        </recipients>
        <recipients>
            <recipient>Grade_2_Sales_NAM</recipient>
            <type>role</type>
        </recipients>
        <recipients>
            <recipient>dennis@silver-peak.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>dgranath@silver-peak.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>ewhite@silver-peak.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>eyeaman@silver-peak.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>jvincenzo@silver-peak.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>rbooth@silver-peak.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>rmarqueling@silver-peak.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Support/oppty_closed_stage</template>
    </alerts>
    <alerts>
        <fullName>OpportunityStageChangeEvalORClosedNotWonOver100K</fullName>
        <ccEmails>opptylost@silver-peak.com</ccEmails>
        <description>Opportunity Stage Change Closed-Not WonOver100k</description>
        <protected>false</protected>
        <senderType>CurrentUser</senderType>
        <template>Support/oppty_closed_stage</template>
    </alerts>
    <alerts>
        <fullName>Opportunity_Registration_Approved</fullName>
        <description>Opportunity Registration Approved</description>
        <protected>false</protected>
        <recipients>
            <type>accountOwner</type>
        </recipients>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>DealRegistrations/DealRegistrationApproved</template>
    </alerts>
    <alerts>
        <fullName>Opportunityhasbeenclosedandwon</fullName>
        <ccEmails>opptywon@silver-peak.com</ccEmails>
        <ccEmails>semanagers@silver-peak.com</ccEmails>
        <description>Opportunity has been closed and won</description>
        <protected>false</protected>
        <recipients>
            <recipient>Account Manager</recipient>
            <type>opportunityTeam</type>
        </recipients>
        <recipients>
            <recipient>Channel Manager</recipient>
            <type>opportunityTeam</type>
        </recipients>
        <recipients>
            <recipient>Inside Sale Representative</recipient>
            <type>opportunityTeam</type>
        </recipients>
        <recipients>
            <recipient>Systems Engineer</recipient>
            <type>opportunityTeam</type>
        </recipients>
        <recipients>
            <recipient>Team Owner</recipient>
            <type>opportunityTeam</type>
        </recipients>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <recipient>CEO</recipient>
            <type>role</type>
        </recipients>
        <recipients>
            <recipient>CFO</recipient>
            <type>role</type>
        </recipients>
        <recipients>
            <recipient>DirectorofCustomerService</recipient>
            <type>role</type>
        </recipients>
        <recipients>
            <recipient>Grade_1_Inside_Sales</recipient>
            <type>role</type>
        </recipients>
        <recipients>
            <recipient>Grade_2_Sales_NAM</recipient>
            <type>role</type>
        </recipients>
        <recipients>
            <recipient>SVPSales</recipient>
            <type>role</type>
        </recipients>
        <recipients>
            <recipient>VPProductManagement</recipient>
            <type>role</type>
        </recipients>
        <recipients>
            <recipient>jvincenzo@silver-peak.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>rrammaha@silver-peak.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Support/OptyClosedWon</template>
    </alerts>
    <alerts>
        <fullName>Sales_Win_Send_to_Opp_Owner</fullName>
        <description>Sales Win Send to Opp Owner</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <recipient>ewhite@silver-peak.com</recipient>
            <type>user</type>
        </recipients>
        <senderAddress>salesops@silver-peak.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/Sales_Win_Email</template>
    </alerts>
    <alerts>
        <fullName>Send_Loss_Email_to_Opp_Owner</fullName>
        <description>Send Loss Email to Opp Owner</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>salesops@silver-peak.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Sales/Sales_Loss_Email</template>
    </alerts>
    <alerts>
        <fullName>Send_email_to_Praj</fullName>
        <description>Send email to Praj</description>
        <protected>false</protected>
        <recipients>
            <recipient>prane@silver-peak.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Sales/RevRecSignedByRSM</template>
    </alerts>
    <alerts>
        <fullName>Send_email_to_registering_partner_sales_rep</fullName>
        <ccEmails>notifications@silver-peak.com</ccEmails>
        <description>Send email to registering partner sales rep</description>
        <protected>false</protected>
        <recipients>
            <field>Registering_Partner_Sales_Rep__c</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>notifications@silver-peak.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>DealRegistrations/Partner_Added_as_Registered</template>
    </alerts>
    <alerts>
        <fullName>Send_me_a_note_upon_Deal_Reg_conversion</fullName>
        <description>Send me a note upon Deal Reg conversion</description>
        <protected>false</protected>
        <recipients>
            <recipient>dbeckus@silver-peak.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>DealRegistrations/DealRegistrationAcknowledged</template>
    </alerts>
    <alerts>
        <fullName>Send_to_BDR_for_closed_dead</fullName>
        <description>Send to BDR for closed dead</description>
        <protected>false</protected>
        <recipients>
            <recipient>Grade_1_Inside_Sales</recipient>
            <type>role</type>
        </recipients>
        <recipients>
            <recipient>Grade_2_BDR</recipient>
            <type>role</type>
        </recipients>
        <recipients>
            <recipient>ISR_Team</recipient>
            <type>role</type>
        </recipients>
        <recipients>
            <recipient>InsideSalesMgr</recipient>
            <type>role</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/oppty_closed_stage_dead</template>
    </alerts>
    <alerts>
        <fullName>Transactional_Opportunity_Alert</fullName>
        <description>Transactional Opportunity Alert</description>
        <protected>false</protected>
        <recipients>
            <recipient>dfehleisen@silver-peak.com</recipient>
            <type>user</type>
        </recipients>
        <senderAddress>notifications@silver-peak.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/Transactional_Opportunity_Assignment</template>
    </alerts>
    <fieldUpdates>
        <fullName>AFOCounterSetup</fullName>
        <field>AFO_counter__c</field>
        <formula>IF( ISPICKVAL( Type , &quot;New Business&quot;) ,  AFO_counter__c , 0 )</formula>
        <name>AFO Counter Setup</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Add_BDR_Comp_Date</fullName>
        <field>BDR_Comp_Date__c</field>
        <formula>Now()</formula>
        <name>Add BDR Comp Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Blank_out_Opp_Source</fullName>
        <field>Opportunity_Source__c</field>
        <name>Blank out Opp Source</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Check_Partner_Initated_To_True</fullName>
        <field>Deal_Reg__c</field>
        <literalValue>1</literalValue>
        <name>Check Partner Initated To True</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Clear_Bypassing_Validation</fullName>
        <field>Bypassing_Validation__c</field>
        <literalValue>0</literalValue>
        <name>Clear Bypassing Validation</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Close_Date_Updates_to_120_Days</fullName>
        <field>CloseDate</field>
        <formula>Today() + 120</formula>
        <name>Close Date Updates to 120 Days</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Deal_reg_Update_Stage_to_Discovery</fullName>
        <field>StageName</field>
        <literalValue>Discovery</literalValue>
        <name>Deal reg Update Stage to Discovery</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Next_Step_Updated_By</fullName>
        <field>Next_Step_Updated_By__c</field>
        <formula>$User.Alias</formula>
        <name>Next Step Updated By</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Next_Step_Updated_Time_Stamp</fullName>
        <field>Next_Step_Updated__c</field>
        <formula>TODAY()</formula>
        <name>Next Step Updated Time Stamp</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set2NewBiz</fullName>
        <description>Set type filed to new business</description>
        <field>Type</field>
        <literalValue>New Business</literalValue>
        <name>Set2NewBiz</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>SetAFOValue</fullName>
        <field>AFO_Value__c</field>
        <formula>IF(  AND(IsClosed , ISPICKVAL( StageName , &quot;Closed Won&quot;),  ISPICKVAL( Type , &quot;New Business&quot;)  ) ,  Amount , 0)</formula>
        <name>Set AFO Value</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>SetCloseDateOnClosedLost</fullName>
        <field>CloseDate</field>
        <formula>TODAY()</formula>
        <name>SetCloseDateOnClosedLost</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>SetDeadReasonPick</fullName>
        <field>Dead_Description__c</field>
        <formula>&quot;Marketplace POC Expired&quot;</formula>
        <name>SetDeadReasonPick</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>SetFinanceId</fullName>
        <field>Finance_Id__c</field>
        <formula>if( OR(isblank(Finance_Id__c),isnull( Finance_Id__c )) , ID_Code_Calc__c,  Finance_Id__c )</formula>
        <name>SetFinanceId</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>SetOppSourceToDR</fullName>
        <field>Opportunity_Source__c</field>
        <literalValue>Deal Registration</literalValue>
        <name>SetOppSourceToDR</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>SetPOCType2None</fullName>
        <field>POC_Type__c</field>
        <literalValue>None</literalValue>
        <name>SetPOCType2None</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>SetPOCType2Trial</fullName>
        <field>POC_Type__c</field>
        <literalValue>Self Trial</literalValue>
        <name>SetPOCType2Trial</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>SetRecordTypeDefault</fullName>
        <field>RecordTypeId</field>
        <lookupValue>New</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>SetRecordTypeDefault</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>SetRecordTypeSpecificFO</fullName>
        <field>RecordTypeId</field>
        <lookupValue>FollowOn</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>SetRecordTypeSpecificFO</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>SetRecordTypeSpecificMR</fullName>
        <field>RecordTypeId</field>
        <lookupValue>Maintenance</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>SetRecordTypeSpecificMR</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>SetWinLossFlagToOne</fullName>
        <field>WinLossInclude__c</field>
        <formula>1</formula>
        <name>SetWinLossFlagToOne</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Close_Date_By_Estimate</fullName>
        <field>CloseDate</field>
        <formula>Intial_Estimated_Close_Date__c</formula>
        <name>Set Close Date by Estimate</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Sales_Region</fullName>
        <field>Sales_Region__c</field>
        <formula>TEXT(Owner.GEO__c) +&apos;-&apos;+TEXT(Owner.Region__c)</formula>
        <name>Set Sales Region</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Technical_Responsibility_Updates</fullName>
        <description>Updates to Dave Fehleisen</description>
        <field>Technical_Responsible__c</field>
        <lookupValue>dfehleisen@silver-peak.com</lookupValue>
        <lookupValueType>User</lookupValueType>
        <name>Technical Responsibility Updates</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Trigger_Assignment</fullName>
        <field>Trigger_Assignment__c</field>
        <literalValue>1</literalValue>
        <name>Trigger Assignment</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Uncheck_Partner_Initated_Flag</fullName>
        <field>Deal_Reg__c</field>
        <literalValue>0</literalValue>
        <name>Uncheck Partner Initated Flag</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Last_Modified_Date</fullName>
        <field>Owner_Last_Activity_Date__c</field>
        <formula>LastModifiedDate</formula>
        <name>Update Last Modified Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Opp_Stage_as_Discovery_RSM</fullName>
        <field>StageName</field>
        <literalValue>Discovery</literalValue>
        <name>Update Opp Stage as Discovery RSM</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>rvee__NotifyRVMemberReset</fullName>
        <field>rvpe__NotifyRVMember__c</field>
        <literalValue>0</literalValue>
        <name>Notify RV Member Reset</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <outboundMessages>
        <fullName>Deal_Registration_Approved</fullName>
        <apiVersion>23.0</apiVersion>
        <endpointUrl>https://partner.silver-peak.com/services/SFDC-DealRegistrationApproved.ashx</endpointUrl>
        <fields>Id</fields>
        <includeSessionId>false</includeSessionId>
        <integrationUser>dbeckus@silver-peak.com</integrationUser>
        <name>Deal Registration Approved</name>
        <protected>false</protected>
        <useDeadLetterQueue>false</useDeadLetterQueue>
    </outboundMessages>
    <outboundMessages>
        <fullName>Notify_RV_Member</fullName>
        <apiVersion>23.0</apiVersion>
        <endpointUrl>https://partner.silver-peak.com/services/SFDC-OpportunityNotifyRVMember.ashx</endpointUrl>
        <fields>Id</fields>
        <includeSessionId>false</includeSessionId>
        <integrationUser>dbeckus@silver-peak.com</integrationUser>
        <name>Notify RV Member</name>
        <protected>false</protected>
        <useDeadLetterQueue>false</useDeadLetterQueue>
    </outboundMessages>
    <rules>
        <fullName>%27Created from Lead%27 Updates Closed Date during conversion to 120 Days after Create Date</fullName>
        <actions>
            <name>Close_Date_Updates_to_120_Days</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.Created_From_Lead__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.LeadSource</field>
            <operation>notEqual</operation>
            <value>Web- Trial Request</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>AFO Value Setup</fullName>
        <actions>
            <name>AFOCounterSetup</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>SetAFOValue</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.StageName</field>
            <operation>equals</operation>
            <value>Closed Won</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Can%27tOpenMarketPlaceOppsinGUI</fullName>
        <actions>
            <name>Set2NewBiz</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.Type</field>
            <operation>equals</operation>
            <value>Marketplace</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Trigger_POC__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <description>if someone opens or tries to set an opp to marketplace, reset it to New Business</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Capture Date TimeStamp Stage modified After New</fullName>
        <actions>
            <name>Add_BDR_Comp_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>And( NOT(ISNEW()), ISCHANGED(StageName), ISPICKVAL(PRIORVALUE(StageName),&quot;New&quot;) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Check Partner Initated Flag</fullName>
        <actions>
            <name>Check_Partner_Initated_To_True</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>AND(
NOT(ISNULL( AccountId)),
Account.Is_Partner_Initiated_Account__c,
NOT(ISPICKVAL(Type,&quot;Marketplace&quot;)),
New_Business__c 
)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Check Signature issue</fullName>
        <actions>
            <name>Send_email_to_Praj</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <formula>AND( Signature_of_Opportunity_Owner__c,
NOT(ISBLANK(PRIORVALUE(Signed_By__c ))),
ISBLANK(Signed_By__c)
)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Clear Bypassing Validation</fullName>
        <actions>
            <name>Clear_Bypassing_Validation</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.Bypassing_Validation__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Clear out opp source for renewal</fullName>
        <actions>
            <name>Blank_out_Opp_Source</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.Opportunity_Source__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Type</field>
            <operation>equals</operation>
            <value>Support Renewal,Subscription Renewal,EC Renewal</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>CloseMarketplacePOC</fullName>
        <actions>
            <name>SetCloseDateOnClosedLost</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>SetDeadReasonPick</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>SetPOCType2Trial</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>when a marketplace opp is closed, then set a bunch of fields</description>
        <formula>AND (
ISPICKVAL(  Type , &quot;Marketplace&quot;),
ISPICKVAL(  StageName , &quot;Closed Dead&quot;),
ISCHANGED(StageName)
)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Closed Lost oppty</fullName>
        <actions>
            <name>OpportunityStageChangeEvalORClosedNotWon</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.StageName</field>
            <operation>equals</operation>
            <value>Closed Lost</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Type</field>
            <operation>equals</operation>
            <value>Follow on Business,New Business,Support Renewal,Subscription Renewal,EC Renewal</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Loss_Description__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Loss_Reason__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.primary_competitor__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>oppty-closed</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Closed-Dead Oppty</fullName>
        <actions>
            <name>Send_to_BDR_for_closed_dead</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.StageName</field>
            <operation>equals</operation>
            <value>Closed Dead</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Type</field>
            <operation>equals</operation>
            <value>Follow on Business,New Business,Support Renewal,Subscription Renewal,EC Renewal</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Dead_Reason__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>Oppty that are closed, send an email to BDR</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Eval Stage Change</fullName>
        <actions>
            <name>EvalStageChange</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <booleanFilter>1 OR 2</booleanFilter>
        <criteriaItems>
            <field>Opportunity.Eval_Stage__c</field>
            <operation>equals</operation>
            <value>Requested,Completed-Failed,Shipped,Completed-Successful</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Eval_Stage__c</field>
            <operation>equals</operation>
            <value>Cond. PO</value>
        </criteriaItems>
        <description>Alert sent on any change to eval status</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Generic-Opportunity Closed Won</fullName>
        <actions>
            <name>Opportunityhasbeenclosedandwon</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>SetFinanceId</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.StageName</field>
            <operation>equals</operation>
            <value>Closed Won</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Type</field>
            <operation>equals</operation>
            <value>Follow on Business,New Business,Support Renewal,Subscription Renewal,EC Renewal</value>
        </criteriaItems>
        <description>Sends an email when an opportunity is closed/won</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>ISR Credit Approval</fullName>
        <actions>
            <name>NotifyVPMarketingtoauthorizeISRcreditonOpportunity</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Opportunity.ISR_Credit__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>Fires and email to VP Marketing to authorize credit for an opportunity be given to an ISR</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Lessthan100KOpportunity Closed Won%28New%26FO%29</fullName>
        <actions>
            <name>Closed_Won_Less_Than_100_K_Email_Template</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 AND 2 AND 3 AND 4 AND 5 AND 6</booleanFilter>
        <criteriaItems>
            <field>Opportunity.StageName</field>
            <operation>equals</operation>
            <value>Closed Won</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Type</field>
            <operation>equals</operation>
            <value>New Business</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Win_Description__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Amount</field>
            <operation>lessOrEqual</operation>
            <value>100000</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Number_of_branches__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.primary_competitor__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>Sends an email when a new and follow on  opportunity is closed/won</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Morethan100KOpportunity Closed Won%28New%26FO%29</fullName>
        <actions>
            <name>Closed_Won_New_and_FO</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 AND 2 AND 3 AND 4 AND 5 AND 6</booleanFilter>
        <criteriaItems>
            <field>Opportunity.StageName</field>
            <operation>equals</operation>
            <value>Closed Won</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Type</field>
            <operation>equals</operation>
            <value>Follow on Business,New Business,Support Renewal,Subscription Renewal,EC Renewal</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Win_Description__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Amount</field>
            <operation>greaterThan</operation>
            <value>100000</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Number_of_branches__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.primary_competitor__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>Sends an email when a new and follow on  opportunity is closed/won</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>NewMarketplaceOppOpened</fullName>
        <actions>
            <name>New_Opp_Opened_from_Marketplace_inquiry</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Opportunity.Type</field>
            <operation>equals</operation>
            <value>Marketplace</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Next Step Updated Today</fullName>
        <actions>
            <name>Next_Step_Updated_By</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Next_Step_Updated_Time_Stamp</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>ISCHANGED( NextStep )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Notify Registered Partner for non Deal Reg opportunitities</fullName>
        <actions>
            <name>Send_email_to_registering_partner_sales_rep</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <formula>AND( NOT(ISPICKVAL(LeadSource,&quot;Deal Registration&quot;)),  OR( IsPICKVAL(Type,&quot;New Business&quot;), IsPICKVAL(Type,&quot;Follow on Business&quot;) ), NOT(ISBLANK(Registering_Partner__c)), NOT(ISBLANK(Registering_Partner_Sales_Rep__c)),  ISCHANGED(Registering_Partner_Sales_Rep__c) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Opportunity Closed Won</fullName>
        <actions>
            <name>Opportunityhasbeenclosedandwon</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>SetFinanceId</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Opportunity.StageName</field>
            <operation>equals</operation>
            <value>Closed Won</value>
        </criteriaItems>
        <description>Sends an email when an opportunity is closed/won</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Opportunity Closed Won%28New%26FO%29</fullName>
        <actions>
            <name>Closed_Won_New_and_FO</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Opportunity.StageName</field>
            <operation>equals</operation>
            <value>Closed Won</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Type</field>
            <operation>equals</operation>
            <value>Follow on Business,New Business</value>
        </criteriaItems>
        <description>Sends an email when a new and follow on  opportunity is closed/won</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Opportunity Registration Converted</fullName>
        <actions>
            <name>Deal_Reg_Converted</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Deal_Reg_Converted_Partner</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.LeadSource</field>
            <operation>equals</operation>
            <value>Deal Registration</value>
        </criteriaItems>
        <description>When a deal registration converts from a lead, setup some of the data values for the opportunity</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Populate Stage Discovery created by RSM</fullName>
        <actions>
            <name>Update_Opp_Stage_as_Discovery_RSM</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>OR( $Profile.Name =&quot;1.1- Regional Sales Manager&quot;, $Profile.Name =&quot;1.4- Intl Regional Sales Manager&quot;, $Profile.Name =&quot;1.0- Sales Management&quot; )</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Prospecting Oppty Advanced</fullName>
        <actions>
            <name>OpportunityAdvancedfromProspecting</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <formula>AND( ISPICKVAL( PRIORVALUE( StageName ) ,&quot;Prospecting&quot;),  ISCHANGED( StageName ) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>RevRecSignedByFinance</fullName>
        <actions>
            <name>NotifyOppOwnerReleasedToClose</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.Finance_Reviewed__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Finance_Released_At__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>when finance signs the rev rec checklist, email to oppty owner</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>RevRecSignedByRSM</fullName>
        <actions>
            <name>EmailFinanceOnRSMSignature</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.Signature_of_Opportunity_Owner__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Signed_At__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Signed_By__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>when the RSM signs the rev rec checklist, email to Kiellie and Richard</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Send Competition Data For Lost Opp</fullName>
        <actions>
            <name>Send_Loss_Email_to_Opp_Owner</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.StageName</field>
            <operation>equals</operation>
            <value>Closed Lost</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Send Competition Data for Win</fullName>
        <actions>
            <name>Sales_Win_Send_to_Opp_Owner</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 AND ((2 AND 3)  OR (4 AND 5)) AND 6</booleanFilter>
        <criteriaItems>
            <field>Opportunity.StageName</field>
            <operation>equals</operation>
            <value>Closed Won</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Type</field>
            <operation>equals</operation>
            <value>New Business</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.First_Win_Opportunity__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Type</field>
            <operation>equals</operation>
            <value>Follow on Business,Support Renewal,Subscription Renewal,EC Renewal,New Business</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Amount</field>
            <operation>greaterThan</operation>
            <value>100000</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CloseDate</field>
            <operation>greaterOrEqual</operation>
            <value>10/23/2017</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Set Sales Region on an Opp</fullName>
        <actions>
            <name>Set_Sales_Region</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>OR (IsNew(), ISCHANGED( OwnerId ))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Set Stage to Discovery for Deal Reg</fullName>
        <actions>
            <name>Deal_reg_Update_Stage_to_Discovery</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.Deal_Reg__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>If the opp is created from deal reg then, the stage should set to Discovery.</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>SetPOCType2None</fullName>
        <actions>
            <name>SetPOCType2None</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.Type</field>
            <operation>equals</operation>
            <value>Support Renewal</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>SetRecordTypeDefault</fullName>
        <actions>
            <name>SetRecordTypeDefault</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.RecordTypeId</field>
            <operation>notEqual</operation>
            <value>New,Follow On,Maintenance,Deleted</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Type</field>
            <operation>notEqual</operation>
            <value>Follow on Business,Support Renewal,Marketplace</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>SetRecordTypeSpecificFO</fullName>
        <actions>
            <name>SetRecordTypeSpecificFO</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.RecordTypeId</field>
            <operation>notEqual</operation>
            <value>Follow On</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Type</field>
            <operation>equals</operation>
            <value>Follow on Business</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>SetRecordTypeSpecificMR</fullName>
        <actions>
            <name>SetRecordTypeSpecificMR</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.RecordTypeId</field>
            <operation>notEqual</operation>
            <value>Maintenance</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Type</field>
            <operation>equals</operation>
            <value>Support Renewal</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>SetWinLossFlagOnNew</fullName>
        <actions>
            <name>SetWinLossFlagToOne</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.WinLossInclude__c</field>
            <operation>lessThan</operation>
            <value>1</value>
        </criteriaItems>
        <description>If flag isn&apos;t one, then set it</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>TempToFixRenewalStage</fullName>
        <active>false</active>
        <criteriaItems>
            <field>Opportunity.Type</field>
            <operation>equals</operation>
            <value>Support Renewal</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.PartnerStage__c</field>
            <operation>contains</operation>
            <value>Verbal</value>
        </criteriaItems>
        <description>to fix the new renewals until the code is changed to the stage</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Track Opp Owner Last Update</fullName>
        <actions>
            <name>Update_Last_Modified_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>OwnerId == LastModifiedById</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Transactional Opportunity checkbox Trigger Re-Assignment</fullName>
        <actions>
            <name>Transactional_Opportunity_Alert</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Trigger_Assignment</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.Transactional_Opportunity__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>UnCheck Partner Intiated Flag</fullName>
        <actions>
            <name>Uncheck_Partner_Initated_Flag</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <formula>AND(
NOT(ISNULL( AccountId)),
Account.Is_Partner_Initiated_Account__c,
NOT(ISPICKVAL(Type,&quot;Marketplace&quot;)),
NOT(New_Business__c) 
)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>UpdateLeadSource</fullName>
        <active>false</active>
        <description>when a lead source is null, then update it to the opportunity source when that field is set or changes</description>
        <formula>AND( If( CASE ( 1, 
IF(ISPICKVAL (LeadSource, &quot;Inbound Call&quot;), 1,0), &quot;Used&quot;,
IF(ISPICKVAL (LeadSource, &quot;Web- Contact us&quot;), 1,0), &quot;Used&quot;,
IF(ISPICKVAL (LeadSource, &quot;Web - Search Engine&quot;), 1,0), &quot;Used&quot;,
IF(ISPICKVAL (LeadSource, &quot;Web- Trial Request&quot;), 1,0), &quot;Used&quot;,
IF(ISPICKVAL (LeadSource, &quot;Web- Info Ctr Sign up&quot;), 1,0), &quot;Used&quot;,
IF(ISPICKVAL (LeadSource, &quot;Mktng Email blast&quot;), 1,0), &quot;Used&quot;,
IF(ISPICKVAL (LeadSource, &quot;Event- Trade Show&quot;), 1,0), &quot;Used&quot;,
IF(ISPICKVAL (LeadSource, &quot;Event- LnL / Other SPEAK&quot;), 1,0), &quot;Used&quot;,
IF(ISPICKVAL (LeadSource, &quot;Event- Webinar&quot;), 1,0), &quot;Used&quot;,
IF(ISPICKVAL (LeadSource, &quot;Promo - White Paper dwnld&quot;), 1,0), &quot;Used&quot;,
IF(ISPICKVAL (LeadSource, &quot;RSM- Rolodex&quot;), 1,0), &quot;Used&quot;,
IF(ISPICKVAL (LeadSource, &quot;RSM - Brocade Referral&quot;), 1,0), &quot;Used&quot;,
IF(ISPICKVAL (LeadSource, &quot;RSM- Cust Referral&quot;), 1,0), &quot;Used&quot;,
IF(ISPICKVAL (LeadSource, &quot;RSM- EMC Referral&quot;), 1,0), &quot;Used&quot;,
IF(ISPICKVAL (LeadSource, &quot;RSM- VAR Referral&quot;), 1,0), &quot;Used&quot;,
IF(ISPICKVAL (LeadSource, &quot;RSM- Other Tech Partner Ref&quot;), 1,0), &quot;Used&quot;,
IF(ISPICKVAL (LeadSource, &quot;ISR- Referral from Lead&quot;), 1,0), &quot;Used&quot;,
IF(ISPICKVAL (LeadSource, &quot;ISR- Research&quot;), 1,0), &quot;Used&quot;,
IF(ISPICKVAL (LeadSource, &quot;Legacy/Unknown&quot;), 1,0), &quot;Used&quot;,
IF(ISPICKVAL (LeadSource, &quot;Deal Registration&quot;), 1,0), &quot;Used&quot;,
IF(ISPICKVAL (LeadSource, &quot;Customer Referral.&quot;), 1,0), &quot;Used&quot;,
&quot;UnUsed&quot;) = &quot;UnUsed&quot;, True, False),  ISCHANGED( Opportunity_Source__c ) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>new_oppty_exec_notice-APAC</fullName>
        <actions>
            <name>NewOpptyopened_APAC</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.CreatedDate</field>
            <operation>greaterThan</operation>
            <value>1/1/2011</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Name</field>
            <operation>notContain</operation>
            <value>Free Marketplace Trial</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Sales_Region__c</field>
            <operation>contains</operation>
            <value>APAC</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Type</field>
            <operation>notEqual</operation>
            <value>Support Renewal,Reseller Demo/NFR,Training/WanStart</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>new_oppty_exec_notice-EMEA</fullName>
        <actions>
            <name>NewOpptyopened_EMEA</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.CreatedDate</field>
            <operation>greaterThan</operation>
            <value>1/1/2011</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Name</field>
            <operation>notContain</operation>
            <value>Free Marketplace Trial</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Sales_Region__c</field>
            <operation>contains</operation>
            <value>EMEA</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Type</field>
            <operation>notEqual</operation>
            <value>Support Renewal,Reseller Demo/NFR,Training/WanStart</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>new_oppty_exec_notice-Ken</fullName>
        <actions>
            <name>NewOpptyopened</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.CreatedDate</field>
            <operation>greaterThan</operation>
            <value>1/1/2011</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Name</field>
            <operation>notContain</operation>
            <value>Free Marketplace Trial</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Sales_Region__c</field>
            <operation>contains</operation>
            <value>NAM,GAM</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Type</field>
            <operation>notEqual</operation>
            <value>Support Renewal,Reseller Demo/NFR,Training/WanStart</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
        <workflowTimeTriggers>
            <timeLength>2</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>new_oppty_exec_notice-LAT</fullName>
        <actions>
            <name>NewOpptyopened_LAT</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.CreatedDate</field>
            <operation>greaterThan</operation>
            <value>1/1/2011</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Name</field>
            <operation>notContain</operation>
            <value>Free Marketplace Trial</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Sales_Region__c</field>
            <operation>contains</operation>
            <value>LAT</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Type</field>
            <operation>notEqual</operation>
            <value>Support Renewal,Reseller Demo/NFR,Training/WanStart</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>oppty-closed</fullName>
        <actions>
            <name>OpportunityStageChangeEvalORClosedNotWonOver100K</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <booleanFilter>1 AND 2 AND 3</booleanFilter>
        <criteriaItems>
            <field>Opportunity.StageName</field>
            <operation>equals</operation>
            <value>Closed Lost,Closed Dead</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Amount</field>
            <operation>greaterOrEqual</operation>
            <value>100000</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Type</field>
            <operation>notEqual</operation>
            <value>Marketplace</value>
        </criteriaItems>
        <description>oppty-closed and not won over 100K add exec staff to notices</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>oppty-closed-under100k</fullName>
        <actions>
            <name>OpportunityStageChangeEvalORClosedNotWon</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <booleanFilter>1 AND 2</booleanFilter>
        <criteriaItems>
            <field>Opportunity.StageName</field>
            <operation>equals</operation>
            <value>Closed Lost,Closed Dead</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Type</field>
            <operation>notEqual</operation>
            <value>Marketplace</value>
        </criteriaItems>
        <description>oppty-closed and not won under 100k</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>oppty-closed_set_closedate</fullName>
        <actions>
            <name>SetCloseDateOnClosedLost</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>oppty-closed and not won, sets the closed date to the date of closue</description>
        <formula>AND( ISCHANGED( StageName ) , OR( ISPICKVAL( StageName , &apos;Closed Lost&apos;) , ISPICKVAL( StageName , &apos;Closed Dead&apos;), 
OR(ISPICKVAL( StageName , &apos;Closed Deleted&apos;),OR(ISPICKVAL( StageName , &apos;Closed Won&apos;)))))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>rvee__Deal Registration Approved</fullName>
        <actions>
            <name>Deal_Registration_Approved</name>
            <type>OutboundMessage</type>
        </actions>
        <active>false</active>
        <formula>(rvpe__IsDealRegistration__c == true)</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>rvee__Notify RV Member</fullName>
        <actions>
            <name>rvee__NotifyRVMemberReset</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Notify_RV_Member</name>
            <type>OutboundMessage</type>
        </actions>
        <active>true</active>
        <formula>(rvpe__NotifyRVMember__c == true)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
