public class POCRequestTriggerHandler implements ITriggerHandler {
    Set<Id> removeUsers = new Set<Id>{'00550000000lhIW','00530000000jZPL'};// remove eric and chris helfer from the APAC and EMEA
        Map<Id,Id> mapReqId= new Map<Id,Id>();
    Set<Id> pendingReturnPocs = new Set<Id>();
    Set<Id> closedPocs = new Set<Id>();
    Set<Id> returnedPocs = new Set<Id>();
    Set<Id> datesChangedPocs = new Set<Id>();
    Set<Id> opportunityIds = new Set<Id>();
    public POCRequestTriggerHandler()
    {
        
    }
    
    public Boolean IsDisabled()
    {
        return false;
    }
    public void BeforeInsert(List<SObject> newItems) 
    {
        Set<Request__c> setPOCRequests= new Set<Request__c>();
        if(newItems!=null && newItems.size()>0)
        {
            for(Request__c newPOC:(List<Request__c>)newItems)
            {
                if(newPOC.POC_Type__c=='EdgeConnect' && newPOC.Is_Unity_Cloud_Orchestrator__c)
                    setPOCRequests.add(newPOC);
                
            }
            
            Set<Id> setPOCAssets= ValidateUnityOrchestrtatorCanBeAdded(setPOCRequests);
            for(Request__c req: (List<Request__c>)newItems)
            {
                if(setPOCAssets!=null && setPOCAssets.size()>0 && setPOCAssets.contains(req.Id))
                {
                    req.addError('Unity Cloud Orchestrator cannot be requested as there is an existing active cloud orch asset or POC on this account.');
                }
            }
        }
        
    }
    public void BeforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) 
    {
        Map<Id,String> requestIds= new Map<Id,String>();
        Set<Request__c> setPOCRequests= new Set<Request__c>();
        if(newItems!=null && newItems.size()>0)
        {
            for (Id reqId : newItems.keyset())
            {
                Request__c newPOC=(Request__c)newItems.get(reqId);
                Request__c oldPOC=(Request__c)oldItems.get(reqId);
                if(newPOC.POC_Type__c=='EdgeConnect' && newPOC.Is_Unity_Cloud_Orchestrator__c && (oldPOC==null || (oldPOC!=null && oldPoc.Is_Unity_Cloud_Orchestrator__c!=newPOC.Is_Unity_Cloud_Orchestrator__c)))
                {
                    
                    if(newPOC.POC_Type__c=='EdgeConnect' && newPOC.Is_Unity_Cloud_Orchestrator__c && oldPoc.Is_Unity_Cloud_Orchestrator__c!=newPOC.Is_Unity_Cloud_Orchestrator__c)
                    {
                        setPOCRequests.add(newPOC);
                    }
                    
                }
                if(newPOC.POC_Type__c!= oldPOC.POC_Type__c)
                {
                    requestIds.put(reqId,newPOC.POC_Type__c);
                }
                
            }
            
            Set<Id> setPOC= CheckValidProductsAddedOnECPOCFlag(requestIds);
            Set<Id> setPOCAssets= ValidateUnityOrchestrtatorCanBeAdded(setPOCRequests);
            for(Request__c req: (List<Request__c>)newItems.values())
            {
                if(setPOCAssets!=null && setPOCAssets.size()>0 && setPOCAssets.contains(req.Id))
                {
                    req.addError('Unity Cloud Orchestrator cannot be requested as there is an existing active cloud orch asset or POC on this account.');
                }
                if(setPOC!=null && setPOC.size()>0 && setPOC.contains(req.Id))
                    req.POC_Type__c.addError('EdgeConnect and Non-EdgeConnect products cannot be mixed.');
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
            for (Id pocId : newItems.keyset())
            {
                Request__c newPOC=(Request__c)newItems.get(pocId);
                if(newPOC.Opportunity__c!=null)
                {
                    mapReqId.put(pocId,newPOC.Opportunity__c);
                }
                opportunityIds.add(newPOC.Opportunity__c);
            }
            PopulatePOCApprovers(mapReqId);
            UpdatePocStatusToOpportunity();
        }
    }
    public void AfterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) 
    {     
        Map<Id,Id> mapPocContact= new Map<Id,Id>();
        Map<Id,Request__c> mapWanOpEmails= new Map<Id,Request__c>();
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
                if(newPOC.Status__c != oldPOC.Status__c)
                {
                    opportunityIds.add(newPOC.Opportunity__c);
                }
                if(newPOC.Opportunity__c != oldPOC.Opportunity__c)
                {
                    opportunityIds.add(newPOC.Opportunity__c);
                    opportunityIds.add(oldPOC.Opportunity__c);
                }
                
                if(oldPoc.Trigger_POC_Approvers__c!=newPOC.Trigger_POC_Approvers__c && newPOC.Trigger_POC_Approvers__c)
                {
                    if(newPOC.Opportunity__c!=null)
                    {
                        mapReqId.put(newPOC.Id,newPOC.Opportunity__c);
                        
                    }
                }
                if(newPOC.Send_email__c!=oldPOC.Send_Email__c && newPOC.Send_Email__c)
                {
                    mapWanOpEmails.put(newPOC.Id, newPOC);
                }
                if((newPOC.Status__c == 'Closed - Returned' || newPOC.Status__c == 'Closed - Won') && newPOC.Status__c != oldPOC.Status__c)
                {
                    //removes the poc link on assets
                    closedPocs.add(newPOC.Id);
                }
                if(newPOC.Status__c == 'Closed - Returned' && newPOC.Status__c != oldPOC.Status__c)
                {
                    //closes the RMA
                    returnedPocs.add(newPOC.Id);
                }
                if(newPOC.Status__c == 'Pending Return' && newPOC.Status__c != oldPOC.Status__c)
                {
                    //creates eval RMA when request is not all virtual
                    pendingReturnPocs.add(newPOC.Id);
                }
                if(newPOC.Target_End_Date__c != oldPOC.Target_End_Date__c)
                {
                    //updates EvaluationEndDate on Assets to TargetEndDate on POC
                    datesChangedPocs.add(newPOC.Id);
                }
            }
            PopulatePOCApprovers(mapReqId);
            UpdatePocStatusToOpportunity();
            DeleteRMAForApprovedPendReturnPOC(mapPocContact);
            HandlePOCStatusChange();
            SendWANOPFulfillmentEmail(mapWanOpEmails);
        }
        
    }
    public void AfterDelete(Map<Id, SObject> oldItems) 
    {
        if(oldItems!=null && oldItems.size()>0)
        {
            for (Id reqId : oldItems.keyset())
            {
                Request__c oldPOC= (Request__c)oldItems.get(reqId);
                opportunityIds.add(oldPOC.Opportunity__c);
            }
            
            UpdatePocStatusToOpportunity();
        }
    }
    public void AfterUndelete(Map<Id, SObject> newItems) 
    {
        if(newItems!=null && newItems.size()>0)
        {
            for (Id reqId : newItems.keyset())
            {
                Request__c newPOC= (Request__c)newItems.get(reqId);
                opportunityIds.add(newPOC.Opportunity__c);
            }
            UpdatePocStatusToOpportunity();
        }
    }
    
    private void UpdatePocStatusToOpportunity()
    {
        if(opportunityIds.size() > 0)
        {
            List<Opportunity> opps = [select Id, Has_Active_POCs__c, AccountId, Account.Has_Active_POCs__c, Account.POC_Request_Date__c, (select Id from Requests__r where IsClosed__c=false and Status__c !='Open' limit 1) from Opportunity where Id in :opportunityIds and StageName!='Closed Deleted'];
            Set<Id> accIds = new Set<Id>();
            for(Opportunity opp : opps)
            {
                opp.Has_Active_POCs__c = opp.Requests__r.size() > 0;
                if(opp.Has_Active_POCs__c == true && opp.POC_History__c == false)
                {
                    opp.POC_History__c = true;
                }
                opp.Bypassing_Validation__c = true;
                accIds.add(opp.AccountId);
            }
            try
            {
                update opps;
            }
            catch(Exception ex)
            {
                SilverPeakUtils.logException(ex);
            }
            List<Account> accs = [select Id, POC_Request_Date__c, Has_Active_POCs__c, (select Id from Opportunities where Has_Active_POCs__c=true limit 1) from Account where Id in :accIds];
            for(Account acc : accs)
            {
                acc.Has_Active_POCs__c = acc.Opportunities.size() > 0;
                if(acc.POC_Request_Date__c == null)
                {
                    acc.POC_Request_Date__c = Date.today();
                }
            }
            try
            {
                update accs;
            }
            catch(Exception ex)
            {
                SilverPeakUtils.logException(ex);
            }
        }
    }
    private void SendWANOPFulfillmentEmail(Map<Id,Request__c> mapRequests)
    {
        List<string>lstVRXModels= new List<string>{'Velocity','VRX-2','VRX-4','VRX-6','VRX-8'};
            List<string>lstVXModels= new List<string>{'VX-0000', 'VX-500','VX-1000','VX-2000','VX-3000','VX-4000','VX-5000','VX-6000','VX-8000','VX-9000'};
                List<Request__c> lstPOCToUpdate = new List<Request__c>();
        Map<Id,integer> mapVXAssets= new Map<Id,integer>();
        Map<Id,integer> mapVRXAssets= new Map<Id,integer>();
        if(mapRequests!=null && mapRequests.size()>0)
        {
            List<Request__c> lstReqData = [select Id,POC_Contact__c,POC_Contact__r.Email,SE__r.Email,SE_Manager__r.Email,RSM_Manager__r.Email,RSM__r.Email,CC_List_1__c,CC_List_2__c,CC_List_3__c,CC_List_4__c,CC_List_5__c from Request__c where Id in:mapRequests.keySet()];
            List<AggregateResult> lstVxAssets= [Select POCRequest__c, COUNT(Id)recCount from Asset where POCRequest__c in :mapRequests.keySet() and CreatedDate=today and Product2.Family='Virtual Image' and Hosted_GMS__c=false and Marketplace_Sourced_Opp__c=0 and (NOT Model__c='GX-V') and Model__c in:lstVXModels GROUP BY POCRequest__c];
            List<AggregateResult> lstVrxAssets= [Select POCRequest__c, COUNT(Id)recCount from Asset where POCRequest__c in :mapRequests.keySet() and CreatedDate=today and Model__c in:lstVRXModels  and Key_Generated__c=true and Marketplace_Sourced_Opp__c=0 GROUP BY POCRequest__c];
            if(lstVxAssets!=null && lstVxAssets.size()>0)
            {
                for(AggregateResult aggr: lstVXAssets) 
                {
                    mapVXAssets.put((Id)aggr.get('POCRequest__c'),(integer)aggr.get('recCount'));
                }
            }
            if(lstVrxAssets!=null && lstVrxAssets.size()>0)
            {
                for(AggregateResult aggr: lstVrxAssets) 
                {
                    mapVRXAssets.put((Id)aggr.get('POCRequest__c'),(integer)aggr.get('recCount'));
                }
            }
            for(Id pocId : mapRequests.keySet())
            {
                Request__c pocDetailRec= new Request__c();
                List<string> lstCopyEmail= new List<String>();
                integer vxCount=mapVXAssets.get(pocId) ; integer vrxCount=mapVRXAssets.get(pocId);
                for(Request__c reqData: lstReqData)
                {
                    if(reqData.Id==pocId)
                    {
                        pocDetailRec=reqData;
                        break;
                    }
                }
                
                if(pocDetailRec!=null)
                {
                    if(pocDetailRec.SE__r.Email!=null)
                    {
                        lstCopyEmail.add(pocDetailRec.SE__r.Email);
                    }
                    if(pocDetailRec.SE_Manager__r.Email!=null)
                    {
                        lstCopyEmail.add(pocDetailRec.SE_Manager__r.Email);
                    }
                    if(pocDetailRec.RSM_Manager__r.Email!=null)
                    {
                        lstCopyEmail.add(pocDetailRec.RSM_Manager__r.Email);
                    }
                    if(pocDetailRec.RSM__r.Email!=null)
                    {
                        lstCopyEmail.add(pocDetailRec.RSM__r.Email);
                    }
                    if(pocDetailRec.CC_List_1__c!=null)
                    {
                        lstCopyEmail.add(pocDetailRec.CC_List_1__c);
                    }
                    if(pocDetailRec.CC_List_2__c!=null)
                    {
                        lstCopyEmail.add(pocDetailRec.CC_List_1__c);
                    }
                    if(pocDetailRec.CC_List_3__c!=null)
                    {
                        lstCopyEmail.add(pocDetailRec.CC_List_3__c);
                    }
                    if(pocDetailRec.CC_List_4__c!=null)
                    {
                        lstCopyEmail.add(pocDetailRec.CC_List_4__c);
                    }
                    if(pocDetailRec.CC_List_5__c!=null)
                    {
                        lstCopyEmail.add(pocDetailRec.CC_List_5__c);
                    }
                    lstCopyEmail.add('notifications@silver-peak.com');
                    
                    
                    if(vxCount>0)
                    {
                        List<EmailTemplate> template = [select Id from EmailTemplate where Name='POC WanOp Fulfillment Email VX' limit 1];
                        if(template.size() > 0)
                        {
                            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                            email.setTemplateId(template[0].Id);
                            email.setTargetObjectId(pocDetailRec.POC_Contact__c);
                            email.setCcAddresses(lstCopyEmail);
                            email.setWhatId(pocId);
                            email.setsaveAsActivity(false);
                            Id orgWideEmail = SilverPeakUtils.getOrganizationWideEmailId('notifications@silver-peak.com');
                            if(orgWideEmail != null)
                            {
                                email.setOrgWideEmailAddressId(orgWideEmail);
                            }
                            
                            email.setCcAddresses(lstCopyEmail);
                            Messaging.sendEmail(new List<Messaging.Email> {email}, true);
                        }
                    }
                    
                    if(vrxCount>0)
                    {
                        // Send Email to VRX
                        List<EmailTemplate> template = [select Id from EmailTemplate where Name='POC WanOp Fulfillment Email VRX' limit 1];
                        if(template.size() > 0)
                        {
                            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                            email.setTemplateId(template[0].Id);
                            email.setTargetObjectId(pocDetailRec.POC_Contact__c);
                            email.setCcAddresses(lstCopyEmail);
                            email.setWhatId(pocId);
                            email.setsaveAsActivity(false);
                            Id orgWideEmail = SilverPeakUtils.getOrganizationWideEmailId('notifications@silver-peak.com');
                            if(orgWideEmail != null)
                            {
                                email.setOrgWideEmailAddressId(orgWideEmail);
                            }
                            email.setCcAddresses(lstCopyEmail);
                            Messaging.sendEmail(new List<Messaging.Email> {email}, true);
                        }
                    }
                    lstPOCToUpdate.add(new Request__c(Id=pocId,Send_Email__c=false));
                }
            }
        }
        if(lstPOCToUpdate.size()>0)
        {
            update lstPOCToUpdate;
        }
    }
    private Set<Id> ValidateUnityOrchestrtatorCanBeAdded (Set<Request__c> setPOCRequests)
    {
        Set<Id> setResult= new Set<Id>();
        for(Request__c req: setPOCRequests)
        {
            List<Request__c> lstReq=[Select Id from Request__c where (NOT ID=:req.Id) and Opportunity__c =:req.Opportunity__c and Is_Unity_Cloud_Orchestrator__c=true and status__c in('Open','Approved To Ship','Pending Approvals')];
            List<Asset> lstAsset=[Select Id from Asset where AccountId=:req.Account_ID__c and Product2.Name like 'EC-ORCH-AAS%' and Status in('Customer Subscription Active','Customer Evaluation')];
            if((lstReq!=null && lstReq.size()>0)||(lstAsset!=null && lstAsset.size()>0))
            {
                setResult.add(req.Id);
            }
        }
        return setResult;
    }
    private Set<Id> CheckValidProductsAddedOnECPOCFlag(Map<Id,string> requestIds)
    {
        Set<string> ECProducts= new Set<string>();
        Set<string> NonECProducts= new Set<string>();
        Set<Id> setResult= new Set<Id>();
        for(Id recordId: requestIds.keyset())
        {
            List<Request__c> requestData =[Select Id,POC_Type__c,VirtualProduct1__c,VirtualProduct2__c,VirtualProduct3__c,VirtualProduct4__c,VirtualProduct5__c,
                                           PhysicalProduct1__c,PhysicalProduct2__c,PhysicalProduct3__c,PhysicalProduct4__c,PhysicalProduct5__c,Opportunity__r.Account.Partner_Type__c,Opportunity__r.Account.ECSP__c from Request__c where Id=:recordId ];
            if(requestData!=null && requestData.size()>0 && requestData.size()==1)
            {
                Request__c currRequest=requestData[0];
                if(currRequest.VirtualProduct1__c!=null && currRequest.VirtualProduct1__c.startsWith('EC-') )
                { 
                    ECProducts.add(currRequest.VirtualProduct1__c);
                }
                else if(currRequest.VirtualProduct1__c!=null && !currRequest.VirtualProduct1__c.startsWith('EC-') )
                {
                    NonECProducts.add(currRequest.VirtualProduct1__c); 
                }
                if(currRequest.VirtualProduct2__c!=null && currRequest.VirtualProduct2__c.startsWith('EC-') )
                { 
                    ECProducts.add(currRequest.VirtualProduct2__c);
                }
                else if(currRequest.VirtualProduct2__c!=null && !currRequest.VirtualProduct2__c.startsWith('EC-') )
                {
                    NonECProducts.add(currRequest.VirtualProduct2__c); 
                }
                
                if(currRequest.VirtualProduct3__c!=null && currRequest.VirtualProduct3__c.startsWith('EC-') )
                { 
                    ECProducts.add(currRequest.VirtualProduct3__c);
                }
                else if(currRequest.VirtualProduct3__c!=null && !currRequest.VirtualProduct3__c.startsWith('EC-') )
                {
                    NonECProducts.add(currRequest.VirtualProduct3__c); 
                }
                
                if(currRequest.VirtualProduct4__c!=null && currRequest.VirtualProduct4__c.startsWith('EC-') )
                { 
                    ECProducts.add(currRequest.VirtualProduct4__c);
                }
                else if(currRequest.VirtualProduct4__c!=null && !currRequest.VirtualProduct4__c.startsWith('EC-') )
                {
                    NonECProducts.add(currRequest.VirtualProduct4__c); 
                }
                
                if(currRequest.VirtualProduct5__c!=null && currRequest.VirtualProduct5__c.startsWith('EC-') )
                { 
                    ECProducts.add(currRequest.VirtualProduct5__c);
                }
                else if(currRequest.VirtualProduct5__c!=null && !currRequest.VirtualProduct5__c.startsWith('EC-') )
                {
                    NonECProducts.add(currRequest.VirtualProduct5__c); 
                }
                
                // Add the Physical Products
                if(currRequest.PhysicalProduct1__c!=null && currRequest.PhysicalProduct1__c.startsWith('EC-') )
                { 
                    ECProducts.add(currRequest.PhysicalProduct1__c);
                }
                else if(currRequest.PhysicalProduct1__c!=null && !currRequest.PhysicalProduct1__c.startsWith('EC-') )
                {
                    NonECProducts.add(currRequest.PhysicalProduct1__c); 
                }
                if(currRequest.PhysicalProduct2__c!=null && currRequest.PhysicalProduct2__c.startsWith('EC-') )
                { 
                    ECProducts.add(currRequest.PhysicalProduct2__c);
                }
                else if(currRequest.PhysicalProduct2__c!=null && !currRequest.PhysicalProduct2__c.startsWith('EC-') )
                {
                    NonECProducts.add(currRequest.PhysicalProduct2__c); 
                }
                
                if(currRequest.PhysicalProduct3__c!=null && currRequest.PhysicalProduct3__c.startsWith('EC-') )
                { 
                    ECProducts.add(currRequest.PhysicalProduct3__c);
                }
                else if(currRequest.PhysicalProduct3__c!=null && !currRequest.PhysicalProduct3__c.startsWith('EC-') )
                {
                    NonECProducts.add(currRequest.PhysicalProduct3__c); 
                }
                
                if(currRequest.PhysicalProduct4__c!=null && currRequest.PhysicalProduct4__c.startsWith('EC-') )
                { 
                    ECProducts.add(currRequest.PhysicalProduct4__c);
                }
                else if(currRequest.PhysicalProduct4__c!=null && !currRequest.PhysicalProduct4__c.startsWith('EC-') )
                {
                    NonECProducts.add(currRequest.PhysicalProduct4__c); 
                }
                
                if(currRequest.PhysicalProduct5__c!=null && currRequest.PhysicalProduct5__c.startsWith('EC-') )
                { 
                    ECProducts.add(currRequest.PhysicalProduct5__c);
                }
                else if(currRequest.PhysicalProduct5__c!=null && !currRequest.PhysicalProduct5__c.startsWith('EC-') )
                {
                    NonECProducts.add(currRequest.PhysicalProduct5__c); 
                }
                if(!currRequest.Opportunity__r.Account.ECSP__c)
                {
                    if((requestIds.get(recordId)=='EdgeConnect' && NonECProducts!=null && NonECProducts.size()>0 ) || (requestIds.get(recordId)=='WAN Op' && ECProducts!=null && ECProducts.size()>0 )) 
                    {
                        setResult.add(recordId);
                    }
                } 
            }
        }
        return setResult;
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
    private void HandlePOCStatusChange()
    {
        try
        {
            if(closedPocs.size() > 0)
            {
                PocRequestAutomationHelper.removePocLinkOnAsset(closedPocs);
            }
            if(pendingReturnPocs.size() > 0)
            {
                PocRequestAutomationHelper.createEvalRMA(pendingReturnPocs);
            }
            if(returnedPocs.size() > 0)
            {
                PocRequestAutomationHelper.closeRMAs(returnedPocs);
            }
            if(datesChangedPocs.size() > 0)
            {
                PocRequestAutomationHelper.updateAssetDate(datesChangedPocs);
            }
        }
        catch(PocRequestAutomationHelper.PocRequestAutomationException ex)
        {
            /* for(Request__c request : newItems.values())
{
request.addError(ex.getMessage());
}*/
        }
    }
    private void PopulatePOCApprovers(Map<Id,Id> mapReqId)
    {
        Map<Id,Opportunity> mapOppId= new Map<Id,Opportunity>(); 
        if(mapReqId.size()>0)
        {
            List<Opportunity> lstOpportunity=[Select Id,Account.ECSP__c,OwnerId,Owner.ManagerId,Owner.Manager.ManagerId,Technical_Responsible__c,Technical_Responsible__r.ManagerId,Technical_Responsible__r.Manager.ManagerId, GEO_Region__c from Opportunity where Id in:mapReqId.values()];
            for(Opportunity opp:lstOpportunity)
            {
                if(!mapOppId.containsKey(opp.Id))
                {
                    mapOppId.put(opp.Id,opp);
                }
            }
            List<Request__c> lstPocs= new List<Request__c>();
            for(Id reqId:mapReqId.keySet())
            {
                
                Opportunity finalOpp= mapOppId.get(mapReqId.get(reqId));
                Request__c pocToUpdate= new Request__c(Id=reqId);
                pocToUpdate.RSM__c=finalOpp.OwnerId!=null?finalOpp.OwnerId:null;
                pocToUpdate.SE__c=finalOpp.Technical_Responsible__c!=null?finalOpp.Technical_Responsible__c:null;
                if(finalOpp.Account.ECSP__c || finalOpp.GEO_Region__c.startsWith('APAC') || finalOpp.GEO_Region__c.startsWith('EMEA') || finalOpp.GEO_Region__c.startsWith('ANZ'))
                {
                    pocToUpdate.RSM_Manager__c=(finalOpp.Owner.ManagerId!=null && !removeUsers.contains(finalOpp.Owner.ManagerId) )?finalOpp.Owner.ManagerId:null;
                    pocToUpdate.RSM_VP_Sales__c=(finalOpp.Owner.Manager.ManagerId!=null && !removeUsers.contains(finalOpp.Owner.Manager.ManagerId))?finalOpp.Owner.Manager.ManagerId:null;
                    pocToUpdate.SE_Manager__c=(finalOpp.Technical_Responsible__r.ManagerId!=null && !removeUsers.contains(finalOpp.Technical_Responsible__r.ManagerId))?finalOpp.Technical_Responsible__r.ManagerId:null;
                    pocToUpdate.SE_Director__c=(finalOpp.Technical_Responsible__r.Manager.ManagerId!=null && !removeUsers.contains(finalOpp.Technical_Responsible__r.Manager.ManagerId) )?finalOpp.Technical_Responsible__r.Manager.ManagerId:null;
                }
                else
                {
                    pocToUpdate.RSM_Manager__c=finalOpp.Owner.ManagerId!=null?finalOpp.Owner.ManagerId:null;
                    pocToUpdate.RSM_VP_Sales__c=finalOpp.Owner.Manager.ManagerId!=null?finalOpp.Owner.Manager.ManagerId:null;
                    pocToUpdate.SE_Manager__c=finalOpp.Technical_Responsible__r.ManagerId!=null?finalOpp.Technical_Responsible__r.ManagerId:null;
                    pocToUpdate.SE_Director__c=finalOpp.Technical_Responsible__r.Manager.ManagerId!=null?finalOpp.Technical_Responsible__r.Manager.ManagerId:null;
                }
                pocToUpdate.Trigger_POC_Approvers__c=false;
                lstPocs.add(pocToUpdate);
                
            }
            if(lstPocs.size()>0)
                update lstPocs;
        }
        
    }
}