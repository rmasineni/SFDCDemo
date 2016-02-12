@RestResource(urlMapping='/v2/opportunities/*')
global class OptyApiOptyEndpoint {

    @HttpPatch
    global static void httpPatch() {
		httpPatch(RestContext.request, RestContext.response);
    }

    global static RestResponse httpPatch(RestRequest restReq, RestResponse restResp) {
        return new OptyApiUpdateOptyHandler().handleRequest(restReq, restResp);
    }

    @HttpGet
    global static void httpGet() {
		httpGet(RestContext.request, RestContext.response);
    }
    
    global static RestResponse httpGet(RestRequest restReq, RestResponse restResp) {
        return new OptyApiReadOptyHandler().handleRequest(restReq, restResp);
    }
}