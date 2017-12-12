global class PartnerPortalUrlRewriter implements Site.UrlRewriter 
{
    
    String PARTNER_PAGE = '/partner/';
    String PARTNER_VISUALFORCE_PAGE = '/partnerportalpagerender?name=';

    global PageReference mapRequestUrl(PageReference  myFriendlyUrl)
    {
        List<ContentPage__c> contentPages = [select Id, Name, VirtualPath__c, ActualUrl__c from ContentPage__c];
        String pathName = getPathName(myFriendlyUrl.getUrl());
        for(ContentPage__c contentPage : contentPages)
        {
            if(pathName.endsWithIgnoreCase('/' + contentPage.VirtualPath__c))
            {
                if(String.isNotBlank(contentPage.ActualUrl__c))
                {
                    return new PageReference(contentPage.ActualUrl__c);
                }
                else
                {
                    PageReference p = new PageReference(PARTNER_VISUALFORCE_PAGE + contentPage.VirtualPath__c);
                    p.getParameters().putAll(myFriendlyUrl.getParameters());
                    System.debug('Test'+p);
                    System.debug('myFriendlyUrl.getParameters() '+myFriendlyUrl.getParameters());
                    return p;
                }
            }
        }
        return myFriendlyUrl;
    }

    global List<PageReference> generateUrlFor(List<PageReference> mySalesforceUrls)
    {
        List<ContentPage__c> contentPages = [select Id, Name, VirtualPath__c, ActualUrl__c from ContentPage__c];
        List<PageReference> myFriendlyUrls = new List<PageReference>();
        for(PageReference p : mySalesforceUrls)
        {
            String pathName = getPathName(p.getUrl());
            Boolean found = false;
            for(ContentPage__c content : contentPages)
            {
                if(pathName.endsWithIgnoreCase('/' + content.ActualUrl__c))
                {
                    myFriendlyUrls.add(new PageReference('/' + content.VirtualPath__c));
                    found = true;
                    break;
                }
            }
            if(!found)
            {
                myFriendlyUrls.add(p);
            }
        }
        return myFriendlyUrls;
        return mySalesforceUrls;
    }
    
    private String getPathName(String url)
    {
        if(url.contains('?'))
        {
            url = url.substring(0, url.indexOf('?'));
        }
        if(url.contains('#'))
        {
            url = url.substring(0, url.indexOf('#'));
        }
        return url;
    }
}