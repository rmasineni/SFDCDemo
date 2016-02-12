@RestResource(urlMapping='/v2/contracts/*')
global class ContractApiContractEndpoint {

    @HttpGet
    global static void httpGet() {
		httpGet(RestContext.request, RestContext.response);
    }
    
    global static RestResponse httpGet(RestRequest restReq, RestResponse restResp) {
        return new ContractApiGetContractHandler().handleRequest(restReq, restResp);
    }

    @HttpPatch
    global static void httpPatch() {
		httpPatch(RestContext.request, RestContext.response);
    }
    
    global static RestResponse httpPatch(RestRequest restReq, RestResponse restResp) {
        return new ContractApiUpdateContractHandler().handleRequest(restReq, restResp);
    }
}