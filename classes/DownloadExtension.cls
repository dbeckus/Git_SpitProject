public class DownloadExtension {
	public final User loggedInUser;
    public  List<Ensemblestorage__DownloadLog__c> lstLog {get;set;}

    public DownloadExtension(ApexPages.StandardController stdController) 
    {
         this.loggedInUser = (User)stdController.getRecord();
         lstLog= new List<Ensemblestorage__DownloadLog__c>();
         if(this.loggedInUser!=null && this.loggedInUser.Id!=null)
         {
             lstLog=[Select Id, Ensemblestorage__File__r.Name,Ensemblestorage__LogDate__c from Ensemblestorage__DownloadLog__c where Ensemblestorage__User__c=:this.loggedInUser.Id order by Ensemblestorage__LogDate__c asc];
         }
        
    }
}