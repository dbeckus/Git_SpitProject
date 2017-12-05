/**
 * Validates if the updating SPContractNumber fields have duplicate values in the database.
 */
trigger ValidateSPContractNumber on Contract (before insert, before update)
{
    Set<String> newSPContractNumbers = new Set<String>();
    Boolean hasDuplicate = false;
    String errMsg = 'Duplicate value.';
    for(Contract contract : Trigger.New)
    {
        //If the updating contracts have duplicate SPContractNumbers, throw error.
        //Else adds the SPContractNumber to the set.
        if(!validateSPContractNumber(contract, 'SP_Contract_Number__c', newSPContractNumbers, true)) { contract.SP_Contract_Number__c.addError(errMsg); hasDuplicate = true; break; }
        if(!validateSPContractNumber(contract, 'SP_Contract_Number_2__c', newSPContractNumbers, true)) { contract.SP_Contract_Number_2__c.addError(errMsg); hasDuplicate = true; break; }
        if(!validateSPContractNumber(contract, 'SP_Contract_Number_3__c', newSPContractNumbers, true)) { contract.SP_Contract_Number_3__c.addError(errMsg); hasDuplicate = true; break; }
        if(!validateSPContractNumber(contract, 'SP_Contract_Number_4__c', newSPContractNumbers, true)) { contract.SP_Contract_Number_4__c.addError(errMsg); hasDuplicate = true; break; }
        if(!validateSPContractNumber(contract, 'SP_Contract_Number_5__c', newSPContractNumbers, true)) { contract.SP_Contract_Number_5__c.addError(errMsg); hasDuplicate = true; break; }
        if(!validateSPContractNumber(contract, 'SP_Contract_Number_6__c', newSPContractNumbers, true)) { contract.SP_Contract_Number_6__c.addError(errMsg); hasDuplicate = true; break; }
        if(!validateSPContractNumber(contract, 'SP_Contract_Number_7__c', newSPContractNumbers, true)) { contract.SP_Contract_Number_7__c.addError(errMsg); hasDuplicate = true; break; }
        if(!validateSPContractNumber(contract, 'SP_Contract_Number_8__c', newSPContractNumbers, true)) { contract.SP_Contract_Number_8__c.addError(errMsg); hasDuplicate = true; break; }
        if(!validateSPContractNumber(contract, 'SP_Contract_Number_9__c', newSPContractNumbers, true)) { contract.SP_Contract_Number_9__c.addError(errMsg); hasDuplicate = true; break; }
        if(!validateSPContractNumber(contract, 'SP_Contract_Number_10__c', newSPContractNumbers, true)) { contract.SP_Contract_Number_10__c.addError(errMsg); hasDuplicate = true; break; }
    }
    
    if(!hasDuplicate)
    {
        Set<Id> contractIds = (Trigger.isInsert) ? new Set<Id>() : Trigger.newMap.keyset();
        //Gets the contract which has the duplicate a SPContractNumber. 
        List<Contract> contracts = [select SP_Contract_Number__c,
                                          SP_Contract_Number_2__c, 
                                          SP_Contract_Number_3__c, 
                                          SP_Contract_Number_4__c, 
                                          SP_Contract_Number_5__c, 
                                          SP_Contract_Number_6__c, 
                                          SP_Contract_Number_7__c, 
                                          SP_Contract_Number_8__c, 
                                          SP_Contract_Number_9__c, 
                                          SP_Contract_Number_10__c 
                                          from Contract where 
                                          (SP_Contract_Number__c in :newSPContractNumbers or 
                                          SP_Contract_Number_2__c in :newSPContractNumbers or 
                                          SP_Contract_Number_3__c in :newSPContractNumbers or 
                                          SP_Contract_Number_4__c in :newSPContractNumbers or 
                                          SP_Contract_Number_5__c in :newSPContractNumbers or 
                                          SP_Contract_Number_6__c in :newSPContractNumbers or 
                                          SP_Contract_Number_7__c in :newSPContractNumbers or 
                                          SP_Contract_Number_8__c in :newSPContractNumbers or 
                                          SP_Contract_Number_9__c in :newSPContractNumbers or 
                                          SP_Contract_Number_10__c in :newSPContractNumbers) and 
                                          Id not in :contractIds];
        if(!contracts.isEmpty())
        {
            Set<String> duplicatedSPContractNumbers = new Set<String>();
            for(Contract contract : contracts)
            {
                //Puts the duplicate SPContractNumber to the set.
                putDuplicatedSPContractNumber(contract, 'SP_Contract_Number__c', newSPContractNumbers, duplicatedSPContractNumbers);
                putDuplicatedSPContractNumber(contract, 'SP_Contract_Number_2__c', newSPContractNumbers, duplicatedSPContractNumbers);
                putDuplicatedSPContractNumber(contract, 'SP_Contract_Number_3__c', newSPContractNumbers, duplicatedSPContractNumbers);
                putDuplicatedSPContractNumber(contract, 'SP_Contract_Number_4__c', newSPContractNumbers, duplicatedSPContractNumbers);
                putDuplicatedSPContractNumber(contract, 'SP_Contract_Number_5__c', newSPContractNumbers, duplicatedSPContractNumbers);
                putDuplicatedSPContractNumber(contract, 'SP_Contract_Number_6__c', newSPContractNumbers, duplicatedSPContractNumbers);
                putDuplicatedSPContractNumber(contract, 'SP_Contract_Number_7__c', newSPContractNumbers, duplicatedSPContractNumbers);
                putDuplicatedSPContractNumber(contract, 'SP_Contract_Number_8__c', newSPContractNumbers, duplicatedSPContractNumbers);
                putDuplicatedSPContractNumber(contract, 'SP_Contract_Number_9__c', newSPContractNumbers, duplicatedSPContractNumbers);
                putDuplicatedSPContractNumber(contract, 'SP_Contract_Number_10__c', newSPContractNumbers, duplicatedSPContractNumbers);
            }
            
            for(Contract contract : Trigger.New)
            {
                //Indicates which field has duplicate SPContractNumber.
                if(!validateSPContractNumber(contract, 'SP_Contract_Number__c', duplicatedSPContractNumbers, false)) { contract.SP_Contract_Number__c.addError(errMsg); break; }
                if(!validateSPContractNumber(contract, 'SP_Contract_Number_2__c', duplicatedSPContractNumbers, false)) { contract.SP_Contract_Number_2__c.addError(errMsg); break; }
                if(!validateSPContractNumber(contract, 'SP_Contract_Number_3__c', duplicatedSPContractNumbers, false)) { contract.SP_Contract_Number_3__c.addError(errMsg); break; }
                if(!validateSPContractNumber(contract, 'SP_Contract_Number_4__c', duplicatedSPContractNumbers, false)) { contract.SP_Contract_Number_4__c.addError(errMsg); break; }
                if(!validateSPContractNumber(contract, 'SP_Contract_Number_5__c', duplicatedSPContractNumbers, false)) { contract.SP_Contract_Number_5__c.addError(errMsg); break; }
                if(!validateSPContractNumber(contract, 'SP_Contract_Number_6__c', duplicatedSPContractNumbers, false)) { contract.SP_Contract_Number_6__c.addError(errMsg); break; }
                if(!validateSPContractNumber(contract, 'SP_Contract_Number_7__c', duplicatedSPContractNumbers, false)) { contract.SP_Contract_Number_7__c.addError(errMsg); break; }
                if(!validateSPContractNumber(contract, 'SP_Contract_Number_8__c', duplicatedSPContractNumbers, false)) { contract.SP_Contract_Number_8__c.addError(errMsg); break; }
                if(!validateSPContractNumber(contract, 'SP_Contract_Number_9__c', duplicatedSPContractNumbers, false)) { contract.SP_Contract_Number_9__c.addError(errMsg); break; }
                if(!validateSPContractNumber(contract, 'SP_Contract_Number_10__c', duplicatedSPContractNumbers, false)) { contract.SP_Contract_Number_10__c.addError(errMsg); break; }
            }
        }
    }
    
    static Boolean validateSPContractNumber(Contract contract, String fieldName, Set<String> spContractNumbers, Boolean updateNumbers)
    {
        if(contract.get(fieldName) != null)
        {
            String fieldValue = String.valueOf(contract.get(fieldName));
            if(spContractNumbers.contains(fieldValue))
            {
                return false;
            }
            else if(updateNumbers)
            {
                spContractNumbers.add(fieldValue);
            }
        }
        return true;
    }
    
    static void putDuplicatedSPContractNumber(Contract contract, String fieldName, Set<String> newNumbers, Set<String> duplicatedNumbers)
    {
        if(contract.get(fieldName) != null)
        {
            String fieldValue = String.valueOf(contract.get(fieldName));
            if(newNumbers.contains(fieldValue))
            {
                duplicatedNumbers.add(fieldValue);
            }
        }
    }
}