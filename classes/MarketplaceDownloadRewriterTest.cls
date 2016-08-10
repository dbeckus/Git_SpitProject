@isTest
public class MarketplaceDownloadRewriterTest
{
    @isTest
    static void test()
    {
        MarketplaceDownloadRewriter rewriter = new MarketplaceDownloadRewriter();
        PageReference actualUrl = rewriter.mapRequestUrl(new PageReference('/download/latest/VX-1000/KVM'));
        System.assertEquals('VX-1000', actualUrl.getParameters().get('model'));
        System.assertEquals('KVM', actualUrl.getParameters().get('hypervisor'));
        rewriter.generateUrlFor(new List<PageReference> {actualUrl});
    }
}