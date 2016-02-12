trigger trg_promo_before_insert_update on Promotion__c (before insert, before update, before delete) {

	Boolean skipValidations = false;
	skipValidations = SkipTriggerValidation.performTriggerValidations();
	if(skipValidations == false){
		
	   String strPrimaryPromotion = '';
	   String strPromoId = '';
	   Integer countReferrals = 0;
	   Set<Id> setPromotionId = new Set<Id>();
	   for(Promotion__c primaryPromos:[select id,Name from Promotion__c where Primary_Promotion__c = true])
	   {
	   	  strPrimaryPromotion = primaryPromos.Name;
	   	  strPromoId = String.ValueOf(primaryPromos.Id);
	   }    
	   if(!Trigger.isDelete)
	   {
	     for(Promotion__c p:Trigger.New)
	     {   	   	
	   	   setPromotionId.add(p.Id);
	   	   // Check if Referred By is changed or set.
	   	   // Promotion Code
	   	   String strPrefix = '';
	   	   if(p.Promotion_Type__c == 'Customer')
	   	   {
	   	     strPrefix = 'CUS';
	   	   }
	   	   if(p.Promotion_Type__c == 'Advocate')
	   	   {
	   	     strPrefix = 'ADV';
	   	   }
	   	   if(p.Promotion_Type__c == 'Employee')
	   	   {
	   	     strPrefix = 'EMP';
	   	   }
	   	   if(p.Promotion_Type__c == 'Partner')
	   	   {
	   	     strPrefix = 'PAR';
	   	   }
	   	   if(p.Promotion_Code__c == '' || p.Promotion_Code__c == null || (Trigger.oldMap != null && p.Promotion_Type__c != Trigger.oldMap.get(p.Id).Promotion_Type__c))
	   	   {   	   	  
	   	      p.Promotion_Code__c = strPrefix + String.ValueOf(Math.floor(Math.random()*100000).intValue()).replace('0','9').replace('1','8');
	   	      if(p.Promotion_Code__c.length() == 7)
	   	      {
	   	      	 p.Promotion_Code__c = p.Promotion_Code__c + '5';
	   	      }
	   	   }
	   	   //Set the Promotion code to uppercase.
		   if(p.Promotion_Code__c != '' && p.Promotion_Code__c != null)
		   {
		   	   p.Promotion_Code__c = p.Promotion_Code__c.toUpperCase();
		   }
		   // Make sure we are not setting a new primary while one exists.
		   if(strPromoId != '' && strPromoId != String.ValueOf(p.id)
		      && p.Primary_Promotion__c 
		      && strPrimaryPromotion != '')
		   {
		   	  p.addError('You cannot set this Promotion as the Primary, because the "' + strPrimaryPromotion + '" Promotion is already marked as the primary.');
		   }	   
	     }
	   }
	   else
	   {
	   	  for(Promotion__c p:Trigger.Old)
	      {
	   	    setPromotionId.add(p.Id);
	   	  }
	   }   
	   // Get count of referrals using each triggered Promotion.  
	   // If one or more exists, and trigger is update, disallow update.
	   //setPromotionId
	   List<AggregateResult> ag = new List<AggregateResult>();
	   Map<String, Integer> mapPromoUses = new Map<String, Integer>();
       if(!setPromotionId.isEmpty()) 
       {    
	     for(AggregateResult groupedResults:[Select Promotion__c, count(Id) numuses FROM Referral_Input__c Where Promotion__c in :setPromotionId group by Promotion__c])
	     {
	   	   ag.add(groupedResults);
	     }
       }    
	   for (AggregateResult ar : ag)
	   {
	   	  mapPromoUses.put(String.ValueOf(ar.get('Promotion__c')), Integer.ValueOf(ar.get('numuses')));   	
	   }
	   if(!mapPromoUses.isEmpty() && !Trigger.isInsert)
	   { 
	   	
	   	if(Trigger.isDelete)
	   	{
	   	  for(Promotion__c p:Trigger.old)
	   	  {
	   	  	 if(p.Id != null && mapPromoUses.get(p.Id) != null && mapPromoUses.get(p.Id) > 0)
	   	     {
	   	     	p.addError('You cannot delete this promotion because it has already been used by ' + String.ValueOf(mapPromoUses.get(p.Id) + ' referrals.  The recommendation is to end date it for today and create a new Promotion that starts tomorrow.'));
	   	     }
	   	  }
	   	}
	   	else
	   	{   	
	   	  for(Promotion__c p:Trigger.New)
	      {
	      	System.Debug('Triggering action for '+ p.Id);
	      	//See what has changed.  Allow changes to certain fields only.
	      	Boolean bChangeAllowed = true;
	        if(Trigger.isUpdate && (
	        	    p.At_Stage1__c	 != Trigger.oldMap.get(p.Id).At_Stage1__c
	  			||	p.At_Stage2__c	 != Trigger.oldMap.get(p.Id).At_Stage2__c
	  			||	p.At_Stage3__c      	 != Trigger.oldMap.get(p.Id).At_Stage3__c      
	  			||	p.Expires_after_usage__c	 != Trigger.oldMap.get(p.Id).Expires_after_usage__c
	  			||	p.In_Time_Duration_Length__c	 != Trigger.oldMap.get(p.Id).In_Time_Duration_Length__c
	  			||	p.In_Time_Duration_Unit__c      	 != Trigger.oldMap.get(p.Id).In_Time_Duration_Unit__c      
	  			||	p.Promotion_Type__c	 != Trigger.oldMap.get(p.Id).Promotion_Type__c
	  			||	p.Referee_Payment_Amount1__c	 != Trigger.oldMap.get(p.Id).Referee_Payment_Amount1__c
	  			||	p.Referee_Payment_Amount2__c	 != Trigger.oldMap.get(p.Id).Referee_Payment_Amount2__c
	  			||	p.Referee_Payment_Amount3__c	 != Trigger.oldMap.get(p.Id).Referee_Payment_Amount3__c
	  			||	p.Referee_Payment_Option1__c	 != Trigger.oldMap.get(p.Id).Referee_Payment_Option1__c
	  			||	p.Referee_Payment_Option2__c	 != Trigger.oldMap.get(p.Id).Referee_Payment_Option2__c
	  			||	p.Referee_Payment_Option3__c	 != Trigger.oldMap.get(p.Id).Referee_Payment_Option3__c
	  			||	p.Referral_Payout_on1__c	 != Trigger.oldMap.get(p.Id).Referral_Payout_on1__c
	  			||	p.Referral_Payout_on2__c	 != Trigger.oldMap.get(p.Id).Referral_Payout_on2__c
	  			||	p.Referral_Payout_on3__c	 != Trigger.oldMap.get(p.Id).Referral_Payout_on3__c
	  			||	p.Referrer_Payment_Amount1__c	 != Trigger.oldMap.get(p.Id).Referrer_Payment_Amount1__c
	  			||	p.Referrer_Payment_Amount2__c	 != Trigger.oldMap.get(p.Id).Referrer_Payment_Amount2__c
	  			||	p.Referrer_Payment_Amount3__c	 != Trigger.oldMap.get(p.Id).Referrer_Payment_Amount3__c
	  			||	p.Referrer_Payment_Option1__c	 != Trigger.oldMap.get(p.Id).Referrer_Payment_Option1__c
	  			||	p.Referrer_Payment_Option2__c	 != Trigger.oldMap.get(p.Id).Referrer_Payment_Option2__c
	  			||	p.Referrer_Payment_Option3__c	 != Trigger.oldMap.get(p.Id).Referrer_Payment_Option3__c
	  			||	p.Start_Date__c      	 != Trigger.oldMap.get(p.Id).Start_Date__c      
	  			||	p.State__c	 != Trigger.oldMap.get(p.Id).State__c
	  			||	p.Utility__c	 != Trigger.oldMap.get(p.Id).Utility__c))
	  			{
		           bChangeAllowed = false;
	            }
	
	      	    if(Trigger.isUpdate 
	      	       && bChangeAllowed 
	      	       && p.End_Date__c != Trigger.oldMap.get(p.Id).End_Date__c && p.End_Date__c < Date.today()
	      	       )
	      	    {
	      	       bChangeAllowed = false;
	      	    }     
	      	
	   	     if(p.Id != null && mapPromoUses.get(p.Id) != null && mapPromoUses.get(p.Id) > 0 && !bChangeAllowed)
	   	     {
	   	     	p.addError('You cannot change the promotion values for this promtion because it has already been used by ' + String.ValueOf(mapPromoUses.get(p.Id) + ' referrals.  The recommendation is to create a new Promotion.'));
	   	     }
	       }
	      }   
	   }
	}
}