public class ApiConfigurationDataController {
    
    
    public static Api_Configuration__c RetreiveApiCredentials(string apiEnvName)
    {
        List<Api_Configuration__c> lstDataObj=[Select Endpoint_URL__c ,UserName__c,Password__c,Base_Endpoint__c from Api_Configuration__c where Environment_Name__c=:apiEnvName];
        if(lstDataObj!=null && lstDataObj.size()>0)
        {
            return lstDataObj[0];
        }
        else
        {
            SilverPeakUtils.logException('Could not find the credentials details in Api_Configuration__c object with this name '+ apiEnvName);
        }
        return null;
    }
}