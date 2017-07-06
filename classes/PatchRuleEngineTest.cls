@isTest
public class PatchRuleEngineTest
{
    @isTest
    static void testMatch()
    {
        PatchRuleEngineBase.Target t = new PatchRuleEngineBase.Target();
        PatchRuleEngine engine = new PatchRuleEngine();
        engine.match(t);
    }
    
    @isTest
    static void testOp()
    {
        PatchRuleEngine engine = new PatchRuleEngine();
        System.assert(engine.opIn('a', new Set<String> {'a', 'b'}));
        System.assert(engine.opInRange('11111', '00000', '22222'));
        System.assert(engine.opInRange('90145', '00000', '90200'));
        System.assert(engine.opEqual('a', 'A'));
        System.assert(engine.opStart('abcd', new Set<String> {'a'}));
        System.assert(engine.opEnd('dcba', new Set<String> {'a'}));
        System.assert(engine.opContain('abcd', 'A')); 
    }
}