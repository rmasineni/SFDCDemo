@RestResource(urlMapping='/v2/modifyProposal/*')
global class ProposalApiModifyEndpoint {
    @HttpPatch
    global static void httpPatch() {
        System.debug('RestContext.request: ' + RestContext.request);
        httpPost(RestContext.request, RestContext.response);
        System.debug('RestContext.response: ' + RestContext.response);
    }
 
    global static RestResponse httpPost(RestRequest restReq, RestResponse restResp) {
        return new ProposalModifyApiHandler().handleRequest(restReq, restResp);
    }
  
}