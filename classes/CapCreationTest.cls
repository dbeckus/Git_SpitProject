@isTest
private class CapCreationTest {
  /* Commenting the test class till Cap Project goes live
   // Test when isCap value is true and updated to false
   @isTest static void IsCapFalse() {  
       //Create New Account
       Account acc  = new Account();
       acc.Name     = 'Hybrid Technologies';
       acc.Type     = 'Prospect';
       acc.IsCap__c = False; 
       insert acc;
       
       acc.IsCap__c = True;
       update acc;
       
       List<Cap__c> lstNullCap = [Select Id, Name, Account_Name__r.Id from Cap__c where Account_Name__r.Id =:acc.Id];
       system.assertEquals(1, lstNullCap.size());
       
       acc.IsCap__c = FALSE;
       update acc;
       
       List<Cap__c> lstNullCap1 = [Select Id, Name, Account_Name__r.Id from Cap__c where Account_Name__r.Id =:acc.Id];
       system.assertEquals(1, lstNullCap1.size());
   }
    //Test when the asscociated Case is not of valid record type
    @isTest static void InvalidCase() {
       //Create New Account
       Account acc1  = new Account();
       acc1.Name     = 'Generic Solutions';
       acc1.Type     = 'Prospect';
       acc1.IsCap__c = FALSE; 
       insert acc1;
        
       //Create a new Contact and associate with the Account
       Contact con   = new Contact();
       con.FirstName = 'John';
       con.LastName  = 'Doe';
       con.AccountId = acc1.Id;
       insert con;
       
       //Create a second new case of IT Help request recordtype
       Case case1         = new Case();
       case1.Subject      = 'Invalid Case for Cap Creation';
       case1.AccountId    = acc1.Id;
       case1.ContactId    = con.Id;
       case1.RecordTypeId = '012500000005HNd';
       case1.Priority     = 'P4 - Low';
       case1.Status       = 'Closed';
       case1.Type         = 'Customer Service';
       case1.Origin       = 'Web';
       insert case1;
      
       acc1.IsCap__c = TRUE;
       update acc1;  
       
       List<Cap__c> lstNewCap = [Select Id, Name, Account_Name__r.Id from Cap__c where Status__c ='Open' and Account_Name__r.Id =:acc1.Id Limit 1];
       system.assertEquals(1, lstNewCap.size());
       List<Cap_Case__c> lstNullCapCase = [Select Id, Name, Cap_Name__r.Id, Case_Number__r.Id from Cap_Case__c
                                        where Cap_Name__r.Id =: lstNewCap[0].Id
                                        and Case_Number__r.Id =: case1.Id];
       system.assertEquals(0, lstNullCapCase.size());
   } 
    
    //Test when the associated case is of valid record type
    @isTest static void ValidCase() {
       //Create New Account
       Account acc2  = new Account();
       acc2.Name     = 'Tech Networks';
       acc2.Type     = 'Prospect';
       acc2.IsCap__c = FALSE; 
       insert acc2;
        
       //Create a new Contact and associate with the Account
       Contact con1   = new Contact();
       con1.FirstName = 'Tom';
       con1.LastName  = 'Brady';
       con1.AccountId = acc2.Id;
       insert con1;
       
       //Create a second new case of IT Help request recordtype
       Case case2         = new Case();
       case2.Subject      = 'Valid Case for Cap Creation';
       case2.AccountId    = acc2.Id;
       case2.ContactId    = con1.Id;
       case2.RecordTypeId = '012500000005Aui';
       case2.Priority     = 'P4 - Low';
       case2.Status       = 'Unassigned';
       case2.Type         = 'Technical Support';
       case2.Origin       = 'Web';
       insert case2;
      
       acc2.IsCap__c = TRUE;
       update acc2;  
       
       List<Cap__c> lstValidCap = [Select Id, Name, Account_Name__r.Id from Cap__c where Status__c ='Open' and Account_Name__r.Id =:acc2.Id Limit 1];
       system.assertEquals(1, lstValidCap.size());
       List<Cap_Case__c> lstValidCapCase = [Select Id, Name, Cap_Name__r.Id, Case_Number__r.Id from Cap_Case__c
                                        where Cap_Name__r.Id =: lstValidCap[0].Id
                                        and Case_Number__r.Id =: case2.Id];
       system.assertEquals(1, lstValidCapCase.size());
   }  
   */  
}