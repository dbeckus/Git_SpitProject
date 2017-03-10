trigger CheckECSPEnabledonEnterpriseAccounts on Account (before update) {
   for(Account acc: Trigger.New) 
   {
      
       Account oldAcc= Trigger.OldMap.get(acc.Id);
       if((oldAcc.ECSP__c!=acc.ECSP__c && !acc.ECSP__c) || (oldAcc.Service_Provider_Account_Type__c !=acc.Service_Provider_Account_Type__c ||oldAcc.Service_Provider_Location__c!=acc.Service_Provider_Location__c&& !acc.ECSP__c || oldAcc.Service_Provider_Domain__c!=acc.Service_Provider_Domain__c||oldAcc.Service_Provider_Environment_Type__c!=acc.Service_Provider_Environment_Type__c||oldAcc.Service_Provider_Admin_User__c!=acc.Service_Provider_Admin_User__c))
       {
           if(acc.Cloud_Portal_Account_Id__c!=null || acc.Cloud_Portal_Account_Key__c!=null || acc.Cloud_Portal_Account_Name__c !=null || acc.Service_Provider_Contracted__c )
           {
               acc.addError('You cannot modify any fields in the service provider information section. Please contact service provider team.');
           }
           else
           {
               List<Asset> lstAssets=[Select Id from Asset where AccountId=:acc.Id and Status in ('Customer Evaluation')];
               List<Request__c> lstPOCs =[Select Id from Request__c where Opportunity__r.AccountId=:acc.Id];
               if((lstAssets!=null && lstAssets.size()>0) || (lstPOCs!=null && lstPOCs.size()>0) )
               {
                   acc.addError('You cannot modify any fields in the service provider information section. Please contact service provider team.');
               }
               
           }
       }
   }
    

}