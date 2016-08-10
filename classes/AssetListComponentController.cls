/*
 * controller of the component AssetList
 */
public class AssetListComponentController
{
    public AssetListComponentController()
    {
    }
    
    public Id RequestId { get; set; }
    public Id RmaId { get; set; }
    public Id ShipmentId { get; set; }
    
    public List<Asset> Assets
    {
        get
        {
            if(RequestId != null)
            {
                return [select Id, Model__c, SerialNumber from Asset where POCRequest__c=:RequestId];
            }
            else if(RmaId != null)
            {
                Set<Id> rmaIds = new Set<Id>();
                for(RMA_Item__c item : [select Id, Asset__c from RMA_Item__c where RMA__c=:RmaId])
                {
                    rmaIds.add(item.Asset__c);
                }
                return [select Id, Model__c, SerialNumber from Asset where Id in :rmaIds];
            }
            else if(ShipmentId != null)
            {
                return [select Id, Model__c, SerialNumber from Asset where Id in (select Asset__c from Shipped_Line__c where Shipment_Id__c=:ShipmentId)];
            }
            else
            {
                return new List<Asset>();
            }
        }
    }
     
    @IsTest
    static void test()
    {        
        Contact contact = new Contact(LastName = 'acme');
        insert contact;  
        AssetListComponentController controller = new AssetListComponentController();
        controller.RequestId = contact.Id;
        List<Asset> assets = controller.Assets;
        controller.RequestId = null;
        controller.RmaId = contact.Id;
        List<Asset> assets2 = controller.Assets;
    }   
}