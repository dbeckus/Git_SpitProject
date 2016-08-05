/**
 * Trigger factory class. Gets trigger handlers class name from custom settings and creates trigger handler classes to execute actions.
 *
 * @author  Matt Yuan
 * @created 4/20/2015
 * @version 1.0
 * @since   33.0
 *
 * @changelog
 * 4/20/2015 Matt Yuan - Created.
 */

public class TriggerFactory
{
    public static void createTriggerHandlers(Schema.sObjectType sobjType)
    {
        String sobjName = sobjType.getDescribe().getName();
        for(TriggerHandlerSetting__c handlerSetting : [SELECT Handler__c FROM TriggerHandlerSetting__c WHERE SObjectType__c = :sobjName ORDER BY ProcessingSequence__c NULLS LAST])
        {
            Type handlerType = Type.forName('', handlerSetting.Handler__c);
            if(handlerType != null)
            {
                ITrigger handler = (ITrigger)handlerType.newInstance();
                execute(handler);
            }
        }
    }
    
    private static void execute(ITrigger handler)
    {
        if(Trigger.isBefore)
        {
            if(Trigger.isInsert)
            {
                handler.beforeInsert();
            }
            else if(Trigger.isUpdate)
            {
                handler.beforeUpdate();
            }
            else if(Trigger.isDelete) 
            {
                handler.beforeDelete();
            }
        }
        else
        {
            if(Trigger.isInsert)
            {
                handler.afterInsert();
            }
            else if(Trigger.isUpdate)
            {
                handler.afterUpdate();
            }
            else if(Trigger.isDelete)
            {
                handler.afterDelete();
            }
            else if(Trigger.isUndelete)
            {
                handler.afterUndelete();
            }
        }
    }
}