public class LMSFetchCertificationsSchedule implements Schedulable {
  public void execute(SchedulableContext context)
    {
        LMSFetchCertificationsBatch obj = new LMSFetchCertificationsBatch();
        Database.executeBatch(obj,1);
    }
}