/*
* Includes helper methods for triggers and classes related to Patch Assignment and Patch Matching
*/
public class PatchRuleHelper
{
    public static List<Id> leadsNeedAssignment;
    public static Patch__c SPCatchAllPatch;
    public static Map<Id, List<Id>> overlayHolder; //this map temporarily holds the result after patch match. because assignPatch and assignTeamMember are in different method call. assignPatch puts result to the map so that assignTeamMember will read it
    
    static
    {
        leadsNeedAssignment = new List<Id>();
        overlayHolder = new Map<Id, List<Id>>();
        SPCatchAllPatch=new Patch__c();
    }
    
    @future
    public static void willAssignPatch(List<Id> recordIds)
    {
        assignPatch(recordIds);
    }
    
    public static void assignPatch(List<Id> recordIds)
    {
        if(recordIds == null || recordIds.size() == 0)
        {
            return;
        }
        List<sObject> objs = getSObjects(recordIds);
        assignPatches(objs);
        if(objs.size() > 0)
        {
            Database.SaveResult[] saveResults = Database.update(objs, false);
            SilverPeakUtils.logDatabaseError(objs, saveResults);
        }
    }
    
    public static void assignPatches(List<sObject> objs)
    {
        Map<Id, Patch__c> patches = new Map<Id, Patch__c>();
        for(Patch__c patch : [select Id, Name,Patch_Name__c, Catchall__c, Type__c, Owner__c, Owner__r.GEO__c, RSM__c,RSS__c, CSM__c, SE__c, ISR__c, Overlay_1__c, Overlay_2__c, Active__c, Overlay__c, FCMM__c from Patch__c])
        {
            patches.put(patch.Id, patch);
            if(patch.Name=='P-603')
            {
                SPCatchAllPatch=patch;
                System.debug('SPCatchAllPatch'+SPCatchAllPatch);
            }
        }
        Map<Id, String> ownerGEO = new Map<Id, String>();
        for(sObject obj : objs)
        {
            Id patchId = null;
            if(obj instanceOf Lead && (Boolean)obj.get('Patch_Locked__c'))
            {
                //if a lead is locked, we keep the patch member up to date, leave the patch unchanged
                patchId = (Id)obj.get('Patch__c');
            }
            else
            {
                PatchRuleEngineBase.Target target = getTarget(obj);
                PatchRuleEngine engine = new PatchRuleEngine();
                PatchRuleEngineBase.Match match = engine.match(target);
                if(match != null)
                {
                    patchId = match.PatchId;
                    overlayHolder.put(obj.Id, match.OverlayMatches);
                }
            }
            Patch__c patch = patches.get(patchId);
            assignPatch(obj, patch);
            ownerGEO.put((Id)obj.get('OwnerId'), null);
        }
        for(User usr : [select Id, GEO_Region__c from User where Id in :ownerGEO.keyset()])
        {
            ownerGEO.put(usr.Id, usr.GEO_Region__c);
        }
        for(sObject obj : objs)
        {
            if(obj instanceOf Lead)
            {
                Lead ld = (Lead)obj;
                if(ownerGEO.get(ld.OwnerId) != null)
                {
                    ld.GEO__c = ownerGEO.get(ld.OwnerId);
                }
            }
        }
    }
    
