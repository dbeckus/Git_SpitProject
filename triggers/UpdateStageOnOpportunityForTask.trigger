trigger UpdateStageOnOpportunityForTask on Task (after insert,before update) {
    Map<Id,Task> oppIdStages=new Map<Id,Task>();
    List<Opportunity> lstOpportunity= new List<Opportunity>();
    List<string> lstErrorMessages= new List<String>();
    /*if(Trigger.isInsert)
{
for(Task item :Trigger.New)
{
if(item.Subject !=null && item.Subject=='New BDR Meeting' && item.WhatId.getSobjectType()==Schema.Opportunity.SObjectType)
{
if(item.Initial_Solution_Interest__c!=null)
{
lstOpportunity.add(new Opportunity(Id=item.WhatId,Deal_Type__c=item.Initial_Solution_Interest__c));
}

}
}
}*/
    if(Trigger.isUpdate)
    {
        for(Task item :Trigger.New)
        {
            Task newTask= Trigger.NewMap.get(item.Id);
            Task oldTask= Trigger.oldMap.get(item.Id);
            
            if(item.Subject !=null && item.Subject=='New BDR Meeting' && item.WhatId.getSobjectType()==Schema.Opportunity.SObjectType)
            {
                oppIdStages.put(item.Id,item);
                
            }
        }
        
        List<Profile> lstProfiles=[Select Id from Profile where Name in('1.1- Regional Sales Manager','1.4- Intl Regional Sales Manager')];
        Set<Id> profileIds= new Set<Id>();
        List<Task> lstToUpdateTasks= new List<Task>();
        if(lstProfiles!=null && lstProfiles.size()>0 )
        {
            for(Profile prof: lstProfiles)
            {profileIds.add(prof.Id);}
            
        }
        if(profileIds.size()>0 && profileIds.contains(UserInfo.getProfileId()))
        {
            if(oppIdStages.size()>0)
            {
                
                for(Task item:Trigger.New)
                {
                    if(oppIdStages.containsKey(item.Id))
                    {
                        boolean isValid=true;
                        Task tskData=oppIdStages.get(item.Id);
                        // Validate the fields 
                        if(tskData.Meeting_Rating__c == null)
                        {
                            item.Meeting_Rating__c.addError('If the Subject is New BDR Meeting, then Meeting Rating is required. Please select Meeting Rating.');
                            return;
                        }
                        if(tskData.Meeting_Rating__c !='No Show/Cancelled' && tskData.Next_Opportunity_Stage__c == null)
                        {
                            item.Next_Opportunity_Stage__c.addError('If the Subject is New BDR Meeting, then Next Opportunity Stage is required. Please select Next Opportunity Stage.');
                            return;
                        }
                        /*if(tskData.Initial_Solution_Interest__c == null)
                        {
                            item.Initial_Solution_Interest__c.addError('If the Subject is New BDR Meeting, then Initial Solution Interest is required. Please select Initial Solution Interest.');
                            return;
                        }*/
                        if(tskData.Next_Opportunity_Stage__c =='Closed Dead' && tskData.Dead_Reason__c== null)
                        {
                            item.Dead_Reason__c.addError('If the Next Opportunity Stage is Closed Dead, then Dead Reason is required. Please select Dead Reason.');
                            return;
                        }
                        Opportunity oppObj=[Select Id, StageName,Dead_Reason__c,IsClosed from Opportunity where Id =:tskData.WhatId];
                        if(oppObj!=null)
                        {
                            if(tskData.Next_Opportunity_Stage__c!=null)
                            {
                                oppObj.StageName= tskData.Next_Opportunity_Stage__c;
                                //oppobj.Deal_Type__c = tskData.Initial_Solution_Interest__c;
                                if(tskData.Next_Opportunity_Stage__c =='Closed Dead')
                                {
                                    oppObj.Dead_Reason__c =tskData.Dead_Reason__c;
                                }
                                lstOpportunity.add(oppObj);
                            }
                        }
                        
                        item.Status='Completed';
                    }
                    
                }
                
            }
            
        }
        /*else
{
for(Id counter: oppIdStages.keySet())
{
Task tskItem=oppIdStages.get(counter);
if(tskItem.Initial_Solution_Interest__c!=null)
{
lstOpportunity.add(new Opportunity(Id=tskItem.WhatId,Deal_Type__c=tskItem.Initial_Solution_Interest__c));
}

}

}*/
    }
    if(lstOpportunity.size()>0)
    {
        update lstOpportunity;
    } 
    
}