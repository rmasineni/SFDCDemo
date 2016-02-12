public with sharing class LeadApiGetLeadsHandler extends RestService {
	
    override public String getApiName() {
        return 'LeadApiGetLeads';
    }
    
    public String getSalesRepId(RestServiceDto.Request req) {
        String salesRepId = req.getStringParam('salesRepId');
        String salesRepEmail = req.getStringParam('salesRepEmail');
        if (String.isBlank(salesRepId) && String.isNotBlank(salesRepEmail)) {
            List<User> users = [select id from User where IsActive = true and Email = :salesRepEmail];
            if (!users.isEmpty()) 
                salesRepId = users.get(0).id;
        }
		
        if (String.isBlank(salesRepId)) {
            salesRepId = UserInfo.getUserId();
        }
        
        return salesRepId;
    }
    
    override public void handleRequest(RestServiceDto.Request req, RestServiceDto.Response resp) {
		String salesRepId = getSalesRepId(req);
        DateTime startTime = req.getRequiredDateTimeParam('startTime');
        DateTime endTime = req.getRequiredDateTimeParam('endTime');
        Integer page = req.getIntegerParam('page');
        Integer pageSize = req.getIntegerParam('pageSize');
        if (page == null || page < 1) {
            page = 1;
        }
        
        if (pageSize == null || pageSize < 1) {
            pageSize = Sf.settingsService.getInteger('LeadApiGetLeadsPageSize', 250);
        }

        Map<String, String> leadSummaryFields = getLeadSummaryFields();
        Map<String, String> optySummaryFields = getOptySummaryFields();
        
        List<Lead> leads = queryLeads(salesRepId, startTime, endTime, page, pageSize, leadSummaryFields, req, resp);
        info('Queried leads ' + leads);
        
        List<Opportunity> optys = queryOptys(salesRepId, startTime, endTime, page, pageSize, optySummaryFields, req, resp);
        info('Queried optys ' + optys);

        if (leads.isEmpty() && optys.isEmpty()) {
            //This will return the empty array [] back to user otherwise, it
            //will return empty object {}, which is wrong as clients expect
         	resp.jsonWriter = new JsonWriter(true);
        } else {
            Integer outputIndex = -1;
			LeadApiReadLeadHandler leadReadHandler = new LeadApiReadLeadHandler();
            for (Integer i = 0; i < leads.size(); i++) {
                outputIndex++;
                resp.jsonWriter.newWith(outputIndex);
                leadReadHandler.prepareResponse(leads.get(i), leadSummaryFields, req, resp);
            }

            OptyApiReadOptyHandler optyReadHandler = new OptyApiReadOptyHandler();
            for (Integer i = 0; i < optys.size(); i++) {
                outputIndex++;
                resp.jsonWriter.newWith(outputIndex);
                optyReadHandler.addOptyToResponse(optys.get(i), optySummaryFields, req, resp);
            }
        }
    }

    public List<Lead> queryLeads(String salesRepId, DateTime startTime, DateTime endTime, Integer page, Integer pageSize,
			Map<String, String> leadSummaryFields, RestServiceDto.Request req, RestServiceDto.Response resp) {
		List<String> fields = new List<String>();

		Map<String, String> leadFieldMapping = LeadApiDto.getLeadApiLeadFieldMapping();        
        for (String restField : leadFieldMapping.keySet()) {
            if (leadSummaryFields == null || leadSummaryFields.containsKey(restField)) {
                fields.add(leadFieldMapping.get(restField));
            }
        }
        
        Id loggedInUserId = UserInfo.getUserId();
		List<String> whereClauses = new String[]{
            'IsConverted = false',
            'LastModifiedDate >= :startTime',
            'LastModifiedDate <= :endTime',
            'Lead_Generated_by__c = :loggedInUserId'
        };

        String soql = createSoqlWithAuditFields(fields, 'Lead', whereClauses, 'lastmodifieddate', page, pageSize);
        
       	List<Lead> leads = Database.query(soql);
        
        resp.stopWatch.markSubElapsedTime();
        
        return leads;
    }
    
    public List<Opportunity> queryOptys(String salesRepId, DateTime startTime, DateTime endTime, Integer page, Integer pageSize,
			Map<String, String> optySummaryFields, RestServiceDto.Request req, RestServiceDto.Response resp) {
		List<String> fields = new List<String>();
		Map<String, String> optyFieldMapping = OptyApiDto.getOptyApiOptyFieldMapping();        
        for (String restField : optyFieldMapping.keySet()) {
            if (optySummaryFields == null || optySummaryFields.containsKey(restField)) {
                fields.add(optyFieldMapping.get(restField));
            }
        }

        //Include account fields.
        fields.add('Account.Id');
        Map<String, String> optyAccountFieldMapping = OptyApiDto.getOptyApiAccountFieldMapping();
        for(String restField : optyAccountFieldMapping.keyset()) {
            if (optySummaryFields == null || optySummaryFields.containsKey(restField)) {
                fields.add('Account.' + optyAccountFieldMapping.get(restField));
            }
        }

        //Include primary contact fields. As contact fields are coming from subquery (child relationship)
        //We will create query for contact field and then will include into the opty query.
        Map<String, String> optyContactFieldMapping = OptyApiDto.getOptyApiContactFieldMapping();
        List<String> contactFields = new List<String>();
        for(String restField : optyContactFieldMapping.keySet()) {
            if (optySummaryFields == null || optySummaryFields.containsKey(restField)) {
		        contactFields.add('Contact.' + optyContactFieldMapping.get(restField));
            }
        }

		if (!contactFields.isEmpty()) {
        	fields.add('(select ' + join(contactFields, ', ') + ' from OpportunityContactRoles where IsPrimary=true)');
		}

        Id loggedInUserId = UserInfo.getUserId();
		List<String> whereClauses = new String[]{
            'LastModifiedDate >= :startTime',
            'LastModifiedDate <= :endTime',
            '(Lead_Generated_by__c = :loggedInUserId or SalesRep__c = :loggedInUserId)'
        };

		String soql = createSoqlWithAuditFields(fields, 'Opportunity', whereClauses, 'lastmodifieddate', page, pageSize);
        
       	List<Opportunity> optys = Database.query(soql);
        
        resp.stopWatch.markSubElapsedTime();
        
        return optys;
    }

    public Map<String, String> getLeadSummaryFields() {
        return getStringMap(RestServiceDto.getSummaryFields('Lead Api'));
    }

    public Map<String, String> getOptySummaryFields() {
        return getStringMap(RestServiceDto.getSummaryFields('Opty Api'));
    }
}