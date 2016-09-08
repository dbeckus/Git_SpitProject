public class CapCaseController {
    
    public boolean IsCAPAccount {get;set;}
    
    public CapCaseController(ApexPages.StandardController stdController)
    {
        Id caseId=stdController.getId();
        Case caseInfo=[Select Id,AccountId, Account.Name,Account.IsCap__c,IsClosed from Case where Id=:caseId];
        if(caseInfo!=null)
        {
            IsCAPAccount= caseInfo.Account.IsCap__c && !caseInfo.IsClosed;
        }
        
    }

}