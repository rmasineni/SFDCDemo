trigger trg_lead_after_delete on Lead (after delete) {
   List<Referral_Input__c> listReferrals = new List<Referral_Input__c>();
   Set<Id> setRefIds = new Set<Id>();
   for(Lead deletedLead:Trigger.Old)
   {
      if(deletedLead.Referral_Input__c != null)
      {
         setRefIds.add(deletedLead.Referral_Input__c);
      }
   }
   for(Referral_Input__c ri:[select id from Referral_Input__c where id in :setRefIds])
   {
      listReferrals.add(ri);
   }
   if(!listReferrals.isEmpty())
   {
      delete listReferrals;
   }
}