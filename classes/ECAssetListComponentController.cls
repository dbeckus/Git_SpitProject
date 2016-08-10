public class ECAssetListComponentController {

 public ECAssetListComponentController ()
    {
    }
    
    public Id RequestId { get; set; }
    public Date DefaultDate
    { 
        get{
                return Date.today();
            }
    }
   
    public List<Asset> Assets
    {
        get
        {
            if(RequestId != null)
            {
                return [select Id, Name, Model__c,SerialNumber,Licenses_Nodes__c,Bandwidth_Nodes__c,License_End_Date__c from Asset where POCRequest__c=:RequestId and Product2.Family='Virtual Image'];
            }
            else
            {
                return new List<Asset>();
            }
        }
    }
  
}