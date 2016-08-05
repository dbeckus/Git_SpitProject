trigger SetDefaultTechResponsibility on Opportunity (before insert,before update) {
    
    Map<Id, Id> defaultTRs = new Map<Id, Id>(); //key: User Id => value: User Default TR Id
    Set<Id> accids= new Set<id>();
    Map<Id, Id> defaultAccRSM = new Map<Id, Id>();
    if(!SilverPeakUtils.BypassingTriggers)
    {
        for(Opportunity opportunity : trigger.new)
        {
            if(opportunity.Type != 'Marketplace' && opportunity.Technical_Responsible__c == null && opportunity.StageName!='New')
            {
                if(opportunity.AccountId!=null)
                {
                    accids.add(opportunity.AccountId);
                    
                }
            }
            
        }
        if(accids.size()>0)
        {
            List<Account> lstAcctDtl=[Select Id,Patch__r.RSM__c from Account where id in: accIds];
            if(lstAcctDtl!=null && lstAcctDtl.size()>0)
            {
                for(Account item: lstAcctDtl)
                {
                    defaultTRs.put(item.Patch__r.RSM__c, null);
                    defaultAccRSM.put(item.Id,item.Patch__r.RSM__c);
                }
                
            }
            if(defaultTRs.size()>0)
            {
                for(User user : [select Id, Default_TR__c from User where Id in :defaultTRs.keySet() and Default_TR__c != null])
                {
                    defaultTRs.put(user.Id, user.Default_TR__c);
                }
                for(Opportunity opportunity : trigger.new)
                {
                    if(opportunity.Technical_Responsible__c == null)
                    {
                        Id rsmId=defaultAccRSM.get(opportunity.AccountId);
                        if(defaultTRs.containsKey(rsmId))
                        {
                            
                            opportunity.Technical_Responsible__c = defaultTRs.get(rsmId);
                            
                        }
                    }
                }
            }   
        }
    }
}