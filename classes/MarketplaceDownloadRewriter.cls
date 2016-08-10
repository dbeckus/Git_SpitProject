/*
 * URLRewriter on force.com site that handles marketplace downloads
 */
global class MarketplaceDownloadRewriter implements Site.UrlRewriter 
{
    //friendlyURL is like /download/latest/MODEL/HYPERVISOR
    global PageReference mapRequestUrl(PageReference friendlyUrl)
    {
        String pageUrl = friendlyUrl.getUrl();
        if(!pageUrl.startsWith('http://') || !pageUrl.startsWith('https://'))
        {
            pageUrl = 'http://' + pageUrl;
        }
        URL url = new URL(pageUrl);
        String[] urlComponents = url.getPath().split('/');
        if(urlComponents.size() == 5)
        {
            if(urlComponents[1] == 'download' && urlComponents[2] == 'latest')
            {
                String model = urlComponents[3];
                String hypervisor = urlComponents[4];
                hypervisor = (hypervisor == null) ? '' : hypervisor.replaceAll('\\s', '');
                PageReference actualUrl = Page.MarketplaceDownload;
                actualUrl.getParameters().put('model', model);
                actualUrl.getParameters().put('hypervisor', hypervisor);
                return actualUrl;
            }
        }
        return friendlyUrl;
    }
    
    //no friendly url conversion is needed in this rewriter
    global PageReference[] generateUrlFor(PageReference[] pages)
    {
        return pages;
    }
}