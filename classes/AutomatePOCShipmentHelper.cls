public class AutomatePOCShipmentHelper {
    
    public static boolean ValidateCustomerPortalLogic(Id pocContact)
    {
        
        User customerUser= ValidatePOCContactCustomerUser(pocContact);
        if(customerUser==null)
        {          
            
            Boolean isCustomerSelfRegChecked= ValidateCustomerSelfRegistrationChecked(pocContact);
            if(isCustomerSelfRegChecked)
            {
                
                return true;
            }
            else
            {
                
                Account custAccount=RetreiveAccount(pocContact);
                if(custAccount!=null)
                {
                    if(custAccount.Type=='Customer' || custAccount.Type=='Prospect')
                    {
                        UpdateSelfCheckRegistration(pocContact);
                        return true;
                    }
                }
                else
                {
                    return false;
                }
            }
            
        }
        else
        {
            
            return true;
        }
        return false;
    }
    public static boolean ValidatePartnerPortalLogic(Id pocContact)
    {
        if(!ValidatePOCContactPartnerUser(pocContact))
        {
            Account partnerAccount=RetreiveAccount(pocContact);
            if(partnerAccount!=null && partnerAccount.Type=='Partner')
            {
                // Create partner user
                Profile portalProfile = [SELECT Id FROM Profile WHERE Name LIKE '13g-SP Partner Community' Limit 1];
                Contact contactDtl=[Select Id, FirstName, LastName,Email,Title from Contact where Id=:pocContact];
                string firstname=contactDtl.FirstName;
                string lastName=contactDtl.lastName;
                string aliasName;
                if(firstName!=null)
                {
                    aliasName=firstName.substring(0,1);
                }
                if(lastName!=null)
                {
                    aliasName=aliasName+lastName;
                }
                if(aliasName!=null && aliasName.length()>8)
                {
                    aliasName=aliasName.substring(0,7);
                }
                User user = new User(
                    FirstName= contactDtl.FirstName,
                    LastName= contactDtl.LastName,
                    Email= contactDTl.Email,
                    Username= contactdtl.Email+'.sp',
                    Title=contactDtl.Title,
                    Alias=aliasName,
                    ProfileId=portalProfile.Id,
                    ContactId=pocContact,
                    IsActive=true,
                    EmailEncodingKey = 'UTF-8',
                    TimeZoneSidKey = 'America/Los_Angeles',
                    LocaleSidKey = 'en_US',
                    LanguageLocaleKey = 'en_US'
                );
                
                try
                {
                    insert user;
                    return true;
                }
                catch(Exception ex)
                {
                    SilverPeakUtils.logException(ex);
                    throw ex;
                }
            }
            else
            {
                return false;
            }
            
        }
        else
        {
            return true;
        }
        
    }
    public static User ValidatePOCContactCustomerUser(Id pocContact)
    {
        List<User> lstUser = [Select Id from User where IsActive=true and ContactId=:pocContact and UserType='PowerCustomerSuccess'];
        if(lstUser!=null && lstUser.size()>0)
        {
            return lstUser[0];
        }
        return null;
    }
    public static boolean ValidateCustomerSelfRegistrationChecked(Id pocContact)
    {
        Contact contact =[Select Id,CanAllowPortalSelfReg from Contact where Id=:pocContact];
        if(contact!=null && contact.CanAllowPortalSelfReg)
        {
            return true;
        }
        return false;
    }
    public static boolean UpdateSelfCheckRegistration(Id pocContact)
    {
        boolean isSucess=false;
        Contact con =[Select Id,CanAllowPortalSelfReg from Contact where Id=:pocContact];
        if(con!=null)
        {
            con.CanAllowPortalSelfReg=true;
            
            try
            {
                update con;
                isSucess=true;
            }
            catch(Exception ex)
            {
                isSucess=false;
                throw ex;
                
            }
            finally
            {
                return isSucess;
            }
            
        }
        return isSucess;
    }
    
    public static Account RetreiveAccount(Id pocContact)
    {
        Contact contact =[Select Id,AccountId from Contact where Id=:pocContact];
        if(contact!=null)
        {
            List<Account>lstAccount= [Select Id,Type,IsCustomerPortal,IsPartner from Account where Id=:contact.AccountId];
            if(lstAccount!=null && lstAccount.size()>0)
            {
                return lstAccount[0];
                
            }
        }
        return null;
    }
    
    public static boolean ValidatePOCContactPartnerUser(Id pocContact)
    {
        List<User> lstUser =  [Select Id from User where IsActive=true and ContactId=:pocContact and UserType='PowerPartner'];
        if(lstUser!=null && lstUser.size()>0)
        {
            return true;
        }
        return false;
    }
    
    public static boolean SendErrorNotificationEmailToShipmentTeam(Set<string> pocIds)
    {
        
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setSubject('Action required: POC\'s are not auto fulfilled.');
        string datastring='The POC listed below could not be fulfilled automatically. Kindly fulfill them manually.\r\n\r\n';
        
        for(string counter: pocIds)
        {
            datastring=datastring + counter +'\r\n';
        }
        mail.setPlainTextBody(datastring);
        mail.setToAddresses(getMailAddresses());
        mail.setCCAddresses( new String[]{'notifications@silver-peak.com'});
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        return true;
    }
    
    public static boolean SendBatchSuccessToShipmentTeam(Set<string> pocIds)
    {
        
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setSubject('POC\'s are fulfilled automatically');
        string datastring= 'The POC listed below were fulfilled successfully.\r\n\r\n';
        for(string counter: pocIds)
        {
            datastring=datastring + counter +'\r\n';
        }
        mail.setPlainTextBody(string.valueof(datastring));
        mail.setToAddresses(getMailAddresses());
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        return true;
    }
    
     public static boolean SendUnityCloudNotifications(Set<string> pocIds)
    {
        
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setSubject('Action required: Unity Cloud Intelligence POC\'s');
        string datastring= 'The POC listed below have unity cloud intelligence product.\r\n\r\n';
        for(string counter: pocIds)
        {
            datastring=datastring + counter +'\r\n';
        }
        mail.setPlainTextBody(string.valueof(datastring));
        mail.setToAddresses(getMailAddresses());
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        return true;
    }
      public static boolean SendGMSLicenseStatusToShipmentTeam(Set<string> pocIds)
    {
        
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setSubject('GMS License Created sucessfully.');
        string datastring= 'The GMS licenses for the POC listed below are generated successfully.\r\n\r\n';
        for(string counter: pocIds)
        {
            datastring=datastring + counter +'\r\n';
        }
        mail.setPlainTextBody(string.valueof(datastring));
        mail.setToAddresses(getMailAddresses());
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        return true;
    }
    public static List<Id> FulfillPocs(Id pocId)
    {
        
        Request__c pocRequest= new Request__c(Id=pocId);
        ApexPages.StandardController stdController= new ApexPages.StandardController(pocRequest);
        VirtualPOCFulfillmentController shipmentController= new VirtualPOCFulfillmentController(stdController);
        shipmentController.LicenseDurationDays =30;  
        shipmentController.isFromApex=true;
        return shipmentController.AutomaticFulfillmentVirtualPOC();       
    }
    
    private static List<String> getMailAddresses()
    {
        List<String> mailList = new List<String>();
        List<String> mailAddresses = new List<String>(); 
        
        Group g = [SELECT (select userOrGroupId from groupMembers) FROM group WHERE name like 'Operations_Only'];
        for (GroupMember gm : g.groupMembers) 
        {
            mailList.add(gm.userOrGroupId);
        }
        User[] usr = [SELECT email FROM user WHERE id IN :mailList];
        for(User u : usr) 
        {
            if(u.email!=null)
            {mailAddresses.add(u.email);}
            
        } 
        return mailAddresses;
    }
    
    public static boolean IsUnityCloudIntelligenceInPoc(Id pocId)
    {
        List<Request__c> lstReq=[Select Id from Request__c where Id=:pocId and (VirtualProduct1__c like 'Unity Cloud%' or VirtualProduct2__c like 'Unity Cloud%' or VirtualProduct3__c like 'Unity Cloud%' or VirtualProduct4__c like 'Unity Cloud%' or VirtualProduct5__c like 'Unity Cloud%')];
        if(lstReq!=null && lstReq.size()>0)
        {
            return true;
        }
        return false;
    }
    
    public static void encryptLicenses(List<Id> licenseIds)
    {
        Set<Id> gmsLicenseIds = new Set<Id>();
        for(License__c gmsLicense : [select Id from License__c where Id in :licenseIds and (AssetId__r.Product2.Model__c='GX-V' OR AssetId__r.Product2.Product_Category__c = 'GMS')])
        {
            gmsLicenseIds.add(gmsLicense.Id);
        }
        if(gmsLicenseIds.size() > 0)
        {
            LicenseEncryptionJob job = new LicenseEncryptionJob();
            job.LicenseIds = new List<Id>(gmsLicenseIds);
            System.enqueueJob(job);
        }
        
        Set<Id> virtualLicenseIds = new Set<Id>();
        for(License__c virtualLicense : [select Id from License__c where Id in :licenseIds and AssetId__r.Product2.Model__c!='GX-V' And AssetId__r.Product2.Product_Category__c !='GMS'])
        {
            virtualLicenseIds.add(virtualLicense.Id);
        }
        if(virtualLicenseIds.size() > 0)
        {
            LicenseEncryptionJob job = new LicenseEncryptionJob();
            job.LicenseIds = new List<Id>(virtualLicenseIds);
            System.enqueueJob(job);
        }
    }
}