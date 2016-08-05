public class LMSFetchCertificationDetailsBatch implements Database.Batchable<sObject>,Database.Stateful, Database.AllowsCallouts{
    private  Integer recordCount = 0;
    public Database.QueryLocator start(Database.BatchableContext context)
    {
        return Database.getQueryLocator([Select Id,Certification_ID__c,Course_Id__c from LMS_Course_Certification__c where Status_Display_Name__c='Sync Pending']);
    }
    
    public void execute(Database.BatchableContext context, List<sObject> scope)
    {
        List<LMS_Course_Certification__c> lstCertificatesDtl= (List<LMS_Course_Certification__c>) scope;
        
        List<LMS_Course_Certification__c> lstCertToUpdate= new List<LMS_Course_Certification__c>();
        string token=null;
        if(Test.isRunningTest())
        {
            token='****';
        }
        if(lstCertificatesDtl!=null && lstCertificatesDtl.size()>0)
        {
            recordCount += lstCertificatesDtl.size();
            for(LMS_Course_Certification__c item: lstCertificatesDtl)
            {
                
                PartnerPortalGetCourseCertificateApi courseCertAPI = new PartnerPortalGetCourseCertificateApi(item.Certification_ID__c,String.valueOf(item.Course_Id__c),token);
                courseCertAPI.execute();
                if(courseCertAPI.CourseCertificate!=null)
                {
                    PartnerPortalCourseCertficate cert= courseCertAPI.CourseCertificate;
                    item.Certification_Title__c= cert.Title;
                    item.Status__c= cert.Status;
                    item.Student_Id__c= cert.studentsId;
                    item.Expiry_Date__c= Date.valueOf(cert.expires);
                    item.Validity_Date__c= Date.valueOf(cert.valid);
                    string statusDisp= cert.StatusDisplay;
                    if(String.isBlank(statusDisp))
                    {
                        statusDisp='Sync Complete';
                    }
                    else if(item.Expiry_Date__c<Date.today())
                    {
                        statusDisp='Expired';
                    }
                    else
                    {  
                        statusDisp='Active';
                    }
                    item.Status_Display_Name__c=statusDisp ;
                    lstCertToUpdate.add(item);
                } 
            }
        }
        
        try
        {
            if(lstCertToUpdate.size()>0)
            {
                
                update lstCertToUpdate;
                
            }
        }
        catch(Exception ex)
        {
            SilverPeakUtils.logException(ex);
        }
    }
    
    public void finish(Database.BatchableContext context)
    {
        insert new ErrorLog__c(Subject__c='LMS Certifications Sync Pending ', Message__c='There are ' + recordCount + ' certifications in sync Pending status.');
        LMSBatchHelper.AssociateContactwithEachCertUsingStudentId();
        LMSBatchHelper.AssociateContactwithEachCertUsingStudentEmail();
        List<LMS_Course_Certification__c> lstCertWithNoEmail= [Select Id,Learner_Contact__c,Student_Id__c from LMS_Course_Certification__c where Learner_Contact__c=null and Student_Email__c=null];
        if(lstCertWithNoEmail!=null && lstCertWithNoEmail.size()>0)
        {
            insert new ErrorLog__c(Subject__c='LMS Certifications By Email ', Message__c='There are ' + lstCertWithNoEmail.size() + ' certifications populated by email.');
        }
       	LMSAssociateLearnerContactByEmail obj = new LMSAssociateLearnerContactByEmail();
        Database.executeBatch(obj,1);
        
    }
}