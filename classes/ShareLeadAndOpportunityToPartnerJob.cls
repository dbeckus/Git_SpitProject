public class ShareLeadAndOpportunityToPartnerJob implements Queueable
{
    public List<Id> OpportunityIds;
    public List<Id> LeadIds;
    
    public void execute(QueueableContext context) 
    {
        if(OpportunityIds != null && OpportunityIds.size() > 0)
        {
            ShareLeadAndOpportunityToPartnerHelper.shareOpportunities(OpportunityIds);
        }
        if(LeadIds != null && LeadIds.size() > 0)
        {
            ShareLeadAndOpportunityToPartnerHelper.shareLeads(LeadIds);
        }
    }
}