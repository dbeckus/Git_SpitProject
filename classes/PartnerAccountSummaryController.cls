public class PartnerAccountSummaryController {
    public boolean IsDistributor{get;set;}
    public Account PartnerAccount{get;set;}
    private final integer  limitSize =50;
    public string ShippingAddress{get;set;}
    public string BillingAddress{get;set;}
    public Contact LoggedinContact{get;set;}
    public List<OpportunityWrapper> OpenOppsList{get;set;}
    public List<Lead> PendingDealReg{get;set;}
    public List<Lead> RejectedDealReg{get;set;}
    public List<Opportunity> RenewalOppsList {get;set;}
    public AccountTeamMemberInfo AcctTeamInfo {get;set;}
    public List<Contact> PartnerContacts{get;set;}
    public List<Asset> PartnerAssets{get;set;}
    public List<Case> PartnerCases{get;set;}
    public PartnerAccountSummaryController()
    {
        SetInitialData();
    }
    
    private void SetInitialData()
    {
        PartnerAccount= new Account();
        AcctTeamInfo= new AccountTeamMemberInfo();
        PendingDealReg= new List<Lead>();
        OpenOppsList= new List<OpportunityWrapper>();
        RenewalOppsList= new List<Opportunity>();
        PartnerContacts = new List<Contact>();
        PartnerAssets= new List<Asset>();
        PartnerCases= new List<Case>();
        string loggedinUser= UserInfo.getUserId();
        User usrDtl=[Select ContactId,UserRole.Name,Profile.Name from User where Id=:loggedinUser LIMIT 1];
        if(usrDtl!=null && usrDtl.ContactId!=null)
        {
            
            string roleName= usrDtl.UserRole.Name;
            string profName= usrDtl.Profile.Name;
            IsDistributor= profName=='13g-SP Distributor Community';
            LoggedinContact=[Select Id, AccountId from Contact where Id=:usrDtl.ContactId];
            if(LoggedinContact!=null && LoggedinContact.AccountId!=null)
            {
                PartnerAccount = [Select Id,Parent.Name,Name,Type,Phone,Website,Fax,Renewal_Contact__r.Name,Partner_Type__c,Owner.Name,ShippingStreet,ShippingCity,ShippingState,ShippingCountry,ShippingPostalCode,BillingStreet,BillingCity,BillingState,BillingCountry,BillingPostalCode,Partner_Level__c,Reseller_Agreement__c,Standard_Discount_EdgeConnect__c,Standard_Discount_Product__c,Standard_Discount_Service__c,Registered_Discount_EdgeConnect__c,Registered_Discount_Product__c,Registered_Discount_Service__c from Account where Id=:LoggedinContact.AccountId];
                ShippingAddress= FormatAddress(PartnerAccount.ShippingStreet,PartnerAccount.ShippingCity,PartnerAccount.ShippingState,PartnerAccount.ShippingPostalCode,PartnerAccount.ShippingCountry);
                BillingAddress= FormatAddress(PartnerAccount.BillingStreet,PartnerAccount.BillingCity,PartnerAccount.BillingState,PartnerAccount.BillingPostalCode,PartnerAccount.BillingCountry);
                AcctTeamInfo=PopulateTeamMember();
                List<Opportunity> lstOpp=new List<Opportunity>();
                System.debug(roleName);
                System.debug(profName);
                if(IsDistributor)
                {
                    if(roleName!=null && roleName.contains('Partner Manager'))
                    {
                        lstOpp=[Select Id,Name,CloseDate,Owner.Name,StageName,Amount,ForecastCategoryName,Registering_Partner__r.Name,Registering_Partner_Sales_Rep__r.Name ,(select Id from Requests__r where IsClosed__c=false) from opportunity where Registered_Distributor__c=:PartnerAccount.Id and Type in ('New Business','Follow on Business')and IsClosed=false];
                        PendingDealReg=[Select Id,Name,Company,Registered_Partner__c,Registered_Partner__r.Name,Registered_Partner_Sales_Rep__r.Name,Status,RSM__r.Name,CSM__r.Name,Registration_Expiration__c,Deal_ID__c from Lead where Registered_Distributor__c=:PartnerAccount.Id and Status in ('Draft','Submitted') and LeadSource='Deal Registration'];
                        RejectedDealReg=[Select Id,Name,Company,Registered_Partner__c,Registered_Partner__r.Name,Registered_Partner_Sales_Rep__r.Name,Status,RSM__r.Name,CSM__r.Name,Registration_Expiration__c,Deal_ID__c from Lead where Registered_Distributor__c=:PartnerAccount.Id and Status in ('Approved','Rejected') and LeadSource='Deal Registration'];
                        RenewalOppsList=[Select Id,Name,CloseDate,Owner.Name,StageName,Amount,ForecastCategoryName,Registering_Partner__r.Name,Registering_Partner_Sales_Rep__r.Name,Next_Step_Reporting__c from opportunity where Registered_Distributor__c=:PartnerAccount.Id and Type = 'Support Renewal' and IsClosed=false];
                    }
                    else
                    {
                        lstOpp=[Select Id,Name,CloseDate,Owner.Name,StageName,Amount,ForecastCategoryName,Registering_Partner__r.Name,Registering_Partner_Sales_Rep__r.Name ,(select Id from Requests__r where IsClosed__c=false) from opportunity where Registered_Distributor_Contact__c=:LoggedinContact.Id and Type in ('New Business','Follow on Business')and IsClosed=false];
                        PendingDealReg=[Select Id,Name,Company,Registered_Partner__c,Registered_Partner__r.Name,Registered_Partner_Sales_Rep__r.Name,Status,RSM__r.Name,CSM__r.Name,Registration_Expiration__c,Deal_ID__c from Lead where Registered_Distributor_Contact__c=:LoggedinContact.Id and Status in ('Draft','Submitted') and LeadSource='Deal Registration'];
                        RejectedDealReg=[Select Id,Name,Company,Registered_Partner__c,Registered_Partner__r.Name,Registered_Partner_Sales_Rep__r.Name,Status,RSM__r.Name,CSM__r.Name,Registration_Expiration__c,Deal_ID__c from Lead where Registered_Distributor_Contact__c=:LoggedinContact.Id and Status in ('Approved','Rejected') and LeadSource='Deal Registration'];
                        RenewalOppsList=[Select Id,Name,CloseDate,Owner.Name,StageName,Amount,ForecastCategoryName,Registering_Partner__r.Name,Registering_Partner_Sales_Rep__r.Name,Next_Step_Reporting__c from opportunity where Registered_Distributor_Contact__c=:LoggedinContact.Id and Type = 'Support Renewal' and IsClosed=false];
                    }
                }
                else
                {
                    if(roleName!=null && roleName.contains('Partner Manager'))
                    {
                        lstOpp=[Select Id,Name,CloseDate,Owner.Name,StageName,Amount,ForecastCategoryName,Registering_Partner__r.Name,Registering_Partner_Sales_Rep__r.Name ,(select Id from Requests__r where IsClosed__c=false) from opportunity where Registering_Partner__c=:PartnerAccount.Id and Type in ('New Business','Follow on Business')and IsClosed=false];
                        PendingDealReg=[Select Id,Name,Company,Registered_Partner__c,Registered_Partner__r.Name,Registered_Partner_Sales_Rep__r.Name,Status,RSM__r.Name,CSM__r.Name,Registration_Expiration__c,Deal_ID__c from Lead where Registered_Partner__c=:PartnerAccount.Id and Status in ('Draft','Submitted') and LeadSource='Deal Registration'];
                        RejectedDealReg=[Select Id,Name,Company,Registered_Partner__c,Registered_Partner__r.Name,Registered_Partner_Sales_Rep__r.Name,Status,RSM__r.Name,CSM__r.Name,Registration_Expiration__c,Deal_ID__c from Lead where Registered_Partner__c=:PartnerAccount.Id and Status in ('Approved','Rejected') and LeadSource='Deal Registration'];
                        RenewalOppsList=[Select Id,Name,CloseDate,Owner.Name,StageName,Amount,ForecastCategoryName,Registering_Partner__r.Name,Registering_Partner_Sales_Rep__r.Name,Next_Step_Reporting__c from opportunity where Registering_Partner__c=:PartnerAccount.Id and Type = 'Support Renewal' and IsClosed=false];
                    }
                    else
                    {
                        
                        lstOpp=[Select Id,Name,CloseDate,Owner.Name,StageName,Amount,ForecastCategoryName,Registering_Partner__r.Name,Registering_Partner_Sales_Rep__r.Name ,(select Id from Requests__r where IsClosed__c=false) from opportunity where Registering_Partner__c=:PartnerAccount.Id and Registering_Partner_Sales_Rep__c=:LoggedinContact.Id and Type in ('New Business','Follow on Business')and IsClosed=false];
                        PendingDealReg=[Select Id,Name,Company,Registered_Partner__c,Registered_Partner__r.Name,Registered_Partner_Sales_Rep__r.Name,Status,RSM__r.Name,CSM__r.Name,Registration_Expiration__c,Deal_ID__c from Lead where Registered_Partner__c=:PartnerAccount.Id and Registered_Partner_Sales_Rep__c=:LoggedinContact.Id and Status in ('Draft','Submitted') and LeadSource='Deal Registration'];
                        RejectedDealReg=[Select Id,Name,Company,Registered_Partner__c,Registered_Partner__r.Name,Registered_Partner_Sales_Rep__r.Name,Status,RSM__r.Name,CSM__r.Name,Registration_Expiration__c,Deal_ID__c from Lead where Registered_Partner__c=:PartnerAccount.Id and Registered_Partner_Sales_Rep__c=:LoggedinContact.Id and Status in ('Approved','Rejected') and LeadSource='Deal Registration'];
                        RenewalOppsList=[Select Id,Name,CloseDate,Owner.Name,StageName,Amount,ForecastCategoryName,Registering_Partner__r.Name,Registering_Partner_Sales_Rep__r.Name,Next_Step_Reporting__c from opportunity where Registering_Partner__c=:PartnerAccount.Id and Registering_Partner_Sales_Rep__c=:LoggedinContact.Id and Type = 'Support Renewal' and IsClosed=false];
                    }
                }
                
                if(lstOpp!=null && lstOpp.size()>0)
                {
                    for(Opportunity opp: lstOpp)
                    {
                        List<Request__c> lstPocs=opp.Requests__r;
                        boolean isDisabled=false;
                        if(lstPocs!=null && lstPocs.size()>0)
                        {isDisabled=true;}
                        OpenOppsList.add(new OpportunityWrapper(false,isDisabled,opp));
                    }
                }
                
                PartnerContacts=[Select Id, Name, Title,Email, Phone,CanAllowPortalSelfReg from Contact where AccountId=:PartnerAccount.Id ];
                PartnerAssets=[Select Id, Name, SerialNumber,InstallDate, Quantity,Contact.Name,Status, IsCompetitorProduct from Asset where AccountId=:PartnerAccount.Id];
                PartnerCases=[Select Id, CaseNumber, Contact.Name,Subject, Priority,CreatedDate,Status,Owner.Name,IsClosed from Case where AccountId=:PartnerAccount.Id and IsClosed=false];
                System.debug('Contact'+PartnerContacts.size());
                System.debug('Assets'+PartnerAssets.size());
                System.debug('Cases'+PartnerCases.size());
                System.debug('Open Opps'+OpenOppsList.size());
                System.debug('Renewal Opps'+RenewalOppsList.size());
                System.debug('Pending Deal Opps'+PendingDealReg.size());
            }
        }
    }
    
    
    public ApexPages.StandardSetController cases_setCon {
        get {
            if(cases_setCon == null) {
                cases_setCon = new ApexPages.StandardSetController(PartnerCases);
            }
            return cases_setCon;
        }
        set;
    }
    
    // Initialize setCon and return a list of records
    public List<Case> getCases() {
        cases_setCon.setpagesize(limitSize);
        return (List<Case>) cases_setCon.getRecords();
    }
    public ApexPages.StandardSetController assets_setCon {
        get {
            if(assets_setCon == null) {
                assets_setCon = new ApexPages.StandardSetController(PartnerAssets);
            }
            return assets_setCon;
        }
        set;
    }
    
    // Initialize setCon and return a list of records
    public List<Asset> getAssets() {
        assets_setCon.setpagesize(limitSize);
        return (List<Asset>) assets_setCon.getRecords();
    }
    
    public ApexPages.StandardSetController contacts_setCon {
        get {
            if(contacts_setCon == null) {
                contacts_setCon = new ApexPages.StandardSetController(PartnerContacts);
            }
            return contacts_setCon;
        }
        set;
    }
    
    // Initialize setCon and return a list of records
    public List<Contact> getContacts() {
        contacts_setCon.setpagesize(limitSize);
        return (List<Contact>) contacts_setCon.getRecords();
    }
    private AccountTeamMemberInfo PopulateTeamMember()
    {
        AccountTeamMemberInfo accInfo= new AccountTeamMemberInfo();
        List<AccountteamMember> acctTeamMemberInfo= [Select UserId,User.Name,TeamMemberRole from AccountteamMember where AccountId=:PartnerAccount.Id and TeamMemberRole in('Account Manager','Systems Engineer','Inside Sale Representative')];
        if(acctTeamMemberInfo!=null && acctTeamMemberInfo.size()>0)
        {
            for(AccountteamMember member:acctTeamMemberInfo)
            { 
                if(member.TeamMemberRole=='Inside Sale Representative')
                {
                    accInfo.InsideSalesMgr= member.User.Name;
                }
                if(member.TeamMemberRole=='Systems Engineer')
                {
                    accInfo.SystemsEngineer= member.User.Name;
                }
                if(member.TeamMemberRole=='Account Manager')
                {
                    accInfo.ChannelManager= member.User.Name;
                }
            }
        }
        
        
        return accInfo;
    }
    private string FormatAddress(string street,string city,string state,string country,string postalCode)
    {
        List<string> lstData= new List<String>();
        string address='';
        if(!String.isBlank(street))
        { lstData.add(street);}
        if(!String.isBlank(city))
        { lstData.add(city);}
        if(!String.isBlank(state))
        { lstData.add(state);}
        if(!String.isBlank(postalCode))
        { lstData.add(postalCode);}
        if(!String.isBlank(country))
        { lstData.add(country);}
        
        if(lstData.size()>0)
        {
            for(string d:lstData)
            {
                address= address+ d +', ';
            }
        }
        if(!string.isBlank(address))
        {
            address= address.substring(0,address.lastIndexOf(','));
        }
        
        return address;
    }
    public PageReference RequestTrial()
    {
        Map<Id,Opportunity> setOppIds= new Map<Id,Opportunity>();
        
        
        for(OpportunityWrapper opp: OpenOppsList)
        {
            if(opp.ischecked)
            {
                setOppIds.put(opp.oppWrapper.Id,opp.oppWrapper);
            }
        }  
        if(setOppIds.size()==0)
        {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.FATAL, 'Please select atleast one opportunity to request a trial.'); 
            ApexPages.addMessage(myMsg);               
        }
        else
        {
            //do initial validations
            List<Request__c>lstPOCs= new List<Request__c>();
            for(Id oppId: setOppIds.keyset())
            {
                Opportunity opp= setOppIds.get(oppId);
                Request__c req= new Request__c();
                req.Opportunity__c=opp.id;
                //req.POC_Contact__c=LoggedinContact.Id;
                insert req;
                List<string> toAddress=new List<string>();
                List<OpportunityteamMember> lstSETeamMember=[Select UserId,User.email,TeamMemberRole from OpportunityteamMember where opportunityId=:opp.Id and TeamMemberRole in('Systems Engineer')];
                List<OpportunityteamMember> lstOtherTeamMember=[Select UserId,User.email,TeamMemberRole from OpportunityteamMember where opportunityId=:opp.Id and TeamMemberRole in('Account Manager','Channel Manager')];
                if(lstOtherTeamMember!=null && lstOtherTeamMember.size()>0)
                {
                    for(OpportunityteamMember member:lstOtherTeamMember)
                    {
                        toAddress.add(member.UserId);
                    }
                    
                }
                List<User> adamUserInfo=[Select Id from User where Name='Adam Fuoss' and IsActive=true and UserType='Standard'];
                if(adamUserInfo!=null && adamUserInfo.size()>0)
                {
                    toAddress.add(adamUserInfo[0].Id);
                }
                //toAddress.add('005500000046uFt');
                //System.debug(toAddress);
                List<EmailTemplate> template = [select Id from EmailTemplate where Name='POC Trial Request Intiated' limit 1];
                if(template.size() > 0)
                {
                    if(!Test.isRunningTest())
                    {
                        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                        email.setTemplateId(template[0].Id);
                        email.setWhatId(req.Id);
                        email.setTargetObjectId(lstSETeamMember[0].UserId);
                        //email.setToAddresses();
                        email.setCcAddresses(toAddress);
                        email.setsaveAsActivity(false);
                        Id orgWideEmail = SilverPeakUtils.getOrganizationWideEmailId('notifications@silver-peak.com');
                        if(orgWideEmail != null)
                        {
                            email.setOrgWideEmailAddressId(orgWideEmail);
                        }
                        Messaging.sendEmail(new List<Messaging.Email> {email}, true);
                    }
                }
            }
            
            
            
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.INFO, 'A trial has been requested for the selected opportunities.'); 
            ApexPages.addMessage(myMsg);     
            SetInitialData();
        }
        
        return null;
    }
    
    public class OpportunityWrapper
    {
        public boolean IsChecked{get;set;}
        public boolean isDisabled{get;set;}
        public Opportunity oppWrapper{get;set;}
        public OpportunityWrapper(boolean isChecked,boolean isDisabled,Opportunity opp)
        {
            this.isChecked =isChecked;
            this.isDisabled =isDisabled;
            this.oppWrapper=opp;
        }
    }
    
    public class AccountTeamMemberInfo
    {
        public string ChannelManager{get;set;}
        public string SystemsEngineer{get;set;}
        public string InsideSalesMgr{get;set;}
        
    }
}