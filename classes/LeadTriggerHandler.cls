public class LeadTriggerHandler implements ITriggerHandler {
    
    public LeadTriggerHandler()
    {
        
    }
    
    public Boolean IsDisabled()
    {
        return false;
    }
    public void BeforeInsert(List<SObject> newItems) 
    {
        Set<String> marketplaceCodes = new Set<String>();
        List<Lead> processingLeads = new List<Lead>();
        List<Lead> leadsNeedAssignment = new List<Lead>();
        List<Lead> dealRegLeads = new List<Lead>();
        Set<Id> userIds = new Set<Id>();
        if(newItems!=null && newItems.size()>0)
        {
            for(Lead leadInfo:(List<Lead>)newItems)
            {
                if(!SilverPeakUtils.BypassingTriggers)
                {
                    if(leadInfo.Patch__c == null)
                    {
                        leadsNeedAssignment.add(leadInfo);
                    }
                    if(String.isNotBlank(leadInfo.Marketplace_Code__c))
                    {
                        marketplaceCodes.add(leadInfo.Marketplace_Code__c.toUpperCase());
                        processingLeads.add(leadInfo);
                    }
                }
                
                if(leadInfo.Deal_Reg__c == true)
                {
                    userIds.add(leadInfo.Deal_Reg_By_Partner_Id__c);
                    dealRegLeads.add(leadInfo);
                }
            }
            
            PatchRuleHelper.assignPatches(leadsNeedAssignment);
            LinkRegisteredPartner(marketplaceCodes,processingLeads);
            ProcessDealReg(userIds,dealRegLeads);
            
        }
        
    }
    public void BeforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) 
    {
        List<Lead> leadsNeedAssignment = new List<Lead>();
        List<Lead> dealRegLeads = new List<Lead>();
        Set<String> marketplaceCodes = new Set<String>();
        List<Lead> processingLeads = new List<Lead>();
        Set<Id> userIds = new Set<Id>();
        if(newItems!=null && newItems.size()>0)
        {
            for (Id leadId : newItems.keyset())
            {
                Lead newLead=(Lead)newItems.get(leadId);
                Lead oldLead=(Lead)oldItems.get(leadId);
                if(!SilverPeakUtils.BypassingTriggers)
                {
                    if(!newLead.IsConverted)
                    {
                        PatchRuleEngineBase.Target target = PatchRuleHelper.getTarget(newLead);
                        PatchRuleEngineBase.Target oldTarget = PatchRuleHelper.getTarget(oldLead);
                        if(newLead.Trigger_Assignment__c || !PatchRuleHelper.isSameTarget(target, oldTarget))
                        {
                            leadsNeedAssignment.add(newLead);
                            PatchRuleHelper.leadsNeedAssignment.add(newLead.Id);
                        }
                    }
                    if(newLead.Marketplace_Code__c != oldLead.Marketplace_Code__c)
                    {
                        if(String.isNotBlank(newLead.Marketplace_Code__c))
                        {
                            marketplaceCodes.add(newLead.Marketplace_Code__c.toUpperCase());
                            processingLeads.add(newLead);
                        }
                        else
                        {
                            newLead.Registered_Partner__c = null;
                        }
                    }
                }
                
                if(newLead.Deal_Reg__c == true && oldLead.Deal_Reg__c!=newLead.Deal_Reg__c)
                {
                    userIds.add(newLead.Deal_Reg_By_Partner_Id__c);
                    dealRegLeads.add(newLead);
                }
                if(newLead.Status != oldLead.Status)
                {
                    newLead.Last_Status_Change__c = Date.today();
                }
            }
            
            if(leadsNeedAssignment.size() > 0)
            {
                PatchRuleHelper.assignPatches(leadsNeedAssignment);
            }
            if(userIds.size()>0)
            {
                ProcessDealReg(userIds,dealRegLeads);
            }
        }
    }
    public void BeforeDelete(Map<Id,SObject> oldItems) 
    {
        if(oldItems.size()>0)
        {
            for(Id leadId:oldItems.keySet())
            {}}
    }
    public void AfterInsert(Map<Id, SObject> newItems) 
    {
        Map<String, Schema.RecordTypeInfo> leadRecordTypes = Lead.SObjectType.getDescribe().getRecordTypeInfosByName();
        Schema.RecordTypeInfo dealReg = leadRecordTypes.get('Deal Registration');
        List<Lead> needToShareLeads = new List<Lead>();
        List<Id> needToShareLeadIds = new List<Id>();
        
        Set<String> moveToSDCampaignStages = new Set<String> { '03 MQL', '04 SAL', '13 MQC', '14 SAC', 'MQL', 'SAL', 'MQC' };
        Set<String> excludedStatuses = new Set<String> {'Submitted', 'Approved', 'Rejected' };
        Set<String> rejectedStatuses = new Set<String> { 'Sales Rejected', 'Rejected' };
        String sdCampaignId = SalesDevelopmentHelper.getSDCampaign();
        
        List<CampaignMember> newSDCampaignMembers = new List<CampaignMember>();
        Set<Id> leadIdsToBeMovedOff = new Set<Id>();
        Map<Id, Lead> leadsToBeUpdated = new Map<Id, Lead>();
        if(newItems!=null && newItems.size()>0)
        {
            for (Id leadId : newItems.keyset())
            {
                Lead newLead =(Lead)newItems.get(leadId);
                if(!SilverPeakUtils.BypassingTriggers)
                {
                    PatchRuleHelper.leadsNeedAssignment.add(leadId); 
                }
                if(dealReg != null && newLead.RecordTypeId == dealReg.getRecordTypeId())
                {
                    needToShareLeads.add(newLead);
                    needToShareLeadIds.add(newLead.Id);
                }
                if(moveToSDCampaignStages.contains(newLead.Lead_Lifecycle_Stage__c) && !excludedStatuses.contains(newLead.Status))
                {
                    if(!leadsToBeUpdated.containsKey(newLead.Id))
                    {
                        leadsToBeUpdated.put(newLead.Id, new Lead(Id=newLead.Id));
                    }
                    leadsToBeUpdated.get(newLead.Id).Lead_Sub_Status__c = null;
                    newSDCampaignMembers.add(new CampaignMember(LeadId = newLead.Id, CampaignId = sdCampaignId));
                }
            }
            if(PatchRuleHelper.leadsNeedAssignment.size() > 0)
            {
                PatchRuleHelper.assignTeamMembers(PatchRuleHelper.leadsNeedAssignment);
                PatchRuleHelper.leadsNeedAssignment = new List<Id>();
            }
            if(needToShareLeads.size() > 0)
            {
                if(System.isFuture())
                {
                    ShareLeadAndOpportunityToPartnerHelper.shareLeads(needToShareLeads);
                }
                else
                {
                    //owner change in assignment rule may remove the sharing, making the sharing in async assures.
                    ShareLeadAndOpportunityToPartnerHelper.willShareLeads(needToShareLeadIds);
                }
            }
            MoveLeadsOnOffCampaign(newSDCampaignMembers, leadIdsToBeMovedOff, leadsToBeUpdated);
        }
    }
    public void AfterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) 
    {     
        Map<String, Schema.RecordTypeInfo> leadRecordTypes = Lead.SObjectType.getDescribe().getRecordTypeInfosByName();
        Schema.RecordTypeInfo dealReg = leadRecordTypes.get('Deal Registration');
        List<Lead> needToShareLeads = new List<Lead>();
        List<Id> needToShareLeadIds = new List<Id>();
        List<Contact> contacts = new List<Contact>();
       	Set<String> moveToSDCampaignStages = new Set<String> { '03 MQL', '04 SAL', '13 MQC', '14 SAC', 'MQL', 'SAL', 'MQC' };
        Set<String> excludedStatuses = new Set<String> {'Submitted', 'Approved', 'Rejected' };
        Set<String> rejectedStatuses = new Set<String> { 'Sales Rejected', 'Rejected' };
        String sdCampaignId = SalesDevelopmentHelper.getSDCampaign();
        
        List<CampaignMember> newSDCampaignMembers = new List<CampaignMember>();
        Set<Id> leadIdsToBeMovedOff = new Set<Id>();
        Map<Id, Lead> leadsToBeUpdated = new Map<Id, Lead>();
        if(newItems!=null && newItems.size()>0)
        {
            for (Id leadId : newItems.keyset())
            {
                Lead newLead= (Lead)newItems.get(leadId);
                Lead oldLead= (Lead)oldItems.get(leadId);  
                if(isChanged(oldLead, newLead, new String[] {'Registered_Distributor_Contact__c', 'Registered_Partner_Sales_Rep__c', 'Registered_Distributor__c', 'Registered_Partner__c'}))
                {
                    needToShareLeads.add(newLead);
                    needToShareLeadIds.add(newLead.Id);
                }
                if(newLead.IsConverted == true && newLead.Trial_Request_from_Marketplace__c == false && newLead.ConvertedContactId != null)
                {
                    contacts.add(new Contact(Id=newLead.ConvertedContactId, Lead_Status__c=newLead.Status));
                }
                PatchRuleHelper.leadsNeedAssignment.add(newLead.Id); 
            }
            if(PatchRuleHelper.leadsNeedAssignment.size() > 0)
            {
                PatchRuleHelper.assignTeamMembers(PatchRuleHelper.leadsNeedAssignment);
                PatchRuleHelper.leadsNeedAssignment = new List<Id>();
            }
            if(needToShareLeads.size() > 0)
            {
                if(System.isFuture())
                {
                    ShareLeadAndOpportunityToPartnerHelper.shareLeads(needToShareLeads);
                }
                else
                {
                    //owner change in assignment rule may remove the sharing, making the sharing in async assures.
                    ShareLeadAndOpportunityToPartnerHelper.willShareLeads(needToShareLeadIds);
                }
            }
            if(!contacts.isEmpty())
            {
                update contacts;
            }
            MoveLeadsOnOffCampaign(newSDCampaignMembers, leadIdsToBeMovedOff, leadsToBeUpdated);
        }
        
    }
    public void AfterDelete(Map<Id, SObject> oldItems) 
    {
        
    }
    public void AfterUndelete(Map<Id, SObject> newItems) 
    {
        
    }
    
    private void LinkRegisteredPartner(Set<String> marketplaceCodes,List<Lead> lstLeads)
    {
        if(!marketplaceCodes.isEmpty())
        {
            Map<String, Id> marketplaceCode2AccountId = new Map<String, Id>();
            for(Partner_Account_Profile__c PAP : [SELECT Id, Account__c, Marketplace_1__c, Marketplace_2__c, Marketplace_3__c FROM Partner_Account_Profile__c WHERE Marketplace_1__c IN :marketplaceCodes OR Marketplace_2__c IN :marketplaceCodes OR Marketplace_3__c IN :marketplaceCodes])
            {
                marketplaceCode2AccountId.put(PAP.Marketplace_1__c, PAP.Account__c);
                marketplaceCode2AccountId.put(PAP.Marketplace_2__c, PAP.Account__c);
                marketplaceCode2AccountId.put(PAP.Marketplace_3__c, PAP.Account__c);
            }
            marketplaceCode2AccountId.remove(null);
            marketplaceCode2AccountId.remove('');
            
            //Send Email Notification
            Map<Id, Account> accounts = new Map<Id, Account>([SELECT Id, (SELECT Id, Email FROM Contacts WHERE Primary_Account_Contact__c = true AND Email != null) FROM Account WHERE Id IN :marketplaceCode2AccountId.values()]);
            List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
            OrgWideEmailAddress orgAdd = [SELECT Id FROM OrgWideEmailAddress WHERE DisplayName = 'Silver Peak Notifications'];
            Messaging.SingleEmailMessage mail;
            List<String> toAddresses;
            String accountId;
            for(Lead lead : lstLeads)
            {
                if(marketplaceCode2AccountId.containsKey(lead.Marketplace_Code__c))
                {
                    accountId = marketplaceCode2AccountId.get(lead.Marketplace_Code__c);
                    lead.Registered_Partner__c = accountId;
                    toAddresses = new List<String>();
                    for(Contact contact : accounts.get(accountId).Contacts)
                    {
                        toAddresses.add(contact.Email);
                    }
                    if(!toAddresses.isEmpty())
                    {
                        mail = new Messaging.SingleEmailMessage();
                        mail.setToAddresses(toAddresses);
                        mail.setOrgWideEmailAddressId(orgAdd.Id);
                        mail.setSubject('A new lead was registered for your account.');
                        mail.setPlainTextBody('A new lead was registered for your account. Please review and assign to the appropriate team member.');
                        mails.add(mail);
                    }
                }
            }
            if(!mails.isEmpty())
            {
                try
                {
                    Messaging.SendEmailResult[] results = Messaging.sendEmail(mails);
                }
                catch(EmailException ex)
                {
                    System.debug('An exception thrown when sending emails: ' + ex);
                }
            }
        }
    }
    
    private void ProcessDealReg(Set<Id> userIds,List<Lead> lstLeads)
    {
        if(userIds.size()>0)        
        {
            userIds.add('005W0000001KS8w');
            Map<Id, User> portalUsers = new Map<Id, User>([select Id, ContactId, Contact.AccountId from User where Id in :userIds and ContactId!=null]);
            for(Lead newLead : lstLeads)
            {
                if(portalUsers.containsKey(newLead.Deal_Reg_By_Partner_Id__c))
                {
                    if(newLead.Registered_Partner__c == null)
                    {
                        newLead.Registered_Partner__c = portalUsers.get(newLead.Deal_Reg_By_Partner_Id__c).Contact.AccountId;
                    }
                    if(newLead.Registered_Partner_Sales_Rep__c == null)
                    {
                        newLead.Registered_Partner_Sales_Rep__c = portalUsers.get(newLead.Deal_Reg_By_Partner_Id__c).ContactId;
                    }
                }
            }
        }
    }
    //checks if the fields are changed in the sObjects
    private Boolean isChanged(sObject oldObj, sObject newObj, String[] fields)
    {
        for(String field : fields)
        {
            Object oldValue = oldObj.get(field);
            Object newValue = newObj.get(field);
            if(oldValue != newValue)
            {
                return true;
            }
        }
        return false;
    }
    private void MoveLeadsOnOffCampaign(List<CampaignMember>newSDCampaignMembers,Set<Id>leadIdsToBeMovedOff, Map<Id, Lead>leadsToBeUpdated)
    {
        String sdCampaignId = SalesDevelopmentHelper.getSDCampaign();
        //Move leads to SD campaign
        if(!newSDCampaignMembers.isEmpty())
        {
            Database.insert(newSDCampaignMembers, false);
        }

        //Move leads off SD campaign
        if(!leadIdsToBeMovedOff.isEmpty())
        {
            delete [select Id from CampaignMember where CampaignId = :sdCampaignId and LeadId in :leadIdsToBeMovedOff];
        }

        //Update leads
        if(!leadsToBeUpdated.isEmpty())
        {
            SilverPeakUtils.BypassingTriggers = true;
            Database.update(leadsToBeUpdated.values(), false);
            SilverPeakUtils.BypassingTriggers = false;
        }
    }
}