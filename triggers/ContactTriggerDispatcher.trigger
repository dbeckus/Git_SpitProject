/**
 * Trigger dispatcher of Contact.
 *
 * @author  Matt Yuan
 * @created 4/21/2015
 * @version 1.0
 * @since   33.0
 *
 * @changelog
 * 4/21/2015 Matt Yuan - Created.
 * 6/24/2016 Zhong - Updated to remove usage of TriggerFactory to avoid additional SOQL
 */

trigger ContactTriggerDispatcher on Contact (before insert, before update, before delete, after insert, after update, after delete, after undelete) 
{
    if(!SilverPeakUtils.BypassingTriggers)
    {
        TriggerHandler handler = new ContactTriggerHandlerForSDC();
        handler.execute();
    }
}