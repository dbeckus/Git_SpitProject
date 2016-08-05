/*
 * Controller of page EditRMALineAddress
 */
global with sharing class EditRMALineAddressController 
{
    private RMA_Item__c item;
    
    public EditRMALineAddressController(ApexPages.StandardController controller) 
    {
        item = (RMA_Item__c)controller.getRecord();
    }
    
    @RemoteAction
    global static List<CountryStateTable__c> getStateList(String country)
    {
        return [select StateCode__c, StateName__c from CountryStateTable__c where Country__c=:country order by StateName__c];
    }
    
    public PageReference save()
    {
        if(!isValidState())
        {
            return null;
        }
        
        try
        {
            item.Ship_to_address__c = NewRMAController.concateAddress(item.ShipToAddress__c, item.ShipToAddressAdditional__c, item.ShipToCity__c, item.ShipToStateOrProvince__c, item.ShipToPostalCode__c, item.ShipToCountry__c, item.Ship_To_Contact__r.FirstName, item.Ship_To_Contact__r.LastName, item.Contact_Phone__c);
            upsert item;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, 'Updated successfully<script>top.opener.location="/'+item.Id+'";top.close();</script>'));
        }
        catch(Exception ex)
        {
            ApexPages.addMessages(ex);
        }
        return null;
    }
    
    private Boolean isValidState()
    {
        List<CountryStateTable__c> states = getStateList(item.ShipToCountry__c);
        if(states.size() > 0)
        {
            Boolean foundState = false;
            for(CountryStateTable__c state : states)
            {
                if(state.StateCode__c == item.ShipToStateOrProvince__c)
                {
                    foundState = true;
                    break;
                }
            }
            if(!foundState)
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, 'You must choose a Ship to State/Province.'));
                return false;
            }
        }
        return true;
    }
    
    @isTest
    static void testEditRMALineAddressController()
    {
        CountryStateTable__c state = new CountryStateTable__c(Name='acme', Country__c='United States', StateCode__c='CA', StateName__c='California');
        insert state;
        
        RMA_Item__c item = new RMA_Item__c(ShipToCountry__c='United States', ShipToStateOrProvince__c='CA');
        ApexPages.StandardController ctrl = new ApexPages.StandardController(item);
        EditRMALineAddressController controller = new EditRMALineAddressController(ctrl);
        
        List<CountryStateTable__c> states = getStateList('United States');
        controller.save();
    }
}