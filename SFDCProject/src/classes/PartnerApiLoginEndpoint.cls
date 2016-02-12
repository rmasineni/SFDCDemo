@RestResource(urlMapping='/v2/login')
global class PartnerApiLoginEndpoint extends BaseClass {
    private static final String SandboxLoginUrl = 'https://test.salesforce.com/services/Soap/u/34.0';
    private static final String ProdLoginUrl = 'https://login.salesforce.com/services/Soap/u/34.0';
    private static final Map<String, Integer> ErrorCodeToStatusCodeMap = new Map<String, Integer>{
        'INVALID_LOGIN' => 403,
        'PASSWORD_LOCKOUT' => 403,
        'LOGIN_MUST_USE_SECURITY_TOKEN' => 403,
        'LOGIN_CHALLENGE_PENDING' => 403,
        'LOGIN_CHALLENGE_ISSUED' => 403,
        'REQUIRED_FIELDS_MISSING' => 401
    };
    private static final String LoginBodyTemplate = '<Envelope xmlns="http://schemas.xmlsoap.org/soap/envelope/"> <Body> <login xmlns="urn:partner.soap.sforce.com"> <username>{UserName}</username> <password>{Password}</password> </login> </Body> </Envelope>';
    private static final List<String> BasicResponseFields = new String[]{
        'metadataServerUrl',
        'passwordExpired',
        'sandbox',
        'userId',
        'serverUrl',
        'sessionId'
	};
    private static final List<String> UserInfoResponseFields = new String[]{
        'userInfo.accessibilityMode',
        'userInfo.currencySymbol',
        'userInfo.orgAttachmentFileSizeLimit',
        'userInfo.orgDefaultCurrencyIsoCode',
        'userInfo.orgDisallowHtmlAttachments',
        'userInfo.orgHasPersonAccounts',
        'userInfo.organizationId',
        'userInfo.organizationMultiCurrency',
        'userInfo.organizationName',
        'userInfo.profileId',
        'userInfo.roleId',
        'userInfo.sessionSecondsValid',
        'userInfo.userDefaultCurrencyIsoCode',
        'userInfo.userEmail',
        'userInfo.userFullName',
        'userInfo.userId',
        'userInfo.userLanguage',
        'userInfo.userLocale',
        'userInfo.userName',
        'userInfo.userTimeZone',
        'userInfo.userType',
        'userInfo.userUiSkin'
	};
    private static final Map<String, String> BooleanFields = new Map<String, String>{
        'sandbox' => '',
        'passwordExpired' => '',
        'userInfo.organizationMultiCurrency' => '',
        'userInfo.orgHasPersonAccounts' => '',
        'userInfo.accessibilityMode' => '',
        'userInfo.orgDisallowHtmlAttachments' => ''
    };
        
    @HttpPost
    global static void httpPost() {
        new PartnerApiLoginEndpoint().processHttpPost();
    }
    
    public void processHttpPost() {
        
        try {
            if (RestContext.request.requestBody == null || String.isBlank(RestContext.request.requestBody.toString())) {
                throw new BusinessException('REQUIRED_FIELDS_MISSING', 'Missing required fields [userName or password]');
            }

            JsonReader reader = new JsonReader(RestContext.request.requestBody.toString());
            String userName = reader.getString('userName');
            String password = reader.getString('password');
            Boolean includeProfile = reader.getBoolean('includeProfile');
            
            if (String.isBlank(userName) || String.isBlank(password)) {
                throw new BusinessException('REQUIRED_FIELDS_MISSING', 'Missing required fields [userName or password]');
            }
            
            String loginRequest = replaceMergeTokens(LoginBodyTemplate, new Map<String, String>{'UserName' => userName, 'Password' => password});
            Boolean sandBox = isTrue(firstNonNull(reader.getBoolean('sandbox'), false));
			String loginResponse = login(sandbox, loginRequest);
            
            JsonWriter jsonWriter = new JsonWriter();
            XmlReader xml = new XmlReader(loginResponse);

            if (includeProfile) {
                for (String field : UserInfoResponseFields) {
                    String value = xml.getString('Body.loginResponse.result.' + field);
                    if (BooleanFields.containsKey(field)) {
                        jsonWriter.write(field, Boolean.valueOf(value));
                    } else {
                        jsonWriter.write(field, value);
                    }
                }
            }

            for (String field : BasicResponseFields) {
                String value = xml.getString('Body.loginResponse.result.' + field);
                if (BooleanFields.containsKey(field)) {
					jsonWriter.write(field, Boolean.valueOf(value));
                } else {
	                jsonWriter.write(field, value);
                }
            }
	            
            //Also write the partner api base path. This helps them to connect to it appropriately.
            Url url = new Url(xml.getString('Body.loginResponse.result.serverUrl'));
            String partnerApiBaseUrl = 'https://' + url.getHost() + '/services/apexrest';
            jsonWriter.write('restApiBaseUrl', partnerApiBaseUrl);
            
            RestContext.response.responseBody = Blob.valueOf(jsonWriter.toPrettyJson());
            RestContext.response.statusCode = 200;
        } catch (Exception e) {
			handleException(e, isTrue(RestContext.request.params.get('debug')));
        }
    }
    
    public String login(Boolean sandbox, String loginRequest) {
		return httpPost(sandbox?SandboxLoginUrl:ProdLoginUrl, 
			loginRequest, new Map<String, String>{'Content-Type' => 'text/xml', 'SOAPAction' => '""'});
    }
    
    public void handleException(Exception e, Boolean debug) {
        String errorCode = null;
        String message = null;
        Integer httpCode = null;
        
        if (e instanceof BusinessException) {
            BusinessException be = (BusinessException) e;
            errorCode = be.errorCode;
            message = be.getMessage();
            httpCode = be.statusCode!=null?Integer.valueOf(be.statusCode):null;
            
        } else if (e instanceof UnsuccessfulHttpResponseException) {
            UnsuccessfulHttpResponseException ue = (UnsuccessfulHttpResponseException) e;
            XmlReader xml = new XmlReader(ue.getResponse().getBody());
            errorCode = xml.getString('Body.Fault.detail.LoginFault.exceptionCode');
            message = xml.getString('Body.Fault.detail.LoginFault.exceptionMessage');
        }
        
        errorCode = errorCode!=null?errorCode:'INTERNAL_SERVER_ERROR';
        httpCode = ErrorCodeToStatusCodeMap.containsKey(errorCode)?ErrorCodeToStatusCodeMap.get(errorCode):500;
        message = message!=null?message:String.valueOf(e);
        
        JsonWriter jsonWriter = new JsonWriter();
        jsonWriter.write('errorCode', errorCode);
        jsonWriter.write('message', message);
        if (debug) {
	        jsonWriter.write('details', getExceptionDetails(e));
        }       
        RestContext.response.responseBody = Blob.valueOf(jsonWriter.toPrettyJson());
        RestContext.response.statusCode = httpCode;
    }
}