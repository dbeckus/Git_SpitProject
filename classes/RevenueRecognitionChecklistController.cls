/**
 * A controller of page RevenueRecognitionChecklist that update opportunity revenue recognition checklist.
 */
public class RevenueRecognitionChecklistController
{
    private Opportunity opp;

    public RevenueRecognitionChecklistController()
    {
        String oppId = ApexPages.currentPage().getParameters().get('id');
        List<opportunity> opps = [Select Id, Name,Owner.ManagerId, AccountId, OwnerId, Finance_Id__c, Signed_By__c, Signed_At__c, Signature_of_Opportunity_Owner__c, ProdRoadmap__c, RightOfReturn__c, Rev_Rec_Reminders__c, Other_Promises_Made__c, 
                                                    Other_Promises_Made_Diclosed__c, Installation_Notes__c, Installation_Date__c, InstallationExpectations__c, Future_Features_Expected__c, Future_Features_Expected_Specifics__c, Finance_Reviewed__c,
                                                    Finance_Review_Notes__c, Finance_Released_At__c, Describe_Contingencies__c, Contingencies_of_Sale__c,   TrainingOrWANStartExpectations__c, DescribeExpectations__c, UnitsGoingAbroad__c, Is_Foreign_Governor_Entity__c From Opportunity Where id=:oppId];
        
        if(opps.size() > 0)
        {
            opp = opps[0]; 
            checkUserAccessibility();
            rrChecklist = opp2Checklist(opp);
            oppInfo = opp;       
        }  
        else
        {
            isAccessible = false;
        }  
    }
    
