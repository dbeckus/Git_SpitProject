@IsTest
public class TestOpportunityTriggerHandler {
    
    @isTest
    static void testRemoveOrphanedPOC()
    {
        Account account = new Account(Name='acme');
        insert account;
        Opportunity opp = new Opportunity(Name='acme', Registered_Partner__c=account.Id, AccountId=account.Id, StageName='Discovery', CloseDate=System.today(),Product_Type__c='Both');
        insert opp;
        Request__c request = new Request__c(Opportunity__c=opp.Id);
        insert request;
        
        delete opp;
    }
    @isTest 
    static void activePOCsTrue(){
        Opportunity opp = new Opportunity();
        opp.Name ='POC Age Opportunity';
        opp.StageName = 'New';
        opp.CloseDate = Date.Today()+30;
        opp.POC_Start_Date__c = Date.Today()-10;
        opp.POC_End_Date__c = Date.Today()-5;
        opp.Has_Active_POCs__c = False;
        insert opp;
        
        opp.Has_Active_POCs__c = True;
        update opp;
        Opportunity Opp1 =[Select Id, Name, POC_Start_Date__c, POC_End_date__c, POC_Age__c, POC_Duration__c, LastmodifiedDate from Opportunity where Id =:opp.Id];
        
        Date expectedDate = Date.newInstance(opp1.LastModifiedDate.year(),opp1.LastModifiedDate.month(),opp1.LastModifiedDate.day());
        system.assertEquals(expectedDate, Opp1.POC_Start_Date__c);
        system.assertEquals(expectedDate, Opp1.POC_End_Date__c);
        system.assertEquals(5, Opp1.POC_Duration__c);
        system.assertEquals(5, Opp1.POC_Age__c);
    }
    
    //Test when Active POC's is unchecked
    @isTest
    static void activePOCsFalse(){
        Opportunity opp = new Opportunity();
        opp.Name ='POC Age Opportunity1';
        opp.StageName = 'New';
        opp.CloseDate = Date.Today()+30;
        opp.POC_Start_Date__c = Date.Today();
        opp.POC_End_Date__c = Date.Today();
        opp.Has_Active_POCs__c = True;
        insert opp;
        
        opp.Has_Active_POCs__c = False;
        update opp;
        Opportunity Opp1 =[Select Id, Name, POC_Start_Date__c, POC_End_date__c, POC_Age__c, POC_Duration__c, LastmodifiedDate from Opportunity where Id =:opp.Id];
        Date expectedDate = Date.newInstance(opp1.LastModifiedDate.year(),opp1.LastModifiedDate.month(),opp1.LastModifiedDate.day());
        system.assertEquals(expectedDate, Opp1.POC_Start_Date__c);
        system.assertEquals(expectedDate, Opp1.POC_End_Date__c);
        system.assertEquals(Null, Opp1.POC_Duration__c);
        system.assertEquals(0, Opp1.POC_Age__c);
    }
    
    //Test when oppportunity is closed with active POC
    @isTest
    static void OpportunityIsClosedWithActivePOC(){
        Opportunity opp = new Opportunity();
        opp.Name ='POC Age Opportunity2';
        opp.StageName = 'New';
        opp.CloseDate = Date.Today()+30;
        opp.POC_Start_Date__c = Date.Today()-10;
        opp.POC_End_Date__c = Date.Today()-10;
        opp.Has_Active_POCs__c = True;
        opp.Type = 'New Business';
        insert opp;
        
        opp.StageName = 'Closed Lost';
        update opp;
        Opportunity Opp1 =[Select Id, Name, POC_Start_Date__c, POC_End_date__c, POC_Age__c, POC_Duration__c, LastmodifiedDate from Opportunity where Id =:opp.Id];
        Date expectedDate = Date.newInstance(opp1.LastModifiedDate.year(),opp1.LastModifiedDate.month(),opp1.LastModifiedDate.day());
        system.assertEquals(Date.Today()-10, Opp1.POC_Start_Date__c);
        system.assertEquals(Date.Today(), Opp1.POC_End_Date__c);
        system.assertEquals(Null, Opp1.POC_Duration__c);
        system.assertEquals(10, Opp1.POC_Age__c);
    }
    
    //Test when oppportunity is closed with no active POC's
    @isTest
    static void OpportunityIsClosedWithoutActivePOC(){
        Opportunity opp = new Opportunity();
        opp.Name ='POC Age Opportunity3';
        opp.StageName = 'New';
        opp.CloseDate = Date.Today()+30;
        opp.POC_Start_Date__c = Date.Today()-10;
        opp.POC_End_Date__c = Date.Today()-10;
        opp.Has_Active_POCs__c = False;
        opp.Type = 'New Business';
        insert opp;
        
        opp.StageName = 'Closed Lost';
        update opp;
        Opportunity Opp1 =[Select Id, Name, POC_Start_Date__c, POC_End_date__c, POC_Age__c, POC_Duration__c, LastmodifiedDate from Opportunity where Id =:opp.Id];
        System.debug('opp1.POC_End_date__c'+opp1.POC_End_date__c);
        
        system.assertEquals(Date.Today()-10, Opp1.POC_Start_Date__c);
        system.assertEquals(Date.Today()-10, Opp1.POC_End_Date__c);
        system.assertEquals(Null, Opp1.POC_Duration__c);
        system.assertEquals(0, Opp1.POC_Age__c);
    }
}