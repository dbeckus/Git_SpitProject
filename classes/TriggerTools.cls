// Version 1.0 - Austin Amoruso - Fast Start IT 2014
public class TriggerTools 
{
    public static List<sObject> getNewValues(List<sObject> newValues, Map<id, sObject> oldValues, List<String> checkValues)
    {
        List<sObject> result = new List<sObject>();
        if(newValues == null)
        {
            return result;
        }    
        if(oldValues == null || checkValues == null )
        {
            return newValues;
        }
        for(sObject obj : newValues)
        {
            sObject old = oldValues.get(obj.id);
            if(old == null)
            {
                result.add(obj);
                continue;
            }
            for(String val : checkValues)
            {
                if(obj.get(val) != null && !obj.get(val).equals(old.get(val)))
                {
                    result.add(obj);
                    break;
                }
            }
        }
        return result;
    }
    
    // Returns list of all records that have any new values and are not null for the specified fields
    public static List<sObject> getNewValues(List<String> checkValues)
    {
        List<sObject> newValues = Trigger.new; 
        Map<id, sObject> oldValues = Trigger.oldMap;
        return getNewValues(newValues, oldValues, checkValues);
    }
    
    // Returns a list of objects that have made the tranistion from value a to value b on the specified fields
    public static List<sObject> getTransitionValues(Map<String,Object> original, Map<String,Object> current)
    {
    	List<sObject> result = new List<sObject>();
    	Map<id, sObject> newValues = Trigger.newMap;
    	Map<id, sObject> oldValues = Trigger.oldMap;
    	if(newValues == null || oldValues == null || original == null || current == null)
    	{
    		return null;
    	}
    	for(id i : oldValues.keySet())
    	{
    		sObject oldObj = oldValues.get(i);
    		sObject newObj = newValues.get(i);
    		boolean add = true;
    		for(String key : original.keySet())
    		{
    			if(!oldObj.get(key).equals(original.get(key)))
    			{
    				add = false;
    				break;
    			}
    		}
    		if(!add)
    		{
    			continue;
    		}
    		for(String key : current.keySet())
    		{
    			if(!newObj.get(key).equals(current.get(key)))
    			{
    				add = false;
    				break;
    			}
    		}
    		if(add)
    		{
    			result.add(newObj);	
    		}
    	}
    	return result;
    }
    
    
    public static Map<String,List<sObject>> getNewValuesMap(List<sObject> newValues, Map<id, sObject> oldValues, List<String> checkValues)
    {
        Map<String,List<sObject>> result = new Map<String,List<sObject>>();
        if(newValues == null || oldValues == null || checkValues == null)
        {
            return result;
        }
        for(sObject obj : newValues)
        {
            sObject old = null;
            if(oldValues != null)
            {
                old = oldValues.get(obj.id);
            }
            for(String val : checkValues)
            {
                if(((old == null || old.get(val) == null) && obj != null && obj.get(val) != null) || (obj != null && obj.get(val) != null && !obj.get(val).equals(old.get(val))))
                {
                    result = appendsObjectToKey(val,obj,result);
                }
            }
        }
        return result;
    }
    
    // Returns a map sorted by fields of all records that have any new values and are not null for the specified fields
    public static Map<String,List<sObject>> getNewValuesMap(List<String> checkValues)
    {
        List<sObject> newValues = Trigger.new;
        Map<id, sObject> oldValues = Trigger.oldMap;
        return getNewValuesMap(newValues, oldValues, checkValues);
    }
    
    // Returns a list of the specified field value from the objects
    public static List<Object> getValueFromField(List<sObject> objects, String field, List<Object> result)
    {
        if(objects == null)
        {
            return result;
        }
        for(sObject obj : objects)
        {
            if(obj != null && obj.get(field) != null)
            {
                result.add(obj.get(field));
            }
        }
        return result;
    }

    
    // Returns a map with all the field values from the specified fields map key is the field name
    public static Map<String, List<Object>> getValuesFromFields(List<sObject> objects, List<String> fields)
    {
        Map<String, List<Object>> result = new Map<String, List<Object>>();
        for(sObject obj : objects)
        {
            if(obj != null)
            {
                for(String field : fields)
                {
                    if(obj.get(field) != null)
                    {
                        result = appendObjectToKey(field,obj,result);
                    }
                }
            }
        }
        return result;
    }
    
