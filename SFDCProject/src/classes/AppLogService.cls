public interface AppLogService {
    App_Log__c logDebug(String module, String action, String message);
    App_Log__c logDebug(String module, String action, String message, String details);
    App_Log__c logDebug(String module, String action, String message, String details, Id recordId);
    
    App_Log__c logError(String module, String action, String message, Exception e);
    App_Log__c logError(String module, String action, String message, String details, Exception e);
    App_Log__c logError(String module, String action, String message, String details, Id recordId, Exception e);
	
    App_Log__c createDebug(String module, String action, String message);
    App_Log__c createDebug(String module, String action, String message, String details);
    App_Log__c createDebug(String module, String action, String message, String details, Id recordId);
    
    App_Log__c createError(String module, String action, String message, Exception e);
    App_Log__c createError(String module, String action, String message, String details, Exception e);
    App_Log__c createError(String module, String action, String message, String details, Id recordId, Exception e);
	
    /**
     * Processes the given app log fields. Processing makes sure required data elements are
     * populated, lengths of each data element of message is appropriate, and details
     * fields lengths are not exceeding the allowed lengths.
     */
    App_Log__c processFields(App_Log__c appLog);
    App_Log__c processFields(App_Log__c appLog, Exception e);

    App_Log__c log(String module, String action, String message, String details, Id recordId, Exception e);
    App_Log__c create(String module, String action, String message, String details, Id recordId, Exception e);

    App_Log__c log(String type, String module, String action, String message, String details, Id recordId, Exception e);
    App_Log__c create(String type, String module, String action, String message, String details, Id recordId, Exception e);

    App_Log__c log(String type, String systemName, String module, String action, String message, String details, Id recordId, Exception e);
    App_Log__c create(String type, String systemName, String module, String action, String message, String details, Id recordId, Exception e);

    App_Log__c log(App_Log__c appLog);
    List<App_Log__c> log(List<App_Log__c> appLogs);
}