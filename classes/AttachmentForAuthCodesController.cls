/*
 * Controller for page AuthorizationCodesTable, generates a html table contains the authorization codes
 * authorization codes are passed in with parameter "authCodes"
 */
public class AttachmentForAuthCodesController 
{
    public AttachmentForAuthCodesController()
    {
    }
    
    //gets an two-dimension array contains the authorization codes passed in with parameter "authCodes"
    //two-dimension array is used to generate a html table,  4 code per row.
    public List<String[]> AuthCodes
    {
        get
        {
            List<String[]> result = new List<String[]>();
            List<String> subResult = new List<String>();
            for(Integer i = 0; i < AllCodes.size(); i++)
            {
                subResult.add(AllCodes[i]);
                if(Math.mod(i + 1, 4) == 0)
                {
                    result.add(subResult);
                    subResult = new List<String>();
                }
            }
            if(subResult.size() > 0)
            {
                while(Math.mod(subResult.size(), 4) != 0)
                {
                    subResult.add(' ');
                }
                result.add(subResult);
            }
            return result;
        }
    }
    
    public String ExpirationDate
    {
        get
        {
            return ApexPages.currentPage().getParameters().get('exp'); 
        }
    }
    
    private List<String> AllCodes
    {
        get
        {
            String authorizationCodesStr =  ApexPages.currentPage().getParameters().get('authCodes'); 
            if(authorizationCodesStr != null)
            {
                return authorizationCodesStr.split(',');
            }
            else
            {
                return new List<String>();
            }
        }
    }
    
    @isTest
    static void testAttachmentForAuthCodesController()
    {
        Account acc = new Account(Name='acme');
        insert acc;
        AuthCode__c code = new AuthCode__c(Account__c=acc.Id, Course_Code__c='test', Valid__c=true);
        insert code;
        code = [select Id, Authorization_Code__c from AuthCode__c where Id=:code.Id limit 1];
        
        Test.setCurrentPage(new PageReference('/apex/AuthorizationCodesTable?authCodes=' + code.Authorization_Code__c));
        AttachmentForAuthCodesController controller = new AttachmentForAuthCodesController();
        System.assert(controller.AuthCodes.size() > 0);
    }
}