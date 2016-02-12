@RestResource(urlMapping='/v2/srattachments/create')
global class SRAttachmentApiCreateAttachmentEndpoint {
	
	@HttpPost
    global static void httpPost() {
		httpPost(RestContext.request, RestContext.response);
    }

    global static RestResponse httpPost(RestRequest restReq, RestResponse restResp) {
        return new SRAttachmentApiCreateAttachmentHandler().handleRequest(restReq, restResp);
    }
}