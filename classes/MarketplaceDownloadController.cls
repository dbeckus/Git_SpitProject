public class MarketplaceDownloadController
{
    public PageReference redirect()
    {
        String model = ApexPages.currentPage().getParameters().get('model');
        String hypervisor = ApexPages.currentPage().getParameters().get('hypervisor');
        hypervisor = (hypervisor == null) ? '' : hypervisor.replaceAll('\\s', '');
        List<MarketplaceDownloadLink__c> links = [select Link__c from MarketplaceDownloadLink__c where Model__c=:model and Hypervisor__c=:hypervisor limit 1];
        if(links.size() > 0 && String.isNotBlank(links[0].Link__c))
        {
            return new PageReference(links[0].Link__c);
        }
        else if(links.size() == 0)
        {
            links = [select Link__c from MarketplaceDownloadLink__c where Model__c=null and Hypervisor__c=:hypervisor limit 1];
            if(links.size() > 0 && String.isNotBlank(links[0].Link__c))
            {
                return new PageReference(links[0].Link__c);
            }
        }
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Specified model and hypervisor cannot be found.'));
        return null;
    }
}