/*
* Provider public method for Silver peak org.
*/
public class SilverPeakUtils
{
    public static Boolean BypassingTriggers = false;
    
    public static Boolean IsProduction()
    {
        Id productionOrgId = '00D300000000byV';
        return UserInfo.getOrganizationId() == productionOrgId;
    }
    
    public static Boolean IsPortalUser()
    {
        User user = [select UserType from User where Id = :UserInfo.getUserId()];
        Boolean portalUser = (user.UserType == 'CustomerSuccess' || user.UserType == 'PowerCustomerSuccess');
        return portalUser;
    }
	public static Boolean IsCommunityUser()
    {
        User user = [select UserType from User where Id = :UserInfo.getUserId()];
        Boolean portalUser = (user.UserType == 'Partner');
        return portalUser;
    }
    public static Boolean IsDistributorCommunityUser()
    {
        User user = [select Profile.Name from User where Id = :UserInfo.getUserId()];
        Boolean portalUser = (user.Profile.Name == '13g-SP Distributor Community');
        return portalUser;
    }
    public static Id getRecordTypeId(String name, String objName)
    {
        List<RecordType> recordType = [Select Id from RecordType where Name = :name and IsActive = true and SObjectType = :objname];
        if(recordType.size() > 0)
        {
            return recordType[0].Id;
        }
        return null;
    }
    
    public static String getSalesforceBaseUrl()
    {
        String host = URL.getSalesforceBaseURL().getHost();
        if(host.endsWith('visual.force.com'))
        {
            String[] hostParts = host.split('\\.');
            String server = hostParts[1];
            return 'https://' + server + '.salesforce.com';
        }
        else
        {
            return host;
        }
    }
    
    public static Id getOrganizationWideEmailId(String emailAddress)
    {
        List<OrgWideEmailAddress> addrs = [select Id from OrgWideEmailAddress where Address=:emailAddress limit 1];
        return (addrs.size() > 0) ? addrs[0].Id : null;
    }
    
    public static String toHex(Integer x)
    {
        String s = '';
        String hex = '0123456789ABCDEF';
        for(Integer i = 0; i <= 5; i++)
        {
            Integer m = Math.mod(x,16);
            s = hex.substring(m, m + 1) + s;
            x /= 16;
        }
        return s;
    }

    public static Asset_Mac__c getAssetMac()
    {
        List<Asset_mac__c> macs = [select Id, Name, Used__c, AssetId__c from Asset_mac__c where Used__c = false limit 1 for update];
        if(macs.size() > 0)
        {
            return macs[0];
        }
        else
        {
            return new Asset_Mac__c();
        }
    }

    public static String getPicklistDefaultValue(Schema.Describefieldresult F)
    {
        List<Schema.Picklistentry> P = F.getPicklistValues();
        for(Schema.Picklistentry pList : P)
        {
            if(pList.isDefaultValue())
            {
                return pList.getValue();
            }
        }
        return null;
    }

    public static void logDatabaseError(List<sObject> records, List<Object> results)
    {
        String message = '';
        Boolean hasError = false;
        List<sObject> failedRecords = new List<sObject>();
        for(Integer i = 0; i < results.size(); i++)
        {
            Object result = results[i];
            sObject record = (records.size() > i) ? records[i] : null;
            
            List<Database.Error> errors = new List<Database.Error>();
            if(result instanceOf Database.SaveResult)
            {
                Database.SaveResult sr = (Database.SaveResult)result;
                if(sr.isSuccess())
                {
                    continue;
                }
                errors.addAll(sr.getErrors());
                failedRecords.add(record);
            }
            else if(result instanceOf Database.DeleteResult)
            {
                Database.DeleteResult dr = (Database.DeleteResult)result;
                if(dr.isSuccess())
                {
                    continue;
                }
                errors.addAll(dr.getErrors());
                failedRecords.add(record);
            }
            else if(result instanceOf Database.UpsertResult)
            {
                Database.UpsertResult ur = (Database.UpsertResult)result;
                if(ur.isSuccess())
                {
                    continue;
                }
                errors.addAll(ur.getErrors());
                failedRecords.add(record);
            }
            else if(result instanceOf Database.UndeleteResult)
            {
                Database.UndeleteResult ur = (Database.UndeleteResult)result;
                if(ur.isSuccess())
                {
                    continue;
                }
                errors.addAll(ur.getErrors());
                failedRecords.add(record);
            }
            else
            {
                continue;
            }
            message = 'Record: ' + failedRecords + '\r\n\r\nError: \r\n';
            for(Database.Error err : errors)
            {
                hasError = true;
                message += err.getMessage() + '\r\n';
            }
            message += '\r\n';
        }
        if(hasError)
        {
            logException(message);
        }
    }
    
    public static void logException(Exception ex)
    {
        logException(ex.getMessage() + '\r\n' + ex.getStackTraceString());
    }
    
    public static void logException(String errMsg)
    {
        logException('Silver Peak Unknown Exception', errMsg);
    }
    
    public static void logException(String subject, String errMsg)
    {
        if(errMsg != null && errMsg.length() > 32767)
        {
            errMsg = errMsg.substring(0, 32767);
        }
        Messaging.SingleEmailMessage errorMail = new Messaging.SingleEmailMessage();
        errorMail.setToAddresses(new String[] { 'prane@silver-peak.com', 'devteam@snapbi.com','dbeckus@silver-peak.com','pmusunuru@silver-peak.com' });
        errorMail.setSubject(subject);
        errorMail.setPlainTextBody(errMsg);
        if(!Test.isRunningTest())
        {
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { errorMail }, false);
        }
        Database.insert(new ErrorLog__c(Subject__c=subject, Message__c=errMsg), false);
    }
}