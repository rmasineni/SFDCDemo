public class LeadApiGetNearbyCustomersHandler extends RestService {

    public override String getApiName() {
        return 'LeadApiGetNearbyCustomers';
    }
    
    public override void handleRequest(RestServiceDto.Request req, RestServiceDto.Response resp) {
        String prospectId = getRecordIdFromPath(req, 'leads');
    	Decimal referenceLat;
    	Decimal referenceLng;
        
        if (isOpportunity(prospectId)) {
            Opportunity opty = queryRefOpty(prospectId);
            referenceLat = opty.Account.Latitude__c;
            referenceLng = opty.Account.Longitude__c;
        } else {
            Lead lead = queryRefLead(prospectId);
            referenceLat = lead.Latitude__c;
            referenceLng = lead.Longitude__c;
        }
        
        if (isNullOrZero(referenceLat) || isNullOrZero(referenceLng)) {
            throw createBusinessException('400', 'INVALID_REF_LAT_LNG', 'Latidue/Longitude co-ordinates are not avaiable for specified lead [' + prospectId + ']');
        }
        
        resp.jsonWriter.write('reference.address.latitude', referenceLat);
        resp.jsonWriter.write('reference.address.longitude', referenceLng);
        
   	 	List<NearbyCustomersViewerServiceDto.ContractWithDistance> contracts = 
			Sf.nearbyCustomersViewerService.findContractsWithinDistance(referenceLat, referenceLng);
        
        prepareResponse(contracts, req, resp);
    }
    
    public Opportunity queryRefOpty(String prospectId) {
		List<Opportunity> optys = [
            select
            	Id, Account.Latitude__c, Account.Longitude__c
            from Opportunity
            where Prospect_Id__c = :prospectId
        ];
        
        if (optys.isEmpty()) {
            throw createBusinessException(RestServiceDto.Error_NotFound, 'Lead with specified Prospect Id [' + prospectId + '] not found.');
        }
        
        return optys.get(0);
    }

    public Lead queryRefLead(String prospectId) {
		List<Lead> leads = [
            select
            	Id, Latitude__c, Longitude__c
            from Lead
            where Prospect_Id__c = :prospectId
        ];
        
        if (leads.isEmpty()) {
            throw createBusinessException(RestServiceDto.Error_NotFound, 'Lead with specified Prospect Id [' + prospectId + '] not found.');
        }
        
        return leads.get(0);
    }
    
    public void prepareResponse(List<NearbyCustomersViewerServiceDto.ContractWithDistance> contracts, RestServiceDto.Request req, RestServiceDto.Response resp) {
        if (contracts.isEmpty()) {
            resp.jsonWriter.write('contracts', new List<String>());
        } else {
            for (Integer i = 0; i < contracts.size(); i++) {
                NearbyCustomersViewerServiceDto.ContractWithDistance contract = contracts.get(i);
                resp.jsonWriter.newWith('contracts[' + i + ']');
                resp.jsonWriter.write('distanceInMiles', contract.distance);
                resp.jsonWriter.write('contractId', contract.contract.id);
                resp.jsonWriter.write('contractNumber', contract.contract.name);
                resp.jsonWriter.write('status', contract.contract.Status__c);
                resp.jsonWriter.write('customer.name', contract.contract.Customer_Name__c);
                resp.jsonWriter.write('customer.phone', contract.contract.Customer_Phone__c);
                resp.jsonWriter.write('salesOrgName', contract.contract.Sales_Organization_Id__r.Name);
                resp.jsonWriter.write('salesRepEmail', contract.contract.Sales_Rep_Email__c);
                resp.jsonWriter.write('leadSource', contract.contract.Opportunity__r.Lead_Source_2__c);
                resp.jsonWriter.write('address.street', contract.contract.Account.Billingstreet);
                resp.jsonWriter.write('address.city', contract.contract.Account.BillingCity);
                resp.jsonWriter.write('address.state', contract.contract.Account.BillingState);
                resp.jsonWriter.write('address.postalCode', contract.contract.Account.BillingPostalCode);
                resp.jsonWriter.write('address.latitude', contract.contract.Account.Latitude__c);
                resp.jsonWriter.write('address.longitude', contract.contract.Account.Longitude__c);
                
                if (!contract.contract.Surveys__r.isEmpty()) {
	                resp.jsonWriter.write('csatSurveyResponse', contract.contract.Surveys__r.get(0).CSAT_Survey_Response__c);
	                resp.jsonWriter.write('csatSurveyDateTime', contract.contract.Surveys__r.get(0).LastModifiedDate);
                }                
            }
        }
    }
}