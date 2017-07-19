@isTest
public class EditCapCasesControllerTest {
    
    //Test Unauthorized User
    @isTest static void UnauthorizedUser(){
        
        Profile prof = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        User techUser = new User(Alias = 'standt', Email='testUser@testtechuser.com', 
                                 EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                                 LocaleSidKey='en_US', ProfileId = prof.Id, 
                                 TimeZoneSidKey='America/Los_Angeles', UserName='testUser@testtechuser.com',
                                 EditCapCapability__c =False);
        techUser.IsActive =true;
        insert techUser;
              
       Account acc = new Account();
       acc.Name     = 'NYC Solutions';
       acc.Type     = 'Customer';
       acc.IsCap__c = TRUE; 
       insert acc;
       
       Contact con   = new Contact();
       con.FirstName = 'Tom';
       con.LastName  = 'Brady';
       con.AccountId = acc.Id;
       insert con;
        
       Cap__c cap = new Cap__c();
       cap.Account_Name__c  = acc.Id;
       cap.Status__c = 'Open';
       insert cap;   
       
       System.runAs(techUser)
       {
       Test.startTest();
       PageReference ref = new PageReference('/apex/EditCapCaseRecords?id=' + acc.Id);
       Test.setCurrentPage(ref);
       EditCapCasesController controller = new EditCapCasesController();
       List<Apexpages.Message> msgs = ApexPages.getMessages();
        boolean b = false;
        for(Apexpages.Message msg:msgs){
            if (msg.getDetail().contains('User cannot Edit CapCase Records')) b = true;
        }
        system.assert(b);
        Test.stopTest();
       }
    }
    
    //Test No Open Cap Record
    @isTest static void NoCap(){
        
        Profile prof = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        User techUser1 = new User(Alias = 'jbrock', Email='testUser1@testtechuser.com', 
                                 EmailEncodingKey='UTF-8', LastName='Testing1', LanguageLocaleKey='en_US', 
                                 LocaleSidKey='en_US', ProfileId = prof.Id, 
                                 TimeZoneSidKey='America/Los_Angeles', UserName='testUser1@testtechuser.com',
                                 EditCapCapability__c =True);
        
        techUser1.IsActive =true;
        insert techUser1;
             
       Account acc1 = new Account();
       acc1.Name     = 'abc Solutions';
       acc1.Type     = 'Customer';
       acc1.IsCap__c = TRUE; 
       insert acc1;
       
       Contact con1   = new Contact();
       con1.FirstName = 'John';
       con1.LastName  = 'Vick';
       con1.AccountId = acc1.Id;
       insert con1;
        
       Cap__c cap1 = new Cap__c();
       cap1.Account_Name__c  = acc1.Id;
       cap1.Status__c = 'Closed';
       insert cap1;   
       
       System.runAs(techUser1)
       {
       Test.startTest();
       PageReference ref = new PageReference('/apex/EditCapCaseRecords?id=' + acc1.Id);
       Test.setCurrentPage(ref);
       EditCapCasesController controller = new EditCapCasesController();
       List<Apexpages.Message> msgs = ApexPages.getMessages();
        boolean b = false;
        for(Apexpages.Message msg:msgs){
            if (msg.getDetail().contains('This Account has no Open Cap Records')) b = true;
        }
        system.assert(b);
        Test.stopTest();
       }
    }

