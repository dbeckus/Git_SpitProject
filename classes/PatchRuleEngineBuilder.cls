/*
 * Builds the PatchRuleEngine according to existing Patch and PatchCriteriaRule records
 */
public class PatchRuleEngineBuilder
{
    private String headerComment;
    private String classHeader;
    private List<String> methods;
    private List<String> subclasses;

    public PatchRuleEngineBuilder()
    {
        headerComment = '/*\r\n' +
                         '* This class is generated dynamically from Patch Rules.\r\n' +
                         '*/\r\n';
        classHeader = 'public class PatchRuleEngine extends PatchRuleEngineBase\r\n';
        methods = new List<String>();
        subclasses = new List<String>();
    }

    public String build()
    {
        registerMainMethod();
        String result = headerComment +
                        classHeader +
                        '{\r\n';
        for(String methodBody : methods)
        {
            result += methodBody;
        }
        for(String subclassBody : subclasses)
        {
            result += subclassBody;
        }
        result += '}';
        return result;
    }

    private void registerMainMethod()
    {
        String methodHeader = '  //returns the matched patch\r\n' +
                              '  public override Match match(Target t)\r\n' +
                              '  {\r\n';
        String methodBody = '    Match result = new Match();\r\n';
        Integer groupIndex = 0;
        List<Patch__c> patchGroup = new List<Patch__c>();
        for(Patch__c patch : [select Id, Active__c, Patch_Name__c, Catchall__c, Overlay__c, CSM__c, ISR__c, Owner__c, ProcessingSequence__c, RSM__c, Rule_Logic__c, SE__c, Type__c, (select Id, Patch__r.Patch_Name__c, Type__c, Value__c, Operation__c, Range_Low__c, Range_High__c, ProcessingSequence__c from Patch_Rules__r order by ProcessingSequence__c) from Patch__c where Active__c=true order by ProcessingSequence__c])
        {
            patchGroup.add(patch);
            if(patchGroup.size() >= 20)
            {
                methodBody += buildPatchGroup(patchGroup, ++groupIndex);
                patchGroup = new List<Patch__c>();
            }
        }
        if(patchGroup.size() > 0)
        {
            methodBody += buildPatchGroup(patchGroup, ++groupIndex);
        }
        String methodFooter = '    return result;\r\n  }\r\n';
        methods.add(methodHeader + methodBody + methodFooter);
    }

    private void registerGroupMatchMethod(List<Patch__c> patches, Integer groupNumber)
    {
        String body = '  private void matchGroup' + groupNumber + '(Target t, Match match)\r\n' +
                      '  {\r\n';
        Integer i = 0;
        for(Patch__c patch : patches)
        {
            body += buildPatch(patch, i++);
        }
        body += '    return;\r\n  }\r\n';
        methods.add(body);
    }

    private String buildPatchGroup(List<Patch__c> patches, Integer groupNumber)
    {
        String methodBody = '    matchGroup'+groupNumber+'(t, result);\r\n' +
                            '    result.PatchId = result.PatchId == null ? result.GeoPatchId : result.PatchId;\r\n' +
                            '    if(result.GeoPatchId != null)\r\n' +
                            '    {\r\n' +
                            '      return result;\r\n' +
                            '    }\r\n';
        registerGroupMatchMethod(patches, groupNumber);
        return methodBody;
    }

    private String buildPatch(Patch__c patch, Integer patchNumber)
    {
        String comment = '    //' + patch.Patch_Name__c + '\r\n';
        String body = '';
        Map<Integer, String> rules = new Map<Integer, String>();
        for(Integer j = 0; j < patch.Patch_Rules__r.size(); j++)
        {
            PatchCriteriaRule__c rule = patch.Patch_Rules__r[j];
            if(rule.ProcessingSequence__c == null)
            {
                throw new SilverPeakException('One of the rule has empty processing sequence. Patch[' + patch.Id+ ']');
            }
            if(isListOperation(rule.Operation__c))
            {
                //body += '    ' + buildRuleList(rule) + '\r\n';
            }
            rules.put(rule.ProcessingSequence__c.intValue(), buildRule(rule));
        }
        body += buildCriteria(patch, rules, patchNumber);
        return body + comment;
    }

