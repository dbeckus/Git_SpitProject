/*
 *    Controller of Page NewOpportunity
 */
public class NewOpportunityController 
{
    public NewOpportunityController(ApexPages.StandardController controller) 
    {
        IsStep1 = true;
        CurrentOpportunity = new Opportunity();
        LeadAndContacts = new List<LeadAndContact>();
        Email = '';
    }
    
    public List<LeadAndContact> LeadAndContacts { get; set; }
    public String Email { get; set; }
    public String LeadSource { get; set; }
    public String AccountSource { get; set; }
    public String ContactSource { get; set; }
    public Lead CurrentLead { get; set; }
    public Opportunity CurrentOpportunity { get; set; }
    public Boolean IsStep1 { get; set; }
    public String LeadConvertStatus { get; set; }
    public List<SelectOption> LeadStatusOptions 
    { 
        get
        {
            List<SelectOption> options = new List<SelectOption>();
            List<LeadStatus> convertStatus = [select Id, MasterLabel from LeadStatus where IsConverted = true order by SortOrder];
            for(LeadStatus status : convertStatus)
            {
                options.add(new SelectOption(status.MasterLabel, status.MasterLabel));
            }
            return options;
        }
    }
    
    public PageReference search()
    {
        LeadAndContacts.clear();
        String temp = '%' + Email + '%';
        if(Email != '')
        {
            for(Lead lead : [select Id, Name, Email from Lead where Email like :temp and IsConverted = false order by Name limit 10])
            {
                LeadAndContacts.add(new LeadAndContact('Lead', lead.Id, lead.Name, lead.Email, null, null));
            }
            for(Contact contact : [select Id, Name, Email, AccountId, Account.Name from Contact where Email like :temp order by Name limit 10])
            {
                LeadAndContacts.add(new LeadAndContact('Contact', contact.Id, contact.Name, contact.Email, contact.AccountId, contact.Account.Name));
            }
        }
        
        return null;
    }
    
    public PageReference next()
    {
        IsStep1 = false;
        User currentUser = [select Id, Default_TR__c from User where Id = :UserInfo.getUserId() limit 1];
        CurrentOpportunity.OwnerId = currentUser.Id;
        CurrentOpportunity.Technical_Responsible__c = currentUser.Default_TR__c;
        CurrentOpportunity.StageName = 'Discovery';
        CurrentOpportunity.Probability = 5;
        CurrentOpportunity.CloseDate = Date.today().addDays(120);
    
        if(LeadSource != 'new')
        {
            String leadSql = 'select ';
            for(Schema.SObjectField sobjectField : Schema.SObjectType.Lead.Fields.getMap().values())
            {
                leadSql += sobjectField.getDescribe().getName() + ', ';
            }
            leadSql = leadSql.subString(0, leadSql.length() - 2);
            List<SObject> leads = Database.query(leadSql + ' from Lead where Id = \'' + LeadSource + '\' limit 1');
            CurrentLead = (leads.size() > 0) ? (Lead)leads[0] : new Lead(OwnerId=currentUser.Id);
        }
        else if(ContactSource == 'new')
        {
            CurrentLead = new Lead();
            CurrentLead.OwnerId = currentUser.Id;
        }
        
        if(AccountSource != 'new')
        {
            CurrentOpportunity.AccountId = AccountSource;
            List<Account> accounts = [select Id, Name from Account where Id = :AccountSource limit 1];
            if(accounts.size() > 0)
            {
                CurrentOpportunity.Name = accounts[0].Name + '-';
                if(LeadSource != 'new' || (LeadSource == 'new' && ContactSource == 'new'))
                {
                    CurrentLead.Company = accounts[0].Name;
                }
            }
        }
        
        return null;
    }
    
    public PageReference prev()
    {
        IsStep1 = true;
        return null;
    }
    
    public Pagereference save()
    {
        //if creating a new contact, a lead should be created
        if(ContactSource == 'new')
        {
            Opportunity opp = convertLead();
            if(opp != null)
            {
                return new PageReference('/' + opp.Id);
            }
        }
        else
        {
            try
            {
                upsert CurrentOpportunity;
                OpportunityContactRole oppContactRole = new OpportunityContactRole(OpportunityId = Currentopportunity.Id, ContactId = ContactSource);
                upsert oppContactRole;
                return new PageReference('/' + CurrentOpportunity.Id);
            }
            catch(Exception e)
            {
                ApexPages.addMessages(e);
                return null;
            }
        }
        
        return null;
    }
    
    public Pagereference saveAndNew()
    {
        PageReference result = save();
        PageReference newPage = Page.NewOpportunity;
        newPage.getParameters().put('retURL', '/006/o');
        newPage.setRedirect(true);
        return (result == null) ? null : newPage;
    }
    
    @RemoteAction
    public static List<Contact> pushContacts(String AccountId)
    {
        return [select Id, Name from Contact where AccountId = :AccountId order by Name limit 100];
    }
    
    private Opportunity convertLead()
    {
        SavePoint sp = Database.setSavePoint();
        Database.LeadConvert lc = new Database.LeadConvert();
        Opportunity opp = new Opportunity();
        try
        {
            upsert CurrentLead;
            lc.setLeadId(CurrentLead.Id);
            if(AccountSource != 'new')
            {
                lc.setAccountId(AccountSource);
            }
            lc.setConvertedStatus(LeadConvertStatus);
            Database.LeadConvertResult lcr = Database.convertLead(lc);
            if(lcr.IsSuccess())
            {
                opp = new Opportunity(Id = lcr.getOpportunityId());
                for(Schema.SObjectField sobjectField : Schema.SObjectType.Opportunity.Fields.getMap().values())
                {
                    if(CurrentOpportunity.get(sobjectField) != null)
                    {
                        opp.put(sobjectField, CurrentOpportunity.get(sobjectField));
                    }
                }
                update opp;
            }
            else
            {
                String errorMessage = '';
                for(Database.Error error : lcr.getErrors())
                {
                    errorMessage += error.getMessage() + '\r\n';
                }
                throw new LeadConvertException(errorMessage);
            }
        }
        catch(Exception e)
        {
            Database.rollback(sp);
            ApexPages.addMessages(e);
            return null;
        }
        
        return opp;
    }
    
    public class LeadAndContact
    {
        public LeadAndContact(String type, String id, String name, String email, String accountId, String accountName)
        {
            this.Type = type;
            this.Id = id;
            this.Name = name;
            this.Email = email;
            this.AccountId = accountId;
            this.AccountName = accountName;
        }
        
        public String Type { get; set; }
        public String Id { get; set; }
        public String Name { get; set; }
        public String Email { get; set; }
        public String AccountId { get; set; }
        public String AccountName { get; set; }
    }
    
    public class LeadConvertException extends Exception {}
}