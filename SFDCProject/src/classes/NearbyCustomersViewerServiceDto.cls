public class NearbyCustomersViewerServiceDto {
	private static BaseClass utils = new BaseClass();
    
	/**
	 * Wrapper class which holds the distance this lead falls from a reference point.
	 * 
	 * Distance is in miles.
	 */    
    public class LeadWithDistance {
        public Lead lead {get;set;}
        public Decimal distance {get;set;}
        
        public LeadWithDistance(Lead lead, Decimal distance) {
            this.lead = lead;
            this.distance = distance;
        }
        
        public String getFormattedDistance() {
            return NearbyCustomersViewerServiceDto.utils.formatAmount(distance);
        }
    }
    
    public class OptyWithDistance {
        public Opportunity opty {get;set;}
        public Decimal distance {get;set;}
        
        public OptyWithDistance(Opportunity opty, Decimal distance) {
            this.opty = opty;
            this.distance = distance;
        }
    }

    public class ContractWithDistance implements Comparable {
        public ServiceContract contract {get;set;}
        public Decimal distance {get;set;}
        public String salesOrgName {get;set;}	
        
        public ContractWithDistance(ServiceContract contract, Decimal distance) {
            this.contract = contract;
            this.distance = distance;
            this.salesOrgName = contract.Sales_Organization_Id__r.name;
        }
        
        public Survey__c getCsatSurvey() {
            return contract.Surveys__r.isEmpty()?null:contract.Surveys__r.get(0);
        }
        
        public Integer compareTo(Object compareToObj) {
            ContractWithDistance o2 = (ContractWithDistance) compareToObj;
            Integer priorityO1 = contract.Sales_Organization_Id__r.Name=='Sunrun'?0:1;
            Integer priorityO2 = o2.contract.Sales_Organization_Id__r.Name=='Sunrun'?0:1;
            Integer result = utils.compareTo(priorityO1, priorityO2);
            if (result == 0) {
                result = utils.compareTo(distance, o2.distance);
            }
            
            return result;
        }
    }
}