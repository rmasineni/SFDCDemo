@RestResource(urlMapping='/v2/leads/*/payment-url')
global class OptyApiPaymentUrlEndpoint {

    @HttpPost
    global static void httpPost() {
		httpPost(RestContext.request, RestContext.response);
    }

    global static RestResponse httpPost(RestRequest restReq, RestResponse restResp) {
        return new OptyApiCreatePaymentUrlHandler().handleRequest(restReq, restResp);
    }

    @HttpGet
    global static void httpGet() {
		httpGet(RestContext.request, RestContext.response);
    }

    global static RestResponse httpGet(RestRequest restReq, RestResponse restResp) {
        return new OptyApiGetPaymentUrlHandler().handleRequest(restReq, restResp);
    }
}