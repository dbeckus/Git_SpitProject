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
 */

trigger MDFRequestTriggerDispatcher on MDF_Request__c (before insert, before update, before delete, after insert, after update, after delete, after undelete)
{
    //if(!SilverPeakUtils.BypassingTriggers)
    //{
        TriggerFactory.createTriggerHandlers(MDF_Request__c.SObjectType);
    //}
}