public with sharing class ProposalApiUpdateProposalHandler extends ProposalBaseHandler implements RestRequestHandler {
    public override String getApiName() {
        return 'ProposalApiUpdateProposal';
    }
	
	public override void handleRequest(RestServiceDto.Request req, RestServiceDto.Response resp) {
		String pathId = getPathId(req.restReq);
		String proposalId = getRecordIdFromPath(req, 'proposals');
		String srAttachmentId = getRecordIdFromPath(req, 'sr_attachments');
		if(!String.isEmpty(srAttachmentId)){
			String activeStatus = req.jsonReader.getString('active');
			List<SR_Attachment__c> srArrachments = queryAndUpdateSRAttachments(proposalId, srAttachmentId, activeStatus);
			prepareSRAttachmentResponse(srArrachments, req, resp);
			resp.stopWatch.markSubElapsedTime();
		}
	}
	
	public List<SR_Attachment__c> queryAndUpdateSRAttachments(String proposalName, String srAttachmentId, String activeStatus) {
		Set<String> srIds = new Set<String>{srAttachmentId};
		List<SR_Attachment__c> srAttachments = getSRAttachments(proposalName, null, srIds);
        if (srAttachments == null || srAttachments.isEmpty()) {
            throw createBusinessException(RestServiceDto.Error_NotFound, 'SR Attachments with specified Proposal Number [' + proposalName + '] is not found');
        }
        
        try{
			for(SR_Attachment__c srAttachmentObj : srAttachments){
	        	srAttachmentObj.active__c = (activeStatus == 'false') ? false : srAttachmentObj.active__c;
	        }
	        if(srAttachments != null && !srAttachments.isEmpty()){
	        	update srAttachments;
	        }
        }catch(Exception expObj){
        	throw createBusinessException(RestServiceDto.Unable_To_Process_Request, expObj.getmessage());
        }
		return srAttachments;
    }

}