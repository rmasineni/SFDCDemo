@RestResource(urlMapping='/v2/leads/*/appointments')
global class OptyApiOptyAppointmentsEndpoint {

    @HttpGet
    global static void httpGet() {
		httpGet(RestContext.request, RestContext.response);
    }

    global static RestResponse httpGet(RestRequest restReq, RestResponse restResp) {
        return new OptyApiGetOptyAppointmentsHandler().handleRequest(restReq, restResp);
    }
}