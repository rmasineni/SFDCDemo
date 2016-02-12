/****************************************************************************
Author  : Peter Alexander Mandy (pmandy@sunrunhome.com)
Date    : June 15, 2012
Description: Class to handle referral related activities
*****************************************************************************/
public with sharing class ReferralService {
   // Collections used to store data for processing and calculations
   Promotion__c pd = new Promotion__c();
   Set<Id> setReferralSourceIds = new Set<Id>();
   List<Referral_Input__c> listNewReferrals = new List<Referral_Input__c>();
   List<Promotion__c> listCurrentActivePromotions = new List<Promotion__c>();
   Map<Id, Map<String,List<Datetime>>> mapSourcePromotionHasUsed = new Map<Id, Map<String,List<Datetime>>>();
   Map<Id, Map<String,Datetime>> mapSourcePromotionCanUse = new Map<Id, Map<String,Datetime>>();
   Map<Id, Map<String, Boolean>> mapSourceValidPromotions = new Map<Id, Map<String, Boolean>>();
   Map<String, Integer> mapPromoToTotalUses = new Map<String, Integer>();
   Map<Id, Id> mapSourceToPromo = new Map<Id, Id>();
   
   public void ReferralService(){}   
   //
   //For Leads
   //
   public Map<Id, Id> getMapSourceToPromo(List<Lead> listLeads){
   //
      for(Lead newLead:listLeads)
      {
          system.debug('---this is newlead1--:'+ newLead.Referred_By_Contact__c);  
          if(newLead.Referred_By_Contact__c != null)
         {
            // Build set of source contact ids who are referring people
            // This will be used to determine the promotions for which they qualify
            setReferralSourceIds.add(newLead.Referred_By_Contact__c);
            System.debug('---This is SetReferralSourceIds--:'+ setReferralSourceIds); 
         }        
      }
      // Get all referrals created with source contact the same as those just triggered
      for(Referral_Input__c r:[select id, Source_Account_Id__c, Source_Contact_Id__c, Promotion__c, Promotion__r.Name, createddate from Referral_Input__c where Source_Contact_Id__c in :setReferralSourceIds])
      {
        if(r.Source_Contact_Id__c != null && mapSourcePromotionHasUsed.get(r.Source_Contact_Id__c) != null)
        {
            // Create map of source contacts and which promotions they have used and when
            if(r.Promotion__c != null)
            {
                if(mapSourcePromotionHasUsed.get(r.Source_Contact_Id__c).get(r.Promotion__r.Name) == null)
                {
                    mapSourcePromotionHasUsed.get(r.Source_Contact_Id__c).put(r.Promotion__r.Name, new List<Datetime>{r.createddate});
                }
                else
                {
                   mapSourcePromotionHasUsed.get(r.Source_Contact_Id__c).get(r.Promotion__r.Name).add(r.createddate);                  
                }
            }
        }
        else
        {   if(r.Source_Contact_Id__c != null)
            {
               mapSourcePromotionHasUsed.put(r.Source_Contact_Id__c,new Map<String, List<Datetime>>{r.Promotion__r.Name => new List<Datetime>{r.createddate}});
            }   
        }
      }
      
         //
   // Promotions will eventually be chosen as follows:
   // Promo Code will NOT be passed in (06/11/2012).  Instead it will be translated into a LeadSource
   // We will need to get a list of all LeadSource values that warrant a referral.
   //
   // look up Promotion (from Promotion__c) and make sure it qualifies based on: 
   //   Dates (Start_Date__c and End_Date__c) and
   //   Number of times used (Expires_after_usage__c) per period (In_Time_Duration__c).
   // If code is NULL, or expired, or invalid in any way, revert to the Primary code (Primary_Promotion__c)
   // For now, we simply select "Standard Referral", until the final details are ironed out.   
   //
   
   // Get current active promotions.
   listCurrentActivePromotions = new List<Promotion__c>();
   for(Promotion__c p:[select id, Expires_after_usage__c, In_Time_Duration_Unit__c, in_Time_Duration_Length__c, 
                             Start_Date__c, End_Date__c, Name, Promotion_Code__c,
                             State__c, Utility__c
                         from Promotion__c 
                        where Primary_Promotion__c = false 
                          and Promotion_Type__c = 'Customer'
                          and Start_Date__c <= Today and End_Date__c >= Today
                         order by Total_Amount__c])
   {      
      listCurrentActivePromotions.add(p);
   }         
   //
   // Create maps for total allowed uses for each promo code, 
   // whether it is still valid for use for each source id, and how far back it goes.
   //
   for(Promotion__c pro:listCurrentActivePromotions)
   {
     Integer expAfterUsage = 99999;
     Integer inDurationLength = 1;
     String inDurationUnit = 'Weeks';
     //
     if(pro.Expires_after_usage__c != null)
     {
        expAfterUsage = Integer.ValueOf(pro.Expires_after_usage__c);
        inDurationLength = Integer.ValueOf(pro.in_Time_Duration_Length__c);
        inDurationUnit = pro.In_Time_Duration_Unit__c;
     }
      mapPromoToTotalUses.put(pro.Name, expAfterUsage);
      
      Datetime oldestdate = date.newinstance(1900,1,1);
      //Compare "already have used" against "can be used".      
      // determine the oldest date in the window for calculating number of uses since that date to today.
      if(inDurationUnit == 'Weeks')
      {
          oldestdate = Date.Today().addDays(Integer.ValueOf(-7 * inDurationLength));
      }
      if(inDurationUnit == 'Months')
      {
          oldestdate = Date.Today().addMonths(Integer.ValueOf(-1 * inDurationLength));
      }
      if(inDurationUnit == 'Years')
      {
          oldestdate = Date.Today().addYears(Integer.ValueOf(-1 * inDurationLength));
      }

      for(Id src:setReferralSourceIds)
      {
          // Initialize Map with false and qualify later
          // Mapping source to which promotions are valid for use.
          if(mapSourceValidPromotions.get(src) != null)
          {
            mapSourceValidPromotions.get(src).put(pro.Name, false);
          }
          else
          {
            mapSourceValidPromotions.put(src, new Map<String, Boolean>{pro.Name => false});
          }
          //Set Oldest use date in window for src/promo map.
          if(mapSourcePromotionCanUse.get(src) == null)
          {
             mapSourcePromotionCanUse.put(src, new map<String,Datetime>{pro.Name => oldestdate});      
             System.Debug(src + ' can use ' + pro.Name + ' ' + mapPromoToTotalUses.get(pro.Name) + ' times since ' + oldestdate);   
          }
          else
          {
             mapSourcePromotionCanUse.get(src).put(pro.Name, oldestdate);
             System.Debug(src + ' can use ' + pro.Name + ' ' + mapPromoToTotalUses.get(pro.Name) + ' times since ' + oldestdate);                   
          }
      }                       
    
   }
   //
   // Set Maps to store the validity of each active promotion for each source id 
   // and compare to number of times used thus far by the source. 
   //
   for(Id source:mapSourcePromotionCanUse.keyset())
   {
      for(String promo:mapSourcePromotionCanUse.get(source).keyset())
      {         
          Integer usageCount = 0;
          if(mapSourcePromotionHasUsed.get(source) != null && mapSourcePromotionHasUsed.get(source).get(promo) != null)
          {
             for(Datetime dt:mapSourcePromotionHasUsed.get(source).get(promo))
             {
               if(dt > mapSourcePromotionCanUse.get(source).get(promo))
               {
                 // count the number of times each promo has been used by each source contact
                 // since the earliest date in the window.
                 usageCount++;                  
               }            
             }
          }
          // check if promo has not exceeded the allowed usage.
          // if not, set it as a valid promotion for this source contact.
          if(usageCount < mapPromoToTotalUses.get(promo))
          {
             mapSourceValidPromotions.get(source).put(promo, true);
             Integer iRemaining = (mapPromoToTotalUses.get(promo)-usageCount)+1;
             System.Debug(source + ' has already used ' + promo + ' ' + usageCount + ' times and can use it ' + iRemaining + ' after this usage.');
          }         
          else
          {
            System.Debug(source + ' has already used ' + promo + ' ' + usageCount + ' times and cannot use it again yet.  Picking Primary Referral.');
          }
      }     
   }  
   // Set choice as primary promotion.
   for(Promotion__c promo:[select id, Expires_after_usage__c, In_Time_Duration_Unit__c, in_Time_Duration_Length__c, 
                             Start_Date__c, End_Date__c, Name, Promotion_Code__c,
                             State__c, Utility__c
                             from Promotion__c 
                             where Primary_Promotion__c = true 
                               and Promotion_Type__c = 'Customer'
                               LIMIT 1])
   {
      pd = promo;         
   }    
   for(Id src:setReferralSourceIds)
   {
       mapSourceToPromo.put(src, pd.id);
       System.debug('------This is mapsourceToPromo1-----:'+mapSourceToPromo);
   }
   //
   // If the source can still use a promo code other than standard, 
   // set that as the promo, else let the primary remain as the promo.
   //
   for(Lead newLead: listLeads)
   {
      // Get Promo        
      System.Debug('promo list size: '+listCurrentActivePromotions.size());
      for(Promotion__c promo:listCurrentActivePromotions)
      {
         System.Debug('PROMO: ' + promo.Name);
         Set<String> setAllPromoCodes = new Set<String>();
         if(promo.Promotion_Code__c != null && promo.Promotion_Code__c != '')
         {
            setAllPromoCodes.addAll(promo.Promotion_Code__c.split(';'));
         }
         // Check for State and Utility on Lead and see if there 
         // are specific Promos for those attributes
         // NULL means "Any" not "None", i.e. NULL State means any referral can use that promo
         // as long as it meets the other criteria.
         //
         Set<String> setStates = new Set<String>();
         if(promo.State__c != '' && promo.State__c != null)
         {
            setStates.addAll(promo.State__c.split(';'));
            System.Debug('STATES: ' + setStates);
         }
         Set<String> setUtilities = new Set<String>();
         if(promo.Utility__c != '' && promo.Utility__c != null)
         {
            setUtilities.addAll(promo.Utility__c.split(';'));
            System.Debug('UTILS: ' + setUtilities);
         }
         System.Debug('PROMOCODES: '+setAllPromoCodes);
         System.Debug('lead Promo set to: '+newLead.Promotion_Code__c);
         
         //if(setAllPromoCodes.size() > 0 && setAllPromoCodes.Contains(newLead.Promo_Code__c)) //== promo.Promotion_Code__c)         
         if(   (setStates.size() == 0 || setStates.Contains(newLead.State))
            && (setUtilities.size() == 0 || setUtilities.Contains(newLead.Utility_Company__c))
            && (setAllPromoCodes.size() == 0 || newLead.Promotion_Code__c == null || newLead.Promotion_Code__c == '' 
                || (setAllPromoCodes.size() > 0 && setAllPromoCodes.Contains(newLead.Promotion_Code__c))
                //|| (newLead.Promotion_Code__c != null && newLead.Promotion_Code__c != '' && setAllPromoCodes.size() > 0 && !setAllPromoCodes.Contains(newLead.Promotion_Code__c)))
                )
            )
         {
            System.Debug('Qualified for promo: ' + promo.Name);
            //Since Promos return in order of least to greatest, the final 
            //and greatest qualifying one will be pushed to the map.    
                        
             if(mapSourceValidPromotions.get(newLead.Referred_By_Contact__c) != null
                && mapSourceValidPromotions.get(newLead.Referred_By_Contact__c).get(promo.Name) != null
                && mapSourceValidPromotions.get(newLead.Referred_By_Contact__c).get(promo.Name))
             {
                 //pd = promo;
                mapSourceToPromo.put(newLead.Referred_By_Contact__c, promo.id);
                System.Debug('Referred By: ' + newLead.Referred_By_Contact__c + ' using promo: ' + promo.Name);
             }
         }
      }      
   }
        
   return mapSourceToPromo;
      
   }
   
   // For updating the referred by contact if changed.
   public void updateReferralSource(Map<Id, Id> mapReferralToNewSource)
   {
       List<Referral_Input__c> listReferralUpdates = new List<Referral_Input__c>();
       Map<id,ServiceContract> SCReferralMap=new Map<id,ServiceContract>();   
       for(ServiceContract sc:[Select id,contactid,service_contract_event__c from ServiceContract where Contactid in:mapReferralToNewSource.values() order by createddate desc]){
        SCReferralMap.put(sc.contactid,sc);
       }      
       for(Referral_Input__c r:[select Id, Source_Contact_Id__c from Referral_Input__c where Id in :mapReferralToNewSource.KeySet()])
       {
           r.Source_Contact_Id__c = mapReferralToNewSource.get(r.Id);
           if(SCReferralMap.containsKey(r.Source_Contact_Id__c)){
            r.Service_Contract_RR__c=SCReferralMap.get(r.Source_Contact_Id__c).id;
            r.Service_Contract_Event_RR__c=SCReferralMap.get(r.Source_Contact_Id__c).service_contract_event__c;             
           }
           listReferralUpdates.add(r);
       }
       if(listReferralUpdates.size() > 0)
       {
          Update listReferralUpdates;
       }
   }
   // For deleting the referral if the referred by contact is removed from the lead.
   public void deleteReferral(Set<Id> setReferralId)
   {
      List<Referral_Input__c> listReferralDeletions = new List<Referral_Input__c>();
      for(Referral_Input__c r: [select Id, Name from Referral_Input__c where id in :setReferralId])
      {
        listReferralDeletions.add(r);
        System.Debug('request to delete: ' + r.Name);
      }
      if(listReferralDeletions.size() > 0)
      {
        System.Debug('deleting...');
        try{
              delete listReferralDeletions;
        }catch(DmlException e){
            System.Debug('ERROR DELETING: ' + e.getMessage());
        }
      }
   }
   
   // For creating the referral if the lead's referred by contact is set.
   public Referral_Input__c createReferral(Lead newLead, List<Lead> listLeads, Map<Id, Id> mapSourcePromo){
         Referral_Input__c newReferral = new Referral_Input__c();
         
         //if(getMapSourceToPromo(listLeads).get(newLead.Referred_By_Contact__c) != null)
         //{
         try{
            newReferral.Promotion__c = mapSourcePromo.get(newLead.Referred_By_Contact__c);
            }
         catch(Exception e){
            newReferral.Promotion__c = [select id, Expires_after_usage__c, In_Time_Duration_Unit__c, in_Time_Duration_Length__c, 
                             Start_Date__c, End_Date__c, Name, Promotion_Code__c,
                             State__c, Utility__c
                             from Promotion__c 
                             where Primary_Promotion__c = true 
                               and Promotion_Type__c = 'Customer'
                               LIMIT 1].id;
             
         }
         //}         
         newReferral.Lead__c = newLead.Id;
         //
         newReferral.Referral_Status__c='Solar Qualification In-progress';
         newReferral.Target_Account_Name__c = newLead.Company;
         newReferral.Target_Address_Street__c = newLead.Street;
         newReferral.Target_Address_City__c = newLead.City;
         newReferral.Target_Address_State__c = newLead.State;
         newReferral.Target_Address_Postal_Code__c = newLead.PostalCode;
         newReferral.Target_Address_Country__c = newLead.Country;
         newReferral.Target_Contact_Salutation__c = newLead.Salutation;
         newReferral.Target_Contact_First_Name__c = newLead.FirstName;
         newReferral.Target_Contact_Last_Name__c = newLead.LastName;         
         newReferral.Target_Contact_Email__c = newLead.Email;
         newReferral.Target_Phone_Number__c = newLead.Phone;         
         newReferral.Source_Account_Id__c = newLead.Referred_By__c;
         newReferral.Source_Contact_Id__c = newLead.Referred_by_Contact__c;
         newReferral.Source_Account_Name__c = newLead.Referred_by_Account_Name__c;           
         newReferral.Source_Address_Street__c = newLead.Referred_by_Street__c;
         newReferral.Source_Address_City__c = newLead.Referred_by_City__c;
         newReferral.Source_Address_State__c = newLead.Referred_by_State__c;
         newReferral.Source_Address_Postal_Code__c = newLead.Referred_by_Postal_Code__c;
         newReferral.Source_Address_Country__c = newLead.Referred_by_Country__c;
         newReferral.Source_Contact_Salutation__c = newLead.Referred_by_Contact_Salutation__c;
         newReferral.Source_Contact_First_Name__c = newLead.Referred_by_Contact_First_Name__c;
         newReferral.Source_Contact_Last_Name__c = newLead.Referred_by_Contact_Last_Name__c;         
         newReferral.Source_Contact_Email__c = newLead.Referred_by_Contact_Email__c;
         newReferral.Source_Phone_Number__c = newLead.Referred_by_Contact_Phone__c;
         return newReferral;
   }
   
public Map<Id, String> RetroValidation(List <Referral_Input__c> listRef)
{
    // For now, ONLY check the Source Contact's Gen Asset and the Gen Asset on the Referral (TARGET)
    // to see if the TE Fund is Set.  If this is NULL, Oracle will not be able to process for payment.
    // We do not want to check other qualifications at this time, because the breadth of this is large.
    // Meaning, we would need to check each referral against it's promotion and then the stage at which
    // each may qualify and see if it has met that qualification yet.
    // Peter Alexander Mandy pmandy@sunrunhome.com 08202012
    Set<Id> setSourceContactId = new Set<Id>();
    Map<Id, Boolean> mapSourceQual = new Map<Id, Boolean>();
    Set<Id> setTargetGAId = new Set<Id>();
    Set<Id> setPromoId = new Set<Id>();
    Map<Id, String> mapReferralToError = new Map<Id, String>();
    for(Referral_Input__c r:listRef)
    { 
        setSourceContactId.add(r.Source_Contact_Id__c);
        setPromoId.add(r.Promotion__c);
    }     
    return mapReferralToError;
}  
 public Map<id,ServiceContract> ServiceContractContactMap(Set<id> contactIds){
    Map<id,ServiceContract> ServContContactMap=new Map<id,ServiceContract>();
    for(ServiceContract sc:[Select id,contactid,service_contract_event__c from ServiceContract where Contactid in:contactIds order by createddate desc]){
        ServContContactMap.put(sc.contactid,sc);
       }
    return ServContContactMap;
 }
 public Map<Id, String> RetroValidationNew(List <Referral_Input__c> listRef){
    Set<Id> setSourceContactId = new Set<Id>();
    Map<Id, Boolean> mapSourceQual = new Map<Id, Boolean>();
    Set<Id> setTargetSCId = new Set<Id>();
    Set<Id> setPromoId = new Set<Id>();
    Map<Id, String> mapReferralToError = new Map<Id, String>();
    for(Referral_Input__c r:listRef)
    { 
        setSourceContactId.add(r.Source_Contact_Id__c);
        if(r.Service_Contract__c != null){setTargetSCId.add(r.Service_Contract__c);}
        setPromoId.add(r.Promotion__c);
    }
    //Check Source's Service Contract to see if it allows for qualification
    for(ServiceContract sc:[select id, TE_Fund_name__c, contactid
                                   from ServiceContract 
                                  where contactid in :setSourceContactId
                                     or Id in :setTargetSCId
                                     order by contactid, TE_Fund_name__c])
    {
        if((sc.TE_Fund_name__c == null || sc.TE_Fund_name__c == '') && setTargetSCId.Contains(sc.Id))
        {
           if(setTargetSCId.Contains(sc.Id))
           {
              mapReferralToError.put(sc.Id, 'Cannot qualify for payment yet, Target Contact\'s Service Contract has null TE Fund Name.');
           }
        }
        //
        if(setSourceContactId.Contains(sc.contactid) && (sc.TE_Fund_name__c == null || sc.TE_Fund_name__c == ''))
        {
            mapReferralToError.put(sc.contactid, 'Cannot qualify for payment yet, Source Contact\'s Service Contract has null TE Fund Name.');
        }   
        if(mapReferralToError.get(sc.contactid) != null && setSourceContactId.Contains(sc.contactid) && sc.TE_Fund_name__c != null && sc.TE_Fund_name__c != '')
        {
            mapReferralToError.remove(sc.contactid);
        }           
    }       
    return mapReferralToError;  
 }  
// For setting the referral status for respective payouts if the criteria have been met.
public void setReferralStatus(Map<Id, Set<String>> mapRefToStatus, String objectName)
{
    //check to see if referral is tied to a promotion that warrants payment at stage for object triggered.
       List<Referral_Input__c> listUpdateReferrals = new List<Referral_Input__c>();
       for(Referral_Input__c r:[select id, //Status__c, 
                                       Promotion__r.Referral_Payout_on3__c,
                                       Promotion__r.Referral_Payout_on2__c,
                                       Promotion__r.Referral_Payout_on1__c, 
                                       Promotion__r.At_Stage3__c, 
                                       Promotion__r.At_Stage2__c, 
                                       Promotion__r.At_Stage1__c,
                                       Milestone_1_Status__c,
                                       Milestone_2_Status__c,
                                       Milestone_3_Status__c
                                  from Referral_Input__c
                                 where Id in :mapRefToStatus.KeySet()
                                   and (   Promotion__r.Referral_Payout_on1__c = :objectName
                                        or Promotion__r.Referral_Payout_on2__c = :objectName
                                        or Promotion__r.Referral_Payout_on3__c = :objectName
                                        )])
       {
        System.Debug('Found a record to update: ' + r.id + ' for ' + objectName + ' with ' + mapRefToStatus.get(r.id));
           Boolean bUpdate = false;
           if(r.Promotion__r.Referral_Payout_on1__c == objectName && mapRefToStatus.get(r.id).Contains(r.Promotion__r.At_Stage1__c) && r.Milestone_1_Status__c == null)
           {
              System.Debug('Matched Milestone 1');
              r.Milestone_1_Status__c = Label.ReferralReadyForPayment;
              bUpdate = true;
              //listUpdateReferrals.add(r);           
           }        
           if(r.Promotion__r.Referral_Payout_on2__c == objectName && mapRefToStatus.get(r.id).Contains(r.Promotion__r.At_Stage2__c) && r.Milestone_2_Status__c == null)
           {
              System.Debug('Matched Milestone 2');
              r.Milestone_2_Status__c = Label.ReferralReadyForPayment;
              bUpdate = true;
              //listUpdateReferrals.add(r);           
           }           
           if(r.Promotion__r.Referral_Payout_on3__c == objectName && mapRefToStatus.get(r.id).Contains(r.Promotion__r.At_Stage3__c) && r.Milestone_3_Status__c == null)
           {
              System.Debug('Matched Milestone 3');
              r.Milestone_3_Status__c = Label.ReferralReadyForPayment;
              bUpdate = true;                      
           }
           if(bUpdate)
           {
              listUpdateReferrals.add(r);
           }           
       }
       if(listUpdateReferrals.size() > 0)
       {
          update listUpdateReferrals;
       }
}

public void setOfferStatus(Map<Id, Set<String>> mapOffToStatus, String objectName)
{
    //check to see if referral is tied to a promotion that warrants payment at stage for object triggered.
       List<Offer__c> listUpdateOffers = new List<Offer__c>();
       for(Offer__c Offer:[select id, //Status__c, 
                                       Promotion__r.Referral_Payout_on3__c,
                                       Promotion__r.Referral_Payout_on2__c,
                                       Promotion__r.Referral_Payout_on1__c, 
                                       Promotion__r.At_Stage3__c, 
                                       Promotion__r.At_Stage2__c, 
                                       Promotion__r.At_Stage1__c,
                                       Offer_Payout_1_Status__c,
                                       Offer_Payout_2_Status__c,
                                       Offer_Payout_3_Status__c
                                  from Offer__c
                                 where Id in :mapOffToStatus.KeySet()
                                   and (   Promotion__r.Referral_Payout_on1__c = :objectName
                                        or Promotion__r.Referral_Payout_on2__c = :objectName
                                        or Promotion__r.Referral_Payout_on3__c = :objectName
                                        )])
       {
        System.Debug('Found a record to update: ' + Offer.id + ' for ' + objectName + ' with ' + mapOffToStatus.get(Offer.id));
           Boolean bUpdate = false;
           if(Offer.Promotion__r.Referral_Payout_on1__c == objectName && mapOffToStatus.get(Offer.id).Contains(Offer.Promotion__r.At_Stage1__c) && Offer.Offer_Payout_1_Status__c == null)
           {
              System.Debug('Matched Milestone 1');
              Offer.Offer_Payout_1_Status__c = Label.ReferralReadyForPayment;
              bUpdate = true;
              //listUpdateReferrals.add(r);           
           }        
           if(Offer.Promotion__r.Referral_Payout_on2__c == objectName && mapOffToStatus.get(Offer.id).Contains(Offer.Promotion__r.At_Stage2__c) && Offer.Offer_Payout_2_Status__c == null)
           {
              System.Debug('Matched Milestone 2');
              Offer.Offer_Payout_2_Status__c = Label.ReferralReadyForPayment;
              bUpdate = true;
              //listUpdateReferrals.add(r);           
           }           
           if(Offer.Promotion__r.Referral_Payout_on3__c == objectName && mapOffToStatus.get(Offer.id).Contains(Offer.Promotion__r.At_Stage3__c) && Offer.Offer_Payout_3_Status__c == null)
           {
              System.Debug('Matched Milestone 3');
              Offer.Offer_Payout_3_Status__c = Label.ReferralReadyForPayment;
              bUpdate = true;                      
           }
           if(bUpdate)
           {
              listUpdateOffers.add(Offer);
           }           
       }
       if(listUpdateOffers.size() > 0)
       {
          update listUpdateOffers;
       }
}
   
}