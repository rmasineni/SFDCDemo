public class milestoneProofPartnerPreferences {
	
	User userRec {get;set;} 
	public Milestone_Proof_Partner_Preference__c partnerPreference; 
	
	public milestoneProofPartnerPreferences()
	{
		userRec = [Select Contact.AccountId From User WHERE Id = :Userinfo.getUserid()];
	}

    public Milestone_Proof_Partner_Preference__c getPartnerPreference()
    {
        if(partnerPreference == null) 
        {
			Milestone_Proof_Partner_Preference__c[] partnerPreferenceList = [Select Id, Partner_Account__c, Notify_Milestone_Proof_Upload__c, Emails_To_Notify_Milestone_Proof_Upload__c 
							From Milestone_Proof_Partner_Preference__c Where Partner_Account__c = :userRec.Contact.AccountId Limit 1];

			if (partnerPreferenceList == null || partnerPreferenceList.size() <= 0)
        	{
				partnerPreference = new Milestone_Proof_Partner_Preference__c();
        	}
        	else
        	{
        		partnerPreference = partnerPreferenceList[0]; 	
        	}
        }
        
        return partnerPreference;   
        
    }	
	
	public PageReference savePreferences()
	{
		if (partnerPreference.Id == null)
		{
			partnerPreference.Partner_Account__c = userRec.Contact.AccountId;
			insert partnerPreference;
		}
		else
		{
			update partnerPreference;
		}
		ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO,'Preferences Saved'));
		return null;
	}
	
    public static testMethod void milestoneProofPreferencesTest()
    {
        Test.startTest();
        milestoneProofPartnerPreferences testMileStoneProofPref = new milestoneProofPartnerPreferences();
        testMileStoneProofPref.getPartnerPreference();
        testMileStoneProofPref.savePreferences();
 		Test.stopTest();       
    }
	
}