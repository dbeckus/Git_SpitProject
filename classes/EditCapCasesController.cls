public class EditCapCasesController {
    
    public Account acct;
    public User user;
    public Cap__c OpenCap;
    public List<Cap_Case__c> lstCapCase;
    public List<Cap_Case__c> lstSelectedCapCases;
    public List<EditCapCasesWrapper> lstWrapperCapCases{get;set;}
    
    public EditCapCasesController(){
         fetchCapCaseData();
    }
     
    private void fetchCapCaseData()
    {
        Id userId = UserInfo.getUserId();
        User loggedUser = [Select Id, EditCapCapability__c from User where Id =: userId];
        Id accId = ApexPages.currentPage().getParameters().get('id');
        
        if(accId!=null){
       
        lstWrapperCapCases = new List<EditCapCasesWrapper> ();
        if(loggedUser.EditCapCapability__c == False ){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Warning, 'User cannot Edit CapCase Records'));
        }
        
        else{
            List<Cap__c> lstCap =  [Select Id, Name, Account_Name__r.Name, Status__c, CreatedDate 
                                from Cap__c where Account_Name__r.Id  = :accId
                                and Status__c= 'Open'];
            System.debug(lstCap);
            
            if(lstCap!=null && lstCap.size()==0) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Warning, 'This Account has no Open Cap Records'));
                
            }
            else 
            {
                OpenCap= lstCap[0];
                lstCapCase = [Select Id,Name,Case_Number__r.CaseNumber,Cap_Name__r.Name,Cap_Name__r.Account_Name__r.Id, 
                              Subject__c,Defect__c,Dupe__c,
                              Engineer__c,ETA__c,Comments__c, Issue_Identified__c,Engineer_Assigned__c,
                              Analysis__c,Evaluating_Fix__c,Fix__c,QA_d__c,Released__c,Case_Status__c
                              from Cap_Case__c where Cap_Name__r.Id = :OpenCap.Id
                              and Cap_Name__r.Status__c='Open'];
                if(lstCapCase.size()==0){
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Warning, 'No Associated CapCase Records found'));    
                }
                else if(lstCapCase.size()>0){
                for(Cap_Case__c ccItem : lstCapCase){
                    EditCapCasesWrapper wcc = new EditCapCasesWrapper(ccItem);
                    lstWrapperCapCases.add(wcc);
                    
                }
            }
        } 
    } 
  } 
}  
    
    public  Cap__c getOpenCap(){
        return OpenCap;  
    }
    
    public List<Cap_Case__c> getCapCasesLst(){
        return lstCapCase;
    }
    
    public PageReference save(){ 
        
        List<Cap_Case__c> lstCapCaseToUpdate= new List<Cap_Case__c>();
        for(EditCapCasesWrapper item : lstWrapperCapCases){
            
            if(item.selected){
                lstCapCaseToUpdate.add(item.ccase);  
            }
        }
        if(lstCapCaseToUpdate.size()==0){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Warning, 'Select atleast 1 record'));
        } 
        else
        {
            List<Cap_Case__c> lstFinalCapCases= new List<Cap_Case__c>();
            for(Cap_Case__c item: lstCapCaseToUpdate){
                Cap_Case__c obj = new Cap_Case__c();
                obj.Id= item.Id;
                obj.Dupe__c = item.Dupe__c;
                obj.Engineer__c= item.Engineer__c;
                obj.ETA__c= item.ETA__c;
                obj.Issue_Identified__c= item.Issue_Identified__c;
                obj.Engineer_Assigned__c= item.Engineer_Assigned__c;
                obj.Analysis__c= item.Analysis__c;
                obj.Evaluating_Fix__c= item.Evaluating_Fix__c;
                obj.Fix__c= item.Fix__c;
                obj.QA_d__c= item.QA_d__c;
                obj.Released__c= item.Released__c;
                lstFinalCapCases.add(obj);
            }
            update lstFinalCapCases; 
            fetchCapCaseData();
            ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM,'Cap Cases Updated Successfully'));
        }
        
        return null;
    } 
    
    public class EditCapCasesWrapper {
        
        public Cap_Case__c ccase{get; set;}
        public Boolean selected {get;set;}
        
        public EditCapCasesWrapper(Cap_Case__c cc)
        {
            ccase = cc;
            selected = false;
        }
    }
}