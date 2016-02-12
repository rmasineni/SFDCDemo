@RestResource(urlMapping='/v2/prospects/*')
global class ProspectApiProspectEndpoint {

    @HttpGet
    global static void httpGet() {
		httpGet(RestContext.request, RestContext.response);
    }

    global static RestResponse httpGet(RestRequest restReq, RestResponse restResp) {
		return new ProspectApiReadProspectHandler().handleRequest(restReq, restResp);
    }
}