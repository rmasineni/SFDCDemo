/****************************************************************************
Author  : Peter Alexander Mandy (pmandy@sunrunhome.com)
Date    : June 05, 2012
Description: This trigger:
             1) Sets the Referral Id if not already set.
             2) monitors the dates on the gen asset to see if it qualifies the corresponding referral for payment.
             3) Updates the target contact/account on the correspondnig referral if applicable.
             Other: Qualtrics Actions, commented out as of 08/08/2012:16:30:08.22
Modifications by: pmandy@sunrunhome.com
08032012: Consider source's GA.  It must have reached M1 and have a TE Fund set in order to pay out referral to source and target.
08082012: Handle setting multiple GA dates in the same DML Transaction.
*****************************************************************************/
trigger trg_gen_asset_after_upd on Generation_Assets__c (after insert, after update) 
{
// Begin Peter Alexander Mandy - Gretsky Code
    Map<Id, Set<String>> mapReferralIdToStatus = new Map<Id, Set<String>>();
    Map<Id, Set<String>> mapOfferIdToStatus = new Map<Id, Set<String>>();
    Map<Id, Id> mapGenAssetIdConId = new Map<Id, Id>();
    Map<Id, Id> mapGenAssetIdAccountId = new Map<Id, Id>(); 
    Map<Id, Id> mapReferralGenAsset = new Map<Id, Id>();
    Map<Id, Id> mapOfferGenAsset = new Map<Id, Id>();
    Map<Id, Id> mapGenAssetContact = new Map<Id, Id>();
    List<Referral_Input__c> listUpdateReferralInput = new List<Referral_Input__c>();
    List<Referral_Input__c> listUpdateReferralsGAId = new List<Referral_Input__c>();
    List<Offer__c> listUpdateOffersGAId = new List<Offer__c>(); 
    List<Offer__c> listUpdateOffersContactId = new List<Offer__c>();
          
    ReferralService refSvc = new ReferralService(); 
    //
    Set<Id> setSourceContacts = new Set<Id>();
    Map<Id,Set<Id>> mapSourceContactReferrals = new Map<Id, Set<Id>>();
    Map<Id,Set<Id>> mapContactOffers = new Map<Id, Set<Id>>();
    Set<Id> opportunityIds = new Set<Id>();
    Set<String> proposalNames = new Set<String>();
	Map<String, Proposal__C> proposalMap = new Map<String, Proposal__C>();
    for(Generation_Assets__c ga:Trigger.New)
    {

		Generation_Assets__c oldGenAsset;
		if(Trigger.isUpdate){
			oldGenAsset = Trigger.oldMap.get(ga.Id);
		}

    	if(Trigger.isInsert && ga.Opportunity_Name__c != null){
    		opportunityIds.add(ga.Opportunity_Name__c);
    	}

		//Check changes to source contact GA fields that qualify from the source's end of things.
		if(ga.Proposal_Unique_ID__c != null && ga.Proposal_Unique_ID__c != '' 
			&& (Trigger.isInsert || (Trigger.isUpdate &&  oldGenAsset.Proposal_Unique_ID__c != ga.Proposal_Unique_ID__c))){
			proposalNames.add(ga.Proposal_Unique_ID__c);
		} 

    	//Check changes to source contact GA fields that qualify from the source's end of things.
    	if((Trigger.isInsert && (ga.TE_Fund_name__c != null || ga.TE_Fund_name__c != '') && (ga.M1_proof_panel_inverter_delivery__c != null))
    	    || (Trigger.isUpdate && ((ga.TE_Fund_name__c != null || ga.TE_Fund_name__c != '') && (Trigger.oldMap.get(ga.Id).TE_Fund_name__c == null || Trigger.oldMap.get(ga.Id).TE_Fund_name__c == ''))
        	|| (ga.M1_proof_panel_inverter_delivery__c != null && Trigger.oldMap.get(ga.Id).M1_proof_panel_inverter_delivery__c == null))            
        	)
    	{
    		// so we must check if these customer contacts are source contacts for any referrals.
    		// and get the GA on those referrals to see if it has reached any payment qualifying states.
    		setSourceContacts.add(ga.Customer_Contact__c);
    		if(mapSourceContactReferrals.get(ga.Customer_Contact__c) != null)
    		{
    			mapSourceContactReferrals.get(ga.Customer_Contact__c).add(ga.Referral_Input__c);
    		}
    		else
    		{
    			mapSourceContactReferrals.put(ga.Customer_Contact__c, new Set<Id>{ga.Referral_Input__c});
    		}
    		//Offer
    		if(mapContactOffers.get(ga.Customer_Contact__c) != null)
    		{
    			mapContactOffers.get(ga.Customer_Contact__c).add(ga.Offer__c);
    		}
    		else
    		{
    			mapContactOffers.put(ga.Customer_Contact__c, new Set<Id>{ga.Offer__c});
    		}
    	}
    	if((Trigger.isInsert && ga.Referral_Input__c != null) || (Trigger.isUpdate && ga.Referral_Input__c != null && (Trigger.oldMap.get(ga.Id).Referral_Input__c == null || ga.Referral_Input__c != Trigger.oldMap.get(ga.Id).Referral_Input__c)))
		{
			mapReferralGenAsset.put(ga.Referral_Input__c, ga.id);
		}
		if((Trigger.isInsert && ga.Offer__c != null) || (Trigger.isUpdate && ga.Offer__c != null && (Trigger.oldMap.get(ga.Id).Offer__c == null || ga.Offer__c != Trigger.oldMap.get(ga.Id).Offer__c)))
		{
			mapOfferGenAsset.put(ga.Offer__c, ga.id);
			
		}
		if((Trigger.isInsert && ga.Customer_Contact__c != null && ga.Offer__c != null) || (Trigger.isUpdate && ga.Customer_Contact__c != null && ga.Offer__c != null && (Trigger.oldMap.get(ga.Id).Customer_Contact__c == null || ga.Customer_Contact__c != Trigger.oldMap.get(ga.Id).Customer_Contact__c)))
		{
			mapGenAssetContact.put(ga.Offer__c,ga.Customer_Contact__c);
		}
        if((Trigger.isInsert && (ga.Customer_Contact__c != null || ga.Account_Name__c != null))
            || (Trigger.isUpdate 
                && (    (ga.Customer_Contact__c != null && Trigger.oldMap.get(ga.id).Customer_Contact__c == null)
                     || (ga.Customer_Contact__c != null && Trigger.oldMap.get(ga.id).Customer_Contact__c != null && ga.Customer_Contact__c != Trigger.oldMap.get(ga.id).Customer_Contact__c)
                     || (ga.Account_Name__c != null && Trigger.oldMap.get(ga.id).Account_Name__c == null)
                     || (ga.Account_Name__c != null && Trigger.oldMap.get(ga.id).Account_Name__c != null && ga.Account_Name__c != Trigger.oldMap.get(ga.id).Account_Name__c))
                     )
          )
        {
            //update target info on referral
            mapGenAssetIdConId.put(ga.id, ga.Customer_Contact__c);
            mapGenAssetIdAccountId.put(ga.id, ga.Account_Name__c);
        }
        /*if(   (Trigger.isInsert && ga.Referral_Input__c != null && ga.NTP_Granted__c != null)
           || (   Trigger.isUpdate 
               && ga.NTP_Granted__c != null 
               && Trigger.oldMap.get(ga.Id).NTP_Granted__c == null //ga.Asset_Status__c != Trigger.oldMap.get(ga.Id).Asset_Status__c 
               && ga.Referral_Input__c != null)
          )*/
        if(   (Trigger.isInsert && ga.Referral_Input__c != null && ga.NTP_Granted__c != null && ga.TE_Fund_name__c != null)
           || (   Trigger.isUpdate 
               && ((ga.NTP_Granted__c != null 
               && Trigger.oldMap.get(ga.Id).NTP_Granted__c == null 
               && ga.TE_Fund_name__c != null)
               || (ga.TE_Fund_name__c != null 
               && Trigger.oldMap.get(ga.Id).TE_Fund_name__c == null 
               && ga.NTP_Granted__c != null))               
               && ga.Referral_Input__c != null)
          )          
        {        
        	if(mapReferralIdToStatus.get(ga.Referral_Input__c) != null)
        	{
        		mapReferralIdToStatus.get(ga.Referral_Input__c).add('NTP');
        	}
        	else
        	{
        	   mapReferralIdToStatus.put(ga.Referral_Input__c, new Set<String>{'NTP'});	
        	}           
        }
        //Offer NTP
        if(   (Trigger.isInsert && ga.Offer__c != null && ga.NTP_Granted__c != null && ga.TE_Fund_name__c != null)
           || (   Trigger.isUpdate 
               && ((ga.NTP_Granted__c != null 
               && Trigger.oldMap.get(ga.Id).NTP_Granted__c == null 
               && ga.TE_Fund_name__c != null)
               || (ga.TE_Fund_name__c != null 
               && Trigger.oldMap.get(ga.Id).TE_Fund_name__c == null 
               && ga.NTP_Granted__c != null))               
               && ga.Offer__c != null)
          )          
        {        
        	if(mapOfferIdToStatus.get(ga.Offer__c) != null)
        	{
        		mapOfferIdToStatus.get(ga.Offer__c).add('NTP');
        	}
        	else
        	{
        	   mapOfferIdToStatus.put(ga.Offer__c, new Set<String>{'NTP'});	
        	}           
        }
        //           
        /*if(   (Trigger.isInsert && ga.Referral_Input__c != null && ga.M1_proof_panel_inverter_delivery__c != null)
           || (   Trigger.isUpdate 
               && ga.M1_proof_panel_inverter_delivery__c != null 
               && Trigger.oldMap.get(ga.Id).M1_proof_panel_inverter_delivery__c == null //ga.Asset_Status__c != Trigger.oldMap.get(ga.Id).Asset_Status__c 
               && ga.Referral_Input__c != null)
          )*/
        if((Trigger.isInsert && ga.Referral_Input__c != null && ga.M1_proof_panel_inverter_delivery__c != null)
           || (   Trigger.isUpdate 
               && ((ga.M1_proof_panel_inverter_delivery__c != null 
               && Trigger.oldMap.get(ga.Id).M1_proof_panel_inverter_delivery__c == null 
               && ga.TE_Fund_name__c != null)
               || (ga.TE_Fund_name__c != null 
               && Trigger.oldMap.get(ga.Id).TE_Fund_name__c == null 
               && ga.M1_proof_panel_inverter_delivery__c != null))               
               && ga.Referral_Input__c != null)   
          )       
        {        
        	if(mapReferralIdToStatus.get(ga.Referral_Input__c) != null)
        	{
        		mapReferralIdToStatus.get(ga.Referral_Input__c).add('M1');
        	}
        	else
        	{
        	   mapReferralIdToStatus.put(ga.Referral_Input__c, new Set<String>{'M1'});	
        	}
        }
        //Offer M1
        if((Trigger.isInsert && ga.Offer__c != null && ga.M1_proof_panel_inverter_delivery__c != null)
           || (   Trigger.isUpdate 
               && ((ga.M1_proof_panel_inverter_delivery__c != null 
               && Trigger.oldMap.get(ga.Id).M1_proof_panel_inverter_delivery__c == null 
               && ga.TE_Fund_name__c != null)
               || (ga.TE_Fund_name__c != null 
               && Trigger.oldMap.get(ga.Id).TE_Fund_name__c == null 
               && ga.M1_proof_panel_inverter_delivery__c != null))               
               && ga.Offer__c != null)   
          )       
        {        
        	if(mapOfferIdToStatus.get(ga.Offer__c) != null)
        	{
        		mapOfferIdToStatus.get(ga.Offer__c).add('M1');
        	}
        	else
        	{
        	   mapOfferIdToStatus.put(ga.Offer__c, new Set<String>{'M1'});	
        	}
        }
        //        
        /*if(   (Trigger.isInsert && ga.Referral_Input__c != null && ga.M2_proof_substantial_completion__c != null)
           || (   Trigger.isUpdate 
               && ga.M2_proof_substantial_completion__c != null 
               && Trigger.oldMap.get(ga.Id).M2_proof_substantial_completion__c == null //ga.Asset_Status__c != Trigger.oldMap.get(ga.Id).Asset_Status__c 
               && ga.Referral_Input__c != null)
          )*/
       if((Trigger.isInsert && ga.Referral_Input__c != null && ga.M2_proof_substantial_completion__c != null)
           || (   Trigger.isUpdate 
               && ((ga.M2_proof_substantial_completion__c != null 
               && Trigger.oldMap.get(ga.Id).M2_proof_substantial_completion__c == null 
               && ga.TE_Fund_name__c != null)
               || (ga.TE_Fund_name__c != null 
               && Trigger.oldMap.get(ga.Id).TE_Fund_name__c == null 
               && ga.M2_proof_substantial_completion__c != null))
               && ga.Referral_Input__c != null)
          )          
        {        
        	if(mapReferralIdToStatus.get(ga.Referral_Input__c) != null)
        	{
        		mapReferralIdToStatus.get(ga.Referral_Input__c).add('M2');
        	}
        	else
        	{
        	   mapReferralIdToStatus.put(ga.Referral_Input__c, new Set<String>{'M2'});	
        	}
        }
        //Offer M2
        if((Trigger.isInsert && ga.Offer__c != null && ga.M2_proof_substantial_completion__c != null)
           || (   Trigger.isUpdate 
               && ((ga.M2_proof_substantial_completion__c != null 
               && Trigger.oldMap.get(ga.Id).M2_proof_substantial_completion__c == null 
               && ga.TE_Fund_name__c != null)
               || (ga.TE_Fund_name__c != null 
               && Trigger.oldMap.get(ga.Id).TE_Fund_name__c == null 
               && ga.M2_proof_substantial_completion__c != null))
               && ga.Offer__c != null)
          )          
        {        
        	if(mapOfferIdToStatus.get(ga.Offer__c) != null)
        	{
        		mapOfferIdToStatus.get(ga.Offer__c).add('M2');
        	}
        	else
        	{
        	   mapOfferIdToStatus.put(ga.Offer__c, new Set<String>{'M2'});	
        	}
        }  
        //
       /* if(   (Trigger.isInsert && ga.Referral_Input__c != null && ga.PTO__c != null)
           || (   Trigger.isUpdate 
               && ga.PTO__c != null 
               && Trigger.oldMap.get(ga.Id).PTO__c == null //ga.Asset_Status__c != Trigger.oldMap.get(ga.Id).Asset_Status__c 
               && ga.Referral_Input__c != null)
          )*/
        if(   (Trigger.isInsert && ga.Referral_Input__c != null && ga.PTO__c != null)
           || (   Trigger.isUpdate 
               && ((ga.PTO__c != null 
               && Trigger.oldMap.get(ga.Id).PTO__c == null 
               && ga.TE_Fund_name__c != null)
               || (ga.TE_Fund_name__c != null 
               && Trigger.oldMap.get(ga.Id).TE_Fund_name__c == null 
               && ga.PTO__c != null)) 
               && ga.Referral_Input__c != null)
          )          
        {        
        	if(mapReferralIdToStatus.get(ga.Referral_Input__c) != null)
        	{
        		mapReferralIdToStatus.get(ga.Referral_Input__c).add('PTO Granted, Facility Active');
        	}
        	else
        	{
        	   mapReferralIdToStatus.put(ga.Referral_Input__c, new Set<String>{'PTO Granted, Facility Active'});	
        	}        	
        }
        //Offer PTO
        if(   (Trigger.isInsert && ga.Offer__c != null && ga.PTO__c != null)
           || (   Trigger.isUpdate 
               && ((ga.PTO__c != null 
               && Trigger.oldMap.get(ga.Id).PTO__c == null 
               && ga.TE_Fund_name__c != null)
               || (ga.TE_Fund_name__c != null 
               && Trigger.oldMap.get(ga.Id).TE_Fund_name__c == null 
               && ga.PTO__c != null)) 
               && ga.Offer__c != null)
          )          
        {        
        	if(mapOfferIdToStatus.get(ga.Offer__c) != null)
        	{
        		mapOfferIdToStatus.get(ga.Offer__c).add('PTO Granted, Facility Active');
        	}
        	else
        	{
        	   mapOfferIdToStatus.put(ga.Offer__c, new Set<String>{'PTO Granted, Facility Active'});	
        	}        	
        }
        //
    }
    
    if(proposalNames.size() > 0){
    	proposalMap = ProposalUtil.getProposalMapForGenAsset();
		if(!proposalMap.isEmpty()){
			ProposalUtil.updateCreditInformationForChangeOrders(proposalMap);
		}
    }
		
	Map<Id, Proposal__C> approvedProposalMap = new Map<Id, Proposal__C>();
    if(opportunityIds.size() > 0){
    	approvedProposalMap = EDPUtil.getApprovedProposals(opportunityIds);
    }
    if(Trigger.isInsert && approvedProposalMap.size() > 0){
		for(Generation_Assets__c ga:Trigger.New)
    	{
			if(ga.Opportunity_Name__c != null){
				Proposal__c approvedProposalObj = approvedProposalMap.get(ga.Opportunity_Name__c);
				if(approvedProposalObj != null){
					if(approvedProposalObj.SR_Signoff__c != null){
						ga.SR_Signoff__c = Date.newInstance(approvedProposalObj.SR_Signoff__c.year(),approvedProposalObj.SR_Signoff__c.month(), approvedProposalObj.SR_Signoff__c.day());
					}
					if(approvedProposalObj.Customer_Signoff_Date__c != null){
						ga.Customer_Signoff__c = Date.newInstance(approvedProposalObj.Customer_Signoff_Date__c.year(),approvedProposalObj.Customer_Signoff_Date__c.month(), approvedProposalObj.Customer_Signoff_Date__c.day());
					}
					if(approvedProposalObj.Revised_SR_Signoff__c != null){
						ga.Revised_SR_Signoff__c = Date.newInstance(approvedProposalObj.Revised_SR_Signoff__c.year(),approvedProposalObj.Revised_SR_Signoff__c.month(), approvedProposalObj.Revised_SR_Signoff__c.day());
					}
				}
			}
    	}
    }
    
    // If any GA Source fields were set, check referrals where that person is the source 
    // to see if it now qualifies for payment based on the target's GA
    if(!mapSourceContactReferrals.isEmpty())
    {
       for(Referral_Input__c ri:[select id, Generation_Asset__c, Source_Contact_Id__c
                                       ,Generation_Asset__r.M1_proof_panel_inverter_delivery__c
                                       ,Generation_Asset__r.M2_proof_substantial_completion__c
                                       ,Generation_Asset__r.NTP_Granted__c
                                       ,Generation_Asset__r.PTO__c
                                   from Referral_Input__c 
                                  where Generation_Asset__c != null
                                    and Source_Contact_Id__c in :mapSourceContactReferrals.keySet()
                                    and Generation_Asset__r.TE_Fund_name__c != null
                                    and (Generation_Asset__r.M1_proof_panel_inverter_delivery__c != null
                                       or Generation_Asset__r.M2_proof_substantial_completion__c != null
                                       or Generation_Asset__r.NTP_Granted__c != null
                                       or Generation_Asset__r.PTO__c != null)])
       {
       	  if(ri.Generation_Asset__r.M1_proof_panel_inverter_delivery__c != null)
       	  {
       	   	 for(Id riid:mapSourceContactReferrals.get(ri.Source_Contact_Id__c))
       	  	 {
        	    if(mapReferralIdToStatus.get(ri.id) != null)
        	    {
        	    	mapReferralIdToStatus.get(ri.id).add('M1');
        	    }
        	    else
        	    {
        	       mapReferralIdToStatus.put(ri.id, new Set<String>{'M1'});	
        	    }       	  	 	
       	  	 }
       	  }
       	  if(ri.Generation_Asset__r.M2_proof_substantial_completion__c != null)
       	  {
       	   	 for(Id riid:mapSourceContactReferrals.get(ri.Source_Contact_Id__c))
       	  	 {
        	    if(mapReferralIdToStatus.get(ri.id) != null)
        	    {
        	    	mapReferralIdToStatus.get(ri.id).add('M2');
        	    }
        	    else
        	    {
        	       mapReferralIdToStatus.put(ri.id, new Set<String>{'M2'});	
        	    }
       	  	 }
       	  }
       	  if(ri.Generation_Asset__r.NTP_Granted__c != null)
       	  {
       	   	 for(Id riid:mapSourceContactReferrals.get(ri.Source_Contact_Id__c))
       	  	 {
        	    if(mapReferralIdToStatus.get(ri.id) != null)
        	    {
        	    	mapReferralIdToStatus.get(ri.id).add('NTP');
        	    }
        	    else
        	    {
        	       mapReferralIdToStatus.put(ri.id, new Set<String>{'NTP'});	
        	    }
       	  	 }
       	  }
       	  if(ri.Generation_Asset__r.PTO__c != null)
       	  {
       	  	 for(Id riid:mapSourceContactReferrals.get(ri.Source_Contact_Id__c))       	  	 
       	  	 {
        	    if(mapReferralIdToStatus.get(ri.id) != null)
        	    {
        	    	mapReferralIdToStatus.get(ri.id).add('PTO Granted, Facility Active');
        	    }
        	    else
        	    {
        	       mapReferralIdToStatus.put(ri.id, new Set<String>{'PTO Granted, Facility Active'});	
        	    }
       	  	 }       	  	
       	  }       	         	         	
       }	
    	
    }
    //Offer
    if(!mapContactOffers.isEmpty())
    {
       for(Offer__c Off:[select id, Generation_Asset__c, Customer_Contact__c
                                       ,Generation_Asset__r.M1_proof_panel_inverter_delivery__c
                                       ,Generation_Asset__r.M2_proof_substantial_completion__c
                                       ,Generation_Asset__r.NTP_Granted__c
                                       ,Generation_Asset__r.PTO__c
                                   from Offer__c 
                                  where Generation_Asset__c != null
                                    and Customer_Contact__c in :mapContactOffers.keySet()
                                    and Generation_Asset__r.TE_Fund_name__c != null
                                    and (Generation_Asset__r.M1_proof_panel_inverter_delivery__c != null
                                       or Generation_Asset__r.M2_proof_substantial_completion__c != null
                                       or Generation_Asset__r.NTP_Granted__c != null
                                       or Generation_Asset__r.PTO__c != null)])
       {
       	  if(Off.Generation_Asset__r.M1_proof_panel_inverter_delivery__c != null)
       	  {
       	   	 for(Id riid:mapContactOffers.get(Off.Customer_Contact__c))
       	  	 {
        	    if(mapOfferIdToStatus.get(Off.id) != null)
        	    {
        	    	mapOfferIdToStatus.get(Off.id).add('M1');
        	    }
        	    else
        	    {
        	       mapOfferIdToStatus.put(Off.id, new Set<String>{'M1'});	
        	    }       	  	 	
       	  	 }
       	  }
       	  if(Off.Generation_Asset__r.M2_proof_substantial_completion__c != null)
       	  {
       	   	 for(Id riid:mapContactOffers.get(Off.Customer_Contact__c))
       	  	 {
        	    if(mapOfferIdToStatus.get(Off.id) != null)
        	    {
        	    	mapOfferIdToStatus.get(Off.id).add('M2');
        	    }
        	    else
        	    {
        	       mapOfferIdToStatus.put(Off.id, new Set<String>{'M2'});	
        	    }
       	  	 }
       	  }
       	  if(Off.Generation_Asset__r.NTP_Granted__c != null)
       	  {
       	   	 for(Id riid:mapContactOffers.get(Off.Customer_Contact__c))
       	  	 {
        	    if(mapOfferIdToStatus.get(Off.id) != null)
        	    {
        	    	mapOfferIdToStatus.get(Off.id).add('NTP');
        	    }
        	    else
        	    {
        	       mapOfferIdToStatus.put(Off.id, new Set<String>{'NTP'});	
        	    }
       	  	 }
       	  }
       	  if(Off.Generation_Asset__r.PTO__c != null)
       	  {
       	  	 for(Id riid:mapContactOffers.get(Off.Customer_Contact__c))       	  	 
       	  	 {
        	    if(mapOfferIdToStatus.get(Off.id) != null)
        	    {
        	    	mapOfferIdToStatus.get(Off.id).add('PTO Granted, Facility Active');
        	    }
        	    else
        	    {
        	       mapOfferIdToStatus.put(Off.id, new Set<String>{'PTO Granted, Facility Active'});	
        	    }
       	  	 }       	  	
       	  }       	         	         	
       }	
    	
    }
    //
    if(!mapReferralGenAsset.isEmpty())
    {
      for(Referral_Input__c r:[select id, Generation_Asset__c from Referral_Input__c where Id in :mapReferralGenAsset.keySet()])
      {
   	  	 r.Generation_Asset__c = mapReferralGenAsset.get(r.Id);
   	  	 listUpdateReferralsGAId.add(r);   	  	 
      }
    }
    if(listUpdateReferralsGAId.size() > 0)
    {
   	  	 Update listUpdateReferralsGAId;
    }
    //offer
    if(!mapOfferGenAsset.isEmpty())
    {
      for(Offer__c Offer:[select id, Generation_Asset__c from Offer__c where Id in :mapOfferGenAsset.keySet()])
      {
   	  	 Offer.Generation_Asset__c = mapOfferGenAsset.get(Offer.Id);
	     listUpdateOffersGAId.add(Offer);   	  	 
      }
    }
    if(listUpdateOffersGAId.size() > 0)
    {
   	  	 Update listUpdateOffersGAId;
    }	  
    //Customer Update on Offer
    if(!mapGenAssetContact.isEmpty())
    {
    	for(Offer__c Offer:[select id, Generation_Asset__c from Offer__c where Id in :mapGenAssetContact.keySet()])
      	{
	     	Offer.Customer_Contact__c = mapGenAssetContact.get(Offer.Id);
	     	listUpdateOffersContactId.add(Offer);   
      	}
    }
    if(listUpdateOffersContactId.size() > 0)
    {
   	  	 Update listUpdateOffersContactId;
    }
    
    if(!mapGenAssetIdConId.isEmpty() || !mapGenAssetIdAccountId.isEmpty())
    {
      for(Referral_Input__c r:[select id, Name, Target_Contact_Id__c, Target_Account_Id__c, 
                                    Opportunity__c, Generation_Asset__c,
                                    Milestone_1_Status__c, Milestone_2_Status__c, Milestone_3_Status__c
                               from Referral_Input__c 
                              where Generation_Asset__c in :mapGenAssetIdConId.KeySet()
                                 or Generation_Asset__c in :mapGenAssetIdAccountId.KeySet()])
      {
    	if(   r.Milestone_1_Status__c == null
           && r.Milestone_2_Status__c == null
    	   && r.Milestone_3_Status__c == null)
    	{
    	   if(mapGenAssetIdConId.get(r.Generation_Asset__c) != null)
    	   {
              r.Target_Contact_Id__c = mapGenAssetIdConId.get(r.Generation_Asset__c);
    	   }
           if(mapGenAssetIdAccountId.get(r.Generation_Asset__c) != null)
    	   {
    	   	   r.Target_Account_Id__c = mapGenAssetIdAccountId.get(r.Generation_Asset__c);
    	   }
           listUpdateReferralInput.add(r);
    	}
      }
    }
    if(listUpdateReferralInput.size() > 0)
    {
       Update listUpdateReferralInput;
    }
    //check for stage change to see if qualifies for referral payment
    if(!mapReferralIdToStatus.isEmpty())
    {
    	//Make sure the source is valid (M1 and TE Fund NOT NULL) else remove from map.
    	Map<Id,Set<Id>> mapSourceToReferrals = new Map<Id, Set<Id>>();
    	for(Referral_Input__c r:[select id, Source_Contact_Id__c
    	                           from Referral_Input__c 
    	                          where id in :mapReferralIdToStatus.keyset()])
    	{
    		if(mapSourceToReferrals.get(r.Source_Contact_Id__c) != null)
    		{
    		   mapSourceToReferrals.get(r.Source_Contact_Id__c).add(r.Id);
    		}
    		else
    		{
    		   mapSourceToReferrals.put(r.Source_Contact_Id__c, new Set<Id>{r.Id});
    		}
    	}
    	Set<Id> setQualifiedSourceIds = new Set<Id>();
    	for(Generation_Assets__c ga:[select id, 
    	                                    M1_proof_panel_inverter_delivery__c, 
    	                                    TE_Fund_name__c,
    	                                    Customer_Contact__c
                                       from Generation_Assets__c
                                      where Customer_Contact__c in :mapSourceToReferrals.keyset()])
    	{
    		if(ga.M1_proof_panel_inverter_delivery__c != null && ga.TE_Fund_name__c != null)
    		{
               setQualifiedSourceIds.add(ga.Customer_Contact__c);
    		}    		    		
    	}
    	for(Id srcId:mapSourceToReferrals.keyset())
    	{
    		if(!setQualifiedSourceIds.Contains(srcId))
    		{
    			//Remove from map
    			for(Id refId:mapSourceToReferrals.get(srcId))
    			{
    			   mapReferralIdToStatus.remove(refId);	
    			}
    		}
    	}
    	//If map still has values after evaluating the source GA data and removing as applicable
    	//then issue the call to the Referral Service method.
    	if(!mapReferralIdToStatus.isEmpty())
    	{
    	   refSvc.setReferralStatus(mapReferralIdToStatus, 'Asset');
    	}
    }
    
     
// End Peter Alexander Mandy - Gretsky Code
	
	//check for stage change to see if qualifies for Offer payment
    if(!mapOfferIdToStatus.isEmpty())
    {
    	//Make sure the source is valid (M1 and TE Fund NOT NULL) else remove from map.
    	Map<Id,Set<Id>> mapContactToOffers = new Map<Id, Set<Id>>();
    	for(Offer__c offer:[select id, Customer_Contact__c
    	                           from Offer__c 
    	                          where id in :mapOfferIdToStatus.keyset()])
    	{
    		if(mapContactToOffers.get(offer.Customer_Contact__c) != null)
    		{
    		   mapContactToOffers.get(offer.Customer_Contact__c).add(offer.Id);
    		}
    		else
    		{
    		   mapContactToOffers.put(offer.Customer_Contact__c, new Set<Id>{offer.Id});
    		}
    	}
    	Set<Id> setQualifiedContactIds = new Set<Id>();
    	for(Generation_Assets__c ga:[select id, 
    	                                    M1_proof_panel_inverter_delivery__c, 
    	                                    TE_Fund_name__c,
    	                                    Customer_Contact__c
                                       from Generation_Assets__c
                                      where Customer_Contact__c in :mapContactToOffers.keyset()])
    	{
    		if(ga.M1_proof_panel_inverter_delivery__c != null && ga.TE_Fund_name__c != null)
    		{
               setQualifiedContactIds.add(ga.Customer_Contact__c);
    		}    		    		
    	}
    	for(Id contId:mapContactToOffers.keyset())
    	{
    		if(!setQualifiedContactIds.Contains(contId))
    		{
    			//Remove from map
    			for(Id offId:mapContactToOffers.get(contId))
    			{
    			   mapOfferIdToStatus.remove(offId);	
    			}
    		}
    	}
    	//If map still has values after evaluating the source GA data and removing as applicable
    	//then issue the call to the Referral Service method.
    	if(!mapOfferIdToStatus.isEmpty())
    	{
    	   refSvc.setOfferStatus(mapOfferIdToStatus, 'Asset');
    	}
    } 

}