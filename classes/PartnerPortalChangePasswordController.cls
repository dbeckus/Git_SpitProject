public without sharing class PartnerPortalChangePasswordController 
{
    public PartnerPortalChangePasswordController() 
    {
    }
    
    public String oldPassword {get; set;}
    public String newPassword {get; set;}
    public String verifyNewPassword {get; set;}        
    
    public PageReference changePassword() 
    {
        return Site.changePassword(newPassword, verifyNewPassword, oldpassword);    
    }     
    
    @isTest
    static void testChangePasswordController() 
    {
        PartnerPortalChangePasswordController controller = new PartnerPortalChangePasswordController();
        controller.oldPassword = '123456';
        controller.newPassword = 'qwerty1'; 
        controller.verifyNewPassword = 'qwerty1';                
        System.assertEquals(controller.changePassword(),null);                           
    } 
}