/*
 * Controller of page PatchRules
 */
public with sharing class PatchRulesController 
{
    private Long deployDateInternal;
    private static final String AdminId = '005500000045fp1AAA'; //Dennis
    
    public PatchRulesController()
    {
        deployDateInternal = 0;
    }

    public String EmailBody { get; set; }
    
    public String PatchToDisplay
    {
        get
        {
            List<PatchInfo> result = new List<PatchInfo>();
            for(Patch__c patch : [select Id, Name, Active__c, Patch_Name__c, Catchall__c, CSM__c, CSM__r.Name, ISR__c, ISR__r.Name, Owner__c, Owner__r.Name, ProcessingSequence__c, RSM__c, RSM__r.Name, Rule_Logic__c, SE__c, SE__r.Name, Type__c, Timestamp__c, 
              Overlay_1__c,Overlay_2__c,Overlay_1__r.Name,Overlay_2__r.Name,(select Id, ProcessingSequence__c, Type__c, Value__c, Operation__c, Range_Low__c, Range_High__c from Patch_Rules__r order by ProcessingSequence__c)
                         from Patch__c order by ProcessingSequence__c])
            {
                result.add(new PatchInfo(patch));
            }
            return JSON.serialize(result);
        }
    }
    
    public Boolean IsAdmin
    {
        get
        {
            User currentUser = [select Id, Profile.PermissionsAuthorApex from User where Id=:UserInfo.getUserId() limit 1];
            return currentUser.Profile.PermissionsAuthorApex;
        }
    }
    
    public Long LastDeploymentDate
    {
        get
        {
            if(deployDateInternal == 0)
            {
                deployDateInternal = PatchRuleHelper.LastDeploymentDate;
            }
            return deployDateInternal;
        }
    }
    
    public PageReference submitToAdmin()
    {
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setTargetObjectId(AdminId);
        email.setSubject('Patch Submission');
        email.setPlainTextBody('User submitted updates to patches. Please login to review and deploy.\r\n\r\n' + EmailBody);
        email.setSaveAsActivity(false);
        Messaging.sendEmail(new List<Messaging.SingleEmailMessage> { email });
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, 'An email has been sent to system administrator.'));
        return null;
    }
    
    public class PatchInfo 
    {
        public PatchInfo(Patch__c patch)
        {
            this.id = patch.Id;
            this.patchNumber = patch.Name;
            this.name = patch.Patch_Name__c;
            this.active = patch.Active__c;
            this.catchall = patch.Catchall__c;
            this.csmId = patch.CSM__c;
            this.csmName = patch.CSM__r.Name;
            this.isrId = patch.ISR__c;
            this.isrName = patch.ISR__r.Name;
            this.ownerId = patch.Owner__c;
            this.ownerName = patch.Owner__r.Name;
            this.rsmId = patch.RSM__c;
            this.rsmName = patch.RSM__r.Name;
            this.seId = patch.SE__c;
            this.seName = patch.SE__r.Name;
            this.patchOverlay1Name=patch.Overlay_1__r.Name;
            this.patchOverlay2Name=patch.Overlay_2__r.Name;
            this.patchOverlay1Id=patch.Overlay_1__c;
            this.patchOverlay2Id=patch.Overlay_2__c;
            this.ruleLogic = patch.Rule_Logic__c;
            this.type = patch.Type__c;
            this.sequence = (patch.ProcessingSequence__c == null) ? null : patch.ProcessingSequence__c.intValue();
            this.timestamp = (patch.Timestamp__c == null) ? 0 : patch.Timestamp__c.getTime();
            this.rules = new List<PatchRuleInfo>();
            for(PatchCriteriaRule__c rule : patch.Patch_Rules__r)
            {
                this.rules.add(new PatchRuleInfo(rule));
            }
        }
        public String id { get; set; }
        public String patchNumber { get; set; }
        public String name { get; set; }
        public Boolean active { get; set; }
        public Boolean catchall { get; set; }
        public String csmId { get; set; }
        public String csmName { get; set; }
        public String isrId { get; set; }
        public String isrName { get; set; }
        public String ownerId { get; set; }
        public String ownerName { get; set;}
        public String rsmId { get; set; }
        public String rsmName { get; set; }
        public String seId { get; set; }
        public String seName { get; set; }
        public String patchOverlay1Name { get; set; }
        public String patchOverlay2Name { get; set; }
        public String patchOverlay1Id { get; set; }
        public String patchOverlay2Id { get; set; }
        public Integer sequence { get; set; }
        public String ruleLogic { get; set; }
        public String type { get; set; }
        public Long timestamp { get; set; }
        public List<PatchRuleInfo> rules { get; set; }
    }
    
    public class PatchRuleInfo
    {
        public PatchRuleInfo(PatchCriteriaRule__c rule)
        {
            this.id = rule.Id;
            this.sequence = (rule.ProcessingSequence__c == null) ? null : rule.ProcessingSequence__c.intValue();
            this.type = rule.Type__c;
            this.operation = rule.Operation__c;
            this.value = rule.Value__c;
            this.rangeLow = rule.Range_Low__c;
            this.rangeHigh = rule.Range_High__c;
            this.matchList = new Set<String>();
        }

        public String id { get; set; }
        public Integer sequence { get; set; }
        public String type { get; set; }
        public String operation { get; set; }
        public String value { get; set; }
        public String rangeLow { get; set; }
        public String rangeHigh { get; set; }
        public Set<String> matchList { get; set; }
    }
}