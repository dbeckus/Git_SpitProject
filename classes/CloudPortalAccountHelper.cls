public class CloudPortalAccountHelper {
    
    
    public static string  GetTokenFromPortal()
    {
        // Added comments
        string endPtUrl;
        HttpRequest request = new HttpRequest();
        request.setMethod('POST');
        request.setHeader('charset', 'UTF-8');
        request.setHeader('Content-Type', 'application/json');
        if(SilverPeakUtils.IsProduction())
        {
            endPtUrl='https://cloudportal.silver-peak.com/portal/apis/rest/login';
        }
        else
        {
            endPtUrl='https://portaldev.silver-peak.com/portal/apis/rest/login';
        }
        request.setEndpoint(endPtUrl);
        JSONGenerator generator = JSON.createGenerator(true);
        generator.writeStartObject();
        if(SilverPeakUtils.IsProduction())
        {
            generator.writeStringField('email', 'cp-salesforce@silver-peak.com');
            generator.writeStringField('mfaCode', '');
            generator.writeStringField('password', 'Mo@V3eLiHLYHbo1U');
        }
        else
        {
            generator.writeStringField('email', 'cloudportaltest@silver-peak.com');
            generator.writeStringField('mfaCode', '');
            generator.writeStringField('password', 'Yesadmin4u');
        }
        
        generator.writeEndObject();        
        String parameters = generator.getAsString();
        request.setBody(parameters);
        
        HttpResponse response = new Http().send(request);
        
        // Process response.
        if(response.getStatusCode() >= 200 && response.getStatusCode() < 400)
        {
            string cookie=response.getHeader('set-cookie');
            System.debug(cookie);
            if(cookie!=null)
            {
                string[] cookiesArr= cookie.split(';');
                //token= cookiesArr[0].substring(cookiesArr[0].indexOf('=')+1,cookiesArr[0].length());
                return cookiesArr[0];
            }
            
        }
        else
        {
            system.debug(response.getBody());
        }
        if(Test.isRunningTest())
        {
            return 'test123';
        }
        return null;
    }
    
    public static Account CreateAccount(Id accountId,string accountName)
    {
        Account cpAccount= new Account();
        Map<String, String> inputParam= new Map<String, String>();
        string apitoken;
        inputParam.put('name',accountName);
        inputParam.put('salesforceId',accountId);
        CloudPortalCreateAccountApi obj = new CloudPortalCreateAccountApi(inputParam);
        apitoken=GetTokenFromPortal();
        obj.token=apitoken;
        obj.execute();
        if(obj.isSucceed)
        {
            CloudPortalAccount cpAcc= obj.CPAccount;
            if(cpAcc!=null)
            {
                cpAccount= new Account();
                cpAccount.Id=accountId;
                cpAccount.Cloud_Portal_Account_Id__c=cpAcc.Id;
                cpAccount.Cloud_Portal_Account_Key__c=cpAcc.accountKey;
                cpAccount.Cloud_Portal_Account_Name__c=cpAcc.Name;
                
            }
            
        }
        
        return cpAccount;
    }
    
    public static Account GetAccountBySalesforceId(Id accountId,string accountName)
    {
        Account cpAccount= null;
        // Call the web service to get the salesforceId 
        string currToken= CloudPortalAccountHelper.GetTokenFromPortal();
        CloudPortalGetAccountBySalesforceIdApi obj= new CloudPortalGetAccountBySalesforceIdApi(accountId);
        obj.token=currToken;
        obj.execute();
        CloudPortalAccountList cpAcc= obj.CPAccount;
        System.debug('cpAcc'+ cpAcc);
        if(cpAcc!=null && cpAcc.accounts!=null && cpAcc.accounts.size()>0)
        {
            cpAccount= new Account();
            cpAccount.Id=accountId;
            cpAccount.Cloud_Portal_Account_Id__c=cpAcc.accounts[0].Id;
            cpAccount.Cloud_Portal_Account_Key__c=cpAcc.accounts[0].accountKey;
            cpAccount.Cloud_Portal_Account_Name__c=cpAcc.accounts[0].Name;
            
        }
        
        return cpAccount;
    }
    
    public static List<CPAsset> ConvertAssetToCpAsset(List<Asset> lstAsset, string assetType)
    {
        List<CPAsset> lstResult= new List<CPASset>();
        List<Asset> filterAssets= new List<Asset>();
        for(Asset counter:lstAsset)
        {
            string prodName=counter.Product2.Name;
            if(assetType=='EC'&& prodName.startsWith('EC')&& !prodName.contains('EC-SAAS')&& !prodName.contains('EC-SP'))
            {filterAssets.add(counter);}
            if(assetType=='SAAS' && (prodName.contains('EC-SAAS') || prodName.contains('UNITY CLOUD INTELLIGENCE')))
            {filterAssets.add(counter);}
             if(assetType=='CPX' && prodName.contains('EC-SP'))
            {filterAssets.add(counter);}
        }
        for(Asset item:filterAssets)
        {
            CPAsset cp= new CPAsset();
            string prodName=item.Product2.Name;
            cp.SerialNumber=item.SerialNumber;
            long millis=0;
            if(item.License_End_Date__c!=null)
            {
                DateTime dt=DateTime.newInstance(item.License_End_Date__c,Time.newInstance(0, 0, 0, 0));
                millis=dt.getTime();
            }
            cp.ExpiryDate= millis;
            cp.BaseNode=0;
            cp.PlusNode=0;
            cp.BoostNode=0;
            if(prodName.contains('BASE') && item.Licenses_Nodes__c!=null)
            {
                cp.BaseNode=integer.valueOf(item.Licenses_Nodes__c);
            } 
            if(prodName.contains('PLUS')&& item.Licenses_Nodes__c!=null)
            {
                cp.PlusNode=integer.valueOf(item.Licenses_Nodes__c);
            } 
            if(item.Bandwidth_Nodes__c!=null)
            {
                cp.BoostNode=((integer.valueOf(item.Bandwidth_Nodes__c)*1000)*100);
            }
            
            lstResult.add(cp); 
        }
        
        return lstResult;
    }
    public static Account GetOrCreateAccountFromCloudPortal(Id accountId,string accountName)
    {
        Account cpAccount= GetAccountBySalesforceId(accountId, accountName);
        if(cpAccount== null)
        {
            cpAccount=CreateAccount(accountId, accountName);
        }
        
        return cpAccount;
    }
}