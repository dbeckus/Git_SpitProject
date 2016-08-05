public class TeamMemberCheck implements Database.batchable<sObject>, Database.Stateful
{
    private Integer totalCount = 0;
    
    public Database.QueryLocator start(Database.BatchableContext BC)
    {
        return Database.getQueryLocator([select Id, Patch__c from Account where Patch__c != null]);
    }
    
    public void execute(Database.BatchableContext BC, List<sObject> scope)
    {
        List<sObject> teamMembers = PatchRuleHelper.getPatchSharings(scope);
        List<AccountTeamMember> oldTeamMembers = [select Id, AccountId, UserId, TeamMemberRole from AccountTeamMember where AccountId in :scope];
        List<Id> recordsNeedAssign = new List<Id>();
        for(sObject obj : scope)
        {
            recordsNeedAssign.add(obj.Id);
        }
        if(!isSameTeam(oldTeamMembers, (List<AccountTeamMember>)teamMembers))
        {
            totalCount++;
            PatchRuleHelper.assignTeamMembers(recordsNeedAssign);
        }
    }
    
    public void finish(Database.BatchableContext BC)
    {
        insert new ErrorLog__c(Subject__c='Error Opportunity', Message__c=String.valueOf(totalCount));
    }
    
    private Boolean isSameTeam(List<AccountTeamMember> oldTeams, List<AccountTeamMember> newTeams)
    {
        for(AccountTeamMember oldTeam : oldTeams)
        {
            Boolean found = false;
            for(AccountTeamMember newTeam : newTeams)
            {
                if(newTeam.AccountId == oldTeam.AccountId && newTeam.UserId == oldTeam.UserId && newTeam.TeamMemberRole == oldteam.TeamMemberRole)
                {
                    found = true;
                    break;
                }
            }
            if(!found)
            {
                return false;
            }
        }
        for(AccountTeamMember newTeam : newTeams)
        {
            Boolean found = false;
            for(AccountTeamMember oldTeam : oldTeams)
            {
                if(newTeam.AccountId == oldTeam.AccountId && newTeam.UserId == oldTeam.UserId && newTeam.TeamMemberRole == oldteam.TeamMemberRole)
                {
                    found = true;
                    break;
                }
            }
            if(!found)
            {
                return false;
            }
        }
        return true;
    }
    
    @isTest
    static void test()
    {
        Account acc = new Account(Name='acme');
        insert acc;
        AccountTeamMember member = new AccountTeamMember(AccountId=acc.Id, UserId=UserInfo.getUserId(), TeammemberRole='Account Manager');
        insert member;
        Test.startTest();
        Database.executeBatch(new TeamMemberCheck(), 1);
        Test.stopTest();
    }
}