/*
 * updates RMA.TrackingInfo to Case.RMA TrackingInfo
 */
trigger UpdateRMATrackingInfoToCase on RMA__c (after insert, after update) 
{
    List<Case> cases = new List<Case>();
    for(RMA__c rma : Trigger.new)
    {
        if(Trigger.isInsert)
        {
            if(rma.Case__c != null && rma.Tracking_Information__c != null && rma.Tracking_Information__c != '')
            {
                cases.add(new Case(Id=rma.Case__c, RMATrackingInfo__c=rma.Tracking_Information__c));
            }
        }
        else if(Trigger.isUpdate)
        {
            RMA__c oldRma = Trigger.oldMap.get(rma.Id);
            if(rma.Case__c != null && rma.Tracking_Information__c != oldRma.Tracking_Information__c)
            {
                cases.add(new Case(Id=rma.Case__c, RMATrackingInfo__c=rma.Tracking_Information__c));
            }
        }
    }
    if(cases.size() > 0)
    {
        update cases;
    }
}