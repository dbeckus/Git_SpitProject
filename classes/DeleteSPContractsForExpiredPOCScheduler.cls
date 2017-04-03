public class DeleteSPContractsForExpiredPOCScheduler implements Schedulable{
    public void execute(SchedulableContext sc)
    {
        List<Contract> lstContractsToDelete= new List<Contract>();
        List<Request__c> lstData = [select Id,Contract_Number__c,(Select Id from Assets__r where Product2.Family='Virtual Image' and Status='Customer Evaluation') from Request__c where Opportunity__r.Account.ECSP__c=true and Target_End_Date__c=:Date.today() and Status__c in('Pending Return','Pending Return - Invoiced','Closed - Returned','Closed - Won') and Contract_Number__c!=null and Contract_Number__r.Contract_Type__c='Evaluation'];
        if(lstData!=null && lstData.size()>0)
        {
            for(Request__c item:lstData)
            {
                List<Asset> lstAssets=item.Assets__r;
                if(lstAssets.size()==0)
                {
                    lstContractsToDelete.add(new Contract(Id=item.Contract_Number__c));
                }
                if(lstContractsToDelete!=null && lstContractsToDelete.size()>0)
                {
                    delete lstContractsToDelete;
                }
                
            }
        }
        
        
    }
}