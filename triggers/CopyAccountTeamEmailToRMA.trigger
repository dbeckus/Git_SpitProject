/*
 * copy account team member email to RMA before updating, inserting.
 */
trigger CopyAccountTeamEmailToRMA on RMA__c (before update, before insert) 
{
    List<AccountTeamMember> managerMembers = new List<AccountTeamMember>();
    List<AccountTeamMember> engineerMembers = new List<AccountTeamMember>();
    
    Set<Id> accountIds = extractAccountIdsFromRMAs(Trigger.new);       
    classifyAccountTeamMember(accountIds, managerMembers, engineerMembers);
    for(RMA__c rma : Trigger.new)
    {   
        rma.Account_Manager_Email_1__c = null;
        rma.Account_Manager_Email_2__c = null;
        rma.System_Engineer_Email_1__c = null;
        rma.System_Engineer_Email_2__c = null; 
                    
        Boolean firstEmailAlreadySet = false;
        for(AccountTeamMember member : managerMembers)
        {
            if(rma.Account__c == member.AccountId)
            {
                if(!firstEmailAlreadySet)
                {
                    rma.Account_Manager_Email_1__c = member.User.Email;
                    firstEmailAlreadySet = true;
                }
                else //firstEmailAlreadySet = true
                {
                    rma.Account_Manager_Email_2__c = member.User.Email;
                    break;
                }          
            }
        }
        
        firstEmailAlreadySet = false;
        for(AccountTeamMember member : engineerMembers)
        {
            if(rma.Account__c == member.AccountId)
            {
                if(!firstEmailAlreadySet)
                {
                    rma.System_Engineer_Email_1__c = member.User.Email;          
                    firstEmailAlreadySet = true;
                }
                else //firstEmailAlreadySet = true;
                {
                    rma.System_Engineer_Email_2__c = member.User.Email;
                    break;
                }
            }
        }        
    }     

    private Set<Id> extractAccountIdsFromRMAs(List<RMA__c> rmas)
    {
        Set<Id> ids = new Set<Id>();
        for(RMA__c rma : rmas)
        {        
            ids.add(rma.Account__c);
        }   
        return ids;
    } 
    
    private void classifyAccountTeamMember(Set<Id> accIds, List<AccountTeamMember> managerTM, List<AccountTeamMember> engineerTM )
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