@IsTest
public class TestLMSUpdateCertExpiredSchedule {
    
    @IsTest
    public static void UpdateExpiredRecords()
    {
        LMS_Course__c course= new LMS_Course__c(Course_Id__c='233333',Course_Name__c='Test Course',Display_Name__c='Test Course Display Name',Is_Active__c=true);
        insert course;
        LMS_Course_Certification__c cert= new LMS_Course_Certification__c(Certification_ID__c='123232323',LMS_Course_Id__c=course.Id,Status_Display_Name__c='Active',Expiry_Date__c=Date.today().addDays(-1));
        insert cert;
        LMSUpdateCertExpiredSchedule obj= new LMSUpdateCertExpiredSchedule();
        obj.execute(null);
        LMS_Course_Certification__c certResult=[Select Status_Display_Name__c from LMS_Course_Certification__c where Id=:cert.Id ];
        System.assertEquals('Expired',certResult.Status_Display_Name__c);
    }
    
}