@IsTest
public class TestBuildExtension {
    
  	@IsTest
    public static void TestBuildExtension_RetreiveFiles()
    {
        Releases__c rel= new  Releases__c();
        rel.Name='TestData';
        rel.Type__c='VX Image';
        rel.Release_Date__c= Date.today();
         rel.Release__c= 'Test Data';
        insert rel;
        
        Builds__c build= new Builds__c();
        build.Name ='Test';
        build.Status__c='GA';
        build.Release__c= rel.Id;
        insert build;
        
        
        PageReference pageRef = new PageReference('/apex/NewBuildDetail?id='+ build.Id+'&relName=VMware');
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController stdController= new ApexPages.StandardController(build);
        BuildExtension bldExtension = new BuildExtension(stdController);
     
        
        
    }
@IsTest
    public static void TestBuildExtension_RetreiveFiles_ISO()
    {
        Releases__c rel= new  Releases__c();
        rel.Name='TestData';
        rel.Type__c='ISO Image';
        rel.Release_Date__c= Date.today();
         rel.Release__c= 'Test Data';
        insert rel;
        
        Builds__c build= new Builds__c();
        build.Name ='Test';
        build.Status__c='GA';
        build.Release__c= rel.Id;
        insert build;
        
        
        PageReference pageRef = new PageReference('/apex/NewBuildDetail?id='+ build.Id+'&relName=TestData');
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController stdController= new ApexPages.StandardController(build);
        BuildExtension bldExtension = new BuildExtension(stdController);
     
        
        
    }
}