trigger SendEmailToOppOwnerAfterQuoteApproved on SBQQ__Quote__c  (after update) {
    
    Set<Id> quoteIds= new Set<Id>();
    List<SBQQ__Quote__c> quotesToUpdate= new List<SBQQ__Quote__c>();
    if(Trigger.IsUpdate)
    {
        for(SBQQ__Quote__c newQuote:Trigger.New)
        {
            SBQQ__Quote__c oldQuote= Trigger.OldMap.get(newQuote.Id);
            if(newQuote.ApprovalStatus__c=='Approved' && newQuote.Trigger_Email__c)
            {
                quoteIds.add(newQuote.Id);
            }
            
        }
    }
    if(quoteIds.size()>0)
    {
        List<EmailTemplate> templates = [select Id from EmailTemplate where DeveloperName='Steelbrick_Final_Quote_Approval' limit 1];
        for(Id counter:quoteIds)
        {
            SBQQ__Quote__c  quoteData=[Select Id,SBQQ__Opportunity2__r.OwnerId from SBQQ__Quote__c where Id=:counter];
            Messaging.SingleEmailMessage singleMessage= new Messaging.SingleEmailMessage();
            singleMessage.setWhatId(counter);
            singleMessage.setTargetObjectId(quoteData.SBQQ__Opportunity2__r.OwnerId);
            singleMessage.setTemplateID(templates[0].Id);
            singleMessage.setSaveAsActivity(false);
            //singleMessage.setCcAddresses(new string[] { 'prane@silver-peak.com' });
            try
            {
                if(!Test.isRunningTest())
                { 
                    Messaging.sendEmail(new Messaging.Email[] {singleMessage});
                }
                
                quotesToUpdate.add(new SBQQ__Quote__c(Id=counter,Trigger_Email__c=false));
               
            }
            catch(Exception ex)
            {
                SilverPeakUtils.logException(ex);
            }
            
        }
        if(quotesToUpdate.size()>0)
        {
            update quotesToUpdate;
        }
    }
    
}