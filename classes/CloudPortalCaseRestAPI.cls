@RestResource(urlMapping='/CPCaseInfo/*')
global with sharing class CloudPortalCaseRestAPI {
    
    @HttpPost
    global static ID CreateNewCase(CaseData caseInfo)
    {
        RestRequest req = RestContext.request;
        RestResponse res=RestContext.response;
        Asset existAsset=null;
        Contact existContact=null;
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
                if(caseInfo.emailAddress!=null)
                {
                    existContact=findContactByEmail(caseInfo.emailAddress);
                }
                if(existContact==null)
                {
                    
                }
              
                insertCase.AssetId=existAsset==null?null:existAsset.Id;
                insertCase.AccountId=existAsset==null?null:existAsset.AccountId;
                insertCase.Subject=caseInfo.subject;
                insertCase.Description=caseInfo.description;
                insertCase.Priority=caseInfo.priority;
                insertCase.Origin='Orchestrator';
                insertCase.RecordTypeId='012500000005AuiAAE';// Tech Support Queue
                //insertCase.ContactEmail=caseInfo.emailAddress;
                insert insertCase;
            }
        }
        catch(Exception ex)
        {
            res.responseBody = Blob.valueOf(String.valueOf(ex) + '\n\n' + ex.getStackTraceString());
            res.statusCode=400;
            System.debug(ex.getMessage());
            
        }
        return insertCase.Id;
    }
  


@HttpGet
global static List<Case> GetCaseInfo()
{
    string caseNumber=RestContext.request.params.get('caseNumber');
    System.debug('caseNumber '+caseNumber);
    List<Case> lstCases=[Select Id, CaseNumber,Priority,Status from Case where CaseNumber=:caseNumber];
    return lstCases;
}
private static Asset findAssetByNumber(String assetNumber)
{
    assetNumber = assetNumber.replaceAll('\\-', '').replaceAll('\\.', '');
    Asset[] assets = [select Id, AccountId from Asset where Name=:assetNumber limit 1];
    if(assets.size() > 0)
    {
        return assets[0];
    }
    else
    {
        return null;
    }
}
private static Contact findContactByEmail(String email)
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
    global string conLastName{get;set;}
    global string conFirstName{get;set;}
    global string cpAccountKey{get;set;}
    global string serialNumber{get;set;}
    
}
}