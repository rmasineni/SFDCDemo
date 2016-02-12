public class LeadCreateLeadsHandlerImpl extends RestService implements LeadCreateLeadsHandler  {
	private static final String RestField_leadOrgLocationId = 'leadOrgLocationId';	
	private static final String RestField_leadOrgLocationName = 'leadOrgLocationName';	

    public override String getApiName() {
        return 'LeadApiCreateLeadV1';
    }
    
    public override void handleRequest(RestServiceDto.Request req, RestServiceDto.Response resp) {
        //ignore as this is is applicable for v2 only
    }
    
    public virtual List<LeadServiceDto.CreateLeadResponse> handleRequestV1(RestRequest req, RestResponse resp) {
		String body = null;
        List<LeadServiceDto.CreateLeadResponse> responses = new List<LeadServiceDto.CreateLeadResponse>();
        
        Savepoint sp = Database.setSavepoint();
        Exception expn = null;
        try {
            body = req.requestBody.toString();
            debug('Received a request with json ' + body);
    
            responses = parseRequest(body);
            
            validateLeads(responses);
    
            insertOrUpdateLeads(responses);
            
            prepareResponses(responses);
            
        } catch (Exception e) {
            expn = e;
            Database.rollback(sp);
            
            responses = new List<LeadServiceDto.CreateLeadResponse>();
            LeadServiceDto.CreateLeadResponse response = new LeadServiceDto.CreateLeadResponse();
            
            if (e instanceof BusinessException) {
            	response.setError('VALIDATION_ERROR', e.getMessage());
            } else {
                response.setError('GENERIC_ERROR', e.getMessage());
            }
            responses.add(response);
        }

        //Save the request as is for tracking in exception object. Even though exeption object is not a right name as there is no exception but
        //we are using that as kind of api log.
		LeadServiceDto.CreateLeadResponse response = responses.get(0);
        
        if (response.errorCode != null) {
        	Sf.appLogger.logError('Api', 'LeadApiCreateLeadV1', 'Lead processing failed with message [' + response.message + ']', 'Request:\n' + body + '\n\n\nResponse:\n' + Json.serializePretty(response), expn);
        } else {
        	Sf.appLogger.logDebug('Api', 'LeadApiCreateLeadV1', 'Lead created successfully as ' + response.leadId, 'Request:\n' + body + '\n\n\nResponse:\n' + Json.serializePretty(response), response.leadId);
        }
        
        return responses;
    }
    
    public virtual List<LeadServiceDto.CreateLeadResponse> parseRequest(String jsonString) {
        List<LeadServiceDto.CreateLeadResponse> leads = new List<LeadServiceDto.CreateLeadResponse>();
		
        try {
            JsonReader reader = new JsonReader(jsonString);

            //By default leadGenBy fields defaults to salesRep
            if (reader.getString('leadRep') == null) {
                reader.setString('leadRep', reader.getString('salesRep'));
            }
            
           	//Process the defaults and overrides for this api.
            processDefaultsAndOverrides('LeadApiCreateLead', reader);

            if (reader.isArray()) {
                List<Object> leadObjs = (List<Object>) reader.getObject();
                for (Object leadObj : leadObjs) {
                    leads.add(parseLead(beforeParseLead((Map<String, Object>) leadObj)));
                }
            } else {
                Map<String, Object> leadObj = beforeParseLead((Map<String, Object>) reader.getObject());
                leads.add(parseLead(leadObj));
            }
        } catch (Exception e) {
            LeadServiceDto.CreateLeadResponse resp = new LeadServiceDto.CreateLeadResponse();
            resp.setError('INVALID_REQUEST', 'Exception while parsing the request. [' + e.getMessage() + ']');
            leads.add(resp);
        }
        return leads;
    }
	
    /**
     * This method is used to prepare the lead rest object, for parsing. This method could be used
     * to pre-fill the rest object values before it is passed to parseLead.
     */
    public Map<String, Object> beforeParseLead(Map<String, Object> leadObj) {
        debug('Comming to beforeLead with lead object ' + leadObj);
        
        //If leadOrganizationLocationId is null, then try to lookup the Id based on the leadOrganizationLocationName, if specified.
        String leadOrgLocationId = (String) leadObj.get(RestField_leadOrgLocationId);
        String leadOrgLocationName = (String) leadObj.get(RestField_leadOrgLocationName);
        
        debug('Lead org location id=' + leadOrgLocationId + ', lead org location name=' + leadOrgLocationName);
        if (isEmpty(leadOrgLocationId) && isNotEmpty(leadOrgLocationName)) {
            debug('Lead Org Location Id is null and Name is not null so going to look for accounts with name ' + leadOrgLocationName);
            
            List<Account> accounts = [select Id from Account where Name = :leadOrgLocationName order by LastModifiedDate desc];
            debug('Found following accounts ' + accounts + ' Going to take first account');
            if (!accounts.isEmpty()) {
                leadObj.put(RestField_leadOrgLocationId, accounts.get(0).id);
            }
        }
        
        debug('Lead object after pre-processing ' + leadObj);
        return leadObj;
    }
    
   	public virtual LeadServiceDto.CreateLeadResponse parseLead(Map<String, Object> leadObj) {
        
        LeadServiceDto.CreateLeadResponse resp = new LeadServiceDto.CreateLeadResponse();
        resp.restReq = leadObj;
        
        try {
            Lead lead = null;
            String prospectId = (String) leadObj.get('prospectId');
            if (isNotEmpty(prospectId)) {
                List<Lead> leads = queryLeadsByProspectIds(new String[]{prospectId});
                if (leads.isEmpty()) {
                    resp.setError('LEAD_NOT_FOUND', 'Lead with specified Prospect Id [' + prospectId + '] not found');
                    return resp;
                }
                lead = leads.get(0);
                if (lead.IsConverted) {
                    resp.setError('LEAD_CONVERTED', 'Lead with specified Prospect Id [' + prospectId + '] already converted to an opportunity and hence cannot be updated');
                    return resp;
                }
            } else {
                lead = new Lead();
            }
            
            Map<String, String> restApiToLeadApiMap = LeadApiDto.getLeadApiLeadFieldMapping();
            
            for (String restApiField : restApiToLeadApiMap.keySet()) {
                copyLeadField(leadObj, restApiField, lead, restApiToLeadApiMap.get(restApiField));
            }

            //Some of the fields cannot be just mapped but they need to be exclusively processed.
            parseComplexFields(leadObj, lead);
            
            resp.lead = lead;
        } catch (Exception e) {
            resp.status = 'error';
            resp.message = String.valueOf(e);
            Sf.appLogger.logError('Api', 'LeadApiCreateLeadV1', 'Exception while parsing the request ' + leadObj, null, e);
        }
        
        return resp;
    }
    
   	public virtual void parseComplexFields(Map<String, Object> leadObj, Lead lead) {
        populateConsultationTime(lead, (String) leadObj.get('consultationDateTime'));
        
        //If company is null, specify it as first name and last name, only if it is a new lead. If we are updating
        //the lead, then lead company would have been specified so don't set it.
        if (isEmpty(lead.Company) && lead.id == null) {
            lead.company = Lead.FirstName + ' ' + lead.LastName;
        }
    }
    
    public virtual void copyLeadField(Map<String, Object> leadObj, String restApiField, Lead lead, String leadApiField) {
        Object value = leadObj.get(restApiField);
        if (value == null || isEmpty(String.valueOf(value))) {
            return;
        }
        
        try {
            String type = getFieldType('Lead', leadApiField);
            
            if (equalsIc(type, 'double') || equalsIc(type, 'currency')) {
                lead.put(leadApiField, Double.valueOf(String.valueOf(value)));
                
            } else if (equalsIc(type, 'integer')) {
                lead.put(leadApiField, Integer.valueOf(String.valueOf(value)));
            
            } else if (equalsIc(type, 'phone')) {
                lead.put(leadApiField, formatPhoneNumber(String.valueOf(value)));
    
            } else if (equalsIc(type, 'boolean')) {
                lead.put(leadApiField, Boolean.valueOf(String.valueOf(value)));

            } else if (isFieldLookUpOfType('Lead', leadApiField, 'User')) {
                lead.put(leadApiField, getUserId(String.valueOf(value)));
                
            } else {
                lead.put(leadApiField, String.valueOf(value));
            }
        } catch (Exception e) {
            throw new SystemException('Exception while copying the rest field ' 
				+ restApiField+ ' with value ' + value + ' to lead field ' + leadApiField + ' [' + e.getMessage() + ']', e);
        }
    }
    
    /**
     * If a rest field is mapped to a Lead field of type User, then we will try to look up the user 
     * assuming the value as email or id.
     */
    public virtual Id getUserId(String restApiFieldValue) {
    	List<User> users = [select id from User where id = :restApiFieldValue or email = :restApiFieldValue.toLowerCase()];
        if (users.isEmpty()) {
            return null;
        }
		
        return users.get(0).id;
    }

    public virtual void validateLeads(List<LeadServiceDto.CreateLeadResponse> leads) {
        List<String> requiredFields = LeadApiDto.getLeadApiLeadRequiredFields();
        
        //For each lead, validate to make sure required fields are specified.
        for (LeadServiceDto.CreateLeadResponse lead : leads) {
            
            //We need to validate only if it is a new lead, because if we are updating then it is assumed
            //that all required fields are populated while saving.
            if (lead.lead == null || lead.lead.id != null) {
                continue;
            }
            
            for (String requiredField : requiredFields) {
                
                //Fields could be multiple fields separated by |. If so, then only one 
                //of the values is required.
                List<String> anyOfRequiredFields = requiredField.split('\\|');
                Boolean atLeastOneFieldPresent = false;
                for (String anyOfRequiredField : anyOfRequiredFields) {
                    Object value = lead.restReq.get(anyOfRequiredField);
                    if (value != null && isNotEmpty(String.valueOf(value))) {
                        atLeastOneFieldPresent = true;
                    }
                }
                
                if (!atLeastOneFieldPresent) {
                    lead.Status = 'error';
                    lead.errorCode = RestServiceDto.Error_RequiredFieldsMissing;
                    if (anyOfRequiredFields.size() == 1) {
                    	lead.message = 'Value is required for field [' + anyOfRequiredFields[0] + ']';
                    } else {
                    	lead.message = 'Value is required for any one of fields [' + join(anyOfRequiredFields, ', ') + ']';
                    }
                }
            }
            
        }
    }
    
    public virtual void insertOrUpdateLeads(List<LeadServiceDto.CreateLeadResponse> leads) {
        List<Lead> leadObjs = extractAllSuccessLeads(leads);
        List<Lead> inserts = new List<Lead>();
        List<Lead> updates = new List<Lead>();
        
        for (Lead lead : leadObjs) {
            if (lead.id == null) {
                inserts.add(lead);
            } else {
                updates.add(lead);
            }
        }

        try {
            if (!inserts.isEmpty()) {
                debug('Inserting leads ' + inserts);
                insert inserts;
            }
            if (!updates.isEmpty()) {
                debug('Updating leads ' + updates);
                update updates;
            }
            
            //Convert lead if applicable.
            for (LeadServiceDto.CreateLeadResponse leadResp : leads) {
                if (leadResp.restReq.get('prospectQualified') != null && Boolean.valueOf(leadResp.restReq.get('prospectQualified'))) {
                    try {
                        ConvertLead.doConvert(leadResp.lead.id);
                    } catch (System.DmlException e) {
                        throw transformException(e);
                    }
                }
            }
            
        } catch (System.DmlException e) {
            if (e.getMessage().indexOf('FIELD_CUSTOM_VALIDATION_EXCEPTION') >= 0) {
				String message = e.getMessage().substringAfter('FIELD_CUSTOM_VALIDATION_EXCEPTION');
                if (message.startsWith(','))  {
                    message = message.substring(1);
                }
                throw new BusinessException(message.trim());
            } else {
                throw e;
            }
        }
    }

    public virtual void prepareResponses(List<LeadServiceDto.CreateLeadResponse> leads) {
        
        //When leads are inserted, it would generate a id called prospect id. This needs to be explicitly queried
        //for it to work.
        Map<Id, Sobject> leadIdToObjMap = getIdMap(queryLeads(getUniqueIdList(extractAllSuccessLeads(leads), 'Id')), 'Id');
        
        //Copy the lead id, prospect id from created leads.
        for (LeadServiceDto.CreateLeadResponse lead : leads) {
            try {
                debug('Preparing the response for ' + lead);
                
                if (lead.lead != null && lead.status != 'error') {
                    Lead leadObj = (Lead) leadIdToObjMap.get(lead.lead.id);
                    
                    lead.leadId = leadObj.id;
                    debug('Lead prospect id is ' + leadObj.prospect_id__c);
                    lead.prospectId = leadObj.Prospect_Id__c;
                    lead.leadOrgLocationId = leadObj.Lead_Organization_Location_2__c;
                    lead.status = 'success';
                    
                    signLeadResponse(lead);
                }
            } catch (Exception e) {
                lead.status = 'error';
                lead.message = String.valueOf(e);
                Sf.appLogger.logError('Api', 'LeadApiCreateLeadV1', 'Exception while preparing the create lead response ' + lead, null, e);
            }
        }
    }
    
    /**
     * This method assigns a expiry time for the lead and signs the response token (based on prospectId, expiryTime and current user).
     */  
    public void signLeadResponse(LeadServiceDto.CreateLeadResponse lead) {
        //Take current time, add configured number of seconds, convert to milliseconds since epoch and convert to seconds as expected.
		lead.expires = getCurrentDateTime().addSeconds(Sf.settingsService.getInteger('LeadApiSignatureExpirySecs', 2592000)).getTime()/1000;

        //Signing string is made of prospect id, expiry time and current user's email.
        //The prefix L before prospect id is required to indicate the id is corresponding to lead.
        String signingString = 'prospectId=L' + lead.prospectId + '&expires=' + lead.expires + '&userId=' + urlEncode(UserInfo.getUserEmail().toLowerCase());
        
        lead.signature = EncodingUtil.base64Encode(Crypto.generateMac('HmacSHA1', Blob.valueOf(signingString), Blob.valueOf(Sf.settingsService.getString('LeadApiSigningPrivateKey'))));
        
        debug('Sign the lead ' + lead + ', using signing string ' + signingString);
        
    }

    public List<Lead> extractAllSuccessLeads(List<LeadServiceDto.CreateLeadResponse> leads) {
        List<Lead> leadObjs = new List<Lead>();
        
        for (LeadServiceDto.CreateLeadResponse lead : leads) {
            if (lead.lead != null && lead.status != 'error') {
                leadObjs.add(lead.lead);
            }
        }
        
        return leadObjs;
    }
    
    public List<Lead> queryLeads(List<Id> leadIds) {
        return [
            select
            	Id,
				Prospect_Id__c,
            	Lead_Organization_Location_2__c
			from Lead
			where id in :leadIds            
        ];
    }
    
    /**
     * Query the leads by specified prospect ids. Returned leads are sorted by LastModifiedDate in desc order (so newest first)
     */ 
    public List<Lead> queryLeadsByProspectIds(List<String> prospectIds) {
        return [
            select
            	Id,
				Prospect_Id__c,
            	Lead_Organization_Location_2__c,
                IsConverted
			from Lead
			where Prospect_Id__c in :prospectIds
            order by LastModifiedDate desc
        ];
    }

    /**
     * Parses the Appointment time and populates the date/time into Consultation_Date_and_Time__c and Consultation_Time__c fields.
     *
     * Iknock sends the appointment time in 2014-09-03T22:08:23z format.
     */
    public virtual void populateConsultationTime(Lead lead, String appointmentTime) {
        if (isEmpty(appointmentTime)) {
            return;
        }
        
        try {
            DateTime apptDateTime = parseAsUtcIsoDateTime(appointmentTime);
            
            lead.Consultation_Date_and_Time__c = apptDateTime.dateGmt();
            lead.Consultation_Time__c = apptDateTime.format('h a');
        } catch (Exception e){
            System.debug('Error while parsing the Appointment time [' + appointmentTime + ']. ' + e.getMessage() + '. Stack Trace[' + getStackTrace(e) +']');
        }    
    }
}