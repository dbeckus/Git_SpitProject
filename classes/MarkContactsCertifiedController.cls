/*
 * The controller of the page MarkContactsCertified.
 */

public class MarkContactsCertifiedController
{
    private String contactId;
    private String eventId;
    private Map<Id, Contact> originalContacts; // key: contact id => value: contact (before user updates the value)
    
    public MarkContactsCertifiedController()
    {
        contactId = ApexPages.currentPage().getParameters().get('cid');
        eventId = ApexPages.currentPage().getParameters().get('eid');
    }
    
    public List<Contact> Contacts
    {
        get
        {
            if(originalContacts == null)
            {
                Date certificationDate = Date.today();
                originalContacts = new Map<Id, Contact>();
                Contacts = new List<Contact>();
                if(contactId != null)
                {
                        for(Contact contact : [select Id, Name, SCTP_Certified__c, SPIE_Certified__c, SPX_Certified__c, SCTP_Score__c, SPIE_Score__c, SPX_Score__c, SCTP_Certification_Date__c, SPIE_Certification_Date__c, SPX_Certification_Date__c from Contact where Id = :contactId])
                        {
                            originalContacts.put(contact.Id, contact.clone());
                            if(contact.SCTP_Certification_Date__c == null) { contact.SCTP_Certification_Date__c = certificationDate; }
                            if(contact.SPIE_Certification_Date__c == null) { contact.SPIE_Certification_Date__c = certificationDate; }
                            if(contact.SPX_Certification_Date__c == null) { contact.SPX_Certification_Date__c = certificationDate; }
                            Contacts.add(contact);
                        }
                }
                else if(eventId != null)
                {
                    for(Training_Registration__c reg : [select Attendee__c, Attendee__r.Name, Attendee__r.SCTP_Certified__c, Attendee__r.SPIE_Certified__c, Attendee__r.SPX_Certified__c, Attendee__r.SCTP_Score__c, Attendee__r.SPIE_Score__c, Attendee__r.SPX_Score__c, Attendee__r.SCTP_Certification_Date__c, Attendee__r.SPIE_Certification_Date__c, Attendee__r.SPX_Certification_Date__c from Training_Registration__c where Event__c = :eventId order by Attendee__r.Name])
                    {
                        if(reg.Attendee__c != null)
                        {
                            originalContacts.put(reg.Attendee__c, reg.Attendee__r.clone());
                            if(reg.Attendee__r.SCTP_Certification_Date__c == null) { reg.Attendee__r.SCTP_Certification_Date__c = certificationDate; }
                            if(reg.Attendee__r.SPIE_Certification_Date__c  == null) { reg.Attendee__r.SPIE_Certification_Date__c = certificationDate; }
                            if(reg.Attendee__r.SPX_Certification_Date__c  == null) { reg.Attendee__r.SPX_Certification_Date__c = certificationDate; }
                            Contacts.add(reg.Attendee__r);
                        }
                    }
                }
            }
            return Contacts;
        }
        set;
    }
    
