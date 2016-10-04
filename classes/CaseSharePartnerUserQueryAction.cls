public class CaseSharePartnerUserQueryAction {
    @InvocableMethod
    public static void ShareCaseWithPartnerManager(List<Id> caseIds)
    {
        System.debug('Case Ids');
        Map<Id,Id>setUserIds= new Map<Id,Id>();
        List<CaseShare> caseShares = new List<CaseShare>();
        if(caseIds!=null && caseIds.size()>0)
        {
            
            List<Case> lstCases=[Select Id,Contact.Account.Name from Case where Id in: caseIds and ContactId in (Select ContactId from User where ProfileId='00e50000000vwju')];
            if(lstCases!=null && lstCases.size()>0)
            {
                for(Case item: lstCases)
                {
                    string partnerAcctName= item.Contact.Account.Name;
                    if(partnerAcctName!='')
                    {
                        //partnerAcctName=partnerAcctName.replaceAll( '-', ' ');
                        //partnerAcctName= partnerAcctName.replaceAll( '\\s+', '');
                        string portalRoleName= partnerAcctName+'Partner Manager';
                        
                        //portalRoleName=portalRoleName+'%';
                        //System.debug('partnerAcctName'+partnerAcctName);
                        System.debug('portalRoleName'+portalRoleName);
                        List<Group> lstGroup=[SELECT Id,Name,DeveloperName,Type FROM Group where RelatedId in(Select Id from UserRole where Name=:portalRoleName) and Type='Role'];
                        System.debug('lstGroup'+lstGroup);
                        if(lstGroup!=null && lstGroup.size()>0) 
                        {
                            setUserIds.put(item.Id,lstGroup[0].Id);
                        }
                    }
                }
                
                //Delete the previous manager role 
                List<CaseShare> delcaseShare= new List<CaseShare>();
                delcaseShare=[Select Id from CaseShare where caseId in: caseIds and RowCause='Manual' and UserOrGroupId in(Select Id from Group where DeveloperName like '%PartnerManager' and Type='Role')];
                if(delCaseShare.size()>0)
                {
                    delete delcaseShare;
                }
                
                
                if(setUserIds.size()>0)
                {
                    for (Id caseId : setUserIds.keyset())
                    {
                        CaseShare item = new CaseShare(CaseId=caseId, UserOrGroupId=setUserIds.get(caseId), CaseAccessLevel='Edit');
                        caseShares.add(item);
                    }
                    if(caseShares.size()>0)
                    {
                        insert caseShares;
                    }
                }
            }
            
        }
        
    }
}