@isTest
public class LeadRejectedControllerTest
{
    @isTest
    static void test()
    {
        Lead ld = new Lead(LastName='acme', Company='acme');
        insert ld;
        
        LeadRejectedController ctrl = new LeadRejectedController(new ApexPages.StandardController(ld));
        ctrl.ismReject();
        ctrl.rsmReject();
    }
}