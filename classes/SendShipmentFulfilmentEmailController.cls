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
        string shipmentType = ValidateShipmentType(shipments[0].Shipment_Account__c,shipments[0].Id);
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
    
    private boolean SendShipmentEmail(string emailTemplate,List<Shipment__c> shipments)
    {
        List<String> ccs = new List<string>();
        List<EmailTemplate> template = [select Id from EmailTemplate where Name=:emailTemplate limit 1];
        if(template.size() > 0)
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
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setTemplateId(template[0].Id);
            email.setTargetObjectId(shipments[0].Shipment_Contact__c);
            email.setCcAddresses(ccs);
            email.setWhatId(shipments[0].Id);
            email.setsaveAsActivity(false);
            Id orgWideEmail = SilverPeakUtils.getOrganizationWideEmailId('notifications@silver-peak.com');
            if(orgWideEmail != null)
            {
                email.setOrgWideEmailAddressId(orgWideEmail);
            }
            Messaging.sendEmail(new List<Messaging.Email> {email}, true);
            return true;
        }
        else
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Email template cannot be found. Please contact system admin.'));
            return false;
        }
        return false;
    }
    private string ValidateShipmentType(Id accountId, Id shipmentId)
    {
        
        string shipmentType='Shipping Fulfilment';
        boolean isEdgeConnect=false;
        integer counterData=0;
        List<Shipment__c> shipmentIds= new List<Shipment__c>();
        Set<Id> shipmentIdList = new Set<Id>();
        List<Shipped_Line__c> lstShipment = new List<Shipped_Line__c>();
        shipmentIds= [Select Id from Shipment__c where Shipment_Account__c=:accountId and PurchaseOrder__c!=null];
        
        if(shipmentIds.size()>0)
        {
            lstShipment= [Select Shipment_Id__c from Shipped_Line__c where Asset__r.Product2.Name like 'EC-%' and Asset__r.Status='Customer Subscription Active' and Shipment_Id__c=:shipmentIds];
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
        if(isEdgeConnect && counterData==1)
            shipmentType='EdgeConnect Fulfillment Email';
        else if(isEdgeConnect && counterData>1)
            shipmentType='EdgeConnect Add-On Email';
        
        return shipmentType;
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