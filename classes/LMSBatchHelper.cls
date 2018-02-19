public class LMSBatchHelper {
    
    public static void InsertCertificationData(Map<Id,List<PartnerPortalCertificate>> mapCertificates )
    {
        List<LMS_Course_Certification__c> lstCertToInsert= new List<LMS_Course_Certification__c>();
        if(mapCertificates!=null && mapCertificates.size()>0)
        {
            for(Id courseId:mapCertificates.keySet())
            {
                List<PartnerPortalCertificate> lstCerts = mapCertificates.get(courseId);
                for(PartnerPortalCertificate cert:lstCerts)
                {
                    LMS_Course_Certification__c sfCertData= new LMS_Course_Certification__c();
                    sfCertData.Certification_ID__c= cert.Id;
                    sfCertData.Course_Id__c= cert.courseId;
                    sfCertData.URI__c= cert.Uri;
                    sfCertData.Status_Display_Name__c='Sync Pending';
                    sfCertData.LMS_Course_Id__c= courseId;
                    lstCertToInsert.add(sfCertData);
                }
            }
            
            if(lstCertToInsert.size()>0)
            {
                insert lstCertToInsert;
            }
        }
    }
    public static void AssociateContactwithEachCertUsingStudentId()
    {
        // select all certificates where contact is null
        List<LMS_Course_Certification__c> lstCert=[Select Id,Learner_Contact__c,Student_Id__c,Student_Email__c from LMS_Course_Certification__c where Learner_Contact__c=null];
        List<String> lstStudentIds= new List<String>();
        Map<string,Id> mapContact= new Map<string,Id>();
        Map<string,string> mapContactEmail= new Map<string,string>();
        List<LMS_Course_Certification__c> lstCertToUpdate= new List<LMS_Course_Certification__c>();
        if(lstCert!=null && lstCert.size()>0)
        {
            for(LMS_Course_Certification__c item : lstCert)
            {
                lstStudentIds.add(string.valueof(item.Student_Id__c));
            }
            List<Partner_Contact_Profile__c> lstPartnerProfile=  [Select Contact__c,LmsUserId__c,Contact__r.Email from Partner_Contact_Profile__c where LmsUserId__c in:lstStudentIds];
            if(lstPartnerProfile!=null && lstPartnerProfile.size()>0)
            {
                
                for(Partner_Contact_Profile__c partInfo : lstPartnerProfile)
                {
                    mapContact.put(partInfo.LmsUserId__c,partInfo.Contact__c);
                    mapContactEmail.put(partInfo.LmsUserId__c,partInfo.Contact__r.Email);
                }
                for(LMS_Course_Certification__c item : lstCert)
                {
                    item.Learner_Contact__c= mapContact.get(string.valueOf(item.Student_Id__c));
                    if(item.Student_Email__c==null)
                    {
                        item.Student_Email__c= mapContactEmail.get(string.valueOf(item.Student_Id__c));
                    }
                    lstCertToUpdate.add(item);
                }
                
                if(lstCertToUpdate.size()>0)
                { update lstCertToUpdate;}
            }
        }
        
    }
    public static void PopulateAccountForContact()
    {
        List<LMS_Course_Certification__c> lstCert=[Select Id,Learner_Contact__c,Learner_Contact__r.AccountId,Learner_Account__c from LMS_Course_Certification__c where Learner_Contact__c!=null and Learner_Account__c=null];
        if(lstCert!=null && lstCert.size()>0)
        {
            for(LMS_Course_Certification__c cert: lstCert)
            {
                if(cert.Learner_Contact__r.AccountId!=null)
                {
                    cert.Learner_Account__c= cert.Learner_Contact__r.AccountId;
                }
            }
            
            update lstCert;
        }
    }
    public static void AssociateContactwithEachCertUsingStudentEmail()
    {
        // select all certificates where contact is null
        List<LMS_Course_Certification__c> lstCert=[Select Id,Learner_Contact__c,Student_Id__c,Student_Email__c from LMS_Course_Certification__c where Learner_Contact__c=null];
        Set<String> lstStudentEmails= new Set<String>();
        Map<string,string> mapContactEmail= new Map<string,string>();
        List<LMS_Course_Certification__c> lstCertToUpdate= new List<LMS_Course_Certification__c>();
        if(lstCert!=null && lstCert.size()>0)
        {            
            for(LMS_Course_Certification__c item : lstCert)
            {
                lstStudentEmails.add(string.valueof(item.Student_Email__c));
            }
            List<Contact> lstContactProfile=  [Select Id,Email from Contact where Email in:lstStudentEmails];
            if(lstContactProfile!=null && lstContactProfile.size()>0)
            {
                
                for(Contact partInfo : lstContactProfile)
                {
                    mapContactEmail.put(partInfo.Email,partInfo.Id);
                }
                for(LMS_Course_Certification__c item : lstCert)
                {
                    if(item.Student_Email__c!=null && !String.isBlank(item.Student_Email__c))
                    { 
                        item.Learner_Contact__c= mapContactEmail.get(string.valueOf(item.Student_Email__c));
                        lstCertToUpdate.add(item);
                    }
                    
                }
                if(lstCertToUpdate.size()>0)
                { update lstCertToUpdate;}
                
            }
        }
        
    }
    
    public static void H_InsertCertificationData(Map<Id,List<HPartnerPortalCertificate>> mapCertificates )
    {
        List<LMS_Course_Certification__c> lstCertToInsert= new List<LMS_Course_Certification__c>();
        if(mapCertificates!=null && mapCertificates.size()>0)
        {
            for(Id courseId:mapCertificates.keySet())
            {
                List<HPartnerPortalCertificate> lstCerts = mapCertificates.get(courseId);
                for(HPartnerPortalCertificate cert:lstCerts)
                {
                    LMS_Course_Certification__c sfCertData= new LMS_Course_Certification__c();
                    sfCertData.Certification_ID__c= cert.Id;
                    sfCertData.Course_Id__c= cert.courseId;
                    sfCertData.LMS_Course_Id__c= courseId;
                    sfCertData.Expiry_Date__c=Date.valueOf(cert.ExpiryDate);
                    sfCertData.Acquired_Date__c=Date.valueOf(cert.AcquiredDate);
                    sfCertData.Enrollment_Id__c=cert.EnrollmentId;
                    string statusDisp='';
                    if(sfCertData.Expiry_Date__c==null)
                    {
                        statusDisp='Active';
                    }
                    else if(sfCertData.Expiry_Date__c<Date.today())
                    {
                        statusDisp='Expired';
                    }
                    else
                    {  
                        statusDisp='Active';
                    }
                    sfCertData.Status_Display_Name__c=statusDisp;
                    lstCertToInsert.add(sfCertData);
                }
            }
            
            if(lstCertToInsert.size()>0)
            {
                insert lstCertToInsert;
            }
        }
    }
    
    
    public static void H_AssociateContactUsingUserId(List<LMS_Course_Certification__c> lstCerts)
    {
        List<LMS_Course_Certification__c> lstCertsToUpdate= new List<LMS_Course_Certification__c>();
        Set<string> setUserId= new Set<String>();
        Map<string,Contact> mapUsrInfo=new  Map<string,Contact>();
        if(lstCerts!=null && lstCerts.size()>0)
        {
            for(LMS_Course_Certification__c item:lstCerts)
            {
                setUserId.add(item.LMS_User_Id__c);
            }
            List<Contact> lstContact=[Select Id,LMS_User_Id__c,AccountId from Contact where LMS_User_Id__c in:setUserId];
            if(lstContact!=null && lstContact.size()>0)
            {
                for(Contact item:lstContact)
                {
                    mapUsrInfo.put(item.LMS_User_Id__c,item);
                }
            }
            
            for(LMS_Course_Certification__c item:lstCerts)
            {
                if(mapUsrInfo!=null && mapUsrInfo.size()>0)
                {
                    Contact con= mapUsrInfo.get(item.Lms_User_Id__c);
                    if(con!=null)
                    {
                        item.Learner_Contact__c=con.Id;
                        item.Learner_Account__c=con.AccountId;
                        lstCertsToUpdate.add(item);
                    }
                }
                
                
            }
            if(lstCertsToUpdate.size()>0)
            {
                update lstCertsToUpdate;
            }
            
        }
        
    }
    
    public static void H_AssociateContactUsingEmailAddress(List<LMS_Course_Certification__c> lstCerts)
    {
        List<LMS_Course_Certification__c> lstCertsToUpdate= new List<LMS_Course_Certification__c>();
        List<Contact> lstContactsToUpdate= new List<Contact>();
        Set<Id> setContactsToUpdate= new Set<Id>();
        Set<string> setUserEmail= new Set<String>();
        Map<string,Contact> mapUsrInfo=new  Map<string,Contact>();
        if(lstCerts!=null && lstCerts.size()>0)
        {
            for(LMS_Course_Certification__c item:lstCerts)
            {
                setUserEmail.add(item.Student_Email__c);
            }
            List<Contact> lstContact=[Select Id,LMS_User_Id__c,AccountId,Email from Contact where Email in:setUserEmail];
            if(lstContact!=null && lstContact.size()>0)
            {
                for(Contact item:lstContact)
                {
                    mapUsrInfo.put(item.Email,item);
                }
                
                for(LMS_Course_Certification__c item:lstCerts)
                {
                    Contact con= mapUsrInfo.get(item.Student_Email__c);
                    if(con!=null)
                    {
                        item.Learner_Contact__c=con.Id;
                        if(con.AccountId!=null)
                        {
                            item.Learner_Account__c=con.AccountId;
                        }
                        lstCertsToUpdate.add(item);
                        con.LMS_User_Id__c=item.LMS_User_Id__c;
                        if(!setContactsToUpdate.contains(con.Id))
                        {
                        	setContactsToUpdate.add(con.Id);
                            lstContactsToUpdate.add(con);
                        }
                    }
                    
                }
                if(lstCertsToUpdate.size()>0)
                {
                    update lstCertsToUpdate;
                }
                
                if(lstContactsToUpdate.size()>0)
                {
                    update lstContactsToUpdate;
                }
            }
        }
        
    }
}