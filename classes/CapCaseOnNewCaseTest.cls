@isTest
   
    private class CapCaseOnNewCaseTest {
    //New Case created when Cap Status is Closed
    @isTest static void CapStatusClosed() { 
        
       Account acc  = new Account();
       acc.Name     = 'InfoTech Solutions';
       acc.Type     = 'Customer';
       acc.IsCap__c = FALSE; 
       insert acc;
        
       Contact con   = new Contact();
       con.FirstName = 'John';
       con.LastName  = 'Doe';
       con.AccountId = acc.Id;
       insert con;
        
       Cap__c closedCap = new Cap__c();
       closedCap.Account_Name__c = acc.Id;
       closedCap.Status__c = 'Closed';
       insert closedCap;
        
       Case nullCase         = new Case();
       nullCase.Subject      = 'Test Cap of Status Closed';
       nullCase.AccountId    = acc.Id;
       nullCase.ContactId    = con.Id;
       nullCase.RecordTypeId = '012500000005Aui';
       nullCase.Priority     = 'P4 - Low';
       nullCase.Status       = 'Unassigned';
       nullCase.Type         = 'Technical Support';
       nullCase.Origin       = 'Web';
       insert nullCase;
       
       List<Cap_Case__c> lstNullCapCases = [Select Id, Name, Cap_Name__r.Id, Case_Number__r.Id from Cap_Case__c
                                        where Cap_Name__r.Id =: closedCap.Id
                                        and Case_Number__r.Id =: nullCase.Id];
       system.assertEquals(0, lstNullCapCases.size());
    }
    // New Case Created with Invalid record type
    @isTest static void InvalidCase() { 
        
       Account acc1  = new Account();
       acc1.Name     = 'Genentec Solutions';
       acc1.Type     = 'Customer';
       acc1.IsCap__c = TRUE; 
       insert acc1;
 
       Contact con1   = new Contact();
       con1.FirstName = 'John';
       con1.LastName  = 'Vick';
       con1.AccountId = acc1.Id;
       insert con1;
        
       Cap__c invalidCap = new Cap__c();
       invalidCap.Account_Name__c = acc1.Id;
       invalidCap.Status__c = 'Open';
       insert invalidCap;
        
       Case Case1         = new Case();
       case1.Subject      = 'Case of Invalid Record Type';
       case1.AccountId    = acc1.Id;
       case1.ContactId    = con1.Id;
       case1.RecordTypeId = '012500000005HNd';
       case1.Priority     = 'P4 - Low';
       case1.Status       = 'Unassigned';
       case1.Type         = 'Customer Service';
       case1.Origin       = 'Web';
       insert case1;
       
       List<Cap_Case__c> lstInvalidCapCases = [Select Id, Name, Cap_Name__r.Id, Case_Number__r.Id from Cap_Case__c
                                        where Cap_Name__r.Id =: invalidCap.Id
                                        and Case_Number__r.Id =: case1.Id];
       system.assertEquals(0, lstInvalidCapCases.size());
    }
        
   /* Commenting till Cap Project needs to go live 
    //New Case created with valid record type
    @isTest static void ValidCase() {  
  
       Account acc2  = new Account();
       acc2.Name     = 'NYC Solutions';
       acc2.Type     = 'Customer';
       acc2.IsCap__c = TRUE; 
       insert acc2;
       
       Contact con2   = new Contact();
       con2.FirstName = 'Tom';
       con2.LastName  = 'Brady';
       con2.AccountId = acc2.Id;
       insert con2;
      
       Cap__c validCap = new Cap__c();
       validCap.Account_Name__c = acc2.Id;
       validCap.Status__c = 'Open';
       insert validCap;
        
       Case Case2         = new Case();
       case2.Subject      = 'Case of Valid Record Type';
       case2.AccountId    = acc2.Id;
       case2.ContactId    = con2.Id;
       case2.RecordTypeId = '012500000005Aui';
       case2.Priority     = 'P4 - Low';
       case2.Status       = 'Unassigned';
       case2.Type         = 'Technical Support';
       case2.Origin       = 'Web';
       insert case2;
       
       List<Cap_Case__c> lstValidCapCases = [Select Id, Name, Cap_Name__r.Id, Case_Number__r.Id from Cap_Case__c
                                        where Cap_Name__r.Id =: validCap.Id
                                        and Case_Number__r.Id =: case2.Id];
       system.assertEquals(1, lstValidCapCases.size());
        }  */
    }