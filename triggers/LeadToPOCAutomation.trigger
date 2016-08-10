/*
    This trigger is not setup for bulk processing
*/
trigger LeadToPOCAutomation on Lead (before insert, after insert, after update)
{
    if(!SilverPeakUtils.BypassingTriggers)
    {
        if(trigger.new.size() == 1)
        {
            final Integer DEFAULT_LICENSE_DURATION_DAYS = 30;
            
            Lead l = trigger.new[0];
            if(l.Trial_Request_from_Marketplace__c)
            {
                if(Trigger.isBefore && Trigger.isInsert)
                {
                    List<LeadToPOCAutomationHelper.ModelInfo> models = LeadToPOCAutomationHelper.resolveModelTrial(l.Model_for_Trial__c);
                    String trialModel = (models.size() > 0) ? models[0].Name : '';
                    if(trialModel == 'VX-X')
                    {
                        l.Send_VX_X_Email__c = true; //flag to trigger a workflow to send email
                        return;
                    }
                    else
                    {
                        if(LeadToPOCAutomationHelper.isEmailBlacklisted(l.Email))
                        {
                            l.Send_Blacklist_Rejection__c = true; //flag to trigger a workflow to send email
                            return;
                        }
                        LeadToPOCAutomationHelper.duplicateOrUpdateLead(l);
                        if(l.Last_Mkt_Campaign__c instanceOf Id)
                        {
                            l.Last_Mkt_Campaign_Id__c = l.Last_Mkt_Campaign__c;
                            l.Last_Mkt_Campaign__c = null;
                        }
                    }
                    
                    //replace lead name and company
                    if(!l.Send_VX_X_Email__c && !l.Send_Blacklist_Rejection__c && !l.isConverted)
                    {
                        LeadToPOCAutomationHelper.replaceLeadName(l);
                    }
                }
                else if(Trigger.isAfter && !l.isConverted && !l.Marketplace_Fulfillment_Only__c && !System.isfuture())
                {
                    List<LeadToPOCAutomationHelper.ModelInfo> models = LeadToPOCAutomationHelper.resolveModelTrial(l.Model_for_Trial__c);
                    String trialModel = (models.size() > 0) ? models[0].Name : '';
                    LeadToPOCAutomationHelper.linkLeadToModelCampaign(l.Id, trialModel);
                    LeadToPOCAutomationHelper.linkLeadToMarketplaceCampaign(l.Id, l.Marketplace_Code__c);
                    LeadToPOCAutomationHelper.linkLeadToCampaign(l.Id, l.Last_Mkt_Campaign_Id__c);
                    
                    //conversion
                    if(!l.Send_VX_X_Email__c && !l.Send_Blacklist_Rejection__c && !l.isConverted)
                    {
                        if(l.LeadSource == 'Web- Trial Request')
                        {
                            LeadToPOCAutomationHelper.convertAndFulfillTrial(l.Id);
                        }
                        else if(l.LeadSource == 'Web- Purchase Request')
                        {
                            LeadToPOCAutomationHelper.convertAndFulfillBuy(l.Id);
                        }                    
                    }
                }
            }
        }
    }
}