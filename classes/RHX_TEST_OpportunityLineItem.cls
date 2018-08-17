@isTest(SeeAllData=true)
public class RHX_TEST_OpportunityLineItem {
	static testMethod void RHX_Testmethod() {
        List<sObject> sourceList = [SELECT Id 
			FROM OpportunityLineItem LIMIT 1];
        if(sourceList.size() == 0) {
            sourceList.add(
                    new OpportunityLineItem()
            );
        }
    	rh2.ParentUtil.UpsertRollupTestRecords( sourceList );
    }
}