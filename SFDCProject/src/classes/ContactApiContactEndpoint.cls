@RestResource(urlMapping='/v2/contacts/*')
global class ContactApiContactEndpoint {

    @HttpGet
    global static void httpGet() {
		httpGet(RestContext.request, RestContext.response);
    }
    
    global static RestResponse httpGet(RestRequest restReq, RestResponse restResp) {
        return new ContactApiGetContactHandler().handleRequest(restReq, restResp);
    }

    @HttpPatch
    global static void httpPatch() {
		httpPatch(RestContext.request, RestContext.response);
    }
    
    global static RestResponse httpPatch(RestRequest restReq, RestResponse restResp) {
        return new ContactApiUpdateContactHandler().handleRequest(restReq, restResp);
    }
}