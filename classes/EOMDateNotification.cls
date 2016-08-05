/*
 * Schedule email notification when EOMDate of assets are satisfied.
 */
 global class EOMDateNotification implements Schedulable, Database.Batchable<sObject>, Database.Stateful
 {
     private Integer contractCount = 0;
     
     global void execute(SchedulableContext SC)
     {
         EOMDateNotification notificationBatch = new EOMDateNotification();
         Database.executeBatch(notificationBatch, 50);
     }

     global Database.QueryLocator start(Database.BatchableContext BC)
     {
        return Database.getQueryLocator([select Id, Owner.Id FROM Account where Suppress_EOM_Notices__c=false]);
     }

     global void execute(Database.BatchableContext BC, List<Account> scope)
     {
         Set<Id> contractIds = new Set<Id>();
         List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
         List<Date> expiredDates = new List<Date>{ Date.today().addMonths(1), Date.today().addMonths(3), Date.today().addMonths(6), Date.today().addYears(1), Date.today().addMonths(18) };
         List<EmailTemplate> eomTemplate = [SELECT Id FROM EmailTemplate Where DeveloperName = 'EOMNotification' limit 1];
         List<OrgWideEmailAddress> addresses = [select Id from OrgWideEmailAddress where Address='notifications@silver-peak.com' limit 1];
         Id orgWideEmailId = (addresses.size() > 0) ? addresses[0].Id : null;
         Map<Id, Id> accountIdToOwnerId = new Map<Id, Id>();
         Map<Id, Set<String>> accountIdToContactEmails = new Map<Id, Set<String>>();

         for(Asset asset : [SELECT Id, AccountId, Account.Owner.Id, Contract_Number__c, Contract_Number__r.CustomerSigned.Email, Contract_Number__r.Customer_Addl_Notices__r.Email, Contract_Number__r.Customer_Addl_Notices_2__r.Email FROM Asset
                             WHERE AccountId in :scope AND End_of_Maintenance__c IN :expiredDates AND Contract_Number__r.Status = 'Activated'])
         {
             contractIds.add(asset.Contract_Number__c);
             if(!accountIdToOwnerId.containsKey(asset.AccountId))
             {
                accountIdToOwnerId.put(asset.AccountId, asset.Account.Owner.Id);
             }

             if(accountIdToContactEmails.containsKey(asset.AccountId))
             {
                accountIdToContactEmails.get(asset.AccountId).add(asset.Contract_Number__r.CustomerSigned.Email);
             }
             else
             {
                 accountIdToContactEmails.put(asset.AccountId, new Set<String>{ asset.Contract_Number__r.CustomerSigned.Email });
             }
             accountIdToContactEmails.get(asset.AccountId).add(asset.Contract_Number__r.Customer_Addl_Notices__r.Email);
             accountIdToContactEmails.get(asset.AccountId).add(asset.Contract_Number__r.Customer_Addl_Notices_2__r.Email);
         }

         if(eomTemplate.size() > 0)
         {
             contractCount += contractIds.size();
             for(String accountId : accountIdToOwnerId.keySet())
             {
                 mails.add(createEmail(eomTemplate[0].Id, orgWideEmailId, accountId, accountIdToOwnerId.get(accountId), accountIdToContactEmails.get(accountId)));
             }
         }

         if(mails.size() > 0)
         {
             Messaging.sendEmail(mails);
         }
     }


     global void finish(Database.BatchableContext BC)
     {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setSubject('EOM Date Notification Finished');
        mail.setPlainTextBody('Total number of contracts notified: ' + contractCount);
        mail.setSaveAsActivity(false);
        mail.setToAddresses(new String[] { 'notifications@silver-peak.com' });
        mail.setUseSignature(false);
        Messaging.sendEmail(new Messaging.Email[] { mail });
     }

     private Messaging.SingleEmailMessage createEmail(Id emailTemplateId, Id orgWideEmailId, String accountId, String accountOwnerId, Set<String> emails)
     {
         Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
         mail.setTemplateId(emailTemplateId);
         mail.setTargetObjectId(accountOwnerId);
         List<String> emailsList = new List<String>();
         emails.remove(null);
         emailsList.addAll(emails);
         emailsList.add('notifications@silver-peak.com');
         mail.setCcAddresses(emailsList);
         //mail.setCcAddresses(new List<String> { 'piziliguang@163.com' });
         mail.setWhatId(accountId);
         mail.setSaveAsActivity(false);
         if(orgWideEmailId != null)
         {
             mail.setOrgWideEmailAddressId(orgWideEmailId);
         }
         return mail;
     }

     @isTest
     global static void testEOMNotification()
     {
        //ready for testing data
        EOMDate__c date1 = new EOMDate__c(Name='acme',Model__c='NX-2500', ShipDate__c=Date.parse('9/1/2012'), EOMDate__c=Date.parse('10/1/2012'));
        EOMDate__c date2 = new EOMDate__c(Name='acme2',Model__c='NX-5600', ShipDate__c=Date.parse('9/1/2012'), EOMDate__c=Date.parse('7/1/2016'));
        EOMDate__c date3 = new EOMDate__c(Name='acme3',Model__c='NX-2700', ShipDate__c=Date.parse('9/1/2012'), EOMDate__c=Date.parse('2/1/2018'));
        EOMDate__c date4 = new EOMDate__c(Name='acme4',Model__c='NX-2700', ShipDate__c=Date.parse('9/1/2012'), EOMDate__c=Date.parse('2/1/2017'));
        EOMDate__c date5 = new EOMDate__c(Name='acme5',Model__c='NX-8504', ShipDate__c=Date.parse('9/1/2012'), EOMDate__c=Date.parse('10/1/2012'));
        insert new EOMDate__c[]{ date1, date2, date3, date4, date5 };
        Product2 product1 = new Product2(IsActive=true, Name='acme', Forecast_Category__c='Virtual', Family = 'Virtual Image', Model__c = 'NX-2500');
        Product2 product2 = new Product2(IsActive=true, Name='acme', Forecast_Category__c='Virtual', Family = 'Virtual Image', Model__c = 'NX-5600');
        insert new Product2[]{ product1, product2};

        Account testAccount = new Account(Name='acme');
        insert testAccount;
        Contact testContact = new Contact(LastName = 'acme', AccountId = testAccount.Id, Email='test@test.com');
        insert testContact;
        Contract newContract = new Contract(AccountId = testAccount.Id, SP_Contract_Number__c = 'acme', Status = 'Draft', CustomerSignedId=testContact.Id);
        insert newContract;
        newContract.Status = 'Activated';
        update newContract;

        Asset asset1 = new Asset(Name='acme', Ship_Date__c = Date.newInstance(2000,01,01), Product2Id=product1.Id, Contract_Number__c = newContract.Id,
                             Quantity=1.00, Status='Conditional PO', AccountId=testAccount.Id,
                             ContactId=testContact.Id, End_of_Maintenance__c = Date.today().addDays(30));
        Asset asset2 = new Asset(Name='acme', Ship_Date__c = Date.newInstance(2000,01,01), Product2Id=product1.Id, Contract_Number__c = newContract.Id,
                             Quantity=1.00, Status='Conditional PO', AccountId=testAccount.Id,
                             ContactId=testContact.Id, End_of_Maintenance__c = Date.today().addDays(180));
        insert new Asset[]{asset1, asset2};
        asset1.End_Of_maintenance__c = Date.today().addDays(30);
        asset2.End_Of_maintenance__c = Date.today().addDays(180);
        update new Asset[]{asset1, asset2};

        system.assertEquals(1, [SELECT Id, CustomerSignedId FROM Contract WHERE id = :newContract.Id].size());
        system.assertEquals(2, [SELECT End_of_Maintenance__c FROM Asset WHERE End_of_Maintenance__c != null AND Contract_Number__c = :newContract.Id].size());
        Test.startTest();
        EOMDateNotification notification = new EOMDateNotification();
        notification.execute(null);
        Test.stopTest();
     }
 }