    public static void assignPatch(sObject obj, Patch__c patch)
    {
        Boolean locked = (Boolean)obj.get('Patch_Locked__c');
        if(patch != null)
        {
            if(obj instanceOf Lead)
            {
                Lead ld = (Lead)obj;
                if(ld.ECSP__c)
                {
                    if(patch.Type__c!='Named Accounts')
                    {
                        patch=SPCatchAllPatch;
                    }
                }
                ld.Patch__c = patch.Id;
                ld.CSM__c = patch.CSM__c;
                ld.ISR__c = patch.ISR__c;
                ld.Patch_Owner__c = patch.Owner__c;
                ld.RSM__c = patch.RSM__c;
                ld.SE__c = patch.SE__c;
                
                if(patch.ISR__c != null)
                {
                    ld.OwnerId = patch.ISR__c;
                }
                if(ld.LeadSource == 'Deal Registration')
                {
                    Map<String, Schema.RecordTypeInfo> leadRecordTypes = Schema.SObjectType.Lead.getRecordTypeInfosByName();
                    if(leadRecordTypes.get('Deal Registration') != null && leadRecordTypes.get('Deal Registration').getRecordTypeId() == ld.RecordTypeId)
                    {
                        //for the deal registration process, NAM goes to CSM, non-NAM goes to RSM
                        if(patch.ISR__c != null && (patch.Owner__r.GEO__c == null || patch.Owner__r.GEO__c.contains('NAM') || patch.Owner__r.GEO__c.contains('GAM')))
                        {
                            ld.OwnerId = patch.ISR__c;
                        }
                        else if(patch.RSM__c != null)
                        {
                            ld.OwnerId = patch.RSM__c;
                        }
                    }
                }
                
            }
            else if(obj instanceOf Account)
            {
                if(locked == true)
                {
                    throw new SilverPeakException('Patch is locked, and cannot be reassigned.');
                }
                Account acc = (Account)obj;
                if(acc.ECSP__c)
                {
                    if(patch.Type__c!='Named Accounts')
                    {
                        patch=SPCatchAllPatch;
                    }
                }
                obj.put('Patch__c', patch.Id);
                /*
if(patch.RSM__c != null)
{
obj.put('OwnerId', patch.RSM__c);
}
String geo = obj.get('GEO_Supported__c') == null ? '' : (String)obj.get('GEO_Supported__c');
if(patch.CSM__c != null && obj.get('Type') == 'Partner' && !geo.contains('APAC') && !geo.contains('EMEA'))
{
obj.put('OwnerId', patch.CSM__c);
}
*/
            }
            else if(obj instanceOf Opportunity)
            {
                if(locked == true)
                {
                    throw new SilverPeakException('Patch is locked, and cannot be reassigned.');
                }
                Opportunity opportunity = (Opportunity)obj;
                if(opportunity.Account.ECSP__c && patch.Type__c!='Named Accounts')
                {
                    patch=SPCatchAllPatch;
                }
                opportunity.Patch__c = patch.Id;
                opportunity.Bypassing_Validation__c = true;
                opportunity.Patch_Locked__c = opportunity.Account.Patch_Locked__c;
                /*
if(patch.RSM__c != null && !opportunity.IsClosed)
{
opportunity.OwnerId = patch.RSM__c;
opportunity.Technical_Responsible__c = patch.SE__c;
}

*/
            }
        }
        else
        {
            if(obj instanceOf Lead)
            {
                Lead ld = (Lead)obj;
                ld.Patch__c = ld.CSM__c = ld.ISR__c = ld.Patch_Owner__c = ld.RSM__c = ld.SE__c = null;
            }
            else if(obj instanceOf Account || obj instanceOf Opportunity)
            {
                obj.put('Patch__c', null);
            }
        }
        obj.put('Trigger_Assignment__c', false);
    }
    
    public static List<sObject> getPatchSharings(List<sObject> objs)
    {
        Set<Id> patchIds = new Set<Id>();
        for(sObject obj : objs)
        {
            patchIds.add((Id)obj.get('Patch__c'));
        }
        for(Id tempId : OverlayHolder.keyset())
        {
            List<Id> overlayPatches = OverlayHolder.get(tempId);
            patchIds.addAll(overlayPatches);
        }
        
         Map<Id, Patch__c> patchMap = new Map<Id, Patch__c>([select Id, CSM__c, SE__c, ISR__c, RSS__c,RSM__c, Overlay_1__c, Overlay_2__c, Owner__c, Overlay__c, FCMM__c from Patch__c where Id in :patchIds]);
        
        List<sObject> result = new List<sObject>();
        for(sObject obj : objs)
        {
            Id patchId = (Id)obj.get('Patch__c');
            if(patchId != null && patchMap.containsKey(patchId))
            {
                result.addAll(getPatchSharing(obj, patchMap.get(patchId)));
            }
            List<Id> overlayPatches = OverlayHolder.get(obj.Id);
            if(overlayPatches != null && overlayPatches.size() > 0)
            {
                for(Id overlayPatchId : overlayPatches)
                {
                    result.addAll(getPatchSharing(obj, patchMap.get(overlayPatchId)));
                }
            }
        }
        return result;
    }
    
    /*@future
public static void willAssignTeamMembers(List<Id> objIds)
{
assignTeamMembers(objIds);
}*/
    
