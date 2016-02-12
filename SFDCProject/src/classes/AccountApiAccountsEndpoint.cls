@RestResource(urlMapping='/v2/accounts')
global class AccountApiAccountsEndpoint {

    @HttpGet
    global static void httpGet() {
		httpGet(RestContext.request, RestContext.response);
    }

    global static RestResponse httpGet(RestRequest restReq, RestResponse restResp) {
        return new AccountApiGetAccountsHandler().handleRequest(restReq, restResp);
    }
}