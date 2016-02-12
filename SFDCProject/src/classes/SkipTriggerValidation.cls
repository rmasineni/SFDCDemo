public class SkipTriggerValidation {

	public static Map<String, Users_For_Trigger_Validations__c> userValidationMap = new Map<String, Users_For_Trigger_Validations__c>();
    static
    {  
		Map<String, Users_For_Trigger_Validations__c> usersForTriggerValidations = Users_For_Trigger_Validations__c.getAll();
		for (Users_For_Trigger_Validations__c userValidationObj : usersForTriggerValidations.values()) {
			userValidationMap.put(userValidationObj.User_Id__c, userValidationObj);           
        } 
    }
	
	public static Boolean performTriggerValidations(){
		Boolean result = false;
		if(userValidationMap != null && !userValidationMap.isEmpty()){
			String loginUserId = UserInfo.getUserId();
			System.debug('loginUserId: ' + loginUserId);
			loginUserId = loginUserId.substring(0,15);
			System.debug('userValidationMap: ' + userValidationMap);
			
			if(userValidationMap.containskey(loginUserId)){
				result = true;
			}
		}
		return result;
	}

}