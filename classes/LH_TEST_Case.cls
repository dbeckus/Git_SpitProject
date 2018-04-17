@isTest(SeeAllData=true)
public class LH_TEST_Case {
   static testMethod void LH_Testmethod() {
        List<sObject> sourceList = [SELECT Id 
           FROM Case LIMIT 1];
        if(sourceList.size() == 0) {
            sourceList.add(
                    new Case()
            );
        }
       Database.upsert(sourceList);
    }
}