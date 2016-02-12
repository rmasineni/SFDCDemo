@RestResource(urlMapping='/v2/appointments/*')
global class SchedulerApiAppointmentEndpoint {

    @HttpGet
    global static void httpGet() {
		httpGet(RestContext.request, RestContext.response);
    }

    global static RestResponse httpGet(RestRequest restReq, RestResponse restResp) {
        return new SchedulerApiGetAppointmentHandler().handleRequest(restReq, restResp);
    }

    @HttpPatch
    global static void httpPatch() {
		httpPatch(RestContext.request, RestContext.response);
    }

    global static RestResponse httpPatch(RestRequest restReq, RestResponse restResp) {
        return new SchedulerApiUpdateAppointmentHandler().handleRequest(restReq, restResp);
    }
}