@isTest
public class PatchRuleHelperTest
{
    @isTest
    static void testLead()
    {
        Lead ld = new Lead(LastName='acme', Company='acme');
        insert ld;
        
        PatchRuleHelper.assignPatch(new List<Id> {ld.Id});
        PatchRuleHelper.assignPatch(ld, null);
    }
    
    @isTest
    static void testAccount()
    {
        Account acc = new Account(Name='acme');
        insert acc;
        
        PatchRuleHelper.assignPatch(new List<Id> {acc.Id});
        PatchRuleHelper.assignPatch(acc, null);
    }
    
    @isTest
    static void testOpportunity()
    {
        Patch__c patch = new Patch__c(Patch_Name__c='acme');
        insert patch;
        Account acc = new Account(Name='acme');
        insert acc;
        Opportunity opp = new Opportunity(Name='acme', CloseDate=Date.today(), StageName='Discovery', AccountId=acc.Id);
        insert opp;
        
        PatchRuleHelper.assignPatch(new List<Id> {opp.Id});
        PatchRuleHelper.assignPatch(opp, null);
    }
    
    @isTest static void testSplitCsv()
    {
        String[] s1 = PatchRuleHelper.splitCsv('us, usa, america, united states of america');
        System.assertEquals(4, s1.size());
        System.assertEquals('us', s1[0]);
        System.assertEquals('usa', s1[1]);
        System.assertEquals('america', s1[2]);
        System.assertEquals('united states of america', s1[3]);
        
        String[] s2 = PatchRuleHelper.splitCsv('taiwan, tw, "taiwan, province of china,"');
        System.assertEquals(3, s2.size());
        System.assertEquals('taiwan', s2[0]);
        System.assertEquals('tw', s2[1]);
        System.assertEquals('taiwan, province of china,', s2[2]);
    }
    
}