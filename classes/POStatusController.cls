/*
 * The controller of page POStatus.
 */
 
public class POStatusController
{
    public POStatusController() { }
    
    public String PONumber
    {
        get
        {
            if(PONumber == null)
            {
                PONumber = '';
            }
            return PONumber;
        }
        set
        {
            PONumber = value.trim();
        }
    }
    
    public Boolean HasNoResult { get; private set; }
    public Purchase_Order__c PurchaseOrder { get; private set; }
    public List<Purchase_Order__c> PurchaseOrders { get; private set; }
    
    public PageReference search()
    {
        HasNoResult = false;
        PurchaseOrders = [select Name, Order_Date__c, Ship_Date__c, Status__c, Missing_End_Customer_PO__c, Missing_Export_Compliance__c, Missing_Freight_Forwarder_information__c, Missing_Reseller_s_Resale_Certificate__c, Missing_Ship_To_Contact_Name_Phone__c, Conditional_language_on_CPO_is_incorr__c, Tracking_Information__c from Purchase_Order__c where Name = :PONumber];
        if(PurchaseOrders.size() == 1)
        {
            PurchaseOrder = PurchaseOrders[0];
        }
        else
        {
            PurchaseOrder = null;
            if(PurchaseOrders.isEmpty())
            {
                HasNoResult = true;
            }
        }
        return null;
    }
    
    public PageReference selectPO()
    {
        String index = ApexPages.currentPage().getParameters().get('index');
        try
        {
            Integer i = Integer.valueOf(index);
            PurchaseOrder = PurchaseOrders[i];
        }
        catch(Exception ex)
        {
            ApexPages.addMessages(ex);
        }
        return null;
    }
    
    @isTest
    static void testPOStatusController()
    {
        PageReference pageRef = new PageReference('/POStatus');
        Test.setCurrentPage(pageRef);
        
        POStatusController controller = new POStatusController();
        controller.search();
        
        Purchase_Order__c testPO = new Purchase_Order__c();
        String poNumber = 'acme' + Date.today().format();
        testPO.Name = poNumber;
        insert testPO;
        
        controller.PONumber = poNumber;
        controller.search();
        
        ApexPages.currentPage().getParameters().put('index', '0');
        controller.selectPO();
    }
}