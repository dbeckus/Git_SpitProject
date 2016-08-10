/**
 * Controller of Releases page.
 */
public with sharing class ReleasesController 
{
    public ReleasesController()
    {
        //ActiveTab = 'VAP';
    }
    
    public List<Releases__c> VapReleases
    {
        get
        {
            return [select Id, Name from Releases__c where Type__c = 'VX Image' or Type__c = 'GX-V Image' order by Name desc];
        }
    }
    
    public List<String> BuildStatuses
    {
        get
        {
            List<String> result = new List<String>();
            for(PickListEntry entry : Builds__c.Status__c.getDescribe().getPicklistValues())
            {
                result.add(entry.getValue());
            }
            return result;
        }
    }
    
    public List<String> ISOModels
    {
        get
        {
            List<String> result = new List<String>();
            for(PickListEntry entry : Builds__c.ISO_Model__c.getDescribe().getPicklistValues())
            {
                result.add(entry.getValue());
            }
            return result;
        }
    }
    
    public List<Builds__c> RecommendedBuilds
    {
        get
        {
            if(ActiveTab == 'VAP')
            {
                if(VAPType == 'VMware')
                {
                    return [select Id, Name, Build_Details__c, Build_Number__c, Release__r.Release_Details__c, ReleaseCode__c, ECO_Date__c, IsRecommended__c, Release__r.Release_Date__c 
                            from Builds__c where Release__c=:ActiveModelTab and Status__c=:ActiveSubTab and Inactive__c=false and IsRecommended__c=true order by ECO_Date__c desc];
                }
                else if(VAPType == 'other')
                {
                    return [select Id, Name, Build_Details__c, Build_Number__c, Release__r.Release_Details__c, ReleaseCode__c, ECO_Date__c, IsRecommended__c, Release__r.Release_Date__c 
                            from Builds__c where Release__r.Type__c='ISO Image' and ISO_Model__c=:ActiveModelTab and Status__c=:ActiveSubTab and Inactive__c=false and IsRecommended__c=true order by ECO_Date__c desc];
                }
                else
                {
                    return null;
                }
            }
            else if(ActiveTab == 'VXOA Release' || ActiveTab == 'GMS' || ActiveTab == 'EdgeConnect')
            {
                
                return [select Id, Name, Build_Details__c, Build_Number__c, Release__r.Release_Details__c, ReleaseCode__c, ECO_Date__c, IsRecommended__c, Release__r.Release_Date__c 
                        from Builds__c where Release__r.Type__c=:ActiveTab and Status__c=:ActiveSubTab and Inactive__c=false and IsRecommended__c=true order by ECO_Date__c desc];
            }
            else
            {
                return null;
            }
        }
    }
    
    public List<Builds__c> OtherBuilds
    {
        get
        {
            if(ActiveTab == 'VAP')
            {
                if(VAPType == 'VMware')
                {
                    return [select Id, Name, Build_Details__c, Build_Number__c, Release__r.Release_Details__c, ReleaseCode__c, ECO_Date__c, IsRecommended__c, Release__r.Release_Date__c 
                            from Builds__c where Release__c=:ActiveModelTab and Status__c=:ActiveSubTab and Inactive__c=false and IsRecommended__c=false order by ECO_Date__c desc];
                }
                else if(VAPType == 'other')
                {
                    return [select Id, Name, Build_Details__c, Build_Number__c, Release__r.Release_Details__c, ReleaseCode__c, ECO_Date__c, IsRecommended__c, Release__r.Release_Date__c 
                            from Builds__c where Release__r.Type__c='ISO Image' and ISO_Model__c=:ActiveModelTab and Status__c=:ActiveSubTab and Inactive__c=false and IsRecommended__c=false order by ECO_Date__c desc];
                }
                else
                {
                    return null;
                }
            }
            else if(ActiveTab == 'VXOA Release' || ActiveTab == 'GMS' || ActiveTab == 'EdgeConnect')
            {
                return [select Id, Name, Build_Details__c, Build_Number__c, Release__r.Release_Details__c, ReleaseCode__c, ECO_Date__c, IsRecommended__c, Release__r.Release_Date__c 
                        from Builds__c where Release__r.Type__c=:ActiveTab and Status__c=:ActiveSubTab and Inactive__c=false and IsRecommended__c=false order by ECO_Date__c desc];
            }
            else
            {
                return null;
            }
        }
    }
    
    public String ActiveTab { get; private set; }    //VAP, VXOA Release or GMS
    public String ActiveSubTab { get; private set; } //GA, FCS, PATCH or BETA
    public String ActiveModelTab { get; private set; } //release id (only for VAP)
    public String VAPType { get; private set; } //VMware, other
    public Boolean RenderVAP { get; private set; }
    
    public PageReference changeBuilds()
    {
        String clickingTab = ApexPages.currentPage().getParameters().get('tab');
        String clickingSubtab = ApexPages.currentPage().getParameters().get('subtab');
        String clickingModel = ApexPages.currentPage().getParameters().get('model');
        String clearPara = ApexPages.currentPage().getParameters().get('clear');
        String clickingVapType = ApexPages.currentPage().getParameters().get('vaptype');
        
        if(String.isNotEmpty(clickingTab))
        {
            ActiveTab = clickingTab;
            if(String.isNotEmpty(clearPara))
            {
                ActiveSubTab = null;
                ActiveModelTab = null;
                VAPType = null;
            }
        }
        if(String.isNotEmpty(clickingSubtab))
        {
            ActiveSubTab = clickingSubtab;
        }
        if(String.isNotEmpty(clickingModel))
        {
            ActiveModelTab = clickingModel;
        }
        if(String.isNotEmpty(clickingVapType))
        {
            VAPType = clickingVapType;
        }
        RenderVAP = ActiveTab == 'VAP' && String.isEmpty(VAPType);
        
        if(String.isEmpty(ActiveSubTab))
        {
            if(ActiveTab == 'VAP')
            {
                if(VAPType == 'VMware')
                {
                        if(VapReleases.size() > 0)
                        {
                            ActiveModelTab = VapReleases[0].Id;
                            ActiveSubTab = BuildStatuses[0];
                        }
                }
                else if(VAPType == 'other')
                {
                        if(ISOModels.size() > 0)
                        {
                            ActiveModelTab = ISOModels[0];
                            ActiveSubTab = BuildStatuses[0];
                        }
                }
            }
            else
            {
                    if(BuildStatuses.size() > 0)
                    {
                        ActiveSubTab = BuildStatuses[0];
                    }
            }
        }
        if(String.isEmpty(ActiveModelTab))
        {
            if(ActiveTab == 'VAP')
            {
                if(VAPType == 'VMware')
                {
                    if(VapReleases.size() > 0)
                    {
                        ActiveModelTab = VapReleases[0].Id;
                    }
                }
                else if(VAPType == 'other')
                {
                    if(ISOModels.size() > 0)
                    {
                        ActiveModelTab = ISOModels[0];
                    }
                }
            }
        }
        return null;
    }
    
    @isTest
    static void testReleasesController()
    {
        ReleasesController controller = new ReleasesController();
        System.assertNotEquals(null, controller.VapReleases);
        System.assertNotEquals(null, controller.BuildStatuses);
        System.assertNotEquals(null, controller.ISOModels);
        
        PageReference page = new PageReference('/apex/releases?tab=VAP&vaptype=VMware');
        Test.setCurrentPage(page);
        controller.changeBuilds();
        System.assertEquals('VAP', controller.ActiveTab);
        System.assertEquals(controller.VapReleases[0].Id, controller.ActiveModelTab);
        List<Builds__c> builds = controller.RecommendedBuilds;
        List<Builds__c> builds2 = controller.OtherBuilds;
        
        page = new PageReference('/apex/releases?tab=VAP&vaptype=other');
        Test.setCurrentPage(page);
        controller.changeBuilds();
        System.assertEquals('VAP', controller.ActiveTab);
        //System.assertEquals(controller.ISOModels[0], controller.ActiveModelTab);
        builds = controller.RecommendedBuilds;
        builds2 = controller.OtherBuilds;
        
        page = new PageReference('/apex/releases?tab=GMS');
        Test.setCurrentPage(page);
        controller.changeBuilds();
        System.assertEquals('GMS', controller.ActiveTab);
        System.assertEquals(controller.BuildStatuses[0], controller.ActiveSubtab);
        builds = controller.RecommendedBuilds;
        builds2 = controller.OtherBuilds;
        
        page = new PageReference('/apex/releases?tab=EdgeConnect');
        Test.setCurrentPage(page);
        controller.changeBuilds();
        System.assertEquals('EdgeConnect', controller.ActiveTab);
        System.assertEquals(controller.BuildStatuses[0], controller.ActiveSubtab);
        builds = controller.RecommendedBuilds;
        builds2 = controller.OtherBuilds;
    }
}