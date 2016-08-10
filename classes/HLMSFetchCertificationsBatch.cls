public class HLMSFetchCertificationsBatch implements  Database.Batchable<sObject>,Database.Stateful,Database.AllowsCallouts
{
    public Database.QueryLocator start(Database.BatchableContext context)
    {
        return Database.getQueryLocator([Select Id,New_Course_Id__c,Last_Fetch_Date__c,Course_Name__c from LMS_Course__c where Is_Active__c=true]);
    }
    public void execute(Database.BatchableContext context, List<sObject> scope)
    { 
        List<LMS_Course__c> lstCourses= (List<LMS_Course__c>)scope;
        string token=null;
        Map<Id,List<HPartnerPortalCertificate>> mapCourseData= new  Map<Id,List<HPartnerPortalCertificate>>();
        List<LMS_Course__c>lstCourseToUpdate= new List<LMS_Course__c>();
        
        for(LMS_Course__c course : lstCourses)
        {
            //Fetch all the certifications for each course
            Date fetchDate= course.Last_Fetch_Date__c;
            if(fetchDate!=null)
            {
                fetchDate=fetchDate.addDays(1);
            }
            // Fetch all the certification details 
            try
            {
                
                if(Test.isRunningTest())
                {
                    token='****';
                }
                else
                {
                    token=HPartnerPortalSSOStub.getHttpToken();
                }
                HPartnerPortalGetCertificatesApi courseGradeAPI = new HPartnerPortalGetCertificatesApi(String.valueOf(course.New_Course_Id__c),token,fetchDate);
                courseGradeAPI.execute();
                if(courseGradeAPI.isSucceed)
                {
                    System.debug('success');
                    if(courseGradeAPI.Certificates!=null && courseGradeAPI.Certificates.size()>0)
                    { 
                        for(HPartnerPortalCertificate cert:courseGradeAPI.Certificates)
                        {
                            cert.courseId= course.New_Course_Id__c;
                        }
                        mapCourseData.put(course.Id,courseGradeAPI.Certificates);
                    }  
                    if(fetchDate==null)
                    {fetchDate=Date.today();}
                    lstCourseToUpdate.add(new LMS_Course__c(Id=course.Id,Last_Fetch_Date__c=fetchDate));
                }
            }
            catch(Exception ex)
            {
                System.debug(ex);
                SilverPeakUtils.logException(ex);
                continue;
            }
        }
        System.Savepoint sp= Database.setSavepoint();
        try
        {
            
            if(lstCourseToUpdate.size()>0)
            {
                update lstCourseToUpdate;
            }
            System.debug('mapCourseData.size()'+mapCourseData.size());
            if(mapCourseData.size()>0)
            {
              
                LMSBatchHelper.H_InsertCertificationData(mapCourseData);
            }
        }
        catch(Exception ex)
        {
            Database.rollback(sp);
            SilverPeakUtils.logException(ex);
        }
        
        
    }  
    
    public void finish(Database.BatchableContext context)
    {
        HLMSFetchUserDetailsBatch obj= new HLMSFetchUserDetailsBatch();
        Database.executeBatch(obj,1);
       
    }
}