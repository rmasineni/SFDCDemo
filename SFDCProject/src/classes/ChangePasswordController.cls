/**
 * An apex page controller that exposes the change password functionality
 */
public with sharing class ChangePasswordController {
    public String oldPassword {get; set;}
    public String newPassword {get; set;}
    public String verifyNewPassword {get; set;}        
    public boolean displayOldPassword {get;set;}
    public String returnUrl {get;set;}
    
    public PageReference changePassword() {
        return Site.changePassword(newPassword, verifyNewPassword, oldpassword);    
    }     
    
   	public ChangePasswordController() {
   		
   		displayOldPassword = false;
   		//oldPassword = null;
   		
		returnUrl = System.currentPagereference().getParameters().get('retURL');
		System.debug('returnUrl: ' + returnUrl);
		
		Id userId = UserInfo.getUserId();
		User userObj = [Select Id, name, UserType, userName, profileId, 
							email, contactId from User where Id = :userId];
		
		System.debug('userObj.usertype: ' + userObj	);
   		if(userObj != null && 'PowerPartner' != userObj.usertype && 'Guest' != userObj.usertype){
   			displayOldPassword = true;
   		}
   	}
   	
	public PageReference back(){
		//String tempURL = Encodingutil.urlEncode(returnUrl, 'UTF-8');
		String urlPath = Label.PartnerPortalSiteUrl + returnUrl;
		PageReference pageRef = new PageReference(urlPath);
		pageRef.setRedirect(true);
        return pageRef;            
	}
    
   	@IsTest(SeeAllData=true) public static void testChangePasswordController() {
        // Instantiate a new controller with all parameters in the page
        ChangePasswordController controller = new ChangePasswordController();
        controller.oldPassword = '123456';
        controller.newPassword = 'qwerty1'; 
        controller.verifyNewPassword = 'qwerty1';                
        
        System.assertEquals(controller.changePassword(),null);    
        controller.back();
                               
    }    
}