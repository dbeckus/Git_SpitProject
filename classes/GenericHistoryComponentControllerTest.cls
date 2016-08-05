@isTest
public class GenericHistoryComponentControllerTest
{
    /*@isTest(SeeAllData=true) 
    static void test() 
    {
        GenericHistoryComponentController controller = new GenericHistoryComponentController();
        System.assert(controller.getObjectHistory().size() == 0);

        AggregateResult[] aggResList = [select OpportunityId, Count(ID) from OpportunityFieldHistory Group By OpportunityId Having Count(ID) > 1 Limit 1];
        System.assert(aggResList.size() > 0,'Test requires at least 1 Opportunity with 2+ Opportunity Field History rows');
      
        controller.parentId = (ID)aggResList[0].get('OpportunityId');
        System.assert(controller.getObjectHistory().size() > 0);        
    }*/
}