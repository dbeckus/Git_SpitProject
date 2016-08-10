/*
 * if TechnicalPresalesReady__c is true, set TechnicalPresalesReadyCertifiedBy__c=currentUser 

 */
trigger SetCertifiedBySignature on Contact (before insert, before update) 
{
    for(Contact cntc : Trigger.new)
    {
      //when inserting, trigger.oldmap is null
        Contact oldcntc = (Trigger.isUpdate) ? Trigger.oldmap.get(cntc.id) : new Contact(TechnicalPresalesReady__c=null);
        if((cntc.TechnicalPresalesReady__c <> oldcntc.TechnicalPresalesReady__c) && cntc.TechnicalPresalesReady__c == true)
        {
            cntc.TechnicalPresalesReadyCertifiedBy__c = UserInfo.getUserId();
           
        }
        if((cntc.TechnicalPresalesReady__c <> oldcntc.TechnicalPresalesReady__c) && cntc.TechnicalPresalesReady__c == false)
        {
            cntc.TechnicalPresalesReadyCertifiedBy__c = null;
           
        }
        

    }
}