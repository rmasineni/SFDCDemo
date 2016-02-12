global class RestServiceDto {
    private static BaseClass utils = new BaseClass();
    global static String Error_MethodNotAllowed = 'METHOD_NOT_ALLOWED';
    global static String Error_NotFound = 'RECORD_NOT_FOUND';
    global static String Error_InvalidId = 'INVALID_ID';
    global static String Error_InternalServerError = 'INTERNAL_SERVER_ERROR';
    global static String Error_RequiredFieldsMissing = 'REQUIRED_FIELDS_MISSING';
    global static String Error_RequiredParametersMissing = 'REQUIRED_PARAMETERS_MISSING';
    global static String Error_InvalidRequest = 'INVALID_REQUEST';
    global static String Error_ValidationError ='VALIDATION_ERROR';
	global static String Unable_To_Process_Request ='UNABLE_TO_PROCESS_REQUEST';
    global static Map<String, Map<String, String>> ApiFieldMappings = new Map<String, Map<String, String>>();
    global static Map<String, List<String>> ApiRequiredFields = new Map<String, List<String>>();
    global static Map<String, List<String>> ApiSummaryFields = new Map<String, List<String>>();
    
    global static Map<String, Integer> ErrorCodeToHttpCodeMap = new Map<String, Integer> {
        Error_MethodNotAllowed => 405, //Method not allowed
        Error_InvalidId => 404, //Not found
        Error_RequiredFieldsMissing => 400, //Bad Request
        Error_RequiredParametersMissing => 400, //Bad Request
        Error_InvalidRequest => 400, //Bad Request
        Error_ValidationError => 400, //Bad Request
        Error_InternalServerError => 500, //Internal server error,
        Error_NotFound => 404
    };

    global virtual class Request {
        public RestRequest restReq {get;set;}
        public JsonReader jsonReader {get;set;}
        private Boolean debug = null;
        
        public Request(RestRequest restReq) {
            this.restReq = restReq;
        }

        public String checkForRequiredParam(String key) {
            String values = restReq.params.get(key);
            if (String.isBlank(values)) {
            	throw utils.createBusinessException(RestServiceDto.Error_RequiredFieldsMissing, 'Required parameter [' + key + '] is not found.');
            }
            
            return key;
        }
        
        
        public String getRequiredStringParam(String key) {
            return getStringParam(checkForRequiredParam(key));
        }

        public String getStringParam(String key) {
            return restReq.params.get(key);
        }
		
        public DateTime getRequiredDateTimeParam(String key) {
            return getDateTimeParam(checkForRequiredParam(key));
        }
        
        public DateTime getDateTimeParam(String key) {
           	String datetimeString = restReq.params.get(key);
            if (String.isBlank(datetimeString)) {
                return null;
            }
            return utils.parseAsUtcIsoDateTime(dateTimeString);
        }

        public Date getRequiredDateParam(String key) {
            return getDateParam(checkForRequiredParam(key));
        }
        
        public Date getDateParam(String key) {
           	String dateString = getStringParam(key);
            if (String.isBlank(dateString)) {
                return null;
            }
            return utils.parseIsoDate(dateString);
        }

        public List<String> getRequiredListParam(String key) {
            return getListParam(checkForRequiredParam(key));
        }
        
        public List<String> getListParam(String key) {
            List<String> valuesList = new List<String>();
            String values = restReq.params.get(key);
            if (!String.isBlank(values)) {
                valuesList = values.split(',');
            }
            
            return valuesList;
        }

        public Integer getIntegerParam(String key) {
            String value = restReq.params.get(key);
            return value==null?null:Integer.valueOf(value);
        }

        public Integer getRequiredIntegerParam(String key) {
            return getIntegerParam(checkForRequiredParam(key));
        }

        public Boolean getBooleanParam(String key) {
            String value = restReq.params.get(key);
            return value==null?false:Boolean.valueOf(value);
        }
        
        public Boolean isDebug() {
            if (debug == null) {
				debug = Boolean.valueof(new BaseClass().firstNonEmpty(restReq.params.get('debug'), 'false'));
            }
            
            return debug;
        }
        
        public String getRequestBody() {
            return restReq.requestBody != null?restReq.requestBody.toString():null;
        }
    }
        
    global virtual class Response {
        public RestResponse restResp {get;set;}
        public JsonWriter jsonWriter {get;set;}
        global String errorCode {get;set;}
        global String message {get;set;}
        global Integer httpStatus {get;set;}
        global String details {get;set;}
        global String recordId {get;set;}
        global StopWatch stopWatch {get;set;}
    
        public Response(RestResponse restResp) {
            stopWatch = new StopWatch();
            jsonWriter = new JsonWriter();
            jsonWriter.ignoreNulls = true;
            
            this.restResp = restResp;
        }
        
        public Response setError(String errorCode, String message) {
            return setError(null, errorCode, message);
        }
        
        public Response setError(Integer httpStatus, String errorCode, String message) {
            this.httpStatus = httpStatus;
            this.errorCode = errorCode;
            this.message = message;
            
            return this;
        }
        
        public Response setResponse(String body) {
        	return setResponse(200, body);
        }
        
        public Response setResponse(Integer httpStatus, String body) {
            this.httpStatus = httpStatus;
            this.restResp.responseBody = Blob.valueOf(body);
            return this;
        }
        
    }
    
    global class Field implements Comparable {
        public String restField {get;set;}
        public String sfdcField {get;set;}
        public String operations {get;set;}
        
        public Field(String restField, String sfdcField) {
            this(restField, sfdcField, null);
        }
        
        public Field(String restField, String sfdcField, String operations) {
            this.restField = restField;
            this.sfdcField = sfdcField;
            this.operations = operations;
        }
        
        public Integer compareTo(Object obj) {
            
            //Returning reverse compare value as when it sent in the
            //response, it is appropriately sorted.
            return -restField.compareTo(((Field) obj).restField);
        }
    }
    
    public static Map<String, String> getFieldMapping(String apiName, String sobjName) {
    	Map<String, String> apiMapping = ApiFieldMappings.get(apiName + '-' + sobjName);
        if (apiMapping == null) {
            apiMapping = new Map<String, String>();
            List<Partner_Api_Field__c> apiFields = [
                select 
                	Rest_Field__c, 
                	Sfdc_Field__c 
                from Partner_Api_Field__c 
                where Api__c = :apiName 
                	and Sobject__c = :sobjName 
                	and Active__c = true
                order by Rest_Field__c desc];
            for (Partner_Api_Field__c apiField : apiFields) {
                apiMapping.put(apiField.Rest_Field__c, apiField.Sfdc_Field__c);
            }
            ApiFieldMappings.put(apiName + '-' + sobjName, apiMapping);
        }
        
        return apiMapping;
    }

    public static List<String> getRequiredFields(String apiName, String sobjName) {
    	List<String> requiredFields = ApiRequiredFields.get(apiName + '-' + sobjName);
        if (requiredFields == null) {
            requiredFields = new List<String>();
            List<Partner_Api_Field__c> apiFields = [select Rest_Field__c, Sfdc_Field__c from Partner_Api_Field__c where Api__c = :apiName and Sobject__c = :sobjName and Required__c = true];
            for (Partner_Api_Field__c apiField : apiFields) {
                requiredFields.add(apiField.Rest_Field__c);
            }
            ApiRequiredFields.put(apiName + '-' + sobjName, requiredFields);
        }
        
        return requiredFields;
    }
    
    public static List<String> getSummaryFields(String apiName) {
    	List<String> summayFields = ApiSummaryFields.get(apiName);
        if (summayFields == null) {
            summayFields = new List<String>();
            List<Partner_Api_Field__c> apiFields = [
                select 
                	Rest_Field__c, 
                	Sfdc_Field__c 
               	from Partner_Api_Field__c 
                where Api__c = :apiName and Summary_Field__c = true];
            for (Partner_Api_Field__c apiField : apiFields) {
                summayFields.add(apiField.Rest_Field__c);
            }
            ApiSummaryFields.put(apiName, summayFields);
        }
        
        return summayFields;
    }

    public static void insertFieldMapping(String apiName, String sobjName, String mapValue) {
       	Map<String, String> mapSetting = new Map<String, String>();
        
        String[] pairs = mapValue.split(',');
        for(String pair : pairs) {
            String[] keyValues = pair.split('=');
            mapSetting.put(keyValues[0], keyValues[1]);
        }
        
        insertFieldMapping(apiName, sobjName, mapSetting);
    }

    public static void insertFieldMapping(String apiName, String sobjName, Map<String, String> fieldMapping) {
        List<Partner_Api_Field__c> fields = new List<Partner_Api_Field__c>();
        for (String restField : fieldMapping.keyset()) {
            Partner_Api_Field__c field = new Partner_Api_Field__c();
            field.api__c = apiName;
            field.rest_field__c = restField;
            field.sfdc_field__c = fieldMapping.get(restfield);
            field.sobject__c = sobjName;
            fields.add(field);
        }

        insert fields;
    }

    public static void setRequiredFields(String apiName, String sobjName, List<String> requiredValues) {
        List<Partner_Api_Field__c> fieldsToUpdate = new List<Partner_Api_Field__c>();
        Map<String, String> requiredValuesMap = utils.getStringMap(requiredValues);
        List<Partner_Api_Field__c> fields = [select id, Rest_Field__c from Partner_Api_Field__c where Api__c = :apiName and Sobject__c = :sobjName];
        for (Partner_Api_Field__c field : fields) {
            if (requiredValuesMap.containsKey(field.Rest_Field__c)) {
                field.Required__c = true;
	            fieldsToUpdate.add(field);
            }
        }
        
        update fieldsToUpdate;
    }
    
    public static void setSummaryFields(String apiName, List<String> requiredValues) {
        List<Partner_Api_Field__c> fieldsToUpdate = new List<Partner_Api_Field__c>();
        Map<String, String> requiredValuesMap = utils.getStringMap(requiredValues);
        List<Partner_Api_Field__c> fields = [select id, Rest_Field__c from Partner_Api_Field__c where Api__c = :apiName];
        for (Partner_Api_Field__c field : fields) {
            if (requiredValuesMap.containsKey(field.Rest_Field__c)) {
                field.Summary_Field__c = true;
	            fieldsToUpdate.add(field);
            }
        }
        
        update fieldsToUpdate;
    }
    
}