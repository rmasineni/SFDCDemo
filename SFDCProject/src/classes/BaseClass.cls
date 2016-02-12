public with sharing virtual class BaseClass {

    public static String Status_ToBeSynced = 'To Be Synced';
    public static String Status_SyncSuccess = 'Sync Success';
    public static String Status_SyncError = 'Sync Error';
    public static String Status_SyncNotApplicable = 'Sync Not Applicable';
    public static String Status_UpdatedDuringSync = 'Updated During Sync Process';
    
    //This flag stores the info to indicate if current user is api only user.
    //this value is determined based on the profile. So instead of querying
    //each time, we will initialize once and reuse each time. As static values
    //will get initialized to null, caching will not be a problem.
    //
    //This is initialized in isApiOnlyUser() method
    private static Boolean isCurrentUserIsApiOnlyUser = null;

    //This field holds the current user's profile name. As we will have to execute
    //a soql to get the name, caching it here let's us reuse it and save the soql.
	private static String currentUserProfileName = null;
    
    //This field holds the current user's role name. As we will have to execute
    //a soql to get the name, caching it here let's us reuse it and save the soql.
	private static String currentUserRoleName = null;

    /**
     * Sometimes when we want to catch exception and log it, we would have to
     * roll back the txs to a defined point. Batch which is calling
     * the service cannot create a save point as that is constituted as DML and after
     * that you cannot make any DMLs. So this is a Static variable, which any class
     * can set to some save point, which can be later used to roll back.
     */ 
    public static SavePoint exceptionRollbackSavePoint = null;
    
    /**
     * Stores all errors that been logged since the start of the request.
     * 
     * This could be used to log to vf page so we can easily debug.
     */
    private static List<String> errorLog = new List<String>();
    
    /**
     * Date Time that should be returned whenever subclass class getCurrentDateTime while system
     * is running test classes.
     * 
     * If this value is null, then DateTime.now() value is returned.
     */
    public static DateTime testCurrentDateTime = null;

    /**
     * Date that should be returned whenever subclass class getCurrentDate while system
     * is running test classes.
     * 
     * If this value is null, then Date.today() value is returned.
     */
    public static Date testCurrentDate = null;
    
    /**
     * General parameters that can be referred in the code primarly
     * while running the test. This can be used to shield any random value
     */
    public static Map<String, Object> testParams = new Map<String, Object>();

    /**
     * Method compares if values are changed between valule1 and value2, taking into consideration the nulls.
     * 
     * If both are null, it would return false. If One of the value is null, then returns true.
     * Otherwise, it will compare the values and returns the result.
     * 
     */
    public Boolean isChanged(Object value1, Object value2) {
        return isChanged(value1, value2, false);
    }
    
    public Boolean isChanged(Object value1, Object value2, boolean nullSameAsEmpty) {
        
       	if (nullSameAsEmpty && value1 instanceof String ) {
            value1 = nullIfEmpty((String) value1);
        }
    
       	if (nullSameAsEmpty && value2 instanceof String ) {
            value2 = nullIfEmpty((String) value2);
        }

        boolean response = false;
        
        if (value1 == null && value2 == null) {
            response = false;
        
        } else if (value1 == null || value2 == null) {
            response = true;
        
       	} else if (value1 instanceof String && value2 instanceof String) {
            response = !((String) value1).equals((String) value2);

        } else {
            info('Coming to non-string comparision with flag ' + nullSameAsEmpty);
        	response = !(value1 == value2);
        }
        
        debug ('Comparing value1=' + value1 + ' to value2=' + value2 + ' with response ' + response);

        return response;
    }

    public PageReference redirectToId() {
        return redirectToId(getRequiredParameter('id'));
    }
    
    public PageReference redirectToId(Id idValue) {
        return redirect('/' + idValue);
    }

    public PageReference redirect(String url) {
        PageReference pageRef = new PageReference(url);
        pageRef.setRedirect(true);
        return pageRef;
    }

    public List<String> getErrorLog() {
        return errorLog;
    }

    /**
     * Creates a String map from given string list. If there are duplicates values in the list, they will be deduped into one entry
     * in the map. Both key and value in the map would contain the same value.
     * 
     * This is typically used if you want to look up a value in the list multiple times, it is efficient to convert to map
     * and hash lookup than looping through list each time, especially if it contains many entries.
     */
    public Map<String, String> getStringMap(List<String> values) {
    	Map<String, String> stringMap = new Map<String, String>();
        if (values == null) {
            return stringMap;
        }
        
        for (String value : values) {
            stringMap.put(value, value);
        }
        
        return stringMap;
    }
    
    public Map<Id, SObject> getIdMap(List<Sobject> objects) {
        return getIdMap(objects, 'Id');
    }

    public Map<Id, SObject> getIdMap(List<Sobject> objects, String field) {
        Map<Id, SObject> idMap = new Map<Id, SOBject>();
        if (objects == null) {
            return idMap;
        }
        
        for (SObject obj : objects) {
            Id id = (Id)obj.get(field);
            if (id != null) {
                idMap.put(id, obj);
            }
        }
        
        return idMap;
    }

    /**
     * Convenience method for getStringMap(List<SObjects>, String, String) with convertCaseTo being null and trim being true.
     */
    public Map<String, SObject> getStringMap(List<Sobject> objects, String field) {
    	return getStringMap(objects, field, null, true);
    }
	
    /**
     * Creates a map of String => SObject out of specified SObjects, using the value of field.
     * The value of String field is case converted according to convertCaseTo parameter.
     * If it is "uppercase" (ignore case), then String value is converted to uppercase before adding to map. 
     * If it is "uppercase" (ignore case), then String value is converted to lowe case before adding to map.
     * All other cases (either, null or some other string), then there is no case conversion.
     * 
     * The specified field could be of any type, it will be converted to string. If the value
     * of the field is null, then that SObject is ignored.
     * 
     * If multiple sobjects have same value, then last sobject in the given list, will be added to map.
     */
    public Map<String, SObject> getStringMap(List<Sobject> objects, String field, String convertCaseTo, boolean trim) {
        Map<String, SObject> stringMap = new Map<String, SOBject>();
        if (objects == null) {
            return stringMap;
        }
        for (SObject obj : objects) {
            if (obj.get(field) == null) {
                continue;
            }
            
            String value = String.valueOf(obj.get(field));
            if (trim) {
                value = value.trim();
            }
            
            if (equalsIc(convertCaseTo, 'uppercase')) {
                stringMap.put(value.toUpperCase(), obj);
                
            } else if (equalsIc(convertCaseTo, 'lowercase')) {
                stringMap.put(value.toLowerCase(), obj);
                
            } else {
                stringMap.put(value, obj);
            }
            
        }
        
        return stringMap;
    }

    public List<Id> getUniqueIdList(List<Sobject> sObjects) {
    	return getIdList(sobjects, 'Id', true);
    }
    
    public List<Id> getUniqueIdList(List<Sobject> sObjects, String field) {
        return getIdList(sObjects, field, true);
    }

    public List<Id> getIdList(List<Sobject> sObjects, String field, Boolean unique) {
        List<Id> idList = new List<Id>();
        Map<Id, Id> uniqueMap = new Map<Id, Id>(); 

        if (sObjects == null) {
            return idList;
        }
        
        for(SObject sobj : sObjects) {
            if (isEmpty((String) sobj.get(field))) {
                continue;
            }
            
            Id value = (Id) sobj.get(field);
            if (value == null) {
                continue;
            }
            
            if (unique && uniqueMap.get(value) != null) {
                continue;
            } 

            idList.add(value);
            uniqueMap.put(value, value);
        }
        
        return idList;
    }

    public List<String> getUniqueStringList(List<Sobject> sObjects, String field) {
        return getStringList(sObjects, field, true);
    }
	
    /**
     * Extracts the String values from specified sOBjects for specified field, creates a list of those values
     * and returns the list.
     * 
     * If uniqe is true, only the unique String values are returned. String values are not case-converted or trimmed.
     */
    public List<String> getStringList(List<Sobject> sObjects, String field, Boolean unique) {
        List<String> values = new List<String>();
        Map<String, String> uniqueMap = new Map<String, String>(); 
        if (sObjects == null) {
            return values;
        }
        
        for(SObject sobj : sObjects) {
            if (isEmpty((String) sobj.get(field))) {
                continue;
            }
            
            String value = (String) sobj.get(field);
            if (value == null) {
                continue;
            }
            
            if (unique && uniqueMap.get(value) != null) {
                continue;
            } 

            values.add(value);
            uniqueMap.put(value, value);
        }
        
        return values;
    }

    /**
     * Adds a info message with specified label to the ApexMessages.
     */
    public void addInfoMessage(String messageString) {
        ApexPages.Message message = new ApexPages.Message(ApexPages.severity.INFO, messageString);
        ApexPages.addMessage(message);
    }

    /**
     * Adds the error message with specified label to the ApexMessages.
     */
    public void addErrorMessage(String messageString) {
        ApexPages.Message message = new ApexPages.Message(ApexPages.severity.ERROR, messageString);
        ApexPages.addMessage(message);
        debug(messageString);
    }

    public List<ApexPages.Message> getErrorMessages() {
        return getMessages(ApexPages.Severity.ERROR);
    }
    
    public List<ApexPages.Message> getInfoMessages() {
        return getMessages(ApexPages.Severity.INFO);
    }

    public List<ApexPages.Message> getMessages(ApexPages.Severity severity) {
        List<ApexPages.Message> messages = new List<ApexPages.Message>();
        for(ApexPages.Message msg : ApexPages.getMessages()) {
            if (msg.getSeverity() == severity) {
                messages.add(msg);
            }
        }
        
        return messages;
    }

    public void addErrorMessage(Exception e) {
        if (e instanceof BusinessException) {
            addErrorMessage(e.getMessage());
        } else {
            addErrorMessage(String.valueOf(e));
        }
        errorLog.add(getStackTrace(e));
        debug(getStackTrace(e));
    }
	
    /**
     * Returns true if there are any messages with severity of ERROR in Current page context.
     */
    public Boolean getHasErrorMessages() {
        return ApexPages.hasMessages(ApexPages.severity.ERROR);
    }
	
    /**
     * Checks if there are any error messages in the page context which contains the specified string (ignoring the case).
     */
    public Boolean getHasErrorMessagesContains(String summaryContains) {
        if (summaryContains == null) {
			return false;        
        }        

        for(ApexPages.Message message : ApexPages.getMessages()) {
            if (message.getSeverity() == ApexPages.severity.ERROR && message.getSummary().toLowerCase().indexOf(summaryContains.toLowerCase()) >= 0) {
                return true;
            }
        }
        
        return false;
    }

    public PageReference getCurrentPage() {
        return System.currentPageReference();
    }

    public String getRequiredParameter(String paramName) {
        String value = getParameter(paramName, null);
        if (isEmpty(value)) {
            throw new BusinessException('Application was expecting a value for URL Parameter (' + paramName + ') but it is either not present or empty.');
        }
        
        return value;
    }

    public String getParameter(String paramName) {
        return getParameter(paramName, null);
    }

    public String getParameter(String paramName, String defaultValue) {
        PageReference page = getCurrentPage();
        if (page == null) {
            debug('Current page is null while getting the parameter ' + paramName);
            return null;
        }
        
        Map<String, String> parameters = page.getParameters();
        String value = parameters.get(paramName);
        if (value == null || (value == '' && defaultValue != null)) {
            debug('Parameters value is null for ' + paramName + ' so assigning the default value=' + defaultValue);
            value = defaultValue;
        }

        debug('Returning parameter ' + paramName + '=' + value);
        return value;
    }

    public SObject firstNonNull(SObject obj1, SObject obj2) {
        return obj1!=null?obj1:obj2;
    }

    public Object firstNonNull(Object obj1, Object obj2) {
        return obj1!=null?obj1:obj2;
    }

    public String getExceptionDetails(Exception e) {
        String details = '';

        if (e instanceof UnsuccessfulHttpResponseException) {
            UnsuccessfulHttpResponseException httpe = (UnsuccessfulHttpResponseException) e;
	        details += '\n\nHttp Details:' + httpe.toString() ;
        }

        details += '\n\nException:\n' + getStackTrace(e);
        
        return details.trim();
    }
    
    public String getStackTrace() {
        return getStackTrace(new SystemException());
    }
    
    public String getStackTrace(Exception e) {
        String eString = e.getTypeName() + ': ' + e.getMessage() + '\n    at ' + e.getStackTraceString();
        if (e.getCause() != null) {
            eString += '\n' + getStackTrace(e.getCause());
        }
        
        return eString;
    }

    /**
     * This method is from http://boards.developerforce.com/t5/forums/forumtopicprintpage/board-id/apex/message-id/27054/print-single-message/false/page/1
     */     
    public String formatNumber(Decimal val) {
    	return formatNumber(val, 2);
    }
    
    public String formatNumber(Decimal val, Integer precision) {
        String osep = ',';
        String nsep = '.';
        String s, tmp;
        Integer i = 6;
        s = val.setScale(precision).toPlainString().replace(osep, nsep);
        while(s.length() > i) {
            tmp = s.substring(0, s.length() - i) + osep + s.substring(s.length() - i);
            s = tmp;
            i += 4;
        }
        return s;
    }

    public String formatAmount(Decimal val) {
        return formatNumber(val, 2);
    }

    public DateTime getCurrentDateTime() {
        if (Test.isRunningTest() && testCurrentDateTime != null) {
            return testCurrentDateTime;
        }
        
        return DateTime.now();
    }

    public Date getCurrentDate() {
        if (Test.isRunningTest() && testCurrentDate != null) {
            return testCurrentDate;
        }
        
        return Date.today();
    }

    public String getCurrentUtcIsoDateTime() {
        return formatAsUtcIsoDateTime(getCurrentDateTime());
    }

    public DateTime parseAsUtcIsoDateTime(String dateTimeString) {
        return (DateTime)json.deserialize('"' + dateTimeString + '"', DateTime.class);
    }
    
    public String formatAsUtcIsoDateTime(DateTime dateTimeVal) {
        if (dateTimeVal == null) {
            return null;
        }
        return dateTimeVal.formatGmt('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
    }

    public String getDateTimeFormattedForId() {
    	return getDateTimeFormattedForId(getCurrentDateTime());
    }
    public String getDateTimeFormattedForId(DateTime dateTimeVal) {
        if (dateTimeVal == null) {
            return null;
        }
        return dateTimeVal.formatGmt('yyyyMMddHHmmss');
    }
    
    /**
     * Parses the ISO date formatted string to date object. Date must be formatted
     * as YYYY-MM-DD. For ex., 2015-07-15
     */
    public Date parseIsoDate(String isoDate) {
        if (String.isBlank(isoDate)){
            return null;
        }
        
    	String[] splits = isoDate.split('-');
        return Date.newInstance(Integer.valueOf(splits[0]), Integer.valueOf(splits[1]), Integer.valueOf(splits[2]));
    }
    
    public String getRandomString() {
        return String.valueOf(Math.abs(Crypto.getRandomInteger()));
    }

    public String getRandomLongString() {
        return String.valueOf(Math.abs(Crypto.getRandomLong()));
    }

    public String getRandomString(Integer length) {
        String randomString = getRandomLongString();
        while(true) {
            if (randomString.length() == length) {
                break;
            }

            if (randomString.length() < length) {
                randomString += getRandomLongString();
            }

            if (randomString.length() > length) {
                randomString = randomString.substring(0, length);
                break;
            }
        }

        return randomString;
    }
	
    /**
     * Generates a random number between 0 and given upper limit (inclusive)
     */
    public Integer getRandomInteger(Integer upper) {
		return getRandomInteger(0, upper);
    }

    /**
     * Generates a random number between lower (inclusive) and upper (inclusive)
     */
    public Integer getRandomInteger(Integer lower, Integer upper) {
		return Math.round(Math.random() * (upper - lower)) + lower;
    }
    
    public String join(String value1, String value2, String separator){
        return join(new String[]{value1, value2}, separator, true);
    }
    
    public String join(List<String> strings, String separator){
        return join(strings, separator, true);
    }
    
    public String joinWithNulls(List<String> strings, String separator){
        return join(strings, separator, false);
    }
    
    public String join(List<String> strings, String separator, Boolean skipNulls){
        if(strings == null){
            return null;
        }
        if (separator == null) {
            separator = ', ';
        }
        String joinedString = null;
        for(String value : strings) {
            if (skipNulls && value == null) {
                continue;
            }
            
            if (value == null) {
                value = '';
            }
            
            if (joinedString == null) {
                joinedString = value;
            } else {
                joinedString += separator + value;
            }
        }
        
        return joinedString;
    }
    
    public void debug(Object value) {
        System.debug(value);
    }
        
    public void info(Object value) {
        System.debug(System.LoggingLevel.INFO, value);
    }

    public String firstNonEmpty(String value1, String value2) {
        if (isNotEmpty(value1)) {
            return value1;
        }

        return value2;
    }

    public String joinIfNotEmpty(String value1, String value2, String value3, String separator) {
        return joinIfNotEmpty(joinIfNotEmpty(value1, value2, separator), value3, separator);
    }
    
    public String joinIfNotEmpty(String value1, String value2, String separator) {
        if (value1 == null && value2 == null) {
            return null;
        }
        
        String output = emptyIfNull(value1);
        
        if (isNotEmpty(value2)) {
            if (isNotEmpty(output)) {
                output += emptyIfNull(separator);
            }
            
            output += value2;
        }
        
        return output;
    }
    
    public Boolean isNotEmpty(String value) {
        return !isEmpty(value);
    }
    
    public Boolean isEmpty(String value) {
        return String.isBlank(value);
    }

    public Boolean isAllBlank(String value1, String value2) {
        return String.isBlank(value1) && String.isBlank(value2);
    }

    public Boolean isNullorZero(Decimal value) {
        return value == null || value == 0.0;
    }
    
    public String emptyIfNull (String value) {
        return value == null?'':value;
    }
    
    public boolean equalsIc(String stringToCompare, String value1) {
        if (stringToCompare == null || value1 == null) {
            return false;
        }
        
        return stringToCompare.equalsIgnoreCase(value1);
    }

    public boolean equalsIc(String stringToCompare, String value1, String value2) {
        return equalsIc(stringToCompare, value1) || equalsIc(stringToCompare, value2);
    }

    public boolean equalsIcAny(String stringToCompare, List<String> values) {
        if (stringToCompare == null || values == null) {
            return false;
        }
        
        for(String value : values) {
            if(stringToCompare.equalsIgnoreCase(value)) {
                return true;
            }
        }
        
        return false;
    }
    
    public String escapeString(String value, String escapeMode) {
        if (isNotEmpty(escapeMode)) {
            if (equalsIc('xml', escapeMode)) {
                value = value==null?null:value.escapeXml();
                
            } else if (equalsIc('html', escapeMode)) {
                value = value==null?null:value.escapeHtml4();
                
            } else if (equalsIc('url', escapeMode)) {
                if (value == null) {
                    value = '';
                } else {
	                value = EncodingUtil.urlEncode(value, 'UTF-8');
                }
            } else {
                throw new BusinessException('Unrecognized escape mode ' + escapeMode);
            }
        }
        
        return value;
    }
    
    public HttpResponse sendHttpRequest(HttpRequest httpRequest) {
        HttpDetails httpDetails = new HttpDetails();
        httpDetails.request = httpRequest;
        return sendHttpRequest(httpDetails);
    }
    
    public HttpResponse sendHttpRequest(HttpDetails httpDetails) {
        try {
            
            Stopwatch sw = new StopWatch();
            info('Sending the http request. ' + httpDetails.getRequestDetails());

            if (Test.isRunningTest() && testParams.get('HttpCalloutMock') != null) {
                httpDetails.response = ((HttpCalloutMock) testParams.get('HttpCalloutMock')).respond(httpDetails.request);
            } else {
				httpDetails.response = new Http().send(httpDetails.request);
            }
            
            info('Received the http response in ' + sw.elapsedTime() + ' ms. ' + httpDetails.getResponseDetails());

			return httpDetails.response;

        } catch(Exception e) {
            throw new SystemException('Exception while sending http request ' + httpDetails.request + ' ' + getStackTrace(e), e);
        }
    }
    
    public String createHttpParmsString(Map<String, String> parms) {
        return joinMap(parms, '&', '=', 'url');
    }
    
    public String httpPost (String url, String body) {
        return httpPost(url, body, null);
    }

    public String httpPost (String url, String body, Map<String, String> headers) {
    	return httpPost(url, body, headers, null);
    }

    public class HttpDetails {
        public HttpRequest request {get;set;}
        public HttpResponse response {get;set;}
        public Map<String, String> requestHeaders {get;set;}
        
        public String getRequestDetails() {
            return 'method=' + request.getMethod() + ', url=' + request.getEndpoint() 
				+ ', headers=' + requestHeaders + ', body=' + request.getBody();
        }

        public String getResponseDetails() {
            String headers = null;
            for (String header : response.getHeaderKeys()) {
                if (header == null) {
                    continue; //sometimes headers are null
                }
                headers = (headers==null?'':headers + ', ') + header + '=' + response.getHeader(header);
            }
            
            return 'code=' + response.getStatusCode() + ', status=' + response.getStatus() + ', headers=[' + headers 
				+ '], body=' + response.getBody();
        }
        
        override public String toString() {
            return 'Request\n=========\n' + getRequestDetails() + '\n\nResponse\n=========\n' + getResponseDetails();
        }
    }
    
    public String httpPost (String url, String body, Map<String, String> headers, Integer timeout) {
		return httpPostDetails(url, body, headers, timeout).response.getBody();    
    }
    
    public HttpDetails httpPostDetails (String url, String body, Map<String, String> headers, Integer timeout) {
        HttpRequest req = new HttpRequest();
        if (headers != null) {
            info('Headers ' + headers);
            for(String key : headers.keySet()) {
                req.setHeader(key, headers.get(key));
            }
        }
        
        req.setEndpoint(url);
        req.setMethod('POST');
        if (timeout != null) {
            req.setTimeout(timeout);
        } else {
            req.setTimeout(60 * 1000);
        }
        if (body != null) {
        	req.setBody(body);
        }
        HttpDetails details = new HttpDetails();
        details.request = req;
        details.requestHeaders = headers;

        HttpResponse resp = sendHttpRequest(details);
        details.response = resp;
        
        if (resp.getStatusCode() != 200) {
            throw new UnsuccessfulHttpResponseException(req, resp);
        }
        
        return details;
    }
    

    public String joinMap(Map<String, String> parms) {
        return joinMap(parms, null, null, null);
    }
    
    public String joinMap(Map<String, String> parms, String fieldSeparator, String keyValueSeparator) {
        return joinMap(parms, fieldSeparator, keyValueSeparator, null);
    }
    
    public String joinMap(Map<String, String> parms, String fieldSeparator, String keyValueSeparator, String escapeMode) {
        String output = '';
        
        if (parms == null) {
            return null;
        }
        
        if (fieldSeparator == null) {
            fieldSeparator = ', ';
        }
        
        if (keyValueSeparator == null) {
            keyValueSeparator = '=';
        }

        for(String key : parms.keySet()) {
            if (isNotEmpty(output)) {
                output += fieldSeparator;
            }
            
            output += key + keyValueSeparator + escapeString(parms.get(key), escapeMode);
        }
        
        return output;
    }
    
    public String httpGet (String url) {
        return httpGet(url, null, null, null);
    }

    public String httpGet (String url, Integer timeout) {
        return httpGet(url, null, null, timeout);
    }

    public String httpGet (String url, Map<String, String> parms) {
        return httpGet(url, null, parms, null);
    }

    public String httpGet (String url, Map<String, String> parms, Integer timeout) {
        return httpGet(url, null, parms, timeout);
    }
    
    public String httpGet (String url, Map<String, String> headers, Map<String, String> parms, Integer timeout) {
        HttpDetails details = httpGetDetails(url, headers, parms, timeout);
        return details.response.getBody();
    }
    
    public HttpDetails httpGetDetails (String url, Map<String, String> headers, Map<String, String> parms, Integer timeout) {
        if (parms != null) {
            String parmsString = joinMap(parms, '&', '=', 'url');
            
            if (url.indexOf('?') >= 0) {
                url += '&' + parmsString;
            } else {
                url += '?' + parmsString;
            }
        }
        
        HttpRequest req = new HttpRequest();

        if (headers != null) {
            for(String key : headers.keySet()) {
                req.setHeader(key, headers.get(key));
            }
        }
        
        req.setEndpoint(url);
        req.setMethod('GET');
        if (timeout != null) {
            req.setTimeout(timeout);
        } else {
            req.setTimeout(60 * 1000);
        }

        HttpDetails details = new HttpDetails();
        details.request = req;
        details.requestHeaders = headers;

        HttpResponse resp = sendHttpRequest(details);
        details.response = resp;
        
        if (resp.getStatusCode() != 200) {
            throw new UnsuccessfulHttpResponseException(req, resp);
        }

        return details;
    }

    public String replaceMergeTokensWithUrlEncode(String value, Map<String, String> tokens) {
        debug('Value [' + value + '] before merging with tokens [' + tokens + ']');
        Map<String, String> urlEncodedTokens = new Map<String, String>();
        if (tokens != null) {
            for (String key : tokens.keySet()) {
                urlEncodedTokens.put(key, urlEncode(tokens.get(key)));
            }
        }
        
        value = replaceMergeTokens(value, urlEncodedTokens);
		debug('Value [' + value + '] after merging with tokens [' + tokens + ']');        
        
        return value;
    }
    
    public String replaceMergeTokens(String value, Map<String, String> tokens) {
        debug('Value [' + value + '] before merging with tokens [' + tokens + ']');
        if (isEmpty(value) || tokens == null) {
            return value;
        }

        for (String token : tokens.keyset()) {
            String tokenValue = tokens.get(token);
            value = replaceMergeToken(value, token, tokenValue);
        }

        debug('Value [' + value + '] after merging with tokens [' + tokens + ']');
        
        return value;
    }
    
    public String replaceMergeToken(String message, String token, String value) {
        if (message == null) {
            return null;
        }
        
        //There are special chars which needs to be replaced in value.
        value = emptyIfNull(value).replaceAll('\\$', '\\\\\\$');
        return message.replaceAll('\\{' + token + '\\}', value);
    }
    
    public String generateVerificationToken() {
        
        String randomString = formatAsUtcIsoDateTime(getCurrentDateTime()) + getRandomLongString();
        String key = EncodingUtil.base64Encode(Crypto.generateDigest('SHA-256', Blob.valueOf(randomString)));
        String urlSafeKey = Encodingutil.urlEncode(key, 'UTF-8').replaceAll('%','_');
        
        if (urlSafeKey.length() > 255) {
            urlSafeKey =  urlSafeKey.substring(0, 254); 
        }
        
        return urlSafeKey;
    }
    
    public EmailTemplate getEmailTemplate(String emailTemplateName) {
        EmailTemplate emailTemplate = null;
        try {
            emailTemplate = [select Id, Body, HtmlValue, IsActive, Markup, Name, Subject, TemplateType from EmailTemplate WHERE developerName = :emailTemplateName limit 1];
        } catch (Exception e) {
            throw new BusinessException('Email template is not configured with name=' + emailTemplateName);
        }
        
        return emailTemplate;
    }

    public void sendEmail(List<String> toAddresses, String subject, String body) {
        sendEmail(toAddresses, subject, body, false);
    }    
    
    public void sendEmail(List<String> toAddresses, String subject, String body, Boolean htmlBody) {
    
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setSubject(subject);
        if (htmlBody) {
        	mail.setHtmlBody(body);
        } else {
        	mail.setPlainTextBody(body);
        }
        mail.setToAddresses(toAddresses);
		debug('Sending email ' + mail);
        
		Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});
    }

    public EmailTemplate sendEmail(String emailTemplateName, String orgwideEmailAddress, Id receipientId, Id relatedToId, Boolean saveAsActivity) {
        debug('Sending email using emailTemplateName=' + emailTemplateName + ', orgwideEmailAddress=' + orgwideEmailAddress 
            + ', receipientId=' + receipientId + ', relatedToId=' + relatedToId + ', saveAsActivity=' + saveAsActivity);
        
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        
        EmailTemplate emailTemplate = getEmailTemplate(emailTemplateName);
        
        if (isNotEmpty(orgwideEmailAddress)) {
            OrgWideEmailAddress orgwideEmail = null; 
            try {
                orgwideEmail = [select Address, Id from OrgWideEmailAddress where address =:orgwideEmailAddress limit 1];
            } catch (Exception e) {
               throw new BusinessException('Org wide email address is not configured with email=' + orgwideEmailAddress);
            }
            
            mail.setOrgWideEmailAddressId(orgwideEmail.id);
        }
        
        mail.setTemplateId(emailTemplate.id);
        mail.setTargetObjectId(receipientId);
        mail.setSaveAsActivity(saveAsActivity);
        
        if (relatedToId != null) {
            mail.setWhatId(relatedToId);
        }

        Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});
        
        return emailTemplate;
    }
    
    /**
     * There is no good way to induce some sleep into the execution thread in Salesforce. This call simulates the sleep by doing
     * very time conuming work. This is not the best way to do it, but it gets the job done.
     */
    public void sleep(Integer milliSeconds) {
        Long startingTime = System.now().getTime();
        while (System.now().getTime() - startingTime < milliSeconds)  {
            getRandomLongString();
        }
    }

    public void checkNotNull(Object value, String paramName) {
        if(value == null) {
            throw new BusinessException('Parameter (' + paramName + ') value cannot be null');
        }
    }

    public void checkNotEmpty(String value, String paramName) {
        if(isEmpty(value)) {
            throw new BusinessException('Parameter (' + paramName + ') value cannot be null or empty');
        }
    }
    
    public String urlEncode(String value) {
        return EncodingUtil.urlEncode(value, 'UTF-8');
    }

    public String base64Encode(String value) {
        return EncodingUtil.base64Encode(Blob.valueOf(value));
    }

    public String urlSafeBase64Encode(Blob input) {
        //URL safe encoding uses - (instead of +) and _ (instead of /)
        String encoded = EncodingUtil.base64Encode(input);
        encoded = encoded.replaceAll('\\+', '-');
        encoded = encoded.replaceAll('/', '_');
        encoded = encoded.replaceAll('=', '');
        return encoded;
    }

    public String urlSafeBase64Encode(String input) {
        return urlSafeBase64Encode(Blob.valueOf(input));
    }
    
    /**
     * Method checks if specified field (should be of type Boolean) has value true in **any** of the specified records. If so, returns true else returns false.
     */
    public Boolean isTrueInAny(List<SObject> sobjs, String field) {
        if (sobjs == null || field == null) {
            return false;
        }
        
        for(Sobject sobj : sobjs) {
            if ((Boolean) sobj.get(field)) {
                return true;
            }
        }
        
        return false;
    }
    
    /**
     * Method checks if specified field (should be of type Boolean) has value true in **all** of the specified records. If so, returns true else returns false.
     */
    public Boolean isTrueInAll(List<SObject> sobjs, String field) {
        if (sobjs == null || field == null) {
            return false;
        }

        for(Sobject sobj : sobjs) {
            if (!((Boolean) sobj.get(field))) {
                return false;
            }
        }
        
        return true;
    }
    
    /**
     * Method checks if specified field (should be of type Boolean) has value true in **any** of the specified records. If so, returns true else returns false.
     */
    public Boolean isFalseInAny(List<SObject> sobjs, String field) {
        if (sobjs == null || field == null) {
            return false;
        }

        for(Sobject sobj : sobjs) {
            if (!((Boolean) sobj.get(field))) {
                return true;
            }
        }
        
        return false;
    }
    
    /**
     * Method checks if specified field (should be of type Boolean) has value true in **all** of the specified records. If so, returns true else returns false.
     */
    public Boolean isFalseInAll(List<SObject> sobjs, String field) {
        if (sobjs == null || field == null) {
            return false;
        }

        for(Sobject sobj : sobjs) {
            if ((Boolean) sobj.get(field)) {
                return false;
            }
        }
        
        return true;
    }
    
    public List<SObject> setValue(List<SObject> sobjs, String field, Object value) {
        if (sobjs == null || field == null) {
            return null;
        }
        
        for (SObject sobj : sobjs) {
            sobj.put(field, value);
        }
        
        return sobjs;
    }
    
    public Object createInstance(String clz) {
        Type typ = Type.forName(clz);
        Object instance = null;
        if (typ != null) {
            instance = typ.newInstance();
        }
        
        if (instance == null) {
            throw new BusinessException('Couldn\'t successfully instantiate an object for class ' + clz + '. Please check if Class name is correct, is compilable and current user has access.');
        }
        
        return instance;
    }
 	
    /**
     * Returns the root exception of this exception chain.
     */
    public Exception getRootException(Exception e) {
        if (e == null || e.getCause() == null) {
            return e;
        }
        
        return getRootException(e.getCause());
    }
    
    public String nullIfEmpty(String value) {
        return isEmpty(value)?null:value;
    }
    
    /**
     * Returns the name of the class, which is callig this method.
     */
    public String getCurrentClassName() {
        String classMethodLine = new SystemException().getStackTraceString().split('\n')[1];
        String[] tokens = classMethodLine.split(':');
        String[] subTokens = tokens[0].split('\\.');
        return subTokens[1];
    }

    /**
     * Returns the name of the class, which is callig this method.
     */
    public String getCurrentClassMethodName() {
        String classMethodLine = new SystemException().getStackTraceString().split('\n')[1];
        String[] tokens = classMethodLine.split(':');
        String[] subTokens = tokens[0].split('\\.');
        return subTokens[1]  + '.' + subTokens[2];
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

    public Schema.DescribeFieldResult describeField(String sobjName, String fieldName) {
        return getFieldDescribe(sobjName, fieldName);
    }
    
    public Schema.DescribeFieldResult getFieldDescribe(String sobjName, String fieldName) {
		DescribeSObjectResult describeResult = describeSobject(sobjName);
        Schema.SObjectField field = describeResult.Fields.getMap().get(fieldName);
        
        if (field == null) {
            throw new BusinessException('Invalid Salesforce field ' + sobjName + '.' + fieldName);
        }
        
        return field.getDescribe();
    }
    
    public Integer getFieldLength(String sobj, String fieldName) {
        Integer length = getFieldDescribe(sobj, fieldName).getLength();
        debug('Field length for ' + sobj + '.' + fieldName + ' is ' + length);
        
        return length;
    }

    public String getFieldType(String sobj, String fieldName) {
        String type = String.valueOf(getFieldDescribe(sobj, fieldName).getType()).toLowerCase();
        
        debug('Field type for ' + sobj + '.' + fieldName + ' is ' + type);
        
        return type;
    }

    public Boolean isFieldLookUpOfType(String sobj, String fieldName, String lookupTypeObject) {
        List<Schema.sObjectType> types = getFieldDescribe(sobj, fieldName).getReferenceTo();
        if (types != null) {
            for (Schema.sObjectType type : types) {
                if (equalsIc(type.getDescribe().getName(), lookupTypeObject)) {
                    return true;
                }
            }
        }
        
        return false;
    }

    /**
     * Check if given sobject field is of type reference. It looks in the SobjectField.type property.
     */
    public Boolean isFieldIdOrRefType(Schema.SObjectField field) {
		String fieldType = String.valueOf(field.getDescribe().getType());
        return fieldType == 'Reference' || fieldType == 'Id';
    }
    
    public String getSobjectName(Id sobjId) {
        return sobjId.getSobjectType().getDescribe().getName();
    }

    public String getSobjectName(Sobject sobj) {
        return sobj.getSObjectType().getDescribe().getName();
    }
    
    public Schema.DescribeSObjectResult describeSobject(String sobjName) {
		Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        for (String sobj : schemaMap.keyset()) {
            if (sobj == sobjName) {
                return schemaMap.get(sobj).getDescribe();
            }
        }
		
		throw new BusinessException('Invalid Sobject Name [' + sobjName + ']');        
    }

    public String getRecordName(Id sobjId) {
        List<Sobject> sobjs = Database.query('select name from ' + getSobjectName(sobjId) + ' where id = :sobjId');
        return (String) (sobjs.isEmpty()?null:sobjs.get(0).get('Name'));
    }
    
    public String getStaticResourceAsString(String staticResourceName) {
        List<StaticResource> srs = [select id, body from StaticResource Where Name = :staticResourceName];
        if (srs.isEmpty()) {
            throw new BusinessException('Static Resource ' + staticResourceName + ' is not defined.');
        }
        
        String contents = srs.get(0).body.toString();
        debug('Returning the static resource ' + staticResourceName + ' contents: ' + contents);
        return contents;
    }
	
	/**
	 * Returns true if current instance is sandbox.
	 * 
	 * See for implementation https://success.salesforce.com/ideaview?id=0873000000083sJAAQ
	 */
    public Boolean isSandbox() {
    	return URL.getSalesforceBaseUrl().getHost().left(2).equalsignorecase('cs');
    }
    
    /**
     * Converts the decimal degrees into radians (http://en.wikipedia.org/wiki/Pi#Geometry_and_trigonometry)
     */
    public Double convertToRadians(Decimal decimalDegrees){
        return decimalDegrees * 3.1415926 / 180;
    }
    
    /**
     * Checks the status is case-insensitive ok or okay
     */
    public Boolean isOk(String status) {
       return equalsIc(status, 'ok') || equalsIc(status, 'okay');
    }
 		
    /**
     * Checks the status is case-insensitive ok or okay
     */
    public Boolean isSuccess(String status) {
       return status != null && status.trim() == 'Success';
    }

    public Boolean isToBeSynced(String status) {
       return status != null && status.trim() == Status_ToBeSynced;
    }
    
    public String createSoql(String sobjName, List<String> fields) {
    	return createSoql(fields, sobjName, null, null, null, null);
    }
    
    public String createSoql(List<String> fields, String sobjName) {
    	return createSoql(fields, sobjName, null, null, null, null);
    }

    public String createSoql(List<String> fields, String sobjName, List<String> whereClauses) {
    	return createSoql(fields, sobjName, whereClauses, null, null, null);
    }

    public String createSoql(List<String> fields, String sobjName, 
			List<String> whereClauses, String orderField, Integer page, Integer pageSize) {
        String soql;
        Set<String> uniqueFields = new Set<String>(fields);
        
        for (String field : uniqueFields) {
            if (soql == null) {
                soql = 'select ';
            } else {
                soql += ', ';
            }
        
            soql += field;
        }
        
        soql += ' from ' + sobjName;
        if (whereClauses != null && !whereClauses.isEmpty()) {
            soql += ' where ' + join(whereClauses, ' and ');
        }
		
		if (orderField != null) {
        	soql += ' order by ' + orderField;
        }

		if (pageSize != null) {
        	soql += ' limit ' + pageSize;
        }
                
		if (page != null && pageSize != null) {
        	soql += ' offset ' + ((page - 1) * pageSize);
        }
		
		info('Returning the created soql ' + soql);
		return soql;
    }
    
    public SObject querySobject(String sobjName, List<String> fields, String whereClause) {
        String soql = createSoql(sobjName, fields) + ' where ' + whereClause;
       	List<SObject> sobjs = Database.query(soql);
       	return sobjs.isEmpty()?null:sobjs.get(0);
    } 
    
    public SObject queryAllFields(Id sobjId) {
        return queryAllFields(null, sobjId);
    }
    
    /**
     * For given sobject, queries all fields in that object using dynamic soql. This query would be 
     * inefficient so use it cautiously.
     */
    public SObject queryAllFields(String sobjName, Id sobjId) {
        if (sobjName == null) {
            sobjName = getSobjectName(sobjId);
        }
        String soql = null;
        Schema.SObjectType sobj = Schema.getGlobalDescribe().get(sobjName);
        if (sobj == null) {
            throw new BusinessException('SObject ' + sobjName + 'doesn\'t exist to describe');
        }
        
        Map<String, Schema.SObjectField> fields = sobj.getDescribe().Fields.getMap();
        
        for (String fieldName : fields.keySet()) {
            if (soql == null) {
                soql = 'select ';
            } else {
                soql += ', ';
            }
        
            soql += fieldName;
        }
        
        soql += ' from ' + sobjName + ' where id = :sobjId';
       	List<SObject> sobjs = Database.query(soql);
        if (!sobjs.isEmpty()) {
            return sobjs.get(0);
        }
        
        return null;
    }

    public Map<String, Object> queryAllFieldsAsMap(String sobjName, Id sobjId) {
		SObject sobj = queryAllFields(sobjName, sobjId);
        if (sobj == null) {
            return null;
        }
        
		Map<String, Object> fieldsValues = new Map<String, Object>();
        Map<String, Schema.SObjectField> fieldsMap = Schema.getGlobalDescribe().get(sobjName).getDescribe().Fields.getMap();
        for (String fieldName : fieldsMap.keySet()) {
            if (!String.valueOf(fieldsMap.get(fieldName).getDescribe().getType()).toLowerCase().equals('address')) {
                //For some reason, test used to fail with message System.TypeException: Data type not supported: Address
                //so we are excluding address fields
                System.debug('Value for field ' + fieldName);
            	fieldsValues.put(fieldName, sobj.get(fieldName));
            }
        }
        
        return fieldsValues;
    }
    
    /**
     * Queries all fields for specified user and returns the object.
     */
    public User queryUser(Id userId) {
       	return (User) queryAllFields('User', userId);  
    }

    /**
     * Queries all fields for specified lead and returns the object.
     */
    public Lead queryLead(Id leadId) {
       	return (Lead) queryAllFields('Lead', leadId);
    }

    /**
     * Queries all fields for specified lead and returns the object.
     */
    public Opportunity queryOpty(Id recordId) {
       	return (Opportunity) queryAllFields('Opportunity', recordId);
    }


    /**
     * Queries all fields for specified account and returns the object.
     */
    public Account queryAccount(Id objId) {
       	return (Account) queryAllFields('Account', objId);
    }
    
    /**
     * Queries all fields for specified contact and returns the object.
     */
    public Contact queryContact(Id objId) {
       	return (Contact) queryAllFields('Contact', objId);
    }

    /**
     * Returns any active user with standard profile and it queries all fields of this user.
     */ 
    public User getAnyStandardUser() {
		return getAnyStandardUsers(1).get(0);
    }

    /**
     * Returns any active user with standard profile and it queries all fields of this user.
     */ 
    public List<User> getAnyStandardUsers(Integer count) {
       	List<User> users = [select id from user where isActive = true and Profile.UserType = 'Standard' limit :count];
        if (users.isEmpty()) {
            throw new BusinessException('Could not retrieve any standard user');
        }
        
        List<User> usersWithDetails = new List<User>();
        for (User user : users) {
            usersWithDetails.add((User) queryAllFields('User', user.id));
        }
        return usersWithDetails;
    }
    
    public Id getRecordTypeId(String sobjName, String recordTypeName) {
        return getRecordTypeId(sobjName, recordTypeName, false);
    }
    
    public Id getRecordTypeId(String sobjName, String recordTypeName, Boolean returnNullIfNotDefined) {
        
		Schema.DescribeSObjectResult cfrSchema = Schema.getGlobalDescribe().get(sobjName).getDescribe(); 
		Map<String, Schema.RecordTypeInfo> recordTypes = cfrSchema.getRecordTypeInfosByName();
        if (recordTypes.get(recordTypeName)==null) {
            if (returnNullIfNotDefined) {
                return null;
            }
            throw new BusinessException('Record type [' + recordTypeName +'] is not defined for Sobject [' + sobjName + ']');
        }
        
		return recordTypes.get(recordTypeName).getRecordTypeId();
    }
    
    /**
     * Splits the given list into multiple sublists with each of the sublists containing maximum specfied number of
     * objects.
     */ 
    public List<List<SObject>> splitListBySize(List<SObject> sobjs, Integer sublistSize) {
        if (sobjs == null) {
            return null;
        }
        
        List<List<SObject>> sublists = new List<List<SObject>>();
        if (sobjs.isEmpty()) {
            return sublists;
        }
        
        List<SObject> sublist = null;

        if (sobjs.size() <= sublistSize) {
            sublists.add(sobjs);
            return sublists;
        }
        
        for (Sobject sobj : sobjs) {
            if (sublist == null) {
                sublist = new List<SObject>();
            }
            
            sublist.add(sobj);
            if (sublist.size() >= sublistSize) {
                sublists.add(sublist);
                sublist = null;
            }
        }
        
        if (sublist != null) {
            sublists.add(sublist);
        }
        
        return sublists;
    }
    
    /**
     * Given a list of sobjects and the field to group by, it creates a map of field value
     * to list of sobjects. If list or field is null or if list is empty, returns empty map
     */ 
    public Map<String, List<SObject>> groupBy(List<SObject> sobjs, String fieldToGroupBy) {
       	Map<String, List<SObject>> groupedMap = new Map<String, List<SObject>>();
        
        if (sobjs == null || fieldToGroupBy == null) {
            return groupedMap;
        }
        
        for (Sobject sobj : sobjs) {
            String key = String.valueOf(sobj.get(fieldToGroupBy));
            if (!groupedMap.containsKey(key)) {
                groupedMap.put(key, new List<SObject>());
            }
            
            groupedMap.get(key).add(sobj);
        }
        
        return groupedMap;
    }
    
    /**
     * Calculates the difference between two datetimes in days. If either of dates is null, then response is null as well.
     */ 
    public Integer diffInDays(DateTime d1, DateTime d2)  {
        if (d1 == null || d2 == null) {
            return null;
        }
		
		Integer diff = (Integer) Math.abs((d1.getTime() - d2.getTime()) / (1000 * 60 * 60 * 24));
        debug('Difference between ' + d1 + ' and ' + d2 + ' is ' + diff + ' days');
        return diff;
    }

    /**
     * Calculates the difference between two datetimes in days. If either of dates is null, then response is null as well.
     */ 
    public Integer diffInSecs(DateTime d1, DateTime d2)  {
        if (d1 == null || d2 == null) {
            return null;
        }
		
		Integer diff = (Integer) Math.abs((d1.getTime() - d2.getTime()) / (1000));
        debug('Difference between ' + d1 + ' and ' + d2 + ' is ' + diff + ' secs');
        return diff;
    }

    /**
     * Calculates the difference between two datetimes in minutes. If either of dates is null, then response is null as well.
     */ 
    public Integer diffInMins(DateTime d1, DateTime d2)  {
        if (d1 == null || d2 == null) {
            return null;
        }
		
		Integer diff = (Integer) Math.abs((d1.getTime() - d2.getTime()) / (1000 * 60));
        System.debug('Difference between ' + d1 + ' and ' + d2 + ' is ' + diff + ' mins');
        return diff;
    }
    
    public Integer increment(Integer value) {
        return increment(value, 1);
    }

    public Integer increment(Integer value, Integer incrementValue) {
        return (value == null || value == 0)?incrementValue:value+incrementValue;
    }

    public Decimal increment(Decimal value) {
		return increment(value, 1);
    }
    
    public Decimal increment(Decimal value, Integer incrementValue) {
        return (value == null || value == 0.0)?incrementValue:value+incrementValue;
    }

    public Integer findMaxInteger(List<Sobject> sobjs, String field) {
        Integer max = null;
        if (sobjs == null || field == null) {
            return null;
        }
        
        for (Sobject sobj : sobjs) {
            if (max == null || Integer.valueOf(sobj.get(field)) > max) {
                max = Integer.valueOf(sobj.get(field));
            }
        }
        
        return max;
    }
    
    public void rollback(SavePoint savepoint) {
        if (savepoint != null) Database.rollback(savepoint);
    }
    
    public List<Sobject> getUpdatedRecords(List<Sobject> oldSobjs, List<Sobject> newSobjs, String field) {
        return getUpdatedRecords(oldSobjs, newSobjs, new String[]{field});
    }
    
    /**
     * Method tries to find the records whcih have been udpated for given set of fields. Record
     * is considered as updated, if any one of the field has been updated. Update check is case sensitive
     * so even if a case is changed, it is treated as updated.
     * 
     * If there are no records, which are updated, then it returns a empty list.
     * 
     * It is expected that both list contain exactly same number of entries. If old is null, whole
     * new is considered as updated.
     */ 
    public List<Sobject> getUpdatedRecords(List<Sobject> oldSobjs, List<Sobject> newSobjs, List<String> fields) {
        return getUpdatedRecords(oldSobjs, newSobjs, fields, false);
    }
    
    public List<Sobject> getUpdatedRecords(List<Sobject> oldSobjs, List<Sobject> newSobjs, List<String> fields, Boolean nullSameAsEmpty) {
		List<Sobject> recordsUpdated = new List<Sobject>();
        for (Integer index = 0; index < oldSobjs.size(); index++) {
            Sobject oldSobj = oldSobjs.get(index);
        	Sobject newSobj = newSobjs.get(index);
            
            if (isChanged(oldSobj, newSobj, fields, nullSameAsEmpty)) {
                recordsUpdated.add(newSobj);
            }
        }
     		
        return recordsUpdated;
    }
    
    public Boolean isChanged(Sobject oldSobj, Sobject newSobj, String field) {
        return isChanged(oldSobj, newSobj, new String[]{field});
    }
    
    public Boolean isChanged(Sobject oldSobj, Sobject newSobj, String[] fields) {
        return isChanged(oldSobj, newSobj, fields, false);
    }
    
    public Boolean isChanged(Sobject oldSobj, Sobject newSobj, String[] fields, Boolean nullSameAsEmpty) {
        for (String field : fields) {
            if (isChanged(oldSobj.get(field), newSobj.get(field), nullSameAsEmpty)) {
                info('Field ' + field + ' is changed from old value="' + oldSobj.get(field) + '" to new value="' + newSobj.get(field) + '" with flag ' + nullSameAsEmpty);
                return true;
            }
        }
        
        return false;
    }
    
    /**
     * Method goes through all given sobjects, finds the records whose given field matches the 
     * given value and returns those records. If there are not mathing records, then
     * returns empty list.
     */ 
    public List<Sobject> getMatchingRecords(List<Sobject> sobjs, String field, Object value) {
        
        List<Sobject> matchingRecords = new List<Sobject>();
        if (sobjs == null || field == null || value == null) {
			return matchingRecords;
        }

        for (Sobject sobj : sobjs) {
            if (sobj.get(field) == value) {
                matchingRecords.add(sobj);
            }
        }
        
        return matchingRecords;
    }
    
    public Boolean isBeforeUpdate() {
        return Trigger.isExecuting && Trigger.IsBefore && Trigger.IsUpdate;
    }
    
    public Boolean isBeforeInsert() {
        return Trigger.isExecuting && Trigger.IsBefore && Trigger.IsInsert;
    }
    
    public Boolean isBeforeInsertOrUpdate() {
        return Trigger.isExecuting && Trigger.IsBefore && (Trigger.IsInsert || Trigger.IsUpdate);
    }

    public Boolean isAfterUpdate() {
        return Trigger.isExecuting && Trigger.IsAfter && Trigger.IsUpdate;
    }
    
    public Boolean isAfterInsert() {
        return Trigger.isExecuting && Trigger.IsAfter && Trigger.IsInsert;
    }
    
    public Boolean isAfterDelete() {
        return Trigger.isExecuting && Trigger.IsAfter && Trigger.IsDelete;
    }

    public Boolean isAfterInsertOrUpdate() {
        return Trigger.isExecuting && Trigger.IsAfter && (Trigger.IsInsert || Trigger.IsUpdate);
    }
    
    /**
     * This class implements the MultiMap concepts from Guava library. This allows to maintain list of strings for given string key.
     * So it allows to implement Map<String, List<String>> construct without having do heavy listing.
     */
    public class MultiStringMap {
       	private Boolean unique = false;
        private Map<String, List<String>> multimap = new Map<String, List<String>>();
        private Map<String, Set<String>> uniqueMultiMap = new Map<String, Set<String>>();
        
        public MultiStringMap() {
            this(false);
        }
        public MultiStringMap(Boolean unique) {
            this.unique = unique;
        }
        
        public void put(String key, String value) {
            if (unique) {
                Set<String> values = uniqueMultiMap.get(key);
                if (values == null) {
                    values = new Set<String>();
                    uniqueMultiMap.put(key, values);
                }
                values.add(value);
            } else {
                List<String> values = multiMap.get(key);
                if (values == null) {
                    values = new List<String>();
                    multimap.put(key, values);
                }
                values.add(value);
            }
        }
        
        public Set<String> keyset() {
            return unique?uniqueMultimap.keySet():multiMap.keySet();
        }

        public List<String> get(String key) {
            List<String> values = null;
            if (unique) {
                if (uniqueMultiMap.containsKey(key)) {
                    values = new List<String>(uniqueMultimap.get(key));
                }
            } else {
                values = multimap.get(key);
            }
            
            return values;
        }
    }
    
    /**
     * Creates a HmacSha256 digest, encodes in Base64 format and returns.
     */
    public Blob hmacSha256(String data, String secretKey) {
       return hmacSha256(data, Blob.valueOf(secretKey));
    }

    /**
     * Creates a HmacSha256 digest, encodes in Base64 format and returns.
     */
    public Blob hmacSha256(String data, Blob secretKey) {
       return hmacSha256(Blob.valueOf(data), secretKey);
    }

    /**
     * Creates a HmacSha256 digest, encodes in Base64 format and returns.
     */
    public Blob hmacSha256(Blob data, Blob secretKey) {
       return Crypto.generateMac('HmacSHA256', data, secretKey); 
    }
    
    public String sha256HashHex(String input) {
        return EncodingUtil.convertToHex(Crypto.generateDigest('SHA-256', Blob.valueOf(input)));
    }

    public Boolean isNotBatchAndFuture() {
        return !System.isBatch() && !System.isFuture();
    }
    
    public BusinessException createBusinessException(String errorCode, String message) {
    	return createBusinessException(null, errorCode, message, null);
    }
    
    public BusinessException createBusinessException(String errorCode, String message, Exception e) {
    	return createBusinessException(null, errorCode, message, e);
    }
    
    public BusinessException createBusinessException(String statusCode, String errorCode, String message) {
    	return createBusinessException(statusCode, errorCode, message, null);
    }
    
    public BusinessException createBusinessException(String statusCode, String errorCode, String message, Exception e) {
        BusinessException be = e==null?new BusinessException(message):new BusinessException(message, e);
        be.errorCode = errorCode;
        be.statusCode = statusCode;
        return be;
    }

    /**
     * Checks if Queueable limits has been reached. If reached, returns true else false.
     */
    public Boolean isQueueableLimitsReached() {
       return Limits.getLimitQueueableJobs() - Limits.getQueueableJobs() <= 0;
    }
    
    public String getQueueableLimitsStatus() {
        return Limits.getQueueableJobs() + ' of ' + Limits.getLimitQueueableJobs();
    }
    
    public Boolean isCalloutsLimitsReached() {
       return Limits.getLimitCallouts() - Limits.getCallouts() <= 0;
    }

    public Integer getCalloutsQuota() {
       return Limits.getLimitCallouts() - Limits.getCallouts();
    }

    public Integer getQueriesQuota() {
       return Limits.getLimitQueries() - Limits.getQueries();
    }

    public String getClassName(Object obj) {
        return String.valueOf(obj).substringBefore(':');
    } 
    
    public String enqueueJobWithCheck(Queueable queueable) {
        if (isQueueableLimitsReached()) {
            info('Queueable limits have been reached [' + getQueueableLimitsStatus() 
                 + '] and hence will not be submitting queueable ' + queueable);
            return null;

        } else if (Test.isRunningTest() && isTrue(testParams.get('RunQueueableInSync'))) {
			queueable.execute(null);
            return null;
            
        } else {
            return System.enqueueJob(queueable);
        }
    }

    public Boolean isTrue(Object obj) {
        if (obj == null) {
            return false;
        } else if (obj instanceof Boolean) {
            return (Boolean) obj;
        } else {
            return Boolean.valueOf(String.valueOf(obj));
        }
    }
                   
    /**
     * Requests a new access token from authorization server using oauth2 client_credentials
     * grant type.
     */
    public String getOAuth2AccessToken(String url, String clientId, String clientSecret) {
        String response = httpGet(url, 
			new Map<String, String>{'Authorization'=>base64Encode(clientId+':'+clientSecret)},
            new Map<String, String>{'grant_type'=>'client_credentials'}, null);
        
        JsonReader reader = new JsonReader(response);
        String token = reader.getString('access_token');
        if (token == null) {
            throw new SystemException('Could not get a OAuth2 Access token from url ' + url + ' using clientId ' + clientId);
        }
        
        return token;
    }
    
    /**
     * Removes all formatting from us phone and keeps the right 10 digits.
     */
    public String removeUSPhoneFormatting(String phone) {
        if (phone != null) {
            //Removes all chars except numbers
	        phone = phone.replaceAll('[^0-9]', '').right(10);
    	}
    
    	return phone;
    }
 	
    public Map<String, String> newStringMap(String key, String value) {
        return new Map<String, String>{key => value};
    }
    
    public Map<String, String> newStringMap(String key1, String value1, String key2, String value2) {
        return new Map<String, String>{key1 => value1, key2 => value2};
    }
    
    public List<String> getDateTimeStrings(Datetime datetimeObj){
    	List<String> result = new List<String>();
    	if(datetimeObj != null){
    		String tempDateTimeStr = datetimeObj.format('yyyy-MM-dd HH:mm');
    		result = tempDateTimeStr.split(' ');
    	}
    	return result;
    }

    public boolean isEmptyCollection(List<SObject> values){
    	return (values == null || values.isEmpty()) ? true : false;
    }

    public boolean isEmptyCollection(List<String> values){
    	return (values == null || values.isEmpty()) ? true : false;
    }

    public boolean isEmptyCollection(List<Id> values){
    	return (values == null || values.isEmpty()) ? true : false;
    }
    
    public boolean isEmptyCollection(Set<String> values){
    	return (values == null || values.isEmpty()) ? true : false;
    }

    public boolean isEmptyCollection(Set<Id> values){
    	return (values == null || values.isEmpty()) ? true : false;
    }
    
    public boolean isEmpty(List<SObject> values){
    	return values == null || values.isEmpty();
    }

    public boolean isEmpty(List<Object> values){
    	return values == null || values.isEmpty();
    }

    public boolean isEmpty(List<String> values){
    	return values == null || values.isEmpty();
    }

    public boolean isEmpty(List<Id> values){
    	return values == null || values.isEmpty();
    }
    
    public boolean isEmpty(Set<String> values){
    	return values == null || values.isEmpty();
    }

    public boolean isEmpty(Set<Id> values){
    	return values == null || values.isEmpty();
    }

    public boolean isEmpty(Set<SObject> values){
    	return values == null || values.isEmpty();
    }

    public boolean isEmpty(Set<Object> values){
    	return values == null || values.isEmpty();
    }

    public Set<String> getCustomLeadSources(String retailerName){
    	Set<String> leadSourceValues = new Set<String>();
    	if(retailerName == 'Home Depot'){
    		leadSourceValues.add('Retail: Sunrun Solar Station');
    		leadSourceValues.add('Retail: The Home Depot In Store');
    		leadSourceValues.add('Retail: The Home Depot Web');
    		leadSourceValues.add('Retail: The Home Depot');
    		leadSourceValues.add('Home Depot');
    		leadSourceValues.add('Retail: The Home Depot - Solar Scouts');
    	}
    	return leadSourceValues;
    }
    
    /**
     * Checks if current user is API Only user (PermissionsApiUserOnly in PermissionSet object) and if so
     * return true. Else returns false.
     */
    public Boolean isApiOnlyUser() {
        
        if (isCurrentUserIsApiOnlyUser == null) {
            
            List<PermissionSet> permissionSets = [
                select PermissionsApiUserOnly 
                from PermissionSet 
                where ProfileId = :UserInfo.getProfileId()
            ];
            
            isCurrentUserIsApiOnlyUser = permissionSets.isEmpty()?false:
            	permissionSets.get(0).PermissionsApiUserOnly;
        }
        
        return isCurrentUserIsApiOnlyUser;
    }
    
    public String getProfileName() {
        if (currentUserProfileName == null) {
	        List<Profile> profiles = [select name from Profile where id = :UserInfo.getProfileId()];
            currentUserProfileName = profiles.isEmpty()?null:profiles.get(0).name;
        }
        
        return currentUserProfileName;
    }
    
    public String getRoleName() {
        if (currentUserRoleName == null) {
	        List<UserRole> roles = [select name from UserRole where id = :UserInfo.getUserRoleId()];
            currentUserRoleName = roles.isEmpty()?null:roles.get(0).name;
        }
        
        return currentUserRoleName;
    }

    public Boolean isMatchesWildcard(String input, String wildcardPattern) {
        if (input == null || wildcardPattern == null) {
            return false;
        }
        
        //We will use regex to compare. We will have to convert * into \\* and ? to \\?
        wildcardPattern = wildcardPattern.replaceAll('\\*', '.*').replaceAll('\\?', '.');
        info('After patter ' + wildcardPattern);
        return Pattern.matches(wildcardPattern, input);
    }
    
    public Boolean isProfileMatchesWildcard(String wildcardPattern) {
    	return isMatchesWildcard(getProfileName(), wildcardPattern);
    }

    public Boolean isRoleMatchesWildcard(String wildcardPattern) {
    	return isMatchesWildcard(getRoleName(), wildcardPattern);
    }
    
    public Integer compareTo(Decimal value1, Decimal value2) {
        if (value1 < value2) {
            return -1;
        } else if (value1 > value2) {
            return 1;
        } else {
            return 0;
        }
    }
    
    /**
     * Extracts all sobjects using specified field and returns the list of
     * extracted sobjects. Nulls are not considered.
     */
    public List<Sobject> getSobjects(List<Sobject> sobjs, String field) {
       	List<Sobject> extractedSobjs = new List<Sobject>();
        for (Sobject sobj : sobjs) {
            Sobject extractedSobj = sobj.getSObject(field);
            if (extractedSobj != null) {
                extractedSobjs.add(extractedSobj);
            }
        }
        
        return extractedSobjs;
    }
    
    public String createText(String input, Integer length) {
        String text = input;
        while(text.length() < length) {
            text += input;
        }
        
        return text.substring(0, length);
    }
    
    public String toString(Map<String, String> stringMap) {
        String value = null;
        if (stringMap != null) {
            for (String key : stringMap.keySet()) {
                if (value != null) {
                    value += ',';
                }
                
                value += key+'=' + stringMap.get(key);
            }
        }
        
        return value;
    }
    
    public String getStringValue(Sobject sobj, String field) {
        Object value = getValue(sobj, field);
        if (value != null) {
            return String.valueOf(value);
        }
        
        return null;
    }
    
    public Object getValue(Sobject sobj, String field) {
        if (sobj == null) {
            return null;
        }
        
        if (field.indexOf('.') < 0) {
            return sobj.get(field);
        }
        
        Sobject parent = sobj;
        String[] fields = field.split('\\.');
        for (Integer i = 0; i < fields.size() - 1; i++) {
            parent = parent.getSObject(fields[i]);
            if (parent == null) {
                return null;
            }
        }

      	return parent.get(fields[fields.size() - 1]);
    }
    
    public String trim(String value, Integer size) {
        if (value == null) {
            return null;
        }
        
        if (value.length() <= size) {
            return value;
        }
        
        return value.substring(0, size);
    }   
    
    public List<String> split(String text, Integer size) {
	    List<String> ret = new List<String>();
        
        for (Integer start = 0; start < text.length(); start += size) {
            ret.add(text.substring(start, Math.min(text.length(), start + size)));
        }
    	return ret;
    }
    
    /**
     * Goes through the given list of sobjects, and removes the entries whose ids matches
     * the ids given in the map.
     */
    public List<Sobject> removeObjectsMatchingIds(List<SObject> sobjs, Map<Id, String> ids) {
		List<Sobject> newList = new List<Sobject>();
        for (Sobject sobj : sobjs) {
            if (!ids.containsKey(sobj.id)) {
                newList.add(sobj);
            }
        }
        
        return newList;
    }

    /**
     * Adds the ids from given list of sobjects into the given Map.
     */
    public Map<Id, String> putAll(Map<Id, String> ids, List<SObject> sobjs) {
        for (Sobject sobj : sobjs) {
            ids.put(sobj.id, '');
        }
        
        return ids;
    }
    
    public Boolean containsIgnoreCase(List<String> values, String valueToSearch) {
        if (values == null || valueToSearch == null) {
            return false;
        }
        
        for (String value : values) {
            if (value.equalsIgnoreCase(valueToSearch)) {
                return true;
            }
        }
        
        return false;
    }
}