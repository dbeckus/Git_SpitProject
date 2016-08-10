public class PartnerPortalUserSharingSchedule implements Schedulable
{
    public void execute(SchedulableContext ctx)
    {
        PartnerPortalUserSharingBatch job = new PartnerPortalUserSharingBatch();
        Database.executeBatch(job, 10);
    }
}