/*
 * Create purchase request on new MDF creation
 */
trigger CreatePurchasingRequests on MDF_Request__c (before insert, after insert)
{
    if(Trigger.isBefore)
    {
        User currentUser = [select Id, ContactId from User where Id = :UserInfo.getUserId() limit 1];
        List<Contact> contacts = [select Id, AccountId, Account.OwnerId, Account.Owner.GEO_Region__c, Account.Patch__c, Account.Patch__r.CSM__c, Account.Patch__r.CSM__r.GEO_Region__c, Account.Patch__r.RSM__c, Account.Patch__r.RSM__r.GEO_Region__c from Contact where Id = :currentUser.ContactId limit 1];
        Account currentAccount = (contacts.size() > 0) ? contacts[0].Account : null;
        Contact currentContact = (contacts.size() > 0) ? contacts[0] : null;
        
        List<RecordType> purchaseRecordType = [select Id from RecordType where SobjectType = 'Purchasing_Request__c' and Name = 'MDF Request' limit 1];
        Id purchaseRecordTypeId = (purchaseRecordType.size() > 0) ? purchaseRecordType[0].Id : null;
        List<Purchasing_Request__c> purchaseRequests = new List<Purchasing_Request__c>();
        for(MDF_Request__c request : trigger.new)
        {
            Purchasing_Request__c purchaseRequest = new Purchasing_Request__c(RecordTypeId = purchaseRecordTypeId);
            purchaseRequests.add(purchaseRequest);
        }
        insert purchaseRequests;
        
        MDF_Request__c request;
        for(Integer i = 0; i < trigger.new.size(); i++)
        {
            request = trigger.new[i];
            if(request.Account__c == null)
            {
                updateGEO(request, currentAccount, currentContact);
            }
            if(request.Purchasing_Request__c == null)
            {
                request.Purchasing_Request__c = purchaseRequests[i].Id;
            }
        }
    }
    else if(Trigger.isAfter)
    {
        List<MDF_Request__c> mdfs = [select Id, Purchasing_Request__c, Account__c, Account__r.Name, OwnerId, Owner.Name, Owner.Email, Company_Billing_Address__c, Remit_to_Address__c from MDF_Request__c where Id in :Trigger.new];
        List<Purchasing_Request__c> requests = new List<Purchasing_Request__c>();
        for(MDF_Request__c mdf : mdfs)
        {
            Purchasing_Request__c request = new Purchasing_Request__c(Id=mdf.Purchasing_Request__c);
            request.Vendor_Name__c = mdf.Account__r.Name;
            request.Vendor_Contact__c = mdf.Owner.Name;
            request.Vendor_Email__c = mdf.Owner.Email;
            request.Vendor_Address__c = isBlankAddress(mdf.Remit_to_Address__c) ? mdf.Company_Billing_Address__c : mdf.Remit_to_Address__c;
            requests.add(request);
        }
        Database.update(requests, false);
    }
    
    private Boolean isBlankAddress(String address)
    {
        if(String.isBlank(address))
        {
            return true;
        }
        return String.isBlank(address.replaceAll('[,\\s\\r\\n]', ''));
    }
    
    private void updateGEO(MDF_Request__c req, Account acc, Contact ct)
    {
        if(acc != null)
        {
            req.Account__c = acc.Id;
            //req.CSM__c = acc.Patch__r.CSM__c;
            //req.RSM__c = acc.Patch__r.RSM__c;
            req.GEO__c = acc.Patch__r.CSM__r.GEO_Region__c;
            /*if(req.CSM__c == null)
            {
                req.CSM__c = acc.OwnerId;
            }
            if(req.RSM__c == null)
            {
                req.RSM__c = acc.OwnerId;
            }*/
            if(String.isBlank(req.GEO__c))
            {
                req.GEO__c = acc.Owner.GEO_Region__c;
            }
            if(String.isNotBlank(req.GEO__c))
            {
                String geo = req.GEO__c;
                String[] parts = geo.split('-');
                if(parts.size() >= 1)
                {
                    req.GEO__c = parts[0];
                }
            }
        }
        if(ct != null)
        {
            req.Submitter__c = ct.Id;
        }
    }
}