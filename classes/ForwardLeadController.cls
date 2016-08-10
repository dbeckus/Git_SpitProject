/*
 * the controller for visualforce page ForwardLead 
 */
public class ForwardLeadController
{
    private String temporaryLeadId;
    
    public ForwardLeadController()
    {
        String opptyId = ApexPages.currentPage().getParameters().get('id');
        if(opptyId != null)
        {
            List<Opportunity> opps = [select AccountId, Account.Name, Name, Deal_Forward__c, Project_Name__c, Project_Description__c, Forwarded_Lead_Id__c from Opportunity where Id = : opptyId ];
            oppty = opps[0];
            List<Contact> optionNames;
            String accountId = oppty.AccountId;
            if(optionNames == null)
            {
                optionNames = [select Id, LastName, FirstName from Contact where AccountId = :accountId];
                if(optionNames.size() < 1)
                {
                    IsPanelShow = true;
                    IsFormShow = false;
                }
                else
                {
                    IsPanelShow = false;
                    IsFormShow = true;
                }
            }
        }
    }
    
    public String NewOwnerId { get; set; }    
    public String NewOwner { get; set; }     
    public String RecordTypeId { get; set; }    
    public String ContactValue { get; set; }     
    public Boolean EmailStatus { get; set; }    
    public Boolean IsPanelShow { get; set; }
    public Boolean IsFormShow { get; set; }
    public Opportunity oppty{ get; set; }
    
    //get the contactName and populate the selectList component
    public List<SelectOption> getContactItems()
    {
        List<SelectOption> options = new List<SelectOption>();
        List<Contact> optionNames;
        if(oppty != null)
        {
            String accountId = oppty.AccountId;
            if(optionNames == null)
            {
                optionNames = [select Id, Name from Contact where AccountId = :accountId];
                if(optionNames.size() > 0)
                {
                    for(Contact c : optionNames)
                    {
                        options.add(new SelectOption(String.valueOf(c.Id), c.Name));
                    }
                }
            }
        }
        return options;
    }
    
    //get the recordType and populate the selectList component
    public List<SelectOption> getTypeItems()
    {
        List<SelectOption> options = new List<SelectOption>();
        List<RecordType> optionTypes;
        if(optionTypes == null)
        {
            optionTypes = [select Id, Name from RecordType where sobjectType = 'lead'];
        }
        for(RecordType r : optionTypes)
        {
            options.add(new SelectOption(String.valueOf(r.Id), r.Name));
        }
        return options;
    }
     
    //action invoke methods  
    public PageReference forward()
    {
        if(NewOwnerId == null || NewOwnerId == '' )
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'please select a new owner!!'));
            return null;
        }
        String leadId = createLeadId(); 
        if(leadId != null)
        {
            if(oppty != null)
            {
                oppty.Deal_Forward__c = true;
                oppty.Forwarded_Lead_ID__c = leadId;
                try
                {
                    update oppty;
                    redirectToLead(leadId);
                }
                catch(DmlException ex)
                {
                    ApexPages.addMessages(ex);
                    return null;
                }
            }   
        }
        return null;
    }
    
    //redirects the opener page to lead, and closes self page
    private void redirectToLead(String leadId)
    {
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Forwarding succeeded. <script>opener.location="/'+leadId+'";setTimeout("self.close()", 2000);</script>'));
    }
    
    //create lead
    private String createLeadId()
    {
        Lead retLead = new Lead(Id=temporaryLeadId);
        List <Contact> contacts = [select firstName, lastName, phone, title, email from contact where id = : ContactValue];
        if(contacts.size() > 0)
        {
            if(oppty != null)
            {
                retLead.OpportunityName__c = oppty.Name;
                retLead.Company = oppty.Account.Name;
                retLead.Project_Name__c = oppty.Project_Name__c;
                retLead.Project_Description__c = oppty.Project_Description__c;  
            }
            retLead.RecordTypeId = RecordTypeId;
            retLead.FirstName = contacts[0].FirstName;
            retLead.LastName = contacts[0].LastName;
            retLead.Phone = contacts[0].Phone;
            retLead.Title = contacts[0].Title;
            retLead.Email = contacts[0].Email;  
            retLead.Deal_Forward__c = true;
            retLead.OwnerId = NewOwnerId; 
            retLead.Email_New_Owner__c = EmailStatus;
            try
            {
                upsert retLead;
                temporaryLeadId = retLead.Id;
            }
            catch(DmlException ex)
            {
                ApexPages.addMessages(ex);
                return null;
            }
        }
        return retLead.Id;
    }
    
    @isTest
    static void testForwardLeadController()
    {
         Account acc = new Account(Name='acme');
         insert acc;
         Contact contact = new Contact(LastName='acme', AccountId=acc.Id);
         insert contact;
         Opportunity opp = new Opportunity(Name='acme', StageName='Open', CloseDate=Date.today(), AccountId=acc.Id, ForecastCategoryName='Pipeline');
         insert opp;
         PageReference page = new PageReference('/apex/ForwardLead?id=' + opp.Id);
         Test.setCurrentPage(page);
         
         ForwardLeadController controller = new ForwardLeadController();
         controller.NewOwnerId = UserInfo.getUserId();
         controller.ContactValue = contact.Id;
         System.assertEquals(1, controller.getContactItems().size());
         System.assert(controller.getTypeItems() != null);
         System.assert(controller.forward() == null);    
	}
    
}