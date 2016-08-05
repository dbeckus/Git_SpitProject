//updates the active status of AuthCode object.
//if there is registration linked to the auth code, the code should be invalid, otherwise, be valid.
trigger ValidateAuthorizationCode on Training_Registration__c(after insert, after update, after delete) 
{
    Set<Id> invalidating = new Set<Id>();
    Set<Id> validating = new Set<Id>();
    if(Trigger.isInsert)
    {
        for(Training_Registration__c registration : Trigger.new)
        {
            if(registration.Authorization__c != null)
            {
                invalidating.add(registration.Authorization__c);
            }
        }
    }
    if(Trigger.isUpdate)
    {
        for(Training_Registration__c registration : Trigger.new)
        {
            Training_Registration__c oldRegistration = Trigger.oldMap.get(registration.Id);
            if(registration.Authorization__c != oldRegistration.Authorization__c)
            {
                invalidating.add(registration.Authorization__c);
                validating.add(oldRegistration.Authorization__c);
            }
        }
    }
    if(Trigger.isDelete)
    {
        for(Training_Registration__c registration : Trigger.old)
        {
            if(registration.Authorization__c != null)
            {
                validating.add(registration.Authorization__c);
            }
        }
    }
    if(invalidating.size() > 0)
    {
        List<AuthCode__c> codes = [select Id from AuthCode__c where Id in :invalidating];
        for(AuthCode__c code : codes)
        {
            code.Valid__c = false;
        }
        update codes;
    }
    if(validating.size() > 0)
    {
        List<AuthCode__c> codes = [select Id from AuthCode__c where Id in :validating];
        for(AuthCode__c code : codes)
        {
            code.Valid__c = true;
        }
        update codes;
    }
}