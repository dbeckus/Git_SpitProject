/*
 * Create purchase request on new MDF creation
 * 26MAY2017 - fixed bug where CSM and RSM were being set before Account was set
 */
trigger CreatePurchasingRequests on MDF_Request__c (before insert, after insert)
{
    if(Trigger.isBefore)
    {
        User currentUser = [select Id, ContactId from User where Id = :UserInfo.getUserId() limit 1];
        List<Contact> contacts = [select Id, AccountId, Account.OwnerId, Account.Owner.GEO_Region__c, Account.Patch__c, Account.Patch__r.CSM__c, Account.Patch__r.CSM__r.GEO_Region__c, Account.Patch__r.Owner__r.GEO_Region__c, Account.Patch__r.RSM__c, Account.Patch__r.RSM__r.GEO_Region__c from Contact where Id = :currentUser.ContactId limit 1];
        Account currentAccount = (contacts.size() > 0) ? contacts[0].Account : null;
        Contact currentContact = (contacts.size() > 0) ? contacts[0] : null;
        Map<Id, Account> moreAccounts = getAccounts(Trigger.new);
        Map<Id, Contact> moreContacts = getContacts(Trigger.new);
        
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
                //MDF created by portal user
                updateGEO(request, currentAccount, currentContact);
            }
            else
            {
                //MDF created by internal user
                Account acc = moreAccounts.get(request.Account__c);
                Contact ct = moreContacts.get(request.Contact__c);
                updateGEO(request, acc, ct);
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
            req.CSM__c = acc.Patch__r.CSM__c;
            req.RSM__c = acc.Patch__r.RSM__c;
            //setting GEO to that of patch owner instead of CAM
            req.GEO__c = acc.Patch__r.Owner__r.GEO_Region__c;
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
    
    private Map<Id, Account> getAccounts(List<MDF_Request__c> mdfs)
    {
        Set<Id> accIds = new Set<Id>();
        for(MDF_Request__c mdf : mdfs)
        {
            accIds.add(mdf.Account__c);
        }
        return new Map<Id, Account>([select Id, OwnerId, Owner.GEO_Region__c, Patch__c, Patch__r.CSM__c, Patch__r.CSM__r.GEO_Region__c, Patch__r.Owner__c, Patch__r.Owner__r.GEO_Region__c, Patch__r.RSM__c, Patch__r.RSM__r.GEO_Region__c from Account where Id in :accIds]);
    }
    
    private Map<Id, Contact> getContacts(List<MDF_Request__c> mdfs)
    {
        Set<Id> contactIds = new Set<Id>();
        Map<Id, Contact> result = new Map<Id, Contact>();
        for(MDF_Request__c mdf : mdfs)
        {
            if(mdf.Contact__c != null)
            {
                result.put(mdf.Contact__c, new Contact(Id=mdf.Contact__c));
            }
        }
        return result;
    }
}