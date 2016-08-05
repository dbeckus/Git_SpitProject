@IsTest
public class TestDownloadExtension {

    @IsTest
    public static void TestDownloadLog()
    {
       User usrData= [Select Id, FirstName, LastName from User where Id=:UserInfo.getUserId() and UserType='Standard' LIMIT 1];
       ApexPages.StandardController stdController= new ApexPages.StandardController(usrData);
       DownloadExtension controller= new DownloadExtension(stdController);
    }
}