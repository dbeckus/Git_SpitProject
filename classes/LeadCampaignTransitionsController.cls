public class LeadCampaignTransitionsController
{

    private Map<String, String> ltMap;
    private List<String> ids;
    private String title;
    
    public String getId()
    {
        return ApexPages.currentPage().getParameters().get('id');
    }
    
    public String getTitle()
    {
        if(title == null)
        {
            title = [SELECT Name FROM Campaign WHERE id = :getId()].Name;
        }
        return title;
    }
    
    public List<String> getIds()
    {
        if(ids == null)
        {
            List<CampaignMember> cms = [SELECT LeadId FROM CampaignMember WHERE CampaignId = :getId()];
            List<String> cmIds = new List<String>();
            for(CampaignMember cm : cms)
            {
                cmIds.add(cm.LeadId);
            }
            List<Lead_Transition__c> lts = [SELECT Id FROM Lead_Transition__c WHERE Lead__c in :cmIds];
            ids = new List<String>();
            for(Lead_Transition__c lt : lts)
            {
                ids.add(lt.Id);
            }
        }
        return ids;
    }
    
    public String getTotalLeads()
    {
        return String.valueOf([SELECT COUNT() FROM Lead_Transition__c WHERE Id in :getIds()]);
    }
    
    public String getMN()
    {
        return String.valueOf([SELECT COUNT() FROM Lead_Transition__c WHERE Marketing_Nurture__c = 1 AND Id in :getIds()]);
    }
    
    public String getMQL()
    {
        return String.valueOf([SELECT COUNT() FROM Lead_Transition__c WHERE Marketing_Qualified__c = 1 AND Id in :getIds()]);
    }
    
    public String getIQL()
    {
        return String.valueOf([SELECT COUNT() FROM Lead_Transition__c WHERE Sales_Qualifying__c = 1 AND Id in :getIds()]);
    }
    
    public String getSAL()
    {
        return String.valueOf([SELECT COUNT() FROM Lead_Transition__c WHERE Sales_Accepted__c = 1 AND Id in :getIds()]);
    }
    
    public String getOPP()
    {
        return String.valueOf([SELECT COUNT() FROM Lead_Transition__c WHERE Converted_to_Opp__c = 1 AND Id in :getIds()]);
    }
    
    public String getWON()
    {
        return String.valueOf([SELECT COUNT() FROM Lead_Transition__c WHERE Won_Business__c = 1 AND Id in :getIds()]);
    }
    
    public String getREJ()
    {
        return String.valueOf([SELECT COUNT() FROM Lead_Transition__c WHERE Rejected__c = 1 AND Id in :getIds()]);
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