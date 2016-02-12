global with sharing class LeadApiDeleteLeadHandler extends LeadApiBaseHandler {
    override public String getApiName() {
        return 'LeadApiDeleteLead';
    }

    override public void handleRequest(RestServiceDto.Request req, RestServiceDto.Response resp) {
        
        //Unpublished parameter to allow deletes
        if (req.getBooleanParam('allowDelete')) {
            String prospectId = getPathId(req.restReq);
            List<Lead> leads = [select id from lead where Prospect_id__c = :prospectId];
            if (!leads.isEmpty()) {
                delete leads;
            }
        }
    }
}