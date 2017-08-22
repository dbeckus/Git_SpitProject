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
 * 6/24/2016 Zhong - hard-code the handler names to avoid additional SOQL. TriggerFactory should be deprecated.
 */

trigger LeadTriggerDispatcher on Lead (before insert, before update, before delete, after insert, after update, after delete, after undelete)
{
    TriggerDispatcher.Run(new LeadTriggerHandler());
    /*if(!SilverPeakUtils.BypassingTriggers)
    {
        TriggerHandler handler = new LeadTriggerHandlerForSDC();
        handler.execute();
        
        handler = new LeadTriggerHandlerForLeadConversion();
        handler.execute();
    }*/
}