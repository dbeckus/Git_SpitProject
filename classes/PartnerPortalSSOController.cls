public with sharing class PartnerPortalSSOController 
{
    public Boolean ProfileValid
    {
        get
        {
            User currentUser = [select Id, UserName, ContactId, Contact.FirstName, Contact.LastName, Contact.Email from User where Id = :UserInfo.getUserId()];
            return currentUser.ContactId != null && String.isNotBlank(currentUser.Contact.FirstName) && String.isNotBlank(currentUser.Contact.LastName); 
        }
    }

    public PageReference redirect()
    {
        if(ProfileValid)
        {
            
            String ssoRequest = ApexPages.currentPage().getParameters().get('SSORequest');
            System.debug('ssoRequest '+ ssoRequest);
 			return ssoLoginTry();
            
            /*if(String.isNotBlank(ssoRequest))
            {
                return ssoLoginConfirm();
            }
            else
            {
                return ssoLoginTry();
            }   */
        }
        else
        {
            return null;
        }
    }
    
    private PageReference ssoLoginTry()
    {
        System.debug('UserInfo.getUserType() '+ UserInfo.getUserType());
        if(UserInfo.getUserType() == 'PowerPartner')
        {
            String url = HPartnerPortalSSOStub.getSSOLink(UserInfo.getUserId());
            System.debug(url);
            return new PageReference(url);
        }
        else
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Only Partner Portal user can login to the LMS.'));
            return null;
        }
    }
    /*
    private PageReference ssoLoginConfirm()
    {
        return new PageReference('https://partners.silver-peak.com/idp/login?app=0sp380000004CMo');
    }*/
}