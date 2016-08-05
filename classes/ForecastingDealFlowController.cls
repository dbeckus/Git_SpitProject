/*
 * a controller for ForecastingDealFlow page
 */
public class ForecastingDealFlowController
{
    private ForecastingController controller;
    
    public ForecastingDealFlowController(ForecastingController controller)
    {
        this.controller = controller;
    }

    public Boolean isAccessible
    {
        get
        {
            String userId = ApexPages.currentPage().getParameters().get('id');
            if(UserInfo.getUserId() == userId)
            {
                    return true;
            }
            for(Id uid : ForecastingController.getAllSubordinateUsers(UserInfo.getUserId()))
            {
                    if(uid == userId)
                    {
                        return true;
                    }
            }
            User currentUser = [select Id, SPForecastEnabled__c, ViewForecastAs__c from User where Id=:UserInfo.getUserId() limit 1];
            if(!currentUser.SPForecastEnabled__c && currentUser.ViewForecastAs__c != null)
            {
                if(CurrentUser.ViewForecastAs__c == userId)
                {
                    return true;
                }
                for(Id uid : ForecastingController.getAllSubordinateUsers(CurrentUser.ViewForecastAs__c))
                {
                    if(uid == userId)
                    {
                        return true;
                    }
                }
            }
            return false;
        }
    }
    
    //returns all subordinate users role down the hierarchy, as well as myself.
    public List<User> SubordinatesAndMyself
    { 
        get
        {
            String userId = ApexPages.currentPage().getParameters().get('id');
            
            List<User> result = new List<User>();
            List<User> users = [select Id, Name, UserRoleId, GEO_Region__c from User where Id=:userId limit 1];
            if(users.size() > 0)
            {
                    result.addAll([select Id, Name, UserRoleId, GEO_Region__c from User where Id in :ForecastingController.getAllSubordinateUsers(userId)]);
                    result.add(users[0]);
            }
            return result;
        }
    }
    //gets current user and all subordinates Geo Regions value
    public List<String> GeoRegions 
    { 
        get
        {
            Set<String> geoRegions = new Set<String>();
            for(User user : SubordinatesAndMyself)
            {
                    geoRegions.add(user.GEO_Region__c);
            }
            List<String> regions = new List<String>();
            regions.addAll(geoRegions);
            return regions;
        } 
    }
        
    @isTest
    static void testForecastingDealFlowController()
    {
        User user = [select Id, Name, UserRoleId, GEO_Region__c from User where SPForecastEnabled__c = true limit 1];
        PageReference page = new PageReference('/apex/ForecastingDealFlow?id=' + user.Id);
        Test.setCurrentPage(page);
        ForecastingController fc = new ForecastingController();
        ForecastingDealFlowController controller = new ForecastingDealFlowController(fc);
        system.assert(controller.SubordinatesAndMyself.size() > 0);
        system.assert(controller.GeoRegions.size() > 0);
        Boolean accessible = controller.isAccessible;
    }
}