/*
 * These defined actions are used in the dynamic Opportunity page and Lead page.
 */
public class CustomAction
{
    public CustomAction(ApexPages.standardController sc) 
    {
        //this constructor to ensure the remote action is injected to vf page
    }
    
    @RemoteAction
    public static ActionResponse respondButtonClick(String buttonName, String recordId)
    {
        Type actionType = Type.forName('CustomAction', buttonName);
        if(actionType != null)
        {
            Object action = actionType.newInstance();
            if(action instanceOf IServerAction)
            {
                return ((IServerAction)action).execute(recordId);
            }
        }
        ActionResponse response = new ActionResponse();
        response.message = 'Button ' + buttonName + ' is not defined';
        return response;
    }
    
    public interface IPageAction
    {
        ActionResponse execute(Id recordId);
    }
    
    public interface IServerAction
    {
        ActionResponse execute(Id recordId);
    }
    
    public class ActionResponse
    {
        public ActionResponse()
        {
            popup = false;
            needRefresh = false;
            needConfirm = false;
        }
        
        public String url { get; set; }
        public String message { get; set; }
        public String javascript { get; set; }
        public Boolean popup { get; set; }
        public Boolean needRefresh { get; set; }
        public Integer popupWidth { get; set; }
        public Integer popupHeight { get; set; }
        public Boolean needConfirm { get; set; }
    }
    
    public class OpportunityEdit implements IPageAction
    {
        public ActionResponse execute(Id recordId)
        {
            ActionResponse result = new ActionResponse();
            result.url = '/' + recordId + '/e?retURL=%2F' + recordId;
            return result;
        }
    }
    
    public class OpportunityDelete implements IPageAction
    {
        public ActionResponse execute(Id recordId)
        {
            ActionResponse result = new ActionResponse();
            result.url = '/apex/ArchiveDeletedOpportunity?id=' + recordId;
            return result;
        }
    }
    
    public class OpportunityRenewal implements IPageAction
    {
        public ActionResponse execute(Id recordId)
        {
            ActionResponse result = new ActionResponse();
            result.url = '/apex/RenewalOpportunity?id=' + recordId;
            return result;
        }
    }
   
    public class OpportunityDefineChannel implements IPageAction
    {
        public ActionResponse execute(Id recordId)
        {
            ActionResponse result = new ActionResponse();
            result.url = '/apex/DefineChannel?id=' + recordId;
            result.popup = true;
            result.popupWidth = 640;
            result.popupHeight = 480;
            return result;
        }
    }
    
    public class OpportunityPatchLock implements IServerAction
    {
        public ActionResponse execute(Id recordId)
        {
            List<Opportunity> opps = [select Id, Patch_Locked__c, OwnerId from Opportunity where Id=:recordId limit 1];
            ActionResponse result = new ActionResponse();
            if(opps.size() > 0)
            {
                Opportunity opp = opps[0];
                try
                {
                    opp.Patch_Locked__c = true;
                    update opp;
                    result.message = 'Patch is locked';
                    result.needRefresh = true;
                }
                catch(Exception ex)
                {
                    result.message = 'Failed to lock patch. The error message is ' + ex.getMessage();
                }
            }
            return result;
        }
    }
    
    public class OpportunityPatchUnlock implements IServerAction
    {
        public ActionResponse execute(Id recordId)
        {
            List<Opportunity> opps = [select Id, Patch_Locked__c, OwnerId from Opportunity where Id=:recordId limit 1];
            ActionResponse result = new ActionResponse();
            if(opps.size() > 0)
            {
                Opportunity opp = opps[0];
                try
                {
                    opp.Patch_Locked__c = false;
                    update opp;
                    result.message = 'Patch is unlocked';
                    result.needRefresh = true;
                }
                catch(Exception ex)
                {
                    result.message = 'Failed to unlock patch. The error message is ' + ex.getMessage();
                }
            }
            return result;
        }
    }
    
