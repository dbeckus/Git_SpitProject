@IsTest	
public class TestDeleteRMAForApprovedPendRet {
    @IsTest	
    public static void deleteRMA()
    {
        Account acc = new Account(Name='testECPOC');
        insert acc;
        Contact contact = new Contact(FirstName = 'AcmeFirstname', LastName = 'AcmeLastname', Phone='123456789', Email = 'acme@acme.com' , accountId=acc.Id);
        insert contact;
        Opportunity opportunity = new Opportunity();
        opportunity.Name = 'acme';
        opportunity.AccountId = acc.Id;
        opportunity.Pricebook2Id = TestUtilities.getStandardPricebookId();
        opportunity.StageName = 'Discovery';
        opportunity.Dead_Reason__c = 'acme';
        opportunity.CloseDate = Date.today().addYears(1);
        opportunity.Type = 'New Business';
        opportunity.Opportunity_Source__c = 'Other';
        opportunity.POC_Type__c = 'POC';
        opportunity.Deal_Type__c = 'Replication';
        opportunity.Product_Type__c='Both';
        opportunity.Technical_Responsible__c=UserInfo.getUserId();
        insert opportunity;
        
        Request__c request = new Request__c(POC_Contact__c = contact.Id);
        request.POC_Type__c='EdgeConnect';
        request.Opportunity__c= opportunity.id;
        request.Evaluation_Product_1__c='EC-XS';
        request.Evaluation_Product_2__c='EC-XS';
        request.Quantity_Location_1__c=1;
        request.Quantity_Location_2__c=1;
        request.Status__c='Pending Return';
        insert request;
        Product2 product = new Product2();
        product.Name = 'EC-XS';
        product.ProductCode = 'EC-XS';
        product.Model__c = 'EC-XS';
        product.Family='Product';
        insert product;
        
        Asset asset= new Asset();
        asset.Name = '001BBC039649_t';
        asset.SerialNumber = '001BBC039649_t';
        asset.AccountId = acc.Id;
        asset.Product2Id = product.Id;
        asset.Status = 'Customer Owned';
        asset.Quantity = 1;
        asset.POCRequest__c=request.Id;
        insert asset;
        Test.startTest();
        NewRMAHelper.createRmaOnPOC(string.valueOf(asset.Id));
        
        
        List<RMA__c> rmaItem=[Select Id from RMA__C where Request__c=:request.Id];
        System.assert(rmaItem!=null && rmaItem.size()>0);
        Profile prof = [SELECT Id FROM Profile WHERE Name='9-Operations Manager']; 
        User usr = new User(Alias = 'standt', Email='testUser@uniquetest.com', 
                            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                            LocaleSidKey='en_US', ProfileId = prof.Id, 
                            TimeZoneSidKey='America/Los_Angeles', UserName='testUser@uniquetest.com');
        
        usr.IsActive =true;
        insert usr;
        System.runAs(usr){
            
            request.Status__c='Shipped - Extended';
            update request;
            
        }
        rmaItem=null;
    	rmaItem=[Select Id from RMA__c where Request__c=:request.Id];
        System.assert(rmaItem.size()==0);
        Test.stopTest();
    }
}