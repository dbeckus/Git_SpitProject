/*
 * copy account team member email to POCRequest before updating, inserting.
 */
trigger CopyAccountTeamEmailToPOC on Request__c (before update, before insert) 
{      
    List<AccountTeamMember> managerMembers = new List<AccountTeamMember>();
    List<AccountTeamMember> engineerMembers = new List<AccountTeamMember>();
    
    Map<String, String> opportunityIdsToAccountIds = extractAccountIdsFromRequests();
    classifyAccountTeamMember(opportunityIdsToAccountIds.values(), managerMembers, engineerMembers);
    for(Request__c request : Trigger.new)
    {   
        request.Account_Manager_Email_1__c = null;
        request.Account_Manager_Email_2__c = null;
        request.System_Engineer_Email_1__c = null;
        request.System_Engineer_Email_2__c = null;     
    
        Boolean firstEmailAlreadySet = false;
        for(AccountTeamMember member : managerMembers)
        {
            if(opportunityIdsToAccountIds.get(request.Opportunity__c) == member.AccountId)
            {
                if(!firstEmailAlreadySet)
                {
                    request.Account_Manager_Email_1__c = member.User.Email;
                    firstEmailAlreadySet = true;
                }
                else
                {
                    request.Account_Manager_Email_2__c = member.User.Email;
                    break;
                }         
            }
        }
        
        firstEmailAlreadySet = false;
        for(AccountTeamMember member : engineerMembers)
        {
            if(opportunityIdsToAccountIds.get(request.Opportunity__c) == member.AccountId)
            {
                if(!firstEmailAlreadySet)
                {
                    request.System_Engineer_Email_1__c = member.User.Email;                 
                    firstEmailAlreadySet = true;
                }
                else
                {
                    request.System_Engineer_Email_2__c = member.User.Email;
                    break;
                }
            }
        }        
    }     
    
    private Map<String, String> extractAccountIdsFromRequests()
    {
        Set<Id> opportIds = new Set<Id>();    
        Map<String, String> opportIdToAccountId = new Map<String, String>();
        for(Request__c request : Trigger.new)
        {        
            opportIds.add(request.Opportunity__c);
        }
        for(Opportunity opp : [SELECT Id, AccountId FROM Opportunity WHERE Id in :opportIds])
        {
            opportIdToAccountId.put(opp.Id, opp.AccountId);
        }
        return opportIdToAccountId;
    } 
    
    private void classifyAccountTeamMember(List<Id> accIds, List<AccountTeamMember> managerTM, List<AccountTeamMember> engineerTM )
    {
        for(AccountTeamMember member : [SELECT Id, AccountId, User.Email, TeamMemberRole FROM AccountTeamMember WHERE AccountId in :accIds AND (TeamMemberRole = 'Account Manager' OR TeamMemberRole = 'Systems Engineer')])
        {
            if(member.TeamMemberRole == 'Account Manager')
            {
                managerTM.add(member);            
            }
            else
            {          
                engineerTM.add(member);
            }
        }    
    }
}