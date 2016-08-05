@isTest
public class PartnerPortalUrlRewriterTest
{
    @isTest
    static void test()
    {
        ContentPage__c p = new ContentPage__c(Name='acme', VirtualPath__c='v', ActualUrl__c='a');
        ContentPage__c p1 = new ContentPage__c(Name='acme1', VirtualPath__c='v1');
        ContentPage__c p2 = new ContentPage__c(Name='acme2', VirtualPath__c='v2', ActualUrl__c='a2');
        
        insert new ContentPage__c[]{p, p1, p2};
        
        PartnerPortalUrlRewriter rewriter = new PartnerPortalUrlRewriter();
        pageReference result = rewriter.mapRequestUrl(new PageReference('/a'));
        pageReference result1 = rewriter.mapRequestUrl(new PageReference('/v'));
        pageReference result2 = rewriter.mapRequestUrl(new PageReference('/v1'));
        
        rewriter.generateUrlFor(new List<PageReference> { new PageReference('/v') });
        rewriter.generateUrlFor(new List<PageReference> { new PageReference('/a?test=xxx') });
        rewriter.generateUrlFor(new List<PageReference> { new PageReference('/a2#test') });

    }
}