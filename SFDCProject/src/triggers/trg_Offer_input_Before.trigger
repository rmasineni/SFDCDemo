trigger trg_Offer_input_Before on Offer__c (before insert, before update) {
    
    Set<Id> setOppIds = new Set<Id>();
    //Map<Id, Id> mapOppIdToGAId = new Map<Id, Id>(); 
    Map<Id, Id> mapOppIdConId = new Map<Id, Id>();
    Map<Id, Id> mapOppIdToSCId = new Map<Id, Id>(); 
      for(Offer__c Offer:Trigger.New)
      {
         if(Trigger.isInsert || (Trigger.isUpdate && Offer.Opportunity__c != null && Trigger.oldMap.get(Offer.Id).Opportunity__c == null))
         {
            if(Offer.Opportunity__c !=null){
              setOppIds.add(Offer.Opportunity__c);            
            }
         }
         
      }
      if(!setOppIds.isempty()){
      for(OpportunityContactRole ocr:[Select Role, OpportunityId, ContactId, Contact.AccountId, isPrimary From OpportunityContactRole where OpportunityId in :setOppIds AND isPrimary = true])
      {
        mapOppIdConId.put(ocr.OpportunityId, ocr.ContactId);
        
      }
      }
      /*
      for(Generation_Assets__c ga:[select id, Offer__c, Opportunity_Name__c, Customer_Contact__c from Generation_Assets__c where Opportunity_Name__c in :setOppIds])
      {
         mapOppIdToGAId.put(ga.Opportunity_Name__c, ga.Id);
      }
      */
      if(!setOppIds.isempty()){
      for(ServiceContract sc:[select id, Offer__c, Opportunity__c, Contactid from ServiceContract where Opportunity__c in :setOppIds])
      {
         mapOppIdToSCId.put(sc.Opportunity__c, sc.Id);
      }
      }
      for(Offer__c Offer:Trigger.New)
      {
         if(Offer.Opportunity__c != null && !mapOppIdConId.isEmpty() && Offer.Customer_Contact__c == null)
         {
            Offer.Customer_Contact__c = mapOppIdConId.get(Offer.Opportunity__c);
       
         }
         /*
         if(Offer.Opportunity__c != null && mapOppIdToGAId.get(Offer.Opportunity__c) != null && Offer.Generation_Asset__c == null)
         {
            Offer.Generation_Asset__c = mapOppIdToGAId.get(Offer.Opportunity__c);
         }
         */
         if(Offer.Opportunity__c != null && mapOppIdToSCId.get(Offer.Opportunity__c) != null && Offer.Service_Contract__c == null)
         {
            Offer.Service_Contract__c = mapOppIdToSCId.get(Offer.Opportunity__c);
         }
      }
}