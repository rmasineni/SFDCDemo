@RestResource(urlMapping='/v2/proposals/*')
global class ProposalApiProposalEndpoint {

    @HttpGet
    global static void httpGet() {
		httpGet(RestContext.request, RestContext.response);
    }
    
    global static RestResponse httpGet(RestRequest restReq, RestResponse restResp) {
        return new ProposalApiGetProposalHandler().handleRequest(restReq, restResp);
    }

    @HttpPatch
    global static void httpPatch() {
		httpPatch(RestContext.request, RestContext.response);
    }

    global static RestResponse httpPatch(RestRequest restReq, RestResponse restResp) {
        return new ProposalApiUpdateProposalHandler().handleRequest(restReq, restResp);
    }
}