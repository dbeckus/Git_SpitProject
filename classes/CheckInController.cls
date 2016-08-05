/**
 * Controller of pages Check-In, RegisterWalkIn
 */
public class CheckInController 
{
    private String campaignId = ApexPages.currentPage().getParameters().get('id');
    private List<LeadInfo> leads;
    private Integer pageSize = 800;
    
    public CheckInController()
    {
        WalkInLead = new Lead();
        pageCount = 1;
        try
        {
            pageIndex = Integer.valueOf(ApexPages.currentPage().getParameters().get('page'));
        }
        catch(Exception ex)
        {
            pageIndex = 1;
        }
        if(!(campaignId instanceOf Id))
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Campaign not found.'));
        }
        else
        {
            Integer memberCount = [select count() from CampaignMember where CampaignId=:campaignId];
            PageCount = Math.ceil(memberCount * 1.0 / PageSize).intValue();
        }
    }
    public Integer PageCount { get; set; }
    public Integer PageIndex { get; set; }
    
    public String campaignName
    {
        get
        {
            return campaign.Name;
        }
    }
    
    public Campaign campaign
    {
        get
        {
            if(campaignId instanceOf Id)
            {
                Campaign camp = [select Name, StartDate, EndDate from Campaign where Id = :campaignId limit 1];
                return camp;
            }
            return null;
        }
    }
    
    public List<LeadInfo> Attendees
    {
        get
        {
            if(leads == null)
            {
                leads = new List<LeadInfo>();
                List<Lead> targets = new List<Lead>();
                if(PageCount <= 1)
                {
                    targets = [select Name, Do_Not_Tele_Qualify__c, Email, Phone, Send_To_RSM__c, LastCampaignRegisteredAttended__c, Description, Company, Title, Survey_FU__c, Survey_FU_Note__c, Last_Mkt_Campaign__c,
                                (select Status from CampaignMembers where CampaignId=:campaignId limit 1)
                                 from Lead where Id in (select LeadId from CampaignMember where CampaignId=:campaignId) and IsConverted = false order by Name limit 1000];
                }
                else
                {
                    ApexPages.StandardSetController setCtrl = new ApexPages.StandardSetController(Database.getQueryLocator([select Name, Do_Not_Tele_Qualify__c, Email, Phone, Send_To_RSM__c, LastCampaignRegisteredAttended__c, Description, Company, Title, Survey_FU__c, Survey_FU_Note__c, Last_Mkt_Campaign__c, 
                                                                 (select Status from CampaignMembers where CampaignId=:campaignId limit 1)
                                                                 from Lead where Id in (select LeadId from CampaignMember where CampaignId=:campaignId) and IsConverted = false order by Name]));
                    setCtrl.setPageSize(pageSize);
                    setCtrl.setPageNumber(pageIndex);
                    targets = (List<Lead>)setCtrl.getRecords();
                }
                for(Lead item : targets)
                {
                    leads.add(new LeadInfo(item));
                }
            }
            return leads;
        }
    }
    
    public Lead WalkInLead { get; set; }
    public String WalkInLeadNote { get; set; }
    
    public PageReference save()
    {
        List<Lead> updatedLeads = new List<Lead>();
        for(LeadInfo info : Attendees)
        {
            if(info.isLCRAA && !info.OriginalIsLCRAA)
            {
                Lead lead = new Lead(Id=info.LeadId);
                lead.Description = getNewLeadDescription(info.LastMktCampaign, info.CheckinNote, info.Description);
                lead.LastCampaignRegisteredAttended__c = true;
                updatedLeads.add(lead);
            }
        }
        
        try
        {
            update updatedLeads;
            leads = null;
            List<CampaignMember> members = [select Id, Status from Campaignmember where CampaignId=:campaignId and LeadId!=null and LeadId in :updatedLeads];
            for(CampaignMember member : members)
            {
                member.Status = 'Attended';
            }
            update members;
        }
        catch(Exception ex)
        {
            ApexPages.addMessages(ex);
        }
        return null;
    }
    
    public PageReference savefu()
    {
        List<Lead> updatedLeads = new List<Lead>();
        for(LeadInfo info : Attendees)
        {
            Lead lead = new Lead(Id=info.LeadId);
            if(info.SendToRSM)
            {
                lead.Send_To_RSM__c = true;
            }
            lead.survey_FU_Note__c = info.SurveyNote; 
            if(info.DoNotCall)
            {
                lead.Do_Not_Tele_Qualify__c = true;
            }
            updatedLeads.add(lead);
        }
        
        try
        {
            update updatedLeads;
            leads = null;
        }
        catch(Exception ex)
        {
            ApexPages.addMessages(ex);
        }
        return null;
    }
    
    public PageReference saveWalkIn()
    {
        try
        {
            List<Lead> existingLeads = [select Id, FirstName, LastName, Title, Company, Email, Phone, Description from Lead where Email=:WalkInLead.Email and IsConverted=false limit 1];
            if(existingLeads.size() >= 1)
            {
                WalkInLead = existingLeads[0];
            }
            else
            {
                WalkInLead.LeadSource = 'Web- Contact us';
                WalkInLead.Last_Mkt_Campaign__c = campaign.Name;
                insert WalkInLead;
            }
            
            WalkInLead.LastCampaignRegisteredAttended__c = true;
            WalkInLead.Description = getNewLeadDescription(campaign.Name, WalkInLeadNote, WalkInLead.Description);
            update WalkInLead;
            CampaignMember member = new CampaignMember(CampaignId=campaignId, LeadId=WalkInLead.Id, Status='Attended');
            insert member;
            return new PageReference('/CheckIn?id=' + campaignId);
        }
        catch(Exception ex)
        {
            ApexPages.addMessages(ex);
            return null;
        }
    }
    
    private static String getNewLeadDescription(String lastCampaign, String note, String priorDescription)
    {
        String result = 'ATTENDED: ' + lastCampaign + ' ' + System.today().format() + ' ' + note;
        if(priorDescription != null && priorDescription != '')
        {
            result += '\r\nPRIOR Notes: ' + priorDescription;
        }
        if(result.length() > 32000)
        {
            result = result.substring(0, 32000);
        }
        return result;
    }
    
    public class LeadInfo
    {
        public LeadInfo(Lead lead)
        {
            this.LeadId = lead.Id;
            if(lead.CampaignMembers.size() > 0)
            {
                this.OriginalIsLCRAA = (lead.CampaignMembers[0].Status == 'Responded' || lead.CampaignMembers[0].Status == 'Attended');
            }
            else
            {
                this.OriginalIsLCRAA = false;
            }
            this.IsLCRAA = this.OriginalIsLCRAA;
            this.CheckinNote = '';
            this.SurveyNote = '';
            this.Name = lead.Name;
            this.Email = lead.Email;
            this.Phone = lead.Phone;
            this.Company = lead.Company;
            this.SendToRSM = lead.Send_To_RSM__c == true;
            this.OriginalSendToRSM = lead.Send_To_RSM__c == true;
            this.DoNotCall = lead.Do_Not_Tele_Qualify__c;
            this.Title = lead.Title;
            this.HasSurveyFU = lead.Survey_FU__c;
            this.OriginalHasSurveyFU = lead.Survey_FU__c;
            this.LastMktCampaign = (lead.Last_Mkt_Campaign__c == null) ? '' : lead.Last_Mkt_Campaign__c;
            this.Description = (lead.Description == null) ? '' : lead.Description;
        }
    
        public Id LeadId { get; set; }
        public String Name { get; set; }
        public String Email { get; set; }
        public String Phone { get; set; }
        public String Company { get; set; }
        public String Title { get; set; }
        public Boolean SendToRSM { get; set; }
        public Boolean OriginalSendToRSM { get; set; }
        public Boolean DoNotCall { get; set; }
        public Boolean OriginalIsLCRAA { get; set; }
        public Boolean IsLCRAA { get; set; }
        public Boolean OriginalHasSurveyFU { get; set; }
        public Boolean HasSurveyFU { get; set; }
        public String CheckinNote { get; set; }
        public String SurveyNote { get; set; }
        public String LastMktCampaign { get; set; }
        public String Description { get; set; }
    }
    
    @isTest
    public static void testCheckInController()
    {
        List<RecordType> recordTypes = [select Id from RecordType where Name = 'Deal Registration' and SObjectType = 'Lead' and IsActive = true];
        if(!recordTypes.isEmpty())
        {
            Lead lead = new Lead(LastName = 'test', Company = 'test', RecordTypeId = recordTypes[0].Id, LastCampaignRegisteredAttended__c = false, Survey_FU__c = false);
            insert lead;
            
            Campaign campaign = new Campaign(Name = 'test', Type = 'Email', Status = 'Planned');
            insert campaign;
            
            CampaignMember campaignMember = new CampaignMember(LeadId = lead.Id, CampaignId = campaign.Id);
            insert campaignMember;
            
            CheckInController noCampaignId = new CheckInController();
            
            PageReference currentPage = new PageReference('/apex/checkin?id=' + campaign.Id);
            Test.setCurrentPage(currentPage);
            CheckInController controller = new CheckInController();
            System.assertEquals(campaign.Name, controller.campaignName);
            if(controller.Attendees.size() > 0)
            {
                controller.Attendees[0].isLCRAA = true;
            }
            controller.save();
            
            if(controller.Attendees.size() > 0)
            {
                controller.Attendees[0].HasSurveyFU = true;
            }
            controller.savefu();
            controller.saveWalkIn();
        }
    }
}