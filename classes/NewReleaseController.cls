public class NewReleaseController {
    
    public string ReleaseType {get;set;}
    public string ReleaseName {get;set;}
    public string ReleaseId {get;set;}
   public string IsoModelName {get;set;}
    public List<Builds__c> GAOtherBuilds {
        get
        {
            
            return LoadOtherBuilds('GA');
        }
        
    }
    public List<Builds__c> GARecommendedBuilds {
        get
        {
            
            return LoadRecommendedBuilds('GA');
        }
    }
    public List<Builds__c> FCSOtherBuilds {
        get
        {
            
            return LoadOtherBuilds('FCS');
        }
    }
    public List<Builds__c> FCSRecommendedBuilds {
        get
        {
            
            return LoadRecommendedBuilds('FCS');
        }
    }
    public List<Builds__c> PatchOtherBuilds {
        get
        {
            
            return LoadOtherBuilds('PATCH');
        }
    }
    public List<Builds__c> PatchRecommendedBuilds {
        get
        {
            
            return LoadRecommendedBuilds('PATCH');
        }}
    public List<Builds__c> BetaOtherBuilds {
        get
        {
            
            return LoadOtherBuilds('BETA');
        }
    }
    public List<Builds__c> BetaRecommendedBuilds {
        get
        {
            
            return LoadRecommendedBuilds('BETA');
        }
    }
    
    
    public NewReleaseController()
    {
        // Set VapType and ReleaseName
        // 
        ReleaseType=ApexPages.currentPage().getParameters().get('relType');
        ReleaseName=ApexPages.currentPage().getParameters().get('relName');
        ReleaseId=ApexPages.currentPage().getParameters().get('reldtl');
        IsoModelName=ApexPages.currentPage().getParameters().get('model');
     
        
        
    }
    
    private List<Builds__c> LoadRecommendedBuilds(string status)
    {
         if(ReleaseType == 'VMware')
                {
                    return [select Id, Name,End_of_Maintenance__c, Build_Details__c, Build_Number__c, Release__r.Release_Details__c, ReleaseCode__c, ECO_Date__c, IsRecommended__c, Release__r.Release_Date__c,FIPS_Compliant__c,Min_Orchestrator_Release__c
                            from Builds__c where Release__c=:ReleaseId and Status__c=:status and Inactive__c=false and IsRecommended__c=true and Id  in (Select Build_Images__c from Ensemblestorage__EnsembleFile__c)  order by ECO_Date__c desc];
                }
                else  if(ReleaseType == 'VXOA Release' || ReleaseType == 'GMS'||ReleaseType == 'EdgeConnect' )
                {
                     return [select Id,End_of_Maintenance__c, Name, Build_Details__c, Build_Number__c, Release__r.Release_Details__c, ReleaseCode__c, ECO_Date__c, IsRecommended__c, Release__r.Release_Date__c,FIPS_Compliant__c,Min_Orchestrator_Release__c
                        from Builds__c where Release__r.Type__c=:ReleaseType and Status__c=:status and Inactive__c=false and IsRecommended__c=true and Id  in (Select Build_Images__c from Ensemblestorage__EnsembleFile__c) order by ECO_Date__c desc];
                }
       		 else  
                {
                    string tagReleaseName='SW '+ReleaseType;
                    return [select Id, Name,End_of_Maintenance__c, Build_Details__c, Build_Number__c, Release__r.Release_Details__c, ReleaseCode__c, ECO_Date__c, IsRecommended__c, Release__r.Release_Date__c,FIPS_Compliant__c,Min_Orchestrator_Release__c
                            from Builds__c where Release__r.Type__c='ISO Image' and ISO_Model__c=:ReleaseName and Status__c=:status and Inactive__c=false and IsRecommended__c=true and Id  in (Select Build_Images__c from Ensemblestorage__EnsembleFile__c where Ensemblestorage__Tag__c includes(:tagReleaseName)) order by ECO_Date__c desc];
                }
        
    }
    
 
    
    private List<Builds__c> LoadOtherBuilds(string status)
    {
        
        if(ReleaseType == 'VMware')
                {
                    return [select Id, Name,End_of_Maintenance__c, Build_Details__c, Build_Number__c, Release__r.Release_Details__c, ReleaseCode__c, ECO_Date__c, IsRecommended__c, Release__r.Release_Date__c,FIPS_Compliant__c,Min_Orchestrator_Release__c 
                            from Builds__c where Release__c=:ReleaseId and Status__c=:status and Inactive__c=false and IsRecommended__c=false and Id  in (Select Build_Images__c from Ensemblestorage__EnsembleFile__c) order by ECO_Date__c desc];
                }
          	else  if(ReleaseType == 'VXOA Release' || ReleaseType == 'GMS'|| ReleaseType == 'EdgeConnect' )
                {
                     return [select Id, Name,End_of_Maintenance__c, Build_Details__c, Build_Number__c, Release__r.Release_Details__c, ReleaseCode__c, ECO_Date__c, IsRecommended__c, Release__r.Release_Date__c,FIPS_Compliant__c,Min_Orchestrator_Release__c
                        from Builds__c where Release__r.Type__c=:ReleaseType  and Status__c=:status and Inactive__c=false and IsRecommended__c=false and Id  in (Select Build_Images__c from Ensemblestorage__EnsembleFile__c) order by ECO_Date__c desc];
                }
                else 
                {
                     string tagReleaseName='SW '+ReleaseType;
                    return [select Id, Name,End_of_Maintenance__c, Build_Details__c, Build_Number__c, Release__r.Release_Details__c, ReleaseCode__c, ECO_Date__c, IsRecommended__c, Release__r.Release_Date__c,FIPS_Compliant__c,Min_Orchestrator_Release__c
                            from Builds__c where Release__r.Type__c='ISO Image' and ISO_Model__c=:ReleaseName and Status__c=:status and Inactive__c=false and IsRecommended__c=false and Id  in (Select Build_Images__c from Ensemblestorage__EnsembleFile__c where Ensemblestorage__Tag__c includes(:tagReleaseName))   order by ECO_Date__c desc];
                }
        
    }
}