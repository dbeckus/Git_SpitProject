public class LicenseTriggerHandler implements ITriggerHandler {
    public LicenseTriggerHandler()
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
            
            for (Id licId : newItems.keyset())
            {
                License__c  newLicense=(License__c )newItems.get(licId);
                License__c  oldLicense=(License__c )oldItems.get(licId);
                
                
                
            }
        }
    }
    public void BeforeDelete(Map<Id,SObject> oldItems) 
    {
        
    }
    public void AfterInsert(Map<Id, SObject> newItems) 
    {
        List<Account> lstAccount= new List<Account>();
        if(newItems!=null && newItems.size()>0)
        {
            for(Id licId: newItems.keyset())
            {
                License__c newLic= (License__c)newItems.get(licId);
                if(newLic.License_Expiration__c!=null && newLic.Quote_Type__c=='EDGECONNECT' && (newLic.Model__c != null && newLic.Model__c.startsWith('ECBASE')) && newLic.Asset_Status__c!='Customer Evaluation')
                {
                    lstAccount.add(new Account(Id=newLic.AccountId__c,EC_End_Date__c=newLic.License_Expiration__c));
                }
            }
            if(lstAccount.size()>0)
            {
                update lstAccount;
            }
        }
    }
    public void AfterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) 
    {     
        List<Account> lstAccount= new List<Account>();
        if(newItems!=null && newItems.size()>0)
        {
            for (Id licId : newItems.keyset())
            {
                License__c  newLic= (License__c )newItems.get(licId);
                License__c  oldLic= (License__c )oldItems.get(licId);
                if(oldLic.License_Expiration__c!=newLic.License_Expiration__c)
                {
                    if(newLic.Quote_Type__c=='EDGECONNECT' && (newLic.Model__c != null && newLic.Model__c.startsWith('ECBASE')) && newLic.Asset_Status__c!='Customer Evaluation')
                    {
                        lstAccount.add(new Account(Id=newLic.AccountId__c,EC_End_Date__c=newLic.License_Expiration__c));
                    }
                }
            }
            if(lstAccount.size()>0)
            {
                update lstAccount;
            }
        }
        
    }
    public void AfterDelete(Map<Id, SObject> oldItems) 
    {
        
    }
    public void AfterUndelete(Map<Id, SObject> newItems) 
    {
       
    }
}