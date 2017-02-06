/**
 * Trigger dispatcher of MDF Request.
 *
 * @author  Matt Yuan
 * @created 8/5/2015
 * @version 1.0
 * @since   34.0
 *
 * @changelog
 * 8/5/2015 Matt Yuan - Created.
 * 6/24/2016 Zhong - Updated to remove usage of TriggerFactory to avoid additional SOQL
 */

trigger MDFRequestTriggerDispatcher on MDF_Request__c (before insert, before update, before delete, after insert, after update, after delete, after undelete)
{
    if(!SilverPeakUtils.BypassingTriggers)
    {
        TriggerHandler handler = new MDFRequestTriggerHandlerForAutoSubmit();
        handler.execute();
    }
}