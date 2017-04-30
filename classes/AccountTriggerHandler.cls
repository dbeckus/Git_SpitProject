public class AccountTriggerHandler implements ITriggerHandler {
    
    public AccountTriggerHandler()
    {
        
    }
    public Boolean IsDisabled()
    {
        return false;
    }
    public void BeforeInsert(List<SObject> newItems) 
    {
        if(newItems!=null && newItems.size()>0)
        {
            
        }
        
    }
    public void BeforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) 
    {
        if(newItems!=null && newItems.size()>0)
        {
            for (Id accId : newItems.keyset())
            {
                
                
            }
        }
    }
    public void BeforeDelete(Map<Id,SObject> oldItems) 
    {
        boolean isSynced=false;
        if(oldItems.size()>0)
        {
            for(Id accId:oldItems.keySet())
            {
                Account oldAccinfo= (Account)oldItems.get(accId);
                if(oldAccinfo.Cloud_Portal_Account_Id__c!=null ||oldAccinfo.Cloud_Portal_Account_Key__c!=null||oldAccinfo.Cloud_Portal_Account_Name__c!=null || oldAccinfo.Sync_with_Cloud_Portal__c )
                {
                    isSynced=true;
                }
                
                if(!isSynced && (oldAccinfo.Cloud_Portal_Account_Id__c==null ||oldAccinfo.Cloud_Portal_Account_Key__c==null||oldAccinfo.Cloud_Portal_Account_Name__c==null))
                {
                    List<Asset> lstAssets= [Select Id from Asset where AccountId=:oldAccinfo.Id and (Product2.Name like 'EC%' or Product2.Name like 'UNITY%' )];
                    if(lstAssets.size()>0)
                    {
                        isSynced=true;
                    } 
                }
                if(isSynced)
                {
                    oldAccinfo.addError('You cannot delete/merge this account as it is synced with cloud portal. Please contact salesforce administrator.');
                }
            }
        }
    }
    public void AfterInsert(Map<Id, SObject> newItems) 
    {
        
    }
    public void AfterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) 
    {
        List<Account> lstPartnerAcctIds= new List<Account>();
        List<Id> setPortalUserAcctId= new List<Id>();
        Set<Id> setSelfRegAcctIds= new Set<Id>();
        if(newItems!=null && newItems.size()>0)
        {
            for (Id accId : newItems.keyset())
            {
                Account newAccInfo= (Account)newItems.get(accId);
                Account oldAccInfo= (Account)oldItems.get(accId);
                if(newAccInfo.Partner_Application_Status__c == 'Approved' && oldAccInfo.Partner_Application_Status__c != 'Approved')
                {
                    lstPartnerAcctIds.add(new Account(Id=newAccInfo.Id,IsPartner=true));
                }
                if(newAccInfo.Service_Provider_Account_Type__c=='Perpetual-Orchestrator SP' || newAccInfo.Service_Provider_Account_Type__c=='Metered-Orchestrator SP')
                {
                    if(oldAccInfo.Cloud_Portal_Account_Key__c==null && newAccInfo.Cloud_Portal_Account_Key__c!=null && oldAccInfo.Cloud_Portal_Account_Name__c==null && newAccInfo.Cloud_Portal_Account_Name__c!=null)
                    {
                        String templateString='Please find the details to create MTO instance. \n\n CloudPortal Account Name : {0}\n\r CloudPortal Account Key : {1}\n\r Service Provider Domain : {2}\n\r Service Provider Location: {4}\n\r Service Provider Admin User: {3}\n\r';
                        String[] arguments = new String[] {newAccInfo.Cloud_Portal_Account_Name__c,newAccInfo.Cloud_Portal_Account_Key__c,newAccInfo.Service_Provider_Domain__c,newAccInfo.Service_Provider_Admin_User__c,newAccInfo.Service_Provider_Location__c};
                            string bodyText= string.format(templateString,arguments);
                        //Send Email to DevOps Team
                        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                        message.toAddresses = new String[] {'devops@silver-peak.com','notifications@silver-peak.com'};
                            message.subject = 'Please create MTO instance for this account '+ newAccInfo.Cloud_Portal_Account_Name__c;
                        message.plainTextBody = bodyText;
                        Messaging.SingleEmailMessage[] messages = 
                            new List<Messaging.SingleEmailMessage> {message};
                                Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
                        if (results[0].success) {
                            System.debug('The email was sent successfully.');
                        } else {
                            System.debug('The email failed to send: '
                                         + results[0].errors[0].message);
                        }
                    }
                }
                if(newAccInfo.GEO_Supported__c != oldAccInfo.GEO_Supported__c)
                {
                    setPortalUserAcctId.add(newAccInfo.Id);
                }
                if(!newAccInfo.IsCustomerPortal && oldAccInfo.IsCustomerPortal)
                {
                    setSelfRegAcctIds.add(newAccInfo.Id);
                }                
            }
            SetAccountAsPartner(lstPartnerAcctIds);
            EnforcePortalUserGroup(setPortalUserAcctId);
            DisableSelfRegForAccount(setSelfRegAcctIds);
        }
    }
    public void AfterDelete(Map<Id, SObject> oldItems) 
    {
        
    }
    public void AfterUndelete(Map<Id, SObject> oldItems) 
    {
        
    }
    private void DisableSelfRegForAccount(Set<Id> accIds)
    {
        if(accIds.size()>0)
        {
            List<Contact> lstCon=[Select Id from Contact where AccountId in: accIds and CanAllowPortalSelfReg=true];
            Set<Id> conIds= new Set<Id>();
            for(Contact con: lstCon)
            {
                conIds.add(con.Id);
            }
            ContactOwnershipHelper.DisableAllowSelfReg(conIds);
        }
    }
    private  void EnforcePortalUserGroup(List<Id> setAcctIds)
    {
        if(setAcctIds.size() > 0)
        {
            PartnerPortalUserSharingBatch job = new PartnerPortalUserSharingBatch(setAcctIds);
            Database.executeBatch(job);
        }
    }
    private void SetAccountAsPartner(List<Account> lstAcctInfo)
    {
        if(lstAcctInfo.size() > 0)
        {
            try
            {
                update lstAcctInfo; 
            }
            catch(Exception ex)
            {
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                String[] toaddress = New String[] {UserInfo.getUserEmail()};
                    email.setPlainTextBody('UpdateAccountIsPartner Error:' + ex.getMessage() );
                email.setToAddresses(toaddress);
                Messaging.sendEmail(New Messaging.SingleEmailMessage[] {email});
            }
        }
    }
    
}