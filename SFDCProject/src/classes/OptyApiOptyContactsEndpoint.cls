@RestResource(urlMapping='/v2/leads/*/contacts')
global class OptyApiOptyContactsEndpoint {

    @HttpPost
    global static void httpPost() {
		httpPost(RestContext.request, RestContext.response);
    }

    global static RestResponse httpPost(RestRequest restReq, RestResponse restResp) {
        return new OptyApiCreateOptyContactHandler().handleRequest(restReq, restResp);
    }

    @HttpGet
    global static void httpGet() {
		httpGet(RestContext.request, RestContext.response);
    }

    global static RestResponse httpGet(RestRequest restReq, RestResponse restResp) {
        return new OptyApiGetOptyContactsHandler().handleRequest(restReq, restResp);
    }
}