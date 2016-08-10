public  class ContactOwnershipHelper {
    
    public static void UpdateContactOwnership(Id accId)
    {
        List<Contact> lstContacts= new List<Contact>();
        Account acc =[Select Id,Type,Patch__r.RSM__c,Patch__r.CSM__c from Account where Id=:accId];
        List<Contact> contacts=[Select Id,OwnerId from Contact where AccountId=:accId];
        if(contacts!=null && contacts.size()>0)
        {
            for(Contact con: contacts)
            {
                if(acc.Type=='Prospect' || acc.Type=='Customer')
                {
                    if(acc.Patch__r.RSM__c!=null && con.OwnerId!=acc.Patch__r.RSM__c)
                    {
                        con.OwnerId= acc.Patch__r.RSM__c;
                        lstContacts.add(con);
                    }
                    
                }
                if(acc.Type=='Other' || acc.Type=='Competitor')
                {
                    
                    con.OwnerId= '00550000002rxts';// Evan id;
                    lstContacts.add(con);
                    
                    
                }
                else if(acc.Type=='Partner')
                {
                    if(acc.Patch__r.CSM__c!=null && con.OwnerId!=acc.Patch__r.CSM__c)
                    {
                        con.OwnerId= acc.Patch__r.CSM__c;
                        lstContacts.add(con);
                    }
                }
                
                
            }
        }
        
        if(lstContacts.size()>0)
        {
            update lstContacts;
        }
        
    }
    
    public static void UpdateContactOwnership_Bulk(Set<Id> lstaccId)
    {
        List<Contact> lstContactsToUpdate= new List<Contact>();
        //List<Account> lstAcc =[Select Id,Type,Patch__r.RSM__c,Patch__r.CSM__c from Account where Id in:lstaccId];
        List<Contact> lstContacts=[Select Id,OwnerId,AccountId,Account.Type,Account.Patch__r.RSM__c,Account.Patch__r.CSM__c from Contact where AccountId in:lstAccId];
        if(lstContacts!=null && lstContacts.size()>0)
        {
            for(Contact item: lstContacts)
            {
                
                if(item.Account.Type=='Prospect' || item.Account.Type=='Customer')
                {
                    if(item.Account.Patch__r.RSM__c!=null && item.OwnerId!=item.Account.Patch__r.RSM__c)
                    {
                        item.OwnerId= item.Account.Patch__r.RSM__c;
                        lstContactsToUpdate.add(item);
                    }
                    
                }
                if(item.Account.Type=='Other' || item.Account.Type=='Competitor')
                {
                    
                    item.OwnerId= '00550000002rxts';// Evan id;
                    lstContactsToUpdate.add(item);
                    
                    
                }
                else if(item.Account.Type=='Partner')
                {
                    if(item.Account.Patch__r.CSM__c!=null && item.OwnerId!=item.Account.Patch__r.CSM__c)
                    {
                        item.OwnerId= item.Account.Patch__r.CSM__c;
                        lstContactsToUpdate.add(item);
                    }
                }
                
                
                
                
            }
        }
    if(lstContactsToUpdate.size()>0)
    {
        update lstContactsToUpdate;
    }
    
}

@future
public static void DisableAllowSelfReg(Set<Id> conList)
{
    List<Contact> lstConToUpdate= new List<Contact>();
for(Id con: conList)
{
System.debug('CanAllowPortalSelfReg');
Contact item= new Contact();
item.Id=con;
item.CanAllowPortalSelfReg=false;
lstConToUpdate.add(item);

}

if(lstConToUpdate.size()>0)
{
update lstConToUpdate;
}
}

}