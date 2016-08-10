trigger SendWanOpFulfillmentEmail on Shipment__c (after update) {
    Map<Id,string> setShipmentIds= new Map<Id,string>();
    Map<Id,Id> setShipmentAccIds= new Map<Id,Id>();
    List<String> ccs = new List<string>();
    for(Shipment__c item:Trigger.New)
    {
        if(item.Send_email__c!=Trigger.oldMap.get(item.Id).Send_Email__c && item.Send_Email__c)
        {
            Contact con= [Select Id, Email from Contact where Id=:item.Shipment_Contact__c];
            setShipmentIds.put(item.Id,con.Email);
            setShipmentAccIds.put(item.Id,item.Shipment_Account__c);
        }
    }
    
    if(setShipmentIds.size()>0)
    {
        for(Id shipId:setShipmentIds.keyset())
        {
            List<string> lstCopyEmail= new List<String>();
            List<AccountTeamMember> lstTeamMember=[Select UserId,User.email,TeamMemberRole from AccountteamMember where AccountId=:setShipmentAccIds.get(shipId) and TeamMemberRole in('Account Manager','Systems Engineer')];
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
            string shipConemail=setShipmentIds.get(shipId);
            if(!string.isBlank(shipConemail))
            {  lstCopyEmail.add(shipConemail);}
          
            if(lstTeamMember!=null && lstTeamMember.size()>0)
            {
                for(AccountTeamMember member: lstTeamMember)
                {
                    lstCopyEmail.add(member.User.Email); 
                }            
            }
            lstCopyEmail.add('notifications@silver-peak.com');
            List<Asset> lstVXAsset=[Select Id,ContactId from Asset where Id in (Select Asset__c from Shipped_Line__c where Shipment_Id__c =:shipId) and Product2.Family='Virtual Image' and Hosted_GMS__c=false and Marketplace_Sourced_Opp__c=0 and (NOT Model__c='GX-V') and Model__c in:lstVXModels];
            
            if(lstVXAsset!=null && lstVXAsset.size()>0)
            {
                //lstCopyEmail.add(lstVXAsset[0].Contact.Email);
                // Send Email to VX
                List<EmailTemplate> template = [select Id from EmailTemplate where Name='WanOp Fulfillment Email VX' limit 1];
                if(template.size() > 0)
                {
                    Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                    email.setTemplateId(template[0].Id);
                    email.setTargetObjectId(lstVXAsset[0].ContactId);
                    email.setCcAddresses(lstCopyEmail);
                    email.setWhatId(shipId);
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
            List<Asset> lstVRXAsset=[Select Id,ContactId,Key_Generated__c,Marketplace_Sourced_Opp__c from Asset where Id in (Select Asset__c from Shipped_Line__c where Shipment_Id__c =:shipId) and Model__c in:lstVRXModels  and Key_Generated__c=true and Marketplace_Sourced_Opp__c=0];
            if(lstVRXAsset!=null && lstVRXAsset.size()>0)
            {
                
                // Send Email to VRX
                List<EmailTemplate> template = [select Id from EmailTemplate where Name='WanOp Fulfillment Email VRX' limit 1];
                if(template.size() > 0)
                {
                    Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                    email.setTemplateId(template[0].Id);
                    email.setTargetObjectId(lstVRXAsset[0].ContactId);
                    email.setCcAddresses(lstCopyEmail);
                    email.setWhatId(shipId);
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
    
}