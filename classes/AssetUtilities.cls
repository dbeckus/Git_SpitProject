public class AssetUtilities 
{
    public static Boolean isServiceProvider()
    {
        Boolean isServiceProvider = false;
        for(User currentUser : [select ContactId from user where Id = :UserInfo.getUserId() and ContactId != null limit 1])
        {
            for(Contact con : [select Account.Service_Provider__c from Contact where Id = :currentUser.ContactId limit 1])
            {
                isServiceProvider = con.Account.Service_Provider__c;
            }
        }
        return isServiceProvider;
    }

    public static Map<String, String> getHeaderMap()
    {
        Map<String, String> fieldLabel2API = new Map<String, String>();
        Set<String> editFieldsByCSV = new Set<String> { 'Customer_Notes__c', 'Deployment_Date__c', 'Reference__c', 'End_Customer__c' };
        for(Schema.SObjectField field : Schema.getGlobalDescribe().get('Asset').getDescribe().fields.getMap().values())
        {
            if(field.getDescribe().isUpdateable() && editFieldsByCSV.contains(field.getDescribe().getName()))
            {
                fieldLabel2API.put(field.getDescribe().getLabel(), field.getDescribe().getName());
            }
        }
        return fieldLabel2API;
    }

    public static List<String> splitCsv(String line)
    {
        if(line == null)
        {
            return new List<String>();
        }
        line = line.replaceAll('"""', '"');
        List<String> result = new List<String>();
        Boolean itemStarted = true;
        Boolean isQuoteItem = false;
        String tempValue = '';
        for(Integer i = 0 ; i < line.length(); i++)
        {
            String c = line.mid(i, 1);
            if(c == ',')
            {
                if(itemStarted && !isQuoteItem)
                {
                    itemStarted = false;
                    result.add(tempValue.trim());
                    tempValue = '';
                }
                else if(itemStarted && isQuoteItem)
                {
                    tempValue += c;
                }
                else
                {
                    result.add(tempValue.trim());
                }
            }
            else if(c == ' ')
            {
                if(itemStarted)
                {
                    tempValue += c;
                }
            }
            else if(c == '"')
            {
                if(!itemStarted)
                {
                    itemStarted = true;
                    isQuoteItem = true;
                }
                else if(itemStarted && isQuoteItem)
                {
                    isQuoteItem = false;
                }
                else if(itemStarted && !isQuoteItem)
                {
                    tempValue += c;
                }
            }
            else
            {
                itemStarted = true;
                tempValue += c;
            }
        }
        result.add(tempValue.trim());
        return result;
    }
}