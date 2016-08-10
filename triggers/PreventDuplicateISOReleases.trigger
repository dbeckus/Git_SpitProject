/*
 * This trigger is used to ensure only one ISO Image release exists in the system.
 */

trigger PreventDuplicateISOReleases on Releases__c (before insert, before update)
{
    Releases__c isoImageRelease = null;
    for(Releases__c release : trigger.new)
    {
        if(release.Type__c == 'ISO Image')
        {
            if(isoImageRelease != null)
            {
                release.Type__c.addError('Only one ISO Image release can exist in the system.');
            }
            isoImageRelease = release;
        }
    }
    if(isoImageRelease != null && [select count() from Releases__c where Type__c = 'ISO Image'] == 1)
    {
        isoImageRelease.Type__c.addError('Only one ISO Image release can exist in the system.');
    }
}