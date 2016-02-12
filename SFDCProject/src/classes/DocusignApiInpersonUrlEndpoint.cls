@RestResource(urlMapping='/v2/eSign/inPersonUrl')
global class DocusignApiInpersonUrlEndpoint {
	@HttpGet
    global static void httpGet() {
		httpGet(RestContext.request, RestContext.response);
    }

    global static RestResponse httpGet(RestRequest restReq, RestResponse restResp) {
        return new DocusignApiGetInpersonUrlHandler().handleRequest(restReq, restResp);
    }
}