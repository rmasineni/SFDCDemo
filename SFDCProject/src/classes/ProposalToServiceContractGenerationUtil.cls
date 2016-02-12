public class ProposalToServiceContractGenerationUtil {

    private static Map<String, String> proposalToServiceContractFieldMap = new Map<String, String>();
    private static Map<String, String> proposalToSCEventFieldMap = new Map<String, String>();

    static
    {              
        Map<String, ProposalToServiceContractFields__c> proposalToServiceContractFields = ProposalToServiceContractFields__c.getAll();
        
        for (String proposalField: proposalToServiceContractFields.keySet()) {
            ProposalToServiceContractFields__c proposalToServiceContractField = ProposalToServiceContractFields__c.getInstance(proposalField);
            proposalToServiceContractFieldMap.put(proposalToServiceContractField.Proposal_Field__c, proposalToServiceContractField.Service_Contract_Field__c);           
        }        
    }

    static
    {              
        Map<String, Proposal_To_SC_Event_Fields__c> proposalToSCEventFields = Proposal_To_SC_Event_Fields__c.getAll();
		for (String proposalField: proposalToSCEventFields.keySet()) {
            Proposal_To_SC_Event_Fields__c proposalToSCEventField = Proposal_To_SC_Event_Fields__c.getInstance(proposalField);
            proposalToSCEventFieldMap.put(proposalToSCEventField.Proposal_Field__c, proposalToSCEventField.Service_Contract_Event_Field__c);           
        }        
    }
    
    public static Set<String> getProposalFields() { 
        return proposalToServiceContractFieldMap.keySet();
    }    

    public static Set<String> getProposalFieldsForSCEvent() { 
        return proposalToSCEventFieldMap.keySet();
    }
    
    public static List<String> getServiceContractFields() {
        return proposalToServiceContractFieldMap.values();
    }       

    public static List<String> getServiceContractEventFields() {
        return proposalToSCEventFieldMap.values();
    }
    
    public static String getProposalFieldsString() {    
        String fields = '';
        Set<String> proposalFields = getProposalFields();
        for (String field : proposalFields) {
            fields += ', ' + field;
        }
 
        Set<String> proposalSCEventFields = getProposalFieldsForSCEvent();
        for (String field : proposalSCEventFields) {
            fields += ', ' + field;
        }    
        
        System.debug('EventFields:01 ' + fields);    
		
		if(!proposalFields.contains('SR_Credit_Status__c')){
			fields += ', SR_Credit_Status__c ';
		}
		if(!proposalFields.contains('Current_Customer_Credit_Report__c')){
			fields += ', Current_Customer_Credit_Report__c ';
		}
		if(!proposalFields.contains('Sunrun_Credit_Status__c')){
			fields += ', Sunrun_Credit_Status__c ';
		}
		if(!proposalFields.contains('SR_Signoff__c')){
			fields += ', SR_Signoff__c ';
		}
		 System.debug('EventFields:02 ' + fields);    
		
		if(!proposalFields.contains('Revised_SR_Signoff__c')){
			fields += ', Revised_SR_Signoff__c ';
		}
		if(!proposalFields.contains('System_Size_STC_DC__c')){
			fields += ', System_Size_STC_DC__c ';
		}
		if(!proposalFields.contains('First_Year_Generation_Estimate__c')){
			fields += ', First_Year_Generation_Estimate__c ';
		}
		return fields; 
    }

    public static String getServiceContractFieldsString() {    
        String fields = '';
        for (String field : getServiceContractFields()) {
            fields += ', ' + field;
        }
        fields += ', Original_Full_System_Cost__c, Original_Price_per_kWh__c, 	Original_Rebate_Estimate__c, Original_System_Size_CEC_AC__c, Original_Yr_1_Gen__c, Payment_Mode__c ';
        System.debug('fields: ' + fields);
        return fields; 
    }    

    public static String getServiceContractEventFieldsString() {    
        String fields = '';
        for (String field : getServiceContractEventFields()) {
            fields += ', ' + field;
        }
        System.debug('EventFields:0 ' + fields);
        
        fields += ', Original_Upfront_Payment_Amount__c, Original_Rebate_Estimate__c, Service_Contract__c ';
        if(!fields.contains('Customer_s_Email__c')){
        	fields += ', Customer_s_Email__c ';
        }
        if(!fields.contains('SR_Signoff__c')){
        	fields += ', SR_Signoff__c ';
        }
        if(!fields.contains('Revised_SR_Signoff__c')){
        	fields += ', Revised_SR_Signoff__c ';
        }
        System.debug('EventFields:1 ' + fields);
        return fields; 
    } 
    
    public static String getProposalFieldMapTo(String proposalField) {
        return proposalToServiceContractFieldMap.get(proposalField);
    } 

    public static String getProposalFieldMapToSCEvent(String proposalField) {
        return proposalToSCEventFieldMap.get(proposalField);
    } 
	
}