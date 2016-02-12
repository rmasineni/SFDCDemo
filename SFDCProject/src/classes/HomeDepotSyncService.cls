public interface HomeDepotSyncService {
    void handleLeadsTrigger();
    void handleContactsTrigger();
    void handleOpportunitiesTrigger();
    void handleAccountsTrigger();
    void handleAPIRequestLogTrigger();
    void handleAPIRequestErrorLogTrigger(); 
    
    //void syncLeads(List<Id> leadIds);
    //void syncLeads(List<Lead> leads);
    void syncLeads(String sunrunBatchId, List<Lead> leads);
    
    void lookupLead(Id apiReqId, String batchNumber, String prospectId);
    //Map<String, HomeDepotLeadLookupDto.LeadDTO> lookupLeads(String batchId, String prospectId);
    //Map<String, HomeDepotLeadLookupDto.LeadDTO> lookupLeads(String batchId, String createdDateStart, String createdDateEnd);
    
    //void syncOpportunities(List<Opportunity> opportunities);
    void syncOpportunities(String sunrunBatchId, List<Opportunity> opportunities);
    void lookupOpportunities(String batchId, String createdDate);

    void errorLogLookup(String createdDate);
      
    void updateLeads(Map<String, Map<String, HomeDepotLeadLookupDto.LeadDTO>> batchIdLeadLookupDTO);

    Map<Id, Map<Id, OpportunityContactRole>> getOpportunityRoleMap(List<Id> opportunityIds); 
    Boolean isHomeDepotOpptyReadyToSync(Opportunity opptyObj, Account acctObj, Contact contactObj); 
    Boolean isHomeDepotLeadReadyToSync(Lead lead);
    
    void handleSCEventsTrigger();
    void syncServiceContractEvents(String batchNumber, List<Service_Contract_Event__c> scEvents);
    void lookupSCE(Id apiReqId, String batchNumber, String prospectId);
    void handleAPIRequestLogSCETrigger();
}