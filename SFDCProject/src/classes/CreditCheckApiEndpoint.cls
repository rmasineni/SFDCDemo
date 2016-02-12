@RestResource(urlMapping='/v2/creditCheck/*')
global class CreditCheckApiEndpoint {

    @HttpGet
    global static void httpGet() {
    	System.debug('RestContext.request: ' + RestContext.request);
		httpPost(RestContext.request, RestContext.response);
		System.debug('RestContext.response: ' + RestContext.response);
    }

    global static RestResponse httpPost(RestRequest restReq, RestResponse restResp) {
        return new CreditCheckApiHandler().handleRequest(restReq, restResp);
    }
}