    //No Open Cap Case Records
    @isTest static void NoCapCases(){
        
        Profile prof = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        User techUser2 = new User(Alias = 'psmit', Email='testUser2@testtechuser.com', 
                                 EmailEncodingKey='UTF-8', LastName='Testing2', LanguageLocaleKey='en_US', 
                                 LocaleSidKey='en_US', ProfileId = prof.Id, 
                                 TimeZoneSidKey='America/Los_Angeles', UserName='testUser2@testtechuser.com',
                                 EditCapCapability__c =True);
        
        techUser2.IsActive =true;
        insert techUser2;
            
       Account acc2 = new Account();
       acc2.Name     = 'XYZ Solutions';
       acc2.Type     = 'Customer';
       acc2.IsCap__c = TRUE; 
       insert acc2;
       
       Contact con2   = new Contact();
       con2.FirstName = 'Paul';
       con2.LastName  = 'Smith';
       con2.AccountId = acc2.Id;
       insert con2;
        
       Cap__c cap2 = new Cap__c();
       cap2.Account_Name__c  = acc2.Id;
       cap2.Status__c = 'Open';
       insert cap2;   
       
       System.runAs(techUser2)
       {
       Test.startTest();
       PageReference ref = new PageReference('/apex/EditCapCaseRecords?id=' + acc2.Id);
       Test.setCurrentPage(ref);
       EditCapCasesController controller = new EditCapCasesController();
       List<Apexpages.Message> msgs = ApexPages.getMessages();
        boolean b = false;
        for(Apexpages.Message msg:msgs){
            if (msg.getDetail().contains('No Associated CapCase Records found')) b = true;
        }
        system.assert(b);
        Test.stopTest();
       }
    }
    
     //Saved without any Cap Cases Selected
      @isTest static void NoRecordsSelected(){
        
       Profile prof = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
       User techUser3 = new User(Alias = 'rvaun', Email='testUser3@testtechuser.com', 
                                 EmailEncodingKey='UTF-8', LastName='Testing3', LanguageLocaleKey='en_US', 
                                 LocaleSidKey='en_US', ProfileId = prof.Id, 
                                 TimeZoneSidKey='America/Los_Angeles', UserName='testUser3@testtechuser.com',
                                 EditCapCapability__c =True);
        
        techUser3.IsActive =true;
        insert techUser3;
           
       Account acc3 = new Account();
       acc3.Name     = 'NLT Solutions';
       acc3.Type     = 'Customer';
       acc3.IsCap__c = TRUE; 
       insert acc3;
       
       Contact con3   = new Contact();
       con3.FirstName = 'Adam';
       con3.LastName  = 'Voges';
       con3.AccountId = acc3.Id;
       insert con3;
        
       Cap__c cap3 = new Cap__c();
       cap3.Account_Name__c  = acc3.Id;
       cap3.Status__c = 'Open';
       insert cap3; 
       
       Case Case3         = new Case();
       case3.Subject      = 'Test Case for no selected records';
       case3.AccountId    = acc3.Id;
       case3.ContactId    = con3.Id;
       case3.RecordTypeId = '012500000005Aui';
       case3.Priority     = 'P4 - Low';
       case3.Status       = 'Unassigned';
       case3.Type         = 'Technical Support';
       case3.Origin       = 'Web';
       insert case3;
           
       Cap_case__c cc3 = new Cap_Case__c();
       cc3.Cap_Name__c = cap3.Id;
       cc3.Case_Number__c = case3.Id;
       cc3.Dupe__c = '123';
       insert cc3;
       
       System.runAs(techUser3)
       {
       Test.startTest();
       PageReference ref = new PageReference('/apex/EditCapCaseRecords?id=' + acc3.Id);
       Test.setCurrentPage(ref);
       EditCapCasesController controller = new EditCapCasesController();
       controller.save(); 
       List<Apexpages.Message> msgs = ApexPages.getMessages();
        boolean b = false;
        for(Apexpages.Message msg:msgs){
           if (msg.getDetail().contains('Select atleast 1 record')) b = true;
        }
        system.assert(b); 
        Test.stopTest();
       }
    }

