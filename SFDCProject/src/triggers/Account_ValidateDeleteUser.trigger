trigger Account_ValidateDeleteUser on Account (before delete) {
	
	Id userProfileId = UserInfo.getProfileId();
	Profile profileObj = [Select Id, name from Profile where id = :userProfileId];
	System.debug('Profile Name: ' + profileObj.Name);
	
	Map<String, SunRunValidateProfiles__c> customSettings = SunRunValidateProfiles__c.getall();
	System.debug('SunRunValidateProfiles__c: ' + customSettings);
	
	Boolean canDelete = false;
	if(!customSettings.containsKey(profileObj.Name)){		
		for(Account accountObj: Trigger.Old){
			if(accountObj.Account_Type__c != null && accountObj.Account_Type__c == PRMLibrary.PARTNER){
				String errorMessage = 'This User does not have delete permissions on Partner Accounts.';
				errorMessage += '\r\n' ;
				errorMessage += 'Please contact System Administrator to delete this record.' ;
				accountObj.addError(errorMessage);
			}
		}
	}
}