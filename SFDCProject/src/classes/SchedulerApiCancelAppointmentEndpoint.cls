@RestResource(urlMapping='/v2/appointments/*/cancel')
global with sharing class SchedulerApiCancelAppointmentEndpoint {
    
    @HttpPatch
    global static void httpPatch() {
		httpPatch(RestContext.request, RestContext.response);
    }

    global static RestResponse httpPatch(RestRequest restReq, RestResponse restResp) {
        return new SchedulerApiCancelAppointmentHandler().handleRequest(restReq, restResp);
    }
}