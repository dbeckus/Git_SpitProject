/*
 * Controller of OpportunityLayoutPreview
 */
public with sharing class OpportunityLayoutPreviewController extends OpportunityController
{
    public OpportunityLayoutPreviewController(ApexPages.standardController sc) 
    {
        super(sc);
        IsOverridable = true;
        if(String.isNotBlank(ApexPages.currentPage().getParameters().get('layoutset')))
        {
            currentLayoutSet = ApexPages.currentPage().getParameters().get('layoutset');
        }
    }
    
    public List<SelectOption> allSalesProcesses
    {
        get
        {
            return new List<SelectOption> {
                new SelectOption('', '-- None --'),
                new SelectOption('New', 'New'),
                new SelectOption('FollowOn', 'Follow On'),
                new SelectOption('Maintenance', 'Maintenance'),
                new SelectOption('Deleted', 'Deleted')
            };
        }
    }
    
    public List<SelectOption> allStageGroupings
    {
        get
        {
            return new List<SelectOption> {
                new SelectOption('New', 'New'),
                new SelectOption('Discovery', 'Discovery'),
                new SelectOption('Qualified', 'Qualified'),
                new SelectOption('Approved', 'Approved'),
                new SelectOption('Final', 'Final'),
                new SelectOption('Closed', 'Closed')
            };
        }
    }
    
    public String SalesProcessToDisplay 
    { 
        get { return currentSalesProcess; }
        set 
        { 
            currentSalesProcess = value; 
            if(currentSalesProcess == 'Deleted')
            {
                currentStage = 'Closed';
            }
            if(currentSalesProcess == '')
            {
                currentStage = '';
            }
        }
    }
    public String StageToDisplay
    {
        get { return currentStage; }
        set 
        { 
            currentStage = value; 
            if(currentSalesProcess == 'Deleted')
            {
                currentStage = 'Closed';
            }
            if(currentSalesProcess == '')
            {
                currentStage = '';
            }
        }
    }
    
    public PageReference refresh()
    {
        layout = null;
        fullRelatedList = null;
        return null;
    }
}