    // One CapCase Record Selected
    @isTest static void SingleRecordSelected(){
        
       Profile prof = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
       User techUser4 = new User(Alias = 'mwaugh', Email='testUser4@testtechuser.com', 
                                 EmailEncodingKey='UTF-8', LastName='Testing4', LanguageLocaleKey='en_US', 
                                 LocaleSidKey='en_US', ProfileId = prof.Id, 
                                 TimeZoneSidKey='America/Los_Angeles', UserName='testUser4@testtechuser.com',
                                 EditCapCapability__c =True);
        
        techUser4.IsActive =true;
        insert techUser4;
            
       Account acc4 = new Account();
       acc4.Name     = 'Yupp Solutions';
       acc4.Type     = 'Customer';
       acc4.IsCap__c = TRUE; 
       insert acc4;
       
       Contact con4   = new Contact();
       con4.FirstName = 'Luke';
       con4.LastName  = 'Cage';
       con4.AccountId = acc4.Id;
       insert con4;
        
       Cap__c cap4 = new Cap__c();
       cap4.Account_Name__c  = acc4.Id;
       cap4.Status__c = 'Open';
       insert cap4; 
       
       Case Case4         = new Case();
       case4.Subject      = 'Test Case for 1 record';
       case4.AccountId    = acc4.Id;
       case4.ContactId    = con4.Id;
       case4.RecordTypeId = '012500000005Aui';
       case4.Priority     = 'P4 - Low';
       case4.Status       = 'Unassigned';
       case4.Type         = 'Technical Support';
       case4.Origin       = 'Web';
       insert case4;
        
       Case Case42         = new Case();
       case42.Subject      = 'Test Case for 2 record';
       case42.AccountId    = acc4.Id;
       case42.ContactId    = con4.Id;
       case42.RecordTypeId = '012500000005Aui';
       case42.Priority     = 'P4 - Low';
       case42.Status       = 'Unassigned';
       case42.Type         = 'Technical Support';
       case42.Origin       = 'Web';
       insert case42;
           
       Cap_case__c cc4 = new Cap_Case__c();
       cc4.Cap_Name__c = cap4.Id;
       cc4.Case_Number__c = case4.Id;
       cc4.Dupe__c = '123';
       cc4.Engineer__c = 'Jeff Smith';
       cc4.Issue_Identified__c = 'Yes';
       cc4.Engineer_Assigned__c = 'Yes';
       cc4.Analysis__c = 'Not Started';
       cc4.Evaluating_Fix__c = 'Not Started';
       cc4.Fix__c = 'Not Started';
       cc4.QA_d__c = 'Not Started';
       cc4.Released__c= 'No';
       insert cc4;
       
       Cap_case__c cc42 = new Cap_Case__c();
       cc42.Cap_Name__c = cap4.Id;
       cc42.Case_Number__c = case42.Id;
       cc42.Dupe__c = '123';
       cc42.Engineer__c = 'Carl Sins';
       cc42.Issue_Identified__c = 'Yes';
       cc42.Engineer_Assigned__c = 'Yes';
       cc42.Analysis__c = 'In Progress';
       cc42.Evaluating_Fix__c = 'In Progress';
       cc42.Fix__c = 'In Progress';
       cc42.QA_d__c = 'In Progress';
       cc42.Released__c= 'No';
       insert cc42;
       
       System.runAs(techUser4)
       {
       Test.startTest();
       PageReference ref = new PageReference('/apex/EditCapCaseRecords?id=' + acc4.Id);
       Test.setCurrentPage(ref);
       EditCapCasesController controller = new EditCapCasesController();
       controller.getOpenCap();
       controller.getCapCasesLst();
           
       List<EditCapCasesController.EditCapCasesWrapper> updateList = controller.lstWrapperCapCases;
           controller.lstWrapperCapCases[1].selected =True;
           controller.lstWrapperCapCases[1].ccase.Dupe__c ='456';    
           controller.save();
           Cap_case__c newcc =[Select Id, Dupe__c from Cap_Case__c where Id=:controller.lstWrapperCapCases[1].ccase.Id];
           system.assertEquals('456',newcc.Dupe__c);
           Test.stopTest();
       } 
    }
}