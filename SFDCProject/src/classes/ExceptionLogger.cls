public class ExceptionLogger {
    private static BaseClass utils = new BaseClass();
    private static Integer DetailsFieldLength = utils.getFieldLength('Exception__c', 'Details__c');
    
    public static Exception__c logException(Exception__c excp) {
        utils.debug('Coming to log exception ' + excp);
        
        if (BaseClass.exceptionRollbackSavePoint != null) {
            Database.rollback(BaseClass.exceptionRollbackSavePoint);
        }
        
        try {
          	insert excp;
        } catch (Exception e1) {
            utils.debug('Exception while logging the exception [' + excp + '] ' + utils.getStackTrace(e1));
        }
        
        return excp;
    }

    public static Exception__c logException(String module, String message, Exception e) {
        return logException(module, message, null, e);
    }
    
    public static Exception__c logException(String module, String message, String recordId, Exception e) {
    	return logException(module, message, null, recordId, e);
    }

    public static Exception__c logException(String module, String message, String objectName, String recordId, Exception e) {
        return logException(createException(module, message, objectName, recordId, e));
    }
    
    public static Exception__c logException(String module, String message, String details, String objectName, String recordId, Exception e) {
        return logException(createException(module, message, details, objectName, recordId, e));
    }

    public static Exception__c logException(String module, String message, String details) {
        return logException(module, message, details, (String) null);
    }

    public static Exception__c logException(String module, String message, String details, String recordId) {
        return logException(module, message, details, (String) null, recordId);
    }

    public static Exception__c logException(String module, String message, String details, String objectName, String recordId) {
        return logException(module, message, details, objectName, recordId, null, null);
    }

    public static Exception__c logException(String module, String message, String details, String objectName, String recordId, String clz, String method) {
        return logException(module, message, details, objectName, recordId, null, clz, method);
    }
    
    public static Exception__c logException(String module, String message, String details, String objectName, String recordId, String exceptionType, String clz, String method) {
        return logException(createException(module, message, details, objectName, recordId, exceptionType, clz, method));
    }
    
    public static Exception__c createException(String module, String message, Exception e) {
        return createException(module, message, null, e);
    }
    
    public static Exception__c createException(String module, String message, String recordId, Exception e) {
    	return createException(module, message, null, recordId, e);
    }

    public static Exception__c createException(String module, String message, String objectName, String recordId, Exception e) {
        return createException(module, message, null, objectName, recordId, e);
    }
    
    public static Exception__c createException(String module, String message, String details, String objectName, String recordId, Exception e) {
        String exceptionType = null;
        String clz = null;
        String method = null;
        
        if (e != null) {
            message = message != null?message:String.valueOf(utils.getRootException(e));
            details = details != null?details:utils.getStackTrace(e);
            exceptionType = e.getTypeName();
            
            try {
                //Stack trace sample is as follows. So we need to extract the 
                //Class.ExceptionTesting.generateException: line 12, column 27
                //AnonymousBlock: line 2, column 1
                String classMethodLine = null;
                Exception original = utils.getRootException(e);
                System.debug('Original stack trace \n ' + original.getStackTraceString());
                List<String> stacktraceLines = original.getStackTraceString().split('\n');
                String stackTraceLine = null;
                for (String line : stacktraceLines) {
                    if (line.indexOf('ExceptionLogger') < 0) {
                       	stackTraceLine = line;
                       	break;
                    }
                }
                
                System.debug('stackTraceLine=' + stackTraceLine);
                
                //Line should be of format 
                //Class.IKnockLeadSyncServiceImpl.syncLeadsToIKnock: line 349, column 1
                String[] tokens = stackTraceLine.split(':')[0].split('\\.');
                
                //First token is keyword Class
                
                //Second is class name
                if (clz == null) {
                    clz = tokens[1];
                }
                
                //Thrid is method name
                if (method == null && tokens.size() >= 3) {
                    method = tokens[2];
                }
            } catch (Exception e1) {
                System.debug('Error while trying to findout the Class/method ' + utils.getStackTrace(e1) + ' original exception ' + utils.getStackTrace(e));
            }
       	}
        
		return createException(module, message, details, objectName, recordId, exceptionType, clz, method);
    }

    public static Exception__c createException(String module, String message, String details) {
        return createException(module, message, details, null, (String) null);
    }
    
    public static Exception__c createException(String module, String message, String details, String recordId) {
        return createException(module, message, details, null, recordId);
    }

    public static Exception__c createException(String module, String message, String details, String objectName, String recordId) {
        return createException(module, message, details, objectName, recordId, null, null);
    }

    public static Exception__c createException(String module, String message, String details, String objectName, String recordId, String clz, String method) {
        return createException(module, message, details, objectName, recordId, null, clz, method);
    }
    
    public static Exception__c createException(String module, String message, String details, String objectName, String recordId, String exceptionType, String clz, String method) {
        Exception__c excp = new Exception__c(
            Module__c=utils.nullIfEmpty(module),
          	Class__c=clz,
            Method__c=method,
            Exception_Type__c=exceptionType
        );
        
        if (message != null) {
            if (message.length() >= 255) {
                message = message.substring(0, 252) + '...';
                excp.Message_Full__c = message;
                if (excp.Message_Full__c.length() > DetailsFieldLength) {
                    excp.Message_Full__c = excp.Message_Full__c.substring(0, DetailsFieldLength);
                }
            }
        }
        excp.Message__c = message;
        
        if (details != null && details.length() > DetailsFieldLength) {
            details = details.substring(0, DetailsFieldLength);
        }
        excp.Details__c = details;
        excp.Record_Id__c = recordId;
		
        System.debug('ObjectName before = ' + objectName);
        if (objectName == null && recordId != null) {
            try {
                objectName = utils.getSobjectName(recordId);
            } catch (Exception e) {
                System.debug('Error while deriving the object name from id ' + recordId + ' ' + utils.getStackTrace(e));
            }
        }
        excp.Object__c = objectName;
        System.debug('ObjectName after = ' + objectName);
        return excp;
    }
}