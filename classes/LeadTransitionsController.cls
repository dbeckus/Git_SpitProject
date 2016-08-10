public class LeadTransitionsController
{

    private Map<String, String> ltMap;
    
    public String getTotalLeads()
    {
        return String.valueOf([SELECT COUNT() FROM Lead_Transition__c]);
    }
    
    public String getMN()
    {
        return String.valueOf([SELECT COUNT() FROM Lead_Transition__c WHERE Marketing_Nurture__c = 1]);
    }
    
    public String getMQL()
    {
        return String.valueOf([SELECT COUNT() FROM Lead_Transition__c WHERE Marketing_Qualified__c = 1]);
    }
    
    public String getIQL()
    {
        return String.valueOf([SELECT COUNT() FROM Lead_Transition__c WHERE Sales_Qualifying__c = 1]);
    }
    
    public String getSAL()
    {
        return String.valueOf([SELECT COUNT() FROM Lead_Transition__c WHERE Sales_Accepted__c = 1]);
    }
    
    public String getOPP()
    {
        return String.valueOf([SELECT COUNT() FROM Lead_Transition__c WHERE Converted_to_Opp__c = 1]);
    }
    
    public String getWON()
    {
        return String.valueOf([SELECT COUNT() FROM Lead_Transition__c WHERE Won_Business__c = 1]);
    }
    
    public String getREJ()
    {
        return String.valueOf([SELECT COUNT() FROM Lead_Transition__c WHERE Rejected__c = 1]);
    }
    
    public Map<String,String> getLT()
    {
        Map<String,String> result = new Map<String,String>();
        result.put('1: Total Leads',getTotalLeads());
        result.put('2: Marketing Nurture -- MN', getMN());
        result.put('3: Marketing Qualified -- MQL', getMQL());
        result.put('4: Sales Qualifying -- IQL', getIQL());
        result.put('5: Sales Accepted -- SAL', getSAL());
        result.put('6: Converted to Opp -- OPP', getOPP());
        result.put('7: Won Business -- WON', getWON());
        result.put('8: Rejected -- REJ', getREJ());
        return result;
    }
    
    public Map<String,String> getLeadTransitions()
    {
        if(ltMap == null)
        {
            ltMap = getLT();
        }
        return ltMap;
    }
    
}