    // Pushes sObject into the list under the proper key(String) in the map
    public static Map<String, List<sObject>> appendsObjectToKey(String key, sObject obj, Map<String,List<sObject>> result)
    {
        if(result == null)
        {
            result = new Map<String,List<sObject>>();
        }
        if(result.get(key) == null)
        {
            List<sObject> temp = new List<sObject>();
            temp.add(obj);
            result.put(key, temp);
        }
        else
        {
            result.get(key).add(obj);
        }
        return result;
    }
    
    // Pushes sObject into the list under the proper key(sObject) in the map
    public static Map<sObject, List<sObject>> appendsObjectToKey(sObject key, sObject obj, Map<sObject,List<sObject>> result)
    {
        if(result == null)
        {
            result = new Map<sObject,List<sObject>>();
        }
        if(result.get(key) == null)
        {
            List<sObject> temp = new List<sObject>();
            temp.add(obj);
            result.put(key, temp);
        }
        else
        {
            result.get(key).add(obj);
        }
        return result;
    }
    
    // Pushes Object into the list under the proper key(String) in the map
    public static Map<String, List<Object>> appendObjectToKey(String Key, Object obj, Map<String,List<Object>> result)
    {
        if(result == null)
        {
            result = new Map<String,List<Object>>();
        }
        if(result.get(key) == null)
        {
            List<Object> temp = new List<Object>();
            temp.add(obj);
            result.put(key, temp);
        }
        else
        {
            result.get(key).add(obj);
        }
        return result;
    }
    
    // Pushes Object into the list under the proper key(Object) in the map
    public static Map<Object, List<Object>> appendObjectToKey(Object Key, Object obj, Map<Object,List<Object>> result)
    {
        if(result == null)
        {
            result = new Map<Object,List<Object>>();
        }
        if(result.get(key) == null)
        {
            List<Object> temp = new List<Object>();
            temp.add(obj);
            result.put(key, temp);
        }
        else
        {
            result.get(key).add(obj);
        }
        return result;
    }
    
    // Pushes Object into the list under the proper key(Object) in the map
    public static Map<Object, List<sObject>> appendObjectToKey(Object Key, sObject obj, Map<Object,List<sObject>> result)
    {
        if(result == null)
        {
            result = new Map<Object,List<sObject>>();
        }
        if(result.get(key) == null)
        {
            List<sObject> temp = new List<sObject>();
            temp.add(obj);
            result.put(key, temp);
        }
        else
        {
            result.get(key).add(obj);
        }
        return result;
    }
    
    // Allows a value to be upserted into a list, either updates the field on the object in list if match or inserts the object 
    public static List<sObject> insertFieldToList(String key, sObject val, String field, List<sObject> result)
    {
        if(result == null)
        {
            result = new List<sObject>();
        }
        sObject temp;
        for(sObject obj : result)
        {
            if(obj.get(key) != null && obj.get(key).equals(val.get(key)))
            {
                temp = obj;
            }
        }
        if(temp == null)
        {
            temp = val;
            result.add(temp);
        }
        temp.put(field, val.get(field));
        return result;
    }
    
    // Allows values to be upserted into a list, either updates the field on the object in list if match or inserts the object
    public static List<sObject> insertFieldsToList(String key, sObject val, List<String> fields, List<sObject> result)
    {
        if(result == null)
        {
            result = new List<sObject>();
        }
        sObject temp;
        for(sObject obj : result)
        {
            if(obj.get(key) != null && obj.get(key).equals(val.get(key)))
            {
                temp = obj;
            }
        }
        if(temp == null)
        {
            temp = val;
            result.add(temp);
        }
        else
        {
        	for(String field : fields)
	        {
            	temp.put(field, val.get(field));   
        	}	
        }
        return result;
    }
    
    // Substrings all strings in array based on the find string
    public static List<String> substringList(List<String> vals, String find)
    {
        List<String> result = new List<String>();
        for(String s : vals)
        {
            Integer index = s.indexOf(find);
            if(index >= 0)
            {
                result.add(s.substring(index));
            }
        }
        return result;
    }
    
    //Attempts to find an object in the list based on rules
    public static sObject listContainsObject(Map<String,Object> rules, List<sObject> objects)
    {
        for(sObject obj : objects)
        {
            if(objectMatchesRules(obj, rules))
            {
                return obj;
            }
        }
        return null;
    }
    