    private String buildCriteria(Patch__c patch, Map<Integer, String> rules, Integer patchNumber)
    {
        String body = '';
        if(rules.keyset().size() > 0)
        {
            body += '    if(';
            if(String.isBlank(patch.Rule_Logic__c))
            {
                for(String ruleName : rules.values())
                {
                    body += ruleName + ' && ';
                }
                body = body.substring(0, body.length() - 4);
            }
            else
            {
                Map<String, String> operatorConversions = new Map<String, String> {
                    'AND' => ' && ',
                    'OR' => ' || ',
                    'NOT' => ' !'
                };
                String ruleLogic = '';
                for(String logicSegment : patch.Rule_Logic__c.toUpperCase().splitByCharacterType())
                {
                    if(logicSegment.isNumeric())
                    {
                        Integer ruleNumber = -1;
                        try
                        {
                            ruleNumber = Integer.valueOf(logicSegment);
                        }
                        catch(Exception ex)
                        {
                            throw new SilverPeakException('Unrecognizable Processing Sequence: ' + logicSegment + ' in patch [' + patch.Id + ']');
                        }
                        if(rules.containsKey(ruleNumber))
                        {
                            ruleLogic += rules.get(ruleNumber);
                        }
                        else
                        {
                            throw new SilverPeakException('Processing Sequence does not exist: ' + logicSegment + ' in patch [' + patch.Id + ']');
                        }
                    }
                    else if(String.isNotBlank(logicSegment))
                    {
                        if(operatorConversions.containsKey(logicSegment))
                        {
                            ruleLogic += operatorConversions.get(logicSegment);
                        }
                        else
                        {
                            ruleLogic += logicSegment;
                        }
                    }
                }
                body += ruleLogic;
            }
            body += ')';
            if(patch.Type__c == 'Overlay')
            {
                String patchName = (patch.Patch_Name__c == null) ? '' : String.escapeSingleQuotes(patch.Patch_Name__c);
                body += 'match.OverlayMatches.add(\'' + patch.Id + '\');';
            }
            else if(patch.Type__c == 'Named Accounts')
            {
                String patchName = (patch.Patch_Name__c == null) ? '' : String.escapeSingleQuotes(patch.Patch_Name__c);
                body += 'match.PatchId = match.PatchId == null ? \'' + patch.Id + '\' : match.PatchId;';
            }
            else 
            {
                //GEO patch
                body += '{match.GeoPatchId = \'' + patch.Id + '\';return;}';
            }
        }
        else
        {
            if(patch.Catchall__c)
            {
                body += '    {match.GeoPatchId = \'' + patch.Id + '\';return;}';
            }
            else
            {
                body += '    //Empty rule criteria ';
            }
        }
        return body;
    }

    private String buildValueList(PatchCriteriaRule__c rule)
    {
        String result = 'new Set<String> { ';
        String notNullValue = (rule.Value__c == null) ? '' : rule.Value__c;
        String[] valueParts = PatchRuleHelper.splitCsv(notNullValue);
        Set<String> values = new Set<String>();
        for(Integer i = 0; i < valueParts.size(); i++)
        {
            String value = valueParts[i];
            if(value.trim().startsWith('"') && i + 1 < valueParts.size())
            {
                value += ',' + valueParts[++i];
            }
            value = value.trim();
            values.add(String.escapeSingleQuotes(value).toLowerCase());
        }
        for(String value : values)
        {
            if(String.isNotBlank(value)) 
            {
                result += '\'' + value + '\', ';
            }
        }
        if(result.endsWith(', '))
        {
            result = result.substring(0, result.length() - 2);
        }
        result += ' }';
        return result;
    }

    private String buildMatchList(PatchCriteriaRule__c rule)
    {
        List<PatchMatchList__c> matchList = [select Id, Name from PatchMatchList__c where Patch_Criteria_Rule__c=:rule.Id order by Name];
        String result = 'new Set<String> { ';
        Set<String> values = new Set<String>();
        for(PatchMatchList__c pml : matchList)
        {
            values.add(String.escapeSingleQuotes(pml.Name).toLowerCase());
        }
        for(String value : values)
        {
            if(String.isNotBlank(value)) 
            {
                result += '\'' + value + '\', ';
            }
        }
        if(result.endsWith(', '))
        {
            result = result.substring(0, result.length() - 2);
        }
        result += ' }';
        return result;
    }

