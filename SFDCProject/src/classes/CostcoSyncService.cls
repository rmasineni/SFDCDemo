public interface CostcoSyncService {
    void handleLeadsTrigger();
    void syncLeads(List<Id> leadIds);
    void retrieveLeads();
    
    void handleAppointmentsTrigger();
    void updateLeadsEstimateDate(List<Id> appointmentIds);
    
    void handleProposalsTrigger();
    void updateLeadsQuoteAmount(List<Id> proposalIds);
    
    void handleServiceContractsTrigger();
    void updateInstallationInfo(List<id> sceIds);
    
    void handleOpportunitiesTrigger();
    void syncOpptys(List<Id> oppIds);
}