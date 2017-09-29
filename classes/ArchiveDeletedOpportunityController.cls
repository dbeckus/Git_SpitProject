/*
 * Controller of page ArchiveDeletedOpportunity
 */
public with sharing class ArchiveDeletedOpportunityController 
{
    private static Id AdminId = '00530000000etJs'; //Curtis Christensen
    private static Id DeletedOppRecordTypeId = '012500000005X67'; //Record type 'Deleted'
    private Opportunity opp;
    
    public ArchiveDeletedOpportunityController(ApexPages.StandardController controller) 
    {
        opp = (Opportunity)controller.getRecord();
        Map<String,Schema.RecordTypeInfo> recordTypes = Schema.SObjectType.Opportunity.getRecordTypeInfosByName();
        if(recordTypes.containsKey('Deleted'))
        {
            DeletedOppRecordTypeId = recordTypes.get('Deleted').getRecordTypeId();
        }
    }
    
    public PageReference archive()
    {
        try
        {
            opp.OwnerId = AdminId;
            opp.RecordTypeId = DeletedOppRecordTypeId;
            opp.StageName = 'Closed Deleted';
            opp.ForecastCategoryName = 'Omitted';
            update opp;
        }
        catch(Exception ex)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Failed to delete opportunity. ' + ex.getMessage()));
            return null;
        }
        Database.delete([select Id from OpportunityTeamMember where OpportunityId=:opp.Id], false);
        Database.delete([select Id from OpportunityShare where OpportunityId=:opp.Id], false);
        
        String retURL = ApexPages.currentPage().getParameters().get('retURL');
        if(String.isNotBlank(retURL))
        {
            return new PageReference(retURL);
        }
        else
        {
            return new PageReference('/006/o');
        }
    }

    @isTest
    static void testArchiveDeletedOpportunityController()
    {
        Opportunity opp = new Opportunity(Name='acme', CloseDate=Date.today(), StageName='Discovery');
        insert opp;
        
        ArchiveDeletedOpportunityController controller = new ArchiveDeletedOpportunityController(new ApexPages.StandardController(opp));
        controller.archive();
        
        opp = [select Id, OwnerId, RecordType.Name from Opportunity where Id=:opp.Id limit 1];
        System.assertEquals('Deleted', opp.RecordType.Name);
    }
    
    
}