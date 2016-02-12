@RestResource(urlMapping='/v2/leads/*/contacts/*')
global class OptyApiOptyContactEndpoint {

    @HttpPatch
    global static void httpPatch() {
		httpPatch(RestContext.request, RestContext.response);
    }

    global static RestResponse httpPatch(RestRequest restReq, RestResponse restResp) {
        return new OptyApiUpdateOptyContactHandler().handleRequest(restReq, restResp);
    }
}