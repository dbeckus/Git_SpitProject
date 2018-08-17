public class CaseTriggerHandler implements ITriggerHandler {
    
    public CaseTriggerHandler()
    {
        
    }
    public Boolean IsDisabled()
    {
        return false;
    }
    public void BeforeInsert(List<SObject> newItems)
    {
        
    }
    public void BeforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems)
    {
        
    }
    public void BeforeDelete(Map<Id,SObject> oldItems)
    {
        
    }
    public void AfterInsert(Map<Id, SObject> newItems) 
    {
        Map<Id,Id> mapCaseAcc = new map<Id,Id>();
        if(newItems!=null && newItems.size()>0)
        {
            for (Id caseId : newItems.keyset())
            {
                Case newCase= (Case)newItems.get(caseId);
                if(newCase.RecordTypeId =='012500000005AuO' || newCase.RecordTypeId == '012500000005Aui')
                {
                    mapCaseAcc.put(newcase.Id, newCase.AccountId);
                }
            }
            CreateDECaseNotes(mapCaseAcc);
        }
    }
    public void AfterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) 
    {
        
    }
    public void AfterDelete(Map<Id, SObject> oldItems) 
    {
        
    }
    public void AfterUndelete(Map<Id, SObject> newItems) 
    {
        
    }
    
    private void CreateDECaseNotes(Map<Id,Id> mapCaseAccounts)
    {
        if(mapCaseAccounts != null && mapCaseAccounts.size()>0)
        {
            List<DE_Case_Note__c> lstDECaseNotes = new List<DE_Case_Note__c>();
            Id caseAccountId;
            List<DE_Note__c> lstAssocDENotes = [Select Id, Account_Name__c from DE_Note__c where Account_Name__c IN :mapCaseAccounts.values()];
            if(lstAssocDENotes != null && lstAssocDENotes.size()>0)
            {
                for(Id caseId: mapCaseAccounts.keySet())
                {
                    caseAccountId = mapCaseAccounts.get(caseId);
                    if(caseAccountId != null)
                    {
                        for(DE_Note__c de: lstAssocDENotes)
                        {
                            if(de.Account_Name__c == caseAccountId)
                            {
                                DE_Case_Note__c decnote= new DE_Case_Note__c();
                                decnote.Case_Number__c = caseId;
                                decnote.DE_Note__c = de.Id;
                                lstDECaseNotes.add(decnote);
                            }
                        }
                    }
                }
            }
            if(lstDECaseNotes != null && lstDECaseNotes.size()>0)
            {
                insert lstDECaseNotes;
            }    
        } 
    }
}