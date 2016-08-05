/*
 * Controller of page Opportunity, OpportunityEdit and OpportunityRelatedList
 */
public with sharing virtual class OpportunityController
{
    private Opportunity opp;
    private String relLayoutNumber = '';
    protected transient RelatedListInfo fullRelatedList;
    protected transient LayoutInfo layout;
    protected String currentSalesProcess = '';
    protected String currentStage = '';
    
    public OpportunityController(ApexPages.standardController sc) 
    {
        try
        {
            sc.addFields(describeFields()); 
            sc.addFields(new List<String> {'RecordType.BusinessProcessId', 'Patch__r.Patch_Name__c', 'StageGrouping__c'});
        }
        catch(Exception ex) { /* Avoid exception in test methods */ }
        
        relLayoutNumber = ApexPages.currentPage().getParameters().get('rlno');
        opp = (Opportunity)sc.getRecord();
        
        if(opp.Id != null) 
        {
            currentSalesProcess = getSalesProcessName(opp.RecordType.BusinessProcessId);
            currentStage = opp.StageGrouping__c;
        }
        else
        {
            String recordTypeId = ApexPages.currentPage().getParameters().get('RecordType');
            String accountId = ApexPages.currentPage().getParameters().get('accid');
            opp.AccountId = accountId;
            List<RecordType> recordTypes = [select Id, BusinessProcessId from RecordType where SObjectType='Opportunity' and Name=:ApexPages.currentPage().getParameters().get('RecordType') limit 1];
            if(recordTypes.size() > 0)
            {
                currentSalesProcess = getSalesProcessName(recordTypes[0].BusinessProcessId);
                opp.RecordTypeId = recordTypeId;
                opp.Probability = 0;
            }
        }
        
        List<User> users = [select Id, OverrideOpportunity__c, Profile.PermissionsModifyAllData from User where Id=:UserInfo.getUserId() limit 1];
        IsAdmin = users[0].Profile.PermissionsModifyAllData;
        IsOverridable = users[0].OverrideOpportunity__c;
    }
    
    public Boolean IsAdmin { get; set; }
    public Boolean IsOverridable { get; set; }
    
    public Boolean IsEditable
    {
        get
        {
            for(ButtonInfo button : DynamicPageLayout.Buttons)
            {
                if(button.Name == 'OpportunityEdit')
                {
                    return true;
                }
            }
            return false;
        }
    }
    
    public DynamicLayout__c LayoutConfig 
    {
        get 
        {
            List<DynamicLayout__c> result = [SELECT Name FROM DynamicLayout__c WHERE Object__c='Opportunity' and SalesProcess__c = :currentSalesProcess and Stage__c=:currentStage limit 1];
            if(result.size() == 0)
            {
                result = [SELECT Name FROM DynamicLayout__c WHERE Object__c='Opportunity' and SalesProcess__c = :currentSalesProcess and Stage__c=null limit 1];
            }
            if(result.size() == 0)
            {
                result = [SELECT Name FROM DynamicLayout__c WHERE Object__c='Opportunity' and SalesProcess__c = null and Stage__c=:currentStage limit 1];
            }
            if(result.size() == 0)
            {
                result = [SELECT Name FROM DynamicLayout__c WHERE Object__c='Opportunity' and SalesProcess__c = null and Stage__c=null limit 1];
            }
            //null value to capture default
            if(result.size() == 0)
            {
                throw new DynamicLayoutException('Default layout configuration is missing. Please contact your system administrator. ['+opp.Id+']');
            }
            return result[0];
        }
    }
    
    public LayoutInfo DynamicPageLayout
    {
        get
        {
            if(layout == null)
            {
                layout = new LayoutInfo();
                DynamicLayout__c config = this.LayoutConfig;
                List<DynamicLayoutElement__c> layoutElements = [select Name, Type__c, ButtonLabel__c, ButtonName__c, SectionName__c, FieldSet__c, SectionColumns__c, ChildObject__c, ChildObjectLabel__c, RelatedField__c from DynamicLayoutElement__c where LayoutNumber__c=:config.Name order by Sequence__c];
                List<String> relatedListNumbers = new List<String>();
                for(DynamicLayoutElement__c element : layoutElements)
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
                        fillRelatedListDetail(relatedList, element.Name, false);
                    }
                }
            }
            return layout;
        }
    }
    
    public RelatedListInfo FullList
    {
        get
        {
            if(fullRelatedList == null)
            {
                List<DynamicLayoutElement__c> layoutElements = [select Name, ChildObject__c, ChildObjectLabel__c, RelatedField__c from DynamicLayoutElement__c where Name = :relLayoutNumber];
                if(!layoutElements.isEmpty())
                {
                    DynamicLayoutElement__c element = layoutElements[0];
                    fullRelatedList = new RelatedListInfo(element.ChildObject__c, element.ChildObjectLabel__c, element.RelatedField__c);
                    fillRelatedListDetail(fullRelatedList, element.Name, true);
                }
            }
            return fullRelatedList;
        }
    }
    
    public String ButtonDefinitions
    {
        get
        {
            List<String> buttons = new List<String>();
            for(ButtonInfo button : DynamicPageLayout.Buttons)
            {
                buttons.add(button.Name);
            }
            buttons.addAll(PredefinedButtons);
            Map<String, CustomAction.ActionResponse> actions = new Map<String, CustomAction.ActionResponse>();
            for(String button : buttons)
            {
                Type actionType = Type.forName('CustomAction', button);
                if(actionType != null)
                {
                    Object action = actionType.newInstance();
                    if(action instanceOf CustomAction.IPageAction)
                    {
                        CustomAction.ActionResponse response = ((CustomAction.IPageAction)action).execute(opp.Id);
                        if(button == 'OpportunityDelete')
                        {
                            response.needConfirm = true;
                        }
                        actions.put(button, response);
                    }
                }
            }
            return JSON.serialize(actions);
        }
    }
    
    public List<String> PredefinedButtons
    { 
        //these are buttons embedded in section
        get { return new List<String> {'OpportunityDefineChannel', 'OpportunityPatchOverride'}; }
    }
    
    public String PredefinedLists 
    { 
        get { return 'OpportunityLineItem, OpportunityFieldHistory, OpportunityHistory, OpenActivity, Quote__c, SBQQ__Quote__c, ActivityHistory, Request__c, NoteAndAttachment, OpportunityContactRole, OpportunityCompetitor, Purchase_Order__c'; }
    }
    
    public String PredefinedReadOnlyFields
    {
        get { return 'OwnerId, CreatedById, CreatedDate, LastModifiedById, LastModifiedDate, RecordTypeId, '; }
    }
    
    public String getCurrentSalesProcess()
    {
        return currentSalesProcess;
    }
    
    public String getCurrentStage()
    {
        List<Opportunity> currentOpp = [select Id, StageName from Opportunity where Id=:opp.Id limit 1];
        if(currentOpp.size() > 0)
        {
            return currentOpp[0].StageName;
        }
        return null;
    }
    
    public String Stage2Probability
    {
        get
        {
            String currentStage = getCurrentStage();  //query live data in case previous update failure makes the stage dirty
            
            List<String> allowedStages = new List<String>();
            if(String.isNotblank(currentStage))
            {
                allowedStages.add(currentStage);
            }
            for(OpportunityStageTransition__c stage : [select ToStage__c from OpportunityStageTransition__c where FromStage__c=:currentStage])
            {
                allowedStages.add(stage.ToStage__c);
            }
            List<StageInfo> result = new List<StageInfo>();
            for(OpportunityStage stage : [SELECT MasterLabel, DefaultProbability, ForecastCategoryName, IsClosed FROM OpportunityStage where MasterLabel in :allowedStages ORDER BY SortOrder])
            {
                List<String> availableCategories = new List<String>{stage.ForecastCategoryName};
                if(stage.ForecastCategoryName == 'Closed')
                {
                    availableCategories.add('Omitted'); 
                }
                else if(stage.ForecastCategoryName == 'Omitted')
                {
                }
                else
                {
                    availableCategories.add('Pipeline'); 
                    availableCategories.add('Best Case'); 
                    availableCategories.add('Commit'); 
                    availableCategories.add('Omitted'); 
                }
                result.add(new StageInfo(stage.MasterLabel, stage.DefaultProbability, stage.ForecastCategoryName, availableCategories));
            }
            Boolean includeCurrentStage = false;
            for(StageInfo stageInfo : result)
            {
                if(stageInfo.stage == currentStage)
                {
                    includeCurrentStage = true;
                    break;
                }
            }
            if(!includeCurrentStage)
            {
                result.add(new StageInfo(currentStage, null, null, null));
            }
            return JSON.serialize(result);
        }
    }
    
    public PageReference deleteChildObject()
    {
        String objToDelete = ApexPages.currentPage().getParameters().get('delId');
        if(String.isNotBlank(objToDelete))
        {
            try
            {
                Database.delete(objToDelete, false);
            }
            catch(Exception ex)
            {
                ApexPages.addMessages(ex);
            }
        }
        return null;
    }
    
    public PageReference checkOverrideability()
    {
        if(IsOverridable)
        {
            return null;
        }
        else
        {
            String currentPage = ApexPages.currentPage().getUrl();
            Map<String, String> currentParameters = ApexPages.currentPage().getParameters();
            currentParameters.put('nooverride', '1');
            currentParameters.remove('id');
            currentParameters.remove('sfdc.override');
            PageReference result = null;
            if(currentPage.toLowercase().contains('/opportunityedit'))
            {
                result = new PageReference('/' + opp.Id + '/e');
            }
            else
            {
                result = new PageReference('/' + opp.Id);
            }
            result.getParameters().putAll(currentParameters);
            result.setRedirect(true);
            return result;
        }
    }
    
    public PageReference save()
    {
        try
        {
            upsert opp;
            PageReference ref = new PageReference('/apex/Opportunity?id=' + opp.Id);
            ref.setRedirect(true);
            return ref;
        }
        catch(DMLException ex)
        {
            ApexPages.addMessages(ex);
            return Page.OpportunityEdit;
        }
    }
    
    @RemoteAction
    public static CustomAction.ActionResponse respondButtonClick(String buttonName, String oppId)
    {
        Type actionType = Type.forName('CustomAction', buttonName);
        if(actionType != null)
        {
            Object action = actionType.newInstance();
            if(action instanceOf CustomAction.IServerAction)
            {
                return ((CustomAction.IServerAction)action).execute(oppId);
            }
        }
        CustomAction.ActionResponse response = new CustomAction.ActionResponse();
        response.message = 'Button ' + buttonName + ' is not defined';
        return response;
    }
    
    private String getSalesProcessName(Id salesProcessId)
    {
        List<BusinessProcess> processes = [SELECT Name FROM BusinessProcess WHERE Id = :salesProcessId limit 1];
        return (processes.size() > 0) ? processes[0].Name : '';
    }
    
    private List<String> describeFields()
    {
        Map<String, Schema.SObjectField> fields = Schema.SObjectType.Opportunity.fields.getMap();
        List<String> result = new List<String>();
        result.addAll(fields.keyset());
        return result;
    }
        
    private void fillRelatedListDetail(RelatedListInfo relatedList, String layoutNumber, Boolean isFullList)
    {
        relatedList.LayoutNumber = layoutNumber;
        List<DynamicRelatedListElement__c> relatedListConfigs = [select ButtonLabel__c, ButtonName__c, FieldName__c, DescendingOrder__c, Type__c from DynamicRelatedListElement__c where LayoutNumber__c=:layoutNumber order by Sequence__c];
        for(DynamicRelatedListElement__c element : relatedListConfigs)
        {
            if(element.Type__c == 'Button')
            {
                relatedList.Buttons.add(new ButtonInfo(element.ButtonLabel__c, element.ButtonName__c));
            }
            else if(element.Type__c == 'Field')
            {
                relatedList.Fields.add(element.FieldName__c);
            }
            else if(element.Type__c == 'OrderBy' || element.Type__c == 'Order By')
            {
                relatedList.OrderBy = element.FieldName__c;
                relatedList.DescendingOrder = element.DescendingOrder__c;
            }
            else if(element.Type__c == 'Limit')
            {
                //relatedList.LimitNumber = 
            }
        }
        if(isFullList) 
        {
            relatedList.LimitNumber = 900;
        }
        String soql = relatedList.constructSoql(opp);
        //relatedList.Records = Database.query(soql);
    }

    public class LayoutInfo
    {
        public LayoutInfo()
        {
            Sections = new List<SectionInfo>();
            Buttons = new List<ButtonInfo>();
            RelatedLists = new List<RelatedListInfo>();
        }
        
        public List<SectionInfo> Sections { get; set; }
        public List<ButtonInfo> Buttons { get; set; }
        public List<RelatedListInfo> RelatedLists { get; set; }
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
        
        public String Name { get; set; }
        public String FieldSet { get; set; }
        public Integer Columns { get; set; }
    }
    
    public class ButtonInfo
    {
        public ButtonInfo(String label, String name)
        {
            this.Label = label;
            this.Name = name;
        }
        
        public String Label { get; set; }
        public String Name { get; set; }
    }
    
    public class RelatedListInfo
    {
        public RelatedListInfo(String objName, String objLabel, String relatedField)
        {
            this.ObjectName = objName;
            this.ObjectLabel = objLabel;
            this.RelatedField = relatedField;
            this.Buttons = new List<ButtonInfo>();
            this.Fields = new List<String>();
            this.OrderBy = 'CreatedDate';
            this.LimitNumber = 5;
        }
        
        public String LayoutNumber { get; set; }
        public String ObjectName { get; set; }
        public String ObjectLabel { get; set; }
        public String RelatedField { get; set; }
        public List<String> Fields { get; set; }
        public List<sObject> Records { get; set; }
        public String OrderBy { get; set; }
        public Boolean DescendingOrder { get; set; }
        public Integer LimitNumber { get; set; }
        public List<ButtonInfo> Buttons { get; set; }
        
        public String constructSoql(Opportunity opp)
        {
            String soql = 'select ';
            if(Fields == null || Fields.size() == 0)
            {
                Fields = new List<String> { 'Id' };
            }
            for(String field : Fields)
            {
                soql += field + ',';
            }
            soql = soql.removeEnd(',');
            soql += ' from ' + ObjectName;
            
            if(ObjectName == 'Case' && opp.AccountId != null)
            {
                soql += ' where AccountId=\'' + opp.AccountId + '\'';
            }
            else if(opp.Id != null && RelatedField != null)
            {
                soql += ' where ' + RelatedField + '=\'' + opp.Id + '\'';
            }
            
            if(OrderBy != null) {
                soql += ' order by ' + OrderBy;
            }
            if(LimitNumber != null && LimitNumber >= 0) {
                soql += ' limit ' + (LimitNumber + 1);
            }
            return soql;
        }
    }
    
    public class StageInfo
    {
        public StageInfo(String stage, Decimal probability, String forecastCategory, List<String> availableForecastCategories)
        {
            this.stage = stage;
            this.probability = probability;
            this.forecastCategory = forecastCategory;
            this.availableForecastCategories = availableForecastCategories;
        }
        
        public String stage { get; set; }
        public Decimal probability { get; set; }
        public String forecastCategory { get; set; }
        public List<String> availableForecastCategories { get; set; }
    }
    
    public class DynamicLayoutException extends Exception {}
}