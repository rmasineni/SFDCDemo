public class DocusignApiGetInpersonUrlHandler extends ProposalBaseHandler{
    override public String getApiName() {
        return 'docuSignInpersonUrl';
    }

    override public void handleRequest(RestServiceDto.Request req, RestServiceDto.Response resp) {
	    String proposalId = req.getRequiredStringParam('proposalId');
	    String envelopId = req.getRequiredStringParam('envelopeId');
	    String recipientStr = req.getRequiredStringParam('recipient');
	    if(String.isEmpty(envelopId)){
			throw createBusinessException(RestServiceDto.Error_InvalidRequest, 'Envelop Id missing in the request.');
	    }
        
        Integer recipient = integer.valueof(recipientStr);
        String resultUrl = getDocuSignInpersonSigningURL(envelopId, recipient, '');
        resp.jsonWriter.write('url', resultUrl);
    }  
}