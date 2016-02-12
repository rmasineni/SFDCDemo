/**
 * Base Class stores some data (like App Logs or Debug logs), which is better
 * if kept out of that class and stored in this class. This class will just have public static fields
 * that BaesClass will accept as requried.
 */
public class BaseClassDto {
	
    /**
     * Every time a callout has been made using sendHttpRequest call, the details of the call
     * is captured as a App Log record, which would need to be explicitly inserted into db
     * by the calling method. This can be done using saveAndClearHttpLogs();
     */
    public static List<App_Log__c> appLogs = new List<App_Log__c>();
    
    public class HttpOptions {
        public String module {get;set;}
        public String action {get;set;}
        public Integer timeout {get;set;}
        public Boolean compressed {get;set;}
    }
    
    public class HttpDetails {
        public DateTime requestDateTime {get;set;}
        public HttpRequest request {get;set;}
        public HttpResponse response {get;set;}
        public Map<String, String> requestHeaders {get;set;}
        public Map<String, String> responseHeaders {get{
            if (responseHeaders == null) {
                if (response != null) {
                    responseHeaders = new Map<String, String>();
                    for (String header : response.getHeaderKeys()) {
                        if (header == null) {
                             //sometimes headers are null
                            continue;
                        }
                        responseHeaders.put(header, response.getHeader(header));
                    }
                }
            }   

            return responseHeaders;
        }set;}
        public HttpOptions options {get;set;}
        public Exception httpException {get;set;}
        public Integer elapsedTime {get;set;}
        
        public String getRequestDetails() {
            String value = '';
            
            value += 'Http Request\n------------------------------------\n';
            if (request == null) {
                value += '\n';
            } else {
                value += 'DateTime: ' + requestDateTime + '\n';
                value += 'Options: ' + options + '\n';
                value += 'Method: ' + request.getMethod() + '\n';
                value += 'Url: ' + request.getEndpoint() + '\n';
                value += 'Headers: ' + toString(requestHeaders) + '\n';
                value += 'Body:\n' + request.getBody() + '\n';
            }
			value += '\n';
            
            return value;
        }

        public String getResponseDetails() {
            String value = '';
            value += 'Http Response\n------------------------------------\n';
            if (response == null) {
                value += '\n';
            } else {
                value += 'Elapsed Time: ' + elapsedTime + ' ms\n';
                value += 'Code: ' + response.getStatusCode() + '\n';
                value += 'Message: ' + response.getStatus() + '\n';
                value += 'Headers: ' + toString(responseHeaders) + '\n';
                value += 'Body:\n' + response.getBody() + '\n';
            }
			value += '\n';
            
            return value;
        }

        public String getExceptionDetails() {
            String value = '';
            value += 'Exception\n------------------------------------\n';
            if (httpException == null) {
                value += '\n';
            } else {
                value += getStackTrace(httpException);
            }
			value += '\n';
            
            return value;
        }

        public Boolean isSuccess() {
            return httpException != null && response != null 
                && response.getStatusCode() >= 200 && response.getStatusCode() <= 299;
        }
        
        public String getDetails() {
            return (getRequestDetails() + getResponseDetails() + getExceptionDetails()).trim();
        }
        
        public App_Log__c createAppLog() {
            String module = getClassAndMethodName('BaseClass');
            if (String.isBlank(module)) {
                module = 'BaseClass.sendHttpRequest';
            }
            String errorMessage = null;
            if (httpException != null) {
                errorMessage = httpException.getMessage();
                
            } else if (response != null) {
                errorMessage = response.getStatusCode() + ' ' + response.getStatus();
            }
            
            String message = isSuccess()?'Http callout successful':'Http callout unsuccessful [' + errorMessage + ']';
    		App_Log__c appLog = Sf.appLogger.create(isSuccess()?'Debug':'Error', 
				module, 'HttpCallout', message, 
                              getDetails(), null, null);

            appLog.System__c = new Url(request.getEndpoint()).getHost();
            return appLog;
        }
        
        /**
         * Returns the class and method name in Class.MethodName format based on
         * the current class stack, ignoring all lines matching the given string. This
         * ignore string can be used to skip class stack entries.
         */
        public String getClassAndMethodName(String ignoreString) {
            try {
                String[] lines = new SystemException().getStackTraceString().split('\n');
                for(String line : lines) {
                    if (line.indexOf(ignoreString) >= 0) {
                        continue;
                    }
                    return line.substringBetween('Class.', ':');
                }
            } catch (Exception e) {
                System.debug(e.getStackTraceString());
            }
        
            return null;
        }

        public String toString(Map<String, String> stringMap) {
            String value = null;
            if (stringMap != null) {
                for (String key : stringMap.keySet()) {
                    if (value != null) {
                        value += ', ';
                    } else {
                        value = '[';
                    }
                    
                    value += key+'=' + stringMap.get(key);
                }
                
                value += ']';
            }
            
            return value;
        }
        
        public String getStackTrace(Exception e) {
            String eString = e.getTypeName() + ': ' + e.getMessage() + '\n    at ' + e.getStackTraceString();
            if (e.getCause() != null) {
                eString += '\n' + getStackTrace(e.getCause());
            }
            
            return eString;
        }
        
    }
    
}