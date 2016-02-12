public class DocumentUploadApiHandler extends ProposalBaseHandler{

	override public String getApiName() {
        return 'documentUpload';
    }

    override public void handleRequest(RestServiceDto.Request req, RestServiceDto.Response resp) {
		resp.jsonWriter = new JsonWriter(true);
		invokeSunrunProxy(req, resp);
    }
    
	public void invokeSunrunProxy(RestServiceDto.Request req, RestServiceDto.Response resp){
		String s3ProxyApiName = '/documentUploadUrls';
    	String serviceEndPoint = SunRunS3RestConnection.proxyEndpoint + s3ProxyApiName;
    	
    	Long Lexpires = SunRunS3RestConnection.getExpirationTime();
    	String encodedPath = SunRunS3RestConnection.sunrunS3BucketName + s3ProxyApiName;
    	String stringtosign = 'POST' +  '\n\n\n'+ Lexpires +'\n/'+ encodedPath;   
		
		String proxySettingsNameStr = SunRunS3RestConnection.QUALIFICATION_DOC;
		String accessKey = SunRunS3RestConnection.getAccessKey(proxySettingsNameStr);
    	String sunrunSecrectKey = SunRunS3RestConnection.getSecretKey(proxySettingsNameStr); 
    	String signed = SunRunS3RestConnection.make_sunrunProxysig(stringtosign,sunrunSecrectKey);
		String endPointURL = serviceEndPoint + '?AWSAccessKeyId=' + accessKey + '&Expires=' + Lexpires+'&Signature='+signed;
    	
    	Map<String, String> headers = new Map<String, String>();
    	headers.put('content-type', 'application/json');
    	BaseClass utils = new BaseClass();
		try {
        	String payload = getPayLoad(req);   //getPayLoad(req); //req.jsonReader.toJson();
			String result = utils.httpPost(endPointURL, payload ,headers);
			System.debug('result: ' + result);
        } catch (UnsuccessfulHttpResponseException exceptionObj) {
            if (exceptionObj.isStatusCode(201)) {
            	HTTPResponse httpResponse = exceptionObj.getResponse();
            	System.debug('httpResponse: ' + httpResponse);
            	processSuccessResponse(httpResponse, resp);
            } else {
                throw exceptionObj;
            }
        }
    }
    
    public String getPayLoad(RestServiceDto.Request req){
		String result = req.jsonReader.toJson();
    	JsonWriter jsonWriterObj = new JsonWriter(true);
    	List<Object> objectList = req.jsonReader.getList('');
    	System.debug('objectList: ' + objectList);
    	for(Integer i = 0; i < objectList.size(); i++){
			Map<String,Object> tempMap = (Map<String,Object>) objectList[i];
			jsonWriterObj.with(i);
		    for(String key : tempMap.keySet()){
		    	Object value = tempMap.get(key);
		    	//if(key == 'contentType'){
		    	//	continue;
		    	//}
		    	System.debug('key: ' + key);
                System.debug('value: ' + value);
                
		    	if(key == 'documentType'){
		    		System.debug('key: ' + key);
		    		value = getS3FolderNameByDocumentType('', '');
		    		System.debug('value: ' + value);
		    	}
				jsonWriterObj.write(key, value);	            	
		    }
			jsonWriterObj.endWith();
		}
    	result = jsonWriterObj.toJson(false);
    	return result;
    }
    
    public void processSuccessResponse(HTTPResponse httpResponse, RestServiceDto.Response resp){
		String result = httpResponse.getBody();
		JsonReader jsonReader = new JsonReader(result);
		Object jsonObj = jsonReader.getObject();
		List<Object> values = (List<Object>) jsonObj;
		for (Integer i = 0; i < values.size(); i++) {
		    Map<String,Object> tempMap = (Map<String,Object>) values[i];
		    resp.jsonWriter.with(i);
		    for(String key : tempMap.keySet()){
				resp.jsonWriter.write(key, tempMap.get(key));	            	
		    }
			resp.jsonWriter.endWith();
		}	    	
    }

}