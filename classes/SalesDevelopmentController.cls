/*
 * Controller of page Sales Development
 */
public with sharing class SalesDevelopmentController
{
    public SalesDevelopmentController()
    {
        CampaignList = new List<SelectOption>();
        Campaign sdCampaign = null;
        SDCampaignId = SalesDevelopmentHelper.getSDcampaign();
        for(Campaign c : [select Id, Name from Campaign where Sales_Targeting__c=true])
        {
          if(c.Id != SDCampaignId)
          {
            CampaignList.add(new SelectOption(c.Id, c.Name));
          }
          else
          {
            sdCampaign = c;
          }
        }
        if(sdCampaign != null)
        {
          //makes sure SD campaign populates first in list
          if(CampaignList.size() > 0)
          {
              CampaignList.add(0, new SelectOption(sdCampaign.Id, sdCampaign.Name));
          }
          else
          {
              CampaignList.add(new SelectOption(sdCampaign.Id, sdCampaign.Name));
          }
        }
        if(CampaignList.size() > 0)
        {
            CampaignId = CampaignList[0].getValue();
        }
        TempLead = new Lead();
        ListViewOptions = new List<SelectOption>();
        ListViewOptions.add(new SelectOption('', 'All in Campaign'));
        ListViewOptions.add(new SelectOption('My Team\'s Leads', 'My Team\'s Leads'));
        ListViewOptions.add(new SelectOption('My Leads', 'My Leads'));
        ListView = 'My Team\'s Leads';
        SortingField = 'mqlDate';
        SortingAsc = false;
        PageSize = 50;
        PageIndex = 0;
        PageCount = 0;
        Records = new List<CampaignMemberInfo>();
        if(CampaignId != null)
        {
            refresh();
        }
    }

    public List<SelectOption> CampaignList { get; set; }
    public List<SelectOption> ListViewOptions { get; set; }
    public String ListView { get; set; }
    public String LifeCycleStage { get; set; }
    public String CampaignId { get; set; }
    public String SDCampaignId { get; private set; }
    public String SortingField { get; set; }
    public Boolean SortingAsc { get; set; }
    public CampaignMemberInfo[] Records { get; set; }
    public Lead TempLead { get; set; }
    public String SelectedIds { get; set; }
    public Integer PageIndex { get; set; }
    public Integer PageSize { get; set; }
    public Integer PageCount { get; set; }

    public List<SelectOption> PageOptions
    {
      get
      {
        List<SelectOption> result = new List<SelectOption>();
        for(Integer i = 0; i < PageCount; i++)
        {
          result.add(new SelectOption(String.valueOf(i), String.valueOf(i + 1)));
        }
        if(result.size() == 0)
        {
          result.add(new SelectOption('0', '1'));  
        }
        return result;
      }
    }

    public PageReference refresh()
    {
      retrieve();
      return null;
    }

    public PageReference refreshZero()
    {
      PageIndex = 0;
      return refresh();
    }
    
    public PageReference previousPage()
    {
      PageIndex = Math.max(0, PageIndex - 1);
      retrieve();
      return null;
    }

    public PageReference nextPage()
    {
      PageIndex = Math.min(PageCount, PageIndex + 1);
      retrieve();
      return null;
    }

    public PageReference updateStatus()
    {
        if(String.isBlank(SelectedIds))
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'You must select at least one record.'));
        }
        else
        {
            List<String> recordIds = SelectedIds.split(',');
            List<sObject> updatingRecords = new List<sObject>();
            for(String recordId : recordIds)
            {
                if(recordId.startsWith('00Q'))
                {
                    updatingRecords.add(new Lead(Id=recordId, Status=TempLead.Status, Lead_Sub_Status__c=TempLead.Lead_Sub_Status__c));
                }
                else
                {
                    updatingRecords.add(new Contact(Id=recordId, Lead_Status__c=TempLead.Status, Lead_Sub_Status__c=TempLead.Lead_Sub_Status__c));
                }
            }
            try
            {
                update updatingRecords;
                SelectedIds = '';
            }
            catch(Exception ex)
            {
                String errorMsg = 'Failed to update status. ';
                if(ex.getMessage().contains('ENTITY_IS_LOCKED'))
                {
                    errorMsg += 'One or more Lead(s)/Contact(s) you selected may be locked by approval process.';
                }
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, errorMsg));
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, ex.getMessage()));
            }
        }
        refresh();
        return null;
    }

    public PageReference updateOwner()
    {
        if(String.isBlank(SelectedIds))
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'You must select at least one record.'));
        }
        else
        {
            List<String> recordIds = SelectedIds.split(',');
            List<sObject> updatingRecords = new List<sObject>();
            for(String recordId : recordIds)
            {
                if(recordId.startsWith('00Q'))
                {
                    updatingRecords.add(new Lead(Id=recordId, OwnerId=TempLead.OwnerId));
                }
                else
                {
                    updatingRecords.add(new Contact(Id=recordId, OwnerId=TempLead.OwnerId));
                }
            }
            try
            {
                update updatingRecords;
                SelectedIds = '';
            }
            catch(Exception ex)
            {
                String errorMsg = 'Failed to update owner. ';
                if(ex.getMessage().contains('ENTITY_IS_LOCKED'))
                {
                    errorMsg += 'One or more Lead(s)/Contact(s) you selected may be locked by approval process.';
                }
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, errorMsg));
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, ex.getMessage()));
            }
        }
        refresh();
        return null;
    }

    public PageReference removeFromCampaign()
    {
        if(String.isBlank(SelectedIds))
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'You must select at least one record.'));
        }
        else
        {
            if(CampaignId == SDCampaignId)
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'You cannot remove a record from Sales Dev campaign.'));
                return null;
            }
            List<String> recordIds = SelectedIds.split(',');
            Set<String> recordIdsWithNoBlank = new Set<String>(recordIds);
            recordIdsWithNoBlank.remove(null);
            recordIdsWithNoBlank.remove('');
            
            try
            {
                delete [select Id from CampaignMember where CampaignId=:CampaignId and (LeadId in :recordIdsWithNoBlank or ContactId in :recordIdsWithNoBlank)];
                SelectedIds = '';
            }
            catch(Exception ex)
            {
                String errorMsg = 'Failed to remove from campaign. ';
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, errorMsg));
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, ex.getMessage()));
            }
        }
        refresh();
        return null;
    }
    
    private void retrieve()
    {
        String leadSoql = '', contactSoql = '';

        leadSoql = 'select Id, Name, Title, State,Country, Email, Phone, OwnerId, Owner.Name, Company, Status, Lead_Sub_Status__c, Lead_Lifecycle_Stage__c, Last_Mkt_Campaign__c, Last_Campaign_Type__c, MQL_Stage_Date__c from Lead where IsConverted = false and Id in (select LeadId from CampaignMember where CampaignId = :CampaignId)';
        contactSoql = 'select Id, Name, Title, MailingState, MailingCountry,Email, Phone, OwnerId, Owner.Name, AccountId, Account.Name, Account.Type, Lead_Status__c, Lead_Sub_Status__c, Lead_Lifecycle_Stage__c, Last_Marketing_Campaign__c, Last_Campaign_Type__c, MQL_Stage_Date__c from Contact where Id in (select ContactId from CampaignMember where CampaignId = :CampaignId)';
        
        List<Id> patchIds = new List<Id>();
        Id userId = UserInfo.getUserId();
        if(String.isNotEmpty(ListView))
        {
            patchIds = ListView.contains('Team') ? getMyTeamPatches() : getMyPatches();
            leadSoql += ' and (OwnerId=:userId or Patch__c in :patchIds)';
            contactSoql += ' and (OwnerId=:userId or Account.Patch__c in :patchIds)';
        }

        if(String.isNotEmpty(LifeCycleStage)&& LifeCycleStage!='MQL')
        {
            leadSoql += ' and Lead_Lifecycle_Stage__c like \'%' + LifeCycleStage + '%\'';
            contactSoql += ' and Lead_Lifecycle_Stage__c like \'%' + LifeCycleStage + '%\'';
        }
        if(String.isNotEmpty(LifeCycleStage) && LifeCycleStage=='MQL')
        {
            leadSoql += ' and (Lead_Lifecycle_Stage__c like \'%' + LifeCycleStage + '%\''+' or Lead_Lifecycle_Stage__c like \'%' + 'MQC' + '%\')';
            contactSoql += ' and (Lead_Lifecycle_Stage__c like \'%' + LifeCycleStage + '%\''+' or Lead_Lifecycle_Stage__c like \'%' + 'MQC' + '%\')';
        }

        leadSoql += ' limit 10000';
        contactSoql += ' limit 10000';
 		System.debug(leadSoql);
        System.debug(contactSoql);
        List<Lead> leads = Database.query(leadSoql);
        List<Contact> contacts = Database.query(contactSoql);
        List<CampaignMemberInfo> fullset = new List<CampaignMemberInfo>();
        Records = new List<CampaignmemberInfo>();
        for(Lead l : leads)
        {
          fullset.add(new CampaignMemberInfo(l, SortingField, SortingAsc));
        }
        for(Contact c : contacts)
        {
          fullset.add(new CampaignMemberInfo(c, SortingField, SortingAsc));
        }
        fullset.sort();
        for(Integer i = PageIndex * PageSize; i < fullset.size()  && i < (PageIndex + 1)* PageSize; i++)
        {
            Records.add(fullset[i]);
        }
        PageCount = (fullset.size() == 0) ? 0 : fullset.size() / PageSize + 1;

        fillContactOppInfo();
    }

    private List<Id> getMyPatches()
    {
        List<Id> result = new List<Id>();
        Id userId = UserInfo.getUserId();
        for(Patch__c p : [select Id from Patch__c where RSM__c=:userId])
        {
            result.add(p.Id);
        }
        return result;
    }

    private List<Id> getMyTeamPatches()
    {
        List<Id> result = new List<Id>();
        Id userId = UserInfo.getUserId();
        for(Patch__c p : [select Id from Patch__c where CSM__c=:userId or ISR__c=:userId or Owner__c=:userId or RSM__c=:userId or SE__c=:userId or Overlay_1__c=:userId or Overlay_2__c=:userId])
        {
            result.add(p.Id);
        }
        return result;
    }

    //Search open opportunities and contact roles.
    private void fillContactOppInfo()
    {
        Set<Id> accountIds = new Set<Id>();
        for(CampaignMemberInfo r : Records)
        {
            if(r.type == 'Contact')
            {
                accountIds.add(r.accountId);
            }
        }
        Map<String, Integer> accountId2OpenOppCount = new Map<String, Integer>();
        for(AggregateResult ar : [select AccountId, COUNT(Id)cnt from Opportunity where AccountId in :accountIds and IsClosed = false and Type!='Support Renewal' group by AccountId])
        {
            accountId2OpenOppCount.put((String)ar.get('AccountId'), (Integer)ar.get('cnt'));
        }
        Set<Id> contactRoleIds = new Set<Id>();
        for(OpportunityContactRole ocr : [select ContactId from OpportunityContactRole where Opportunity.AccountId in :accountIds and Opportunity.IsClosed = false and Opportunity.Type!='Support Renewal'])
        {
            contactRoleIds.add(ocr.ContactId);
        }
        for(CampaignMemberInfo r : Records)
        {
            if(r.type == 'Contact')
            {
                r.hasOpenOpps = accountId2OpenOppCount.get(r.accountId) > 0;
                r.isContactRole = contactRoleIds.contains(r.recordId);
            }
        }
    }

    public class CampaignMemberInfo implements Comparable
    {
        private String sortingField;
        private Boolean sortAsc;

        public CampaignMemberInfo(Contact ct, String sortField, Boolean sortAsc)
        {
            this.selected = false;
            this.recordId = ct.Id;
            this.name = ct.Name;
            this.type = 'Contact';
            this.accountId = ct.AccountId;
            this.accountName = ct.Account.Name;
            this.accountType = ct.Account.Type;
            this.lifecycleStage = ct.Lead_Lifecycle_Stage__c;
            this.status = ct.Lead_Status__c;
            this.substatus = ct.Lead_Sub_Status__c;
            this.ownerId = ct.OwnerId;
            this.ownerName = ct.Owner.Name;
            this.title = ct.Title;
            this.state = ct.MailingState;
            this.Country = ct.MailingCountry;
            this.phone = ct.Phone;
            this.email = ct.Email;
            this.lastMktCampaign = ct.Last_Marketing_Campaign__c;
            this.lastCampaignType = ct.Last_Campaign_Type__c;
            this.mqlDate = ct.MQL_Stage_Date__c;
            setSortingField(sortField, sortAsc);
        }

        public CampaignMemberInfo(Lead lead, String sortField, Boolean sortAsc)
        {
            this.selected = false;
            this.recordId = lead.Id;
            this.name = lead.Name;
            this.type = 'Lead';
            this.accountName = lead.Company;
            this.lifecycleStage = lead.Lead_Lifecycle_Stage__c;
            this.status = lead.Status;
            this.substatus = lead.Lead_Sub_Status__c;
            this.ownerId = lead.OwnerId;
            this.ownerName = lead.Owner.Name;
            this.title = lead.Title;
            this.state = lead.State;
            this.Country = lead.Country;
            this.email = lead.Email;
            this.phone = lead.Phone;
            this.lastMktCampaign = lead.Last_Mkt_Campaign__c;
            this.lastCampaignType = lead.Last_Campaign_Type__c;
            this.mqlDate = lead.MQL_Stage_Date__c;
            this.hasOpenOpps = false;
            this.isContactRole = false;
            setSortingField(sortField, sortAsc);
        }

        public Boolean selected { get; set; }
        public Id recordId { get; set; }
        public String name { get; set; }
        public String type { get; set; }
        public Id accountId { get; set; }
        public String accountName { get; set; }
        public String accountType { get; set; }
        public String status { get; set; }
        public String substatus { get; set; }
        public String lifecycleStage { get; set; }
        public Id ownerId { get; set; }
        public String ownerName { get; set; }
        public String title { get; set; }
        public String state { get; set; }
        public String Country { get; set; }
        public String email { get; set; }
        public String phone { get; set; }
        public String lastMktCampaign { get; set; }
        public String lastCampaignType { get; set; }
        public DateTime createdDate { get; set; }
        public DateTime mqlDate { get; set; }
        public Boolean hasOpenOpps { get; set; }
        public Boolean isContactRole { get; set; }
        
        public void setSortingField(String fieldName, Boolean sortAsc)
        {
            if(fieldName == 'name')
            {
                sortingField = name;
            }
            else if(fieldName == 'type')
            {
                sortingField = type;
            }
            else if(fieldName == 'accountName')
            {
                sortingField = accountName;
            }
            else if(fieldName == 'status')
            {
                sortingField = status;
            }
            else if(fieldName == 'title')
            {
                sortingField = title;
            }
            else if(fieldName == 'state')
            {
                sortingField = state;
            }
            else if(fieldName == 'email')
            {
                sortingField = email;
            }
            else if(fieldName == 'phone')
            {
                sortingField = phone;
            }
            else if(fieldName == 'lastMktCampaign')
            {
                sortingField = lastMktCampaign;
            }
            else if(fieldName == 'lastCampaignType')
            {
                sortingField = lastCampaignType;
            }
            else if(fieldName == 'accountType')
            {
                sortingField = accountType;
            }
            else if(fieldName == 'ownerName')
            {
                sortingField = ownerName;
            }
            else if(fieldName == 'country')
            {
                sortingField = Country;
            }
            else if(fieldName == 'mqlDate')
            {
                sortingField = (mqlDate == null) ? null : mqlDate.format('yyyy-MM-dd');
            }
            this.sortAsc = sortAsc;
        }

        public Integer compareTo(Object compareTo)
        {
            CampaignMemberInfo other = (CampaignMemberInfo)compareTo;
            if(this.sortingField == other.sortingField)
            {
                return 0;
            }
            else if(other.sortingField == null || this.sortingField > other.sortingField)
            {
                return sortAsc ? 1 : -1;
            }
            else
            {
                return sortAsc ? -1 : 1;
            }
        }
    }
}