/*
 * If the lead has a marketplace code, set the Registered Partner to an account with the same code on its Partner Account Profile.
 */
trigger LinkLeadToRegisteredPartner on Lead (before insert, before update) 
{
    if(!SilverPeakUtils.BypassingTriggers)
    {
        Set<String> marketplaceCodes = new Set<String>();
        List<Lead> processingLeads = new List<Lead>();
        if(Trigger.isInsert)
        {
            for(Lead lead : Trigger.new)
            {
                if(String.isNotBlank(lead.Marketplace_Code__c))
                {
                    marketplaceCodes.add(lead.Marketplace_Code__c.toUpperCase());
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
                    if(String.isNotBlank(lead.Marketplace_Code__c))
                    {
                        marketplaceCodes.add(lead.Marketplace_Code__c.toUpperCase());
                        processingLeads.add(lead);
                    }
                    else
                    {
                        lead.Registered_Partner__c = null;
                    }
                }
            }
        }

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
            for(Lead lead : processingLeads)
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
}