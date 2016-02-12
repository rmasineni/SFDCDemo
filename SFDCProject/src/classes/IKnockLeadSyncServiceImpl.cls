public class IKnockLeadSyncServiceImpl extends BaseClass implements IKnockLeadSyncService {
	
	private static final String ErrorUpdatingIKnock = 'Error Updating IKnock';
    
    private static final String IKnock_FirstName = Sf.settingsService.getString('IKnock_FirstName', 'First Name');
    private static final String IKnock_LastName = Sf.settingsService.getString('IKnock_LastName', 'Last Name');
    private static final String IKnock_Email = Sf.settingsService.getString('IKnock_Email', 'Email');
    private static final String IKnock_Mobile = Sf.settingsService.getString('IKnock_Mobile', 'Mobile');
    private static final String IKnock_Phone = Sf.settingsService.getString('IKnock_Phone', 'Phone');    

    private static final String IKnock_StreetNo = Sf.settingsService.getString('IKnock_StreetNo', 'Street No.');
    private static final String IKnock_StreetName = Sf.settingsService.getString('IKnock_StreetName', 'Street Name');
    private static final String IKnock_UnitNo = Sf.settingsService.getString('IKnock_UnitNo', 'Unit No.');
    private static final String IKnock_State = Sf.settingsService.getString('IKnock_State', 'State');
    private static final String IKnock_PostalCode = Sf.settingsService.getString('IKnock_PostalCode', 'Zip Code');

    private static final String IKnock_AgentEmail = Sf.settingsService.getString('IKnock_AgentEmail', 'Agent Email');
    private static final String IKnock_AppointmentTime = Sf.settingsService.getString('IKnock_AppointmentTime', 'Appointment Time');
    private static final String IKnock_BasicOrElectric = Sf.settingsService.getString('IKnock_BasicOrElectric', 'Basic or Electric?');
    private static final String IKnock_BestWayToFollowUp = Sf.settingsService.getString('IKnock_BestWayToFollowUp', 'Best Way to Follow Up?');
    private static final String IKnock_City = Sf.settingsService.getString('IKnock_City', 'City');
    private static final String IKnock_CompletedFormId = Sf.settingsService.getString('IKnock_CompletedFormId', 'completed_form_id');
    private static final String IKnock_AddressId = Sf.settingsService.getString('IKnock_AddressId', 'address_id');
    private static final String IKnock_Hoa = Sf.settingsService.getString('IKnock_Hoa', 'HOA?');

    private static final String IKnock_JanUsage = Sf.settingsService.getString('IKnock_JanUsage', 'Jan kWh');
    private static final String IKnock_FebUsage = Sf.settingsService.getString('IKnock_FebUsage', 'Feb kWh');
    private static final String IKnock_MarUsage = Sf.settingsService.getString('IKnock_MarUsage', 'Mar kWh');
    private static final String IKnock_AprUsage = Sf.settingsService.getString('IKnock_AprUsage', 'Apr Kwh');
    private static final String IKnock_MayUsage = Sf.settingsService.getString('IKnock_MayUsage', 'May Kwh');
    private static final String IKnock_JunUsage = Sf.settingsService.getString('IKnock_JunUsage', 'Jun Kwh');
    private static final String IKnock_JulUsage = Sf.settingsService.getString('IKnock_JulUsage', 'Jul Kwh');
    private static final String IKnock_AugUsage = Sf.settingsService.getString('IKnock_AugUsage', 'Aug Kwh');
    private static final String IKnock_SepUsage = Sf.settingsService.getString('IKnock_SepUsage', 'Sep Kwh');
    private static final String IKnock_OctUsage = Sf.settingsService.getString('IKnock_OctUsage', 'Oct Kwh');
    private static final String IKnock_NovUsage = Sf.settingsService.getString('IKnock_NovUsage', 'Nov kWh');
    private static final String IKnock_DecUsage = Sf.settingsService.getString('IKnock_DecUsage', 'Dec kWh');

    private static final String IKnock_MonthlyElecBill = Sf.settingsService.getString('IKnock_MonthlyElecBill', 'Average Monthly Electric Bill');
    private static final String IKnock_Notes = Sf.settingsService.getString('IKnock_Notes', 'Description');
    private static final String IKnock_OverTwoStories = Sf.settingsService.getString('IKnock_OverTwoStories', 'Over 2 Stories?');
    private static final String IKnock_HomeType = Sf.settingsService.getString('IKnock_HomeType', 'Home Type');
    private static final String IKnock_RoofMaterial = Sf.settingsService.getString('IKnock_RoofMaterial', 'Roof Material');
    private static final String IKnock_SquareFootage = Sf.settingsService.getString('IKnock_SquareFootage', 'Square footage');
    private static final String IKnock_Utility = Sf.settingsService.getString('IKnock_Utility', 'Utility');
            
    private Map<String, String> httpHeaders = null;

    private Map<String, String> leadStringFieldMappings = new Map<String, String> {
      IKnock_BasicOrElectric => 'Usage_Option__c',
      IKnock_BestWayToFollowUp => 'Best_way_to_reach__c',
      IKnock_City => 'City',
      IKnock_Email => 'Email',
      IKnock_FirstName => 'FirstName',
      IKnock_Hoa => 'Hoa__c',
      IKnock_HomeType => 'Home_Type__c',
      IKnock_LastName => 'LastName',
      IKnock_Mobile => 'MobilePhone',
      IKnock_Notes => 'Notes__c',
      IKnock_OverTwoStories => 'Over_2_stories__c',
      IKnock_Phone => 'Phone',
      IKnock_PostalCode => 'PostalCode',
      IKnock_RoofMaterial => 'Roofing_Type__c',
      IKnock_State => 'State',
      IKnock_Utility => 'Utility_Company__c',
      IKnock_AddressId => 'IKnock_Address_Id__c'
    };

    private Map<String, String> leadNumberFieldMappings = new Map<String, String> {
        IKnock_MonthlyElecBill => 'Average_Monthly_Electric_Bill__c',
        IKnock_AprUsage =>  'Apr_Usage__c',
        IKnock_AugUsage =>  'Aug_Usage__c',
        IKnock_DecUsage => 'Dec_Usage__c',
        IKnock_FebUsage => 'Feb_Usage__c',
        IKnock_JanUsage => 'Jan_Usage__c',
        IKnock_JulUsage =>  'Jul_Usage__c',
        IKnock_JunUsage =>  'Jun_Usage__c',
        IKnock_MarUsage => 'Mar_Usage__c',
        IKnock_MayUsage =>  'May_Usage__c',
        IKnock_NovUsage => 'Nov_Usage__c',
        IKnock_OctUsage =>  'Oct_Usage__c',
        IKnock_SepUsage =>  'Sep_Usage__c'
    };
    
    public void retrieveLeads() {
        
        Integer maxLeadsPerIteration = Sf.settingsService.getInteger('iKnockLeadExtractMaxLeadsPerIteration');
        System.debug('Starting to retrieve (maximum ' + maxLeadsPerIteration + ') leads from iKnock Service...');
        
        String response = sendIKnockRequest(getLeadExtractUrl());
        System.debug('Content is ' + response);
        
        if (response == null) {
            System.debug('No more new leads in iKnock service. Terminating the bactch processing.');
            return;
        }
        
        List<Object> rows = (List<Object>) Json.deserializeUntyped(response);
        if (rows.size() == 0) {
            System.debug('IKnockService retuned empty response ' + response);
            return;
        }
        
        //Retrieve the header row from response and create a map of index to label,
        //which we will use to parse the data records.
        Map<String, String> headerIndexToLabelMap = new Map<String, String>();
        List<Object> headerRow = (List<Object>) rows.get(0);
        for(Integer i = 0; i < headerRow.size(); i++ ) {
            headerIndexToLabelMap.put('' + i, (String) headerRow.get(i));
        }
        
        System.debug('Mapped label to index ' + headerIndexToLabelMap);
        
        Map<String, List<Lead>> salesRepEmailToLeads = new Map<String, List<Lead>>();
        Integer maxFormId = 0;
        List<Lead> leads = new List<Lead>();
        for(Integer i = 1; i < rows.size(); i++ ) {

            Lead lead = createLead(headerIndexToLabelMap, (List<Object>) rows.get(i), salesRepEmailToLeads);            
            leads.add(lead);
            
            maxFormId = Math.max(maxFormId, Integer.valueOf(lead.External_Id__c));
            
            if (leads.size() >= maxLeadsPerIteration) {
                System.debug('Processed ' + leads.size() + ' of ' + rows.size() + ' and reached the max configured leads size per iteration of ' + maxLeadsPerIteration 
                             + ' so skipping processing rest of the iKnock leads and they will be picked up in next batch. Setting the DeltaId as ' + maxFormId);
                break;
            }
        }
        
        populateSalesRepDetails(salesRepEmailToLeads);
        
        BaseClass.exceptionRollbackSavePoint = Database.setSavepoint();
        
        System.debug('Inserting leads (' + leads.size() + ' leads) [' + leads + ']');
        insert leads;
        
        System.debug('After inserting leads ' + leads);
        
        Sf.settingsService.setString('iKnockLeadExtractDeltaId', String.valueOf(maxFormId));
    }
    
    
    public Lead createLead(Map<String, String> headerIndexToLabelMap, List<Object> dataRow, Map<String, List<Lead>> salesRepEmailToLeads) {
        String unitNo;
        String streetName;
        String streetNo;
        String salesRepEmail;
        String appointmentTime;
        
        Lead lead = new Lead();
        Integer externalId = 0;
        for (Integer j = 0; j < dataRow.size(); j++) {
            String label = headerIndexToLabelMap.get('' + j);
            Object value = dataRow.get(j);
            System.debug(label + '=' + value);
            
            if (value == null || (value instanceof String && isEmpty((String) value))) {
                continue;
            }
            
            String stringValue = String.valueOf(value);
            String leadApi = leadStringFieldMappings.get(label);
            if (leadApi != null) {
                System.debug('Assigning string value ' + stringValue  + ' to ' + leadApi);
                lead.put(leadApi, stringValue);
            }

            leadApi = leadNumberFieldMappings.get(label);
            if (leadApi != null) {
                lead.put(leadApi, parseDoubleIgnoreErrors(stringValue));
            }
            
            if (label == IKnock_CompletedFormId) {
                externalId = (Integer) value;
                
            } else if (label == IKnock_StreetName) {
                streetName = stringValue;

            } else if (label == IKnock_UnitNo) {
                unitNo = stringValue;

            } else if (label == IKnock_StreetNo) {
                streetNo = stringValue;

            } else if (label == IKnock_AgentEmail) {
                salesRepEmail = stringValue.toLowerCase();

            } else if (label == IKnock_AppointmentTime) {
                appointmentTime = stringValue;
                
            } else if (label == IKnock_SquareFootage) {
                try {
                    lead.put('Square_footage__c', parseDoubleIgnoreErrors(stringValue));
                } catch (Exception e) {
                    System.debug('Tried to store Sq Footage as string but failed so trying to store string.');
                    lead.put('Square_footage__c', stringValue);
                }
            } 
        }
        
        lead.Street = join(new String[]{streetNo, streetName}, ' ');
        if (isNotEmpty(unitNo)) {
            lead.Street = lead.Street + ' APT ' + unitNo;
        }
        
        lead.Company = join(new String[]{lead.firstName, lead.LastName}, ' ');
        lead.External_Id__c = String.valueOf(externalId);
        lead.Country = 'USA';
        lead.Phone = formatPhoneNumber(lead.phone);
        lead.Mobilephone = formatPhoneNumber(lead.Mobilephone);        
        
        populateConsultationTime(lead, appointmentTime);        
        
        lead.Channel__c = Sf.settingsService.getString('iKnockLeadExtractLeadChannel');
        lead.Status = Sf.settingsService.getString('iKnockLeadExtractLeadStatus');
        lead.Field_Marketing_Branch__c = Sf.settingsService.getString('iKnockLeadExtractLeadBranch', null);
        lead.Custom_Lead_Source__c = Sf.settingsService.getString('iKnockLeadExtractLeadSource');
        lead.External_Source__c = Sf.settingsService.getString('iKnockLeadExtractLeadSourceSystem');            
                    
        if (salesRepEmailToLeads.get(salesRepEmail) == null) {
            salesRepEmailToLeads.put(salesRepEmail, new List<Lead>());
        }
        salesRepEmailToLeads.get(salesRepEmail).add(lead);

        return lead;
    }
    
    /**
     * Parses the Appointment time and populates the date/time into Consultation_Date_and_Time__c and Consultation_Time__c fields.
     *
     * Iknock sends the appointment time in 2014-09-03 22:08:23 format.
     */
    public void populateConsultationTime(Lead lead, String appointmentTime) {
        try {
            String[] splits = appointmentTime.split(' ');
            lead.Consultation_Date_and_Time__c = Date.valueOf(splits[0]);
            
            //For time component, requirement is to just take the hour component and store that value. As time is in this format, 22:08:23, we will split by :
            //and take the first value and store it.
            lead.Consultation_Time__c = DateTime.valueOf(appointmentTime).format('h a');
        } catch (Exception e){
            System.debug('Error while parsing the Appointment time [' + appointmentTime + ']. ' + e.getMessage() + '. Stack Trace[' + getStackTrace(e) +']');
        }    
    }
    
    /**
     * Looks up the Sales rep user details (and corresponding account) for all specified emails
     * and populates the lead details if user is found.
     */    
    public void populateSalesRepDetails(Map<String, List<Lead>> salesRepEmailToLeads) {
        List<User> users = [select Id, Email, Contact.AccountId from User where email in :salesRepEmailToLeads.keySet()];
        
        for(User user : users) {
            List<Lead> leads = salesRepEmailToLeads.get(user.email);
            if (leads != null) {
                for (Lead lead : leads) {
                    lead.SalesRep__c = user.id;
                    lead.Sales_Partner__c = user.contact.AccountId;
                }
            }
        }
    }

    public String getLeadExtractUrl() {
        String deltaId = Sf.settingsService.getString('iKnockLeadExtractDeltaId');
        String clientId = Sf.settingsService.getString('iKnockLeadExtractClientId');
        String formId = Sf.settingsService.getString('iKnockLeadExtractFormId');
        String url = Sf.settingsService.getString('iKnockLeadExtractUrl');
        Map<String, String> urlParms = new Map<String, String>{
            'DeltaId' => deltaId,
            'ClientId' => clientId,
            'FormId' => formId
        };
        
        url = replaceMergeTokens(url, urlParms ); 
        
        System.debug('Lead Extract Url is ' + url);
        return url;   
    }
    
    public void syncLeadsToIKnock(List<Lead> leads) {
        initUrlParameterInIKnock();
        
        String partnerLeadUrl = Sf.settingsService.getString('iKnockUpdatePartnerLeadUrl');
        String attName = Sf.settingsService.getString('iKnockUpdateUrlAttName');
        List<Lead> updatedLeads = new List<Lead>();
		List<Exception__c> excps = new List<Exception__c>();

        //If the lead has address id, then update the partner url.
        for(Lead lead : leads) {
            if (isNotEmpty(lead.IKnock_Address_Id__c)) {
                String attValue = replaceMergeToken(partnerLeadUrl, 'LeadId', lead.id);
                Boolean isRepeatError = equalsIc(lead.IKnock_Sync_Status__c, ErrorUpdatingIKnock);
                try {
                    updateIKnock(lead.IKnock_Address_Id__c, attName, attValue);
                    lead.IKnock_Sync_Status__c = 'IKnock Updated';
                } catch (Exception e) {
                    System.debug('Error updating iknock for lead ' + lead + ' ' + getStackTrace(e));
                    lead.IKnock_Sync_Status__c = ErrorUpdatingIKnock;
                    lead.IKnock_Sync_Message__c = getStackTrace(e);

                    if (!isRepeatError) {
                    	excps.add(ExceptionLogger.createException('IKnockLeadUpdateBatch', 'Exception while updating iKnock with url for lead ' + lead, e));
                    }
                }

                updatedLeads.add(lead);
            }
        }
        
        BaseClass.exceptionRollbackSavePoint = Database.setSavepoint();
        update updatedLeads;
        
        if (!excps.isEmpty()) {
            try {
	            insert excps;
            } catch (Exception e) {
                debug(e);
            }
        }
    }

    public void syncOptiesToIKnock(List<Lead> leads) {
        initUrlParameterInIKnock();
        
        String partnerOptyUrl = Sf.settingsService.getString('iKnockUpdatePartnerOptyUrl');
        String attName = Sf.settingsService.getString('iKnockUpdateUrlAttName');
        List<Opportunity> opties = new List<Opportunity>();
		List<Exception__c> excps = new List<Exception__c>();
        
        //If the lead has address id, then update the partner url.
        for(Lead lead : leads) {
            if (isNotEmpty(lead.IKnock_Address_Id__c)  && lead.ConvertedOpportunity != null) {
                String attValue = replaceMergeToken(partnerOptyUrl, 'OptyId', lead.ConvertedOpportunity.id);
                Boolean isRepeatError = equalsIc(lead.IKnock_Sync_Status__c, ErrorUpdatingIKnock);
                
                try {
                    updateIKnock(lead.IKnock_Address_Id__c, attName, attValue);
                    lead.ConvertedOpportunity.IKnock_Sync_Status__c = 'IKnock Updated';
                } catch (Exception e) {
                    System.debug('Error updating iknock for opty ' + lead + ' ' + getStackTrace(e));
                    lead.ConvertedOpportunity.IKnock_Sync_Status__c = ErrorUpdatingIKnock;
                    lead.ConvertedOpportunity.IKnock_Sync_Message__c = getStackTrace(e);
                    
                    if (!isRepeatError) {
                    	excps.add(ExceptionLogger.createException('IKnockOptyUpdateBatch', 'Exception while updating iKnock with url for opportunity ' + lead, e));
                    }
                }
                
                opties.add(lead.ConvertedOpportunity);
            }
        }
        
        BaseClass.exceptionRollbackSavePoint = Database.setSavepoint();
        update opties;
        
        if (!excps.isEmpty()) {
            try {
	            insert excps;
            } catch (Exception e) {
                debug(e);
            }
        }
    }

    public void updateIKnock(String addressId, String attName, String attValue) {
        String url = getIKnockUpdateUrl(addressId, attName, attValue);
        try {
            String response = httpPost(url, 'value=' + attValue, initAndGetIKnockHttpHeaders(), getIKnockHttpTimeoutMillis());
            System.debug('IKnock Update Response is ' + response);
         } catch (UnsuccessfulHttpResponseException e) {
             if (e.getResponse().getStatusCode() == 201) {
                 //iKnock returns 201 if key is successfully updated.
             } else {
                 throw e;
             }
         }
    }

    /**
     * IKnock allows to update the particular attribute of an entity. If it is custom attribute,
     * such attribute needs to be created first before providing any value. 
     * 
     * Attribute can be initialized, by calling API
     * /api/vYYYYMMDD/accounts/{account_id}/clients/{client_id}/attached-data-keys/?key_name=my%20new%20key
     * 
     * If Key is created, it will return 201 and if key is already there then it will return 400.
     * 
     * In our case, key name is retrieved from the Custom Settings iKnockUpdateUrlAttName.
     */ 
    public void initUrlParameterInIKnock() {
        
        String accountId = Sf.settingsService.getString('iKnockUpdateAccountId');
        String clientId = Sf.settingsService.getString('iKnockLeadExtractClientId');
        String url = Sf.settingsService.getString('iKnockUpdateParameterInitUrl');
        String attName = Sf.settingsService.getString('iKnockUpdateUrlAttName');
        
        Map<String, String> urlParms = new Map<String, String>{
            'AccountId' => accountId,
            'ClientId' => clientId
        };
        
        url = replaceMergeTokens(url, urlParms); 
        
        System.debug('IKnock parameter init Url is ' + url);

        try {
            String response = httpPost(url, 'key_name=' + urlEncode(attName), initAndGetIKnockHttpHeaders(), getIKnockHttpTimeoutMillis());
            System.debug('IKnock Init parameter Response is ' + response);
         } catch (UnsuccessfulHttpResponseException e) {
             if (e.getStatusCode() == 201) {
                 //201 key is successfully created
             } else if (e.getStatusCode() == 400) {
                 //400 means key already exists and hence we can ignore the exception
             } else {
                 throw e;
             }
         }
    }
    
    public String getIKnockUpdateUrl(String addressId, String attName, String attValue) {
        String accountId = Sf.settingsService.getString('iKnockUpdateAccountId');
        String clientId = Sf.settingsService.getString('iKnockLeadExtractClientId');
        String url = Sf.settingsService.getString('iKnockUpdateUrl');
        Map<String, String> urlParms = new Map<String, String>{
            'AccountId' => accountId,
            'ClientId' => clientId,
            'AddressId' => urlEncode(addressId),
            'AttName' => urlEncode(attName),
            'AttValue' => urlEncode(attValue)
        };
        
        url = replaceMergeTokens(url, urlParms); 
        
        System.debug('IKnock update Url is ' + url);
        return url;   
    }
    
    public Double parseDoubleIgnoreErrors(String value) {
        try {
            return Double.valueOf(value);
        } catch (Exception e) {
            System.debug('Exception while parsing the double string value "' + value + '". Returning 0.0');
        }
        
        return 0.0;
    }

    public Map<String, String> initAndGetIKnockHttpHeaders() {
        if (httpHeaders == null) {
            Blob headerValue = Blob.valueOf(Sf.settingsService.getString('iKnockLeadExtractUserId') + ':' + Sf.settingsService.getString('iKnockLeadExtractPassword'));
            String authorizationHeader = 'BASIC ' + EncodingUtil.base64Encode(headerValue);
            httpHeaders = new Map<String, String>{'Authorization' => authorizationHeader};
        }
        
        return httpHeaders;
    }
    
    public String sendIKnockRequest(String url) {
        
        try {
            return httpGet(url, initAndGetIKnockHttpHeaders(), null, getIKnockHttpTimeoutMillis());
        } catch (UnsuccessfulHttpResponseException e) {
            
            //If there are no changes, iknock returns 204
            if (e.getResponse().getStatusCode() == 204) {
                return null;
            }
            
            throw e;
        }
    }
    
    public String formatPhoneNumber(String value) {
        if (value == null) {
            return value;
        }
    
        //Remove all special chars spaces, -, ( and )
        String newValue = value.replaceAll(' ', '').replaceAll('-', '').replaceAll('\\(','').replaceAll('\\)', ''); 
        
        //If the phone length is exactly 10 digits, then format it as (123) 456-7890
        if (newValue.length() == 10) {
            newValue = '(' + newValue.substring(0, 3) + ') ' + newValue.substring(3, 6) + '-' + newValue.substring(6, 10);
        } else {
        
            //If length is not exactly 10, then keep original value
            newValue = value;
        }
        
        return newValue;
    }
    
    public Integer getIKnockHttpTimeoutMillis() {
        return Sf.settingsService.getInteger('iKnockHttpTimeoutSecs', 10) * 1000;
    }
}