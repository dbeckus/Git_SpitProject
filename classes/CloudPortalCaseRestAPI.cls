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
                    existAsset=findAssetByNumber(caseInfo.serialNumber);
                }
                if(caseInfo.salesforceId!=null)
                {
                    acctId=FindAccountBySalesforceId(caseInfo.salesforceId);
                }
                if(acctId==null && existAsset!=null && existAsset.AccountId!=null)
                {
                    acctId=existAsset.AccountId;
                }
                 if(acctId==null)
                 {
                     string errorMessage= string.format('Unable to create case as there is no account with salesforce ID={0} and serial number={1}', new String[]{caseInfo.salesforceId,caseInfo.serialNumber});
                     throw new CustomException(errorMessage);
                 }
                
                
                if(caseInfo.emailAddress!=null)
                {
                    existContact=findContactByEmail(caseInfo.emailAddress);
                }
                
                if(existContact==null)
                {                    
                    if(acctId!=null)
                    {
                        existContact= CreateContactByMail(caseInfo.emailAddress,caseInfo.conFullName,caseInfo.conPhoneNumber,acctId);
                    }
                }
                if(existAsset==null)
                {
                     caseInfo.description=string.format('{0} \n SerialNumber: {1}', new String[]{caseInfo.description,caseInfo.serialNumber});
                }
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
                res.statusCode=200;
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
    private static Asset FindAssetByNumber(String assetNumber)
    {
        List<Asset> assets= new List<Asset>();
        System.debug(assetNumber);
        if(assetNumber!=null && assetNumber!='')
        {
            assetNumber = assetNumber.replaceAll('\\-', '').replaceAll('\\.', '');
            assets = [select Id, AccountId from Asset where Name=:assetNumber];
            System.debug('assets serial'+ assets);
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
    
    private static Id FindAccountBySalesforceId(string salesforceId)
    {
        List<Account> lstAccount=null;
        Id accountId=null;
        if(salesforceId!=null)
        {
            lstAccount=[Select Id from Account where Id=:salesforceId];
        }
        if(lstAccount!=null && lstAccount.size()>0)
        {
            accountId=lstAccount[0].Id;
        }
        return accountId;
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
    
   
    global class CaseData
    {
        global string subject{get;set;}
        global string description{get;set;}
        global string priority{get;set;}
        global string emailAddress{get;set;}
        global string conFullName{get;set;}
        global string conPhoneNumber{get;set;}
        global string salesforceId{get;set;}
        global string serialNumber{get;set;}
        
    }
}