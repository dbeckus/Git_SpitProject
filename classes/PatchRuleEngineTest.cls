@isTest
public class PatchRuleEngineTest
{
    @isTest
    static void testMatch()
    {
        PatchRuleEngine.Target t = new PatchRuleEngine.Target();
        PatchRuleEngine.match(t);
    }
    
    @isTest
    static void testOp()
    {
        System.assert(PatchRuleEngine.opIn('a', new Set<String> {'a', 'b'}));
        System.assert(PatchRuleEngine.opInRange('11111', '00000', '22222'));
        System.assert(PatchRuleEngine.opInRange('90145', '00000', '90200'));
        System.assert(PatchRuleEngine.opEqual('a', 'A'));
        System.assert(PatchRuleEngine.opStart('abcd', new Set<String> {'a'}));
        System.assert(PatchRuleEngine.opEnd('dcba', new Set<String> {'a'}));
        System.assert(PatchRuleEngine.opContain('abcd', 'A')); 
    }
}