/*
 * Controller of page PartnerPortalDocumentDownload
 */
public class PartnerPortalDocumentDownloadController
{
    public PageReference redirect()
    {
        String docNumber = ApexPages.currentPage().getParameters().get('doc');
        String url = getDownloadUrl(docNumber);
        if(String.isNotBlank(url))
        {
            return new PageReference(url);
        }
        else
        {
            return new PageReference('/page_not_found');
        }
    }
    
    public static String getDownloadUrl(String doc)
    {
        if(String.isNotBlank(doc))
        {
            List<PartnerPortalDocument__c> links = [select Content_Id__c, Public_URL__c from PartnerPortalDocument__c where Name=:doc limit 1];
            if(links.size() > 0)
            {
                if(UserInfo.getUserType() == 'Guest' && links[0].Public_URL__c != null)
                {
                    return links[0].Public_URL__c;
                }
                else
                {
                    List<ContentDocument> documents = [select LatestPublishedVersionId from ContentDocument where Id=:links[0].Content_Id__c limit 1];
                    if(documents.size() > 0 && documents[0].LatestPublishedVersionId != null)
                    {    
                        return '/sfc/servlet.shepherd/version/download/'+documents[0].LatestPublishedVersionId+'?asPdf=false';
                    }
                }
            }
        }
        return null;
    }
}