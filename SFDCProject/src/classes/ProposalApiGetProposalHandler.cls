public with sharing class ProposalApiGetProposalHandler extends ProposalBaseHandler implements RestRequestHandler {
    public override String getApiName() {
        return 'ProposalApiGetProposal';
    }
	
	public override void handleRequest(RestServiceDto.Request req, RestServiceDto.Response resp) {
		String pathId = getPathId(req.restReq);
		String proposalId = getRecordIdFromPath(req, 'proposals');
		if(pathId == 'sr_attachments'){
			String documentType = req.getStringParam('documentType');
			List<SR_Attachment__c> srAttachments = getSRAttachments(proposalId, documentType, null);
	        if (srAttachments == null || srAttachments.isEmpty()) {
	            throw createBusinessException(RestServiceDto.Error_NotFound, 'SR Attachments with specified Proposal [' + proposalId + '] is not found');
	        }
			prepareSRAttachmentResponse(srAttachments, req, resp);
			resp.stopWatch.markSubElapsedTime();
		}else{ 
        	addToResponse(queryProposal(req, resp), getProposalFieldMapping(), true, req, resp);
		}
	}
	
	public Proposal__c queryProposal(RestServiceDto.Request req, RestServiceDto.Response resp) {
		String proposalNumber =  getRecordIdFromPath('proposals', req);
		String soql = createSoqlWithAuditFields(getProposalFieldMapping().values(), 'Proposal__c', 'Name = :proposalNumber');
		List<SObject> sobjs = Database.query(soql);
		if (sobjs.isEmpty()) {
            throw createBusinessException(RestServiceDto.Error_NotFound, 'Proposal with specified Proposal Number [' + proposalNumber + '] is not found');
        }
		resp.stopWatch.markSubElapsedTime();
		return (Proposal__c) sobjs.get(0);
    }

}