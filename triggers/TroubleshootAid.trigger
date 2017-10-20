trigger TroubleshootAid on Case (before insert, before update)
{
    try
    {
        List<Troubleshoot_Aids__c> troubleshootAids = new List<Troubleshoot_Aids__c>
            ([SELECT Field_Linked__c, Field_Value__c, URL__c
              FROM Troubleshoot_Aids__c]);
    
        for (Case c : Trigger.new)
        {
            for (Troubleshoot_Aids__c troubleshootAid : troubleshootAids)
            {
                Object value = c.get(troubleshootAid.Field_Linked__c);
                if (value == troubleshootAid.Field_Value__c)
                    c.Troubleshoot_URL__c = troubleshootAid.URL__c;
            }
        }
    }
    catch (Exception e)
    {
        System.debug(Logginglevel.ERROR, e);
    }
}