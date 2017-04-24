public  class RenewalAssetsHelper
{
    public static String LicenseIdJSON { get; set; }
    public static void CheckUnCheckAssets(List<Asset> lstAssets, boolean selectFlag)
    {
        List<Asset> finalUpdateAsset = new List<Asset>();
        if(lstAssets!=null && lstAssets.size()>0)
        {
            for(Asset asset:lstAssets)
            {
                asset.Is_Selected_For_Renewal__c= selectFlag;
                finalUpdateAsset.add(asset);
            }
            update finalUpdateAsset;
        }
    }
    
    
    public static boolean RenewEdgeConnectLicense(List<Asset> lstAsset)
    {
        
        List<License__c> lstLicenses= new List<License__c>();
        List<Asset> lstAssets= new List<Asset>();
        if(lstAsset!=null && lstAsset.size()>0)
        {
            for(Asset asset: lstAsset)
            {
                string prodName= asset.Product2.Name;
                if((prodName.startsWith('EC-BASE')||prodName.startsWith('EC-PLUS'))&& asset.Licenses_Nodes__c == asset.Renewal_Nodes__c )
                {
                    asset.Licenses_Nodes__c= asset.Renewal_Nodes__c;
                }
                if(prodName.startsWith('EC-BOOST')&& asset.Bandwidth_Nodes__c == asset.Renewal_Nodes__c)
                {
                    asset.Bandwidth_Nodes__c= asset.Renewal_Nodes__c;
                }
                lstAssets.add(asset);
                if(prodName!='EC-ORCH')
                {
                    List<License__c> lstLicense=  [Select Id,Name,License_Expiration__c, AssetId__c from License__c where AssetId__c =: asset.Id];
                    if(lstLicense!=null && lstLicense.size()>0)
                    {
                        for(License__c item: lstLicense)
                        {
                            if(item!=null)
                            {      
                                
                                item.License_Expiration__c= asset.Renewal_Date__c;
                                lstLicenses.add(item);                
                            }
                        }
                    }
                }
            }
            try
            {
                if(lstlicenses.size()>0)
                {
                    update lstLicenses;
                }
                if(lstAssets.size()>0)
                {
                    update lstAssets;
                }
            }
            catch(Exception ex)
            {
                
                ApexPages.addMessages(ex);
                SilverPeakutils.logException(ex);
                return false;
            }
            
        }
        
        return true;
    }
    
    public static boolean RenewEdgeConnectNodes(List<Asset> lstAsset)
    {
        
        List<License__c> lstLicenses= new List<License__c>();
        List<Asset> lstAssets= new List<Asset>();
        if(lstAsset!=null && lstAsset.size()>0)
        {
            for(Asset asset: lstAsset)
            {
                string prodName= asset.Product2.Name;
                if((prodName.startsWith('EC-BASE')||prodName.startsWith('EC-PLUS')))
                {
                    asset.EC_Old_Node_Count__c=asset.Licenses_Nodes__c;
                    asset.Licenses_Nodes__c= asset.Renewal_Nodes__c;
                }
                if(prodName.startsWith('EC-BOOST'))
                {
                    asset.EC_Old_Node_Count__c=asset.Bandwidth_Nodes__c;
                    asset.Bandwidth_Nodes__c= asset.Renewal_Nodes__c;
                }
                lstAssets.add(asset);
            }
            try
            {
                if(lstAssets.size()>0)
                {
                    update lstAssets;
                }
            }
            catch(Exception ex)
            {
                
                ApexPages.addMessages(ex);
                SilverPeakutils.logException(ex);
                return false;
            }
            
        }
        
        return true;
    }
    
    public static boolean ClearRenewalDate(List<Asset> lstAsset)
    {
        if(lstAsset!=null && lstAsset.size()>0)
        {
            for(Asset asset: lstAsset)
            {
                
                string prodName= asset.Product2.Name;
                if((prodName.startsWith('EC-BASE')||prodName.startsWith('EC-PLUS'))&& asset.Licenses_Nodes__c == asset.Renewal_Nodes__c )
                {
                    asset.Renewal_Nodes__c=0;
                    asset.Renewal_Date__c=null;
                    asset.Renewal_Start_Date__c=null;
                    
                }
                if(prodName.startsWith('EC-BOOST')&& asset.Bandwidth_Nodes__c == asset.Renewal_Nodes__c)
                {
                    asset.Renewal_Nodes__c=0;
                    asset.Renewal_Date__c=null;
                    asset.Renewal_Start_Date__c=null;
                }
                if(prodName.startsWith('EC-SAAS') ||(prodName.startsWith('EC-ORCH')))
                {
                    asset.Renewal_Start_Date__c=null;
                    asset.Renewal_Date__c=null;
                    asset.Renewal_Nodes__c=0;
                }
                if(!prodName.startsWith('EC-'))
                { 
                    asset.Renewal_Start_Date__c=null;
                    asset.Renewal_Date__c=null;
                }	              
                
            }
            try
            {
                if(lstAsset.size()>0)
                {
                    update lstAsset;
                }
            }
            catch(Exception ex)
            {
                ApexPages.addMessages(ex);
                SilverPeakutils.logException(ex);
                return false;
            }
            
        }
        
        return true;
    }
    
    public static boolean CreateNewLicenses(List<Asset> lstAssets)
    {
        
        License__c License =null;
        List<License__c> concretLicenses = new List<License__c>();
        Savepoint sp = Database.setSavePoint();
        try
        { 
            if(lstAssets!=null && lstAssets.size()>0)
            {
                for(Asset asset: lstAssets)
                {
                    License= new License__c();
                    License.AssetId__c= asset.Id;
                    License.Contact_for_Notification__c = asset.ContactId;
                    if(asset.Product2.Product_Category__c == 'GMS' && (asset.Product2.Model__c == 'GX-V' || asset.Product2.Model__c == 'EC-ORCH'))
                    {
                        License.Quantity__c = Integer.valueOf(asset.GMS_Nodes__c);
                    }
                    else
                    {
                        License.Quantity__c = 1;
                    }
                    License.Start_Date__c = Date.today();
                    //License.RenewalKeyGenerated__c = true;
                    Integer numberOfLicenses = (asset.Product2.NumberOfLicenses__c == null) ? 1 : asset.Product2.NumberOfLicenses__c.intValue();
                    List<License__c> existingLicenses = [select Id, Model__c, SerialNumber__c from License__c where AssetId__c=:asset.Id order by CreatedDate desc limit :numberOfLicenses];
                    for(License__c existingLicense : existingLicenses)
                    {
                        License__c newLicense = License.clone(false, false, false, false);
                        newLicense.Model__c = existingLicense.Model__c;
                        newLicense.License_Expiration__c= asset.Renewal_Date__c;
                        newLicense.SerialNumber__c = existingLicense.SerialNumber__c;
                        concretLicenses.add(newLicense);
                    }
                }
            }
            
            if(concretLicenses!=null && concretLicenses.size()>0)
            {
                
                insert concretLicenses;
                List<Id> licenseIds = new List<Id>();
                for(License__c item : concretLicenses)
                {
                    licenseIds.add(item.Id);
                }
                VirtualAssetManager.encryptLicenses(licenseIds);
                LicenseIdJSON = JSON.serialize(licenseIds);
            }
        }
        catch(Exception ex)
        {
            ApexPages.addMessages(ex);
            Database.rollback(sp);
            SilverPeakutils.logException(ex);
            return false;
        }
        
        
        return true;
    }
    
    public static List<License__c> CreateNewLicensesForBatch(List<Asset> lstAssets)
    {
        
        License__c License =null;
        List<License__c> concretLicenses = new List<License__c>();
        Savepoint sp = Database.setSavePoint();
        try
        { 
            if(lstAssets!=null && lstAssets.size()>0)
            {
                for(Asset asset: lstAssets)
                {
                    System.debug('Licenses'+ asset.Renewal_Date__c);
                    License= new License__c();
                    License.AssetId__c= asset.Id;
                    License.Contact_for_Notification__c = asset.ContactId;
                    if(asset.Product2.Product_Category__c == 'GMS' && (asset.Product2.Model__c == 'GX-V' || asset.Product2.Model__c == 'EC-ORCH'))
                    {
                        License.Quantity__c = Integer.valueOf(asset.GMS_Nodes__c);
                    }
                    else
                    {
                        License.Quantity__c = 1;
                    }
                    License.Start_Date__c = Date.today();
                    //License.RenewalKeyGenerated__c = true;
                    Integer numberOfLicenses = (asset.Product2.NumberOfLicenses__c == null) ? 1 : asset.Product2.NumberOfLicenses__c.intValue();
                    List<License__c> existingLicenses = [select Id, Model__c, SerialNumber__c from License__c where AssetId__c=:asset.Id order by CreatedDate desc limit :numberOfLicenses];
                    for(License__c existingLicense : existingLicenses)
                    {
                        License__c newLicense = License.clone(false, false, false, false);
                        newLicense.Model__c = existingLicense.Model__c;
                        newLicense.License_Expiration__c= asset.Renewal_Date__c;
                        newLicense.SerialNumber__c = existingLicense.SerialNumber__c;
                        concretLicenses.add(newLicense);
                    }
                }
            }
            if(concretLicenses!=null && concretLicenses.size()>0)
            {
                insert concretLicenses;
            }
        }
        
        catch(Exception ex)
        {
            ApexPages.addMessages(ex);
            Database.rollback(sp);
            SilverPeakutils.logException(ex);
            return null;
        }
        
        
        return concretLicenses;
    }
    public static boolean GenerateLicensesForBatch(List<Id> lstLicenses)
    {
        
        try
        { 
            VirtualAssetManager.encryptLicenses_Batch(lstLicenses);
            LicenseIdJSON = JSON.serialize(lstLicenses);
        }
        catch(Exception ex)
        {
            ApexPages.addMessages(ex);
            SilverPeakutils.logException(ex);
            return false;
        }
        
        
        return true;
    }
    public static void SendEmailsForPOCRequest(Request__c pocRequest)
    {
        string pocRenewalEmailType= '';
        if(pocRequest!=null && pocRequest.POC_Type__c=='EdgeConnect')
        {
            pocRenewalEmailType='EdgeConnect Virtual Renewal Email POC';
        }
        else 
        {
            pocRenewalEmailType='WANOP Virtual Renewal Email_POC';
        }
        
        if(pocRenewalEmailType!=null)
        {
            List<EmailTemplate> template = [select Id from EmailTemplate where Name=:pocRenewalEmailType limit 1];
            if(template.size() > 0)
            {
                List<String> ccs = getAccountTeam(pocRequest.Opportunity__r.AccountId);
                ccs.add('notifications@silver-peak.com');
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                email.setTemplateId(template[0].Id);
                email.setTargetObjectId(pocRequest.POC_Contact__c);
                email.setCcAddresses(ccs);
                email.setWhatId(pocRequest.Id);
                email.setsaveAsActivity(false);
                Id orgWideEmail = SilverPeakUtils.getOrganizationWideEmailId('notifications@silver-peak.com');
                if(orgWideEmail != null)
                {
                    email.setOrgWideEmailAddressId(orgWideEmail);
                }
                Messaging.sendEmail(new List<Messaging.Email> {email}, true);  
            }
        }
    }
    public static void SendEmailsForServiceProviderPO(Purchase_Order__c purchaseOrder,Id customerContact)
    {
        List<EmailTemplate> template = [select Id from EmailTemplate where Name='SP Virtual Renewal Email PO' limit 1];
        if(template.size() > 0)
        {
            List<String> ccs = getAccountTeam(purchaseOrder.Opportunity__r.AccountId);
            if(customerContact!=null)
            {
                Contact contactPerson = [Select email from Contact where Id=:customerContact];
                ccs.add(contactPerson.Email);
            }
            ccs.add('notifications@silver-peak.com');
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setTemplateId(template[0].Id);
            email.setTargetObjectId(purchaseOrder.Email_Contact__c);
            email.setCcAddresses(ccs);
            email.setWhatId(purchaseOrder.Id);
            email.setsaveAsActivity(false);
            Id orgWideEmail = SilverPeakUtils.getOrganizationWideEmailId('notifications@silver-peak.com');
            if(orgWideEmail != null)
            {
                email.setOrgWideEmailAddressId(orgWideEmail);
            }
            Messaging.sendEmail(new List<Messaging.Email> {email}, true);  
        }
    }
    public static void SendEmailsForPurchaseOrder(boolean IsEdgeConnect,Purchase_Order__c purchaseOrder, Id customerContact )
    {
        string pocRenewalEmailType= '';
        if(IsEdgeConnect)
        {
            pocRenewalEmailType='EdgeConnect Virtual Renewal Email PO';
        }
        else 
        {
            pocRenewalEmailType='WANOP Virtual Renewal Email PO';
        }
        if(pocRenewalEmailType!=null)
        {
            List<EmailTemplate> template = [select Id from EmailTemplate where Name=:pocRenewalEmailType limit 1];
            if(template.size() > 0)
            {
                List<String> ccs = getAccountTeam(purchaseOrder.Opportunity__r.AccountId);
                if(customerContact!=null)
                {
                    Contact contactPerson = [Select email from Contact where Id=:customerContact];
                    ccs.add(contactPerson.Email);
                }
                ccs.add('notifications@silver-peak.com');
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                email.setTemplateId(template[0].Id);
                email.setTargetObjectId(purchaseOrder.Email_Contact__c);
                email.setCcAddresses(ccs);
                email.setWhatId(purchaseOrder.Id);
                email.setsaveAsActivity(false);
                Id orgWideEmail = SilverPeakUtils.getOrganizationWideEmailId('notifications@silver-peak.com');
                if(orgWideEmail != null)
                {
                    email.setOrgWideEmailAddressId(orgWideEmail);
                }
                Messaging.sendEmail(new List<Messaging.Email> {email}, true);  
            }
        }
    }    
    
    public static void SendEmailsForPurchaseOrder_Reduction(Purchase_Order__c purchaseOrder)
    {
        string pocRenewalEmailType= 'EC Virtual Renewal Email PO Reduction';
        if(pocRenewalEmailType!=null)
        {
            List<EmailTemplate> template = [select Id from EmailTemplate where Name=:pocRenewalEmailType limit 1];
            if(template.size() > 0)
            {
                List<String> ccs = getAccountTeam(purchaseOrder.Opportunity__r.AccountId);
                ccs.add('notifications@silver-peak.com');
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                email.setTemplateId(template[0].Id);
                email.setTargetObjectId(purchaseOrder.Email_Contact__c);
                email.setCcAddresses(ccs);
                email.setWhatId(purchaseOrder.Id);
                email.setsaveAsActivity(false);
                Id orgWideEmail = SilverPeakUtils.getOrganizationWideEmailId('notifications@silver-peak.com');
                if(orgWideEmail != null)
                {
                    email.setOrgWideEmailAddressId(orgWideEmail);
                }
                Messaging.sendEmail(new List<Messaging.Email> {email}, true);  
            }
        }
    }    
    
    
    private static List<String> getAccountTeam(Id accId)
    {
        List<AccountTeamMember> members = [select Id, User.EMail from AccountTeamMember where AccountId=:accId and User.isActive=true];
        List<String> emails = new List<String>();
        for(AccountTeamMember atm : members)
        {
            emails.add(atm.User.Email);
        }
        return emails;
    }
}