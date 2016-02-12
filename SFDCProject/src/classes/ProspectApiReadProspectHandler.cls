public class ProspectApiReadProspectHandler extends ProposalBaseHandler {

    override public String getApiName() {
        return 'ProspectApiReadProspect';
    }

    override public void handleRequest(RestServiceDto.Request req, RestServiceDto.Response resp) {
		String prospectId = getRecordIdFromPath(req, 'prospects');
		String proposalsStr = getPathId(req.restReq);
		Opportunity optyObj = getOpportunity(prospectId);       
        if(optyObj == null || optyObj.Id == null){
        	throw createBusinessException(RestServiceDto.Error_NotFound, 'Proposals for the specified Prospect Id [' + prospectId + '] not found.');
        }
        
        //Here is how we will handle the read.
        //
        //1. From the Proposal to rest api mapping get the list of fields that needs to be read
        //		mapping will not be there for audit fields, so they will need to be add separately.
        //2. Query the Proposal for prospect id with those fields
        //3. Create a json with all fields
        if(proposalsStr == 'proposals'){
			prepareResponse(queryProposals(optyObj.Id, prospectId, req, resp), req, resp);
        }
    }

    public List<Proposal__c> queryProposals(String optyId, String prospectId, RestServiceDto.Request req, RestServiceDto.Response resp) {
        List<Proposal__c> proposals = queryProposals(new String[]{optyId}, req, resp);
        if (proposals.isEmpty()) {
            throw createBusinessException(RestServiceDto.Error_NotFound, 'Proposal with specified Prospect Id [' + prospectId + '] not found.');
        }
        System.debug('proposals: ' + proposals);
        return proposals;
    }

    public List<Proposal__c> queryProposals(List<String> optyIds, RestServiceDto.Request req, RestServiceDto.Response resp) {
		Set<String> proposalStages = new Set<String>();
		proposalStages.add('Submitted');
		proposalStages.add('Created');
		String soql = createSoqlWithAuditFields(ProposalApiDto.getProspectApiProposalFieldMapping().values(), 'Proposal__c', 
					new String[]{'Opportunity__c in :optyIds and Stage__c in :proposalStages order by lastmodifieddate desc '});
		List<Proposal__c> proposals = Database.query(soql);
		resp.stopWatch.markSubElapsedTime();
        return proposals;
    }

	public void prepareResponse(List<Proposal__c> proposals, RestServiceDto.Request req, RestServiceDto.Response resp) {
        prepareResponse(proposals, null, req, resp);
    }
    
	public void prepareResponse(List<Proposal__c> proposals, Map<String, String> outputFields, RestServiceDto.Request req, RestServiceDto.Response resp) {
		Map<String, String> fieldMapping = ProposalApiDto.getProspectApiProposalFieldMapping();
        resp.jsonWriter = new JsonWriter(true);
        Integer i = 0;
        for(Proposal__c proposalObj : proposals){
        	resp.jsonWriter.with(i);
	        Object value;
			System.debug('fieldMapping: ' + fieldMapping);
	        for (String restField : fieldMapping.keySet()) {
	            //if (outputFields == null || outputFields.containsKey(restField)) {
	                value = proposalObj.get(fieldMapping.get(restField));
	                resp.jsonWriter.writeIfNotNull(restField, value);
	            //}
	        }
			resp.jsonWriter.write('createdDate', proposalObj.CreatedDate);
			resp.jsonWriter.write('createdBy', proposalObj.CreatedBy.UserName);
			resp.jsonWriter.write('lastModifiedDate', proposalObj.LastModifiedDate);
			resp.jsonWriter.write('lastModifiedBy', proposalObj.LastModifiedBy.UserName);     
			resp.jsonWriter.endWith();
			i++;   	
        }
		resp.stopWatch.markSubElapsedTime();
    }

}