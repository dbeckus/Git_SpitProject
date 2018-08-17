public class FindContactReferences {
    
    List<Case> lstCases = new List<Case>();
    List<Request__c> lstPOCRequests = new List<Request__c>();
    List<Opportunity> lstOpportunities = new List<Opportunity>();
    List<Opportunity> lstOppContactroles = new List<Opportunity>();
    List<Quote__c> lstQuotes = new List<Quote__c>();
    List<Lead> lstLeads = new List<Lead>();
    List<Contract> lstContracts = new List<Contract>();
    List<Shipment__c> lstShipments = new List<Shipment__c>();
    List<Asset> lstAssets = new List<Asset>();
    List<Purchase_Order__c> lstPurchaseOrders = new List<Purchase_Order__c>();
    List<RMA__c> lstRMAs = new List<RMA__c>();
    List<Rma_Item__c> lstRMAItems = new List<RMA_Item__c>();
    List<MDF_Request__c> lstFundingRequests = new List< MDF_Request__c>();
    List<License__c> lstLicenses = new List<License__c>(); 
    List<LMS_Course_Certification__c> lstLMSCourseCerts= new List< LMS_Course_Certification__c>();
    List<Information_Card__c> lstInformationCards = new List<Information_Card__c>(); 
    List<Account> lstContactRefAccounts = new List<Account>();
    
    public FindContactReferences()
    {
        Id contactId = ApexPages.currentPage().getParameters().get('id');
        
        if(contactId != null)
        {
            lstCases = [Select CaseNumber, Contact.Id, Contact.Name, Status, RecordType.Name from Case where Contact.Id =:contactId];
            lstPOCRequests = [Select Name, POC_Contact__r.Name, Status__c, Type__c from Request__c where POC_Contact__r.Id =:contactId];
            lstOpportunities = [Select Name, StageName, Registered_Distributor_Contact__r.Name, Registering_Partner_Sales_Rep__r.Name from Opportunity where Registered_Distributor_Contact__r.Id =:contactId or Registering_Partner_Sales_Rep__r.Id =:contactId];
            lstOppContactroles = [Select Name, StageName, (Select OpportunityId From OpportunityContactRoles) From Opportunity where id in (Select OpportunityId From OpportunityContactRole where ContactId =:contactId)];
            lstQuotes = [Select Name, Opportunity__r.Name, PreparedFor__r.Name from Quote__c where PreparedFor__r.Id =:contactId];
            LstLeads = [Select Name, Deal_Registration_Reseller_Contact__r.Name, Registered_Distributor_Contact__r.Name, Registered_Partner_Sales_Rep__r.Name from Lead where Deal_Registration_Reseller_Contact__r.Id =:contactId or Registered_Distributor_Contact__r.Id =:contactId or Registered_Partner_Sales_Rep__r.Id =:ContactId];
            lstContracts = [Select ContractNumber, CustomerSigned.Name, Customer_Addl_Notices__r.Name, Customer_Addl_Notices_2__r.Name, Reseller_Addl_Notices__r.Name from Contract where CustomerSigned.Id =:contactId or Customer_Addl_Notices__r.Id =:contactId or Customer_Addl_Notices_2__r.Id =:contactId or Reseller_Addl_Notices__r.Id =:contactId];
            lstShipments = [Select Name, Shipment_Contact__r.Name from Shipment__c where Shipment_Contact__r.Id =:contactId];
            lstAssets = [Select Name, Contact.Name, Shipment_Contact__r.Name from Asset where Contact.Id =:contactId or Shipment_Contact__r.Id =:contactId];
            lstPurchaseOrders = [Select Name, Email_Contact__r.Name from Purchase_order__c where Email_Contact__r.Id =:contactId];
            lstRMAs = [Select Name, Status__c, Contact__r.Name, Contact_Loc_1__r.Name, Contact_Loc_2__r.Name, Contact_Loc_3__r.Name, Contact_Loc_4__r.Name from RMA__c where Contact__r.Id=:contactId or Contact_Loc_1__r.Id=:contactId or Contact_Loc_2__r.Id=:contactId or Contact_Loc_3__r.Id=:contactId or Contact_Loc_4__r.Id=:contactId];
            lstRMAItems = [Select Name, Ship_To_Contact__r.Name from RMA_Item__c where Ship_To_Contact__r.Id =:contactId];
            lstFundingRequests = [Select Name, Contact__r.Name, Submitter__r.Name from MDF_Request__c where Contact__r.Id =:contactId or Submitter__r.Id =:contactId];
            lstLicenses = [Select Name, Contact_for_Notification__r.Name from License__c where Contact_for_Notification__r.Id =:contactId];
            lstLMSCourseCerts = [Select Name, Learner_Contact__r.Name from LMS_Course_Certification__c where Learner_Contact__r.Id =:contactId];
            lstInformationCards = [Select Name, MarketingPartnerContact__r.Name, PrimaryPartnerContact__r.Name, RegisteringUserContact__r.Name, SignatoryPartnerContact__r.Name from Information_Card__c where MarketingPartnerContact__r.Id=:contactId or PrimaryPartnerContact__r.Id=:contactId or RegisteringUserContact__r.Id=:contactId or SignatoryPartnerContact__r.Id=:contactId];
            lstContactRefAccounts = [Select Name, Dell_Contact__r.Name, EMC_Contact__r.Name, HDS_Contact__r.Name, MarketingPartnerContact__r.Name, PrimaryPartnerContact__r.Name,
                                     RegisteringUserContact__r.Name, Renewal_Contact__r.Name, SignatoryPartnerContact__r.Name, Support_Contact1__r.Name, Support_Contact2__r.Name,
                                     Support_Contact3__r.Name, VAR1_Contact__r.Name, VAR2_Contact__r.Name from Account where Dell_Contact__r.Id=:contactId or EMC_Contact__r.Id=:contactId or
                                     HDS_Contact__r.Id=:contactId or MarketingPartnerContact__r.Id=:contactId or PrimaryPartnerContact__r.Id=:contactId or
                                     RegisteringUserContact__r.Id=:contactId or Renewal_Contact__r.Id=:contactId or SignatoryPartnerContact__r.Id=:contactId or Support_Contact1__r.Id=:contactId or
                                     Support_Contact2__r.Id=:contactId or Support_Contact3__r.Id=:contactId or VAR1_Contact__r.Id=:contactId or VAR2_Contact__r.Id=:contactId];                  
        }
    }
    
    public List<Case> getlstCases()
    {
        return lstCases;
    }
    
    public List<Lead> getLstLeads()
    {
        return LstLeads;
    }
    
    public List<Request__c> getlstPOCRequests()
    {
        return lstPOCRequests;
    }
    
    public List<Opportunity> getlstOpportunities()
    {
        return lstOpportunities;
    }
    
    public List<Opportunity> getlstOppContactroles()
    {
        return lstOppContactroles;
    }
    
    public List<Quote__c> getlstQuotes()
    {
        return lstQuotes;
    }
    
    public List<Contract> getlstContracts()
    {
        return lstContracts;
    }
    
    public List<Shipment__c> getlstShipments()
    {
        return lstShipments;
    }
    
    public List<Asset> getlstAssets()
    {
        return lstAssets;
    }
    
    public List<Purchase_Order__c> getlstPurchaseOrders()
    {
        return lstPurchaseOrders;
    }
    
    public List<RMA__c> getlstRMAs()
    {
        return lstRMAs;
    }
    
    public List<RMA_Item__c> getlstRMAItems()
    {
        return lstRMAItems;
    }
    
    public List<MDF_Request__c> getlstFundingRequests()
    {
        return lstFundingRequests;
    }
    
    public List<License__c> getlstLicenses()
    {
        return lstLicenses;
    }
    
    public List<LMS_Course_Certification__c> getlstLMSCourseCerts()
    {
        return lstLMSCourseCerts;
    }
    
    public List<Information_Card__c> getlstInformationCards()
    {
        return lstInformationCards;
    }
    
    public List<Account> getlstContactRefAccounts()
    {
        return lstContactRefAccounts;
    }
    
    
}