    // Helper method: checks if object matches rules
    public static boolean objectMatchesRules(sObject obj, Map<String,Object> rules)
    {
    	for(String key : rules.keySet())
    	{
    		if(String.isBlank(String.valueof(rules.get(key))) && String.isBlank(String.valueof(obj.get(key))))
    		{
    			continue;
    		}
    		if(!obj.get(key).equals(rules.get(key)))
			{
				return false;
			}
    	}
    	return true;
    }
    
    // Maps List A to List B based on rules specified
    public static Map<sObject, List<sObject>> pathMapFromLists(List<sObject> listA, List<sObject> lB, String fieldA, String fieldB, Boolean multiple)
    {
        Map<sObject, List<sObject>> result = new Map<sObject, List<sObject>>();
        if(lB == null || listA == null || fieldA == null || fieldB == null)
        {
            return result;
        }
        List<sObject> listB = lB.clone();
        for(sObject a : listA)
        {
            for(Integer i = 0; i < listB.size(); i++)
            {
                sObject b = listB.get(i);
                if(a != null && b != null && a.get(fieldA) != null && b.get(fieldB) != null && a.get(fieldA).equals(b.get(fieldB)))
                {
                    TriggerTools.appendsObjectToKey(a, b, result);
                    if(!multiple)
                    {
                        listB.remove(i);                        
                    }
                }
            }
        }
        return result;
    }
    
    // Maps List A to List B based on rules specified: When multiple is not possible for a given key 
    public static Map<sObject, sObject> pathMapFromLists(List<sObject> listA, List<sObject> lB, String fieldA, String fieldB)
    {
        Map<sObject, sObject> result = new Map<sObject, sObject>();
        if(lB == null || listA == null || fieldA == null || fieldB == null)
        {
            return result;
        }
        List<sObject> listB = lB.clone();
        for(sObject a : listA)
        {
            for(Integer i = 0; i < listB.size(); i++)
            {
                sObject b = listB.get(i);
                if(a != null && b != null && a.get(fieldA) != null && b.get(fieldB) != null && a.get(fieldA).equals(b.get(fieldB)))
                {
                	result.put(a,b);
                    listB.remove(i);                        
                }
            }
        }
        return result;
    }
    
    // Links First Map to Last Map if possible, requires all maps to be in proper asscending order to perform links
    public static Map<sObject, List<sObject>> shortcutMaps(List<Map<sObject, List<sObject>>> maps)
    {
        if(maps.size() < 2)
        {
            if(maps == null)
            {
                return null;
            }
            return maps.get(0);
        }
        Map<sObject, List<sObject>> result = new Map<sObject, List<sObject>>();
        result = maps.get(0);
        for(Integer i = 0; i < maps.size() - 1; i++)
        {
            result = shortcutMap(result, maps.get(i + 1));
        }
        return result;
    }
    
    // Links Map A to Map B if possible
    public static Map<sObject, List<sObject>> shortcutMap(Map<sObject, List<sObject>> mapA, Map<sObject, List<sObject>> mapB)
    {
        Map<sObject, List<sObject>> result = new Map<sObject, List<sObject>>();
        for(sObject curKey: mapA.keySet())
        {
            List<sObject> tempList = new List<sObject>();
            List<sObject> curList = mapA.get(curKey);
            for(sObject key : curList)
            {
                if(mapB.containsKey(key))
                {
                    List<sObject> nextList = mapB.get(key);
                    if(nextList != null && nextList.size() > 0)
                    {
                        tempList.addAll(nextList);
                    }
                }
            }
            result.put(curKey, tempList);
        }
        return result;
    }
    
    // Removes sObjects from list based on any field value in map
    public static List<sObject> removeWithValuesFromList(List<sObject> os, Map<String, List<Object>> fields)
    {
        List<sObject> objs = os.clone();
        for(Integer i = 0; i < objs.size(); i++)
        {
            sObject obj = objs.get(i);
            for(String key : fields.keySet())
            {
                for(Object val : fields.get(key))
                {
                    if(obj.get(key).equals(val))
                    {
                        objs.remove(i);
                        break;
                    }
                }        
            }
        }
        return objs;
    }
    
    // Removes sObjects from list based on any field value in map
    public static List<sObject> removeWithValueFromList(List<sObject> os, Map<String, Object> fields)
    {
        List<sObject> objs = os.clone();
        for(Integer i = 0; i < objs.size(); i++)
        {
            sObject obj = objs.get(i);
            for(String key : fields.keySet())
            {
                if(obj.get(key).equals(fields.get(key)))
                {
                    objs.remove(i);
                    break;
                }
            }        
        }
        return objs;
    }
    
