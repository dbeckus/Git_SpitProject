/*
* Controller for CmaConvertConfirm page
*/
public with sharing class CmaConvertConfirmController
{
    public CmaConvertConfirmController()
    {
        CmaId = ApexPages.CurrentPage().getParameters().get('id');
    }

    public String CmaId { get; set; }
    public String VxAssetId
    {
        get
        {
            List<RMA_Item__c> items = [select Id, Asset__c from RMA_Item__c where RMA__c=:CmaId and Status__c='Shipped' limit 1];
            if(items.size() > 0)
            {
                return items[0].Asset__c;
            }
            return 'Error';
        }
    }
}