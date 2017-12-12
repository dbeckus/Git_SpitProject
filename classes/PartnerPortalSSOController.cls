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
        System.debug('ProfileValid'+ProfileValid);
        if(ProfileValid)
        {
            /*String ssoRequest = ApexPages.currentPage().getParameters().get('SSORequest');
            if(String.isNotBlank(ssoRequest))
            {
                return ssoLoginCofirm();
            }
            else
            {*/
                return ssoLoginTry();
            //}   
        }
        else
        {
            return null;
        }
    }
    
    private PageReference ssoLoginTry()
    {
        if(UserInfo.getUserType() == 'PowerPartner')
        {
            String url = HPartnerPortalSSOStub.getSSOLink(UserInfo.getUserId());
            System.debug('URL '+url );
            return new PageReference(url);
        }
        else
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Only Partner Portal user can login to the LMS.'));
            return null;
        }
     
       
    }
    
    private PageReference ssoLoginCofirm()
    {
        String ssoRequest = ApexPages.currentPage().getParameters().get('SSORequest');
        String ssoResponse = PartnerPortalSSOStub.md5Hash(ssoRequest);
        return new PageReference('http://training.silver-peak.com/get.ashx?method=sso&SSOResponse=' + ssoResponse);
    }
}