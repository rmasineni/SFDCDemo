public class AppLogServiceImpl implements AppLogService {
    
    //Max is 131072 but will keep it at 131000
    public static Integer DetailsMaxLength = 131000;
    public static Integer MessageMaxLength = 255;
    private static final BaseClass utils = new BaseClass();
    
    public App_Log__c logDebug(String module, String action, String message) {
        return log('Debug', module, action, message, null, null, null);
    }

    public App_Log__c logDebug(String module, String action, String message, String details) {
        return log('Debug', module, action, message, details, null, null);
    }
    
    public App_Log__c logDebug(String module, String action, String message, String details, Id recordId) {
        return log('Debug', module, action, message, details, recordId, null);
    }
    
    public App_Log__c logError(String module, String action, String message, Exception e) {
        return log('Error', module, action, message, null, null, e);
    }

    public App_Log__c logError(String module, String action, String message, String details, Exception e) {
        return log('Error', module, action, message, details, null, e);
    }
    
    public App_Log__c logError(String module, String action, String message, String details, Id recordId, Exception e) {
        return log('Error', module, action, message, details, recordId, e);
    }
	
    public App_Log__c createDebug(String module, String action, String message) {
        return create('Debug', module, action, message, null, null, null);
    }

    public App_Log__c createDebug(String module, String action, String message, String details) {
        return create('Debug', module, action, message, details, null, null);
    }
    
    public App_Log__c createDebug(String module, String action, String message, String details, Id recordId) {
        return create('Debug', module, action, message, details, recordId, null);
    }

    public App_Log__c createError(String module, String action, String message, Exception e) {
        return create('Error', module, action, message, null, null, e);
    }

    public App_Log__c createError(String module, String action, String message, String details, Exception e) {
        return create('Error', module, action, message, details, null, e);
    }
    
    public App_Log__c createError(String module, String action, String message, String details, Id recordId, Exception e) {
        return create('Error', module, action, message, details, recordId, e);
    }

    public App_Log__c log(String type, String module, String action, String message, String details, Id recordId, Exception e) {
		return log(type, null, module, action, message, details, recordId, e);
    }

    public App_Log__c log(String module, String action, String message, String details, Id recordId, Exception e) {
        return log(null, null, module, action, message, details, recordId, e);
    }
    
    public App_Log__c create(String module, String action, String message, String details, Id recordId, Exception e) {
        return create(null, null, module, action, message, details, recordId, e);
    }

    public App_Log__c create(String type, String module, String action, String message, String details, Id recordId, Exception e) {
        return create(type, null, module, action, message, details, recordId, e);
    }

    public App_Log__c log(String type, String systemName, String module, String action, String message, String details, Id recordId, Exception e) {
		return log(create(type, systemName, module, action, message, details, recordId, e));
    }

    public App_Log__c processFields(App_Log__c appLog, Exception e) {
        return create(appLog, 'Error', 
			appLog.System__c, appLog.Module__c, 
           	appLog.Action__c, appLog.Message__c, 
            utils.join(new String[]{appLog.Details__c, appLog.Details2__c, appLog.Details3__c}, ''), 
			appLog.Record_Id__c, e);
    }
    
    public App_Log__c processFields(App_Log__c appLog) {
        return create(appLog, appLog.Type__c, 
			appLog.System__c, appLog.Module__c, 
           	appLog.Action__c, appLog.Message__c, 
            utils.join(new String[]{appLog.Details__c, appLog.Details2__c, appLog.Details3__c}, ''), 
			appLog.Record_Id__c, null);
    }

    public App_Log__c create(String type, String systemName, String module, String action, String message, String details, Id recordId, Exception e) {
    	return create(null, type, systemName, module, action, message, details, recordId, e);
    }
    
    public App_Log__c create(App_Log__c appLog, String type, String systemName, String module, String action, String message, String details, Id recordId, Exception e) {
        if (applog == null) {
            appLog = new App_Log__c();
        }

        appLog.System__c = systemName;
        appLog.Record_Id__c = (Id) recordId;
            
        if (String.isBlank(type)) {
            type = e==null?'Debug':'Error';
        }
        applog.Type__c = type;
        
        if (e != null && (String.isBlank(module) || String.isBlank(action))) {
            String[] classMethod = getClassAndMethod(e);
            
            if (String.isBlank(module)) {
                module = classMethod[0];
            }

            if (String.isBlank(action)) {
                action = classMethod[1];
            }
        }
        applog.Module__c = module;
        applog.Action__c = action;
        
        if (recordId != null) {
            appLog.Sobject__c =  utils.getSobjectName(recordId);
        }
        
        if (e != null && String.isBlank(message)) {
            message = e.getMessage();
        }
        
        if (message != null && message.length() > MessageMaxLength) {
            if (String.isBlank(details)) {
                details = 'Message:' + message;
            } else {
				details = 'Message:' + message + '\n\nDetails:' + details;
            }
            message = message.substring(0, MessageMaxLength);
        }
        applog.Message__c = message;
		
        if (e != null) {
            if (String.isBlank(details)) {
                details = 'Exception:\n' + utils.getExceptionDetails(e);
            } else {
                details = details + '\n\nException:\n' + utils.getExceptionDetails(e);
            }
        }
        
        //If details length is exceeding max length, split into second field.
        if (!String.isBlank(details)) {
            List<String> splits = utils.split(details, DetailsMaxLength);
            for (Integer i = 0; i < Math.min(splits.size(), 5); i++) {
                appLog.put('Details' + (i == 0?'':String.valueOf(i+1)) + '__c', splits.get(i));
            }
        }

        return applog;
    }
    
    public App_Log__c log(App_Log__c appLog) {
        return log(new App_Log__c[]{appLog}).get(0);
    }
    
    public List<App_Log__c> log(List<App_Log__c> appLogs) {
        try {
            if (Sf.settingsService.getBoolean('AppLoggerSkipLogging', false)) {
                return appLogs;
            }

            for (App_Log__c appLog : appLogs) {
                processFields(appLog);
            }
            
            insert appLogs;
        } catch (Exception e) {
            System.debug(new BaseClass().getExceptionDetails(e));
        }

        return appLogs;
    }

    public String[] getClassAndMethod(Exception e) {
        try {
            String classMethodLine = null;
            Exception original = utils.getRootException(e);

            List<String> stacktraceLines = original.getStackTraceString().split('\n');
            
            System.debug('Exception lines ' + stacktraceLines);
            
            //Get the first line.
            String stackTraceLine = stacktraceLines.get(0);
            
            //Line should be of format 
            //Class.IKnockLeadSyncServiceImpl.syncLeadsToIKnock: line 349, column 1
            String[] tokens = stackTraceLine.split(':')[0].split('\\.');
            
            System.debug('Token after split ' + tokens);
            
            //First token is keyword Class
            
            //Second is class name
            String[] resp = new String[2];
            resp[0] = tokens[1];
            
            //Thrid is method name
            resp[1] = tokens.size() >= 3?tokens[2]:null;
            
            return resp;
        } catch (Exception e1) {
            System.debug('Excpetion while getting the class and method name from Exeption ' + e + ' ' + utils.getStackTrace(e1));
        }
        
        return new String[2];
    }
}