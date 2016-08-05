/*
 * Controller of page LeadLayoutSetup
 */
public with sharing class LeadLayoutSetupController 
{
    public LeadLayoutSetupController() 
    {
        
    }

    public List<ButtonOpt>      Buttons { get; set; }
    public List<SectionOpt>     Sections { get; set; }
    public List<RelatedListOpt> RelatedLists { get; set; }

    public PageReference init()
    {
        Buttons = new List<ButtonOpt> 
        {
            new ButtonOpt(1, 'Edit', 'LeadEdit'),
            new ButtonOpt(2, 'Delete', 'LeadDelete'),
            new ButtonOpt(3, 'Convert', 'LeadConvert'),
            new ButtonOpt(4, 'Clone', 'LeadClone'),
            new ButtonOpt(5, 'Find Duplicates', 'LeadMerge')
        };

        Sections = new List<SectionOpt> 
        {
            new SectionOpt(2, 'Lead Information',  'Lead_Information_Section', '0IX50000000L18k', 2),
            new SectionOpt(3, 'Disclaimer', 'Disclaimer_Section', '0IX50000000L18i', 2),
            new SectionOpt(4, 'End Customer Information', 'End_Customer_Information_Section', '0IX50000000L18j', 2),
            new SectionOpt(5, 'Marketing Information', 'Marketing_Information_Section', '0IX50000000L18n', 2),
            new SectionOpt(6, 'Opportunity Registration', 'Opportunity_Registration_Section', '0IX50000000L18o', 2),
            new SectionOpt(7, 'Partner Resource Center', 'Partner_Resource_Center_Section', '0IX50000000L18p', 2),
            new SectionOpt(8, 'Qualification Information', 'Qualification_Information_Section', '0IX50000000L18q', 2),
            new SectionOpt(9, 'Scoring', 'Scoring_Section', '0IX50000000L18r', 2),
            new SectionOpt(10, 'Description', 'Description_Section', '0IX50000000L18h', 2),
            new SectionOpt(11, 'Lead Lifecycle', 'Lead_Lifecycle_Section', '0IX50000000L18l', 2),
            new SectionOpt(12, 'System Information', 'Converted_Information_Section', '0IX50000000L18s', 2),
            new SectionOpt(13, 'Sales Team/Channel Information', '', '', 2),
            new SectionOpt(14, 'Marketo Information', '', '', 1)
        };


        RelatedLists = new List<RelatedListOpt> 
        {
            new RelatedListOpt(1, 'Open Activities', 'OpenActivity', 'WhoId'),
            new RelatedListOpt(2, 'Activity History', 'ActivityHistory', 'WhoId'),
            new RelatedListOpt(3, 'Campaign History', 'CampaignMember', 'LeadId'),
            new RelatedListOpt(4, 'Approval History',  'ProcessInstanceHistory', 'TargetObjectId'),
            new RelatedListOpt(5, 'Lead History',  'LeadHistory', 'LeadId')
        };

        Map<String, DynamicLayout__c> layoutNumberMap = new Map<String, DynamicLayout__c>();
        for(DynamicLayout__c layout : [select Name, RecordType__c, UserRole__c from DynamicLayout__c where Object__c = 'Lead'])
        {
            layoutNumberMap.put(layout.Name, layout);
        }
        for(DynamicLayoutElement__c element : [select Name, LayoutNumber__c, Type__c, SectionName__c, ButtonLabel__c, ChildObjectLabel__c from DynamicLayoutElement__c where LayoutNumber__c in :layoutNumberMap.keyset()])
        {
            ConfigurableItem item = null;
            if(element.Type__c == 'Section')
            {
                item = findItem(Sections, element.SectionName__c);
            }
            else if(element.Type__c == 'Button')
            {
                item = findItem(Buttons, element.ButtonLabel__c);
            }
            else if(element.Type__c == 'RelatedList' || element.Type__c == 'Related List')
            {
                item = findItem(RelatedLists, element.ChildObjectLabel__c);
            }
            DynamicLayout__c layout = layoutNumberMap.get(element.LayoutNumber__c);
            if(item != null && layout != null)
            {
                RoleInfo role = item.findRole(layout.RecordType__c, layout.UserRole__c);
                if(role != null)
                {
                    role.IsChecked = true;
                }
            }
        }
        return null;
    }

    public PageReference save()
    {
        SavePoint sp = Database.setSavePoint();
        try
        {
            removeExistingLayoutSetup();
            buildNewLayout();
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, 'Save succeeded.'));
        }
        catch(Exception ex)
        {
            Database.rollback(sp);
            ApexPages.addMessages(ex);
        }
        return null;
    }

    private void removeExistingLayoutSetup()
    {
        List<DynamicLayout__c> leadLayouts = [select Id, Name from DynamicLayout__c where Object__c = 'Lead'];
        List<String> layoutNumbers = new List<String>();
        for(DynamicLayout__c layout : leadLayouts)
        {
            layoutNumbers.add(layout.Name);
        }
        delete leadLayouts;
        delete [select Id from DynamicLayoutElement__c where LayoutNumber__c in :layoutNumbers];
    }
    
    private void buildNewLayout()
    {
        List<DynamicLayout__c> newLayouts = new List<DynamicLayout__c> 
        {
            new DynamicLayout__c(Name = 'DL-Lead-000', Object__c = 'Lead', RecordType__c = null, UserRole__c = null),
            new DynamicLayout__c(Name = 'DL-Lead-001', Object__c = 'Lead', RecordType__c = 'Lead', UserRole__c = 'Outside Sales'),
            new DynamicLayout__c(Name = 'DL-Lead-002', Object__c = 'Lead', RecordType__c = 'Lead', UserRole__c = 'Inside Sales'),
            new DynamicLayout__c(Name = 'DL-Lead-003', Object__c = 'Lead', RecordType__c = 'Lead', UserRole__c = 'Channel'),
            new DynamicLayout__c(Name = 'DL-Lead-004', Object__c = 'Lead', RecordType__c = 'Lead', UserRole__c = 'Marketing'),
            new DynamicLayout__c(Name = 'DL-Lead-005', Object__c = 'Lead', RecordType__c = 'Lead', UserRole__c = 'All/Read Only'),
            new DynamicLayout__c(Name = 'DL-Lead-006', Object__c = 'Lead', RecordType__c = 'Deal Registration', UserRole__c = 'Outside Sales'),
            new DynamicLayout__c(Name = 'DL-Lead-007', Object__c = 'Lead', RecordType__c = 'Deal Registration', UserRole__c = 'Inside Sales'),
            new DynamicLayout__c(Name = 'DL-Lead-008', Object__c = 'Lead', RecordType__c = 'Deal Registration', UserRole__c = 'Channel'),
            new DynamicLayout__c(Name = 'DL-Lead-009', Object__c = 'Lead', RecordType__c = 'Deal Registration', UserRole__c = 'Marketing'),
            new DynamicLayout__c(Name = 'DL-Lead-010', Object__c = 'Lead', RecordType__c = 'Deal Registration', UserRole__c = 'All/Read Only'),
            new DynamicLayout__c(Name = 'DL-Lead-011', Object__c = 'Lead', RecordType__c = 'Tele-Lead', UserRole__c = 'Outside Sales'),
            new DynamicLayout__c(Name = 'DL-Lead-012', Object__c = 'Lead', RecordType__c = 'Tele-Lead', UserRole__c = 'Inside Sales'),
            new DynamicLayout__c(Name = 'DL-Lead-013', Object__c = 'Lead', RecordType__c = 'Tele-Lead', UserRole__c = 'Channel'),
            new DynamicLayout__c(Name = 'DL-Lead-014', Object__c = 'Lead', RecordType__c = 'Tele-Lead', UserRole__c = 'Marketing'),
            new DynamicLayout__c(Name = 'DL-Lead-015', Object__c = 'Lead', RecordType__c = 'Tele-Lead', UserRole__c = 'All/Read Only'),
            new DynamicLayout__c(Name = 'DL-Lead-016', Object__c = 'Lead', RecordType__c = 'Converted', UserRole__c = null)
        };
        insert newLayouts;


        List<DynamicLayoutElement__c> newLayoutElements = new List<DynamicLayoutElement__c>();
        Integer index = 0;
        for(DynamicLayout__c layout : newLayouts)
        {
            for(SectionOpt sec : Sections)
            {
                RoleInfo cell = sec.findRole(layout.RecordType__c, layout.UserRole__c);
                if(cell != null && cell.IsChecked)
                {
                    newLayoutElements.add(new DynamicLayoutElement__c(Name='DLE-Lead-' + (index++), LayoutNumber__c=layout.Name, Type__c='Section', SectionName__c=sec.Label, FieldSet__c=sec.FieldSetName, SectionColumns__c=sec.Columns, Sequence__c=sec.Sequence));
                }
            }
            for(ButtonOpt btn : Buttons)
            {
                RoleInfo cell = btn.findRole(layout.RecordType__c, layout.UserRole__c);
                if(cell != null && cell.IsChecked)
                {
                    newLayoutElements.add(new DynamicLayoutElement__c(Name='DLE-Lead-' + (index++), LayoutNumber__c=layout.Name, Type__c='Button', ButtonName__c=btn.Name, ButtonLabel__c=btn.Label, Sequence__c=btn.Sequence));
                }
            }
            for(RelatedListOpt relList : RelatedLists)
            {
                RoleInfo cell = relList.findRole(layout.RecordType__c, layout.UserRole__c);
                if(cell != null && cell.IsChecked)
                {
                    newLayoutElements.add(new DynamicLayoutElement__c(Name='DLE-Lead-' + (index++), LayoutNumber__c=layout.Name, Type__c='Related List', ChildObjectLabel__c=relList.Label, ChildObject__c=relList.ChildObjectName, RelatedField__c=relList.RelatedFieldName, Sequence__c=relList.Sequence));
                }
            }
        }
        insert newLayoutElements;
    }

    private ConfigurableItem findItem(List<ConfigurableItem> items, String label)
    {
        for(ConfigurableItem item : items)
        {
            if(item.Label == label)
            {
                return item;
            }
        }
        return null;
    }
    
    public class RoleInfo
    {
        public RoleInfo(String name)
        {
            this.Name = name;
            this.IsChecked = false;
        }
        
        public String   Name        { get; set; }
        public Boolean  IsChecked   { get; set; }
    }

    public class RecordTypeInfo
    {
        public RecordTypeInfo(String name)
        {
            this.Name = name;
            this.OutSideSales   = new RoleInfo('Outside Sales');
            this.InsideSales    = new RoleInfo('Inside Sales');
            this.Channel        = new RoleInfo('Channel');
            this.Marketing      = new RoleInfo('Marketing');
            this.AllReadOnly    = new RoleInfo('All/Read Only');
            this.Converted      = new RoleInfo('Converted');
            this.DefaultRole    = new RoleInfo(null);
        }
        
        public String   Name            { get; set; }
        public RoleInfo OutSideSales    { get; set; }
        public RoleInfo InsideSales     { get; set; }
        public RoleInfo Channel         { get; set; }
        public RoleInfo Marketing       { get; set; }
        public RoleInfo AllReadOnly     { get; set; }
        public RoleInfo Converted       { get; set; }
        public RoleInfo DefaultRole     { get; set; }
        
        public RoleInfo findRole(String label)
        {
            List<RoleInfo> allRoles = new List<RoleInfo> { OutsideSales, InsideSales, Channel, Marketing, AllReadOnly, Converted, DefaultRole };
            for(RoleInfo role : allRoles)
            {
                if(role.Name == label)
                {
                    return role;
                }
            }
            return null;
        }
    }
    
    public abstract class ConfigurableItem 
    {
        public ConfigurableItem()
        {
            Lead                = new RecordTypeInfo('Lead');
            DealRegistration    = new RecordTypeInfo('Deal Registration');
            TeleLead            = new RecordTypeInfo('Tele-Lead');
            Converted           = new RecordTypeInfo('Converted');
            DefaultRecordType   = new RecordTypeInfo(null);
        }
        
        public String           Label               { get ;set; }
        public Integer          Sequence            { get; set; }
        public RecordTypeInfo   Lead                { get; set; }
        public RecordTypeInfo   DealRegistration    { get; set; }
        public RecordTypeInfo   TeleLead            { get; set; }
        public RecordTypeInfo   Converted           { get; set; }
        public RecordTypeInfo   DefaultRecordType   { get; set; }
        
        public RoleInfo findRole(String recordType, String role)
        {
            RecordTypeInfo rt = this.findRecordType(recordType);
            if(rt != null)
            {
                return rt.findRole(role);
            }
            return null;
        }
        
        private RecordTypeInfo findRecordType(String label)
        {
            List<RecordTypeInfo> allRecordTypes = new List<RecordTypeInfo> { Lead, DealRegistration, TeleLead, Converted, DefaultRecordType };
            for(RecordTypeInfo rt : allRecordTypes)
            {
                if(rt.Name == label)
                {
                    return rt;
                }
            }
            return null;
        }
    }
    
    public class ButtonOpt extends ConfigurableItem 
    {

        public ButtonOpt(Integer sequence, String label, String name) 
        {
            super();
            this.Sequence   = sequence;
            this.Label      = label;
            this.Name       = name;
        }

        public String Name { get; set; }
    }

    public class SectionOpt extends ConfigurableItem
    {
        public SectionOpt(Integer sequence, String label, String fieldSetName, String fieldSetId, Integer columns) 
        {
            super();
            this.Sequence       = sequence;
            this.Label          = label;
            this.FieldSetName   = fieldSetName;
            this.FieldSetId     = fieldSetId;
            this.Columns        = columns;
        }
        
        public Integer  Columns         { get; set; }
        public String   FieldSetName    { get; set; }
        public String   FieldSetId      { get; set; }
    }

    public class RelatedListOpt extends ConfigurableItem
    {
        public RelatedListOpt(Integer sequence, String label, String childObjectName, String relatedFieldName) 
        {
            super();
            this.Sequence           = sequence;
            this.Label              = label;
            this.ChildObjectName    = childObjectName;
            this.RelatedFieldName   = relatedFieldName;
        }
        
        public String ChildObjectName   { get; set; }
        public String RelatedFieldName  { get; set; }
    }
}