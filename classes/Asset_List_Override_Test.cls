@isTest
private class Asset_List_Override_Test {

    /*static testMethod void Asset_List_Override_Test() {
        
        // Create an account
        Account a1 = new Account();
        a1.Name='Scrooge and Marley';
        a1.Type='Other';
        insert a1;
        
        // Create a contact
        Contact c1 = new Contact();
        c1.LastName='Marley';
        c1.FirstName='Jacob';
        c1.AccountId=a1.id;
        c1.Email='dclaar@silver-peak.com';
        insert c1;
        
        // Create a product
        Product2 p2 = new Product2();
        p2.Name='VX-5001';
        p2.Product_Category__c='Appliance';
        p2.Family='Product';
        p2.ProductCode='500045-314';
        p2.Description='VIRTUAL, 45Mbps, 64K FLOWS';
        insert p2;
        
        // Create an Asset
        List<Asset> la = new List<Asset>();
        ApexPages.StandardSetController sc = new ApexPages.StandardSetController(la);
        Assets_List_Override c = new Assets_List_Override(sc);
        Asset a = (Asset)sc.getRecord();
        a.Product2Id=p2.id;
        a.AccountId=a1.id;
        
        // See the products
        List<SelectOption> pol = c.getProducts();
        system.debug('product options list='+pol);
        system.assert(!pol.isEmpty(),'Product options list is empty!');
        
        // try save and new
        c.saveAndNew=true;
        PageReference p;
        try {
            p = c.nameRankSerial();
        } catch (Exception ex) {
            System.debug('Caught exception '+ex.getMessage());
        }
        system.debug('page reference: '+p);
        try {
            p = c.save();
        } catch (Exception ex) {
            System.debug('Caught exception '+ex.getMessage());
        }
        system.debug('page reference: '+p);
        
        // try save and not new. id is an account
        ApexPages.currentPage().getParameters().put('id',a1.id);
        c = new Assets_List_Override(sc);
        a = (Asset)sc.getRecord();
        a.Product2Id=p2.id;
        c.saveAndNew=false;
        c.license.Duration__c=0;
        try {
            p = c.nameRankSerial();
        } catch (Exception ex) {
            System.debug('Caught exception '+ex.getMessage());
        }
        system.debug('page reference: '+p);
        try {
            p = c.save();
        } catch (Exception ex) {
            System.debug('Caught exception '+ex.getMessage());
        }
        system.debug('page reference: '+p);
        
        // Try with a id=product and an account in the URL
        ApexPages.currentPage().getParameters().put('id',p2.id);
        ApexPages.currentPage().getParameters().put('page:form:pageBlock:assetInformation:account_lkid',a1.id);
        c = new Assets_List_Override(sc);
        a = (Asset)sc.getRecord();
        a.AccountId=a1.id;
        c.saveAndNew=false;
        c.license.Duration__c=0;
        try {
            p = c.nameRankSerial();
        } catch (Exception ex) {
            System.debug('Caught exception '+ex.getMessage());
        }
        system.debug('page reference: '+p);
        try {
            p = c.save();
        } catch (Exception ex) {
            System.debug('Caught exception '+ex.getMessage());
        }
        system.debug('page reference: '+p);
        
    }*/
}