public with sharing class OpportunityStageSetupController 
{
    public OpportunityStageSetupController ()
    {
        StageOptions = getAllStages();
    }
    
    public List<String> StageOptions { get; set; }
    public List<StageTransition> StageMatrix { get; set; }
    
    public PageReference init()
    {
        StageMatrix = new List<StageTransition>();
        for(String stage : StageOptions)
        {
            StageTransition transition = new StageTransition(stage);
            for(String stage2 : StageOptions)
            {
                transition.ToStages.add(new StageInfo(stage2));
            }
            StageMatrix.add(transition);
        }
        for(OpportunityStageTransition__c transition : [select FromStage__c, ToStage__c from OpportunityStageTransition__c])
        {
            StageTransition fromStage = findStage(transition.FromStage__c);
            if(fromStage != null)
            {
                StageInfo toStage = fromStage.findStage(transition.ToStage__c);
                if(toStage != null)
                {
                    toStage.IsChecked = true;
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
            delete [select Id from OpportunityStageTransition__c];
            List<OpportunityStageTransition__c> newTransitions = new List<OpportunityStageTransition__c>();
            Integer index = 1;
            for(StageTransition transition : StageMatrix)
            {
                for(StageInfo stage : transition.ToStages)
                {
                    if(stage.IsChecked)
                    {
                        newTransitions.add(new OpportunityStageTransition__c(Name='OST-' + (index++), FromStage__c=transition.StageName, ToStage__c=stage.StageName));
                    }
                }
            }
            insert newTransitions;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, 'Save succeeded.'));
        }
        catch(Exception ex)
        {
            ApexPages.addMessages(ex);
            Database.rollback(sp);
        }
        return null;
    }
    
    private List<String> getAllStages()
    {
        List<String> result = new List<String>();
        for(OpportunityStage stage : [select MasterLabel from OpportunityStage where IsActive=true order by SortOrder])
        {
            result.add(stage.MasterLabel);
        }
        return result;
    }
    
    private StageTransition findStage(String stageName)
    {
        for(StageTransition stage : StageMatrix)
        {
            if(stage.StageName == stageName)
            {
                return stage;
            }
        }
        return null;
    }
    
    public class StageTransition
    {
        public StageTransition(String stage)
        {
            this.StageName = stage;
            this.ToStages = new List<StageInfo>();
        }
        
        public String StageName { get; set; }
        public List<StageInfo> ToStages { get; set; }
        
        public StageInfo findStage(String stageName)
        {
            for(StageInfo stageInfo : ToStages)
            {
                if(stageInfo.StageName == stageName)
                {
                    return stageInfo;
                }
            }
            return null;
        }
    }
    
    public class StageInfo
    {
        public StageInfo(String stage)
        {
            this.StageName = stage;
            this.IsChecked = false;
        }
        
        public String StageName { get; set; }
        public Boolean IsChecked { get; set; }
    }
}