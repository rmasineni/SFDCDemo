/**
 * This is the base class for all Rest Services like Lead Api, Opty Api etc., This contains some utility methods, and basic resposne types etc.,
 */ 
global abstract with sharing class RestService extends BaseClass implements RestRequestHandler {
    
    /**
     * If the rest url is record specific one (the one which ends in an id), then this extracts that id and returns. Underneath, it merely
     * extracts the last segment of the url and returns. If there is no last segment, then returns null.
     */ 
    global String getPathId(RestRequest req) {
        String value = null;
        if (req.requestURI.lastIndexOf('/') >= 0) {
            value = req.requestURI.substring(req.requestURI.lastIndexOf('/') + 1);
            if (value.indexOf('?') >= 0) {
	            value = value.substringBefore('?');
            }
        }
		
        return value;
    }

    global RestResponse handleRequest(RestRequest restReq, RestResponse restResp) {
	   	DateTime startTime = DateTime.now();
        String httpMethod = restReq.httpMethod;

        RestServiceDto.Request req = new RestServiceDto.Request(restReq);
        RestServiceDto.Response resp = new RestServiceDto.Response(restResp);
    	Boolean debug = req.isDebug() || Test.isRunningTest();
        Exception expn = null;
        
        try {
            info('Received API Request method=' + httpMethod +', uri=' + restReq.requestURI + ', resourcePath=' + restReq.resourcePath
                       + ', body=' + req.getRequestBody() + ' and handling the requesting using ' + getClassName(this));
            
            parseRequest(req, resp);
            
            handleRequest(req, resp);
			
            info('Received response from Request Handler ' + resp);

        } catch (Exception e) {
            
            System.debug('Inside exception the resp is ' + resp + ' ' + getExceptionDetails(e));
           	e = transformException(e);
            
            if (e instanceof BusinessException) {
                BusinessException be = ((BusinessException) e);
                resp.errorCode = be.errorCode;
                if (be.statusCode != null) {
	                resp.httpStatus = Integer.valueOf(be.statusCode);
                }
            }
            
            resp.errorCode = firstNonEmpty(resp.errorCode, RestServiceDto.Error_InternalServerError);
            resp.message = e.getMessage();
            resp.details = getStackTrace(e);
            expn = e;
        }
        
        if (resp.httpStatus == null) {
            if (resp.errorCode != null) {
                resp.httpStatus = (Integer) firstNonNull(RestServiceDto.ErrorCodeToHttpCodeMap.get(resp.errorCode), 500);
            } else {
                if (httpMethod == 'POST') {
                    resp.httpStatus = 201;
                    
                } else if (httpMethod == 'DELETE') {
                    resp.httpStatus = 204;
                    
                } else {
                    resp.httpStatus = 200;
                }
            }
        }
        
        if (resp.errorCode != null) {
            resp.jsonWriter = new JsonWriter();
            resp.jsonWriter.write('errorCode', resp.errorCode);
            resp.jsonWriter.write('message', resp.message);
            
            if (debug && resp.details != null) resp.jsonWriter.write('details', resp.details);
        }
		
		String respJson = resp.jsonWriter.toPrettyJson();      

        //Write the request and response into the exception log.  
        String message = resp.errorCode == null?
            'Request processing successful':'Request processing failed with message [' + resp.message + ']';
		String details = 'Request:\n' + req.getRequestBody()
            + '\n\nResponse:\n' + respJson;
        String systemName = req.jsonReader!=null?req.jsonReader.getString('externalSource'):null;
        String recordId = resp.recordId;
		Sf.appLogger.log('Api', getApiName(), message, details, resp.recordId, expn);
        
        restResp.responseBody = Blob.valueOf(respJson);
        restResp.statusCode = resp.httpStatus;

        String elapsedTime = String.valueOf(DateTime.now().getTime() - startTime.getTime());
        
        restResp.headers.put('X-Sfdc-Sunrun-ServerProcessingTimeMs', elapsedTime);
        restResp.headers.put('Content-Type', 'application/json');
        
        if (debug) {
            setDebugHeaders(resp, restResp);
        }
        
        info('Sending API response in ' + elapsedTime + ' ms [' + resp.stopWatch.timeEntries + ']. code=' 
             + restResp.statusCode + ', headers=[' + restResp.headers + '], body=' 
             + restResp.responseBody.toString());
        
        return restResp;
    }

    global abstract String getApiName();
    global abstract void handleRequest(RestServiceDto.Request req, RestServiceDto.Response resp);
    
    public void setDebugHeaders(RestServiceDto.Response resp, RestResponse restResp) {
        JsonWriter jsonWriter = new JsonWriter();
        Integer index = 0;
        for (StopWatch.ElapsedTimeEntry entry : resp.stopWatch.timeEntries) {
            
            //Code contains class.method but as json writer treats . as object separator,
            //we need to replace them all with -
            jsonWriter.write('[' + index + '].' + entry.code.replaceAll('\\.','-'), entry.elapsedTime);
            index++;
        }
        
        restResp.headers.put('X-Sfdc-Sunrun-ServerProcessingTimesMs', jsonWriter.toJson());
    }
    
    /**
     * We have a object, Partner_API_Default_Value__c, which captures all default/overrides
     * that needs to be applied to incoming request. If the config is of type "Default" then
     * those values are applied to incoming request if those fields are not already populated.
     * If type is "override", then configured values are always applied to incoming request, overriding
     * what is supplied by the API client.
     * 
     * This method reads the configuration for for given endpoint and applies the values
     * as configured. Input request must be a JsonReader as input field and output field could be
     * multi level field expression.
     * 
     * This method modifies the given JsonReader and returns the same JsonReader back.
     */ 
    public JsonReader processDefaultsAndOverrides(String api, JsonReader jsonReader) {
        
        List<Partner_API_Default_Value__c> fieldDefaults = [
            Select
                Type__c,
                Input_Field__c,
                Input_Value__c,
                Output_Field__c,
                Output_Value__c
           From Partner_API_Default_Value__c
           where API__c = :api and Active__c = true
        ];
        
        info('Configured API Defaults are ' + fieldDefaults);
        
        for (Partner_API_Default_Value__c fieldDefault : fieldDefaults) {
            info('Processing ' + fieldDefault);
            if (fieldDefault.Input_Value__c == jsonReader.getString(fieldDefault.Input_Field__c)) {
                if (fieldDefault.Type__c == 'Override' || isEmpty(jsonReader.getString(fieldDefault.Output_Field__c))) {
                    jsonReader.setString(fieldDefault.Output_Field__c, fieldDefault.Output_Value__c);
                }
            }
        }
        
        return jsonReader;
    }
    
    public Exception transformException(Exception e) {
        try {
            if (e instanceof System.DmlException) {
                System.DmlException de = (System.DmlException) e;
                
                if (e.getMessage().indexOf('FIELD_CUSTOM_VALIDATION_EXCEPTION') >= 0) {
                    String message = e.getMessage().substringAfter('FIELD_CUSTOM_VALIDATION_EXCEPTION');
                    if (message.startsWith(','))  {
                        message = message.substring(1);
                    }
                    
                    return createBusinessException(RestServiceDto.Error_ValidationError, message.trim());
                }
    
                if (e.getMessage().indexOf('REQUIRED_FIELD_MISSING') >= 0) {
                    String message = e.getMessage().substringAfter('REQUIRED_FIELD_MISSING');
                    if (message.startsWith(','))  {
                        message = message.substring(1);
                    }
                    
                    return createBusinessException(RestServiceDto.Error_ValidationError, message.trim());
                }
            }        
            
            return e;
        } catch (Exception e1) {
            return e;
        }
    }
    
    /**
	 * Parses the given json into JsonReader and stores the json reader in the given request object.
     * 
	 * If there is any error while parsing the whole response then throws the exception. 
	 */
    public void parseRequest(RestServiceDto.Request req, RestServiceDto.Response resp) {
        try {
            String requestBody = req.getRequestBody();
            if (!String.isBlank(requestBody)) {
	            req.jsonReader = new JsonReader(requestBody);
            } else if (req.restReq.httpMethod == 'POST') {
                throw new BusinessException(RestServiceDto.Error_RequiredFieldsMissing, 'Http POST request body is missing');
            }
            
        } catch (BusinessException e) {
            throw e;
        } catch (Exception e) {
            throw createBusinessException(RestServiceDto.Error_InvalidRequest, 
				'Exception while parsing the request. [' + e.getMessage() + ']', e);
        }
    }

    public String getRecordIdFromPath( String collectionName, RestServiceDto.Request req) {
        String value = req.restReq.requestURI.substringAfter('/' + collectionName + '/');
        if (value.indexOf('?') >= 0) {
            value = value.substringBefore('?');
        }
        
        if (value.indexOf('/') >= 0) {
            value = value.substringBefore('/');
        }
		
        if (String.isBlank(value)) {
            throw createBusinessException(RestServiceDto.Error_InvalidId, 
				'Could not get record id from path ' + req.restReq.requestURI + ' with record collection prefix \'' + collectionName + '\'');
        }
        
        return value;
    }
    
    public String getRecordIdFromPath(RestServiceDto.Request req, String collectionName) {
        return getRecordIdFromPath(collectionName, req);
    }
    
    public void copyRestFieldsToSfdcFields(Sobject record, Map<String, String> restToSfdcFieldMapping, RestServiceDto.Request req) {
        JsonReader jsonReader = req.jsonReader;
        String sobjectName = getSobjectName(record);
        
        for (String restApiField : restToSfdcFieldMapping.keySet()) {
            copyRestFieldValue(jsonReader, restApiField, record, sobjectName, restToSfdcFieldMapping.get(restApiField), true);
        }
    }

    public virtual void copyRestFieldValue(JsonReader jsonReader, String restApiField, Sobject record, String sfdcApiField, boolean skipNullOrEmpty) {
		copyRestFieldValue(jsonReader, restApiField, record, null, sfdcApiField, skipNullOrEmpty);    
    }
    
    public virtual void copyRestFieldValue(JsonReader jsonReader, String restApiField, Sobject record, String sobjectName, String sfdcApiField, boolean skipNullOrEmpty) {
        Object value = jsonReader.getValue(restApiField);
        
        if (skipNullOrEmpty && (value == null || isEmpty(String.valueOf(value)))) {
            return;
        }
        
        try {
            if (sobjectName == null) {
                sobjectName = getSobjectName(record);
            }
            
            String type = getFieldType(sobjectName, sfdcApiField);
            
            if (equalsIc(type, 'double') || equalsIc(type, 'currency')) {
                record.put(sfdcApiField, Double.valueOf(String.valueOf(value)));
                
            } else if (equalsIc(type, 'integer')) {
                record.put(sfdcApiField, Integer.valueOf(String.valueOf(value)));
            
            } else if (equalsIc(type, 'phone')) {
                record.put(sfdcApiField, formatPhoneNumber(String.valueOf(value)));
    
            } else if (equalsIc(type, 'boolean')) {
                record.put(sfdcApiField, Boolean.valueOf(String.valueOf(value)));

            } else if (equalsIc(type, 'date')) {
                record.put(sfdcApiField, parseIsoDate(String.valueOf(value)));

            } else if (isFieldLookUpOfType(sobjectName, sfdcApiField, 'User')) {
                record.put(sfdcApiField, queryUserIdByIdOrEmail(String.valueOf(value)));
                
            } else {
                record.put(sfdcApiField, String.valueOf(value));
            }
        } catch (Exception e) {
            throw new SystemException('Exception while copying the rest field ' 
				+ restApiField+ ' with value ' + value + ' to Salesforce field ' + sfdcApiField + ' [' + e.getMessage() + ']', e);
        }
    }

    /**
     * If a rest field is mapped to a Lead field of type User, then we will try to look up the user 
     * assuming the value as email or id.
     */
    public Id queryUserIdByIdOrEmail(String restApiFieldValue) {
    	List<User> users = [select id from User where id = :restApiFieldValue or email = :restApiFieldValue.toLowerCase()];
        if (users.isEmpty()) {
            return null;
        }
		
        return users.get(0).id;
    }
    
    public String formatPhoneNumber(String value) {
        if (value == null) {
            return value;
        }
    
        //Remove all special chars spaces, -, ( and )
        String newValue = value.replaceAll(' ', '').replaceAll('-', '').replaceAll('\\(','').replaceAll('\\)', ''); 
        
        //If the phone length is exactly 10 digits, then format it as (123) 456-7890
        if (newValue.length() == 10) {
            newValue = '(' + newValue.substring(0, 3) + ') ' + newValue.substring(3, 6) + '-' + newValue.substring(6, 10);
        } else {
        
            //If length is not exactly 10, then keep original value
            newValue = value;
        }
        
        return newValue;
    }
    
    public void validateRequiredFields(List<String> requiredFields, RestServiceDto.Request req) {
        validateRequiredFields(null, requiredFields, req);
    }
    
    public void validateRequiredFields(Sobject record, List<String> requiredFields, RestServiceDto.Request req) {
        JsonReader jsonReader = req.jsonReader;
        if (jsonReader == null) {
            throw new BusinessException('Missing request body with required parameter(s) [' + join(requiredFields, ',') + ']');
        }
        
        for (String requiredField : requiredFields) {
            
            //Fields could be multiple fields separated by |. If so, then only one 
            //of the values is required.
            List<String> anyOfRequiredFields = requiredField.split('\\|');
            Boolean atLeastOneFieldPresent = false;
            for (String anyOfRequiredField : anyOfRequiredFields) {
                Object value = jsonReader.getString(anyOfRequiredField);
                if (value != null && isNotEmpty(String.valueOf(value))) {
                    atLeastOneFieldPresent = true;
                }
            }
            
            if (!atLeastOneFieldPresent) {
                String message;
                if (anyOfRequiredFields.size() == 1) {
                    message = 'Value is required for field [' + anyOfRequiredFields[0] + ']';
                } else {
                    message = 'Value is required for any one of fields [' + join(anyOfRequiredFields, ', ') + ']';
                }
                
                throw BusinessException.create(RestServiceDto.Error_RequiredFieldsMissing, message);
            }
        }
    }
	
	/**
	 * Validates if given sobject fields are appropriately populated based on the specified mapping
	 */
    public void validateRequiredFields(Sobject record, List<String> requiredFields, Map<String, String> fieldMapping) {
        
        for (String requiredField : requiredFields) {
            
            //Fields could be multiple fields separated by |. If so, then only one 
            //of the values is required.
            List<String> anyOfRequiredFields = requiredField.split('\\|');
            Boolean atLeastOneFieldPresent = false;
            for (String anyOfRequiredField : anyOfRequiredFields) {
                Object value = getValue(record, fieldMapping.get(requiredField));
                if (value != null && isNotEmpty(String.valueOf(value))) {
                    atLeastOneFieldPresent = true;
                }
            }
            
            if (!atLeastOneFieldPresent) {
                String message;
                if (anyOfRequiredFields.size() == 1) {
                    message = 'Value is required for field [' + anyOfRequiredFields[0] + ']';
                } else {
                    message = 'Value is required for any one of fields [' + join(anyOfRequiredFields, ', ') + ']';
                }
                
                throw BusinessException.create(RestServiceDto.Error_RequiredFieldsMissing, message);
            }
        }
    }

    public void applyPatch(Sobject record, Map<String, String> restToSfdcFieldMapping, RestServiceDto.Request req) {
		JsonReader jsonReader = req.jsonReader;
        
        String sobjName = record.getSObjectType().getDescribe().getName();
        for (String restApiField : restToSfdcFieldMapping.keySet()) {
            String sfdcField = restToSfdcFieldMapping.get(restApiField);
            
            //If sfdc field is compound field, for ex, Opportunity__r.Prospect_Id__c, system will not support it
            if (sfdcField.indexOf('.') >= 0) {
                continue;
            }
            
            if (jsonReader.containsKey(restApiField)) {
                info('Key is in the request ' + restApiField);
	            copyRestFieldValue(jsonReader, restApiField, record, sobjName, sfdcField, false);
            } else {
                info('Key is NOT in the request ' + restApiField);
            }
        }
    }
    
    public Boolean isOpportunity(String prospectId) {
       	List<Opportunity> opties = [select id from Opportunity where Prospect_id__c = :prospectId or External_Id__c =:prospectId];
        return !opties.isEmpty();
    }

    public String createSoqlWithAuditFields(List<String> fields, String sobjectName, String whereClause) {
        return createSoqlWithAuditFields(fields, sobjectName, new String[]{whereClause}, null, null, null);
    }

    public String createSoqlWithAuditFields(List<String> fields, String sobjectName, String whereClause, String orderByField) {
        return createSoqlWithAuditFields(fields, sobjectName, new String[]{whereClause}, orderByField, null, null);
    }

    public String createSoqlWithAuditFields(List<String> fields, String sobjectName, List<String> whereClauses) {
		return createSoqlWithAuditFields(fields, sobjectName, whereClauses, null, null, null);
    }
    
    public String createSoqlWithAuditFields(List<String> fields, String sobjectName, List<String> whereClauses, String orderByField, Integer page, Integer pageSize) {
        fields.add('CreatedBy.UserName');
        fields.add('CreatedDate');
        fields.add('LastModifiedBy.UserName');
        fields.add('LastModifiedDate');
		
        return createSoql(fields, sobjectName, whereClauses, orderByField, page, pageSize);
    }
    
    public void addToResponse(List<Sobject> sobjs, Map<String, String> fieldMapping, Boolean auditFields, RestServiceDto.Request req, RestServiceDto.Response resp) {
        for (Integer i = 0; i < sobjs.size(); i++) {
            resp.jsonWriter.newWith(i);
            addToResponse(sobjs.get(i), fieldMapping, auditFields, req, resp);
        }
    }
    
    public void addToResponse(Sobject sobj, Map<String, String> fieldMapping, Boolean auditFields, RestServiceDto.Request req, RestServiceDto.Response resp) {
        if (auditFields) {
            resp.jsonWriter.write('createdDate', getValue(sobj, 'CreatedDate'));
            resp.jsonWriter.write('createdBy', getValue(sobj, 'CreatedBy.UserName'));
            resp.jsonWriter.write('lastModifiedDate', getValue(sobj, 'LastModifiedDate'));
            resp.jsonWriter.write('lastModifiedBy', getValue(sobj, 'LastModifiedBy.UserName'));
        }

        for (String restField : fieldMapping.keySet()) {
	    	resp.jsonWriter.writeIfNotNull(restField, getValue(sobj, fieldMapping.get(restField)));
        }
    }
    
    /**
     * This method assigns a expiry time for the lead and signs the response token (based on prospectId, expiryTime and current user).
     */  
    public void signLead(Sobject leadOrOpty, RestServiceDto.Response resp) {
        //Take current time, add configured number of seconds, convert to milliseconds since epoch and convert to seconds as expected.
		Long expires = getCurrentDateTime().addSeconds(Sf.settingsService.getInteger('LeadApiSignatureExpirySecs', 2592000)).getTime()/1000;

        //Signing string is made of prospect id, expiry time and current user's email.
        //The prefix L before prospect id is required to indicate the id is corresponding to lead.
        String signingString = 'prospectId=L' + getValue(leadOrOpty, 'Prospect_Id__c') + '&expires=' + expires + '&userId=' + urlEncode(UserInfo.getUserEmail().toLowerCase());
        String signature = EncodingUtil.base64Encode(Crypto.generateMac('HmacSHA1', Blob.valueOf(signingString), Blob.valueOf(Sf.settingsService.getString('LeadApiSigningPrivateKey'))));
        
        resp.jsonWriter.write('expires', expires);
        resp.jsonWriter.write('signature', signature);
    }
}