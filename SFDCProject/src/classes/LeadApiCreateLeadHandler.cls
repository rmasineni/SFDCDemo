public class LeadApiCreateLeadHandler extends LeadApiBaseHandler {
    public Boolean isVersion1 {get;set;}
    
    public LeadApiCreateLeadHandler() {
        this(false);
    }
    
    public LeadApiCreateLeadHandler(Boolean isVersion1) {
        this.isVersion1 = isVersion1;
    }
    
    override public String getApiName() {
        return isVersion1?'LeadApiCreateLeadV1':'LeadApiCreateLead';
    }
    
    /** 
	 * Main method of the handler, which calls all other mehtods. This is the method invokved by the LeadServiceImpl.
	 * 
	 * Usually client's don't need to override this method but they can if they want complete control over processing of 
	 * createLeadsRequest.
	 */
    override public void handleRequest(RestServiceDto.Request req, RestServiceDto.Response resp) {
        
        Savepoint sp = Database.setSavepoint();
        
        try {
            parseRequest(req, resp);
            
            initRequest(req, resp);
            
            Lead lead = parseLead(req, resp);
            
            validateLead(lead, req, resp);
            
            saveLead(lead, req, resp);
            
            Id optyId = null;
            
            try {
                optyId = convertLeadIfApplicable(lead, req, resp);
            } catch (Exception e) {
                info('Exception while converting the lead. ' + getExceptionDetails(e));
            }
            
            prepareResponse(lead, optyId, req, resp);
            
        } catch (Exception e) {
            
            //If there is any error while converting the lead, we will rollback
            //the changes we saved and return the error. As we are rolling back changes
            //before request is saved in exception log, we should stil see the error.
            Database.rollback(sp);
            
            throw e;
        }
    }
    
    /**
     * Initializes the json reader with any defaults that need to be added before creating the lead.
     */ 
    public JsonReader initRequest(RestServiceDto.Request req, RestServiceDto.Response resp) {
        try {
            debug('Comming to initRequest with request ' + req);
            
            JsonReader jsonReader = req.jsonReader;
            
            //If leadOrganizationLocationId is null, then try to lookup the Id based on the leadOrganizationLocationName, if specified.
            String leadOrgLocationId = jsonReader.getString(LeadApiDto.RestField_leadOrgLocationId);
            String leadOrgLocationName = jsonReader.getString(LeadApiDto.RestField_leadOrgLocationName);
            
            debug('Lead org location id=' + leadOrgLocationId + ', lead org location name=' + leadOrgLocationName);
            
            if (isEmpty(leadOrgLocationId) && isNotEmpty(leadOrgLocationName)) {
                debug('Lead Org Location Id is null and Name is not null so going to look for accounts with name ' + leadOrgLocationName);
                
                List<Account> accounts = [select Id from Account where Name = :leadOrgLocationName order by LastModifiedDate desc];
                debug('Found following org location accounts ' + accounts + ' Going to take first account');
                
                if (!accounts.isEmpty()) {
                    jsonReader.setString(LeadApiDto.RestField_leadOrgLocationId, accounts.get(0).id);
                }
            }
            
            //By default leadGenBy fields defaults to salesRep
            if (jsonReader.getString('leadRep') == null) {
                jsonReader.setString('leadRep', jsonReader.getString('salesRep'));
            }
            
            //Once request level defaults are processed, then apply the api fields configs.
            //Note that the string 'LeadApiCreateLead' is critical as all configuration
            //is done against this. If this is changed, unless the configuration is also
            //changed, api defaults will not be processed.
            processDefaultsAndOverrides('LeadApiCreateLead', jsonReader);
            
            debug('Lead object after pre-processing ' + jsonReader);
            
            resp.stopwatch.markSubElapsedTime();
            
            return jsonReader;

        } catch (Exception e) {
            throw createBusinessException(RestServiceDto.Error_InternalServerError, 'Exception while processing the request. [' + e.getMessage() + ']', e);
        }
    }

    public Lead parseLead(RestServiceDto.Request req, RestServiceDto.Response resp) {
        
        Lead lead = new Lead();

        copyRestFieldsToSfdcFields(lead, LeadApiDto.getLeadApiLeadFieldMapping(), req);
        
        //Some of the fields cannot be just mapped but they need to be exclusively processed.
        parseConsultationTime(lead, req.jsonReader);
        
        //If company is null, specify it as first name and last name, only if it is a new lead. If we are updating
        //the lead, then lead company would have been specified so don't set it.
        if (isEmpty(lead.Company)) {
            lead.company = Lead.FirstName + ' ' + lead.LastName;
        }
        
        resp.stopwatch.markSubElapsedTime();
        return lead;
    }
    
    /**
     * Parses the Appointment time and parseConsultationTime the date/time into Consultation_Date_and_Time__c and Consultation_Time__c fields.
     *
     * Iknock sends the appointment time in 2014-09-03T22:08:23z format.
     */
    public void parseConsultationTime(Lead lead, JsonReader jsonReader) {
        String appointmentTime= jsonReader.getString(LeadApiDto.RestField_consultationDateTime);
        
        if (isEmpty(appointmentTime)) {
            return;
        }
        
        try {
            DateTime apptDateTime = parseAsUtcIsoDateTime(appointmentTime);
            
            lead.Consultation_Date_and_Time__c = apptDateTime.date();
            lead.Consultation_Time__c = apptDateTime.format('h a');
        } catch (Exception e){
            throw BusinessException.create(RestServiceDto.Error_InvalidRequest, 'Error while parsing the Appointment time [' + appointmentTime + ']. ' + e.getMessage(), e);
        }
    }
    
	/**
	 * Validate the leads to make sure they have the appropriate fields populated.
	 * 
	 * if there is any error, then populate the corresponding leads status=error, (and code/message as appropriate)
	 */
    public void validateLead(Lead lead, RestServiceDto.Request req, RestServiceDto.Response resp) {
		validateRequiredFields(lead, LeadApiDto.getLeadApiLeadRequiredFields(), req);

        resp.stopwatch.markSubElapsedTime();
    }

	/**
	 * Finally inserts or updates the leads as appropriate.
	 */
    public void saveLead(Lead lead, RestServiceDto.Request req, RestServiceDto.Response resp) {
        if (lead.id == null) {
            debug('Inserting lead ' + lead);
            insert lead;
        } else {
            debug('Updating lead ' + lead);
            update lead;
        }
        
        resp.stopwatch.markSubElapsedTime();            
    }

    public String convertLeadIfApplicable(Lead lead, RestServiceDto.Request req, RestServiceDto.Response resp) {
		String optyId;
        if (req.jsonReader.getBoolean('prospectQualified')) {
            optyId = ConvertLead.doConvert(lead.id);
        }
        
        resp.stopwatch.markSubElapsedTime();
        
		return optyId;        
    }
    
	/**
	 * Prepare the lead responses to be returned to client. You can populate the required fields
	 */ 
    public void prepareResponse(Lead lead, Id optyId, RestServiceDto.Request req, RestServiceDto.Response resp) {
        debug('Preparing the response for ' + lead + ' with lead id ' + lead.id);
		
		lead = queryLead(lead.id);
        
        debug('Lead after quering ' + lead);

        resp.recordId = lead.id;
        
        resp.jsonWriter.write('prospectId', lead.Prospect_Id__c);
        resp.jsonWriter.write('leadId', lead.id);
        resp.jsonWriter.writeIfNotEmpty('opportunityId', optyId);
        resp.jsonWriter.write('leadOrgLocationId', lead.Lead_Organization_Location_2__c);
	
        if (isVersion1) {
            resp.httpStatus = 200;
	        resp.jsonWriter.write('status', 'success');
        }
        
        signLead(lead, resp);
        
        resp.stopwatch.markSubElapsedTime();
    }
}