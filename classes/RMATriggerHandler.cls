public class RMATriggerHandler implements ITriggerHandler {
    Set<Id> caseIds = new Set<Id>();
    Map<Id,List<AccountTeamMember>> managerMembers = new Map<Id,List<AccountTeamMember>> ();
    Map<Id,List<AccountTeamMember>> engineerMembers = new Map<Id,List<AccountTeamMember>>();
    public RMATriggerHandler()
    {
        
    }
    
    public Boolean IsDisabled()
    {
        return false;
    }
    public void BeforeInsert(List<SObject> newItems) 
    {
        Set<Id> accIds= new Set<Id>();
        if(newItems!=null && newItems.size()>0)
        {
            ClassifyAccountTeamMember(newItems);
            for(RMA__c newRma: (List<RMA__c>) newItems)
            {
                accIds.add(newRma.Account__c);
                CopyAccountTeamEmailToRMA(newRMA,managerMembers.get(newRMA.Account__c),engineerMembers.get(newRMA.Account__c));
            } 
        }
        
    }
    public void BeforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) 
    {
        Set<Id> accIds= new Set<Id>();
        if(newItems!=null && newItems.size()>0)
        {
            ClassifyAccountTeamMember(newItems.values());
            for(Id rmaId: newItems.keyset())
            {
                RMA__c newRMA= (RMA__c) newItems.get(rmaId);
                RMA__c oldRMA= (RMA__c) oldItems.get(rmaId);
                CopyAccountTeamEmailToRMA(newRMA,managerMembers.get(newRMA.Account__c),engineerMembers.get(newRMA.Account__c));
            }
        }
    }
    public void BeforeDelete(Map<Id,SObject> oldItems) 
    {
        
    }
    public void AfterInsert(Map<Id, SObject> newItems) 
    {
        
        if(newItems!=null && newItems.size()>0)
        {
            for (Id rmaId : newItems.keyset())
            {
                RMA__c newRMA= (RMA__c) newItems.get(rmaId);
                if(newRMA.Case__c != null)
                {
                    caseIds.add(newRMA.Case__c);
                }
            }
            UpdateRMACountOnCase();
        }
    }
    public void AfterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) 
    {    
        Set<Id> setRMAs= new Set<Id>();
         Set<Id> setDispatchRMA= new Set<Id>();
        Set<Id> setRMADispatchIds= new Set<Id>();
        if(newItems!=null && newItems.size()>0)
        {
            for (Id rmaId : newItems.keyset())
            {
                RMA__c newRMA= (RMA__c) newItems.get(rmaId);
                RMA__c oldRMA= (RMA__c) oldItems.get(rmaId);
                if(newRMA.Type__c=='Advance Replace'&& newRMA.Status__c=='In FA/Recd' && oldRMA.Status__c!=newRMA.Status__c)
                {
                    setRMAs.add(rmaId);
                }
                if(newRMA.Status__c == 'Dispatched' && oldRMA.Status__c != 'Dispatched')
                {
                    setRMADispatchIds.add(rmaId);
                }
                if(newRMA.Case__c != oldRma.Case__c)
                {
                    if(newRMA.Case__c != null)
                    {
                        caseIds.add(newRMA.Case__c);
                    }
                    if(oldRma.Case__c != null)
                    {
                        caseIds.add(oldRma.Case__c);
                    }
                }
                if(newRMA.LineCount__c==1)
                {
                    if(oldRma.Status__c != 'Dispatch Rejected' && newRma.Status__c == 'Dispatch Rejected' && hasErrorMessage(newRma.Note_Loc_1__c))
                    {
                        setDispatchRMA.add(newRMA.Id);
                    }
                }
                
            }
            ChangeRMAItemProduct(setDispatchRMA);
            UpdateRMACountOnCase();
            DispatchRMAItem(setRMADispatchIds);
            SendNotificationtoHardwareEngineering(setRMAs);
        }
        
    }
    public void AfterDelete(Map<Id, SObject> oldItems) 
    {
        if(oldItems!=null && oldItems.size()>0)
        {
            for (Id rmaId : oldItems.keyset())
            {
                RMA__c oldRMA= (RMA__c) oldItems.get(rmaId);
                if(oldRMA.Case__c != null)
                {
                    caseIds.add(oldRMA.Case__c);
                }
            }
            UpdateRMACountOnCase();
        }
    }
    public void AfterUndelete(Map<Id, SObject> newItems) 
    {
        if(newItems!=null && newItems.size()>0)
        {
            for (Id rmaId : newItems.keyset())
            {
                RMA__c newRMA= (RMA__c) newItems.get(rmaId);
                if(newRMA.Case__c != null)
                {
                    caseIds.add(newRMA.Case__c);
                }
            }
            UpdateRMACountOnCase();
        }
    }
    
    private void UpdateRMACountOnCase()
    {
        if(caseIds!=null && caseIds.size()>0)
        {
            List<Case> updatingCases = new List<Case>();
            for(Id caseId : caseIds)
            {
                Integer count = [select count() from RMA__c where Case__c=:caseId];
                Case updatingCase = new Case(Id = caseId, RMA_Count__c = count);
                updatingCases.add(updatingCase);
            }
            update updatingCases;
        }
        
    }
    private void ClassifyAccountTeamMember(List<RMA__c> lstRMA)
    {
       Set<Id> accIds= new Set<Id>();
        
        for(RMA__c req: lstRMA)
        {
            accIds.add(req.Account__c);
        }
        List<AccountTeamMember> lstData= [SELECT Id, AccountId, User.Email, TeamMemberRole FROM AccountTeamMember WHERE AccountId in :accIds AND (TeamMemberRole = 'Account Manager' OR TeamMemberRole = 'Systems Engineer')];
        for(Id acctId: accIds)
        {
            List<AccountTeamMember> lstManager=new List<AccountTeamMember>();
            List<AccountTeamMember> lstSE=new List<AccountTeamMember>();
            for(AccountTeamMember member : lstData)
            {
                if(member.TeamMemberRole == 'Account Manager' && member.AccountId== acctId)
                {
                    lstManager.add(member);            
                }
                else if(member.TeamMemberRole == 'Systems Engineer' && member.AccountId== acctId)
                {          
                    lstSE.add(member);
                }
            }
            managerMembers.put(acctId,lstManager);
            engineerMembers.put(acctId,lstSE);
        }
    }    
    private void DispatchRMAItem(Set<Id> setRMAIds)
    {
        List<RMA_Item__c> items = new List<RMA_Item__c>();
        if(setRMAIds!=null && setRMAIds.size()>0)
        {
            items = [select Id from RMA_Item__c where RMA__c in:setRMAIds];
            if(items.size() > 0)
            {
                update items;
            }
        }
        
    }
    private void ChangeRMAItemProduct(Set<Id> rmaIds)
    {
        List<RMA_Item__c> rejectedItems = new List<RMA_Item__c>();
        for(RMA_Item__c item : [select Id, RMA__c, Product2__c, Product2__r.Use_System_Alternative__c, Product2__r.RMA_Primary_Replacement__c, Product2__r.RMA_Alternate_1__c, Product2__r.RMA_Alternate_2__c, Asset__r.Product2Id, Asset__r.Product2.RMA_Primary_Replacement__c, Asset__r.Product2.RMA_Alternate_1__c, Asset__r.Product2.RMA_Alternate_2__c, AltProdPreviouslyOrdered__c, AltProdPreviouslyOrdered__r.Use_System_Alternative__c, AltProdPreviouslyOrdered__r.RMA_Primary_Replacement__c, AltProdPreviouslyOrdered__r.RMA_Alternate_1__c, AltProdPreviouslyOrdered__r.RMA_Alternate_2__c from RMA_Item__c where RMA__c in :rmaIds])
        {
            Id currentProductId = item.Product2__c;
            Id originalProductId;
            Product2 originalProduct;
            if(item.AltProdPreviouslyOrdered__c == null)
            {
                originalProductId = currentProductId;
                originalProduct = item.Product2__r;
                item.AltProdPreviouslyOrdered__c = currentProductId;
            }
            else
            {
                originalProductId = item.AltProdPreviouslyOrdered__c;
                originalProduct = item.AltProdPreviouslyOrdered__r;
            }
            List<Id> alternateProductSequence;
            if(originalProduct.Use_System_Alternative__c)
            {
                Id systemProductId = (item.Asset__r.Product2.RMA_Primary_Replacement__c == null) ? item.Asset__r.Product2Id : item.Asset__r.Product2.RMA_Primary_Replacement__c;
                alternateProductSequence = new List<Id> { originalProductId, originalProduct.RMA_Primary_Replacement__c, systemProductId, item.Asset__r.Product2.RMA_Alternate_1__c, item.Asset__r.Product2.RMA_Alternate_2__c};
            }
            else
            {
                alternateProductSequence = new List<Id> { originalProductId, originalProduct.RMA_Primary_Replacement__c, originalProduct.RMA_Alternate_1__c, originalProduct.RMA_Alternate_2__c };
            }
            
            Boolean foundCurrent = false;
            for(Id productId : alternateProductSequence)
            {
                if(currentProductId == productId)
                {
                    foundCurrent = true;
                }
                if(foundCurrent && currentProductId != productId && productId != null)
                {
                    currentProductId = productId;
                    break;
                }
            }
            item.Product2__c = currentProductId;
            rejectedItems.add(item);
            
        }
        if(rejectedItems.size() > 0)
        {
            update rejectedItems;
        }
    }
    private static Boolean hasErrorMessage(String message)
    {
        if(message == null)
        {
            return false;
        }
        List<String> errorMessages;
        if(errorMessages == null)
        {
            errorMessages = new List<String> { 'Part Number Not Found', 'Part Number Not Active', 'Insufficient QOH', 'Serial Qty Doesn\'t Match Parts Qty' };
        }
        for(String m : errorMessages)
        {
            if(message.contains(m))
            {
                return true;
            }
        }
        return false;   
    }
    private void SendNotificationtoHardwareEngineering(Set<Id> setRMAIds)
    {
        if(setRMAIds!=null && setRMAIds.size()>0)
        {
            List<RMA_Item__c> rmaItems=[Select Id,Asset__r.Name,Asset__r.Product2.Name,RMA__r.Name,RMA__r.Disposition__c,RMA__r.Disposition_Notes__c,RMA__r.Account__r.Name,RMA__r.Contact__r.Id from RMA_Item__c where RMA__c in:setRMAIds];
            if(rmaItems!=null && rmaItems.size()>0)
            {
                List<Messaging.SingleEmailMessage> allmsg = new List<Messaging.SingleEmailMessage>();
                for(RMA_Item__c item:rmaItems)
                {
                    OrgWideEmailAddress owa = [select id, DisplayName, Address from OrgWideEmailAddress where DisplayName='Silver Peak Notifications' limit 1];
                    String templateString='S/N {0} ({1}) has been returned from {2} against {3}.\n\n\n';
                    String[] arguments = new String[] {item.Asset__r.Name, item.Asset__r.Product2.Name,item.RMA__r.Account__r.Name,item.RMA__r.Name};
                        string bodyText= string.format(templateString,arguments);
                    bodyText= bodyText+ 'Disposition Location: '+ item.RMA__r.Disposition__c +'\n';
                    bodyText= bodyText+ 'Notes: '+ item.RMA__r.Disposition_Notes__c;
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    mail.setSaveAsActivity(false);
                    mail.setOrgWideEmailAddressId(owa.id);
                    List<String> sendTo = new List<String>();
                    sendTo.add('hware@silver-peak.com');
                    mail.setToAddresses(sendTo);
                    mail.setSubject(item.RMA__r.Name +' faulty system received');
                    mail.setPlainTextBody (bodyText);
                    List<String> ccTo = new List<String>();
                    ccTo.add('notifications@silver-peak.com');
                    mail.setCcAddresses(ccTo);
                    allmsg.add(mail);
                    
                }
                if(allmsg.size()>0)
                {
                    if(!Test.isRunningTest())
                    {
                        Messaging.sendEmail(allmsg,false);
                    }
                    
                }
                
                
            }
        }
    }
    private void CopyAccountTeamEmailToRMA(RMA__c newRMA, List<AccountTeamMember> acctManager, List<AccountTeamMember> seManager )
    {
        newRMA.Account_Manager_Email_1__c=null;
        newRMA.Account_Manager_Email_2__c=null;
        newRMA.System_Engineer_Email_1__c=null;
        newRMA.System_Engineer_Email_2__c=null;
        if(acctManager!=null && acctManager.size()>0 )
        {
            if(acctManager[0].User.Email!=newRMA.Account_Manager_Email_1__c)
              newRMA.Account_Manager_Email_1__c=acctManager[0].User.Email;
            if(acctManager.size()>1)
            {
               if(acctManager[1].User.Email!=newRMA.Account_Manager_Email_2__c)
                 newRMA.Account_Manager_Email_2__c=acctManager[1].User.Email;
            }
        }
        
        
        if(seManager!=null && seManager.size()>0 )
        {
            if(seManager[0].User.Email!=newRMA.System_Engineer_Email_1__c)
              newRMA.System_Engineer_Email_1__c =seManager[0].User.Email;
            if(seManager.size()>1)
            {
                if(seManager[1].User.Email!= newRMA.System_Engineer_Email_2__c)
                   newRMA.System_Engineer_Email_2__c =seManager[1].User.Email;
               
            }
        }
        
    }
}