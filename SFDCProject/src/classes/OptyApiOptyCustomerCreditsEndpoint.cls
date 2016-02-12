@RestResource(urlMapping='/v2/leads/*/customercredits')
global class OptyApiOptyCustomerCreditsEndpoint {

    @HttpGet
    global static void httpGet() {
		httpGet(RestContext.request, RestContext.response);
    }

    global static RestResponse httpGet(RestRequest restReq, RestResponse restResp) {
        return new OptyApiGetOptyCustomerCreditsHandler().handleRequest(restReq, restResp);
    }
}