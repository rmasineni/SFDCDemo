@RestResource(urlMapping='/v2/leads/*')
global class LeadApiLeadEndpoint {

    @HttpPatch
    global static void httpPatch() {
		httpPatch(RestContext.request, RestContext.response);
    }

    global static RestResponse httpPatch(RestRequest restReq, RestResponse restResp) {
        return new LeadApiUpdateLeadHandler().handleRequest(restReq, restResp);
    }

    @HttpGet
    global static void httpGet() {
		httpGet(RestContext.request, RestContext.response);
    }
    
    global static RestResponse httpGet(RestRequest restReq) {
        return httpGet(restReq, new RestResponse());
    }

    global static RestResponse httpGet(RestRequest restReq, RestResponse restResp) {
        return new LeadApiReadLeadHandler().handleRequest(restReq, restResp);
    }

    @HttpDelete
    global static void httpDelete() {
		httpDelete(RestContext.request, RestContext.response);
    }

    global static RestResponse httpDelete(RestRequest restReq, RestResponse restResp) {
        return new LeadApiDeleteLeadHandler().handleRequest(restReq, restResp);
    }
}