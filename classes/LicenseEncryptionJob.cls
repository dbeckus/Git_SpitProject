/*
 * Enqueue a job to encrypt license of virtual asset.
 * LicenseIds should either be all GMS assets, or all non-GMS assets
 */
public class LicenseEncryptionJob implements Queueable, Database.AllowsCallouts
{    
    public List<Id> LicenseIds { get; set; }
    
    public void execute(QueueableContext context) 
    {
        if(LicenseIds != null && LicenseIds.size() > 0)
        {
            encryptLicenses();
        }
    }
    
    private void encryptLicenses()
    {
        Set<Id> gmsLicenseIds = new Set<Id>();
        for(License__c gmsLicense : [select Id from License__c where Id in :licenseIds and (AssetId__r.Product2.Model__c='GX-V' OR AssetId__r.Product2.Product_Category__c = 'GMS')])
        {
            gmsLicenseIds.add(gmsLicense.Id);
        }
        if(gmsLicenseIds.size() > 0)
        {
            encryptGmsLicenses(gmsLicenseIds);
            return;
        }
        
        Set<Id> virtualLicenseIds = new Set<Id>();
        for(License__c virtualLicense : [select Id from License__c where Id in :licenseIds and AssetId__r.Product2.Model__c!='GX-V' And AssetId__r.Product2.Product_Category__c !='GMS'])
        {
            virtualLicenseIds.add(virtualLicense.Id);
        }
        if(virtualLicenseIds.size() > 0)
        {
            encryptVirtualLicenses(virtualLicenseIds);
        }
    }
    
    private void encryptGmsLicenses(Set<Id> licenseIds)
    {
        List<License__c> licenses = [select Id, Start_Date__c, Quantity__c, RenewalKeyGenerated__c, License_Expiration__c, SerialNumber__c, AssetId__c, AssetId__r.SerialNumber, AssetId__r.GMS_Nodes__c, AssetId__r.Quantity, AssetId__r.Product2.Name, AssetId__r.Product2.Model__c, AssetId__r.Product2.LicenseAsModel__c, AssetId__r.Product2.ProductCode, AssetId__r.Product2.Product_Category__c from License__c where Id in :licenseIds];
        if(licenses.size() > 0)
        {
            try
            {
                String licenseAesEncryptedText = prepareLicenseBeforeSend(licenses);
                String serverResult = getEncryptionResultGms(licenseAesEncryptedText);
                List<String> plainLicenses = processEncryptionResult(serverResult, licenses);
                logLicenseCreation(plainLicenses);
                update licenses;
                copyLicenseKeyToAsset(licenses);
            }
            catch(Exception ex)
            {
                List<Id> ls = new List<Id>();
                ls.addAll(licenseIds);
                String errorMessage = 'Tried to encrypt licenses [' + String.join(ls, ', ') + '].\n';
                errorMessage += 'Error Message is: ' + ex.getMessage();
                SilverPeakUtils.logException('Silver Peak Exception in VirtualAssetManager', errorMessage);
            }
        }
    }
    
    private void encryptVirtualLicenses(Set<Id> licenseIds)
    {
        List<License__c> licenses = [select Id, Start_Date__c, Quantity__c, RenewalKeyGenerated__c, License_Expiration__c, SerialNumber__c, AssetId__c, AssetId__r.SerialNumber, AssetId__r.GMS_Nodes__c, AssetId__r.Quantity, AssetId__r.Product2.Name, AssetId__r.Product2.Model__c, AssetId__r.Product2.LicenseAsModel__c, AssetId__r.Product2.ProductCode, AssetId__r.Product2.Product_Category__c from License__c where Id in :licenseIds];
        String logMsg = '';
        if(licenses.size() > 0)
        {
            try
            {
                String licenseAesEncryptedText = prepareLicenseBeforeSend(licenses);
                String serverResult = getEncryptionResultVirtual(licenseAesEncryptedText);
                List<String> plainLicenses = processEncryptionResult(serverResult, licenses);
                logLicenseCreation(plainLicenses);
                update licenses;
                copyLicenseKeyToAsset(licenses);
            }
            catch(Exception ex)
            {
                List<Id> ls = new List<Id>();
                ls.addAll(licenseIds);
                String errorMessage = 'Tried to encrypt licenses [' + String.join(ls, ', ') + '].\n';
                errorMessage += 'Error Message is: ' + ex.getMessage();
                SilverPeakUtils.logException('Silver Peak Exception in VirtualAssetManager', errorMessage);
            }
        }
    }
    
