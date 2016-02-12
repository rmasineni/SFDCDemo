public without sharing class GoogleCalendarSyncSetupController extends GoogleCalendarSyncUserSetupController {
    public Account account {get;set;}
    public List<App_Log__c> syncErrors {get;set;}	
    
    public GoogleCalendarSyncSetupController() {
        super(null);
        changeUser();
        if (isNotEmpty(getParameter('id'))) {
            initUser(getParameter('id'));
			initUserDetails();
        }
    }

    public PageReference changeUser() {
        user = null;
        account = new Account();
        calendarId = null;
        return null;
    }

    public PageReference continueWithSetup() {
        if (isEmpty(account.OwnerId)) {
            addErrorMessage('Please select a User to continue with Google Calendar Setup.');
            return null;
        }
        
        initUser(account.ownerId);
        initUserDetails();
        return null;
    }
    
    public void initUserDetails() {
        syncErrors = Sf.googleCalendarService.getSyncErrors(user.id);
    }
}