@isTest
public class PartnerPortalDocumentDownloadCtrlTest
{
    @isTest
    static void test()
    {
        PartnerPortalDocument__c doc = new PartnerPortalDocument__c(Name='test', Content_Id__c='acme');
        insert doc;
        Test.setCurrentPage(new PageReference('/apex/content_download?doc=acme'));
        PartnerPortalDocumentDownloadController controller = new PartnerPortalDocumentDownloadController();
        controller.redirect();
    }
}