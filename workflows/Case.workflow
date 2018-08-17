<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>AccountTeamNotification</fullName>
        <description>Account Team Notification</description>
        <protected>false</protected>
        <recipients>
            <recipient>Case Updates</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>Systems Engineer</recipient>
            <type>accountTeam</type>
        </recipients>
        <senderAddress>support@silver-peak.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Sales/CaseUpdatedNotice</template>
    </alerts>
    <alerts>
        <fullName>CaseClosed</fullName>
        <description>Case Closed</description>
        <protected>false</protected>
        <recipients>
            <recipient>dennis@silver-peak.com</recipient>
            <type>user</type>
        </recipients>
        <senderAddress>support@silver-peak.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Support/CustomerCaseClosure</template>
    </alerts>
    <alerts>
        <fullName>Email_Case_Update_Added</fullName>
        <ccEmails>caseupdates@silver-peak.com</ccEmails>
        <description>Email - Case Update Added</description>
        <protected>false</protected>
        <recipients>
            <recipient>Case Updates</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>Systems Engineer</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>All Comments</recipient>
            <type>caseTeam</type>
        </recipients>
        <recipients>
            <recipient>Internal Discussion</recipient>
            <type>caseTeam</type>
        </recipients>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Support/InternalCaseUpdate</template>
    </alerts>
    <alerts>
        <fullName>Email_Case_Update_Added_UI</fullName>
        <description>Email - Case Update Added in UI</description>
        <protected>false</protected>
        <recipients>
            <recipient>Case Updates</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>Systems Engineer</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>All Comments</recipient>
            <type>caseTeam</type>
        </recipients>
        <recipients>
            <recipient>Internal Discussion</recipient>
            <type>caseTeam</type>
        </recipients>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Support/InternalCaseUpdate</template>
    </alerts>
    <alerts>
        <fullName>Email_DevOps_Support_Case_Creation</fullName>
        <description>Email- DevOps Support Case Creation</description>
        <protected>false</protected>
        <recipients>
            <field>ContactEmail</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>SuppliedEmail</field>
            <type>email</type>
        </recipients>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>devopshelp@silver-peak.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Support/DevOps_Support_Case_Creation</template>
    </alerts>
    <alerts>
        <fullName>Email_Facilities_Support_Case_Creation</fullName>
        <description>Email-Facilities Support Case Creation</description>
        <protected>false</protected>
        <recipients>
            <field>ContactEmail</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>SuppliedEmail</field>
            <type>email</type>
        </recipients>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>facilities@silver-peak.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Support/Facilities_Case_Creation</template>
    </alerts>
    <alerts>
        <fullName>Email_HR_Support_Case_Creation</fullName>
        <description>Email- HR Support Case Creation</description>
        <protected>false</protected>
        <recipients>
            <field>ContactEmail</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>SuppliedEmail</field>
            <type>email</type>
        </recipients>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>hrhelp@silver-peak.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Support/HR_Support_Case_Creation</template>
    </alerts>
    <alerts>
        <fullName>Email_Help_Case_Opened</fullName>
        <description>Email - Help - Case Opened</description>
        <protected>false</protected>
        <recipients>
            <field>ContactEmail</field>
            <type>email</type>
        </recipients>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>ithelp@silver-peak.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Support/EmployeeITTicketCreation</template>
    </alerts>
    <alerts>
        <fullName>Email_Help_Customer_Case_Comments</fullName>
        <description>Email - Help - Customer Case Comments</description>
        <protected>false</protected>
        <recipients>
            <field>CC1__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>CC2__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>CC3__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>ContactEmail</field>
            <type>email</type>
        </recipients>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>ithelp@silver-peak.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Support/TicketCommentUpdate</template>
    </alerts>
    <alerts>
        <fullName>Email_Help_Owner_Case_Comments</fullName>
        <description>Email - Help - Owner Case Comments</description>
        <protected>false</protected>
        <recipients>
            <field>CC1__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>CC2__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>CC3__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>ContactEmail</field>
            <type>email</type>
        </recipients>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>ithelp@silver-peak.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Support/TicketCommentUpdate</template>
    </alerts>
    <alerts>
        <fullName>Email_LabHelp_Support_Case_Creation</fullName>
        <description>Email- LabHelp Support Case Creation</description>
        <protected>false</protected>
        <recipients>
            <field>ContactEmail</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>SuppliedEmail</field>
            <type>email</type>
        </recipients>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>labhelp@silver-peak.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Support/LabHelp_Support_Case_Creation</template>
    </alerts>
    <alerts>
        <fullName>Email_Support_Case_Opened</fullName>
        <ccEmails>customerresponse@answer1.com</ccEmails>
        <description>Email - Support - Case Opened</description>
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
            <field>CC10__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>CC11__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>CC12__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>CC1__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>CC2__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>CC3__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>CC4__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>CC5__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>CC6__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>CC7__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>CC8__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>CC9__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>ContactEmail</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>SuppliedEmail</field>
            <type>email</type>
        </recipients>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <recipient>csr@answer1.com</recipient>
            <type>user</type>
        </recipients>
        <senderAddress>support@silver-peak.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Support/CustomerCaseCreation</template>
    </alerts>
    <alerts>
        <fullName>Email_Support_Customer_Case_Comments</fullName>
        <description>Email - Support - Customer Case Comments</description>
        <protected>false</protected>
        <recipients>
            <recipient>Case Updates</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>Systems Engineer</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>All Comments</recipient>
            <type>caseTeam</type>
        </recipients>
        <recipients>
            <field>CC10__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>CC11__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>CC12__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>CC1__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>CC2__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>CC3__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>CC4__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>CC5__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>CC6__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>CC7__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>CC8__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>CC9__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>ContactEmail</field>
            <type>email</type>
        </recipients>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>support@silver-peak.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Support/CaseCommentUpdate</template>
    </alerts>
    <alerts>
        <fullName>Email_Support_Owner_Case_Comment</fullName>
        <description>Email - Support - Owner Case Comment</description>
        <protected>false</protected>
        <recipients>
            <recipient>Case Updates</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>Systems Engineer</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>All Comments</recipient>
            <type>caseTeam</type>
        </recipients>
        <recipients>
            <field>CC10__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>CC11__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>CC12__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>CC1__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>CC2__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>CC3__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>CC4__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>CC5__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>CC6__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>CC7__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>CC8__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>CC9__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>ContactEmail</field>
            <type>email</type>
        </recipients>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>support@silver-peak.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Support/CaseCommentUpdate</template>
    </alerts>
    <alerts>
        <fullName>EngineeringSupportCaseopened</fullName>
        <ccEmails>tseteam@silver-peak.com</ccEmails>
        <description>Engineering Support Case opened</description>
        <protected>false</protected>
        <senderAddress>support@silver-peak.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Support/TechSupportCaseinQueue</template>
    </alerts>
    <alerts>
        <fullName>NewCaseiscreatedLinklaters</fullName>
        <ccEmails>Jason@rdc.uk.com, paul.lawrence@rdc.uk.com</ccEmails>
        <description>New Case is created - Linklaters</description>
        <protected>false</protected>
        <senderAddress>support@silver-peak.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Support/LinklatersCases</template>
    </alerts>
    <alerts>
        <fullName>NewHighPriorityCaseiscreated</fullName>
        <ccEmails>tseteam@silver-peak.com,</ccEmails>
        <ccEmails>SEManagers@silver-peak.com</ccEmails>
        <description>New High Priority Case is created</description>
        <protected>false</protected>
        <recipients>
            <type>accountOwner</type>
        </recipients>
        <recipients>
            <recipient>Systems Engineer</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>afuoss@silver-peak.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>cdehoust@silver-peak.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>crogers@silver-peak.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>dennis@silver-peak.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>dhughes@silver-peak.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>mkulkarni@silver-peak.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>psingh@silver-peak.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>ttedijanto@silver-peak.com</recipient>
            <type>user</type>
        </recipients>
        <senderAddress>support@silver-peak.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Support/TechSupportP1</template>
    </alerts>
    <alerts>
        <fullName>NewHighPriorityCaseiscreated4CSR1</fullName>
        <description>New High Priority Case is created for Answer 1</description>
        <protected>false</protected>
        <recipients>
            <recipient>csr@answer1.com</recipient>
            <type>user</type>
        </recipients>
        <senderAddress>support@silver-peak.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Support/TechSupportP1</template>
    </alerts>
    <alerts>
        <fullName>New_Portal_User_case</fullName>
        <ccEmails>tseteam@silver-peak.com</ccEmails>
        <description>New Portal User case</description>
        <protected>false</protected>
        <senderAddress>support@silver-peak.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Support/CustomerPortalCaseCreation</template>
    </alerts>
    <alerts>
        <fullName>Notification_of_rejection_by_team_member</fullName>
        <description>Notification of rejection by team member</description>
        <protected>false</protected>
        <recipients>
            <field>CC1__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>ContactEmail</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>SuppliedEmail</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Support/ChangeRequestRejected</template>
    </alerts>
    <alerts>
        <fullName>NotifyEngineeringwhenacaseisescalated</fullName>
        <ccEmails>ttedijanto@silver-peak.com</ccEmails>
        <description>Notify Engineering when a case is escalated</description>
        <protected>false</protected>
        <senderAddress>support@silver-peak.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Support/CaseOwnershipAssigned</template>
    </alerts>
    <alerts>
        <fullName>NotifyNewOwner</fullName>
        <description>NotifyNewOwner</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>support@silver-peak.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Support/CaseOwnershipAssigned</template>
    </alerts>
    <alerts>
        <fullName>PerfHelp_Case_Comments</fullName>
        <description>PerfHelp - Case Comments</description>
        <protected>false</protected>
        <recipients>
            <field>CC1__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>ContactEmail</field>
            <type>email</type>
        </recipients>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>perfhelp@silver-peak.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Support/TicketCommentUpdate</template>
    </alerts>
    <alerts>
        <fullName>PerfHelp_Case_Opened</fullName>
        <description>PerfHelp - Case Opened</description>
        <protected>false</protected>
        <recipients>
            <field>CC1__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>ContactEmail</field>
            <type>email</type>
        </recipients>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>perfhelp@silver-peak.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Support/PerfHelp_Ticket_Creation</template>
    </alerts>
    <alerts>
        <fullName>SampleEntryForCaseAccountTeam</fullName>
        <description>SampleEntryForCaseAccountTeam</description>
        <protected>false</protected>
        <recipients>
            <recipient>Case Updates</recipient>
            <type>accountTeam</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/EOL_upgrade</template>
    </alerts>
    <alerts>
        <fullName>SendCaseCommentUpdatedNotification</fullName>
        <description>Send Case Comment Updated Notification</description>
        <protected>false</protected>
        <recipients>
            <recipient>All Comments</recipient>
            <type>caseTeam</type>
        </recipients>
        <recipients>
            <field>CC10__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>CC11__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>CC12__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>CC1__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>CC2__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>CC3__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>CC4__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>CC5__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>CC6__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>CC7__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>CC8__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>CC9__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>ContactEmail</field>
            <type>email</type>
        </recipients>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>support@silver-peak.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Support/CaseCommentUpdate</template>
    </alerts>
    <alerts>
        <fullName>SendNewCaseNotification</fullName>
        <description>Send New Case Notification</description>
        <protected>false</protected>
        <recipients>
            <field>CC10__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>CC11__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>CC12__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>CC1__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>CC2__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>CC3__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>CC4__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>CC5__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>CC6__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>CC7__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>CC8__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>CC9__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>ContactEmail</field>
            <type>email</type>
        </recipients>
        <senderAddress>support@silver-peak.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Support/CustomerCaseCreation</template>
    </alerts>
    <alerts>
        <fullName>SendNewCaseNotification2CSR</fullName>
        <description>Send New Case Notification To Answer1</description>
        <protected>false</protected>
        <recipients>
            <recipient>csr@answer1.com</recipient>
            <type>user</type>
        </recipients>
        <senderAddress>support@silver-peak.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Support/Answer1CaseCreationNotice</template>
    </alerts>
    <alerts>
        <fullName>SendNewCaseNotificationNonEmail</fullName>
        <description>Send New Case Notification- Non Email</description>
        <protected>false</protected>
        <recipients>
            <field>CC10__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>CC11__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>CC12__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>CC1__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>CC2__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>CC3__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>CC4__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>CC5__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>CC6__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>CC7__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>CC8__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>CC9__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>ContactEmail</field>
            <type>email</type>
        </recipients>
        <senderAddress>support@silver-peak.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Support/CustomerCaseCreationNonEmail</template>
    </alerts>
    <alerts>
        <fullName>Send_Case_Contact_a_satisfaction_survey_request</fullName>
        <description>Send Case Contact a satisfaction survey request</description>
        <protected>false</protected>
        <recipients>
            <field>ContactEmail</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>SuppliedEmail</field>
            <type>email</type>
        </recipients>
        <senderAddress>support@silver-peak.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Support/SupportSatisfactionSurvey</template>
    </alerts>
    <alerts>
        <fullName>Send_Email_Notification_to_Facilities_Team</fullName>
        <description>Send Email Notification to Facilities Team</description>
        <protected>false</protected>
        <recipients>
            <recipient>cemel@silver-peak.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>jcreasy@silver-peak.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>jslaughterbeck@silver-peak.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>ldenton@silver-peak.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Support/CaseOwnershipAssigned</template>
    </alerts>
    <alerts>
        <fullName>Send_Email_Notification_to_HR_Team</fullName>
        <description>Send Email Notification to HR Team</description>
        <protected>false</protected>
        <recipients>
            <recipient>jcreasy@silver-peak.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>jslaughterbeck@silver-peak.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>msewani@silver-peak.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Support/CaseOwnershipAssigned</template>
    </alerts>
    <alerts>
        <fullName>Send_Support_Case_Notification_to_CSR_Team</fullName>
        <ccEmails>customerresponse@answer1.com</ccEmails>
        <ccEmails>Alicia@answer1.com</ccEmails>
        <ccEmails>Cameron@answer1.com</ccEmails>
        <ccEmails>Athena@answer1.com</ccEmails>
        <ccEmails>tsemanagers@silver-peak.com</ccEmails>
        <description>Send Support Case Notification to CSR Team</description>
        <protected>false</protected>
        <recipients>
            <recipient>pmusunuru@silver-peak.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Support_Case_Notification_to_Csr_Team</template>
    </alerts>
    <alerts>
        <fullName>notify_customer_wanstart_activated</fullName>
        <description>notify_customer_wanstart_activated</description>
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
            <recipient>Executive Sponsor</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>Lead Qualifier</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>Sales Manager</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>Sales Rep</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>Systems Engineer</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <field>CC1__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>CC2__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>ContactEmail</field>
            <type>email</type>
        </recipients>
        <recipients>
            <recipient>dennis@silver-peak.com</recipient>
            <type>user</type>
        </recipients>
        <senderAddress>support@silver-peak.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Support/WANstart_Activation</template>
    </alerts>
    <fieldUpdates>
        <fullName>Case_Notification_TimeStamp</fullName>
        <field>Case_Notification_TimeStamp__c</field>
        <formula>NOW()- 0.02073</formula>
        <name>Case Notification TimeStamp</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ChangeCaseRecordType</fullName>
        <field>RecordTypeId</field>
        <lookupValue>TechnicalSupport</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>ChangeCaseRecordType</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ChangeCasetTypeTech</fullName>
        <field>Type</field>
        <literalValue>Technical support</literalValue>
        <name>ChangeCasetType2Tech</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ChangeOwner4ITRequests</fullName>
        <field>OwnerId</field>
        <lookupValue>ITHelp</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>ChangeOwner4ITRequests</name>
        <notifyAssignee>true</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ChangeOwner4PerfHelpRequests</fullName>
        <field>OwnerId</field>
        <lookupValue>PerfHelp</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>ChangeOwner4PerfHelpRequests</name>
        <notifyAssignee>true</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Close_the_Case</fullName>
        <field>Status</field>
        <literalValue>Completed</literalValue>
        <name>Close the Case</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Disable_RMA_Flag</fullName>
        <field>Allow_RMA__c</field>
        <literalValue>0</literalValue>
        <name>Disable RMA Flag</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>FU_RT_SetToWANStart</fullName>
        <description>Sets record type to WANstart when a case is created for one of the WANstart types</description>
        <field>RecordTypeId</field>
        <lookupValue>WANstart</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>FU:RT-SetToWANStart</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Get_Case_Opened_Priority</fullName>
        <field>Case_Opened_Priority__c</field>
        <formula>TEXT(Priority)</formula>
        <name>Get Case Opened Priority</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Get_Product_Quote_Type</fullName>
        <field>Product_Quote_Type__c</field>
        <formula>TEXT(Asset.Product2.Product_Type__c)</formula>
        <name>Get Product Quote Type</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>SendFieldFalse</fullName>
        <field>CreatedByApex__c</field>
        <literalValue>0</literalValue>
        <name>Send Field False</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>SendToTier1Queue</fullName>
        <field>OwnerId</field>
        <lookupValue>Tier1</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>SendToTier1Queue</name>
        <notifyAssignee>true</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>SetAsITRequest</fullName>
        <description>Change the case type to be an IT help request when the case contact email contains Silver Peak Email domains and the case was created by Email Handler</description>
        <field>RecordTypeId</field>
        <lookupValue>IT_Help_Requests</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>SetAsITRequest</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>SetFieldFalse</fullName>
        <field>CreatedByApex__c</field>
        <literalValue>0</literalValue>
        <name>Set Field False</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>SetOwnerToTSQ</fullName>
        <description>Set the Owner on cases created in the portal to the tech support queue</description>
        <field>OwnerId</field>
        <lookupValue>TechSupportQueue</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>SetOwnerToTSQ</name>
        <notifyAssignee>true</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>SetPartnerEmailFromText</fullName>
        <description>there is a formula field to copy the account parnter email to the case as a text field, this rule will copy that text into an email field. It assumes valiation will pass because the email value would have been validate upon entry at the account</description>
        <field>Partner_Notifications__c</field>
        <formula>Partner_Notifications_Text__c</formula>
        <name>SetPartnerEmailFromText</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>SetStatus</fullName>
        <description>to be unassigend</description>
        <field>Status</field>
        <literalValue>Unassigned</literalValue>
        <name>SetStatus</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>SetVisibleInPortalFlag</fullName>
        <description>to true</description>
        <field>IsVisibleInSelfService</field>
        <literalValue>1</literalValue>
        <name>SetVisibleInPortalFlag</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Setup_Google_CC</fullName>
        <description>add silverpeak@google.com to CC12 field</description>
        <field>CC12__c</field>
        <formula>&quot;silverpeak@google.com&quot;</formula>
        <name>Setup Google CC</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Support_Case_30_min_Notification1_False</fullName>
        <field>Support_Case_30_min_Notification__c</field>
        <literalValue>0</literalValue>
        <name>Support Case 30 min Notification1-False</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Support_Case_30_min_Notification1_True</fullName>
        <field>Support_Case_30_min_Notification__c</field>
        <literalValue>1</literalValue>
        <name>Support Case 30 min Notification1-True</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UpdateApprovalStatus</fullName>
        <field>Change_Development_Stage__c</field>
        <literalValue>Approved</literalValue>
        <name>UpdateApprovalStatus</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Case_CC_10_Email</fullName>
        <field>CC10__c</field>
        <formula>Contact.Account.Customer_CC_Email__c</formula>
        <name>Update Case CC 10 Email</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Case_Disposition</fullName>
        <field>Case_Disposition__c</field>
        <literalValue>Answer/Solution Provided</literalValue>
        <name>Update Case Disposition</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Case_Entitlement_Type</fullName>
        <field>Entitlement_Type__c</field>
        <literalValue>Contract</literalValue>
        <name>Update Case Entitlement Type</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Case_Field</fullName>
        <field>UpdatedBy__c</field>
        <name>Update Case Field</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Case_Reason</fullName>
        <field>Reason</field>
        <literalValue>Management</literalValue>
        <name>Update Case Reason</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Case_Status_to_In_Process</fullName>
        <field>Status</field>
        <literalValue>In Process</literalValue>
        <name>Update Case Status to In Process</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Entitlement_Type</fullName>
        <field>Entitlement_Type__c</field>
        <literalValue>Contract</literalValue>
        <name>Update Entitlement Type</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>expire_wanstart_case</fullName>
        <field>Status</field>
        <literalValue>Expired</literalValue>
        <name>expire_wanstart_case</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>set_start_date</fullName>
        <description>today</description>
        <field>Begin_Date__c</field>
        <formula>Today()</formula>
        <name>set_start_date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Activate_WANstart_cases</fullName>
        <actions>
            <name>notify_customer_wanstart_activated</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>set_start_date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>when the status changes to active, set start date</description>
        <formula>ISPICKVAL( Status , &quot;Active&quot;)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>expire_wanstart_case</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>Case.End_Date__c</offsetFromField>
            <timeLength>1</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>AutoDispatchPhoneCases</fullName>
        <actions>
            <name>NotifyNewOwner</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>SetOwnerToTSQ</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.Type</field>
            <operation>equals</operation>
            <value>Incoming Email,Customer Service,Technical support</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.Username</field>
            <operation>equals</operation>
            <value>csr@answer1.com</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Origin</field>
            <operation>equals</operation>
            <value>Phone</value>
        </criteriaItems>
        <criteriaItems>
            <field>Contact.Testing__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <description>When a case is opened by Tier 1 and coded as phone, auto dispatch it to Tech support queue</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Beta_Cases</fullName>
        <actions>
            <name>EngineeringSupportCaseopened</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <booleanFilter>(1 OR 2) AND 3</booleanFilter>
        <criteriaItems>
            <field>Case.Type</field>
            <operation>equals</operation>
            <value>Engineering Support</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Entitlement_Type__c</field>
            <operation>equals</operation>
            <value>Beta</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Incoming Email,Technical Support</value>
        </criteriaItems>
        <description>Send an email when a beta case is created</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Case Closed Internal</fullName>
        <actions>
            <name>CaseClosed</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Closed,Closed-Unresolved</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Case Comment Updated</fullName>
        <actions>
            <name>SendCaseCommentUpdatedNotification</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>SetFieldFalse</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <formula>AND(CreatedByApex__c = true, CreatedDate  &lt;&gt;  LastModifiedDate)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Case Updates - Internal Discussion</fullName>
        <actions>
            <name>Email_Case_Update_Added</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Update_Case_Field</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.UpdatedBy__c</field>
            <operation>equals</operation>
            <value>Internal</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.LastModifiedById</field>
            <operation>equals</operation>
            <value>caseupdates@silver-peak.com</value>
        </criteriaItems>
        <description>Use this rule for Case updates that are done by email</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Case Updates - Internal in UI Discussion</fullName>
        <actions>
            <name>Email_Case_Update_Added_UI</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Update_Case_Field</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.UpdatedBy__c</field>
            <operation>equals</operation>
            <value>Internal</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.LastModifiedById</field>
            <operation>notEqual</operation>
            <value>caseupdates@silver-peak.com</value>
        </criteriaItems>
        <description>Use this rule for Case updates that are done in User Interface</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>CaseOwnershipChange</fullName>
        <actions>
            <name>NotifyNewOwner</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>bypass trigger for new case ownership and send one from support</description>
        <formula>AND( ISCHANGED( OwnerId ) ,

OR( ( $RecordType.Name = &apos;Technical Support&apos;) ,
( $RecordType.Name = &apos;Incoming Email&apos;)  ,
( $RecordType.Name =  &apos;WANstart&apos;) 
),

NOT(Contact.Testing__c)
)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Cases - Linklaters</fullName>
        <actions>
            <name>NewCaseiscreatedLinklaters</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 AND (2 OR 3) AND 4</booleanFilter>
        <criteriaItems>
            <field>Contact.AccountName</field>
            <operation>equals</operation>
            <value>Linklaters</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Priority</field>
            <operation>equals</operation>
            <value>P1 - Urgent</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Severity__c</field>
            <operation>equals</operation>
            <value>S1- Critical</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Incoming Email,Technical Support</value>
        </criteriaItems>
        <description>When a case is opened for Linklaters, notify the RDP rep in the UK</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>ChangeCaseType</fullName>
        <actions>
            <name>ChangeCaseRecordType</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>ChangeCasetTypeTech</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 AND 2 OR 3</booleanFilter>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Incoming Email</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.OwnerId</field>
            <operation>contains</operation>
            <value>Technical</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Origin</field>
            <operation>equals</operation>
            <value>Orchestrator</value>
        </criteriaItems>
        <description>Change the case record type and type Technical Support</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Close WAN START Case after 60 days</fullName>
        <actions>
            <name>Update_Entitlement_Type</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.Subject</field>
            <operation>startsWith</operation>
            <value>New WANstart</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>WANstart</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Close_the_Case</name>
                <type>FieldUpdate</type>
            </actions>
            <actions>
                <name>Update_Case_Disposition</name>
                <type>FieldUpdate</type>
            </actions>
            <actions>
                <name>Update_Case_Entitlement_Type</name>
                <type>FieldUpdate</type>
            </actions>
            <actions>
                <name>Update_Case_Reason</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>Case.CreatedDate</offsetFromField>
            <timeLength>60</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>CustomerSatisfactionSurvey</fullName>
        <actions>
            <name>Send_Case_Contact_a_satisfaction_survey_request</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 AND 2 AND 3 AND 4</booleanFilter>
        <criteriaItems>
            <field>Case.IsClosed</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Send_Survey__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Technical Support</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.CreatedDate</field>
            <operation>lessThan</operation>
            <value>TODAY</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>DevOps Support Case Creation</fullName>
        <actions>
            <name>Email_DevOps_Support_Case_Creation</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.Type</field>
            <operation>equals</operation>
            <value>DevOpsHelp</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>DevOps Help Requests</value>
        </criteriaItems>
        <description>This workflow rule will send an email notification to the customer about the case creation.</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Escalation Email</fullName>
        <active>true</active>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Escalated - Tier 4</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Pending Eng Feedback,Pending Bug Fix</value>
        </criteriaItems>
        <description>Upon escalation to the Engineering Queue, send an email with the current status of the case to the Engineering alias distribution list</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Escalation to Eng</fullName>
        <actions>
            <name>NotifyEngineeringwhenacaseisescalated</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Pending Bug Fix,Pending Eng Feedback,Eng. - Additional Info Requested,Escalated - Tier 4</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Incoming Email,Technical Support</value>
        </criteriaItems>
        <description>Send an email when a case status is changed to escalated to engineering</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>FU%3ART-SetToWANStart</fullName>
        <actions>
            <name>FU_RT_SetToWANStart</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.Type</field>
            <operation>equals</operation>
            <value>WANstart Bundled,WANstart Services</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Facilities Case Creation</fullName>
        <actions>
            <name>Email_Facilities_Support_Case_Creation</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.Type</field>
            <operation>equals</operation>
            <value>Facilities</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Facilities</value>
        </criteriaItems>
        <description>This workflow rule will send an email notification to the customer about the case creation.</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Facilities-CaseOwnershipChange</fullName>
        <actions>
            <name>Send_Email_Notification_to_Facilities_Team</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>This workflow is used to notify the facilities team when a case is assigned to a team member.</description>
        <formula>AND(ISCHANGED(OwnerId), 
RecordType.Id =&apos;01238000000E9ik&apos;)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Get Product Quote Type on Case</fullName>
        <actions>
            <name>Get_Product_Quote_Type</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>OR(ISNEW(),
   ISCHANGED(AssetId))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>HR Support Case Creation</fullName>
        <actions>
            <name>Email_HR_Support_Case_Creation</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.Type</field>
            <operation>equals</operation>
            <value>HR Support</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>HR Requests</value>
        </criteriaItems>
        <description>This workflow rule will send an email notification to the customer about the case creation.</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>HR-CaseOwnershipChange</fullName>
        <actions>
            <name>Send_Email_Notification_to_HR_Team</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>This workflow is used to notify the HR team when a case is assigned to a team member.</description>
        <formula>AND(ISCHANGED(OwnerId), 
RecordType.Id =&apos;01238000000E9il&apos;)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Help - Case Opened</fullName>
        <actions>
            <name>Email_Help_Case_Opened</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>IT Help Requests</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Help - Customer Case Comments</fullName>
        <actions>
            <name>Email_Help_Customer_Case_Comments</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Update_Case_Field</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>IT Help Requests</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.UpdatedBy__c</field>
            <operation>equals</operation>
            <value>Customer</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Help - Owner Case Comments</fullName>
        <actions>
            <name>Email_Help_Owner_Case_Comments</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Update_Case_Field</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>IT Help Requests</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.UpdatedBy__c</field>
            <operation>equals</operation>
            <value>Owner</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>LabHelp Support Case Creation</fullName>
        <actions>
            <name>Email_LabHelp_Support_Case_Creation</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.Type</field>
            <operation>equals</operation>
            <value>LabHelp</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Lab Help Requests</value>
        </criteriaItems>
        <description>This workflow rule will send an email notification to the customer about the case creation.</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>New Case Created</fullName>
        <actions>
            <name>SendNewCaseNotification</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>SendNewCaseNotification2CSR</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.CreatedByApex__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Incoming Email,Technical Support</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Subject</field>
            <operation>notContain</operation>
            <value>AUTOCASE</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.ContactEmail</field>
            <operation>notEqual</operation>
            <value>support@salesforce.com</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>notEqual</operation>
            <value>Closed,Closed-Unresolved,Completed,Expired</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>New Case Created -Non Email</fullName>
        <actions>
            <name>SendNewCaseNotificationNonEmail</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.Origin</field>
            <operation>notEqual</operation>
            <value>Email</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Incoming Email,Technical Support</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>New Case Created All</fullName>
        <actions>
            <name>New_Portal_User_case</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>ChangeCasetTypeTech</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>SetOwnerToTSQ</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 and (2 AND 3 AND 4 AND 5) AND (6 OR 7) AND 8 AND 9</booleanFilter>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Incoming Email,Technical Support</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.ProfileId</field>
            <operation>notEqual</operation>
            <value>8-TSE Team</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.UserRoleId</field>
            <operation>notEqual</operation>
            <value>Director of Customer Service</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.ProfileId</field>
            <operation>notEqual</operation>
            <value>10-SP CS Administrator</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.ProfileId</field>
            <operation>notEqual</operation>
            <value>10a-Outsource Support</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Priority</field>
            <operation>notEqual</operation>
            <value>P1 - Urgent</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Severity__c</field>
            <operation>notEqual</operation>
            <value>P1- Urgent</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.ContactEmail</field>
            <operation>notEqual</operation>
            <value>support@salesforce.com</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>notEqual</operation>
            <value>Closed,Closed-Unresolved,Completed,Expired</value>
        </criteriaItems>
        <description>Notify TSE team when a customer portal users creates a case</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>NewITHelpRequests</fullName>
        <actions>
            <name>ChangeOwner4ITRequests</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>SetStatus</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>1</booleanFilter>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>IT Help Requests</value>
        </criteriaItems>
        <description>New IT Requests</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>NewLabHelpRequests</fullName>
        <actions>
            <name>ChangeOwner4ITRequests</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>SetStatus</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <booleanFilter>1</booleanFilter>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Lab Help Requests</value>
        </criteriaItems>
        <description>New Lab Requests</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Notice to Account Team</fullName>
        <actions>
            <name>AccountTeamNotification</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <formula>AND( 
NOT( ISCHANGED( UpdatedBy__c )), 
NOT(RecordType.DeveloperName = &quot;IT_Help_Requests&quot;),
NOT(RecordType.DeveloperName = &quot;HR_Requests&quot;),
NOT(RecordType.DeveloperName = &quot;Facilities&quot;),
NOT(RecordType.DeveloperName = &quot;Lab_Help_Requests&quot;),
NOT(RecordType.DeveloperName = &quot;DevOps_Help_Requests&quot;),
NOT(RecordType.DeveloperName = &quot;Perf_Help_Requests&quot;)
)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Notification to Csr Answer1 when its assigned to Tier1</fullName>
        <actions>
            <name>SendNewCaseNotification2CSR</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <booleanFilter>(1 OR 2) AND 3 And 4</booleanFilter>
        <criteriaItems>
            <field>Case.Severity__c</field>
            <operation>notEqual</operation>
            <value>P1- Urgent</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Priority</field>
            <operation>notEqual</operation>
            <value>P1 - Urgent</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Incoming Email,Technical Support</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.OwnerId</field>
            <operation>equals</operation>
            <value>Tier1</value>
        </criteriaItems>
        <description>When a case is assigned to Tier 1, send a notification to csr answer1</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>NotifyQueueOwner</fullName>
        <actions>
            <name>CaseOwnershipChanged</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>Notify the Tech Support Queue email - back up to the unchecked owner transfer from Tier1 Queue</description>
        <formula>AND (ISCHANGED( OwnerId),  
OR (
PRIORVALUE( OwnerId) = &apos;00G500000016yiB&apos;,
PRIORVALUE( OwnerId) = &apos;00530000000j42G&apos;
),
NOT( Contact.Testing__c )
)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Perf Help - Customer Case Comments</fullName>
        <actions>
            <name>PerfHelp_Case_Comments</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Update_Case_Field</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Perf Help Requests</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.UpdatedBy__c</field>
            <operation>equals</operation>
            <value>Customer</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Perf Help - Owner Case Comments</fullName>
        <actions>
            <name>PerfHelp_Case_Comments</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Update_Case_Field</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Perf Help Requests</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.UpdatedBy__c</field>
            <operation>equals</operation>
            <value>Owner</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>PerfHelpRequests- Case Opened</fullName>
        <actions>
            <name>PerfHelp_Case_Opened</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>ChangeOwner4PerfHelpRequests</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>SetStatus</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Perf Help Requests</value>
        </criteriaItems>
        <description>New PerfHelp Requests</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Priority when Case Opened</fullName>
        <actions>
            <name>Get_Case_Opened_Priority</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Contact.mkto_si__Priority__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Incoming Email,WANstart,Technical Support</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>RemoveAllowRMAFlagonAssetChange</fullName>
        <actions>
            <name>Disable_RMA_Flag</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>AND ( ISCHANGED( AssetId ), Allow_RMA__c  )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>SEActivate_WANstart_cases</fullName>
        <actions>
            <name>set_start_date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>when the status changes to active, set start date</description>
        <formula>ISPICKVAL( Status , &quot;In Progress&quot;)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>expire_wanstart_case</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>Case.End_Date__c</offsetFromField>
            <timeLength>1</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Setup Google CC</fullName>
        <actions>
            <name>Setup_Google_CC</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Incoming Email,Technical Support</value>
        </criteriaItems>
        <criteriaItems>
            <field>Account.Name</field>
            <operation>contains</operation>
            <value>Google</value>
        </criteriaItems>
        <description>add silverpeak@google.com to CC12</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Severity 1 Case</fullName>
        <actions>
            <name>NewHighPriorityCaseiscreated</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>NewHighPriorityCaseiscreated4CSR1</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>SendToTier1Queue</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>(1 OR 2) AND 3 AND (4 AND 5 AND 6)</booleanFilter>
        <criteriaItems>
            <field>Case.Severity__c</field>
            <operation>equals</operation>
            <value>P1- Urgent</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Priority</field>
            <operation>equals</operation>
            <value>P1 - Urgent</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Incoming Email,Technical Support</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.ProfileId</field>
            <operation>notEqual</operation>
            <value>8-TSE Team</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.ProfileId</field>
            <operation>notEqual</operation>
            <value>8a-TSE Manager</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.ProfileId</field>
            <operation>notEqual</operation>
            <value>3-SP Sys Admin</value>
        </criteriaItems>
        <description>When Severity S1 or Priority P1 case is opened or changed,, send an email to Escalation Engineering and Management team</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Support - Case Opened</fullName>
        <actions>
            <name>SetVisibleInPortalFlag</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Incoming Email,Technical Support</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Support - Customer Case Comments</fullName>
        <actions>
            <name>Email_Support_Customer_Case_Comments</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Update_Case_Field</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Incoming Email,Technical Support,WANstart</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.UpdatedBy__c</field>
            <operation>equals</operation>
            <value>Customer</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Support - Owner Case Comments</fullName>
        <actions>
            <name>Email_Support_Owner_Case_Comment</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Update_Case_Field</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Incoming Email,Technical Support,WANstart</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.UpdatedBy__c</field>
            <operation>equals</operation>
            <value>Owner</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Support Case 30 mins Notification-1</fullName>
        <actions>
            <name>Case_Notification_TimeStamp</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 AND 2 AND (3 OR 4) AND 5</booleanFilter>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Incoming Email,Technical Support</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.IsClosed</field>
            <operation>notEqual</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.OwnerId</field>
            <operation>equals</operation>
            <value>Tier1</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.OwnerId</field>
            <operation>equals</operation>
            <value>Csr Answer1</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Support_Case_30_min_Notification__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Send_Support_Case_Notification_to_CSR_Team</name>
                <type>Alert</type>
            </actions>
            <actions>
                <name>Support_Case_30_min_Notification1_True</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>Case.Case_Notification_TimeStamp__c</offsetFromField>
            <timeLength>1</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Support Case 30 mins Notification-2</fullName>
        <actions>
            <name>Case_Notification_TimeStamp</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 AND 2 AND (3 OR 4) AND 5</booleanFilter>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Incoming Email,Technical Support</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.IsClosed</field>
            <operation>notEqual</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.OwnerId</field>
            <operation>equals</operation>
            <value>Tier1</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.OwnerId</field>
            <operation>equals</operation>
            <value>Csr Answer1</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Support_Case_30_min_Notification__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Send_Support_Case_Notification_to_CSR_Team</name>
                <type>Alert</type>
            </actions>
            <actions>
                <name>Support_Case_30_min_Notification1_False</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>Case.Case_Notification_TimeStamp__c</offsetFromField>
            <timeLength>1</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Update Case CC Email</fullName>
        <actions>
            <name>Update_Case_CC_10_Email</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>AND( OR( ISBLANK( CC10__c ), ISCHANGED( ContactId ) ), NOT(ISBLANK( Contact.AccountId ))    )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Update Case Status to In Process</fullName>
        <actions>
            <name>Update_Case_Status_to_In_Process</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Pending Customer Feedback,Pending Customer Verification</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Incoming Email,WANstart,Technical Support</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.UpdatedBy__c</field>
            <operation>equals</operation>
            <value>Customer</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>UpdatePartnerNoticeEmail</fullName>
        <actions>
            <name>SetPartnerEmailFromText</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Incoming Email,Technical Support</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>dispatch to level 1</fullName>
        <actions>
            <name>NewHighPriorityCaseiscreated</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Case.Priority</field>
            <operation>equals</operation>
            <value>P1 - Urgent</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Incoming Email,Technical Support</value>
        </criteriaItems>
        <description>Dispatch a case to level 1 when customer chooses P1</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <tasks>
        <fullName>CaseOpen5Days</fullName>
        <assignedToType>creator</assignedToType>
        <description>The case associated to this task has been open for five days.</description>
        <dueDateOffset>2</dueDateOffset>
        <notifyAssignee>true</notifyAssignee>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>Not Started</status>
        <subject>Case Open 5 Days</subject>
    </tasks>
</Workflow>
