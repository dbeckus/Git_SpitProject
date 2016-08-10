@IsTest
public class TestDownloadsController {
    
    @IsTest(SeeAllData=true)
    public static void DownloadsControllerTest_VAP()
    {
        List<Releases__c> vx9000Dtl=[select Id, Name from Releases__c where Type__c = 'VX Image' and Name='VX-9000'];
        PageReference pageRef = new PageReference('/apex/Downloads?tab=VAP&subTab=VX-9000&releaseDtl='+vx9000Dtl[0].Id);
        Test.setCurrentPage(pageRef);
        DownloadsController controller = new DownloadsController();
        System.assertEquals('VAP', controller.ActiveTab);
        System.assertEquals('VX-9000', controller.ActiveSubTab);
        System.assertEquals(vx9000Dtl[0].Id, controller.ReleaseDtl);
         System.assert(controller.VapReleases.size()>0);
    }
    
    @IsTest(SeeAllData=true)
    public static void DownloadsControllerTest_ISO()
    {
        List<Releases__c> vx9000Dtl=[select Id, Name from Releases__c where Type__c = 'VX Image' and Name='VX-9000'];
        PageReference pageRef = new PageReference('/apex/Downloads?tab=VAP&model=Orchestrator&subtab=Xen');
        Test.setCurrentPage(pageRef);
        DownloadsController controller = new DownloadsController();
        System.assertEquals('VAP', controller.ActiveTab);
        System.assertEquals('Xen', controller.ActiveSubTab);
        System.assertEquals('Orchestrator', controller.ActiveModelTab);
          System.assert(controller.ISOModels.size()>0);
    }
    
     @IsTest(SeeAllData=true)
    public static void DownloadsControllerTest_VXOA()
    {
        List<Releases__c> vx9000Dtl=[select Id, Name from Releases__c where Type__c = 'VX Image' and Name='VX-9000'];
        PageReference pageRef = new PageReference('/apex/Downloads?tab=VXOA Release&model=Orchestrator&subtab=VXOA Release');
        Test.setCurrentPage(pageRef);
        DownloadsController controller = new DownloadsController();
        System.assertEquals('VXOA Release', controller.ActiveTab);
        System.assertEquals('VXOA Release', controller.ActiveSubTab);
        System.assertEquals('Orchestrator', controller.ActiveModelTab);
    }
}