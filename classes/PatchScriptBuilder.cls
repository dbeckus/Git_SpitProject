public class PatchScriptBuilder
{
    public static String build()
    {
        String result = 'public class PatchScriptExecutor\r\n';
        result += '{\r\n';
        result += '  public static void execute()\r\n';
        result += '  {\r\n';
        result += '    SavePoint sp = Database.setSavePoint();\r\n';
        result += '    try {\r\n';
        result += '    List<Id> patches = createPatches();\r\n';
        result += '    List<Id> criteria = createCriteria(patches);\r\n';
        result += '    createMatchList(criteria);\r\n';
        result += '    } catch(Exception ex) { Database.rollback(sp); throw ex;} \r\n';
        result += '  }\r\n\r\n';
        
        result += '  private static List<Id> createPatches()\r\n';
        result += '  {\r\n';
        List<Patch__c> patches = [select Id, Active__c, Catchall__c, Comments__c, Patch_Name__c, ProcessingSequence__c, Rule_Logic__c, Type__c from Patch__c];
        Map<Id, Integer> patchIndex = new Map<Id, Integer>();
        Integer i = 0;
        result += '    List<snappm__Patch__c> ps = new List<snappm__Patch__c> {\r\n';
        for(Patch__c p : patches)
        {
            result += '    new snappm__Patch__c(snappm__Active__c='+p.Active__c+', snappm__Catchall__c='+p.Catchall__c+', snappm__Comments__c=\''+escape(p.Comments__c)+'\', snappm__PatchName__c=\''+escape(p.Patch_Name__c)+'\', snappm__ProcessingSequence__c='+p.ProcessingSequence__c+', snappm__RuleLogic__c=\''+escape(p.Rule_Logic__c)+'\', snappm__Type__c=\''+escape(p.Type__c)+'\'),\r\n';
            patchIndex.put(p.Id, i++);
        }
        result = result.removeEnd(',\r\n');
        result += '    };\r\n';
        result += '    insert ps;\r\n';
        result += '    List<Id> result = new List<Id>();\r\n';
        result += '    for(snappm__Patch__c p : ps)\r\n';
        result += '    {\r\n';
        result += '      result.add(p.Id);\r\n';
        result += '    }\r\n';
        result += '    return result;\r\n';
        result += '  }\r\n\r\n';
        
        result += '  private static List<Id> createCriteria(List<Id> ps)\r\n';
        result += '  {\r\n';
        List<PatchCriteriaRule__c> criteria = [select Id, Type__c, Operation__c, Patch__c, ProcessingSequence__c, Range_High__c, Range_Low__c, Value__c, (select Id, Name from MatchList__r) from PatchCriteriaRule__c];
        Map<Id, Integer> criteriaIndex = new Map<Id, Integer>();
        i = 0;
        result += '    List<snappm__PatchCriteriaRule__c> cs = new List<snappm__PatchCriteriaRule__c> {\r\n';
        for(PatchCriteriaRule__c c : criteria)
        {
            result += '  new snappm__PatchCriteriaRule__c(snappm__Field__c=\''+escape(c.Type__c)+'\', snappm__Operation__c=\''+escape(c.Operation__c)+'\', snappm__Patch__c=ps['+patchIndex.get(c.Patch__c)+'], snappm__ProcessingSequence__c='+c.ProcessingSequence__c+', snappm__RangeHigh__c=\''+escape(c.Range_High__c)+'\', snappm__RangeLow__c=\''+escape(c.Range_Low__c)+'\', snappm__Value__c=\''+escape(c.Value__c)+'\'),\r\n';
            criteriaIndex.put(c.Id, i++);
        }
        result = result.removeEnd(',\r\n');
        result += '\r\n';
        result += '    };\r\n';
        result += '    insert cs;\r\n';
        result += '    List<Id> result = new List<Id>();\r\n';
        result += '    for(snappm__PatchCriteriaRule__c c : cs)\r\n';
        result += '    {\r\n';
        result += '      result.add(c.Id);\r\n';
        result += '    }\r\n';
        result += '    return result;\r\n';
        result += '  }\r\n\r\n';
        
        result += '  private static void createMatchList(List<Id> cs)\r\n';
        result += '  {\r\n';
        result += '    List<snappm__PatchMatchList__c> ms = new List<snappm__PatchMatchList__c>();\r\n';
        for(PatchCriteriaRule__c c : criteria)
        {
            Set<String> items = new Set<String>();
            for(PatchMatchList__c m : c.MatchList__r)
            {
                items.add('\'' + escape(m.Name) + '\'');
            }
            if(items.size() > 0)
            {
                String itemsStr = String.join(new List<String>(items), ', ');
                result += '    ms.addAll(getMatchList(cs['+criteriaIndex.get(c.Id)+'], new List<String> {'+itemsStr+'}));\r\n';
            }
        }
        result = result.removeEnd(',\r\n');
        result += '    insert ms;\r\n';
        result += '  }\r\n\r\n';
        
        result += '  private static List<snappm__PatchMatchList__c> getMatchList(Id criteriaId, List<String> items)\r\n';
        result += '  {\r\n';
        result += '    List<snappm__PatchMatchList__c> result = new List<snappm__PatchMatchList__c>();\r\n';
        result += '    for(String item : items)\r\n';
        result += '    {\r\n';
        result += '      result.add(new snappm__PatchMatchList__c(Name=item, snappm__PatchCriteriaRule__c=criteriaId));\r\n';
        result += '    }\r\n';
        result += '    return result;\r\n';
        result += '  }\r\n';
        
        result += '}';
        return result;
    }
    
    private static String escape(String text)
    {
        if(text == null)
        {
            return '';
        }
        return String.escapeSingleQuotes(text);
    }
    
    @isTest
    static void test()
    {
        PatchScriptBuilder.build();
    }
}