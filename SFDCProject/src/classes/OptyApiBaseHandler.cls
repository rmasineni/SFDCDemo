public abstract class OptyApiBaseHandler extends RestService {

    public String getProspectIdFromPath(RestServiceDto.Request req) {
        try {
	        return getRecordIdFromPath(req, 'leads');
        } catch (BusinessException e) {
	        return getRecordIdFromPath(req, 'opportunities');
        }
    }
    
    public List<Opportunity> queryOptys(List<String> prospectIds, RestServiceDto.Request req, RestServiceDto.Response resp) {
		List<String> fields = OptyApiDto.getOptyApiOptyFieldMapping().values();
		
        //Include account fields.
        for(String accountField : OptyApiDto.getOptyApiAccountFieldMapping().values()) {
	        fields.add('Account.' + accountField);
        }

        //Include primary contact fields. As contact fields are coming from subquery (child relationship)
        //We will create query for contact field and then will include into the opty query.
        List<String> contactFields = new List<String>();
        for(String contactField : OptyApiDto.getOptyApiContactFieldMapping().values()) {
	        contactFields.add('Contact.' + contactField);
        }
		fields.add('(select ' + join(contactFields, ', ') + ' from OpportunityContactRoles where IsPrimary=true)');
        
        String soql = createSoqlWithAuditFields(fields, 'Opportunity', 'prospect_id__c in :prospectIds or external_Id__c in :prospectIds');
		info('Query Optys soql  ' + soql);
        
       	List<Opportunity> optys = Database.query(soql);
        
        resp.stopWatch.markSubElapsedTime();
        
        return optys;
    }
    
    public Opportunity queryOpty(RestServiceDto.Request req, RestServiceDto.Response resp) {
        String prospectId = getProspectIdFromPath(req);
        List<Opportunity> optys = queryOptys(new String[]{prospectId}, req, resp);
        if (optys.isEmpty()) {
            //Even though we are querying the opty, error message will read as Lead because
            //from customer pont of view, both are same.
            throw createBusinessException(RestServiceDto.Error_NotFound, 'Lead with specified Prospect Id [' + prospectId + '] not found.');
        }

        resp.stopWatch.markSubElapsedTime();
        
        return optys.get(0);
    }
    
    public List<OpportunityContactRole> queryOptyContactRoles(Id optyId) {
		List<String> fields = new List<String>();
        
        for (String contactField : OptyApiDto.getOptyApiContactFieldMapping().values()) {
            fields.add('Contact.' + contactField);
        }
        fields.add('Contact.Contact_Number__c');
        fields.add('OpportunityId');
        fields.add('ContactId');
        fields.add('Role');
        fields.add('IsPrimary');
        fields.add('CreatedBy.UserName');
        fields.add('CreatedDate');
        fields.add('LastModifiedBy.UserName');
        fields.add('LastModifiedDate');
        
        String soql = createSoql(fields, 'OpportunityContactRole', new String[]{'OpportunityId = :optyId'});
       	return Database.query(soql);
    }
    
    public OpportunityContactRole queryOptyContactRoleByEmail(Id optyId, String email) {
		List<OpportunityContactRole> roles = queryOptyContactRoles(optyId);
        for (OpportunityContactRole role : roles) {
            if (role.contact.email == email) {
                return role;
            }
        }		
        
        return null;
    }

    public OpportunityContactRole queryPrimaryOptyContactRole(Id optyId) {
		List<OpportunityContactRole> roles = queryOptyContactRoles(optyId);
        for (OpportunityContactRole role : roles) {
            if (role.isPrimary) {
                return role;
            }
        }		
        
        return null;
    }

    public OpportunityContactRole queryOptyContactRoleByContactNum(Id optyId, String contactNum) {
		List<OpportunityContactRole> roles = queryOptyContactRoles(optyId);
        for (OpportunityContactRole role : roles) {
            if (role.contact.Contact_Number__c == contactNum || role.contact.id == contactNum) {
                return role;
            }
        }		
        
        return null;
    }

    public void addOptyToResponse(Opportunity opty, RestServiceDto.Request req, RestServiceDto.Response resp) {
	    addOptyToResponse(opty, null, req, resp);
    }
    
    public void addOptyToResponse(Opportunity opty, Map<String, String> outputFields, RestServiceDto.Request req, RestServiceDto.Response resp) {
		Map<String, String> optyFieldMapping = OptyApiDto.getOptyApiOptyFieldMapping();
        for (String restField : optyFieldMapping.keySet()) {
            if (outputFields == null || outputFields.containsKey(restField)) {
		    	resp.jsonWriter.write(restField, getValue(opty, optyFieldMapping.get(restField)));
            }
        }
        
        signLead(opty, resp);
        
	    resp.jsonWriter.write('prospectQualified', true);
		resp.jsonWriter.write('createdDate', opty.CreatedDate);
		resp.jsonWriter.write('createdBy', opty.CreatedBy.UserName);
		resp.jsonWriter.write('lastModifiedDate', opty.LastModifiedDate);
		resp.jsonWriter.write('lastModifiedBy', opty.LastModifiedBy.UserName);
		
 		Map<String, String> accountFieldMapping = OptyApiDto.getOptyApiAccountFieldMapping();
		Account account = opty.Account;
        for (String restField : accountFieldMapping.keySet()) {
            if (outputFields == null || outputFields.containsKey(restField)) {
		    	resp.jsonWriter.write(restField, getValue(account, accountFieldMapping.get(restField)));
            }
        }

        if (!opty.OpportunityContactRoles.isEmpty()) {
            Map<String, String> contactFieldMapping = OptyApiDto.getOptyApiContactFieldMapping();
            Contact contact = opty.OpportunityContactRoles.get(0).Contact;
            for (String restField : contactFieldMapping.keySet()) {
                if (outputFields == null || outputFields.containsKey(restField)) {
	                resp.jsonWriter.write(restField, getValue(contact, contactFieldMapping.get(restField)));
                }
            }
        }
    }
    
    public void addOptyContactRoleToResponse(OpportunityContactRole role, RestServiceDto.Request req, RestServiceDto.Response resp) {
        JsonWriter jsonWriter = resp.jsonWriter;
        addOptyContactResponse(jsonWriter, role.Contact);
        
        if (req.isDebug()) {
	        jsonWriter.write('roleId', role.id);
	        jsonWriter.write('opportunityId', role.OpportunityId);
        }
        
        jsonWriter.write('role', role.Role);
        jsonWriter.write('primary', role.IsPrimary);
    }
    
    public void addOptyContactResponse(JsonWriter writer, Contact contact) {
 		Map<String, String> optyApiContactFieldMapping = OptyApiDto.getOptyApiContactFieldMapping();
        
        for (String restField : optyApiContactFieldMapping.keySet()) {
	    	writer.writeIfNotNull(restField, contact.get(optyApiContactFieldMapping.get(restField)));
	    	writer.writeIfNotNull('contactNumber', contact.Contact_Number__c);
	    	writer.writeIfNotNull('contactId', contact.Id);
        }
    }
}