trigger PartnerContract_ValidateDeleteUser on Partner_Contract__c (before delete) {

	Id userProfileId = UserInfo.getProfileId();
	Profile profileObj = [Select Id, name from Profile where id = :userProfileId];
	//System.debug('Profile Name: ' + profileObj.Name);
	
	Map<String, SunRunValidateProfiles__c> customSettings = SunRunValidateProfiles__c.getall();
	//System.debug('SunRunValidateProfiles__c: ' + customSettings);
	
	Boolean canDelete = false;
	if(!customSettings.containsKey(profileObj.Name)){		
		for(Partner_Contract__c contractObj: Trigger.Old){
			String errorMessage = 'This User does not have delete permissions on Partner Contracts.';
			errorMessage += '\r\n' ;
			errorMessage += 'Please contact System Administrator to delete this record.' ;
			contractObj.addError(errorMessage);
		}
	}
}