public class DeploymentEngineeringNotesTriggerHandler implements ITriggerHandler {
    map<DE_Note__c,Id> mapDEAcc = new map<DE_Note__c,Id>();
    map<DE_Note__c, List<String>> mapInitialDERecipient = new map<DE_Note__c, List<String>>();
    map<DE_Note__c, List<String>> mapFinalDERecipient = new map<DE_Note__c, List<String>>();
    map<DE_Note__c, List<String>> mapCaseOwnerEmails = new map<DE_Note__c, List<String>>();
    public DeploymentEngineeringNotesTriggerHandler()
    {
        
    }
    public Boolean IsDisabled()
    {
        return false;
    }
    public void BeforeInsert(List<SObject> newItems)
    {
        
    }
    public void BeforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems)
    {
        
    }
    public void BeforeDelete(Map<Id,SObject> oldItems)
    {
        
    }
    public void AfterInsert(Map<Id, SObject> newItems) 
    {   
        if(newItems!=null && newItems.size()>0)
        {
            for(Id deId : newItems.keyset())
            {
                DE_Note__c newDE = (DE_Note__c)newItems.get(deId);
                String newRecipients = newDE.Additional_Email_Recipients__c;
                if(newRecipients !=NULL)
                {
                    mapInitialDERecipient.put(newDE, newRecipients.split('[;,]',0));
                } 
                mapDEAcc.put(newDE, newDE.Account_Name__c);
            }
            
            mapFinalDERecipient = ValidateAddtlRecipients(mapInitialDERecipient);
            mapCaseOwnerEmails = getCaseOwnerEmails(mapDEAcc);
            CreateDECaseNotesforDENote(mapDEAcc);
            SendEmailNotification(mapCaseOwnerEmails, mapFinalDERecipient);
        }
        
    }
    public void AfterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) 
    {
        if(newItems!=null && newItems.size()>0)
        {
            for(Id deId : newItems.keyset())
            {
                DE_Note__c newDENoteInfo= (DE_Note__c)newItems.get(deId);
                DE_Note__c oldDENoteInfo= (DE_note__c)oldItems.get(deId); 
                String newRecipients = newDENoteInfo.Additional_Email_Recipients__c;
                if((newRecipients !=NULL))
                {
                    mapInitialDERecipient.put(newDENoteInfo, newRecipients.split('[;,]',0));
                }  
                mapDEAcc.put(newDENoteInfo, newDENoteInfo.Account_Name__c);
            }
            mapFinalDERecipient = ValidateAddtlRecipients(mapInitialDERecipient);
            mapCaseOwnerEmails = getCaseOwnerEmails(mapDEAcc);
            SendEmailNotification(mapCaseOwnerEmails, mapFinalDERecipient);
        }
        
    }
    public void AfterDelete(Map<Id, SObject> oldItems) 
    {
        
    }
    public void AfterUndelete(Map<Id, SObject> newItems) 
    {
        
    }
    
    private void CreateDECaseNotesforDENote(Map<DE_Note__c,Id> mapDEAccounts)
    {
        if(mapDEAccounts != null && mapDEAccounts.size()>0)
        { 
            List<DE_Case_Note__c> lstDeployEngCaseNotes = new List<DE_Case_Note__c>();
            Id DEAccountId;
            list<Case> lstAssocCases = [Select Id, Account.Id from Case where RecordtypeId IN ('012500000005AuO','012500000005Aui') AND ClosedDate = NULL and Account.Id IN : mapDEAccounts.values()];
            if(lstAssocCases != null && lstAssocCases.size()>0)
            {
                for(DE_Note__c de: mapDEAccounts.keySet())
                {
                    DEAccountId = mapDEAccounts.get(de);
                    if(DEAccountId != null)
                    {
                        for(Case c: lstAssocCases)
                        {
                            if(c.AccountId == DEAccountId){
                                DE_Case_Note__c decnote= new DE_Case_Note__c();
                                decnote.Case_Number__c = c.Id;
                                decnote.DE_Note__c = de.Id;
                                lstDeployEngCaseNotes.add(decnote);
                            }
                        }
                    }
                }
                if(lstDeployEngCaseNotes != null && lstDeployEngCaseNotes.size()>0)
                {
                    insert lstDeployEngCaseNotes;
                }
            }
        }
    }
    
    private map<DE_Note__c,List<String>> ValidateAddtlRecipients (map<DE_Note__c,List<String>> mapInitialDERecipients)
    {
        map<DE_Note__c,List<String>> mapFinalAddtlRecipients = new map<DE_Note__c,List<String>>();
        String emailRegex = '^[a-zA-Z0-9._|\\\\%#~`=?&/$^*!}{+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,4}$';
        if(mapInitialDERecipients != null && mapInitialDERecipients.size()>0)
        {
            for(DE_Note__c d: mapInitialDERecipients.keyset())
            {
                List<String> lstDERecipient = new List<String>();
                for(Integer i=0; i<mapInitialDERecipients.get(d).size(); i++)
                {
                    String s = mapInitialDERecipients.get(d)[i];
                    Pattern MyPattern = Pattern.compile(emailRegex);
                    Matcher MyMatcher = MyPattern.matcher(s);
                    if (MyMatcher.matches()) 
                    {
                        lstDERecipient.add(s);
                    }
                    else
                    {
                        d.addError('Invalid Email Format:' + s);  
                    }
                }
                if(lstDERecipient != null && lstDERecipient.size()>0)
                {
                    mapFinalAddtlRecipients.put(d,lstDERecipient);
                }  
            }  
        }
        
        return mapFinalAddtlRecipients;
    }
    
    private Map<DE_Note__c, List<String>> getCaseOwnerEmails (Map<DE_Note__c,Id> mapDEAccounts)
    {
        Id DEAccountId;
        List<String> lstCaseOwnerEmails = new List<String>();
        Map<DE_Note__c, List<String>> mapDECaseOwnerEmails = new Map<DE_Note__c, List<String>>();
        if(mapDEAccounts != null && mapDEAccounts.size()>0)
        { 
            List<Case> lstCasesforOwners = [Select Id, Account.Id, Owner.Id, Owner.Email from Case where RecordtypeId IN ('012500000005AuO','012500000005Aui') AND ClosedDate = NULL and Account.Id IN : mapDEAccounts.values()];
            if(lstCasesforOwners != null && lstCasesforOwners.size()>0)
            {
                for(DE_Note__c de: mapDEAccounts.keySet())
                {
                    DEAccountId = mapDEAccounts.get(de);
                    if(DEAccountId != null)
                    {
                        for(Case c: lstCasesforOwners)
                        {
                            if(c.AccountId == DEAccountId)
                            {
                                if(c.OwnerId.getSObjectType() == User.SObjectType)
                                {
                                    lstCaseOwnerEmails.add(c.Owner.Email);
                                }
                            }
                        }
                    }
                    if(lstCaseOwnerEmails != null && lstCaseOwnerEmails.size()>0)
                    {
                        mapDECaseOwnerEmails.put(de, LstCaseOwnerEmails);  
                    } 
                }  
            }
        } 
        return mapDECaseOwnerEmails;
    }
    
    private void SendEmailNotification(Map<DE_Note__c,List<String>> CaseOwnerEmails, map<DE_Note__c,List<String>> AdditionalEmailRecipients)
    {
        List<Messaging.SingleEmailMessage> lstMails = new List<Messaging.SingleEmailMessage>();
        if(CaseOwnerEmails != null && CaseOwnerEmails.size()>0)
        {
            for(De_Note__c denote: CaseOwnerEmails.keyset())
            {
                String body = 'A new Deployment Engineering Note has been created/updated for'+' '+ denote.Acc_Name__c + ' ' + ' by ' + UserInfo.getName() + '\n' + '\n';
                body += 'Deployment Engineering Notes: '+ '\n' ;
                body += denote.DE_Notes__c;
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setToAddresses(CaseOwnerEmails.get(denote));
                mail.setSubject('DE Note:' + ' ' + denote.Name + ' ' + 'Created');
                mail.setPlainTextBody(body);
                lstMails.add(mail);    
            }
        }
        if(AdditionalEmailRecipients != null && AdditionalEmailRecipients.size()>0)
        {
            for(De_Note__c denote: AdditionalEmailRecipients.keyset())
            {
                String body = 'A new Deployment Engineering Note has been created/updated for'+' '+ denote.Acc_Name__c + ' ' + ' by ' + UserInfo.getName() + '\n' + '\n';
                body += 'Deployment Engineering Notes: '+ '\n' ;
                body += denote.DE_Notes__c;
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setToAddresses(AdditionalEmailRecipients.get(denote));
                mail.setSubject('DE Note:' + ' ' + denote.Name + ' ' + 'Created');
                mail.setPlainTextBody(body);
                lstMails.add(mail);    
            }
        }
        if(lstMails != null && lstMails.size()>0)
        {
            Messaging.sendEmail(lstMails);
        }   
    }
}