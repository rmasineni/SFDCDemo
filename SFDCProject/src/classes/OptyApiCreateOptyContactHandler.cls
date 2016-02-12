global class OptyApiCreateOptyContactHandler extends OptyApiBaseHandler {

    global override String getApiName() {
        return 'OptyApiCreateOptyContact';
    }
    
    global override void handleRequest(RestServiceDto.Request req, RestServiceDto.Response resp) {
        
        processDefaultsAndOverrides(getApiName(), req.jsonReader);
        
        OptyContactRoleDetails details = parseOptyContactRole(req, resp);
        
        validateRequest(details, req, resp);
        
        saveRequest(details, req, resp);
        
        prepareResponse(details, req, resp);
    }
    
    public class OptyContactRoleDetails {
        public String prospectId {get;set;}
        public Opportunity opty {get;set;}
        public Contact contact {get;set;}
        public OpportunityContactRole optyContactRole {get;set;}
    }
    
    public OptyContactRoleDetails parseOptyContactRole(RestServiceDto.Request req, RestServiceDto.Response resp) {
        
        OptyContactRoleDetails details = new OptyContactRoleDetails();
        details.prospectId = getProspectIdFromPath(req);
        details.opty = queryOpty(req, resp);
        
        details.contact = new Contact();
        copyRestFieldsToSfdcFields(details.contact, OptyApiDto.getOptyApiContactFieldMapping(), req);
        details.contact.AccountId = details.opty.AccountId;
        
        details.optyContactRole = new OpportunityContactRole();
        copyRestFieldValue(req.jsonReader, 'role', details.optyContactRole, 'Role', true);
        copyRestFieldValue(req.jsonReader, 'primary', details.optyContactRole, 'IsPrimary', true);

        resp.stopwatch.markSubElapsedTime();
        
        return details;
    }
    
	/**
	 * Validate the leads to make sure they have the appropriate fields populated.
	 * 
	 * if there is any error, then populate the corresponding leads status=error, (and code/message as appropriate)
	 */
    public void validateRequest(OptyContactRoleDetails details, RestServiceDto.Request req, RestServiceDto.Response resp) {
        List<String> requriedFields = Sf.settingsService.getStringList('OptyApiContactRequiredFields', new List<String>());
		requriedFields.add('role');
        
		validateRequiredFields(requriedFields, req);

        //Check if there is already opty contact role with specified email.
        OpportunityContactRole role = queryOptyContactRoleByEmail(details.opty.id, details.contact.email);
        if (role != null) {
            throw createBusinessException(RestServiceDto.Error_ValidationError, 
				'Contact with specified email [' + details.contact.email 
				+ '] already exists for specified lead [' + details.prospectId + ']');
        }
        
        resp.stopwatch.markSubElapsedTime();
    }

	/**
	 * Finally inserts or updates the leads as appropriate.
	 */
    public void saveRequest(OptyContactRoleDetails details, RestServiceDto.Request req, RestServiceDto.Response resp) {
        //Save contact first.			
        insert details.contact;
        
        details.optyContactRole.ContactId = details.contact.id;
        details.optyContactRole.OpportunityId = details.opty.id;
        
        insert details.optyContactRole;
        
        resp.stopwatch.markSubElapsedTime();            
    }

	/**
	 * Prepare the lead responses to be returned to client. You can populate the required fields
	 */ 
    public void prepareResponse(OptyContactRoleDetails details, RestServiceDto.Request req, RestServiceDto.Response resp) {
		
        OpportunityContactRole role = queryOptyContactRoleByEmail(details.opty.id, details.contact.email);
		addOptyContactRoleToResponse(role, req, resp);
        
        resp.stopwatch.markSubElapsedTime();
    }
    
}