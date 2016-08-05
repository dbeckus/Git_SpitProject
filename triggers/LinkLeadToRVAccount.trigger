/*
 * If the lead has a marketplace code, link it to a RV Account with the same code.
 */
trigger LinkLeadToRVAccount on Lead (before insert, before update) 
{
    /*
    if(!SilverPeakUtils.BypassingTriggers)
    {
        Set<String> marketplaceCodes = new Set<String>();
        List<Lead> processingLeads = new List<Lead>();
        if(Trigger.isInsert)
        {
            for(Lead lead : Trigger.new)
            {
                if(lead.Marketplace_Code__c != null)
                {
                    lead.Marketplace_Code__c = lead.Marketplace_Code__c.toUpperCase();
                    marketplaceCodes.add(lead.Marketplace_Code__c);
                    processingLeads.add(lead);
                }
            }
        }
        if(Trigger.isUpdate)
        {
            for(Lead lead : Trigger.new)
            {
                if(lead.Marketplace_Code__c != Trigger.oldMap.get(lead.Id).Marketplace_Code__c)
                {
                    if(lead.Marketplace_Code__c == null)
                    {
                        lead.rvpe__RVAccount__c = null;
                    }
                    else
                    {
                        marketplaceCodes.add(lead.Marketplace_Code__c);
                        processingLeads.add(lead);
                    }
                }
            }
        }
        if(marketplaceCodes.size() > 0)
        {
            Map<String, Id> rvAccountMap = new Map<String, Id>();
            Map<String, List<rvpe__RVMember__c>> rvMemberMap = new Map<String, List<rvpe__RVMember__c>>();
            for(rvpe__RVAccount__c account : [select Id, Marketplace_Code_1__c, Marketplace_Code_2__c, Marketplace_Code_3__c, Marketplace_Code_4__c, (select rvpe__Email__c from rvpe__RVMembers__r where Lead_Administrator__c = true and rvpe__Email__c != null) from rvpe__RVAccount__c where Marketplace_Code_1__c in :marketplaceCodes or Marketplace_Code_2__c in :marketplaceCodes or Marketplace_Code_3__c in :marketplaceCodes or Marketplace_Code_4__c in :marketplaceCodes])
            {
                rvAccountMap.put(account.Marketplace_Code_1__c, account.Id);
                rvAccountMap.put(account.Marketplace_Code_2__c, account.Id);
                rvAccountMap.put(account.Marketplace_Code_3__c, account.Id);
                rvAccountMap.put(account.Marketplace_Code_4__c, account.Id);
                rvMemberMap.put(account.Id, account.rvpe__RVMembers__r);
            }
            rvAccountMap.remove(null);
            rvAccountMap.remove('');
            
            List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
            OrgWideEmailAddress orgAdd = [select Id from OrgWideEmailAddress where DisplayName = 'Silver Peak Notifications'];
            Messaging.SingleEmailMessage mail;
            List<String> toAddresses;
            for(Lead lead : processingLeads)
            {
                if(rvAccountMap.containsKey(lead.Marketplace_Code__c))
                {
                    lead.rvpe__RVAccount__c = rvAccountMap.get(lead.Marketplace_Code__c);
                    toAddresses = new List<String>();
                    for(rvpe__RVMember__c member : rvMemberMap.get(lead.rvpe__RVAccount__c))
                    {
                        toAddresses.add(member.rvpe__Email__c); //Testing in sandbox.
                    }
                    if(toAddresses.size() > 0)
                    {
                        mail = new Messaging.SingleEmailMessage();
                        mail.setToAddresses(toAddresses);
                        //mail.setCcAddresses(new List<String> { 'curtisc@silver-peak.com' } ); //Testing in sandbox.
                        mail.setOrgWideEmailAddressId(orgAdd.Id);
                        mail.setSubject('A new lead was registered for your account.');
                        mail.setPlainTextBody('A new lead was registered for your account. Please review and assign to the appropriate team member.');
                        mails.add(mail);
                    }
                }
            }
            
            if(mails.size() > 0)
            {
                Messaging.sendEmail(mails);
            }
        }
    }*/
}