    public class OpportunityPatchOverride implements IPageAction
    {
        public ActionResponse execute(Id recordId)
        {
            ActionResponse result = new ActionResponse();
            result.url = '/apex/PatchOverride?id=' + recordId;
            result.popup = true;
            result.popupWidth = 400;
            result.popupHeight = 400;
            return result;
        }
    }
    
    public class OpportunityRevenueRecognitionChecklist implements IPageAction
    {
        public ActionResponse execute(Id recordId)
        {
            ActionResponse result = new ActionResponse();
            result.url = '/apex/revenuerecognitionchecklist?id=' + recordId;
            result.popup = true;
            result.popupWidth = 890;
            result.popupHeight = 700;
            return result;
        }
    }
    
    public class DefineChannelOnQuote implements IPageAction
    {
        public ActionResponse execute(Id recordId)
        {
            ActionResponse result = new ActionResponse();
            result.url = '/apex/DefineChannelForQuote?id=' + recordId;
            result.popup = true;
            result.popupWidth = 750;
            result.popupHeight = 600;
            return result;
        }
    }
    
    public class OpportunityForwardLead implements IPageAction
    {
        public ActionResponse execute(Id recordId)
        {
            ActionResponse result = new ActionResponse();
            result.url = '/apex/ForwardLead?id=' + recordId;
            return result;
        }
    }
    public class OpportunityMerge implements IPageAction
    {
        public ActionResponse execute(Id recordId)
        {
            ActionResponse result = new ActionResponse();
            result.url = '/apex/OpportunityChooseForMerge?id=' + recordId;
            return result;
        }
    }

    //Lead actions
    public class LeadEdit implements IPageAction
    {
        public ActionResponse execute(Id recordId)
        {
            ActionResponse result = new ActionResponse();
            result.url = '/' + recordId + '/e?retURL=%2F' + recordId;
            return result;
        }
    }

    public class LeadDelete implements IServerAction
    {
        public ActionResponse execute(Id recordId)
        {
            ActionResponse result = new ActionResponse();
            try
            {
                Database.delete(recordId);
                //result.needRefresh = true;
                result.url = '/00Q/o';
            }
            catch(DMLException ex)
            {
                result.message = 'Failed to delete this lead. The error message is ' + ex.getMessage();
            }
            return result;
        }
    }

    public class LeadClone implements IPageAction
    {
        public ActionResponse execute(Id recordId)
        {
            ActionResponse result = new ActionResponse();
            result.url = '/' + recordId + '/e?clone=1&retURL=%2F' + recordId;
            return result;
        }
    }

    public class LeadConvert implements IPageAction
    {
        public ActionResponse execute(Id recordId)
        {
            ActionResponse result = new ActionResponse();
            result.url = '/lead/leadconvert.jsp?retURL=%2F' + recordId + '&id=' + recordId;
            return result;
        }
    }

    public class LeadMerge implements IPageAction
    {
        public ActionResponse execute(Id recordId)
        {
            ActionResponse result = new ActionResponse();
            result.url = '/lead/leadmergewizard.jsp?retURL=%2F' + recordId + '&id=' + recordId;
            return result;
        }
    }

    public class LeadDenyDealRegistration implements IPageAction
    {
        public ActionResponse execute(Id recordId)
        {
            ActionResponse result = new ActionResponse();
            result.url = 'https://rvpe.cs13.visual.force.com/apex/denyDealRegistration?id=' + recordId + '&scontrolCaching=1';
            return result;
        }
    }

    public class LeadRSMAccepted implements IServerAction
    {
        public ActionResponse execute(Id recordId)
        {
            ActionResponse result = new ActionResponse();
            List<Lead> leads = [select Id, OwnerId, Status from Lead where Id = :recordId limit 1];
            if(leads.size() > 0)
            {
                Lead lead = leads[0];
                try
                {
                    lead.Status = 'RSM Accepted'; 
                    lead.OwnerId = UserInfo.getUserId(); 
                    update lead;
                    result.needRefresh = true;
                    result.message = 'Accepted by RSM';
                }
                catch(DMLException ex)
                {
                    result.message = 'Failed to accept. The error message is ' + ex.getMessage();
                }
            }

            return result;
        }
    }