    public String prepareLicenseBeforeSend(List<License__c> licenses)
    {
        List<String> licenseToBeEncoded = new List<String>();
        for(License__c license : licenses)
        {
            licenseToBeEncoded.add(getPlainTextLicenseKey(license));
        }
        String licensesPlainText = String.join(licenseToBeEncoded, ',');
        String licenseAesEncryptedText = aes128Encrypt(licensesPlainText);
        return licenseAesEncryptedText;
    }
    
    private List<String> processEncryptionResult(String serverResult, List<License__c> licenses)
    {
        if(serverResult != null && serverResult.contains('Error'))
        {
            throw new LicenseEncryptionException('Server exception. ' + serverResult);
        }
        String aesEncryptedLicenses = serverResult;
        List<String> resultLicenses = aesEncryptedLicenses.split('\n');
        if(resultLicenses.size() != licenses.size())
        {
            throw new LicenseEncryptionException('The service returned doesn\'t match requested parameter. Supposed ' + licenses.size() + ' licenses, actual ' + resultLicenses.size() + ' result.');
        }
        List<String> plainLicenses = new List<String>();
        for(Integer index = 0; index < resultLicenses.size(); index++)
        {
            String plainLicense = aes128Decrypt(resultLicenses[index]);
            licenses[index].Key__c = plainLicense;
            plainLicenses.add(plainLicense);
        }
        return plainLicenses;
    }
    
    private String getPlainTextLicenseKey(License__c license)
    {
        String result = '';
        if(license.AssetId__r.Product2.Model__c == 'GX-V' || license.AssetId__r.Product2.Product_Category__c == 'GMS')
        {
            String serialNumber = license.AssetId__r.SerialNumber;
            if(serialNumber == null || serialNumber.length() != 12)
            {
                throw new LicenseEncryptionException('Incorrect serial number [' + serialNumber + '] on license [' + license.Id + ']');
            }
            serialNumber = serialNumber.substring(0, 2) + '-' + serialNumber.substring(2, 4) + '-' + serialNumber.substring(4, 6) + '-' + serialNumber.substring(6, 8) + '-' + serialNumber.substring(8, 10) + '-' + serialNumber.substring(10, 12);
            String qty = (license.Quantity__c == null) ? '0' : String.valueOf(Math.floor(license.Quantity__c));
            String endDate = (license.License_Expiration__c == null) ? '' : String.valueOf(license.License_Expiration__c.year()).substring(2, 4) + ('0' + String.valueOf(license.License_Expiration__c.month())).right(2) + ('0' + String.valueOf(license.License_Expiration__c.day())).right(2);
            if (endDate == '291231') 
            {
                result = serialNumber + '#' + qty;
            }
            else 
            {
                result = serialNumber + '#' + qty + ((endDate == '') ? '' : '#' + endDate);
            }
        }
        else
        {
            //Generates virtual license key
            String productCode = license.AssetId__r.Product2.LicenseAsModel__c;
            productCode = (productCode == null) ? license.AssetId__r.Product2.Model__c : productCode;
            productCode = (productCode == null) ? license.AssetId__r.Product2.Name : productCode;
            productCode = productCode.replaceAll('-', '');   //*** CDC 3-14-12 found needed to clean the model of dashses in order to decode the keys
            
            String startDate = (license.Start_Date__c == null) ? '' : (license.Start_Date__c.year() + '/' + license.Start_Date__c.month() + '/' + license.Start_Date__c.day());
            String endDate = (license.License_Expiration__c == null) ? '' : (license.License_Expiration__c.year() + '/' + license.License_Expiration__c.month() + '/' + license.License_Expiration__c.day());
            String serialNumber = license.SerialNumber__c;
            String gmsNodeCount = license.AssetId__r.GMS_Nodes__c;   // future item to support
            
            if (endDate < '2000/12/31')             
            {
                result = productCode+'-'+startDate + '-0-1-' + serialNumber;
            }
            else 
            {
                result = productCode+'-'+startDate+'-'+endDate+'-1-' + serialNumber;
            }           
        }
        System.debug('plain=' + result);
        return result;
    }
    
