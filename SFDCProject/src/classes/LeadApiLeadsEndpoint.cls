@RestResource(urlMapping='/v2/leads')
global class LeadApiLeadsEndpoint {

    @HttpGet
    global static void httpGet() {
		httpGet(RestContext.request, RestContext.response);
    }

    global static RestResponse httpGet(RestRequest restReq, RestResponse restResp) {
        return new LeadApiGetLeadsHandler().handleRequest(restReq, restResp);
    }

    @HttpPost
    global static void httpPost() {
		httpPost(RestContext.request, RestContext.response);
    }

    global static RestResponse httpPost(RestRequest req) {
		return httpPost(req, new RestResponse());
    }

    global static RestResponse httpPost(RestRequest restReq, RestResponse restResp) {
        return new LeadApiCreateLeadHandler().handleRequest(restReq, restResp);
    }
}