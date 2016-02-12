@RestResource(urlMapping='/v2/leads/*/payments')
global class OptyApiOptyPaymentsEndpoint {

    @HttpGet
    global static void httpGet() {
		httpGet(RestContext.request, RestContext.response);
    }

    global static RestResponse httpGet(RestRequest restReq, RestResponse restResp) {
        return new OptyApiGetOptyPaymentsHandler().handleRequest(restReq, restResp);
    }
}