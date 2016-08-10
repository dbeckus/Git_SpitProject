trigger ShareMDFToPartner on MDF_Request__c (after insert, after update) 
{
    List<MDF_Request__c> needToShareMDFs = new List<MDF_Request__c>();
    for(MDF_Request__c mdf : trigger.New)
    {
        if(Trigger.isinsert)
        {
            if(mdf.Account__c != null)
            {
                needToShareMDFs.add(mdf);
            }
        }
        else if(Trigger.isUpdate)
        {
            MDF_Request__c oldMDF = trigger.oldmap.get(mdf.Id);
            if(isChanged(oldMDF, mdf, new String[] {'Account__c', 'OwnerId'}))
            {
                needToShareMDFs.add(mdf);
            }
        }    
    }
    if(needToShareMDFs.size() > 0)
    {
        ShareMDFToPartnerHelper.shareMDFs(needToShareMDFs);
    }
    
    //Checks if the fields are changed in the sObjects
    private Boolean isChanged(sObject oldObj, sObject newObj, String[] fields)
    {
        for(String field : fields)
        {
            Object oldValue = oldObj.get(field);
            Object newValue = newObj.get(field);
            if(oldValue != newValue)
            {
                return true;
            }
        }
        return false;
    }
}