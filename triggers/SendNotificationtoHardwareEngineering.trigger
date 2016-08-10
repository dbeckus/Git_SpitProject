trigger SendNotificationtoHardwareEngineering on RMA__c (after update) {
    Set<Id> setRMAs= new Set<Id>();
    
    for(RMA__c item: Trigger.New)
    {
        RMA__c oldRMA=Trigger.OldMap.get(item.Id);
        if(item.Type__c=='Advance Replace'&& item.Status__c=='In FA/Recd' && oldRMA.Status__c!=item.Status__c)
        {
            setRMAs.add(item.Id);
        }
    }
    
    
    List<RMA_Item__c> rmaItems=[Select Id,Asset__r.Name,Asset__r.Product2.Name,RMA__r.Name,RMA__r.Disposition__c,RMA__r.Disposition_Notes__c,RMA__r.Account__r.Name,RMA__r.Contact__r.Id from RMA_Item__c where RMA__c in:setRMAs];
    
    if(rmaItems!=null && rmaItems.size()>0)
    {
        List<Messaging.SingleEmailMessage> allmsg = new List<Messaging.SingleEmailMessage>();
        for(RMA_Item__c item:rmaItems)
        {
            
            OrgWideEmailAddress owa = [select id, DisplayName, Address from OrgWideEmailAddress where DisplayName='Silver Peak Notifications' limit 1];
            String templateString='S/N {0} ({1}) has been returned from {2} against {3}.\n\n\n';
            String[] arguments = new String[] {item.Asset__r.Name, item.Asset__r.Product2.Name,item.RMA__r.Account__r.Name,item.RMA__r.Name};
            string bodyText= string.format(templateString,arguments);
            bodyText= bodyText+ 'Disposition Location: '+ item.RMA__r.Disposition__c +'\n';
            bodyText= bodyText+ 'Notes: '+ item.RMA__r.Disposition_Notes__c;
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setSaveAsActivity(false);
            mail.setOrgWideEmailAddressId(owa.id);
            List<String> sendTo = new List<String>();
            sendTo.add('hware@silver-peak.com');
            mail.setToAddresses(sendTo);
            mail.setSubject(item.RMA__r.Name +' faulty system received');
            mail.setPlainTextBody (bodyText);
            List<String> ccTo = new List<String>();
            ccTo.add('notifications@silver-peak.com');
            mail.setCcAddresses(ccTo);
            allmsg.add(mail);
            
        }
        if(allmsg.size()>0)
        {
            if(!Test.isRunningTest())
            {
                Messaging.sendEmail(allmsg,false);
            }
            
        }
        
    }
    
    
}