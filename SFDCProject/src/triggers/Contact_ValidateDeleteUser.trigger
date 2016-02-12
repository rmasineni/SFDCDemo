trigger Contact_ValidateDeleteUser on Contact (before delete) {

  Boolean skipValidations = False;
  skipValidations = SkipTriggerValidation.performTriggerValidations();
  if(skipValidations == false){
  
    Id userProfileId = UserInfo.getProfileId();
    Profile profileObj = [Select Id, name from Profile where id = :userProfileId];
    //System.debug('Profile Name: ' + profileObj.Name);
    
    Map<String, SunRunValidateProfiles__c> customSettings = SunRunValidateProfiles__c.getall();
    //System.debug('SunRunValidateProfiles__c: ' + customSettings);
    
    Boolean canDelete = false;
    if(!customSettings.containsKey(profileObj.Name)){       
        for(Contact contactObj: Trigger.Old){
            if(contactObj.Contact_Type__c != null && contactObj.Contact_Type__c == PRMLibrary.PARTNER){
                String errorMessage = 'This User does not have delete permissions on Partner Contacts.';
                errorMessage += '\r\n' ;
                errorMessage += 'Please contact System Administrator to delete this record.' ;
                contactObj.addError(errorMessage);
            }
        }
    }

  }
}