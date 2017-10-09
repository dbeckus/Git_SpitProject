public class POCRequestTriggerHandler implements ITriggerHandler {

    public POCRequestTriggerHandler()
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
            for(Request__c newReq:(List<Request__c>)newItems)
            {
               
                
            }
        }
        
    }
    public void BeforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) 
    {
       
        if(newItems!=null && newItems.size()>0)
        {
            for (Id reqId : newItems.keyset())
            {
                Request__c newPOC=(Request__c)newItems.get(reqId);
                Request__c oldPOC=(Request__c)oldItems.get(reqId);
                
                
            }
            
        }
    }
    public void BeforeDelete(Map<Id,SObject> oldItems) 
    {
        if(oldItems.size()>0)
        {
            for(Id reqId:oldItems.keySet())
            {
               
            }
        }
    }
    public void AfterInsert(Map<Id, SObject> newItems) 
    {

        if(newItems!=null && newItems.size()>0)
        {
            for (Id oppId : newItems.keyset())
            {
                
            }
       
        }
    }
    public void AfterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) 
    {     
    	Map<Id,Id> mapPocContact= new Map<Id,Id>();
        if(newItems!=null && newItems.size()>0)
        {
            for (Id reqId : newItems.keyset())
            {
                Request__c newPOC= (Request__c)newItems.get(reqId);
                Request__c oldPOC= (Request__c)oldItems.get(reqId);
                if((oldPoc.Status__c=='Shipped- Pending Extension Approval' || oldPoc.Status__c=='Pending Return' || oldPoc.Status__c=='Pending Return - Invoiced' ) && newPOC.Status__c=='Shipped - Extended')
                {
                    mapPocContact.put(newPOC.Id,newPOC.POC_Contact__c);
                }
            }
        }
        DeleteRMAForApprovedPendReturnPOC(mapPocContact);
    }
    public void AfterDelete(Map<Id, SObject> oldItems) 
    {
        if(oldItems!=null && oldItems.size()>0)
        {
            for (Id reqId : oldItems.keyset())
            {
               
            }
             
            
        }
    }
    public void AfterUndelete(Map<Id, SObject> newItems) 
    {
        if(newItems!=null && newItems.size()>0)
        {
            for (Id reqId : newItems.keyset())
            {
                
            }
        }
    }
    
    private void DeleteRMAForApprovedPendReturnPOC(Map<Id,Id> mapReqs)
    {
        List<RMA__c> rmaIdsToDelete= new List<RMA__c>();
        List<Asset> lstAssetToUpdate= new List<Asset>();
        System.Savepoint sp= Database.setSavepoint();
        try
        {
            if(mapReqs.size()>0)
            {
                for(Id pocId:mapReqs.keySet())
                {
                    List<RMA__c> rmaIds = [Select Id,LineCount__c,Received_Count__c,Account__c from RMA__c where Request__c =:pocId and status__c!='Closed'];
                    System.debug('rmaIds.Id'+rmaIds[0].Id);
                    if(rmaIds!=null && rmaIds.size()>0)
                    {
                        for(RMA__c counter:rmaIds)
                        {
                            if(counter.Received_Count__c==0)
                            {
                                rmaIdsToDelete.add(counter);
                            }
                            List<Asset> lstAsset=[Select Id from Asset where Id in (Select Asset__c from RMA_Item__c where RMA__c =: counter.Id and status__c!='Received')];
                            System.debug('lstAsset'+lstAsset);
                            if(lstAsset!=null && lstAsset.size()>0)
                            {
                                for(Asset item: lstAsset)
                                {
                                    item.Status='Customer Evaluation';
                                    lstAssetToUpdate.add(item);
                                }
                            }
                        } 
                    }
                    SendEmailToPOCContactforRMA(pocId,mapReqs.get(pocId));
                }
                if(lstAssetToUpdate.size()>0)
                {
                    update lstAssetToUpdate;
                }
                if(rmaIdsToDelete.size()>0)
                {
                    delete rmaIdsToDelete;
                }
            }
        }
        catch(Exception ex)
        {
            Database.rollback(sp);
        }
    }
    private  void SendEmailToPOCContactforRMA(Id pocId,Id pocContact)
    {
        List<EmailTemplate> template = [select Id from EmailTemplate where Name='Extension Approval Pending Return' limit 1];
        if(template.size() > 0)
        {
            List<String> ccs = getPOCRecipients(pocId);
            ccs.add('notifications@silver-peak.com');
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setTemplateId(template[0].Id);
            email.setTargetObjectId(pocContact);
            email.setCcAddresses(ccs);
            email.setWhatId(pocId);
            email.setsaveAsActivity(false);
            Id orgWideEmail = SilverPeakUtils.getOrganizationWideEmailId('notifications@silver-peak.com');
            if(orgWideEmail != null)
            {
                email.setOrgWideEmailAddressId(orgWideEmail);
            }
            Messaging.sendEmail(new List<Messaging.Email> {email}, true);  
        }
    }
    private List<String> getPOCRecipients(Id pocId)
    {
        List<Request__c> members = [select Id, SE__r.Email,SE_Manager__r.Email,RSM_Manager__r.Email,RSM__r.Email,CC_List_1__c,CC_List_2__c,CC_List_3__c,CC_List_4__c,CC_List_5__c from Request__c where Id=:pocId];
        List<String> emails = new List<String>();
        if(members!=null && members.size()>0)
        {
            if(members[0].SE__r.Email!=null)
            {
                emails.add(members[0].SE__r.Email);
            }
            if(members[0].SE_Manager__r.Email!=null)
            {
                emails.add(members[0].SE_Manager__r.Email);
            }
            if(members[0].RSM_Manager__r.Email!=null)
            {
                emails.add(members[0].RSM_Manager__r.Email);
            }
            if(members[0].RSM__r.Email!=null)
            {
                emails.add(members[0].RSM__r.Email);
            }
            if(members[0].CC_List_1__c!=null)
            {
                emails.add(members[0].CC_List_1__c);
            }
            if(members[0].CC_List_2__c!=null)
            {
                emails.add(members[0].CC_List_1__c);
            }
            if(members[0].CC_List_3__c!=null)
            {
                emails.add(members[0].CC_List_3__c);
            }
            if(members[0].CC_List_4__c!=null)
            {
                emails.add(members[0].CC_List_4__c);
            }
            if(members[0].CC_List_5__c!=null)
            {
                emails.add(members[0].CC_List_5__c);
            }
        }
        
        return emails;
    }
}