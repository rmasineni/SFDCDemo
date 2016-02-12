@RestResource(urlMapping='/v2/leads/*/nearbycustomers')
global class LeadApiNearbyCustomersEndpoint {

    @HttpGet
    global static void httpGet() {
		httpGet(RestContext.request, RestContext.response);
    }

    global static RestResponse httpGet(RestRequest restReq, RestResponse restResp) {
        return new LeadApiGetNearbyCustomersHandler().handleRequest(restReq, restResp);
    }
}