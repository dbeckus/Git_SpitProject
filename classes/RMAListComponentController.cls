public class RMAListComponentController {
     public RMAListComponentController()
    {
    }
    
    public Id RequestId { get; set; }  
    
    public List<RMA__c> RMAs
    {
        get
        {
            if(RequestId != null)
            {
                return [select Id,Name from RMA__c where Request__c=:RequestId and Status__c!='Closed'];
            }
            else
            {
                return new List<RMA__c>();
            }
        }
    }
     
    

}