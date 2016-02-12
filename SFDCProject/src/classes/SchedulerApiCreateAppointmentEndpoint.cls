@RestResource(urlMapping='/v2/appointments/create')
global class SchedulerApiCreateAppointmentEndpoint {

    @HttpPost
    global static void httpPost() {
		httpPost(RestContext.request, RestContext.response);
    }

    global static RestResponse httpPost(RestRequest restReq, RestResponse restResp) {
        return new SchedulerApiCreateAppointmentHandler().handleRequest(restReq, restResp);
    }
}