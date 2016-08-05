public class PartnerPortalPageRenderController 
{    
    private ContentPage__c CurrentPage;
    
    public PartnerPortalPageRenderController() 
    {
        String pageName = ApexPages.currentPage().getParameters().get('name');
        List<ContentPage__c> contentpages = [select Id, Name, Content__c, Public__c, ActualUrl__c, VirtualPath__c from ContentPage__c where VirtualPath__c=:pageName limit 1];
        CurrentPage = (contentpages.size() > 0) ? contentpages[0] : new ContentPage__c(Name='Unknown', Public__c=true, Content__c='<div id="main">No page found.</div>');
    }

    public String Title 
    {
        get
        {
            return CurrentPage.Name;
        }
    }
    public String PageContent 
    {
        get
        {
            return CurrentPage.Content__c;
        }
    }
    
    public PageReference authenticate()
    {
        if(UserInfo.getUserType() != 'Guest' || CurrentPage.Public__c == true)
        {
            if(UserInfo.getUserType() != 'Guest' && CurrentPage.VirtualPath__c == 'home')
            {
                return new PageReference('/champions_home');
            }
            return null;
        }
        else
        {
            PageReference ref = new PageReference('/home?retURL=%2F' + ApexPages.currentPage().getParameters().get('name'));
            return ref;
        }
    }
    
}