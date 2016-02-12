public interface AwsSyncService {
	
    void handleLeadsTrigger();
    void syncLeads(SyncJobInfo syncJob);
    
    void handleOptysTrigger();
    void handleAccountsTrigger();
    void handleContactsTrigger();
    void syncOptys(SyncJobInfo syncJob);

    void handlePaymentsTrigger();
	void syncPayments(SyncJobInfo syncJob);
    
    void handleCreditsTrigger();
	void syncCredits(SyncJobInfo syncJob);
    
    void handleContractsTrigger();
    void syncContracts(SyncJobInfo syncJob);

    void handleProposalsTrigger();
    void syncProposals(SyncJobInfo syncJob);

    String sendSqsMessage(String queueName, String message);
}