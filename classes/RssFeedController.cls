public class RssFeedController {
    public List<Case> caseList {get;set;}
    public RssFeedController(){
        caseList = [SELECT Id, CaseNumber, Subject, Priority from Case LIMIT 10];
        
        
    }
    
   

}