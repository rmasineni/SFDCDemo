public interface AmbassadorSyncService {
      void handleReferralsTrigger();
      void syncReferrals(List<Id> referralIds);

	void handleERPContacts();
	void syncERPContacts(List<Id> contactIds);
    
    void handleInactiveRefereeContacts();
    void ActivateRefereeContacts(List<Id> contactIds);
    
    void handleNonAmbassadorReferrals();
	void syncNonAmbassadorReferrals(List<Id> referralIds);
    
}