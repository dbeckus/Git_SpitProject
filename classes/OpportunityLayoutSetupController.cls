public with sharing class OpportunityLayoutSetupController 
{
    public OpportunityLayoutSetupController() 
    {
    }

    public List<ButtonOpt> Buttons { get; set; }
    public List<SectionOpt> Sections { get; set; }
    public List<RelatedListOpt> RelatedLists { get; set; }
    
    public PageReference init() 
    {
        Buttons = new List<ButtonOpt> 
        {
            new ButtonOpt(10, 'Edit', 'OpportunityEdit'),
            new ButtonOpt(20, 'Clone', 'OpportunityClone'),
            new ButtonOpt(30, 'Delete', 'OpportunityDelete'),
            new ButtonOpt(40, 'Rev Rec Checklist', 'OpportunityRevenueRecognitionChecklist'),
            new ButtonOpt(50, 'Renewal', 'OpportunityRenewal'),
            new ButtonOpt(60, 'Merge', 'OpportunityMerge')
        };

        Sections = new List<SectionOpt> 
        {
            new SectionOpt(10, 'Opportunity Information', 'Opportunity_Information_Section', '0IX50000000L0aw', 2),
            new SectionOpt(15, 'Description', 'Description_Section', '0IX50000000L14f', 1),
            new SectionOpt(20, 'Technical Environment/POC', 'Technical_Environment_POC_Section', '0IX50000000L0b1', 2),
            new SectionOpt(30, 'Qualification Information', 'Qualification_Information_Section', '0IX50000000L0ay', 1),
            new SectionOpt(40, 'Closed Disposition', 'Closed_Disposition_Section', '0IX50000000L0bE', 2),
            new SectionOpt(50, 'Partner Resource Center Info', 'Partner_Resource_Center_Info_Section', '0IX50000000L0ax', 2),
            new SectionOpt(60, 'Marketing Data', 'Marketing_Data_Section', '0IX50000000L0av', 2),
            new SectionOpt(70, 'Revenue Recognition Checklist', 'Revenue_Recognition_Checklist_Section', '0IX50000000L0az', 2),
            new SectionOpt(80, 'Deleted', 'Deleted_Section', '0IX50000000L0au', 2),
            new SectionOpt(90, 'Sales Team/Patch/Channel Information', 'Sales_Team_Patch_Channel_Information_Sec', '0IX50000000L0b0', 2)
        };

        RelatedLists = new List<RelatedListOpt> 
        {
            new RelatedListOpt(10, 'Contact Roles', 'OpportunityContactRole', 'OpportunityId'),
            new RelatedListOpt(20, 'Silver Peak Quotes', 'Quote__c', 'Opportunity__c'),
            new RelatedListOpt(25, 'SteelBrick Quotes', 'SBQQ__Quote__c', 'SBQQ__Opportunity2__c'),
            new RelatedListOpt(30, 'Products', 'OpportunityLineItem', 'OpportunityId'),
            new RelatedListOpt(40, 'POC Requests', 'Request__c', 'Opportunity__c'),
            new RelatedListOpt(50, 'Purchase Orders', 'Purchase_Order__c', 'Opportunity__c'),
            new RelatedListOpt(60, 'Competitors', 'OpportunityCompetitor', 'OpportunityId'),
            new RelatedListOpt(70, 'Open Activities', 'OpenActivity', 'ParentId'),
            new RelatedListOpt(80, 'Activity History', 'ActivityHistory', 'ParentId'),
            new RelatedListOpt(90, 'Stage History', 'OpportunityHistory', 'OpportunityId'),
            new RelatedListOpt(100, 'Opportunity History', 'OpportunityFieldHistory', 'OpportunityId'),
            new RelatedListOpt(110, 'Note and Attachments', 'NoteAndAttachment', 'ParentId'),
            new RelatedListOpt(110, 'Related Opportunities', 'Opportunity', 'Related_Opportunity__c')
        };
        
        Map<String, DynamicLayout__c> layoutNumberMap = new Map<String, DynamicLayout__c>();
        for(DynamicLayout__c layout : [select Name, SalesProcess__c, Stage__c from DynamicLayout__c where Object__c='Opportunity'])
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
                StageGroupInfo stage = item.findStage(layout.SalesProcess__c, layout.Stage__c);
                if(stage != null)
                {
                    stage.IsChecked = true;
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
        List<DynamicLayout__c> oppLayouts = [select Id, Name from DynamicLayout__c where Object__c='Opportunity'];
        List<String> layoutNumbers = new List<String>();
        for(DynamicLayout__c layout : oppLayouts)
        {
            layoutNumbers.add(layout.Name);
        }
        delete oppLayouts;
        delete [select Id from DynamicLayoutElement__c where LayoutNumber__c in :layoutNumbers];
    }
    
    private void buildNewLayout()
    {
        List<DynamicLayout__c> newOppLayouts = new List<DynamicLayout__c> {
            new DynamicLayout__c(Name='DL-1', Object__c='Opportunity', SalesProcess__c='New', Stage__c='New'),
            new DynamicLayout__c(Name='DL-2', Object__c='Opportunity', SalesProcess__c='New', Stage__c='Discovery'),
            new DynamicLayout__c(Name='DL-3', Object__c='Opportunity', SalesProcess__c='New', Stage__c='Qualified'),
            new DynamicLayout__c(Name='DL-4', Object__c='Opportunity', SalesProcess__c='New', Stage__c='Approved'),
            new DynamicLayout__c(Name='DL-5', Object__c='Opportunity', SalesProcess__c='New', Stage__c='Final'),
            new DynamicLayout__c(Name='DL-6', Object__c='Opportunity', SalesProcess__c='New', Stage__c='Closed'),
            new DynamicLayout__c(Name='DL-7', Object__c='Opportunity', SalesProcess__c='FollowOn', Stage__c='New'),
            new DynamicLayout__c(Name='DL-8', Object__c='Opportunity', SalesProcess__c='FollowOn', Stage__c='Discovery'),
            new DynamicLayout__c(Name='DL-9', Object__c='Opportunity', SalesProcess__c='FollowOn', Stage__c='Qualified'),
            new DynamicLayout__c(Name='DL-10', Object__c='Opportunity', SalesProcess__c='FollowOn', Stage__c='Approved'),
            new DynamicLayout__c(Name='DL-11', Object__c='Opportunity', SalesProcess__c='FollowOn', Stage__c='Final'),
            new DynamicLayout__c(Name='DL-12', Object__c='Opportunity', SalesProcess__c='FollowOn', Stage__c='Closed'),
            new DynamicLayout__c(Name='DL-13', Object__c='Opportunity', SalesProcess__c='Maintenance', Stage__c='New'),
            new DynamicLayout__c(Name='DL-14', Object__c='Opportunity', SalesProcess__c='Maintenance', Stage__c='Discovery'),
            new DynamicLayout__c(Name='DL-15', Object__c='Opportunity', SalesProcess__c='Maintenance', Stage__c='Qualified'),
            new DynamicLayout__c(Name='DL-16', Object__c='Opportunity', SalesProcess__c='Maintenance', Stage__c='Approved'),
            new DynamicLayout__c(Name='DL-17', Object__c='Opportunity', SalesProcess__c='Maintenance', Stage__c='Final'),
            new DynamicLayout__c(Name='DL-18', Object__c='Opportunity', SalesProcess__c='Maintenance', Stage__c='Closed'),
            new DynamicLayout__c(Name='DL-19', Object__c='Opportunity', SalesProcess__c='Deleted', Stage__c='Closed'),
            new DynamicLayout__c(Name='DL-20', Object__c='Opportunity', SalesProcess__c=null, Stage__c=null)
        };
        insert newOppLayouts;
        List<DynamicLayoutElement__c> newLayoutElements = new List<DynamicLayoutElement__c>();
        Integer index = 1;
        for(DynamicLayout__c oppLayout : newOppLayouts)
        {
            for(SectionOpt sec : Sections)
            {
                StageGroupInfo cell = sec.findStage(oppLayout.SalesProcess__c, oppLayout.Stage__c);
                if(cell != null && cell.IsChecked)
                {
                    newLayoutElements.add(new DynamicLayoutElement__c(Name='DLE-' + (index++), LayoutNumber__c=oppLayout.Name, Type__c='Section', SectionName__c=sec.Label, FieldSet__c=sec.FieldSetName, SectionColumns__c=sec.Columns, Sequence__c=sec.Sequence));
                }
            }
            for(ButtonOpt btn : Buttons)
            {
                StageGroupInfo cell = btn.findStage(oppLayout.SalesProcess__c, oppLayout.Stage__c);
                if(cell != null && cell.IsChecked)
                {
                    newLayoutElements.add(new DynamicLayoutElement__c(Name='DLE-' + (index++), LayoutNumber__c=oppLayout.Name, Type__c='Button', ButtonName__c=btn.Name, ButtonLabel__c=btn.Label, Sequence__c=btn.Sequence));
                }
            }
            for(RelatedListOpt relList : RelatedLists)
            {
                StageGroupInfo cell = relList.findStage(oppLayout.SalesProcess__c, oppLayout.Stage__c);
                if(cell != null && cell.IsChecked)
                {
                    newLayoutElements.add(new DynamicLayoutElement__c(Name='DLE-' + (index++), LayoutNumber__c=oppLayout.Name, Type__c='Related List', ChildObjectLabel__c=relList.Label, ChildObject__c=relList.ChildObjectName, RelatedField__c=relList.RelatedFieldName, Sequence__c=relList.Sequence));
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
    
    
    
    public class SalesProcessInfo
    {
        public SalesProcessInfo(String name)
        {
            this.Name = name;
            NewStage = new StageGroupInfo('New');
            DiscoveryStage = new StageGroupInfo('Discovery');
            QualifiedStage = new StageGroupInfo('Qualified');
            ApprovedStage = new StageGroupInfo('Approved');
            FinalStage = new StageGroupInfo('Final');
            ClosedStage = new StageGroupInfo('Closed');
            DeletedStage = new StageGroupInfo('Deleted');
            DefaultStage = new StageGroupInfo(null);
        }
        
        public String Name { get; set; }
        public StageGroupInfo NewStage { get ;set; }
        public StageGroupInfo DiscoveryStage { get ;set; }
        public StageGroupInfo QualifiedStage { get ;set; }
        public StageGroupInfo ApprovedStage { get ;set; }
        public StageGroupInfo FinalStage { get ;set; }
        public StageGroupInfo ClosedStage { get ;set; }
        public StageGroupInfo DeletedStage { get ;set; }
        public StageGroupInfo DefaultStage { get ;set; }
        
        public StageGroupInfo findStage(String label)
        {
            List<StageGroupInfo> allStages = new List<StageGroupInfo> { NewStage, DiscoveryStage, QualifiedStage, ApprovedStage, FinalStage, ClosedStage, DeletedStage, DefaultStage };
            for(StageGroupInfo stage : allStages)
            {
                if(stage.Name == label)
                {
                    return stage;
                }
            }
            return null;
        }
    }
    
    public class StageGroupInfo
    {
        public StageGroupInfo(String name)
        {
            this.Name = name;
            this.IsChecked = false;
        }
        
        public String Name { get; set; }
        public Boolean IsChecked { get; set; }
    }
    
    public abstract class ConfigurableItem 
    {
        public ConfigurableItem()
        {
            NewProcess = new SalesProcessInfo('New');
            FollowOnProcess = new SalesProcessInfo('FollowOn');
            MaintenanceProcess = new SalesProcessInfo('Maintenance');
            DeletedProcess = new SalesProcessInfo('Deleted');
            DefaultProcess = new SalesProcessInfo(null);
        }
        
        public String Label { get ;set; }
        public Integer Sequence { get; set; }
        public SalesProcessInfo NewProcess { get; set; }
        public SalesProcessInfo FollowOnProcess { get; set; }
        public SalesProcessInfo MaintenanceProcess { get; set; }
        public SalesProcessInfo DeletedProcess { get; set; }
        public SalesProcessInfo DefaultProcess { get; set; }
        
        public StageGroupInfo findStage(String salesProcess, String stage)
        {
            SalesProcessInfo process = this.findProcess(salesProcess);
            if(process != null)
            {
                return process.findStage(stage);
            }
            return null;
        }
        
        private SalesProcessInfo findProcess(String label)
        {
            List<SalesProcessInfo> allProcesses = new List<SalesProcessInfo> { NewProcess, FollowOnProcess, MaintenanceProcess, DeletedProcess, DefaultProcess };
            for(SalesProcessInfo process : allProcesses)
            {
                if(process.Name == label)
                {
                    return process;
                }
            }
            return null;
        }
    }
    
    public class ButtonOpt extends ConfigurableItem 
    {
        public String Name { get; set; }

        public ButtonOpt(Integer sequence, String label, String name) 
        {
            super();
            this.Sequence = sequence;
            this.Label = label;
            this.Name = name;
        }
    }

    public class SectionOpt extends ConfigurableItem
    {
        public SectionOpt(Integer sequence, String label, String fieldSetName, String fieldSetId, Integer columns) 
        {
            super();
            this.Sequence = sequence;
            this.Label = label;
            this.FieldSetName = fieldSetName;
            this.Columns = columns;
            this.FieldSetId = fieldSetId;
        }
        
        public Integer Columns { get; set; }
        public String FieldSetName { get; set; }
        public String FieldSetId { get; set; }
    }

    public class RelatedListOpt extends ConfigurableItem
    {
        public RelatedListOpt(Integer sequence, String label, String childObjectName, String relatedFieldName) 
        {
            super();
            this.Sequence = sequence;
            this.Label = label;
            this.ChildObjectName = childObjectName;
            this.RelatedFieldName = relatedFieldName;
        }
        
        public String ChildObjectName { get; set; }
        public String RelatedFieldName { get; set; }
    }
}