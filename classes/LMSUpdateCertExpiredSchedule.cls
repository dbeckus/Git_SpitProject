public class LMSUpdateCertExpiredSchedule implements Schedulable {
    public void execute(SchedulableContext context)
    {
        List<LMS_Course_Certification__c> lstCertificatesDtl=[ Select Id,Certification_ID__c,Course_Id__c from LMS_Course_Certification__c where Status_Display_Name__c='Active' and Expiry_Date__c<:Date.today()];
        List<LMS_Course_Certification__c> lstCertificatesToUpdate = new List<LMS_Course_Certification__c>();
        if(lstCertificatesDtl!=null && lstCertificatesDtl.size()>0)
        {
            for(LMS_Course_Certification__c cert:lstCertificatesDtl)
            {
                cert.Status_Display_Name__c='Expired';
                lstCertificatesToUpdate.add(cert);
            }
        }
        if(lstCertificatesToUpdate.size()>0)
        {
            update lstCertificatesToUpdate;
        }
    }
}