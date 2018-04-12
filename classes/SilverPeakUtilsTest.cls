/*
* Silver Peak Utils Test Class
*/
@isTest
private class SilverPeakUtilsTest
{
    @isTest
    static void testIsPortalUser()
    {
        system.assertEquals(SilverPeakUtils.isPortalUser(), false);
    }
 	@isTest
    static void testIsUserNameExistswithEmail()
    {
        system.assertEquals(SilverPeakUtils.IsUserNameExistswithEmail('abc@abc.com'), false);
    }
    @isTest
    static void testGetRecordType()
    {
        system.assert(SilverPeakUtils.getRecordTypeId('RMA', 'RMA__c') != null);
    }

    @isTest
    static void testToHex()
    {
        system.assert(SilverPeakUtils.toHex(8) != null);
    }

    @isTest
    static void testGetAssetMac()
    {
        Asset_mac__c amac = new Asset_mac__c(Used__c = false);
        insert amac;
        system.assert(SilverPeakUtils.getAssetMac() != null);
    }

    @isTest
    static void testGetPicklistDefaultValue()
    {
        SilverPeakUtils.getPicklistDefaultValue(Account.Type.getDescribe());
    }
    
    @isTest
    static void testBaseUrl()
    {
        System.assert(SilverPeakutils.getSalesforceBaseUrl() != null);
    }
}