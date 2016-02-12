public class NearbyCustomersViewerServiceImpl extends BaseClass {

    /**
     * Queries the given lead with basic lead and address related details.
     */
    public Lead queryLeadWithAddressDetails(String leadId) {
        return [
            select
            	Id, Name, Lead_Status__c, FirstName, LastName, Company, Email, Street, City, State, PostalCode, 
            	Country, Latitude__c, Longitude__c, Address_Location__Latitude__s, Address_Location__Longitude__s, Address_Standardization_Status__c
            from Lead
            where Id = :leadId
            limit 1
        ];
    }
    
    /**
     * Queries the given opty id with basic opty and address related details.
     */
    public Opportunity queryOptyWithAddressDetails(String optyId) {
        return [
            select
            	Id, Name, Account.BillingStreet, Account.BillingCity, Account.BillingState, Account.BillingPostalCode, 
            	Account.BillingCountry, Account.Latitude__c, Account.Longitude__c, 
            	Account.Billing_Address_Location__Latitude__s, Account.Billing_Address_Location__Longitude__s, 
	            Account.Address_Standardization_Status__c
            from Opportunity
            where Id = :optyId
            limit 1
        ];
    }

    public List<NearbyCustomersViewerServiceDto.LeadWithDistance> findLeadsWithinDistance(Integer maxRecords, Double withinDistanceInMiles, Decimal lat, Decimal lng, String ignoreLeadId) {
        
        String soql = 'select id, Name, Lead_Status__c, FirstName, LastName, Street, City, State, PostalCode, Latitude__c, Longitude__c from Lead where Latitude__c != null and Longitude__c != null ';

        if (ignoreLeadId != null) {
            soql += ' and id != :ignoreLeadId';
        }
        
        soql += ' and DISTANCE(Address_Location__c, GEOLOCATION(' 
            	+ lat + ', ' + lng + '), \'mi\') < ' + withinDistanceInMiles + ' order by DISTANCE(Address_Location__c, GEOLOCATION(' 
            	+ lat + ', ' + lng + '), \'mi\') limit ' + maxRecords;
        
        info('Executing the soql ' + soql);
        
        List<Lead> leads = Database.query(soql);
        
        List<NearbyCustomersViewerServiceDto.LeadWithDistance> leadsWithDistance = new List<NearbyCustomersViewerServiceDto.LeadWithDistance>();
        for (Lead lead : leads) {
            leadsWithDistance.add(new NearbyCustomersViewerServiceDto.LeadWithDistance(lead, Sf.addressService.calculateDistance(lat, lng, lead.Latitude__c, lead.Longitude__c)));
        }
        
        return leadsWithDistance;
    }

    public List<NearbyCustomersViewerServiceDto.OptyWithDistance> findOptiesWithinDistance(Integer maxRecords, Double withinDistanceInMiles, Decimal lat, Decimal lng) {
        String soql = 'select id, Opportunity_Status__c, Name, Account.Name, Account.BillingStreet, Account.BillingCity, Account.BillingState, Account.BillingPostalCode, Account.Latitude__c, Account.Longitude__c from Opportunity where Account.Latitude__c != null and Account.Longitude__c != null and DISTANCE(Account.Billing_Address_Location__c, GEOLOCATION(' 
            	+ lat + ', ' + lng + '), \'mi\') < ' + withinDistanceInMiles + ' order by DISTANCE(Account.Billing_Address_Location__c, GEOLOCATION(' 
            	+ lat + ', ' + lng + '), \'mi\') limit ' + maxRecords;
        
        info('Executing the soql ' + soql);
        
        List<Opportunity> opties = Database.query(soql);
        
        List<NearbyCustomersViewerServiceDto.OptyWithDistance> optiesWithDistance = new List<NearbyCustomersViewerServiceDto.OptyWithDistance>();
        for (Opportunity opty : opties) {
            optiesWithDistance.add(new NearbyCustomersViewerServiceDto.OptyWithDistance(opty, Sf.addressService.calculateDistance(lat, lng, opty.Account.Latitude__c, opty.Account.Longitude__c)));
        }
        
        return optiesWithDistance;
    }
    
    public List<NearbyCustomersViewerServiceDto.ContractWithDistance> findContractsWithinDistance(Integer maxRecords, Double withinDistanceInMiles, Decimal lat, Decimal lng) {
        String soql = 'select id, '
            	+ ' Status__c, Name, Customer_Name__c, Customer_Phone__c, '
            	+ ' Sales_Organization_Id__r.Name, Sales_Rep_Email__c, System_Size_DC__c, '
            	+ ' Opportunity__r.Lead_Source_2__c, Account.Name, Account.BillingStreet, '
            	+ ' Account.BillingCity, Account.BillingState, Account.BillingPostalCode, '
            	+ ' Account.Latitude__c, Account.Longitude__c, (select CSAT_Survey_Response__c, '
            	+ ' LastModifiedDate from Surveys__r order by LastModifiedDate desc limit 1) ' 
            	+ ' from ServiceContract where Status__c != \'Deal Cancelled\' and Service_Contract_Status__c = \'Active\' and '
            	+ ' Account.Latitude__c != null and Account.Longitude__c != null and '
            	+ ' DISTANCE(Account.Billing_Address_Location__c, GEOLOCATION(' 
            	+ lat + ', ' + lng + '), \'mi\') < ' + withinDistanceInMiles 
            	+ ' order by DISTANCE(Account.Billing_Address_Location__c, GEOLOCATION(' 
            	+ lat + ', ' + lng + '), \'mi\') limit ' + maxRecords;
        
        info('Executing the soql ' + soql);
        
        List<ServiceContract> contracts = Database.query(soql);
        
        List<NearbyCustomersViewerServiceDto.ContractWithDistance> contractsWithDistance = new List<NearbyCustomersViewerServiceDto.ContractWithDistance>();
        for (ServiceContract contract : contracts) {
            contractsWithDistance.add(new NearbyCustomersViewerServiceDto.ContractWithDistance(contract, Sf.addressService.calculateDistance(lat, lng, contract.Account.Latitude__c, contract.Account.Longitude__c)));
        }

        contractsWithDistance.sort();
        
        return contractsWithDistance;
    }
}