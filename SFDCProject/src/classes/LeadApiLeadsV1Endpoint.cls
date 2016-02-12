@RestResource(urlMapping='/v1/leads/createLead')
global class LeadApiLeadsV1Endpoint {

    @HttpPost
    global static void httpPost() {
		httpPost(RestContext.request, RestContext.response);
    }

    global static RestResponse httpPost(RestRequest restReq, RestResponse restResp) {
        return new LeadApiCreateLeadHandler(true).handleRequest(restReq, restResp);
    }
}