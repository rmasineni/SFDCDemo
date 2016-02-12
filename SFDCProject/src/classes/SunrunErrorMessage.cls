public class SunrunErrorMessage {
	
	public static Map<String, Sunrun_Error_Message__c> getErrorMessage(Set<String> erroCodes){
		Map<String, Sunrun_Error_Message__c> sunrunErrorMessages = new Map<String, Sunrun_Error_Message__c>();
		for(Sunrun_Error_Message__c sunrunErrorObj : [Select name, Error_Message__c, Error_Description__c 
														from Sunrun_Error_Message__c where name in :erroCodes]){
			sunrunErrorMessages.put(sunrunErrorObj.name, sunrunErrorObj);
		}
		return sunrunErrorMessages;
	}

	public static Sunrun_Error_Message__c getErrorMessage(String errorCode){
		Sunrun_Error_Message__c errorMessageObj;
		Set<String> errorCodes = new Set<String>();
		errorCodes.add(errorCode);
		
		Map<String, Sunrun_Error_Message__c> sunrunErrorMessages = getErrorMessage(errorCodes);
		if(sunrunErrorMessages.size() > 0  && sunrunErrorMessages.containskey(errorCode)){
			errorMessageObj = sunrunErrorMessages.get(errorCode);
		}
		return errorMessageObj;
	}
	
	 static testMethod void testSunrunErrorMessage() {
	 	Sunrun_Error_Message__c errorMessageObj = new Sunrun_Error_Message__c();
	 	errorMessageObj.name = 'ERROR_0001';
	 	errorMessageObj.Error_Message__c = 'Test Message';
	 	errorMessageObj.Error_Description__c = 'Test Description';
	 	insert errorMessageObj;
	 	System.debug('errorMessageObj: ' + errorMessageObj);
	 	
	 	Sunrun_Error_Message__c resultObj = SunrunErrorMessage.getErrorMessage('ERROR_0001');
	 	System.debug('resultObj: ' + resultObj);
	 	System.assertNotEquals(null, resultObj);
	 }
	
}