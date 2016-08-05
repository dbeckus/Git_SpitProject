/*
 * if Signature_of_Opportunity_Owner__c is true, set SignedBy=currentUser and SignedAt=currentTime
 * if Finance_Reviewed is true, set FinanceReleasedAt=currentTime
 */
trigger SetSignatureOwner on Opportunity (before insert, before update) 
{
    if(!SilverPeakUtils.BypassingTriggers)
    {
        for(Opportunity oppty : Trigger.new)
        {
            //when inserting, trigger.oldmap is null
            Opportunity oldOpp = (Trigger.isUpdate) ? Trigger.oldmap.get(oppty.id) : new Opportunity(Signature_of_Opportunity_Owner__c=null, Finance_Reviewed__c=null);
            if((oppty.Signature_of_Opportunity_Owner__c <> oldOpp.Signature_of_Opportunity_Owner__c) && oppty.Signature_of_Opportunity_Owner__c == true)
            {
                oppty.Signed_By__c = UserInfo.getUserId();
                oppty.Signed_At__c = System.now();
            }
            if((oppty.Signature_of_Opportunity_Owner__c <> oldOpp.Signature_of_Opportunity_Owner__c) && oppty.Signature_of_Opportunity_Owner__c == false)
            {
                oppty.Signed_By__c = null;
                oppty.Signed_At__c = null;
            }
            
            if((oppty.Finance_Reviewed__c <> oldOpp.Finance_Reviewed__c) && oppty.Finance_Reviewed__c == true)
            {
                oppty.Finance_Released_At__c = System.now();
            }
             if((oppty.Finance_Reviewed__c <> oldOpp.Finance_Reviewed__c) && oppty.Finance_Reviewed__c == false)
            {
                oppty.Finance_Released_At__c = null;
            }
        }
    }
}