    // Merges List A and List B where duplicates based on rules map will default to List A
    public static List<sObject> priorityMerge(List<sObject> listA, List<sObject> listB, Map<String, String> rules)
    {
        if(listA == null && listB == null)
        {
            return null;
        }
        if(listA == null)
        {
            return listB;
        }
        if(listB == null)
        {
            return listA;
        }
        List<sObject> result = listA.clone();
        for(sObject obj : listB)
        {
            boolean skip = false;
            for(sObject master : listA)
            {
                if(TriggerTools.sameObject(master,obj,rules))
                {
                    skip = true;
                    break;
                }
            }
            if(!skip)
            {
                result.add(obj);
            }
        }
        return result;
            
    }
    
    // Helper Method: checks if object a and object a are the same based on field matching rules in map
    public static boolean sameObject(sObject a, sObject b, Map<String, String> rules)
    {
        for(String key : rules.keySet())
        {
            if(!a.get(key).equals(b.get(rules.get(key))))
            {
                return false;
            }
        }
        return true;
    }
    
    
    // Removes values from List A if they are contained in List B based on matching rules specified in map
    public static List<sObject> removeListFromList(List<sObject> listA, List<sObject> listB, Map<String,String> rules)
    {
        List<sObject> result = new List<sObject>();
        if(listA == null)
        {
            return result;
        }
        if(listB == null)
        {
            return listA;
        }

        for(sObject objA : listA)
        {
            boolean skip = false;
            for(sObject objB : listB)
            {
                if(sameObject(objA,objB,rules))
                {
                    skip = true;
                    break;
                }
            }
            if(!skip)
            {
                result.add(objA);
            }
        }
        return result;
    }
    
    // Removes values from List A if they are contained in List B based on fields specified in list
    public static List<Object> removeListFromList(List<Object> listA, List<Object> listB, List<Object> result)
    {
        for(Object objA : listA)
        {
            boolean skip = false;
            for(Object objB : listB)
            {
                if(objA.equals(objB))
                {
                    skip = true;
                    break;
                }
            }
            if(!skip)
            {
                result.add(objA);
            }
        }
        return result;
    }
    
    // Combines fields on object to create a unique key
    public static List<string> makeObjectKeys(List<sObject> objs, List<String> fields)
    {
        return makeObjectKeys(objs,fields, false);
    }
    
    // Combines fields on object to create a unique key 
    public static List<String> makeObjectKeys(List<sObject> objs, List<String> fields, boolean includeBlanks)
    {
        List<String> result = new List<String>();
        if(objs == null || fields == null || fields.size() == 0)
        {
            return result;
        }
        for(sObject obj : objs)
        {
            String temp = makeObjectKey(obj, fields);
            if(!(includeBlanks == false && temp == ''))
            {
                result.add(temp);
            }
        }
        return result;
    }
    
    // Helper Method: Creates a uniques key for a single object based on fields in list
    public static string makeObjectKey(sObject obj, List<String> fields)
    {
        String result = '';
        for(String field : fields)
        {
            result += obj.get(field);
        }
        return result;
    }
    
    // Combines fields on object to create a unique key from a map
    public static List<String> makeObjectKeys(Map<sObject,List<sObject>> objsMap, List<String> keyFields, List<String> valueFields, boolean includeBlanks)
    {
        List<String> result = new List<String>();
        for(sObject objKey : objsMap.keyset())
        {
            for(sObject obj : objsMap.get(objkey))
            {
                String tempA = makeObjectKey(objKey,keyFields);
                String tempB = makeObjectKey(obj,valueFields);
                String tempAB = tempA + tempB;
                if(!(includeBlanks == false && tempAB == ''))
                {
                    result.add(tempAB);
                }
            }
        }
        return result;
    }
    
    public static List<String> makeObjectKeys(Map<sObject,List<sObject>> objsMap, List<String> keyFields, List<String> valueFields)
    {
        return makeObjectKeys(objsMap, keyFields, valueFields, false);
    }
    
    
    public static List<String> makeObjectKeys(Map<sObject,List<sObject>> objsMap, List<String> fields, boolean includeBlanks)
    {
        return makeObjectKeys(objsMap, fields, fields, includeBlanks);
    }
    
    public static List<String> makeObjectKeys(Map<sObject,List<sObject>> objsMap, List<String> fields)
    {
        return makeObjectKeys(objsMap, fields, fields, false);
    }
    