    public PageReference save()
    {
        Boolean updateSequence = false; //Only when the checkbox is selected sequence will be updated.
        for(Contact contact : Contacts)
        {
            if((contact.SCTP_Certified__c && !originalContacts.get(contact.Id).SCTP_Certified__c) 
                || (contact.SPIE_Certified__c && !originalContacts.get(contact.Id).SPIE_Certified__c)
                || (contact.SPX_Certified__c && !originalContacts.get(contact.Id).SPX_Certified__c))
            {
                updateSequence = true;
                break;
            }
        }
        Set<String> contactsToUpdateIDs = new Set<String>();
        List<Contact> contactsToUpdate = new List<Contact>();
        Savepoint sp = Database.setSavepoint();
        if(updateSequence)
        {
            List<Sequence__c> sequences =  [select Name, Number__c from Sequence__c where Name in ('SCTP', 'SPIE', 'SPX') for update]; //lock the sequence.
            Map<String, Sequence__c> sequenceMap = new Map<String, Sequence__c>();
            for(Sequence__c sequence : sequences)
            {
                sequenceMap.put(sequence.Name, sequence);
            }
            Decimal maxSCTPNo = sequenceMap.get('SCTP').Number__c;
            Decimal maxSPIENo = sequenceMap.get('SPIE').Number__c;
            Decimal maxSPXNo = sequenceMap.get('SPX').Number__c;
            for(Contact contact : Contacts)
            {
                if(contact.SCTP_Certified__c && !originalContacts.get(contact.Id).SCTP_Certified__c)
                {
                    contact.SCTP_Cert__c = String.valueOf(maxSCTPNo);
                    contactsToUpdate.add(contact);
                    contactsToUpdateIDs.add(contact.Id);
                    maxSCTPNo++;
                }
                if(contact.SPIE_Certified__c && !originalContacts.get(contact.Id).SPIE_Certified__c)
                {
                    contact.SPIE_Cert__c = String.valueOf(maxSPIENo);
                    if(!contactsToUpdateIDs.contains(contact.Id))
                    {
                        contactsToUpdate.add(contact);
                        contactsToUpdateIDs.add(contact.Id);
                    }
                    maxSPIENo++;
                }
                if(contact.SPX_Certified__c && !originalContacts.get(contact.Id).SPX_Certified__c)
                {
                    contact.SPX_Cert__c = String.valueOf(maxSPXNo);
                    if(!contactsToUpdateIDs.contains(contact.Id))
                    {
                        contactsToUpdate.add(contact);
                        contactsToUpdateIDs.add(contact.Id);
                    }
                    maxSPXNo++;
                }
            }
            try
            {
                sequenceMap.get('SCTP').Number__c = maxSCTPNo;
                sequenceMap.get('SPIE').Number__c = maxSPIENo;
                sequenceMap.get('SPX').Number__c = maxSPXNo;
                update sequences;
            }
            catch(Exception ex)
            {
                ApexPages.addMessages(ex);
                Database.rollback(sp);
                return null;
            }
        }
        else
        {
            for(Contact contact : Contacts)
            {
                if(contact.SCTP_Certified__c && originalContacts.get(contact.Id).SCTP_Certified__c && !contactsToUpdateIDs.contains(contact.Id))
                {
                    contactsToUpdate.add(contact);
                    contactsToUpdateIDs.add(contact.Id);
                }
                if(contact.SPIE_Certified__c && originalContacts.get(contact.Id).SPIE_Certified__c && !contactsToUpdateIDs.contains(contact.Id))
                {
                    contactsToUpdate.add(contact);
                    contactsToUpdateIDs.add(contact.Id);
                }
                if(contact.SPX_Certified__c && originalContacts.get(contact.Id).SPX_Certified__c && !contactsToUpdateIDs.contains(contact.Id))
                {
                    contactsToUpdate.add(contact);
                    contactsToUpdateIDs.add(contact.Id);
                }
            }
        }
        for(Contact contact : contactsToUpdate) // clear the certification information if it's not certified.
        {
            if(!contact.SCTP_Certified__c) { contact.SCTP_Score__c = null; contact.SCTP_Certification_Date__c = null; }
            if(!contact.SPIE_Certified__c) { contact.SPIE_Score__c = null; contact.SPIE_Certification_Date__c = null; }
            if(!contact.SPX_Certified__c) { contact.SPX_Score__c = null; contact.SPX_Certification_Date__c = null; }
        }
        try
        {
            if(contactsToUpdate.size() > 0)
            {
                update contactsToUpdate;
            }
            String msg = 'Succeeded.  <script type="text/javascript">top.opener.location="/';
            msg += (contactId == null) ? eventId : contactId;
            msg += '";setTimeout("top.close()", "3000");</script>';
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, msg));
        }
        catch(Exception ex)
        {
            ApexPages.addMessages(ex);
            Database.rollback(sp);
        }
        return null;
    }
    
    @isTest
    static void testMarkContactsCertifiedController()
    {
        Account testAccount = new Account(Name = 'acme');
        insert testAccount;
        Contact testContact1 = new Contact(AccountId = testAccount.Id, LastName = 'acme');
        Contact testContact2 = testContact1.clone();
        Contact[] testContacts = new Contact[] { testContact1, testContact2 };
        insert testContacts;
        Sequence__c[] testSequences = new Sequence__c[] { new Sequence__c(Name = 'SCTP', Number__c = 00001),  new Sequence__c(Name = 'SPIE', Number__c = 00001),  new Sequence__c(Name = 'SPX', Number__c = 00001) };
        insert testSequences;
        
        //Test visiting from contact page.
        PageReference pageRef = new PageReference('/apex/MarkContactsCertified?cid=' + testContact1.Id);
        Test.setCurrentPage(pageRef);
        MarkContactsCertifiedController controller = new MarkContactsCertifiedController();
        for(Contact c : controller.Contacts)
        {
            c.SCTP_Certified__c = true;
            c.SPIE_Certified__c = true;
            c.SPX_Certified__c = true;
        }
        controller.save();
        
        //Test visiting from event page.
        RecordType recordType = [select Id from RecordType where SObjectType = 'Training_Events__c' limit 1];
        Training_Events__c testEvent = new Training_Events__c(Name = 'acme', RecordTypeId = recordType.Id);
        insert testEvent;
        Training_Registration__c testReg = new Training_Registration__c(Attendee__c = testContact2.Id, Event__c = testEvent.Id);
        insert testReg;
        
        pageRef = new PageReference('/apex/MarkContactsCertified?eid=' + testEvent.Id);
        Test.setCurrentPage(pageRef);
        controller = new MarkContactsCertifiedController();
        system.assertEquals(1, controller.Contacts.size());
        controller.save();
    }
}