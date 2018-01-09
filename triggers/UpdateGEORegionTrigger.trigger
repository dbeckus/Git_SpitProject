trigger UpdateGEORegionTrigger on User_GEO_Region__e (after insert) {

for(User_GEO_Region__e  obj:Trigger.New)
{
   List<opportunity> lstOpp=[Select Id from Opportunity where OwnerId=:obj.Owner_Id__c];
   if(lstOpp!=null && lstOpp.size()>0)
   {
       for(Opportunity opp: lstOpp)
       {
           opp.Sales_Region__c=obj.GEO_Region__c;
       }
        update lstOpp;
   }
  
}

}