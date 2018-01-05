public class MDFTriggerHandler implements ITriggerHandler{
public MDFTriggerHandler()
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
            for(Id assetId:newItems.keyset())
            {
               
            }
        }
    }
    public void BeforeDelete(Map<Id,SObject> oldItems) 
    {
        
        if(oldItems.size()>0)
        {
            for(Id assetId:oldItems.keySet())
            {
                
            }
        }
    }
    public void AfterInsert(Map<Id, SObject> newItems) 
    {
        List<MDF_Request__c>lstRequests= new List<MDF_Request__c>();
        Set<Id> accountIds = new Set<Id>();
        List<MDF_Request__c> lstMDF= new List<MDF_Request__c>();
        if(newItems!=null && newItems.size()>0)
        {
            for (Id mdfId : newItems.keyset())
            {
                MDF_Request__c mdf= (MDF_Request__c)newItems.get(mdfId);
                if(mdf.Is_Portal_Request__c)
                    lstRequests.add(mdf);
                if(mdf.Account__c!=null)
                {
                    lstMDF.add(mdf);
                }
            }
            if(!SilverPeakUtils.BypassingTriggers)
            {
                AutoSubmitMDFRequest(lstRequests);
            }
           
            ShareMDFToPartner(lstMDF);
            CopyMdfToAccount(accountIds);
        }
    }
    
    public void AfterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) 
    {
        System.debug('After Update');
        Set<Id> accountIds = new Set<Id>();
        List<MDF_Request__c> lstMDF= new List<MDF_Request__c>();
        if(newItems!=null && newItems.size()>0)
        {
            for (Id mdfId : newItems.keyset())
            {
                MDF_Request__c newMDF= (MDF_Request__c)newItems.get(mdfId);
                MDF_Request__c oldMDF= (MDF_Request__c)oldItems.get(mdfId);
                if(newMDF.Approval_Status__c == 'Approved' && oldMdf.Approval_Status__c != 'Approved' || oldMdf.Account__c != newMDF.Account__c)
                {
                    if(newMDF.Account__c!=null)
                        accountIds.add(newMDF.Account__c);
                }
                if(newMDF.Account__c!=oldMDF.Account__c || newMDF.OwnerId!=oldMdf.OwnerId)
                    lstMDF.add(newMDF);
            }
            ShareMDFToPartner(lstMDF);
            CopyMdfToAccount(accountIds);
        }
    }
    public void AfterDelete(Map<Id, SObject> oldItems) 
    {
        
        for(Id assetId : oldItems.keySet())
        {
          
        }
       
    }
    public void AfterUndelete(Map<Id, SObject> newItems) 
    {
        
        if(newItems!=null)
        {
            for(Id assetId : newItems.keySet())
            {
            }
        }
      
    }
    
    
    private void AutoSubmitMDFRequest(List<MDF_Request__c> lstRequests)
    {
        List<Approval.ProcessSubmitRequest> requests = new List<Approval.ProcessSubmitRequest>();
        for(MDF_Request__c item : lstRequests)
        {
                Approval.ProcessSubmitRequest submitReq = new Approval.ProcessSubmitRequest();
                submitReq.setComments('Submitting request for approval.');
                submitReq.setObjectId(item.Id);
                //submitReq.setSubmitterId(UserInfo.getUserId());
                //submitReq.setProcessDefinitionNameOrId('New_MDF_Request');
                //submitReq.setSkipEntryCriteria(true);
                requests.add(submitReq);
        }
        try
        {
            List<Approval.ProcessResult> results = Approval.process(requests, false);
        }
        catch(Exception ex)
        {
            System.debug('An exception was thrown: ' + ex);
        }
    }
    
    private void CopyMdfToAccount(Set<Id> accountIds)
    {
        List<Account> updatingAccounts = new List<Account>();
        if(accountIds.size() > 0)
        {
            List<AggregateResult> allMdfs = [select sum(Estimated_Silver_Peak_Amount__c) c, Account__c a from MDF_Request__c where Account__c in :accountIds group by Account__c];
            List<AggregateResult> approvedMdfs = [select sum(Estimated_Silver_Peak_Amount__c) c, Account__c a from MDF_Request__c where Account__c in :accountIds and Approval_Status__c='Approved' group by Account__c];
            
            for(Id accId : accountIds)
            {
                updatingAccounts.add(new Account(Id=accId, Total_Requested_MDF__c=0, Total_Approved_MDF__c=0));
            }
            for(AggregateResult r :  allMdfs)
            {
                Id accId = (Id)r.get('a');
                Decimal amount = (Decimal)r.get('c');
                for(Account acc : updatingAccounts)
                {
                    if(acc.Id == accId)
                    {
                        acc.Total_Requested_MDF__c = amount;
                        break;
                    }
                }
            }
            for(AggregateResult r :  approvedMdfs)
            {
                Id accId = (Id)r.get('a');
                Decimal amount = (Decimal)r.get('c');
                for(Account acc : updatingAccounts)
                {
                    if(acc.Id == accId)
                    {
                        acc.Total_Approved_MDF__c = amount;
                        break;
                    }
                }
            }
        }
        if(updatingAccounts.size() > 0)
        {
            Database.update(updatingAccounts, false);
        }
    }
    
    private void ShareMDFToPartner(List<MDF_Request__c> needToShareMDFs)
    {
        if(needToShareMDFs!=null && needToShareMDFs.size() > 0)
        {
            ShareMDFToPartnerHelper.shareMDFs(needToShareMDFs);
        }
    }
}