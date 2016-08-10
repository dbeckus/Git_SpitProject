@isTest
public class ECAssetListComponentControllerTest {
 @IsTest
    static void test()
    {        
        Contact contact = new Contact(LastName = 'acme');
        insert contact;  
        ECAssetListComponentController controller = new ECAssetListComponentController();
        controller.RequestId = contact.Id;
        List<Asset> assets = controller.Assets;
      
    }     
     @IsTest
    static void test_NoRequestId()
    {        
        Contact contact = new Contact(LastName = 'acme');
        insert contact;  
        ECAssetListComponentController controller = new ECAssetListComponentController();
        controller.RequestId = null;
        Date dateNow=controller.DefaultDate;
        List<Asset> assets = controller.Assets;
      
    }     
}