    public static List<String> makeObjectKeys(Map<sObject,List<sObject>> objsMap, String keyField, String valueField, boolean includeBlanks)
    {
        List<String> keyFields = new List<String>();
        keyFields.add(keyField);
        List<String> valueFields = new List<String>();
        valueFields.add(valueField);
        return makeObjectKeys(objsMap, keyFields, valueFields, includeBlanks);
    }
    
    public static List<String> makeObjectKeys(Map<sObject,List<sObject>> objsMap, String keyField, String valueField)
    {
        return makeObjectKeys(objsMap, keyField, valueField, false);
    }
    
    public static List<String> makeObjectKeys(Map<sObject,List<sObject>> objsMap, String field, boolean includeBlanks)
    {
        return makeObjectKeys(objsMap, field, field, includeBlanks);
    }
    
    public static List<String> makeObjectKeys(Map<sObject,List<sObject>> objsMap, String field)
    {
        return makeObjectKeys(objsMap, field, field, false);
    }
    
    // Verifies field is not being set to any of the values in the list
    public static sObject elevateField(sObject obj, String field, List<String> rank, object newValue)
    {
        if(obj != null)
        {
            object currentValue = obj.get(field);        
            if(currentValue == null)
            {
                obj.put(field,newValue);
            }
            else 
            {
                for(String f : rank)
                {
                    if(currentValue.equals(f))
                    {
                        return obj;
                    }
                }
                obj.put(field,newValue);                
            }
        }
        return obj;
    }
    
    // Remove objects that do not match the specified rules
    public static List<sObject> removeNoncompliantObjects(List<sObject> objs, Map<String,String> rules, List<sObject> result)
    {
    	for(sObject obj : objs)
    	{
    		if(objectMatchesRules(obj, rules))
    		{
    			result.add(obj);
    		}
    	}
    	return result;
    }
    
    // Makes a map with the specified field as the key from the list of objects
    public static Map<Object, sObject> makeMapFromList(List<sObject> objs, String field)
    {
    	Map<Object, sObject> result = new Map<Object, sObject>();
    	for(sObject obj : objs)
    	{
    		result.put(obj.get(field),obj);
    	}
    	return result;
    }
    
    // Makes a map with the specified field as the key from the list of objects; duplicate keys will be put into the list for that key
    public static Map<Object, List<sObject>> makeMapListFromList(List<sObject> objs, String field, Map<Object, List<sObject>> result)
    {
    	for(sObject obj : objs)
    	{
    		result = appendObjectToKey(obj.get(field), obj,result);
    	}
    	return result;
    }
    
    public static boolean isEmpty(List<sObject> lst)
    {
    	if(lst != null && lst.size() > 0)
    	{
    		return true;
    	}
    	return false;
    }
    
    
    // Not been tested
    public static List<sObject> sortList(List<sObject> objs, String field)
    {
    	List<sObject> result = new List<sObject>();
    	if(!isEmpty(objs))
    	{
    		List<Object> order = null;
    		if(objs[0].get(field) instanceof Integer)
    		{
    			order = (List<Integer>)getValueFromField(objs, field, new List<Integer>());
    		}
    		else if(objs[0].get(field) instanceof Long)
    		{
    			order = (List<Long>)getValueFromField(objs, field, new List<Long>());
    		}
    		else if(objs[0].get(field) instanceof Double)
    		{
    			order = (List<Double>)getValueFromField(objs, field, new List<Double>());
    		}
    		else if(objs[0].get(field) instanceof Decimal)
    		{
    			order = (List<Decimal>)getValueFromField(objs, field, new List<Decimal>());
    		}
    		else
    		{
    			order = getValueFromField(objs, field, new List<Object>());	
    		}
    		if(order != null)
    		{
    			order.sort();
    			for(Object obj : order)
    			{
    				result.addAll(getAllMatches(objs, field, obj));
    			}
    		}
    	}
    	return result;
    }
    
    // Not been tested
    public static List<sObject> getAllMatches(List<sObject> objs, String key, Object value)
    {
    	Map<String,Object> values = new Map<String,Object>();
    	values.put(key,value);
    	return getAllMatches(objs, values);
    }
    
    // Not been tested
    public static List<sObject> getAllMatches(List<sObject> objs, Map<String,Object> values)
    {
    	List<sObject> result = new List<sObject>();
    	for(sObject obj : objs)
    	{
    		if(objectMatchesRules(obj,values))
    		{
    			result.add(obj);
    		}
    	}
    	return result;
    }
    
}