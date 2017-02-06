public class PartnerMDFListingController {
    public list<MDF_Request__c> Requests{ get; set; }
    public PartnerMDFListingController()
    {
        User currentUser = [select Id, Contact.AccountId from User where Id=:userInfo.getUserId() limit 1];
        Requests = [Select Id, Name,Type_of_Program__c , Event_Campaign_Name__c, Activity_Date__c, Activity_Complete__c, Partner_Account__c, GEO__c, 
                    MDF_Status__c, Approval_Status__c from MDF_Request__c where Account__c=:currentUser.Contact.AccountId order by Activity_Date__c Desc NULLS LAST];
    }
}