    public static void assignTeamMembers(List<Id> objIds)
    {
        if(objIds == null || objIds.size() == 0)
        {
            return;
        }
        SavePoint sp = Database.setSavePoint();
        try
        {
            List<sObject> objs = getSObjects(objIds);
            if(objs.size() > 0)
            {
                if(objs[0] instanceOf Lead)
                {
                    List<Lead> effectiveObjs = new List<Lead>();
                    List<Id> leadIds = new List<Id>();
                    for(sObject obj : objs)
                    {
                        Lead ld = (Lead)obj;
                        if(!ld.IsConverted)
                        {
                            effectiveObjs.add(ld);
                            leadIds.add(ld.Id);
                        }
                    }
                    if(effectiveObjs.size() > 0)
                    {
                        Database.delete([select Id from LeadShare where LeadId in :effectiveObjs], false);
                        Database.insert(getPatchSharings(effectiveObjs), false);
                        //ShareLeadAndOpportunityToPartnerHelper.willShareLeads(leadIds);
                    }
                }
                else if(objs[0] instanceOf Opportunity)
                {
                    List<Opportunity> effectiveOpps = new List<Opportunity>();
                    List<Id> oppIds = new List<Id>();
                    Set<Id> oppIdsForOpportunityShare = new Set<Id>();
                    Set<Id> oppUserIdsForOpportunityShare = new Set<Id>();
                    for(sObject obj : objs)
                    {
                        Opportunity opp = (Opportunity)obj;
                        if(!opp.IsClosed)
                        {
                            effectiveOpps.add(opp);
                            oppIds.add(opp.Id);
                        }
                    }
                    if(effectiveOpps.size() > 0)
                    {
                        List<sObject> teamMembers = getPatchSharings(effectiveOpps);
                        List<OpportunityTeamMember> oldOppMembers = [select Id from OpportunityTeamMember where OpportunityId in :effectiveOpps];
                        if(oldOppMembers.size() > 0)
                        {
                            Database.DeleteResult[] result = Database.delete(oldOppMembers, false);
                            //SilverPeakUtils.logDatabaseError(oldOppMembers, result);
                        }
                        Database.SaveResult[] result = Database.insert(teamMembers, false);
                        //SilverPeakUtils.logDatabaseError(teamMembers, result);
                        //ShareLeadAndOpportunityToPartnerHelper.willShareOpportunities(oppIds);
                        for(sObject obj: teamMembers)
                        {
                            String oppTeamMemberRole = (String)obj.get('TeamMemberRole');
                            Id oppUserIdForShare = (Id)obj.get('UserId');
                            Id oppIdForShare = (Id)obj.get('OpportunityId');
                            if(oppTeamMemberRole != null && oppTeamMemberRole != 'Field and Channel Marketing Manager')
                            {    
                                oppIdsForOpportunityShare.add(oppIdForShare);
                                oppUserIdsForOpportunityShare.add(oppUserIdForShare);
                            }
                        }  
                        EditAccessToOppTeam(oppIdsForOpportunityShare, OppUserIdsForOpportunityShare);
                    }
                }
                else if(objs[0] instanceOf Account)
                {
                    List<sObject> teamMembers = getPatchSharings(objs);
                    List<AccountTeamMember> oldAccMembers = [select Id from AccountTeamMember where AccountId in :objs];
                    if(oldAccMembers.size() > 0)
                    {
                        Database.DeleteResult[] result = Database.delete(oldAccMembers, false);
                        SilverPeakUtils.logDatabaseError(oldAccMembers, result);
                    }
                    Database.SaveResult[] result = Database.insert(teamMembers, false);
                    SilverPeakUtils.logDatabaseError(teamMembers, result);
                }
            }
        }
        catch(Exception ex)
        {
            Database.rollback(sp);
            SilverPeakUtils.logException('Failed to assign team members, record id: ' + objIds);
            SilverPeakUtils.logException(ex);
        }
    }
    
    @future
    public static void refreshPatchTimestamp(Set<Id> patchIds)
    {
        List<Patch__c> patches = [select Id, Timestamp__c from Patch__c where Id in :patchIds];
        for(Patch__c patch : patches)
        {
            patch.Timestamp__c = System.now();
        }
        try
        {
            update patches;
        }
        catch(Exception ex)
        {
            SilverPeakUtils.logException(ex);
        }
    }
    
    public static Long LastDeploymentDate
    {
        get
        {
            List<ApexClass> engineClass = [select LastModifiedDate from ApexClass where Name='PatchRuleEngine' limit 1];
            if(engineClass.size() > 0)
            {
                return engineClass[0].LastModifiedDate.getTime();
            }
            return 0;
        }
    }
    
