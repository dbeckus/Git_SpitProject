trigger SendWanOPPOCFulfillmentEmail on Request__c (after update) {
    Map<Id,string> setPocIds= new Map<Id,string>();
    Map<Id,Id> setPOCAccIds= new Map<Id,Id>();
    List<String> ccs = new List<string>();
    List<Request__c> lstPOCToUpdate = new List<Request__c>();
    for(Request__c item:Trigger.New)
    {
        if(item.Send_email__c!=Trigger.oldMap.get(item.Id).Send_Email__c && item.Send_Email__c)
        {
            Contact con= [Select Id, Email from Contact where Id=:item.POC_Contact__c];
            Opportunity opp=[Select Id, AccountId from Opportunity where id=:item.Opportunity__c];
            setPocIds.put(item.Id,con.Email);
            setPOCAccIds.put(item.Id,opp.AccountId);
            Request__c req= new Request__c(Id=item.Id,Send_Email__c=false);
            lstPOCToUpdate.add(req);
            
        }
    }
    
    if(setPocIds.size()>0)
    {
        for(Id pocId:setPocIds.keyset())
        {
            List<string> lstCopyEmail= new List<String>();
            
            List<string>lstVXModels= new List<string>();
            lstVXModels.add('VX-0000');
            lstVXModels.add('VX-500');
            lstVXModels.add('VX-1000');
            lstVXModels.add('VX-2000');
            lstVXModels.add('VX-3000');
            lstVXModels.add('VX-4000');
            lstVXModels.add('VX-5000');
            lstVXModels.add('VX-6000');
            lstVXModels.add('VX-7000');
            lstVXModels.add('VX-8000');
            lstVXModels.add('VX-9000');
            string shipConemail=setPocIds.get(pocId);
          
            List<Request__c> members = [select Id, SE__r.Email,SE_Manager__r.Email,RSM_Manager__r.Email,RSM__r.Email from Request__c where Id=:pocId];
            
            if(members!=null && members.size()>0)
            {
                if(members[0].SE__r.Email!=null)
                {
                    lstCopyEmail.add(members[0].SE__r.Email);
                }
                if(members[0].SE_Manager__r.Email!=null)
                {
                    lstCopyEmail.add(members[0].SE_Manager__r.Email);
                }
                if(members[0].RSM_Manager__r.Email!=null)
                {
                    lstCopyEmail.add(members[0].RSM_Manager__r.Email);
                }
                if(members[0].RSM__r.Email!=null)
                {
                    lstCopyEmail.add(members[0].RSM__r.Email);
                }
            }
            lstCopyEmail.add('notifications@silver-peak.com');
            lstCopyEmail.add('prane@silver-peak.com');
            List<Asset> lstVXAsset=[Select Id,ContactId from Asset where POCRequest__c=:pocId and CreatedDate=today and Product2.Family='Virtual Image' and Hosted_GMS__c=false and Marketplace_Sourced_Opp__c=0 and (NOT Model__c='GX-V') and Model__c in:lstVXModels];
            
            if(lstVXAsset!=null && lstVXAsset.size()>0)
            {
                //lstCopyEmail.add(lstVXAsset[0].Contact.Email);
                // Send Email to VX
                List<EmailTemplate> template = [select Id from EmailTemplate where Name='POC WanOp Fulfillment Email VX' limit 1];
                if(template.size() > 0)
                {
                    Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                    email.setTemplateId(template[0].Id);
                    email.setTargetObjectId(lstVXAsset[0].ContactId);
                    email.setCcAddresses(lstCopyEmail);
                    email.setWhatId(pocId);
                    email.setsaveAsActivity(false);
                    Id orgWideEmail = SilverPeakUtils.getOrganizationWideEmailId('notifications@silver-peak.com');
                    if(orgWideEmail != null)
                    {
                        email.setOrgWideEmailAddressId(orgWideEmail);
                    }
                    
                    email.setCcAddresses(lstCopyEmail);
                    Messaging.sendEmail(new List<Messaging.Email> {email}, true);
                }
            }
            List<string>lstVRXModels= new List<string>();
            lstVRXModels.add('Velocity');
            lstVRXModels.add('VRX-2');
            lstVRXModels.add('VRX-4');
            lstVRXModels.add('VRX-6');
            lstVRXModels.add('VRX-8');
            List<Asset> lstVRXAsset=[Select Id,ContactId,Key_Generated__c,Marketplace_Sourced_Opp__c from Asset where POCRequest__c=:pocId and CreatedDate=today and Model__c in:lstVRXModels  and Key_Generated__c=true and Marketplace_Sourced_Opp__c=0];
            if(lstVRXAsset!=null && lstVRXAsset.size()>0)
            {
                
                // Send Email to VRX
                List<EmailTemplate> template = [select Id from EmailTemplate where Name='POC WanOp Fulfillment Email VRX' limit 1];
                if(template.size() > 0)
                {
                    Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                    email.setTemplateId(template[0].Id);
                    email.setTargetObjectId(lstVRXAsset[0].ContactId);
                    email.setCcAddresses(lstCopyEmail);
                    email.setWhatId(pocId);
                    email.setsaveAsActivity(false);
                    Id orgWideEmail = SilverPeakUtils.getOrganizationWideEmailId('notifications@silver-peak.com');
                    if(orgWideEmail != null)
                    {
                        email.setOrgWideEmailAddressId(orgWideEmail);
                    }
                    email.setCcAddresses(lstCopyEmail);
                    Messaging.sendEmail(new List<Messaging.Email> {email}, true);
                }
            }
        }
        
    }
    if(lstPOCToUpdate.size()>0)
    {
        update lstPOCToUpdate;
    }
    
}