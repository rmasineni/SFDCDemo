public with sharing class OptyApiUpdateOptyContactHandler extends OptyApiBaseHandler {
    override public String getApiName() {
        return 'OptyApiUpdateOptyContact';
    }

    /**
     * Method implements the patch protocol for lead. For patch, it will process only the fields
     * which are explicitly requested in the request.
     */ 
    override public void handleRequest(RestServiceDto.Request req, RestServiceDto.Response resp) {
        
        processDefaultsAndOverrides(getApiName(), req.jsonReader);
		Opportunity opty = queryOpty(req, resp);

        String contactNum = getRecordIdFromPath(req, 'contacts');
        OpportunityContactRole role = queryOptyContactRoleByContactNum(opty.id, contactNum);
        if (role == null) {
            throw createBusinessException(RestServiceDto.Error_NotFound, 'Contact with specified Contact Number [' + contactNum + '] not found.');
        }

        applyPatch(role, OptyApiDto.getOptyApiContactRoleFieldMapping(), req);
        applyPatch(role.Contact, OptyApiDto.getOptyApiContactFieldMapping(), req);
        
	    validateRequiredFields(role, OptyApiDto.getOptyApiContactRoleRequiredFields(), OptyApiDto.getOptyApiContactRoleFieldMapping());
	    validateRequiredFields(role.contact, OptyApiDto.getOptyApiContactRoleRequiredFields(), OptyApiDto.getOptyApiContactRoleFieldMapping());
		
        update role;
        update role.contact;
        
        addOptyContactRoleToResponse(role, req, resp);
    }
    
    
}