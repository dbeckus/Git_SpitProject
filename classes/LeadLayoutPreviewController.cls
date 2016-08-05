/*
 * Controller of page LeadLayoutPreview
 */
public class LeadLayoutPreviewController extends LeadController
{
    public LeadLayoutPreviewController(ApexPages.StandardController sc) 
    {
        super(sc);
    }
    
    public List<SelectOption> allRecordTypes
    {
        get
        {
            return new List<SelectOption> {
                new SelectOption('', '-- None --'),
                new SelectOption('Lead', 'Lead'),
                new SelectOption('Deal Registration', 'Deal Registration'),
                new SelectOption('Tele-Lead', 'Tele-Lead'),
                new SelectOption('Converted', 'Converted')
            };
        }
    }
    
    public List<SelectOption> allRoleGroupings
    {
        get
        {
            return new List<SelectOption> {
                new SelectOption('Outside Sales', 'Outside Sales'),
                new SelectOption('Inside Sales', 'Inside Sales'),
                new SelectOption('Channel', 'Channel'),
                new SelectOption('Marketing', 'Marketing'),
                new SelectOption('All/Read Only', 'All/Read Only')
            };
        }
    }
    
    public String RecordTypeToDisplay 
    { 
        get { return recordType; }
        set 
        { 
            recordType = value; 
            if(recordType == 'Converted')
            {
                roleGrouping = '';
            }
        }
    }
    public String RoleGroupToDisplay
    {
        get { return roleGrouping; }
        set 
        { 
            roleGrouping = value; 
            if(recordType == 'Converted')
            {
                roleGrouping = '';
            }
        }
    }
    
    public PageReference refresh()
    {
        layout = null;
        return null;
    }
}