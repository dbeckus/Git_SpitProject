/**
* Controller of Releases page.
*/
public with sharing class DownloadsController 
{
    public DownloadsController()
    {
        ActiveTab = 'VAP';
        changeBuilds();
    }
    //this section is for the product model number tabs across the top//    
    public List<Releases__c> VapReleases
    {
        get
        {
            return [select Id, Name from Releases__c where Type__c = 'VX Image' or Type__c = 'GX-V Image' order by Name asc];
        }
    }
    
    
    
    public List<String> ISOModels
    {
        get
        {
            List<String> result = new List<String>();
            for(PickListEntry entry : Builds__c.ISO_Model__c.getDescribe().getPicklistValues())
            {
                result.add(entry.getValue());
            }
            return result;
        }
    }
    
    
    public String ActiveTab { get; private set; }    //VAP, VXOA Release or GMS
    public String ActiveSubTab { get; private set; } //VMware,Xen,Hyper-V,KVM
    public String ActiveModelTab { get; private set; } //All products related to ActiveSubTab
    public String ReleaseDtl { get; private set; } //release id (only for VAP)
    
    public PageReference changeBuilds()
    {
        
        String clickingTab = ApexPages.currentPage().getParameters().get('tab');
        String clickingSubtab = ApexPages.currentPage().getParameters().get('subtab');
        String clickingModel = ApexPages.currentPage().getParameters().get('model');
        String clearPara = ApexPages.currentPage().getParameters().get('clear');
        String releaseId = ApexPages.currentPage().getParameters().get('releaseDtl');
        
        if(String.isNotEmpty(clickingTab))
        {
            ActiveTab = clickingTab;
            if(String.isNotEmpty(clearPara))
            {
                ActiveSubTab = null;
                ActiveModelTab = null;
               
            }
        }
        
        if(String.isNotEmpty(clickingSubtab))
        {
            ActiveSubTab = clickingSubtab;
            
        }
        if(String.isNotEmpty(clickingModel))
        {
            ActiveModelTab = clickingModel;
            
        }
        
        if(String.isNotEmpty(releaseId))
        {
            ReleaseDtl = releaseId;
        }
        
        if(ActiveTab == 'VAP')
        {
            if(!String.isEmpty(ActiveSubTab))
            {
                PageReference pageRef= new PageReference('/apex/NewReleases');
                pageRef.getParameters().put('relType',ActiveSubTab);
                pageRef.getParameters().put('relName',ActiveModelTab);
                if(ActiveSubTab=='VMware')
                {
                    pageRef.getParameters().put('reldtl',ReleaseDtl);
                }
                else
                {
                    pageRef.getParameters().put('model',ActiveModelTab);
                }
                pageRef.setRedirect(true);
                return pageRef;
            }
        }
        else
        {
            if(!String.isEmpty(ActiveSubTab))
            {
                
                PageReference pageRef= new PageReference('/apex/NewReleases');
                pageRef.getParameters().put('relType',ActiveSubTab);
               // pageRef.getParameters().put('model',ActiveModelTab);
                pageRef.getParameters().put('relName',ActiveModelTab);
                pageRef.setRedirect(true);
                return pageRef;
            }
            
        }
        
        
        
        return null;
    }
    
    
}