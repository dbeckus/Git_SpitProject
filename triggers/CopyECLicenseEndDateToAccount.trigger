trigger CopyECLicenseEndDateToAccount on License__c (after insert,after update) {
    Set<Account> setAcc= new Set<Account>();
    for(License__c obj: Trigger.New)
    {
        License__c oldLicense=null;
        if(Trigger.isUpdate)
        {
            oldLicense = Trigger.OldMap.get(obj.Id);
        }
        
        if(oldLicense==null ||(oldLicense!=null && oldLicense.License_Expiration__c!=obj.License_Expiration__c))
        {
            if(obj.Quote_Type__c=='EDGECONNECT' && obj.Model__c.startsWith('ECBASE') && obj.Asset_Status__c!='Customer Evaluation')
            {
                setAcc.add(new Account(Id=obj.AccountId__c,EC_End_Date__c=obj.License_Expiration__c));
            }
        }
    }
    if(setAcc.size()>0)
    {
        List<Account> lstAcc= new List<Account>();
        lstAcc.addAll(setAcc);
        update lstAcc;
    }
    
}