    //supports acc/opp/lead Id
    public static sObject getSObject(Id recordId)
    {
        List<sObject> result = getSObjects(new List<Id> { recordId });
        if(result.size() > 0)
        {
            return result[0];
        }
        return null;
    }
    
    //supports acc/opp/lead Id
    public static List<sObject> getSObjects(List<Id> recordIds)
    {
        List<sObject> result = new List<sObject>();
        Set<Id> accIds = new Set<Id>(), oppIds = new Set<Id>(), leadIds = new Set<Id>();
        for(Id recordId : recordIds)
        {
            String recordIdStr = recordId + '';
            if(recordIdStr.startsWith('001'))
            {
                accIds.add(recordId);
            }
            else if(recordIdStr.startsWith('00Q'))
            {
                leadIds.add(recordId);
            }
            else if(recordIdStr.startsWith('006'))
            {
                oppIds.add(recordId);
            }
        }
        if(accIds.size() > 0)
        {
            result.addAll((List<sObject>)[select Id, Name, OwnerId, Patch__c, BillingCountry, BillingPostalCode, BillingState, Industry, Type, Patch_Locked__c, GEO_Supported__c,ECSP__c from Account where Id in :accIds]);
        }
        if(leadIds.size() > 0)
        {
            result.addAll((List<sObject>)[select Id, Name, OwnerId, Patch__c, IsConverted, Company, Email, Country, State, PostalCode, Industry, Ownership_Routing__c, Patch_Locked__c, Trial_Request_from_Marketplace__c, LeadSource, RecordTypeId, GEO__c,ECSP__c from Lead where Id in :leadIds]);
        }
        if(oppIds.size() > 0)
        {
            result.addAll((List<sObject>)[select Id, Name, OwnerId, Patch__c, Type, IsClosed, IsWon, StageName, Transactional_Opportunity__c, Technical_Responsible__c, AccountId, Account.Name, Account.BillingCountry, Account.BillingPostalCode, Account.BillingState, Account.Industry, Account.Patch__c, Account.Patch__r.Id, Account.Patch__r.RSM__c, Account.Patch_Locked__c, Patch_Locked__c,Account.ECSP__c from Opportunity where Id in :oppIds]);
        }
        return result;
    }
    
    //supports acc/opp/lead object
    public static PatchRuleEngineBase.Target getTarget(sObject obj)
    {
        PatchRuleEngineBase.Target target = new PatchRuleEngineBase.Target();
        if(obj instanceOf Account)
        {
            Account acc = (Account)obj;
            target.Company = acc.Name;
            //target.EmailDomain = acc.Email;
            target.Country = acc.BillingCountry;
            target.ZipCode = acc.BillingPostalCode;
            target.State = acc.BillingState;
            target.Industry = acc.Industry;
            target.Locked = acc.Patch_Locked__c;
        }
        else if(obj instanceOf Lead)
        {
            Lead ld = (Lead)obj;
            target.Company = ld.Company;
            target.EmailDomain = getEmailDomain(ld.Email);
            target.Country = ld.Country;
            target.ZipCode = ld.PostalCode;
            target.State = ld.State;
            target.Industry = ld.Industry;
            target.Locked = ld.Patch_Locked__c;
        }
        else if(obj instanceOf Opportunity)
        {
            Opportunity opp = (Opportunity)obj;
            target.Company = opp.Account.Name;
            //target.EmailDomain = opp.Email;
            target.Country = opp.Account.BillingCountry;
            target.ZipCode = opp.Account.BillingPostalCode;
            target.State = opp.Account.BillingState;
            target.Industry = opp.Account.Industry;
            target.Locked = opp.Patch_Locked__c;
        }
        return target;
    }
    
    public static Boolean isSameTarget(PatchRuleEngineBase.Target a, PatchRuleEngineBase.Target b)
    {
        return a.Company == b.Company && a.EmailDomain == b.EmailDomain && a.Country == b.Country && a.ZipCode == b.ZipCode && a.State == b.State && a.Industry == b.Industry;
    }
    
    public static String getEmailDomain(String email)
    {
        email = (email == null) ? '' : email;
        return (email.indexOf('@') >= 0) ? email.substring(email.indexOf('@') + 1) : email;
    }
    
