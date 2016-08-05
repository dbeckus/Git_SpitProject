public class PagingTestController {
  // ApexPages.StandardSetController must be instantiated   
  // for standard list controllers       
    public ApexPages.StandardSetController setCon {
        get {
            if(setCon == null) {
                setCon = new ApexPages.StandardSetController(Database.getQueryLocator(
                      [select name,closedate from Opportunity]));
            }
            return setCon;
        }
        set;
    }

    // Initialize setCon and return a list of records
   
    public List<Opportunity> getOpportunities() {
         setCon.setpagesize(10);
         return (List<Opportunity>) setCon.getRecords();
    }
    
   
}