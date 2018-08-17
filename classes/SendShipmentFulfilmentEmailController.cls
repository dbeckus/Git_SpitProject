public class SendShipmentFulfilmentEmailController
{
    private Id shipmentId;
    
    public SendShipmentFulfilmentEmailController(ApexPages.StandardController ctrl)
    {
        shipmentId = ctrl.getId();
    }
    
    public PageReference send()
    {
        boolean isMailSent=false;
        List<Shipment__c> shipments = [select Id, Shipment_Account__c, Shipment_Contact__c from Shipment__c where Id=:shipmentId limit 1];
        if(shipments.size() == 0)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'You must click "Send Fulfilment Email" button on a shipment.'));
            return null;
        }
        if(shipments[0].Shipment_Contact__c == null)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'The shipment doesn\'t have a shipping contact.'));
            return null;
        }
        List<string> shipmentType = ValidateShipmentType(shipments[0].Shipment_Account__c,shipments[0].Id);
        isMailSent= SendShipmentEmail(shipmentType,shipments);
        if(isMailSent)
        {
            return new PageReference('/' + shipmentId);
        }
        return null;
    }
    
    private List<String> getAccountTeam(Id accId)
    {
        List<AccountTeamMember> members = [select Id, User.EMail from AccountTeamMember where AccountId=:accId and User.isActive=true];
        List<String> emails = new List<String>();
        for(AccountTeamMember atm : members)
        {
            emails.add(atm.User.Email);
        }
        return emails;
    }
    
    private boolean SendShipmentEmail(List<string> emailTemplates,List<Shipment__c> shipments)
    {
        List<String> ccs = new List<string>();
        List<EmailTemplate> lstTemplates = [select Id, Name from EmailTemplate where Name=:emailTemplates];
        if(lstTemplates.size() > 0)
        {
            string assetContactEmail= RetreiveAssetContact(shipments[0].Id);
            if(assetContactEmail!=null && assetContactEmail!='' )
            {
                ccs.add(assetContactEmail);
            }
            List<String> accTeamMember=getAccountTeam(shipments[0].Shipment_Account__c);
            if(accTeamMember!=null && accTeamMember.size()>0 )
            {
                ccs.addAll(accTeamMember);
            }
            ccs.add('notifications@silver-peak.com');
            
            List<Messaging.SingleEmailMessage> emailmessages = new List<Messaging.SingleEmailMessage>();  
            for(EmailTemplate template: lstTemplates)
            {
                if(template.Name =='EdgeConnect Fulfillment Email' || template.Name =='EdgeConnect Add-On Email' || template.Name == 'EdgeConnect Unity Orch Fulfillment Email')
                {
                    ccs.add('RenewalsTeam@silver-peak.com');
                }
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                email.setTemplateId(template.Id);
                email.setTargetObjectId(shipments[0].Shipment_Contact__c);
                email.setCcAddresses(ccs);
                email.setWhatId(shipments[0].Id);
                email.setsaveAsActivity(false);
                Id orgWideEmail = SilverPeakUtils.getOrganizationWideEmailId('notifications@silver-peak.com');
                if(orgWideEmail != null)
                {
                    email.setOrgWideEmailAddressId(orgWideEmail);
                }
                emailmessages.add(email);
            } 
            system.debug('number of emails:'+ emailmessages.size());
            Messaging.sendEmail(emailmessages, true);
            return true;   
        }
        else
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Email template cannot be found. Please contact system admin.'));
            return false;
        }
        
        return false;
    }
    private List<string> ValidateShipmentType(Id accountId, Id shipmentId)
    {
        
        string shipmentType='Shipping Fulfilment';
        boolean isEdgeConnect=false;
        boolean isServiceProvider=false;
        boolean hasECORCH=false;
        boolean hasNonORCH=false;
        integer counterData=0;
        List<String> lstShipmentTemplates= new List<String>();
        List<Shipment__c> shipmentIds= new List<Shipment__c>();
        Set<Id> shipmentIdList = new Set<Id>();
        List<Shipped_Line__c> lstShipment = new List<Shipped_Line__c>();
        List<Shipped_Line__c> lstOrchShipment = new List<Shipped_Line__c>();
        List<Shipped_Line__c> lstNonOrchShipment = new List<Shipped_Line__c>();
        
        lstShipment= [Select Shipment_Id__c from Shipped_Line__c where Asset__r.Product2.Name like 'EC-%' and Asset__r.Status='Customer Owned' and Asset__r.Product2.Product_Type__c in('EC-SP-Perpetual','EC-SP-Term') and Shipment_Id__c=:shipmentId];
        lstOrchShipment = [Select Shipment_Id__c from Shipped_Line__c where Asset__r.Product2.Name like 'EC-ORCH-AAS%' and Asset__r.Status='Customer Subscription Active' and Asset__r.Product2.Product_Type__c ='EDGECONNECT' and Shipment_Id__c=:shipmentId];
        lstNonOrchShipment = [Select Shipment_Id__c from Shipped_Line__c where (NOT Asset__r.Product2.Name like 'EC-ORCH-AAS%') and Asset__r.Status='Customer Subscription Active' and Asset__r.Product2.Product_Type__c ='EDGECONNECT' and Shipment_Id__c=:shipmentId];
        
        if(lstShipment.size()>0)
        {
            isServiceProvider=true;
        }
        else 
        {
            if(lstOrchShipment.size()>0)
            {
                hasECORCH=true;
            }
            if(lstNonOrchShipment.size()>0)
            {
                hasNonORCH=true;
            }
            shipmentIds= [Select Id from Shipment__c where Shipment_Account__c=:accountId and PurchaseOrder__c!=null];
            if(shipmentIds.size()>0)
            {
                lstShipment= [Select Shipment_Id__c from Shipped_Line__c where Asset__r.Product2.Name like 'EC-%' and Asset__r.Status='Customer Subscription Active' and Asset__r.Product2.Product_Type__c ='EDGECONNECT' and Shipment_Id__c=:shipmentIds];
            }
            if(lstShipment!=null && lstShipment.size()>0)
            {
                
                for(Shipped_Line__c item :lstShipment)
                {
                    shipmentIdList.add(item.Shipment_Id__c);
                }
                
                if(shipmentIdList.size()>0 && shipmentIdList.contains(shipmentId))
                {
                    counterData= shipmentIdList.size();
                    isEdgeConnect=true;                
                }
            }
            
        }
        if(isEdgeConnect && counterData==1)
        {
            shipmentType='EdgeConnect Fulfillment Email';
            lstShipmentTemplates.add(shipmentType);
        }
        else if(isEdgeConnect && counterData>1)
        {
            if(hasNonORCH)
            {
                shipmentType='EdgeConnect Add-On Email';
                lstShipmentTemplates.add(shipmentType);
            }
            if(hasECORCH)
            {
                shipmentType='EdgeConnect Unity Orch Fulfillment Email';
                lstShipmentTemplates.add(shipmentType);
            }
        }
        else if(isServiceProvider)
        {
            shipmentType='SP Shipping Fulfilment';
            lstShipmentTemplates.add(shipmentType);
        }
        else
        {
            lstShipmentTemplates.add(shipmentType);
        }
        system.debug('lstShipmentTemplates Info:' + lstShipmentTemplates);
        return lstShipmentTemplates; 
    }
    
    private string RetreiveAssetContact(Id shipmentId)
    {
        List<Asset> lstAsset= [Select Contact.Email from Asset where Id in(Select Asset__c from Shipped_Line__c where Shipment_Id__c=:shipmentId) ];
        if(lstAsset!=null && lstAsset.size()>0)
        {
            return lstAsset[0].Contact.Email;
        }
        
        return '';
    }
}