/**
 * Test class for MDFRequestTriggerHandlerForAutoSubmit
 * @author  Matt Yuan
 * @version 1.0
 *
 * @changelog
 * 8/5/2015 Matt Yuan - Created.
 */

@isTest
public class MDFRequestTriggerHandlerTest
{
    @isTest
    static void test()
    {
        TriggerHandlerSetting__c setting = new TriggerHandlerSetting__c(Name = '1', SObjectType__c = 'MDF_Request__c', Handler__c = 'MDFRequestTriggerHandlerForAutoSubmit');
        insert setting;
        
        Test.startTest();
        MDF_Request__c mdfReq = new MDF_Request__c(Is_Portal_Request__c = true);
        insert mdfReq;
        Test.stopTest();
    }
}