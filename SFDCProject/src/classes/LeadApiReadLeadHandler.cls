public with sharing class LeadApiReadLeadHandler extends LeadApiBaseHandler {
    override public String getApiName() {
        return 'LeadApiReadLead';
    }

    override public void handleRequest(RestServiceDto.Request req, RestServiceDto.Response resp) {
        String prospectId = getRecordIdFromPath(req, 'leads');
        if (isOpportunity(prospectId)) {
            new OptyApiReadOptyHandler().handleRequest(req, resp);
            return;
        }
        
        //Here is how we will handle the read.
        //
        //1. From the lead to rest api mapping get the list of fields that needs to be read
        //		mapping will not be there for audit fields, so they will need to be add separately.
        //2. Query the lead for prospect id with those fields
        //3. Create a json with all fields
        prepareResponse(queryLead(prospectId, req, resp), req, resp);
    }
    
    public Lead queryLead(String prospectId, RestServiceDto.Request req, RestServiceDto.Response resp) {
        List<Lead> leads = queryLeads(new String[]{prospectId}, req, resp);
        if (leads.isEmpty()) {
            throw createBusinessException(RestServiceDto.Error_NotFound, 'Lead with specified Prospect Id [' + prospectId + '] not found.');
        }
        return leads.get(0);
    }
 
    public List<Lead> queryLeads(List<String> prospectIds, RestServiceDto.Request req, RestServiceDto.Response resp) {

        String soql = createSoqlWithAuditFields(LeadApiDto.getLeadApiLeadFieldMapping().values(), 'Lead', 
					new String[]{'prospect_id__c in :prospectIds or external_id__c in :prospectIds'});
        
       	List<Lead> leads = Database.query(soql);
        
        resp.stopWatch.markSubElapsedTime();
        
        return leads;
    }
    
	public void prepareResponse(Lead lead, RestServiceDto.Request req, RestServiceDto.Response resp) {
        prepareResponse(lead, null, req, resp);
    }
    
	public void prepareResponse(Lead lead, Map<String, String> outputFields, RestServiceDto.Request req, RestServiceDto.Response resp) {
		Map<String, String> fieldMapping = LeadApiDto.getLeadApiLeadFieldMapping();
        
        Object value;
        for (String restField : fieldMapping.keySet()) {
            if (outputFields == null || outputFields.containsKey(restField)) {
                value = getValue(lead, fieldMapping.get(restField));
                resp.jsonWriter.writeIfNotNull(restField, value);
            }
        }
        
       	signLead (lead, resp);
        
		resp.jsonWriter.write('prospectQualified', false);
		resp.jsonWriter.write('createdDate', lead.CreatedDate);
		resp.jsonWriter.write('createdBy', lead.CreatedBy.UserName);
		resp.jsonWriter.write('lastModifiedDate', lead.LastModifiedDate);
		resp.jsonWriter.write('lastModifiedBy', lead.LastModifiedBy.UserName);

        resp.stopWatch.markSubElapsedTime();
    }
}