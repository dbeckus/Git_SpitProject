@IsTest
public class TestNewReleasesController {

    @IsTest(SeeAllData=true)
    public static void TestNewReleasesDataVmWare()
    {   
       
        List<Releases__c> vx9000Dtl=[select Id, Name from Releases__c where Type__c = 'VX Image' and Name='VX-9000'];
        PageReference pageRef = new PageReference('/apex/NewReleases?relType=VMware&relName=VX-9000&reldtl='+vx9000Dtl[0].Id);
        Test.setCurrentPage(pageRef);
        NewReleaseController controller = new NewReleaseController();
        System.assertEquals('VX-9000', controller.ReleaseName);
         System.assertEquals('VMware', controller.ReleaseType);
         System.assertEquals(vx9000Dtl[0].Id, controller.ReleaseId);
        List<Builds__c> builds1 = controller.GARecommendedBuilds;
        List<Builds__c> builds2 = controller.GAOtherBuilds;
         List<Builds__c> builds3 = controller.FCSRecommendedBuilds;
        List<Builds__c> builds4 = controller.FCSOtherBuilds;
          List<Builds__c> builds5 = controller.BETARecommendedBuilds;
        List<Builds__c> builds6 = controller.BetaOtherBuilds;
          List<Builds__c> builds7 = controller.PatchRecommendedBuilds;
        List<Builds__c> builds8 = controller.PatchOtherBuilds;
    }
    
    @IsTest(SeeAllData=true)
    public static void TestNewReleasesDataISO()
    {   
       
        List<Releases__c> vx9000Dtl=[select Id, Name from Releases__c where Type__c = 'VX Image' and Name='VX-9000'];
        PageReference pageRef = new PageReference('/apex/NewReleases?relType=Xen&relName=All VX/VRX&model=All VX/VRX');
        Test.setCurrentPage(pageRef);
        NewReleaseController controller = new NewReleaseController();
        System.assertEquals('All VX/VRX', controller.ReleaseName);
         System.assertEquals('Xen', controller.ReleaseType);
         System.assertEquals(null, controller.ReleaseId);
        System.assertEquals('All VX/VRX', controller.IsoModelName);
        
        List<Builds__c> builds1 = controller.GARecommendedBuilds;
        List<Builds__c> builds2 = controller.GAOtherBuilds;
         List<Builds__c> builds3 = controller.FCSRecommendedBuilds;
        List<Builds__c> builds4 = controller.FCSOtherBuilds;
          List<Builds__c> builds5 = controller.BETARecommendedBuilds;
        List<Builds__c> builds6 = controller.BetaOtherBuilds;
          List<Builds__c> builds7 = controller.PatchRecommendedBuilds;
        List<Builds__c> builds8 = controller.PatchOtherBuilds;
    }
    
    @IsTest(SeeAllData=true)
    public static void TestNewReleasesDataVXOImage()
    {   
       
        
        PageReference pageRef = new PageReference('/apex/NewReleases?relType=VXOA Release&model=All VX/VRX&relName=All VX/VRX');
        Test.setCurrentPage(pageRef);
        NewReleaseController controller = new NewReleaseController();
        System.assertEquals('All VX/VRX', controller.ReleaseName);
         System.assertEquals('VXOA Release', controller.ReleaseType);
         System.assertEquals(null, controller.ReleaseId);
        System.assertEquals('All VX/VRX', controller.IsoModelName);
        
        List<Builds__c> builds1 = controller.GARecommendedBuilds;
        List<Builds__c> builds2 = controller.GAOtherBuilds;
         List<Builds__c> builds3 = controller.FCSRecommendedBuilds;
        List<Builds__c> builds4 = controller.FCSOtherBuilds;
          List<Builds__c> builds5 = controller.BETARecommendedBuilds;
        List<Builds__c> builds6 = controller.BetaOtherBuilds;
          List<Builds__c> builds7 = controller.PatchRecommendedBuilds;
        List<Builds__c> builds8 = controller.PatchOtherBuilds;
    }
}