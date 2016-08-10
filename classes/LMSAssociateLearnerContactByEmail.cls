public class LMSAssociateLearnerContactByEmail implements Database.Batchable<sObject>,Database.Stateful,Database.AllowsCallouts {
    public Database.QueryLocator start(Database.BatchableContext context)
    {
        return Database.getQueryLocator([Select Id,Learner_Contact__c,Student_Id__c from LMS_Course_Certification__c where Learner_Contact__c=null and Student_Email__c=null]);
    }
    
    public void execute(Database.BatchableContext context, List<sObject> scope)
    {
        Map<string,PartnerPortalStudentInfoResult> mapStudentInfoApi= new  Map<string,PartnerPortalStudentInfoResult>();
        Set<String> lstStudentIds= new Set<String>();
        PartnerPortalGetStudentInformationApi studentAPI =null;
        List<LMS_Course_Certification__c> lstCert= (List<LMS_Course_Certification__c>)scope;
        string token=null;
        if(Test.isRunningTest())
        {
            token='****';
        }
        if(lstCert!=null && lstCert.size()>0)
        {
            for(LMS_Course_Certification__c item : lstCert)
            {
                lstStudentIds.add(string.valueof(item.Student_Id__c));
            }
            for(string studId: lstStudentIds)
            {
                // call get studentAPI
                studentAPI= new PartnerPortalGetStudentInformationApi(studId,token);
                studentAPI.execute();
                mapStudentInfoApi.put(studId,studentAPI.studentInfo);
            }     
        }
        
        List<String> lstEmailIds= new List<String>();
        List<LMS_Course_Certification__c> lstCertToUpdate= new List<LMS_Course_Certification__c>(); 
        Map<String,Id> mapContacts= new Map<String,Id>();
        
        if(lstCert!=null && lstCert.size()>0)
        {
            for(LMS_Course_Certification__c item : lstCert)
            {
                if(mapStudentInfoApi.size()>0)
                {
                    PartnerPortalStudentInfoResult studInfoAPI =mapStudentInfoApi.get(string.valueOf(item.Student_Id__c));
                    item.Student_Email__c= studInfoAPI.Email;
                    lstEmailIds.add(studInfoAPI.Email);
                }
            }
            update lstCert;
            if(lstEmailIds.size()>0)
            {
                List<Contact> lstContact= [Select Id,Email from Contact where Email in: lstEmailIds];
                if(lstContact!=null && lstContact.size()>0)
                {
                    for(Contact con:lstContact)
                    {
                        mapContacts.put(con.email,con.Id);
                    }
                    
                    for(LMS_Course_Certification__c item : lstCertToUpdate)
                    {
                        if(item.Student_Email__c!=null && !String.isBlank(item.Student_Email__c))
                        {
                            Id contactId=  mapContacts.get(item.Student_Email__c);
                            item.Learner_Contact__c= contactId;
                            lstCertToUpdate.add(item);
                        }
                    }
                    if(lstCertToUpdate.size()>0)
                    {
                        update lstCertToUpdate;
                    }
                    
                }
            }
            
        }
    }
    
    public void finish(Database.BatchableContext context)
    {
        LMSBatchHelper.PopulateAccountForContact();
    }
}