public class AssociateLMSCertificateWithContact implements Schedulable {

    public void execute(SchedulableContext sc)
    {
        // Associate Certification with Contact
        LMSBatchHelper.H_AssociateContactUsingUserId();
        // Associate Certiifcation with Email Address.
        LMSBatchHelper.H_AssociateContactUsingEmailAddress();
    }
}