    private String buildZipcodeList(PatchCriteriaRule__c rule)
    {
        Set<String> values = new Set<String>();
        if(rule.Operation__c == 'in match list')
        {
            for(PatchMatchList__c pml : [select Id, Name from PatchMatchList__c where Patch_Criteria_Rule__c=:rule.Id order by Name])
            {
                values.add(pml.Name);
            }
        }
        else
        {
            String entry = rule.Value__c;
            entry = (entry == null) ? '' : entry;
            values.addAll(entry.split('\\s*,\\s*'));
        }
        List<String> altValues = new List<String>(values);
        altValues.sort();
        String result = '';
        String low = '', high = '';
        for(String value : altValues)
        {
            if(!value.isNumeric())
            {
                result += value + ',';
                continue;
            }
            if(String.isBlank(low))
            {
                low = value;
                high = value;
            }
            else if(Integer.valueOf(high) + 1 == Integer.valueOf(value))
            {
                high = value;
            }
            else
            {
                result += (low == high) ? low + ',' : low + '~' + high + ',';
                low = high = value;
            }
        }
        result += (low == high) ? low + ',' : low + '~' + high + ',';
        result = result.removeEnd(',');
        return result;
    }

    private String buildRule(PatchCriteriaRule__c rule)
    {
        Map<String, String> opMap = new Map<String, String> {
                                                                'equals' => 'opEqual', 'not equal to' => '!opEqual',
                                                                'in' => 'opIn', 'not in' => '!opIn',
                                                                'starts with' => 'opStart', 'not starts with' => '!opStart',
                                                                'ends with' => 'opEnd', 'not ends with' => '!opEnd',
                                                                'contains' => 'opContain', 'not contains' => '!opContain',
                                                                'in range' => 'opInRange',
                                                                'in match list' => 'opIn'
                                                            };
        Map<String, String> fieldMap = new Map<String, String> {
                                                                    'Company Name' => 't.Company',
                                                                    'Email Domain' => 't.EmailDomain',
                                                                    'Country' => 't.Country',
                                                                    'Zip Code' => 't.ZipCode',
                                                                    'State' => 't.State',
                                                                    'Industry' => 't.Industry'
                                                                };
        if(!opMap.containsKey(rule.Operation__c))
        {
            throw new SilverPeakException('Operation cannot be recognized: ' + rule.Operation__c + '. Patch[' + rule.Patch__c + ']');
        }
        if(!fieldMap.containsKey(rule.Type__c))
        {
            throw new SilverPeakException('Rule Criteria cannot be recognized: ' + rule.Type__c + '. Patch[' + rule.Patch__c + ']');
        }

        String field = fieldMap.get(rule.Type__c);
        String methodName = opMap.get(rule.Operation__c);
        if(rule.Type__c == 'Zip Code' && (rule.Operation__c == 'in' || rule.Operation__c == 'not in' || rule.Operation__c == 'in match list'))
        {
            methodName = (rule.Operation__c == 'not in') ? '!opZipcode' : 'opZipcode';
            return methodName + '(' + field + ', \'' + buildZipcodeList(rule) + '\')';
        }

        if(rule.Operation__c == 'in range')
        {
            String valueLow = (rule.Range_Low__c == null) ? 'null' : String.escapeSingleQuotes(rule.Range_Low__c);
            String valueHigh = (rule.Range_High__c == null) ? 'null' : String.escapeSingleQuotes(rule.Range_High__c);
            return methodName + '(' + field + ', \'' + valueLow + '\', \'' + valueHigh + '\')';
        }
        else if(rule.Operation__c == 'in match list')
        {
            return methodName + '(' + field + ', ' + buildMatchList(rule) + ')';
        }
        else if(isListOperation(rule.Operation__c))
        {
            return methodName + '(' + field + ', ' + buildValueList(rule) + ')';
        }
        else //equals, contains
        {
            String value = (rule.Value__c == null) ? '' : String.escapeSingleQuotes(rule.Value__c);
            return methodName + '(' + field + ', \'' + value + '\')';
        }
    }

    private String wrapId(Id value)
    {
        return (value == null) ? 'null' : '\'' + value + '\'';
    }

    private Boolean isListOperation(String op)
    {
        return op == 'in' || op == 'not in' || op == 'starts with' || op == 'not starts with' || op == 'ends with' || op == 'not ends with';
    }
}