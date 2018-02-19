public class AssociateLMSCertificateWithContact implements Schedulable {
    
    public void execute(SchedulableContext sc)
    {
        List<LMS_Course_Certification__c> lstCerts=[Select Id,LMS_User_Id__c,Student_Email__c from  LMS_Course_Certification__c where (LMS_User_Id__c!=null or Student_Email__c!=null) and Learner_Contact__c=null and IsActive__c=true];
        List<LMS_Course_Certification__c> lstCertStudentId= new List<LMS_Course_Certification__c>();
        List<LMS_Course_Certification__c> lstCertStudentEmail= new List<LMS_Course_Certification__c>();
        if(lstCerts!=null && lstCerts.size()>0)
        {
            
            for(LMS_Course_Certification__c cert:lstCerts)
            {
                if(cert.LMS_User_Id__c!=null)
                {
                    lstCertStudentId.add(cert);
                }
                if(cert.Student_Email__c!=null)
                {
                    lstCertStudentEmail.add(cert);
                }
            }
            // Associate Certification with Contact
            LMSBatchHelper.H_AssociateContactUsingUserId(lstCertStudentId);
            // Associate Certiifcation with Email Address.
            LMSBatchHelper.H_AssociateContactUsingEmailAddress(lstCertStudentEmail);
            
        }
        
    }
}