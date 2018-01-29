@RestResource(urlMapping='/CPCaseInfo/*')
global with sharing class CloudPortalCaseRestAPI {
    
    @HttpPost
    global static ID CreateNewCase(CaseData caseInfo)
    {
        RestRequest req = RestContext.request;
        RestResponse res=RestContext.response;
        Asset existAsset=null;
        Contact existContact=null;
        Id acctId=null;
        Case insertCase= new Case();
        try
        {
            if(caseInfo!=null)
            {
                // Find Asset info
                if(caseInfo.serialNumber!=null)
                {
                    existAsset=findAssetByNumber(caseInfo.serialNumber,caseInfo.cpLicenseKey);
                }
                if(caseInfo.emailAddress!=null)
                {
                    existContact=findContactByEmail(caseInfo.emailAddress);
                }
                if(existContact==null)
                {
                    
                    // Create Contact 
                    // Find Account by either Asset Id, Account key and license key
                    if(existAsset!=null)
                    {
                        acctId=existAsset.AccountId;
                    }
                    else
                    {
                        acctId=FindAccountByKey(caseInfo.cpAccountKey, caseInfo.cpLicenseKey);
                    }
                    //Create Contact 
                    //
                    if(acctId!=null)
                    {
                        existContact= CreateContactByMail(caseInfo.emailAddress,caseInfo.conFullName,caseInfo.conPhoneNumber,acctId);
                    }
                    
                    
                }
                
                caseInfo.description=string.format('{0} \n SerialNumber: {1}', new String[]{caseInfo.description,caseInfo.serialNumber});
                if(existContact== null)
                {
                     caseInfo.description=string.format('{0} \n EmailAddress: {1}', new String[]{caseInfo.description,caseInfo.emailAddress});
                }
                insertCase.AssetId=existAsset==null?null:existAsset.Id;
                insertCase.AccountId=acctId;
                insertCase.Subject=caseInfo.subject;
                insertCase.Description=caseInfo.description;
                insertCase.Priority=caseInfo.priority;
                insertCase.Origin='Orchestrator';
                insertCase.RecordTypeId='012500000005AuiAAE';// Tech Support Queue
                insertCase.ContactId=existContact!=null?existContact.Id:null;
                insert insertCase;
            }
        }
        catch(Exception ex)
        {
            insert new ErrorLog__c(Subject__c='Error in CPCaseInfo API', Message__c=ex.getMessage() + '\r\n' + ex.getStackTraceString());
            res.responseBody = Blob.valueOf(String.valueOf(ex) + '\n\n' + ex.getStackTraceString());
            res.statusCode=400;
            System.debug(ex.getMessage());
            System.debug(ex.getStackTraceString());
            
        }
        return insertCase.Id;
    }
    
    
    /*
@HttpGet
global static List<Case> GetCaseInfo()
{
string caseNumber=RestContext.request.params.get('caseNumber');
System.debug('caseNumber '+caseNumber);
List<Case> lstCases=[Select Id, CaseNumber,Priority,Status from Case where CaseNumber=:caseNumber];
return lstCases;
}*/
    
    private static Contact CreateContactByMail(String emailAddress, String senderName, string phoneNumber,Id accId)
    {
        String firstName = '';
        String lastName = '';
        senderName = (senderName != null) ? senderName.trim() : '';
        if(senderName != '')
        {
            Integer spaceIdx = senderName.lastIndexOf(' ');
            if(spaceIdx >= 0)
            {
                firstName = senderName.substring(0, spaceIdx);
                lastName = senderName.substring(spaceIdx + 1);
            }
            else
            {    
                lastName = senderName;
            }
        }
        
        if(lastName == '' || lastName == null)
        {
            lastName = 'Unknown';
        }
        Contact contact = new Contact(AccountId=accId, LastName = lastName, FirstName = firstName, Email = emailAddress,Phone=phoneNumber, leadSource = 'Customer Service');
        insert contact;
        return contact;
    }
    private static Asset FindAssetByNumber(String assetNumber,string licenseKey)
    {
        List<Asset> assets= new List<Asset>();
        System.debug(assetNumber);
        System.debug(licenseKey);
        if(assetNumber!=null && assetNumber!='')
        {
            assetNumber = assetNumber.replaceAll('\\-', '').replaceAll('\\.', '');
            assets = [select Id, AccountId from Asset where Name=:assetNumber];
            System.debug('assets serial'+ assets);
        }
        if(licenseKey!=null && licenseKey!='' && assets.size()==0)
        {
            assets = [select Id, AccountId from Asset  where License_Key__c=:licenseKey.trim()];
            System.debug('assets license'+ assets);
        }
        
        if( assets.size() > 0)
        {
            
            return assets[0];
        }
        else
        {
            return null;
        }
    }
    private static Contact FindContactByEmail(String email)
    {
        if(String.isNotBlank(email) && email.length() >= 2)
        {
            List<List<Contact>> result = [find :email In EMAIL FIELDS RETURNING Contact(Id, Name) limit 1];
            //Contact[] contacts = [select Id, Name from contact where Email=:email or Second_Email__c=:email or Third_Email__c=:email limit 1];
            if(result[0].size() > 0)
            {
                return result[0][0];
            }
        }
        return null;
    }
    
    private static Id FindAccountByKey(string acctKey, string licenseKey)
    {
        List<Account> lstAcc = new List<Account>();
        if(acctKey!=null)
        {
            lstAcc=[Select Id from Account where Cloud_Portal_Account_Key__c=:acctKey.trim()];
        }
        if(licenseKey!=null && lstAcc.size()==0)
        {
            lstAcc=[Select Id from Account where Id in (Select AccountId from Asset where License_Key__c=:licenseKey.trim())];
        }
        if(lstAcc.size()>0)
        {
            return lstAcc[0].Id;
        }
        return null;
        
        
    }
    global class CaseData
    {
        global string subject{get;set;}
        global string description{get;set;}
        global string priority{get;set;}
        global string emailAddress{get;set;}
        global string conFullName{get;set;}
        global string conPhoneNumber{get;set;}
        global string cpAccountKey{get;set;}
        global string cpLicenseKey{get;set;}
        global string serialNumber{get;set;}
        
    }
}