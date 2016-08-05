/*
 * Controller page LicenseAgreementInvoke.
 */
public class LicenseAgreementController
{
    private String operationType;
    public LicenseAgreementController()
    {        
        operationType = ApexPages.currentPage().getParameters().get('op');
    }

    public Boolean IsAgree
    {
        get
        {
            User currentUser = [select License_Agreement_Checked__c from User where id = :UserInfo.getUserId() limit 1];
            if(currentUser != null)
            {
                if(currentUser.License_Agreement_Checked__c == true)
                {                    
                    return true;
                }
                else
                {
                    return false;
                }
            }
            else
            {
                return false;
            }
        }
    }  
    
    public void setLicenseAgreement()
    { 
        if(Integer.valueOf(operationType) == 1)
        {
            User currentUser = [select License_Agreement_Checked__c from User where id = :UserInfo.getUserId() limit 1];
            currentUser.License_Agreement_Checked__c = true;
            try
            {
                update currentUser;
            }
            catch(DmlException ex)
            {
                ApexPages.addMessages(ex);
            } 
        }    
    }    
    
    @isTest
    static void testLicenseAgreement()
    {
        ApexPages.currentPage().getParameters().put('op','1');
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        LicenseAgreementController testController = new LicenseAgreementController();
        Boolean result1 = testController.isAgree;
        testController.setLicenseAgreement();
        Boolean result2 = testController.isAgree;
        system.assertEquals(true,result2);            
    }
}