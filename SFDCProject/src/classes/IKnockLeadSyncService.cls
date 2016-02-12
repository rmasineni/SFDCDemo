public interface IKnockLeadSyncService {

    void retrieveLeads();
    
    void syncLeadsToIKnock(List<Lead> leads);

    void syncOptiesToIKnock(List<Lead> leads);
}