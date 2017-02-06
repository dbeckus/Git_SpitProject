@isTest
public class AttachmentCheckOnMDFTest {
    @isTest
    public static void test()
    {
    /**
        List<User> portalUsers = [select Id from User where UserType='PowerPartner' and IsActive=true limit 1];
        if(portalUsers.size() > 0)
        {
            System.runas(portalUsers[0])
            {
                MDF_Request__c mdf = new MDF_Request__c(Activity_Complete__c = true);
                insert mdf;
                Attachment att = new Attachment(Name = 'Acme');
                att.Body = Blob.valueOf('abc');
                att.ParentId = mdf.Id;
                try
                {
                    insert att; 
                    System.assert(false, 'There should be an error');
                }catch( Exception ex)
                {
                }
            }
        }
        */
    }
}