@RestResource(urlMapping='/v2/srattachments/documentUpload')
global class DocumentUploadApiEndpoint {

    @HttpPost
    global static void httpPost() {
    	System.debug('RestContext.request: ' + RestContext.request);
		httpPost(RestContext.request, RestContext.response);
		System.debug('RestContext.response: ' + RestContext.response);
    }

    global static RestResponse httpPost(RestRequest restReq, RestResponse restResp) {
        return new DocumentUploadApiHandler().handleRequest(restReq, restResp);
    }
}