    public class LeadRSMRejected implements IPageAction
    {
        public ActionResponse execute(Id recordId)
        {
            ActionResponse result = new ActionResponse();
            result.url = '/apex/LeadRSMRejected?id=' + recordId;
            result.popup = true;
            result.popupWidth = 400;
            result.popupHeight = 325;
            return result;
        }
    }

    public class LeadISRQualified implements IServerAction
    {
        public ActionResponse execute(Id recordId)
        {
            ActionResponse result = new ActionResponse();
            List<Lead> leads = [select Id, OwnerId, Status, Screening_Results__c, Screening_Pass_Date__c, Screening_Organization__c, Screening_Agent__c, IQL_Date_Stamp__c, IQL_Tracking__c, IQL_ISR_Tracking__c from Lead where Id = :recordId limit 1];
            if(leads.size() > 0)
            {
                Lead lead = leads[0];
                if(lead.OwnerId == UserInfo.getUserId())
                {
                    try
                    {
                        lead.Status = 'ISR Qualified'; 
                        lead.Screening_Results__c = 'ISR Qualified'; 
                        lead.Screening_Pass_Date__c = Date.today(); 
                        lead.Screening_Organization__c = 'Silver Peak'; 
                        lead.Screening_Agent__c = UserInfo.getLastName(); 
                        lead.IQL_Date_Stamp__c = Date.today(); 
                        lead.IQL_Tracking__c = true; 
                        lead.IQL_ISR_Tracking__c = UserInfo.getLastName();
                        update lead;
                        result.needRefresh = true;
                        result.message = 'Qualified by ISR';
                    }
                    catch(DMLException ex)
                    {
                        result.message = 'Failed to qualify. The error message is ' + ex.getMessage();
                    }
                }
                else
                {
                    result.message = 'You must be the Lead Owner to qualify it.';
                }
            }
            return result;
        }
    }

    public class LeadISRRejected implements IPageAction
    {
        public ActionResponse execute(Id recordId)
        {
            ActionResponse result = new ActionResponse();
            result.url = '/apex/LeadISRRejected?id=' + recordId;
            result.popup = true;
            result.popupWidth = 400;
            result.popupHeight = 325;
            return result;
        }
    }

    public class LeadPatchOverride implements IPageAction
    {
        public ActionResponse execute(Id recordId)
        {
            ActionResponse result = new ActionResponse();
            result.url = '/apex/PatchOverride?id=' + recordId;
            result.popup = true;
            result.popupWidth = 400;
            result.popupHeight = 400;
            return result;
        }
    }

    public class LeadPatchLock implements IServerAction
    {
        public ActionResponse execute(Id recordId)
        {
            ActionResponse result = new ActionResponse();
            List<Lead> leads = [select Id, Patch_Locked__c, OwnerId from Lead where Id = :recordId limit 1];
            if(leads.size() > 0)
            {
                Lead lead = leads[0];
                try
                {
                    lead.Patch_Locked__c = true;
                    update lead;
                    result.message = 'Patch is locked';
                    result.needRefresh = true;
                }
                catch(DMLException ex)
                {
                    result.message = 'Failed to lock patch. The error message is ' + ex.getMessage();
                }
            }
            return result;
        }
    }

    public class LeadPatchUnlock implements IServerAction
    {
        public ActionResponse execute(Id recordId)
        {
            ActionResponse result = new ActionResponse();
            List<Lead> leads = [select Id, Patch_Locked__c, OwnerId from Lead where Id = :recordId limit 1];
            if(leads.size() > 0)
            {
                Lead lead = leads[0];
                try
                {
                    lead.Patch_Locked__c = false;
                    update lead;
                    result.message = 'Patch is unlocked';
                    result.needRefresh = true;
                }
                catch(DMLException ex)
                {
                    result.message = 'Failed to unlock patch. The error message is ' + ex.getMessage();
                }
            }
            return result;
        }
    }
}