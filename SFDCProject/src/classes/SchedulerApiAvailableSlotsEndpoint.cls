@RestResource(urlMapping='/v2/appointments/availableslots')
global class SchedulerApiAvailableSlotsEndpoint {

    @HttpGet
    global static void httpGet() {
		httpGet(RestContext.request, RestContext.response);
    }

    global static RestResponse httpGet(RestRequest restReq, RestResponse restResp) {
        return new SchedulerApiGetAvailableSlotsHandler().handleRequest(restReq, restResp);
    }
}