    private String getEncryptionResultVirtual(String aes128License)
    {
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://storage.silverpeaksystems.com/Genlicense.ashx');    
        //req.setEndpoint('https://test.exfit.cn/Genlicense.ashx');    
        req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        req.setBody('v=' + EncodingUtil.urlEncode(aes128License, 'utf-8'));
        req.setMethod('POST');
        req.setTimeout(60000);  //60 seconds time out
        HttpResponse res = h.send(req);
        return res.getBody();
    }
    
    private String getEncryptionResultGms(String aes128License)
    {
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://storage.silverpeaksystems.com/GenGmslicense.ashx');
        //req.setEndpoint('https://test.exfit.cn/GenGmslicense.ashx');
        req.setHeader('Content-Type', 'text/plain');
        req.setBody(aes128License);
        req.setMethod('POST');
        req.setTimeout(60000);  //60 seconds time out
        HttpResponse res = h.send(req);
        return res.getBody();
    }
    
    private void logLicenseCreation(List<String> licenses)
    {
        if(SilverPeakUtils.IsProduction())
        {
            try
            {
                String plainBody = String.join(licenses, '\r\n');
                Blob encryptedBody = Crypto.encrypt('AES256', Blob.valueOf('735065616B30C0F1735065616B30C0F1'), Blob.valueOf('4368657917336E65'), Blob.valueOf(plainBody));
                Http h = new Http();
                HttpRequest req = new HttpRequest();
                req.setEndpoint('https://storage.silverpeaksystems.com/linux/phlicense/cgi-bin/batchaddlicense.pl');
                //req.setEndpoint('https://test.exfit.cn/linux/phlicense/cgi-bin/batchaddlicense.pl');
                req.setBody('v=' + EncodingUtil.urlEncode(EncodingUtil.base64Encode(encryptedBody), 'utf-8'));
                req.setMethod('POST');
                req.setTimeout(60000);  //60 seconds time out
                HttpResponse response = h.send(req);
            }
            catch(Exception ex)
            {
                SilverPeakUtils.logException('Silver Peak Exception in VirtualAssetManager', 'The license was generated and updated, but failed to log to silver-peak server. The error message is: ' + ex.getMessage());
            }
        }
    }
    
    private void copyLicenseKeyToAsset(List<License__c> licenses)
    {
        Map<Id, Asset> id2Assets = new Map<Id, Asset>();
        for(License__c license : licenses)
        {
            if(!id2Assets.containsKey(license.AssetId__c))
            {
                id2Assets.put(license.AssetId__c, new Asset(Id=license.AssetId__c));
            }
            if(license.RenewalKeyGenerated__c == true)
            {
                id2Assets.get(license.AssetId__c).Renewal_Key_Generated__c = true;
            }
            else
            {
                id2Assets.get(license.AssetId__c).Key_Generated__c = true;
            }
            id2Assets.get(license.AssetId__c).License_Key__c = license.Key__c;
        }
        update id2Assets.values();
    }
    
    private String aes128Encrypt(String plainText)
    {
        Blob key = Blob.valueOf('[Cheyenne*%7971]');
        Blob iv = Blob.valueOf('0123456789abcdef');
        Blob data = Blob.valueOf(plainText);
        Blob encryptedData = Crypto.encrypt('AES128', key, iv, data);
        return EncodingUtil.base64Encode(encryptedData);
    }
    
    private String aes128Decrypt(String cipherText)
    {
        Blob key = Blob.valueOf('[Cheyenne*%7971]');
        Blob iv = Blob.valueOf('0123456789abcdef');
        Blob returnkey = EncodingUtil.base64Decode(cipherText);
        Blob decryptedData = Crypto.decrypt('AES128', key, iv, returnkey);
        return decryptedData.toString();
    }
    
    public class LicenseEncryptionException extends Exception {}
}