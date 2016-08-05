/*
 *  Sends email to the lead owners if the deferral date is today.
 */
public class LeadTransitionHistoricalBatch implements Database.Batchable<Sobject>, Database.Stateful
{
    public Database.Querylocator start(Database.BatchableContext BC)
    {
         return Database.getQueryLocator([select Id, ConvertedOpportunityId, CreatedDate, ConvertedDate, isConverted FROM Lead WHERE CreatedDate >= 2013-08-01T01:01:01Z]);
    }
    
    public void execute(Database.BatchableContext BC, List<Lead> leads)
    {
        List<String> leadIds = new List<String>();
        List<String> oppIds = new List<String>();
        Map<String, String> leadOppMap = new Map<String, String>();
        
        for(Lead l : leads)
        {
            leadIds.add(l.id);
            if(l.ConvertedOpportunityId != null)
            {
                oppIds.add(l.ConvertedOpportunityId);
                leadOppMap.put(l.ConvertedOpportunityId,l.id);
            }
        }
        
        List<Lead_Matrix__c> lms = [SELECT Name, Campaign__c, Date__c, Transition_State__c FROM Lead_Matrix__c];
        // Map<String, Lead_Matrix__c>
        Map<Object, sObject> lmMap = new Map<Object, sObject>();
        lmMap = TriggerTools.makeMapFromList(lms, 'name');
        
        List<Lead_Transition_Order__c> ltos = [SELECT Index__c, Transition_State__c, Campaign__c, Date__c FROM Lead_Transition_Order__c ORDER BY Index__c DESC];
        
        List<CampaignMember> cms = [SELECT Id, LeadId, CreatedDate, CampaignId FROM CampaignMember WHERE LeadId in :leadIds ORDER BY CreatedDate ASC];
        List<LeadHistory> lhs = [SELECT Id, LeadId, CreatedDate, Field, NewValue FROM LeadHistory WHERE LeadId in :leadIds AND (Field = 'Status' OR Field = 'leadConverted') ORDER BY CreatedDate ASC];
        List<Lead_Transition__c> lts = [SELECT Id, Converted_to_Opp__c, IQL_Campaign__c, IQL_Date__c, Lead__c, Marketing_Nurture__c, Marketing_Qualified__c, MN_Campaign__c, MN_Date__c, MQL_Campaign__c, MQL_Date__c, OPP_Campaign__c, OPP_Date__c, REJ_Campaign__c, REJ_Date__c, Rejected__c, SAL_Campaign__c, SAL_Date__c, Sales_Accepted__c, Sales_Qualifying__c, Won_Business__c, WON_Campaign__c, WON_Date__c FROM Lead_Transition__c WHERE Lead__C in :leadIds];
        List<Opportunity> opps = [SELECT id, IsWon, LastActivityDate, CampaignId FROM Opportunity WHERE id in :oppIds];
        Map<Object, List<CampaignMember>> cmMap = new Map<Object, List<CampaignMember>>();
        Map<Object, List<LeadHistory>> lhMap = new Map<Object, List<LeadHistory>>();
        Map<String, Opportunity> wonLeads = new Map<String, Opportunity>();
        
        cmMap = TriggerTools.makeMapListFromList(cms, 'LeadId', cmMap);
        lhMap = TriggerTools.makeMapListFromList(lhs, 'LeadId', lhMap);
        
        for(Opportunity opp : opps)
        {
            if(opp.IsWon)
            {
                String leadId = leadOppMap.get(opp.id);
                wonLeads.put(leadId, opp);
            }
        }
        
        for(Lead lead : leads)
        {
        	Map<String,Object> rules = new Map<String,Object>();
        	rules.put('Lead__c',lead.id);
        	Lead_Transition__c temp = (Lead_Transition__c)TriggerTools.listContainsObject(rules, lts);
        	
        	List<CampaignMember> cmList = cmMap.get(lead.id);
            List<LeadHistory> lhList = lhMap.get(lead.id);
            
            if(temp == null)
			{
				temp = new Lead_Transition__c(Marketing_Nurture__c = 1, Lead__c = lead.id,  MN_Date__c = lead.CreatedDate);
				if(!lead.isConverted)
				{
					temp.Lead_ID__c = Lead.id;
				} 
				if(cmList != null && cmList.size() > 0)
				{
					temp.MN_Campaign__c = getOldestCampaign(cmList);
				}
        		lts.add(temp);
			}
            
            if(lhList != null)
            {
				
                for(LeadHistory lh : lhList)
                {
                    if(lh.Field == 'Status' && lh.NewValue != null)
                    {
                        String val = String.valueOf(lh.NewValue);
                        if(!String.isBlank(val))
                        {
							Lead_Matrix__c lm = (Lead_Matrix__c)lmMap.get(val);
	                        if(lm != null)
	                        {
		                        String state = lm.Transition_State__c;
		                        if(state != null && (temp.get(state) == null || temp.get(state) != 1))
		                        {
		                            temp.put(state, 1);
		                            temp.put(lm.Date__c,lh.CreatedDate);
		                            if(cmList != null && cmList.size() > 0)
		                            {
		                            	temp.put(lm.Campaign__c, getClosetCampaign(lh.CreatedDate, cmList));	
		                            }
		                        }
	                        }
                        }
                    }
                    else if(lh.Field == 'leadConverted')
                    {
                        temp.Converted_to_Opp__c = 1;
                        temp.OPP_Date__c = lh.CreatedDate;
                        if(cmList != null && cmList.size() > 0)
                        {
                        	temp.OPP_Campaign__c = getClosetCampaign(lh.CreatedDate, cmList);	
                        }
                        if(wonLeads != null && wonLeads.get(lead.id) != null)
                        {
                            temp.Won_Business__c = 1;
                            temp.WON_Date__c = wonLeads.get(lead.id).LastActivityDate;
							temp.WON_Campaign__c = wonLeads.get(lead.id).CampaignId;
                            if(cmList != null && cmList.size() > 0)
                            {
                            	if(String.isBlank(temp.WON_Campaign__c))
                            	{
                            		temp.WON_Campaign__c = getClosetCampaign(wonLeads.get(lead.id).LastActivityDate, cmList);	
                            	}
                            }
                        }
                    }
                }
            }
            else
            {
            	if(lead.ConvertedOpportunityId != null)
            	{
            		temp.Converted_to_Opp__c = 1;
                    temp.OPP_Date__c = lead.ConvertedDate;
					if(cmList != null && cmList.size() > 0)
					{
						temp.OPP_Campaign__c = getClosetCampaign(lead.ConvertedDate, cmList);
					}
					if(wonLeads != null && wonLeads.get(lead.id) != null)
                    {
                        temp.Won_Business__c = 1;
                        temp.WON_Date__c = wonLeads.get(lead.id).LastActivityDate;
						temp.WON_Campaign__c = wonLeads.get(lead.id).CampaignId;
                        if(cmList != null && cmList.size() > 0)
                        {
                        	if(String.isBlank(temp.WON_Campaign__c))
                        	{
                        		temp.WON_Campaign__c = getClosetCampaign(wonLeads.get(lead.id).LastActivityDate, cmList);	
                        	}
                        }
                    }
            	}
            }
            // Set all intermediate steps
            if(temp != null)
            {
            	Integer setOn = null;
            	String campaign = null;
            	Datetime d = null;
	            for(Lead_Transition_Order__c lto : ltos)
	            {
	            	if(temp.get(lto.Transition_State__c) != null && temp.get(lto.Transition_State__c) == 1)
	            	{
	            		setOn = 1;
	            		campaign = (String)temp.get(lto.Campaign__c);
	            		d = (Datetime)temp.get(lto.Date__c);
	            	}
	            	else if(setOn != null)
	            	{
	            		temp.put(lto.Transition_State__c,  1);
	            		temp.put(lto.Date__c, d);
	            		temp.put(lto.Campaign__c, campaign);
	            	}
	            }
            }
        }
        
        Database.upsert(lts, true);
    }
    
    public void finish(Database.BatchableContext BC) 
    {
        
    }
    
    private String getCampaign(DateTime cd, List<CampaignMember> cms)
    {
        if(cms != null)
        {
            for(CampaignMember cm : cms)
            {
                if(cm.CreatedDate <= cd)
                {
                    return cm.CampaignId;
                }
            }
        }
        return '';
    }
    
    private String getOldestCampaign(List<CampaignMember> cms)
    {
    	if(cms != null && cms.size() > 0)
    	{
    		return cms[cms.size()-1].CampaignId;
    	}
    	return '';
    }
    
    private String getClosetCampaign(DateTime cd, List<CampaignMember> cms)
    {
    	String result = getCampaign(cd, cms);
    	if(String.isBlank(result))
    	{
    		result = getOldestCampaign(cms);
    	}
    	return result;
    }
    
}