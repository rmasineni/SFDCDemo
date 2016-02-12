trigger trg_gen_asset_bef_ins_upd on Generation_Assets__c (before insert,before update) {
   //Peter Alexander Mandy 06262012
   Set<Id> setOppIds = new Set<Id>();
   Map<Id, Id> mapOppReferral = new Map<Id, Id>();
   Map<Id, Id> mapOppOffer = new Map<Id, Id>();
   Map<Id, Id> mapGAtoOffer = new Map<Id, Id>();
   Map<Id, Id> mapReferralGenAsset = new Map<Id, Id>();
   Map<Id, Id> mapOpptytoGa = new Map<Id, Id>();
   //TIPS-291
   Map<Id, Id> mapOppIdToMarkedAsSoldRep = new Map<Id, Id>();
   Map<Id, String> mapOppIdToCorporateEmail = new Map<Id, String>();   
   Set<String> newHomeTypes = new Set<String>();
   newHomeTypes.add('Vertically-split duplex');
   newHomeTypes.add('Townhome / rowhome');
   newHomeTypes.add('Single-family detached home in condo development');
   
   //
   Set<String> proposalNames = new Set<String>();
   List<Referral_Input__c> listUpdateReferrals = new List<Referral_Input__c>();
   List<Offer__c> OfferList = new List<Offer__c>();
   Map<String, Proposal__C> proposalMap = new Map<String, Proposal__C>();
   if(Trigger.isInsert || Trigger.isUpdate){
		for(Generation_Assets__c ga: Trigger.New)
   	  	{
   	  		Generation_Assets__c oldGenAsset;
   	  		if(Trigger.isUpdate){
   	  			oldGenAsset = Trigger.oldMap.get(ga.Id);
   	  		}
			if(ga.Proposal_Unique_ID__c != null && ga.Proposal_Unique_ID__c != '' 
				&& (Trigger.isInsert || (Trigger.isUpdate &&  oldGenAsset.Proposal_Unique_ID__c != ga.Proposal_Unique_ID__c))){
				proposalNames.add(ga.Proposal_Unique_ID__c);
				System.debug('proposalNames: ' + proposalNames);
			}
   	  	}   

		if(proposalNames.size() > 0){
   	  		proposalMap = ProposalUtil.getProposalMapByName(proposalNames);
   	  		if(!proposalMap.isEmpty()){
   	  			ProposalUtil.notifyPartnerOperations(proposalMap.values());
   	  		}
   	  	}	
		Promotion__c promoObj = new Promotion__c();
		Opportunity opptyObj = new Opportunity();
		List<Opportunity> updateoppty = new List<Opportunity>();
		for(Generation_Assets__c ga: Trigger.New)
		{
			if(ga.Proposal_Unique_ID__c != null && ga.Proposal_Unique_ID__c != '' && proposalMap.containsKey(ga.Proposal_Unique_ID__c)){
				Proposal__c propObj = proposalMap.get(ga.Proposal_Unique_ID__c);
				if(propObj != null){
					if(Trigger.isInsert){
						ga.Total_Solar_Prepay_Required__c = propObj.Total_Solar_Prepay_Required__c;
						ga.Verengo_Financed__c = propObj.Partner_Financed__c;
						ga.ACH_Required__c = propObj.ACH_Required__c;
					}
					ga.proposal__c = propObj.Id;
					System.debug('propObj.home_type__c: ' + propObj.home_type__c);
					System.debug('newHomeTypes: ' + newHomeTypes);
					if(propObj.home_type__c != null && newHomeTypes.contains(propObj.home_type__c)){
						ga.HOA__c = 'Yes - attached home / single-family condo';
					}
					System.debug('ga.HOA__c: ' + ga.HOA__c);
				}
			}
			
			Generation_Assets__c oldGenAsset;
   	  		if(Trigger.isUpdate){
   	  			oldGenAsset = Trigger.oldMap.get(ga.Id);
   	  		}
		
	     	/*if((trigger.isInsert || (Trigger.isUpdate && oldGenAsset.proposal__c != ga.proposal__c)) && (ga.proposal__c != null)){
	        	
	        	system.debug('proposal :' + ga.proposal__c);
				
				Proposal__c propObj = [select id, Promo_Code__c, Opportunity__c from proposal__c where id =: ga.proposal__c];
				
	            system.debug('Promotion :' + propObj.Promo_Code__c);
	            List<Promotion__c> promoObjList = [Select id, Promotion_Code__c, Name from Promotion__c where Promotion_Code__c =: propObj.Promo_Code__c limit 1];
	            
	            system.debug('Opportunity :' + propObj.Opportunity__c);
				List<Opportunity> opptyList = [Select id, name, promotion_name__c from Opportunity where id =: propObj.Opportunity__c limit 1];
				
	            if(promoObjList != null && promoObjList.size() > 0 && opptyList != null && opptyList.size() > 0){
	                 promoObj = promoObjList[0];
	                 opptyObj = opptyList[0];
	                
	                opptyObj.promotion_name__c = promoObj.id;
	                List<Offer__c> addOfferList = [SELECT Id,LastModifiedDate From Offer__c  where Promotion__c =: promoObj.id  ORDER BY LastModifiedDate DESC LIMIT 1];
					Offer__c offer = new Offer__c();
					if(addOfferList.size() > 0){
						offer=addOfferList[0];
						opptyObj.Offer__c = offer.id;
					}
					
	                updateoppty.add(opptyObj);
	            }   
	        }*/
        
		}
		
		
		/*if(updateoppty != null){
			update updateoppty;
		}*/
			
	
	}	

   if(Trigger.isInsert) // || Trigger.isUpdate) //Shourie is checking on when the oppid is set on the ga.
   {
   	  for(Generation_Assets__c ga: Trigger.New)
   	  {
   	  	 if(ga.Opportunity_Name__c != null)
   	  	 {
   	  	 	setOppIds.add(ga.Opportunity_Name__c);
   	  	 	mapOpptytoGa.put(ga.Opportunity_Name__c,ga.id);
   	  	 }
   	  }

   	  for(Opportunity o:[select Id, Referral__c, Offer__c,Sales_Representative__c, Sales_Representative__r.Account.Corporate_Email_Address__c from Opportunity where id in :setOppIds])
   	  {
   	  	mapOppReferral.put(o.Id, o.Referral__c);
   	  	mapOppOffer.put(o.Id, o.Offer__c);
   	  	//mapGAtoOffer.put(o.Offer__c,mapOpptytoGa.get(o.Id));
   	  	//system.debug('mapGAtoOffer:' + o.Offer__c  + ':' + mapOpptytoGa.get(o.Id));
   	  	mapOppIdToMarkedAsSoldRep.put(o.Id, o.Sales_Representative__c);
   	  	mapOppIdToCorporateEmail.put(o.Id, o.Sales_Representative__r.Account.Corporate_Email_Address__c);
   	  }
   	  
   	  /*for(Offer__c offer : [select id,Generation_Asset__c from Offer__c where id in : mapGAtoOffer.keyset() ]){
   	  	offer.Generation_Asset__c = mapGAtoOffer.get(offer.id);
   	  	system.debug('offer.Generation_Asset__c:' + mapGAtoOffer.get(offer.id));
   	  	Offerlist.add(offer);
   	  }
   	  if(offerList.size() > 0){
   	  	update offerlist;
   	  }*/
   	  
   	  for(Generation_Assets__c ga: Trigger.New)
   	  {
   	  	 if(ga.Opportunity_Name__c != null)
   	  	 {
   	  	 	ga.Referral_Input__c = mapOppReferral.get(ga.Opportunity_Name__c);
   	  	 	ga.Offer__c = mapOppOffer.get(ga.Opportunity_Name__c);
   	  	 	if(mapOppIdToMarkedAsSoldRep.get(ga.Opportunity_Name__c) != null)
   	  	 	{
   	  	 	   ga.Marked_As_Sold_Rep__c = mapOppIdToMarkedAsSoldRep.get(ga.Opportunity_Name__c);
   	  	 	}
   	  	 	if(mapOppIdToCorporateEmail.get(ga.Opportunity_Name__c) != null)
   	  	 	{
   	  	 	   ga.Sales_Partner_Corporate_Email_Address__c = mapOppIdToCorporateEmail.get(ga.Opportunity_Name__c);
   	  	 	}
   	  	 	mapReferralGenAsset.put(ga.Referral_Input__c, ga.Id);
   	  	 }
   	  }  
   }
   
    for (Integer intPos = 0; intPos < Trigger.new.size(); intPos++)
    {
        Generation_Assets__c rec = Trigger.new[intPos];
		System.debug('Before M1_proof_panel_inverter_delivery__c: ' + rec.M1_proof_panel_inverter_delivery__c);
        if (rec.SR_Signoff__c != null && rec.Welcome_Call__c != null && (Trigger.isInsert || (rec.Welcome_Call__c != Trigger.old[intPos].Welcome_Call__c || rec.SR_Signoff__c != Trigger.old[intPos].SR_Signoff__c ) ) )
        {
            double busDaysDiff = 0;
            Date fromDate = rec.SR_Signoff__c;
            Date toDate = rec.Welcome_Call__c;
            integer daysDiff = fromDate.daysBetween(toDate);
            if (daysDiff > 0)
            {
                integer weekDiff = math.mod(daysDiff,7);
                integer w1 = fromDate.toStartOfWeek().daysBetween(fromDate);
                integer w2 = toDate.toStartOfWeek().daysBetween(toDate);
                if (w1 > w2)
                    weekDiff -= 2;
                if ((w1 == 0 && w2 == 6) || w1 == 6) 
                    weekDiff--;
                    
                busDaysDiff = Math.abs((Math.floor(daysDiff/7)*5) + weekDiff);
            }
            Trigger.new[intPos].Days_until_Welcome_Call_Made__c = busDaysDiff;
        }
    }
}