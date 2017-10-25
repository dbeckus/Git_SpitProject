public class OpportunityTriggerHandler implements ITriggerHandler {
    
    public OpportunityTriggerHandler()
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
            for(Opportunity newOpp:(List<Opportunity>)newItems)
            {
                if(!SilverPeakUtils.BypassingTriggers)
                {
                    if(newOpp.LeadSource==null)
                    {
                        newOpp.LeadSource=newOpp.Opportunity_Source__c;
                    }
                }
                System.debug('newOpp.CloseDate'+newOpp.CloseDate);
                newOpp.Fiscal_Quarter_Name__c=RetrieveQuarterName(newOpp.CloseDate);
            }
        }
        
    }
    public void BeforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) 
    {
        Set<Id> notAllowClosedStageOpps= new Set<Id>();
        Schema.Describefieldresult F = Opportunity.LeadSource.getDescribe();
        List<Schema.Picklistentry> P = F.getPicklistValues();
        Set<String> options = new Set<String>();
        for(Schema.Picklistentry ple : P)
        {
            options.add(ple.getValue());
        }
        if(newItems!=null && newItems.size()>0)
        {
            List<Asset> lstAssets=[Select Id,POCRequest__r.Opportunity__c from Asset where Product2.Family='Product' and POCRequest__c  in (Select Id from Request__c where Opportunity__c in :newItems.keyset())];
            notAllowClosedStageOpps=CheckIfAssetsCreatedForClosedOpp(lstAssets);
            for (Id oppId : newItems.keyset())
            {
                Opportunity newOpp=(Opportunity)newItems.get(oppId);
                Opportunity oldOpp=(Opportunity)oldItems.get(oppId);
                
                if(newOpp.CloseDate!=oldOpp.CloseDate)
                {
                    newOpp.Fiscal_Quarter_Name__c= RetrieveQuarterName(newOpp.CloseDate);
                }
                
                if(!SilverPeakUtils.BypassingTriggers)
                {
                    if(newOpp.Opportunity_Source__c!=oldOpp.Opportunity_Source__c)
                    {
                        if(!options.contains(newOpp.LeadSource))
                        {
                            newOpp.LeadSource=newOpp.Opportunity_Source__c;
                        }
                    }
                }
                
                if(!newOpp.IsClosed)
                {
                    if(oldOpp.Has_Active_POCs__c != newOpp.Has_Active_POCs__c)
                    {
                        if(newOpp.Has_Active_POCs__c)
                        {
                            newOpp.POC_Start_Date__c = Date.today();
                            newOpp.POC_End_Date__c   = Date.today();
                            newOpp.POC_Duration__c   = oldOpp.POC_Age__c;
                        }
                        else
                        {
                            newOpp.POC_End_Date__c   = Date.today();
                        }
                    }
                }
                else if(newOpp.IsClosed && !oldOpp.IsClosed)
                {
                    if(newOpp.StageName=='Closed Dead'|| newOpp.StageName=='Closed Lost' || newOpp.StageName=='Closed Deleted') 
                    {
                        if(notAllowClosedStageOpps!=null && notAllowClosedStageOpps.size()>0 && notAllowClosedStageOpps.contains(newOpp.Id))
                        {
                            newOpp.addError('This selected stage cannot be updated as it has active physical assets.');
                        }
                    }
                    if(newOpp.Has_Active_POCs__c)
                    {
                        newOpp.POC_End_Date__c = Date.today();
                    } 
                }
            }
            
        }
    }
    public void BeforeDelete(Map<Id,SObject> oldItems) 
    {
        if(oldItems.size()>0)
        {
            User currentUser = [select Id, Profile.PermissionsModifyAllData, Profile.PermissionsCustomizeApplication from User where Id=:UserInfo.getUserId() limit 1];
            Boolean isAdmin = currentUser.Profile.PermissionsModifyAllData && currentUser.Profile.PermissionsCustomizeApplication;
            for(Id oppId:oldItems.keySet())
            {
                Opportunity opp=(Opportunity)oldItems.get(oppId);
                if(!isAdmin)
                {
                    opp.addError('You are not allowed to delete opportunities.');
                }
            }
        }
    }
    public void AfterInsert(Map<Id, SObject> newItems) 
    {
        List<Id> lstOpps= new List<Id>();
        List<OpportunityContactRole>lstContactRole= new List<OpportunityContactRole>();
        Set<Id> oppNeedsPatchAssign = new Set<Id>();
        Set<Id> oppNeedsTeamAssign = new Set<Id>();
        List<Opportunity> oppsNeedSharing = new List<Opportunity>();
        List<Id> oppIdsNeedSharing = new List<Id>();
        if(newItems!=null && newItems.size()>0)
        {
            for (Id oppId : newItems.keyset())
            {
                Opportunity newOpp=(Opportunity)newItems.get(oppId);
                if(newOpp.CampaignId == SalesDevelopmentHelper.getSDcampaign())
                {
                    lstOpps.add(oppId);
                }
                if(newOpp.Type != 'Marketplace')
                {
                    if(newOpp.Patch__c == null)
                    {
                        oppNeedsPatchAssign.add(newOpp.Id);
                    }
                    else
                    {
                        oppNeedsTeamAssign.add(newOpp.Id);
                    }
                }
                if(newOpp.LeadSource=='Deal Registration')
                {
                    oppsNeedSharing.add(newOpp);
                    oppIdsNeedSharing.add(newOpp.Id);
                }
            }
            ShareOppToRegisteredPartner(oppsNeedSharing,oppIdsNeedSharing);
            LinkOpportunityToPatch(oppNeedsPatchAssign, oppNeedsTeamAssign);
            ResetPrimaryCampaignSource(lstOpps);
            //SetContactRole(newItems.keyset());
        }
    }
    public void AfterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) 
    {     
        Set<Id> wanStartOpps= new Set<Id>();
        Set<Id> setAccIds= new Set<Id>();
        Set<Id> oppNeedsPatchAssign = new Set<Id>();
        Set<Id> oppNeedsTeamAssign = new Set<Id>();
        List<Opportunity> oppsNeedSharing = new List<Opportunity>();
        List<Id> oppIdsNeedSharing = new List<Id>();
        if(newItems!=null && newItems.size()>0)
        {
            for (Id oppId : newItems.keyset())
            {
                Opportunity newOpp=(Opportunity)newItems.get(oppId);
                Opportunity oldOpp=(Opportunity)oldItems.get(oppId);
                if(!SilverPeakUtils.BypassingTriggers)
                {  
                    if(newOpp.WANstartCaseCreated__c==null)
                    {
                        newOpp.WANstartCaseCreated__c=false;
                    }
                    if (newOpp.IsWon && newOpp.WANstart_count__c > 0 && newOpp.WANstartCaseCreated__c == false)
                    {
                        if(newOpp.IsWon != oldOpp.IsWon || newOpp.WANstart_count__c != oldOpp.WANstart_count__c || newOpp.WANstartCaseCreated__c != oldOpp.WANstartCaseCreated__c)
                            wanStartOpps.add(newOpp.Id);
                    }
                    
                }
                if(newOpp.Type != 'Marketplace' && newOpp.IsClosed == false)
                {
                    if(newOpp.Patch_Locked__c == false)
                    {
                        if(newOpp.Trigger_Assignment__c || newOpp.AccountId != oldOpp.AccountId)
                        {
                            oppNeedsPatchAssign.add(newOpp.Id);
                            oppNeedsTeamAssign.add(newOpp.Id);
                            continue;
                        }
                    }
                    if(newOpp.Patch__c != oldOpp.Patch__c || newOpp.Trigger_Assignment__c || newOpp.OwnerId != oldOpp.OwnerId)
                    {
                        oppNeedsTeamAssign.add(newOpp.Id);
                    }
                }
                if(newOpp.StageName!=oldOpp.StageName)
                {
                    if(newOpp.AccountId!=null)
                    {
                        setAccIds.add(newOpp.AccountId);
                    }
                }
                if(newOpp.LeadSource=='Deal Registration')
                {
                    if(isChanged(oldOpp, newOpp, new String[] { 'LeadSource', 'OwnerId', 'Registered_Distributor_Contact__c', 'Registering_Partner_Sales_Rep__c', 'Registered_Distributor__c', 'Registering_Partner__c'}))
                    {
                        oppsNeedSharing.add(newOpp);
                        oppIdsNeedSharing.add(newOpp.Id);
                    }
                }
            }
            ShareOppToRegisteredPartner(oppsNeedSharing,oppIdsNeedSharing);
            LinkOpportunityToPatch(oppNeedsPatchAssign, oppNeedsTeamAssign);
            CalculateFirstCustomerDate(setAccIds);
            //SetContactRole(newItems.keyset());
            CreateWANStartCase(wanStartOpps);
            SycnOpportunityToQuoteHandler.sycnOpportunityDateToQuoteDateOnUpdate((Map<Id,Opportunity>)oldItems,(Map<Id,Opportunity>)newItems);
            UpdateFirstOpportunityWinCheckBox(setAccIds);
        }
        
    }
    public void AfterDelete(Map<Id, SObject> oldItems) 
    {
        if(oldItems!=null && oldItems.size()>0)
        {
            for (Id oppId : oldItems.keyset())
            {
                Opportunity oldOpp=(Opportunity)oldItems.get(oppId);
            }
            if(!SilverPeakUtils.BypassingTriggers)
            {
                OpportunityMergeController.removeOrphanedPOC();
            }  
            
        }
    }
    public void AfterUndelete(Map<Id, SObject> newItems) 
    {
        if(newItems!=null && newItems.size()>0)
        {
            for (Id oppId : newItems.keyset())
            {
                Opportunity newOpp=(Opportunity)newItems.get(oppId);
            }
        }
    }
    //checks if the fields are changed in the sObjects
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
    private void ShareOppToRegisteredPartner(List<Opportunity> opps, List<Id> oppIds)
    {
        if(opps.size() > 0)
        {
            
            ShareLeadAndOpportunityToPartnerHelper.willShareOpportunities(oppIds);
            
        }
    }
    
    
    private void CalculateFirstCustomerDate(Set<Id> acctIds)
    {
        List<Account> lstAccToUpdate= new List<Account>();  
        if(acctIds!=null && acctIds.size()>0)
        {
            List<Account> lstAccounts =[Select Id,First_Asset_Quarter__c,Is_Partner_Initiated_Account__c ,(Select Id, CloseDate,Deal_Reg__c,First_Win_Opportunity__c from Opportunities where StageName='Closed Won' order by CloseDate asc) from Account where Id in:acctIds ];
            
            for(Account item: lstAccounts)
            {
                System.debug('AcctIds');
                Date minDate=null;
                boolean partnerInitated;
                List<Opportunity> lstCurrOpp=item.Opportunities;
                if(lstCurrOpp!=null && lstCurrOpp.size()>0)
                {
                    minDate= lstCurrOpp[0].CloseDate;
                    partnerInitated=lstCurrOpp[0].Deal_Reg__c;
                    string currentFiscalQuarter =RetrieveQuarterName(minDate);
                    if(item.First_Asset_Quarter__c!=currentFiscalQuarter || item.Is_Partner_Initiated_Account__c!=partnerInitated)
                    {
                        lstAccToUpdate.add(new Account(Id=item.Id,First_Asset_Quarter__c=currentFiscalQuarter,Is_Partner_Initiated_Account__c=partnerInitated));
                    }
                    
                }
                else
                {
                    lstAccToUpdate.add(new Account(Id=item.Id,First_Asset_Quarter__c='',Is_Partner_Initiated_Account__c=false));
                }
            }
            
            if(lstAccToUpdate.size()>0)
            {
                update lstAccToUpdate;
            }
            
        }
    }
    
    private void UpdateFirstOpportunityWinCheckBox(Set<Id> acctIds)
    {
        List<Opportunity> lstOppToUpdate= new List<Opportunity>();
        if(acctIds!=null && acctIds.size()>0)
        {
            
            List<Account> lstAccounts =[Select Id,(Select Id,Name, StageName,CloseDate,Deal_Reg__c,First_Win_Opportunity__c from Opportunities  order by CloseDate asc, LastModifiedDate asc) from Account where Id in:acctIds ];
            for(Account item: lstAccounts)
            {
                System.debug(item.Id);
                boolean firstOpp=false;
                List<Opportunity> lstCurrOpps=item.Opportunities;
                System.debug('lstCurrOpps '+ lstCurrOpps.size());
                if(lstCurrOpps!=null && lstCurrOpps.size()>0)
                {
                    for(integer counter=0; counter<lstCurrOpps.size(); counter++)
                    {
                        Opportunity currOpp=lstCurrOpps[counter];
                        if(currOpp.StageName=='Closed Won' && !firstOpp)
                        {
                            firstOpp=true;
                            if(!currOpp.First_Win_Opportunity__c)
                            {
                                currOpp.First_Win_Opportunity__c=true;
                                lstOppToUpdate.add(currOpp);
                            }
                            
                        }
                        else
                        {
                            if(currOpp.First_Win_Opportunity__c)
                            {
                                currOpp.First_Win_Opportunity__c=false;
                                lstOppToUpdate.add(currOpp);
                            }
                            
                        }
                        
                    }
                }
                
            }
            if(lstOppToUpdate.size()>0)
            {
                update lstOppToUpdate;
            }
            
            
        }
        
    }
    
    private  string RetrieveQuarterName(Date closeDate)
    {
        List<Period> lstPeriod =[Select Type, StartDate, EndDate, QuarterLabel, PeriodLabel, Number, FiscalYearSettings.Name From Period  where Type ='Quarter' order by StartDate];
        if(lstPeriod!=null && lstPeriod.size()>0)
        {
            for(Period item: lstPeriod)
            {
                if(item.StartDate<=closeDate && closeDate<=item.EndDate)
                {
                    return item.FiscalYearSettings.Name + 'Q' + item.Number;
                }
            }
        }
        return null;
    }
    
    private void LinkOpportunityToPatch(Set<Id> setPatchAssign, Set<Id> setTeamAssign)
    {
        if(setPatchAssign.size() > 0)
        {
            if(System.isFuture() || System.isBatch())
            {
                PatchRuleHelper.assignPatch(new List<Id>(setPatchAssign));
            }
            else
            {
                PatchRuleHelper.willAssignPatch(new List<Id>(setPatchAssign));
                List<Opportunity> opps = new List<Opportunity>();
                for(Id oppId : setPatchAssign)
                {
                    opps.add(new Opportunity(Id=oppId, Trigger_Assignment__c=false, Bypassing_Validation__c=true));
                }
                update opps;
            }
        }
        if(setTeamAssign.size() > 0)
        {
            PatchRuleHelper.assignTeamMembers(new List<Id>(setTeamAssign));
        }
    }
    /* private void SetContactRole(Set<Id> oppIds)
{
List<OpportunityContactRole>lstContactRole= new List<OpportunityContactRole>();
List<OpportunityContactRole> oppCR = [select id, role from OpportunityContactRole where 
opportunityid in :oppIds AND role= null];

if(oppCR.size() > 0)
{
for(OpportunityContactRole item: oppCR)
{
item.Role = 'Contact';
lstContactRole.add(item);
}

}
if(lstContactRole.size()>0)
{
update lstContactRole;
}
}*/
    private Set<Id> CheckIfAssetsCreatedForClosedOpp(List<Asset> lstAssets)
    {
        Set<Id> setOppIds= new Set<Id>();
        if(lstAssets!=null && lstAssets.size()>0)
        {
            for(Asset asset: lstAssets)
            {
                setOppIds.add(asset.POCRequest__r.Opportunity__c);
            }
        }
        return setOppIds;
    }
    private void ResetPrimaryCampaignSource(List<Id> setOpps)
    {
        if(setOpps.size() > 0)
        {
            if(System.isFuture())
            {
                SalesDevelopmentHelper.ResetPrimaryCampaignSource(setOpps);
            }
            else
            {
                SalesDevelopmentHelper.willResetPrimaryCampaignSource(setOpps);
            }
        }
    }
    private void CreateWANStartCase(Set<Id> oppIds)
    {
        List<Case> cases = new List<Case>();
        Id TechSupportQueue = '00G30000000mEL4';
        if(oppIds!=null && oppIds.size()>0)
        {
            List<Opportunity> opps = new List<Opportunity>();
            for(Opportunity opp : [select Id, AccountId, Account.Name, Technical_Responsible__c, (select Id from OpportunityLineItems where PricebookEntry.ProductCode in('300019-002','300148-001')) from Opportunity where Id in :oppIds])
            {
                if (opp.AccountId != null)
                {
                    Case newCase = new Case(Subject='New WANstart for ' + opp.Account.Name, AccountId=opp.AccountId);
                    if(opp.Technical_Responsible__c != null)
                    {
                        newCase.OwnerId = opp.Technical_Responsible__c;
                    }
                    else
                    {
                        newCase.OwnerId = TechSupportQueue;
                    }
                    if(opp.OpportunityLineItems.size() > 0)
                    {
                        newCase.Type = 'WANstart Services';
                        newCase.Status = 'Staged';
                    }
                    else
                    {
                        newCase.Type = 'WANstart Bundled';
                        newCase.Status = 'Staged';
                    }
                    cases.add(newCase);
                    opps.add(new Opportunity(Id=opp.Id, WANstartCaseCreated__c=true));
                }
            }
            if(cases.size() > 0)
            {
                try
                {
                    insert cases;
                    update opps;
                }
                catch(Exception ex)
                {
                    Trigger.new[0].addError(ex.getMessage());
                }
            }
        }
    }
}