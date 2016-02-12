/****************************************************************************
Author  : Peter Alexander Mandy (pmandy@sunrunhome.com)
Date    : June 05, 2012
Description: This trigger updates leads with the referral id from the referral
             that was created if applicable.
*****************************************************************************/
trigger trg_referral_input_after_insert on Referral_Input__c (after insert, after update) {

	Boolean skipValidations = false;
	skipValidations = SkipTriggerValidation.performTriggerValidations();
	if(skipValidations == false){
	   Map<Id, Id> mapLeadIdToReferralId = new Map<Id, Id>();
	   Map<Id, Id> mapOpptyIdToReferralId = new Map<Id, Id>();
	   List<Lead> listUpdateLeads = new List<Lead>();
	   List<Opportunity> listUpdateOpptys = new List<Opportunity>();
	   //List<Generation_Assets__c> listUpdateGA = new List<Generation_Assets__c>();
	   List<ServiceContract> listUpdateSC = new List<ServiceContract>();
	   if(Trigger.isInsert)
	   {
	      for(Referral_Input__c referral:Trigger.New)
	      {
	         if(referral.Lead__c != null)
	         {
	             mapLeadIdToReferralId.put(referral.Lead__c, referral.Id);
	         }
	         if(referral.Opportunity__c != null)
	         {
	            mapOpptyIdToReferralId.put(referral.Opportunity__c, referral.Id);
	         }
	      }
	   
	      for(Lead referralLeads:[select id, Referral_Input__c from Lead where Id in :mapLeadIdToReferralId.keyset()])
	      {
	         referralLeads.Referral_Input__c = mapLeadIdToReferralId.get(referralLeads.id);
	         listUpdateLeads.add(referralLeads);
	      }
	      for(Opportunity referralOpptys:[select id, Referral__c from Opportunity where Id in :mapOpptyIdToReferralId.keyset()])
	      {
	         referralOpptys.Referral__c = mapOpptyIdToReferralId.get(referralOpptys.id);
	         listUpdateOpptys.add(referralOpptys);
	      }           
	      // Check if GenAsset exists for this oppty.  If so, update the referral on GA and GA on Referral.
	      /*
	      for(Generation_Assets__c ga:[select id, Opportunity_Name__c, Referral_Input__c from Generation_Assets__c where Opportunity_Name__c in :mapOpptyIdToReferralId.keyset()])
	      {
	         ga.Referral_Input__c = mapOpptyIdToReferralId.get(ga.Opportunity_Name__c);
	         listUpdateGA.add(ga);
	      } 
	      */
		  for(ServiceContract sc:[select id, Opportunity__c, Referral__c from ServiceContract where Opportunity__c in :mapOpptyIdToReferralId.keyset()])
	      {
	         sc.Referral__c = mapOpptyIdToReferralId.get(sc.Opportunity__c);
	         listUpdateSC.add(sc);
	      }	
	      if(listUpdateOpptys.size() > 0)
	      {
	         update listUpdateOpptys;
	      }   
	      if(listUpdateLeads.size() > 0)
	      {
	         update listUpdateLeads;
	      }
	      /*
	      if(listUpdateGA.size() > 0)
	      {
	          update listUpdateGA;      
	      }*/
	      if(listUpdateSC.size() > 0)
	      {
	          update listUpdateSC;      
	      }
	   }
   }
}