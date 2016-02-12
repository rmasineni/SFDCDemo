trigger trg_Offer_after_insert on Offer__c (after insert, after update) {
   
   Map<Id, Id> mapLeadIdToOfferId = new Map<Id, Id>();
   Map<Id, Id> mapOpptyIdToOfferId = new Map<Id, Id>();
   List<Lead> listUpdateLeads = new List<Lead>();
   List<Opportunity> listUpdateOpptys = new List<Opportunity>();
   //List<Generation_Assets__c> listUpdateGA = new List<Generation_Assets__c>();
   List<ServiceContract> listSCUpdate=new List<ServiceContract>();
   if(Trigger.isInsert)
   {
      for(Offer__c Offer:Trigger.New)
      {
         if(Offer.Lead__c != null && Offer.Lead__r.IsConverted == false)
         {
             mapLeadIdToOfferId.put(Offer.Lead__c, Offer.Id);
         }
         if(Offer.Opportunity__c != null)
         {
            mapOpptyIdToOfferId.put(Offer.Opportunity__c, Offer.Id);
         }
      }
   
      for(Lead OfferLeads:[select id, Offer__c from Lead where Id in :mapLeadIdToOfferId.keyset() and IsConverted = false])
      {
         if(OfferLeads.Offer__c == null){
	         OfferLeads.Offer__c = mapLeadIdToOfferId.get(OfferLeads.id);
	         listUpdateLeads.add(OfferLeads);
         }
      }
      for(Opportunity OfferOpptys:[select id, Offer__c from Opportunity where Id in :mapOpptyIdToOfferId.keyset()])
      {
         OfferOpptys.Offer__c = mapOpptyIdToOfferId.get(OfferOpptys.id);
         listUpdateOpptys.add(OfferOpptys);
      }           
      // Check if GenAsset exists for this oppty.  If so, update the Offer on GA and GA on Offer.
      /*for(Generation_Assets__c ga:[select id, Opportunity_Name__c, Offer__c from Generation_Assets__c where Opportunity_Name__c in :mapOpptyIdToOfferId.keyset()])
      {
         ga.Offer__c = mapOpptyIdToOfferId.get(ga.Opportunity_Name__c);
         listUpdateGA.add(ga);
      } */
      for(ServiceContract sc:[select id, Opportunity__c, Offer__c from ServiceContract where Opportunity__c in :mapOpptyIdToOfferId.keyset()]){
      	sc.Offer__c=mapOpptyIdToOfferId.get(sc.Opportunity__c);
      	listSCUpdate.add(sc);
      }

      if(listUpdateOpptys.size() > 0)
      {
         update listUpdateOpptys;
      }   
      if(listUpdateLeads.size() > 0)
      {
         update listUpdateLeads;
      }
      if(listSCUpdate.size()>0){
      	update listSCUpdate;
      }
      /*
      if(listUpdateGA.size() > 0)
      {
          update listUpdateGA;      
      }
      */
   }
}