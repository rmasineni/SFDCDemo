global interface RestRequestHandler {
    /**
     * Implemenetation should return the name of the api this handler implements. This name is used
     * to log the request/response payloads, look up the fields defaults etc.
	 */    
    String getApiName();
    
    RestResponse handleRequest(RestRequest restReq, RestResponse restResp);

	void handleRequest(RestServiceDto.Request req, RestServiceDto.Response resp);
}