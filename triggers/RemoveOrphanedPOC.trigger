/*
 * Removes POCs after the OPP is deleted
 */
trigger RemoveOrphanedPOC on Opportunity (after delete) 
{
    if(!SilverPeakUtils.BypassingTriggers)
    {
        OpportunityMergeController.removeOrphanedPOC();
    }
}