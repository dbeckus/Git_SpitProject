/**
 * Trigger dispatcher of Lead.
 *
 * @author  Matt Yuan
 * @created 4/21/2015
 * @version 1.0
 * @since   33.0
 *
 * @changelog
 * 4/21/2015 Matt Yuan - Created.
 */

trigger LeadTriggerDispatcher on Lead (before insert, before update, before delete, after insert, after update, after delete, after undelete)
{
    //if(!SilverPeakUtils.BypassingTriggers)
    //{
        TriggerFactory.createTriggerHandlers(Lead.SObjectType);
    //}
}