    public static List<String> splitCsv(String line)
    {
        List<String> result = new List<String>();
        Boolean itemStarted = true;
        Boolean isQuoteItem = false;
        String tempValue = '';
        for(Integer i = 0 ; i < line.length(); i++)
        {
            String c = line.mid(i, 1);
            if(c == ',')
            {
                if(itemStarted && !isQuoteItem)
                {
                    itemStarted = false;
                    result.add(tempValue.trim());
                    tempValue = '';
                }
                else if(itemStarted && isQuoteItem)
                {
                    tempValue += c;
                }
            }
            else if(c == ' ')
            {
                if(itemStarted)
                {
                    tempValue += c;
                }
            }
            else if(c == '"')
            {
                if(!itemStarted)
                {
                    itemStarted = true;
                    isQuoteItem = true;
                }
                else if(itemStarted && isQuoteItem)
                {
                    isQuoteItem = false;
                }
                else if(itemStarted && !isQuoteItem)
                {
                    tempValue += c;
                }
            }
            else
            {
                itemStarted = true;
                tempValue += c;
            }
        }
        result.add(tempValue.trim());
        return result;
    }
    
    @testvisible
    private static List<sObject> getPatchSharing(sObject obj, Patch__c patch)
    {
        List<sObject> result = new List<sObject>();
        if(patch != null)
        {
            if(obj instanceOf Lead)
            {
                Lead ld = (Lead)obj;
                if(patch.CSM__c != null && patch.CSM__c != ld.OwnerId)
                {
                    result.add(new LeadShare(LeadId=ld.Id, UserOrGroupId=patch.CSM__c, LeadAccessLevel='Edit'));
                }
                if(patch.ISR__c != null && patch.ISR__c != ld.OwnerId)
                {
                    result.add(new LeadShare(LeadId=ld.Id, UserOrGroupId=patch.ISR__c, LeadAccessLevel='Edit'));
                }
                if(patch.Owner__c != null && patch.Owner__c != ld.OwnerId)
                {
                    result.add(new LeadShare(LeadId=ld.Id, UserOrGroupId=patch.Owner__c, LeadAccessLevel='Edit'));
                }
                if(patch.RSM__c != null && patch.RSM__c != ld.OwnerId)
                {
                    result.add(new LeadShare(LeadId=ld.Id, UserOrGroupId=patch.RSM__c, LeadAccessLevel='Edit'));
                }
                if(patch.SE__c != null && patch.SE__c != ld.OwnerId)
                {
                    result.add(new LeadShare(LeadId=ld.Id, UserOrGroupId=patch.SE__c, LeadAccessLevel='Edit'));
                }
                if(patch.FCMM__c != null && patch.FCMM__c != ld.OwnerId)
                {
                    result.add(new LeadShare(LeadId=ld.Id, UserOrGroupId=patch.FCMM__c, LeadAccessLevel='Edit'));
                }
                if(patch.Overlay_1__c != null && patch.Overlay_1__c != ld.OwnerId)
                {
                    result.add(new LeadShare(LeadId=ld.Id, UserOrGroupId=patch.Overlay_1__c, LeadAccessLevel='Edit'));
                }
                if(patch.Overlay_2__c != null && patch.Overlay_2__c != ld.OwnerId)
                {
                    result.add(new LeadShare(LeadId=ld.Id, UserOrGroupId=patch.Overlay_2__c, LeadAccessLevel='Edit'));
                }
            }
            else if(obj instanceOf Account)
            {
                Account acc = (Account)obj;
                if(patch.CSM__c != null)
                {
                    result.add(new AccountTeamMember(AccountId=acc.Id, UserId=patch.CSM__c, TeamMemberRole='Channel Manager'));
                }
                if(patch.ISR__c != null)
                {
                    result.add(new AccountTeamMember(AccountId=acc.Id, UserId=patch.ISR__c, TeamMemberRole='Inside Sale Representative'));
                }
                if(patch.RSM__c != null)
                {
                    result.add(new AccountTeamMember(AccountId=acc.Id, UserId=patch.RSM__c, TeamMemberRole='Account Manager'));
                }
                if(patch.SE__c != null)
                {
                    result.add(new AccountTeamMember(AccountId=acc.Id, UserId=patch.SE__c, TeamMemberRole='Systems Engineer'));
                }
                if(patch.Owner__c != null && !IsPartOfCoreTeam(patch,patch.Owner__c))
                {
                    result.add(new AccountTeamMember(AccountId=acc.Id, UserId=patch.Owner__c, TeamMemberRole='Team Owner'));
                }
                if(patch.Overlay_1__c != null && patch.Overlay__c == true && !IsPartOfCoreTeam(patch,patch.Overlay_1__c))
                {
                    result.add(new AccountTeamMember(AccountId=acc.Id, UserId=patch.Overlay_1__c, TeamMemberRole='Team Member'));
                }
                if(patch.Overlay_2__c != null && patch.Overlay__c == true && !IsPartOfCoreTeam(patch,patch.Overlay_2__c))
                {
                    result.add(new AccountTeamMember(AccountId=acc.Id, UserId=patch.Overlay_2__c, TeamMemberRole='Team Member'));
                }
                if(patch.FCMM__c != null)
                {
                    result.add(new AccountTeamMember(AccountId=acc.Id, UserId=patch.FCMM__c, TeamMemberRole='Field and Channel Marketing Manager'));
                }
                if(patch.RSS__c != null)
                {
                    result.add(new AccountTeamMember(AccountId=acc.Id, UserId=patch.RSS__c, TeamMemberRole='Renewal Specialist'));
                }
            }
            else if(obj instanceOf Opportunity)
            {
                Opportunity opp = (Opportunity)obj;
                if(patch.CSM__c != null)
                {
                    result.add(new OpportunityTeamMember(OpportunityId=opp.Id, UserId=patch.CSM__c, TeamMemberRole='Channel Manager'));
                }
                if(patch.ISR__c != null)
                {
                    result.add(new OpportunityTeamMember(OpportunityId=opp.Id, UserId=patch.ISR__c, TeamMemberRole='Inside Sale Representative'));
                }
                if(patch.RSM__c != null)
                {
                    result.add(new OpportunityTeamMember(OpportunityId=opp.Id, UserId=patch.RSM__c, TeamMemberRole='Account Manager'));
                }
                if(patch.SE__c != null)
                {
                    result.add(new OpportunityTeamMember(OpportunityId=opp.Id, UserId=patch.SE__c, TeamMemberRole='Systems Engineer'));
                }
                if(patch.FCMM__c != null && !IsPartOfCoreTeam(patch,patch.FCMM__c))
                {
                    result.add(new OpportunityTeamMember(OpportunityId=opp.Id, UserId=patch.FCMM__c, TeamMemberRole='Field and Channel Marketing Manager'));
                }
                if(patch.Owner__c != null && !IsPartOfCoreTeam(patch,patch.Owner__c))
                {
                    result.add(new OpportunityTeamMember(OpportunityId=opp.Id, UserId=patch.Owner__c, TeamMemberRole='Team Owner'));
                }
                if(patch.Overlay_1__c != null && !IsPartOfCoreTeam(patch,patch.Overlay_1__c))
                {
                    result.add(new OpportunityTeamMember(OpportunityId=opp.Id, UserId=patch.Overlay_1__c, TeamMemberRole='Team Member'));
                }
                if(patch.Overlay_2__c != null && !IsPartOfCoreTeam(patch,patch.Overlay_2__c))
                {
                    result.add(new OpportunityTeamMember(OpportunityId=opp.Id, UserId=patch.Overlay_2__c, TeamMemberRole='Team Member'));
                }
                if(patch.SE__c != null && opp.Technical_Responsible__c!= null && patch.SE__c != opp.Technical_Responsible__c)
                {
                    result.add(new OpportunityTeamMember(OpportunityId=opp.Id, UserId=opp.Technical_Responsible__c, TeamMemberRole='Systems Engineer'));
                }
                if(patch.RSS__c != null)
                {
                    result.add(new OpportunityTeamMember(OpportunityId=opp.Id, UserId=patch.RSS__c, TeamMemberRole='Renewal Specialist'));
                }
            }
        }
        return result;
    }
    
    private static void EditAccessToOppTeam(Set<Id> setOppIds, Set<Id> setUserIds)
    { 
        List<OpportunityShare> listShares = [Select Id,OpportunityAccessLevel,Rowcause from OpportunityShare where OpportunityId  IN :setOppIds and UserOrGroupId IN : setUserIds and rowcause ='Team'];
        
        if(listShares != null && listShares.size()>0 ){
            for (OpportunityShare share : listShares)  {
                share.OpportunityAccessLevel = 'Edit';
            }
            update listShares;
        }
    }
    
    private static boolean IsPartOfCoreTeam(Patch__c patch,Id userId)
    {
        if(userId== patch.RSM__c)
        {return true;}
        if(userId== patch.CSM__c)
        {return true;}
        if(userId== patch.ISR__c)
        {return true;}
        if(userId== patch.SE__c)
        {return true;}
        return false;
    }
}