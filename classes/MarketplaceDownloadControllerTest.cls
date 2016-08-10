@isTest
public class MarketplaceDownloadControllerTest
{
    @isTest
    static void test()
    {
        MarketplaceDownloadLink__c link = new MarketplaceDownloadLink__c(Name='acme', Model__c='test', Hypervisor__c='kvm', Link__c='http://www.test.com');
        insert link;
        
        Test.setCurrentPage(new PageReference('/apex/MarketplaceDownload?model=test&hypervisor=kvm'));
        MarketplaceDownloadController controller = new MarketplaceDownloadController();
        PageReference result = controller.redirect();
        
        System.assertEquals(link.Link__c, result.getUrl());
    }
}