/**
 * Controller of Lead, LeadEdit page.
 */
public with sharing virtual class LeadController 
{
    private Lead lead;
    protected String recordType;
    protected String roleGrouping;
    protected transient LayoutInfo layout;

    public LeadController(ApexPages.StandardController sc)
    {
        try
        {
            sc.addFields(describeFields());
            sc.addFields(new List<String> {'RecordType.Name'} );
        }catch(Exception ex) {}
        
        lead = (Lead)sc.getRecord();
        User currentUser = [SELECT RoleGrouping__c FROM User WHERE Id = :UserInfo.getUserId()];
        roleGrouping = currentUser.RoleGrouping__c;
        if(lead.IsConverted) 
        {
            recordType = 'Converted';
        } 
        else 
        {
            recordType = lead.RecordType.Name;
        }
    }

    public DynamicLayout__c PageLayoutConfig
    {
        get 
        {
            List<DynamicLayout__c> result = [SELECT Name FROM DynamicLayout__c WHERE Object__c = 'Lead' AND RecordType__c = :recordType AND UserRole__c = :roleGrouping LIMIT 1];
            if(result.size() == 0) 
            {
                result = [SELECT Name FROM DynamicLayout__c WHERE Object__c = 'Lead' AND RecordType__c = :recordType AND UserRole__c = null LIMIT 1];
            }
            if(result.size() == 0) 
            {
                result = [SELECT Name FROM DynamicLayout__c WHERE Object__c = 'Lead' AND RecordType__c = null AND UserRole__c = null LIMIT 1];
            }
            if(result.size() == 0) 
            {
                throw new LayoutException('Default layout configuration is missing. Please contact your system administrator. ['+lead.Id+']');
            }
            return result[0];
        }
    }

    public LayoutInfo PageLayout
    {
        get
        {
            if(layout == null)
            {
                layout = new LayoutInfo();
                DynamicLayout__c config = this.PageLayoutConfig;
                for(DynamicLayoutElement__c element : [SELECT Name, Type__c, ButtonLabel__c, ButtonName__c, SectionName__c, FieldSet__c, SectionColumns__c, ChildObject__c, ChildObjectLabel__c, RelatedField__c FROM DynamicLayoutElement__c WHERE LayoutNumber__c = :config.Name ORDER BY Sequence__c])
                {
                    if(element.Type__c == 'Button')
                    {
                        layout.Buttons.add(new ButtonInfo(element.ButtonLabel__c, element.ButtonName__c));
                    }
                    else if(element.Type__c == 'Section')
                    {
                        layout.Sections.add(new SectionInfo(element.SectionName__c, element.FieldSet__c, element.SectionColumns__c));
                    }
                    else if(element.Type__c == 'RelatedList' || element.Type__c == 'Related List')
                    {
                        RelatedListInfo relatedList = new RelatedListInfo(element.ChildObject__c, element.ChildObjectLabel__c, element.RelatedField__c);
                        layout.RelatedLists.add(relatedList);
                    }
                }
            }
            return layout;
        }
    }

    public String ButtonDefinitions
    {
        get
        {
            List<String> buttonNames = new List<String>();
            for(ButtonInfo button : PageLayout.Buttons)
            {
                buttonNames.add(button.Name);
            }
            buttonNames.addAll(PredefinedButtons);

            Map<String, CustomAction.ActionResponse> actions = new Map<String, CustomAction.ActionResponse>();
            for(String buttonName : buttonNames)
            {
                Type actionType = Type.forName('CustomAction', buttonName);
                if(actionType != null)
                {
                    Object action = actionType.newInstance();
                    if(action instanceOf CustomAction.IPageAction)
                    {
                        CustomAction.ActionResponse response = ((CustomAction.IPageAction)action).execute(lead.Id);
                        if(buttonName == 'LeadDelete')
                        {
                            response.needConfirm = true;
                        }
                        actions.put(buttonName, response);
                    }
                }
            }
            return JSON.serialize(actions);
        }
    }
    
    public String CampaignContacts 
    {
        get
        {
            List<Contact> contacts = [select Id, Name from Contact where Campaign_Lead__c=:lead.Id];
            return JSON.serialize(contacts);
        }
    }
    
    public Boolean IsEditable
    {
        get
        {
            for(ButtonInfo button : PageLayout.Buttons)
            {
                if(button.Name == 'LeadEdit')
                {
                    return true;
                }
            }
            return false;
        }
    }
    
    public List<String> PredefinedButtons
    { 
        //these are buttons embedded in section
        get { return new List<String> { 'LeadRSMRejected', 'LeadISRRejected', 'LeadPatchOverride' }; }
    }

    public String PredefinedInlineEditingFields
    {
        get { return 'OwnerId, Name, Street, City, State, PostalCode, Country'; }
    }
    
    public String PredefinedReadOnlyFields
    {
        get { return 'OwnerId, CreatedById, CreatedDate, LastModifiedById, LastModifiedDate, RecordTypeId'; }
    }
    
    public PageReference save()
    {
        try
        {
            upsert lead;
            PageReference ref = new PageReference('/apex/Lead?id=' + lead.Id);
            ref.setRedirect(true);
            return ref;
        }
        catch(DMLException ex)
        {
            ApexPages.addMessages(ex);
            return Page.LeadEdit;
        }
    }
    
    private List<String> describeFields()
    {
        Map<String, Schema.SObjectField> fields = Schema.SObjectType.Lead.fields.getMap();
        List<String> result = new List<String>();
        result.addAll(fields.keyset());
        return result;
    }

    public class LayoutInfo
    {
        public LayoutInfo()
        {
            Sections = new List<SectionInfo>();
            Buttons = new List<ButtonInfo>();
            RelatedLists = new List<RelatedListInfo>();
        }
        
        public List<SectionInfo>        Sections        { get; set; }
        public List<ButtonInfo>         Buttons         { get; set; }
        public List<RelatedListInfo>    RelatedLists    { get; set; }
    }
    
    public class SectionInfo
    {
        public SectionInfo(String name, String fieldset, Decimal columns)
        {
            this.Name = name;
            this.FieldSet = fieldset;
            if(columns == null || columns > 2)
            {
                this.Columns = 2;
            }
            else
            {
                this.Columns = columns.intValue();
            }
        }
        
        public String   Name        { get; set; }
        public String   FieldSet    { get; set; }
        public Integer  Columns     { get; set; }
    }
    
    public class ButtonInfo
    {
        public ButtonInfo(String label, String name)
        {
            this.Label = label;
            this.Name = name;
        }
        
        public String Label { get; set; }
        public String Name  { get; set; }
    }

    public class RelatedListInfo
    {
        public RelatedListInfo(String objName, String objLabel, String relatedField)
        {
            this.ObjectName = objName;
            this.ObjectLabel = objLabel;
            this.RelatedField = relatedField;
        }

        public String ObjectName    { get; set; }
        public String ObjectLabel   { get; set; }
        public String RelatedField  { get; set; }
    }
    
    public class LayoutException extends Exception {}
}