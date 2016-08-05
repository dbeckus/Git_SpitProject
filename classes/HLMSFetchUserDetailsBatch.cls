public class HLMSFetchUserDetailsBatch implements Database.Batchable<sObject>,Database.Stateful,Database.AllowsCallouts
{
    public Database.QueryLocator start(Database.BatchableContext context)
    {
        return Database.getQueryLocator([Select Id,Enrollment_Id__c,LMS_User_Id__c from  LMS_Course_Certification__c where LMS_User_Id__c=null and Enrollment_Id__c!=null]);
    }
    public void execute(Database.BatchableContext context, List<sObject> scope)
    { 
        List<LMS_Course_Certification__c> lstCerts =(List<LMS_Course_Certification__c>) scope;
        if(lstCerts.size()>0)
        {
            for(LMS_Course_Certification__c item:lstCerts)
            {
                HPartnerPortalGetEnrollementDetailsApi obj= new HPartnerPortalGetEnrollementDetailsApi(item.Enrollment_Id__c,'');
                obj.execute();
                if(obj.isSucceed)
                {
                    HPartnerPortalEnrollment enroll=obj.Enrollement;
                    item.LMS_User_Id__c=enroll.UserId;
                    if(item.LMS_User_Id__c!=null)
                    {
                        HPartnerPortalGetUserDetailsApi obj1= new HPartnerPortalGetUserDetailsApi(item.LMS_User_Id__c,'');
                        obj1.execute();
                        if(obj1.isSucceed)
                        {
                            HPartnerPortalUser usrInfo=obj1.UserInfo;
                            item.Student_Email__c=usrInfo.EmailAddress;
                        }
                    }
                    
                }
                
            }
            System.Savepoint sp= Database.setSavepoint();
            try
            {
                
                update lstCerts;
            }
            catch(Exception ex)
            {
                Database.rollback(sp);
                SilverPeakUtils.logException(ex);
            }
            
        }
        
    }  
    
    public void finish(Database.BatchableContext context)
    {
        
        // Associate Certification with Contact
        LMSBatchHelper.H_AssociateContactUsingUserId();
        // Associate Certiifcation with Email Address.
        LMSBatchHelper.H_AssociateContactUsingEmailAddress();
    }
}