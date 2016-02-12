@RestResource(urlMapping='/v2/opportunities')
global class OptyApiOptysEndpoint {

    @HttpPost
    global static void httpPost() {
		httpPost(RestContext.request, RestContext.response);
    }

    global static RestResponse httpPost(RestRequest restReq, RestResponse restResp) {
        return new OptyApiCreateOptyHandler().handleRequest(restReq, restResp);
    }
}