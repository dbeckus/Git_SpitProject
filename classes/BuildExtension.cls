public class BuildExtension {

    public  final Builds__c bldDtl;
    public string ReleaseType{get;set;}
   
    public List<Ensemblestorage__EnsembleFile__c> FilesData{get;set;}
    
    public BuildExtension(ApexPages.StandardController stdController )
    {
        this.bldDtl= (Builds__c)stdController.getRecord();
        ReleaseType= ApexPages.currentPage().getParameters().get('relName');
        if(ReleaseType!='VMware' && ReleaseType!='VXOA Release' && ReleaseType != 'GMS'&& ReleaseType != 'EdgeConnect')
        { ReleaseType='SW '+ReleaseType;}
       
        FilesData= RetreiveFiles();
    }
    
    private List<Ensemblestorage__EnsembleFile__c> RetreiveFiles()
    { 
        List<Ensemblestorage__EnsembleFile__c> lstFiles= new List<Ensemblestorage__EnsembleFile__c>();
        if(ReleaseType!='VMware' && ReleaseType!='VXOA Release' && ReleaseType !='GMS'&& ReleaseType !='EdgeConnect')
        {
        	lstFiles=[Select Id,Name,Ensemblestorage__Comment__c,Ensemblestorage__FormatedSize__c from Ensemblestorage__EnsembleFile__c where Build_Images__c=:bldDtl.Id and Ensemblestorage__Tag__c includes(:ReleaseType)];
        }
        else
        {
             lstFiles=[Select Id,Name,Ensemblestorage__Comment__c,Ensemblestorage__FormatedSize__c from Ensemblestorage__EnsembleFile__c where Build_Images__c=:bldDtl.Id];
        }
        return lstFiles;
    }
}