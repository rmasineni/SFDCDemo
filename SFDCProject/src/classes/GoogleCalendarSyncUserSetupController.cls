public virtual without sharing class GoogleCalendarSyncUserSetupController extends BaseClass {
    public User user {get;set;}
    public String calendarId {get;set;}
    public String userAccessToken {get;set;}
    public String serviceAccountEmail {get;set;}
    public String verificationErrorMessage {get;set;}

    public GoogleCalendarSyncUserSetupController() {
		this(UserInfo.getUserId());
    }

    public GoogleCalendarSyncUserSetupController(String userId) {
        serviceAccountEmail = Sf.googleCalendarService.getServiceAccountEmail();
        
        if (userId != null) {
            initUser(UserInfo.getUserId());
            initOAuthResponse();
        }
    }
 
    public PageReference requestGoogleForOAuthAccess() {
		String url = Sf.googleCalendarService.getOAuthAccessRequestUrl();
     	return new PageReference(url);
    }
	
    public void initOAuthResponse() {
        //Check if it erroed out. If so, add error message.
        String error = getParameter('error');
        if (isNotempty(error)) {
            addErrorMessage('Request to access your Google Calendar failed. [Message: ' + error + ']. Please try to grant access again. If you continue to have problems, please contact administrator.');
            return;
        }
        
        //Check if we have successful oauth code
        String code = getParameter('code');
        if (isEmpty(code)) {
            return;
        }
        
        userAccessToken = Sf.googleCalendarService.getOAuthAccessToken(code);
        
        if (isEmpty(calendarId)) {
            calendarId = Sf.googleCalendarService.getUserPrimaryCalendarId(userAccessToken);
        }
    }

    public PageReference grantAccessAndEnableSync() {
        Sf.googleCalendarService.grantAccessToCalendar(userAccessToken, calendarId);
		
        return enableCalendarSync(false);
   	}

    public PageReference grantAccessAndEnableAndStartFullSync() {
        Sf.googleCalendarService.grantAccessToCalendar(userAccessToken, calendarId);
		
        return enableCalendarSync(true);
   	}
    
    public PageReference startFullSync() {
        Sf.googleCalendarService.requestFullSync(new String[]{user.id});
        addInfoMessage('Full sync has been started and it may take few minutes to complete.');
        return null;
    }
    
	public PageReference enableSync() {
		return enableCalendarSync(false);       
   	}

   	public PageReference enableAndStartFullSync() {
   		return enableCalendarSync(true);
   	}
    
   	public PageReference enableCalendarSync(Boolean startFullSync) {
        try {
            if (Test.isRunningTest()) {
                Exception e = (Exception) BaseClass.testParams.get('ExceptionToThrow');
                if (e != null) {
                    throw e;
                }
            }
            
            //Enable calendar sync
            Sf.googleCalendarService.enableCalendarSync(user.id, calendarId, startFullSync);
            user = Sf.googleCalendarService.queryUsers(new Id[]{user.id}).get(0);
            addInfoMessage('Google Calendar Sync is enabled.');
        } catch (UnsuccessfulHttpResponseException e) {
            if (e.isStatusCode(403)) {
                addErrorMessage('Received error from Google API (403 Forbidden). This error typically happens' + 
                	+ ' when user\'s calendar is not shared with Service account (' + serviceAccountEmail 
                    + ') with "Make changes AND manage sharing" access. Please make sure that Calendar is shared and try again.');
            } else if (e.isStatusCode(404)) {
                addErrorMessage('Received error from Google API (404 Resource Not Found). This error typically happens' + 
                	+ ' when user\'s calendar is not shared with Service account (' + serviceAccountEmail 
                    + ') with "Make changes AND manage sharing" access. Please make sure that Calendar is shared and try again.');
            } else {
	            addErrorMessage(e);
            }
        } catch (Exception e) {
            addErrorMessage(e);
        }
        
    	return null;
    }
    
    public PageReference disableSync() {
        try {
            Sf.googleCalendarService.disableCalendarSync(user.id);
            user = Sf.googleCalendarService.queryUsers(new Id[]{user.id}).get(0);
            addInfoMessage('Google Calendar Sync is disabled.');
        } catch (Exception e) {
            addErrorMessage(e);
        }
        
    	return null;
    }
    
    public void initUser(Id userId) {
        user = Sf.googleCalendarService.queryUsers(new Id[]{userId}).get(0);
		calendarId = user.Google_Calendar_Id__c;
        
        if (user != null && user.Google_Calendar_Sync_Enabled__c) {
            try {
                Sf.googleCalendarService.verifyUserCalendarSetupAndAccess(calendarId);
            } catch (Exception e) {
                verificationErrorMessage = e.getMessage();
                addErrorMessage('Access Verification Error: ' + verificationErrorMessage);
            }
        }
    }
}