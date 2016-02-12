trigger trg_aft_ins_oppty on Opportunity (after insert, after update) {
   Map<Id, Id> mapRefIdToOppId = new Map<Id, Id>();
   List<Referral_Input__c> listReferralUpdates = new List<Referral_Input__c>();
   ReferralService refSvc = new ReferralService(); 
   List<Referral_Input__c> listNewReferrals = new List<Referral_Input__c>();
   Map<Id, Id> mapReferralToNewSource = new Map<Id, Id>();
   Set<Id> setOppIds = new Set<Id>();
   //
   /*
   if(Trigger.isInsert)
   {
      for(Opportunity o:Trigger.New)
      {
   	     if(o.Referral__c != null)
   	     {
	        mapRefIdToOppId.put(o.Referral__c, o.Id);
   	     }	
      }
      for(Referral_Input__c r:[select id, Opportunity__c from Referral_Input__c where id in :mapRefIdToOppId.KeySet()])
      {
   	     r.Opportunity__c = mapRefIdToOppId.get(r.id);
   	     listReferralUpdates.add(r);
      }
      if(listReferralUpdates.size() > 0)
      {
         update listReferralUpdates;
      }
      // get contact id for updating referral target contact id.
   }
   */
   //check for stage change to see if qualifies for referralbpayment
   Map<Id, Set<String>> mapReferralIdToStage = new Map<Id, Set<String>>(); 
   Map<Id, Set<String>> mapReferralIdToConvertedLead = new Map<Id, Set<String>>();  // To handle Salesforce bug where trigger does not catch status change to "Converted".  
   List<Referral_Input__c> listReferrals = new List<Referral_Input__c>();
   for(Opportunity o:Trigger.New)
   {
   	   if((Trigger.isInsert || (Trigger.isUpdate && o.StageName != Trigger.oldMap.get(o.Id).StageName)) && o.Referral__c != null)
   	   {   	   	   
           if(mapReferralIdToStage.get(o.Referral__c) != null)
           {
              mapReferralIdToStage.get(o.Referral__c).add(o.StageName);
           }
           else
           {
              mapReferralIdToStage.put(o.Referral__c, new Set<String>{o.StageName});	
           }    	   	   
   	   	   if(Trigger.isInsert && o.Lead_Created_Date__c != null)
   	   	   {
   	   	   	    System.Debug('Adding Value to Converted Lead Map for referral: ' + o.Referral__c);
        	    if(mapReferralIdToConvertedLead.get(o.Referral__c) != null)
        	    {
        	    	mapReferralIdToConvertedLead.get(o.Referral__c).add('Converted');
        	    }
        	    else
        	    {
        	       mapReferralIdToConvertedLead.put(o.Referral__c, new Set<String>{'Converted'});	
        	    }   	   	   	     	   	   	  
   	   	   }
   	   }
   }
   if(!mapReferralIdToStage.isEmpty())
   {
      refSvc.setReferralStatus(mapReferralIdToStage, 'Opportunity');
   }
   if(!mapReferralIdToConvertedLead.isEmpty())
   {
   	  System.Debug('Calling SetReferralStatus');
   	  refSvc.setReferralStatus(mapReferralIdToConvertedLead, 'Lead');
   }
   if(!mapReferralToNewSource.isEmpty())
   {
      refSvc.updateReferralSource(mapReferralToNewSource);
   }
   
  /* List<Offer__c> offerObjList = new List<Offer__c>();
   for(Opportunity newoppty:Trigger.New){
   		if(trigger.isInsert ){
   			
   			Offer__c offerObj = new Offer__c();
   			
   			if(newoppty.id != null && newoppty.offer_promotion_name__c != null){
   			offerObj.Opportunity__c = newoppty.id;
   			offerObj.Promotion__c = newoppty.offer_promotion_name__c;
   			offerObj.Customer_Salutation__c = newoppty.LC_Salutation__c;

   			 offerObj.Customer_Address_City__c =  newoppty.LC_City__c;
   			 offerObj.Customer_Address_Country__c =  newoppty.LC_Country__c;
   			 offerObj.Customer_Email__c =  newoppty.LC_Email__c;
   			 offerObj.Customer_First_Name__c =  newoppty.LC_FirstName__c;
   			 offerObj.Customer_Last_Name__c =  newoppty.LC_LastName__c;
   			 offerObj.Customer_Phone_Number__c =  newoppty.LC_PhoneNumber__c;
   			 offerObj.Customer_Address_State__c =  newoppty.LC_State__c;
   			 offerObj.Customer_Address_Street__c =  newoppty.LC_Street__c;
   			 offerObj.Customer_Address_ZipCode__c =  newoppty.LC_ZipCode__c;
   			 
   			 
   			 offerObjList.add(offerObj);
   			}
   			 
   		}
   }
   if(offerObjList.size() > 0 && offerObjList != null){
   	insert offerObjList;
   	
   } */
}