    public PageReference save()
    {
        if(opp != null)
        {
            if(!isFinaceUser() && rrChecklist.Finance_Reviewed__c)//only when current user in finance team group, he is accessible to the revenue checklist fields.
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING,  'Only the finance users can save the finance reviewed box as checked'));
            }
            else
            {
                checklist2Opp(rrChecklist, opp);
                Savepoint sp = Database.setSavepoint();
                if(rrChecklist.Finance_Reviewed__c)
                {
                    //Updates the Purchase Orders if this opportunity is signed off by finance. sets a flag for workflow to trigger actions on
            
                    Purchase_Order__c[] purchaseOrders = [select OppReleased__c from Purchase_Order__c where Opportunity__c = :opp.Id];
                    if(!purchaseOrders.isEmpty())
                    {
                        for(Purchase_Order__c purchaseOrder : purchaseOrders)
                        {
                            purchaseOrder.OppReleased__c = true;
                        }
                        try
                        {
                            update purchaseOrders;
                        }
                        catch(DMLexception ex)
                        {
                            Database.rollback(sp);
                            ApexPages.addMessages(ex);
                            return null;
                        }
                    }
                }
                try
                {
                    update opp;
                    isSaved = true;
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, '<h1>Data has been saved.</h1><script type="text/javascript">setTimeout("window.opener.location=window.opener.location;window.close()",2000);</script>'));
                }
                catch(DMLexception ex)
                {
                    Database.rollback(sp);
                    ApexPages.addMessages(ex);
                }
            }
        }
        
        return null;
    }
    
    public boolean isAccessible { get; set; }  //only when current user is opp owner or who in finance team group, he is accessible to the revenue checklist fields.
    public boolean isSaved { get; set; }  
    public RevenueRecognitionChecklist__c rrChecklist { get; set; }
    public Opportunity oppInfo { get; set; }
    
    private void checkUserAccessibility()
    {
        String userId = UserInfo.getUserId();
        //only when current user is opp owner or who in finance team group, he is accessible to the revenue checklist fields.
        Set<String> accessibleUsers = finaceUser();
        isAccessible = (userId.equals(opp.OwnerId) || userId.equals(opp.Owner.ManagerId) || accessibleUsers.contains(userId));
    }
    
    private Boolean isFinaceUser()
    {
        String userId = UserInfo.getUserId();
        Set<String> accessibleUsers = finaceUser();
        return  accessibleUsers.contains(userId);
    }
    
    private Set<String> finaceUser()
    {
        Set<String> accessibleUsers  = new Set<String>();
        String groupName = 'Finance Team'; 
        List<Group> groupList = [Select Id from Group Where Name =:groupName limit 1];
         if(groupList.size() > 0)
        {
            String groupId = groupList[0].Id;
            accessibleUsers = queryGroupMember(groupId);
        }
        return  accessibleUsers;
    }
    
    private Set<String> queryGroupMember(String groupId)
    {
        Set<String> result = new Set<String>();
        
        List<GroupMember> groupMemberList = [Select UserOrGroupId from GroupMember Where GroupId =:groupId];

        if(groupMemberList.size() > 0)
        {           
            for(GroupMember groupMemberInfo : groupMemberList )
            {
                String userOrGroupId = groupMemberInfo.UserOrGroupId;
                if(userOrGroupId.startsWith('005'))
                {
                    //is a user
                    result.add(userOrGroupId);
                }
                else if(userOrGroupId.startswith('00G'))
                {
                    //is a group
                    result.addAll(queryGroupMember(userOrGroupId));
                }
            }
        }
        return result;
    }
    
    private RevenueRecognitionChecklist__c opp2Checklist(Opportunity opp)
    {
        RevenueRecognitionChecklist__c rrChecklist = new RevenueRecognitionChecklist__c();
        rrChecklist.Signed_By__c = opp.Signed_By__c;
        rrChecklist.Signed_At__c = opp.Signed_At__c;
        rrChecklist.Signature_of_Opportunity_Owner__c = opp.Signature_of_Opportunity_Owner__c;
        rrChecklist.Roadmap_Information__c = opp.ProdRoadmap__c;
        rrChecklist.RightOfReturn__c = opp.RightOfReturn__c;
        rrChecklist.Reminders__c = opp.Rev_Rec_Reminders__c;
        rrChecklist.Other_Promises_Made__c = opp.Other_Promises_Made__c;
        rrChecklist.Other_Promises_Made_Disclosure__c = opp.Other_Promises_Made_Diclosed__c;
        rrChecklist.Installation_Notes__c = opp.Installation_Notes__c;
        rrChecklist.Installation_Date__c = opp.Installation_Date__c;
        rrChecklist.InstallationExpectations__c = opp.InstallationExpectations__c;
        rrChecklist.Future_Features_Expected__c = opp.Future_Features_Expected__c;
        rrChecklist.Future_Features_Expected_Specifics__c = opp.Future_Features_Expected_Specifics__c;
        rrChecklist.Finance_Reviewed__c = opp.Finance_Reviewed__c;
        rrChecklist.Finance_Review_Notes__c = opp.Finance_Review_Notes__c;
        rrChecklist.Finance_Released_At__c = opp.Finance_Released_At__c;
        rrChecklist.Describe_Contingencies__c = opp.Describe_Contingencies__c;
        rrChecklist.Contingencies_of_Sale__c = opp.Contingencies_of_Sale__c;
        rrChecklist.TrainingOrWANStartExpectations__c = opp.TrainingOrWANStartExpectations__c;
        rrChecklist.DescribeExpectations__c = opp.DescribeExpectations__c;
        rrChecklist.UnitsGoingAbroad__c = opp.UnitsGoingAbroad__c;
        rrChecklist.Is_Foreign_Governor_Entity__c = opp.Is_Foreign_Governor_Entity__c;
        return rrChecklist;
    }
    
    private void checklist2Opp(RevenueRecognitionChecklist__c checklist, Opportunity opp)
    {
        //opp.Signed_By__c = checklist.Signed_By__c;
        //opp.Signed_At__c = checklist.Signed_At__c;
        opp.Signature_of_Opportunity_Owner__c = checklist.Signature_of_Opportunity_Owner__c;
        opp.ProdRoadmap__c = checklist.Roadmap_Information__c;
        opp.RightOfReturn__c = checklist.RightOfReturn__c;
        opp.Other_Promises_Made__c = checklist.Other_Promises_Made__c;
        opp.Other_Promises_Made_Diclosed__c = (checklist.Other_Promises_Made__c == 'Yes') ? checklist.Other_Promises_Made_Disclosure__c : null;
        opp.InstallationExpectations__c = checklist.InstallationExpectations__c;
        opp.Installation_Notes__c = (checklist.InstallationExpectations__c == 'Yes') ? checklist.Installation_Notes__c : null;
        opp.Installation_Date__c = (checklist.InstallationExpectations__c == 'Yes') ? checklist.Installation_Date__c : null;       
        opp.Future_Features_Expected__c = checklist.Future_Features_Expected__c;
        opp.Future_Features_Expected_Specifics__c = (checklist.Future_Features_Expected__c == 'Yes') ? checklist.Future_Features_Expected_Specifics__c : null;
        opp.Finance_Reviewed__c = checklist.Finance_Reviewed__c;
        opp.Finance_Review_Notes__c = checklist.Finance_Review_Notes__c;
        //opp.Finance_Released_At__c = checklist.Finance_Released_At__c;
        opp.Contingencies_of_Sale__c = checklist.Contingencies_of_Sale__c;
        opp.Describe_Contingencies__c = (checklist.Contingencies_of_Sale__c == 'Yes') ? checklist.Describe_Contingencies__c : null; 
        opp.TrainingOrWANStartExpectations__c = checklist.TrainingOrWANStartExpectations__c;
        opp.DescribeExpectations__c = (checklist.TrainingOrWANStartExpectations__c == 'Yes') ? checklist.DescribeExpectations__c : null;
        opp.UnitsGoingAbroad__c = checklist.UnitsGoingAbroad__c;  
        opp.Is_Foreign_Governor_Entity__c = checklist.Is_Foreign_Governor_Entity__c;
    }
    
    @isTest
    static void testSave()
    {   
        Account acc = new Account(name = 'acc1');       
        insert acc;
        User user=[select Id from User where IsActive=true limit 1];       
        List<Opportunity> oppList = new List<Opportunity>();
               
        for(Integer i = 0; i < 2; i++)
        {
            Opportunity opp = new Opportunity(); 
            opp.Name = 'opp' + i;
            opp.CloseDate = Date.today();
            opp.StageName = 'Discovery';
            opp.Opportunity_Source__c = 'Dell';
            opp.Type = 'Follow on Business';
            opp.AccountId = acc.Id;
            opp.InstallationExpectations__c = 'Yes';
            opp.Other_Promises_Made__c = 'Yes';
            opp.Future_Features_Expected__c = 'Yes';
            opp.Contingencies_of_Sale__c = 'Yes';
            opp.TrainingOrWANStartExpectations__c = 'Yes';
            opp.Finance_Reviewed__c = true;
            opp.Deal_Type__c = 'Replication';
            if(i == 1)
            {
                opp.InstallationExpectations__c = 'No';
                opp.Other_Promises_Made__c = 'No';
                opp.Future_Features_Expected__c = 'No';
                opp.Contingencies_of_Sale__c = 'No';
                opp.TrainingOrWANStartExpectations__c = 'No';
                opp.Finance_Reviewed__c = false;
                opp.OwnerId = user.Id;
            }
            
            oppList.add(opp);
        }
        
        insert oppList;
        
        for(Opportunity oppInfo : oppList)
        {
            String oppId = oppInfo.Id;
            PageReference page = new PageReference('/apex/revenuerecogniztionchecklist?id=' + oppId);  
            Test.setCurrentPage(page);
            RevenueRecognitionChecklistController rrcc = new RevenueRecognitionChecklistController();
            system.assertEquals(rrcc.save(), null); 
        } 
    }
}