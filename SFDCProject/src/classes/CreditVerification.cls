@RestResource(urlMapping='/v2/creditVerification/*')
global class CreditVerification {

    @HttpGet
    global static void httpGet() {
		httpGet(RestContext.request, RestContext.response);
    }

    global static RestResponse httpGet(RestRequest restReq, RestResponse restResp) {
        return null;
        //return new CreditVerificationHandler().handleRequest(restReq, restResp);
    }

}