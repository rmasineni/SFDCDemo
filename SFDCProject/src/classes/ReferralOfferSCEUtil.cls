public with sharing class ReferralOfferSCEUtil {
    public static void ReferralOfferSCEUtil(boolean isinsert,boolean isupdate,List<Service_Contract_Event__c> sceList,Map<id,Service_Contract_Event__c> oldMap,set<id> sceids){
        Set<Id> setSourceContacts = new Set<Id>();
        Map<Id,Set<Id>> mapSourceContactReferrals = new Map<Id, Set<Id>>();
        Map<Id,Set<Id>> mapContactOffers = new Map<Id, Set<Id>>();
        Map<Id, Set<String>> mapReferralIdToStatus = new Map<Id, Set<String>>();
        Map<Id, Set<String>> mapOfferIdToStatus = new Map<Id, Set<String>>();
        List<Referral_Input__c> listUpdateReferralsSCId = new List<Referral_Input__c>();        
        Set<id> scIds=new Set<id>();    
        ReferralService refSvc = new ReferralService();             
        for(Service_Contract_Event__c sce:sceList){
            scIds.add(sce.service_contract__c);
        }
        Map<id,ServiceContract> sceMap=ServiceContractUtil.getServiceContractMap(scIds);
        for(Service_Contract_Event__c sce:sceList){
            if(isinsert&&sceMap.containsKey(sce.service_contract__c)&&(sceMap.get(sce.service_contract__c).TE_Fund_name__c != null&&sceMap.get(sce.service_contract__c).TE_Fund_name__c != '')&&(sce.M1_proof_panel_inverter_delivery__c!=null)
            ||(isUpdate&&sce.M1_proof_panel_inverter_delivery__c!=null&&oldMap.get(sce.id).M1_proof_panel_inverter_delivery__c==null)){
                setSourceContacts.add(sceMap.get(sce.service_contract__c).Contactid);
                if(mapSourceContactReferrals.get(sceMap.get(sce.service_contract__c).Contactid) != null)
                {
                    mapSourceContactReferrals.get(sceMap.get(sce.service_contract__c).Contactid).add(sceMap.get(sce.service_contract__c).Referral__c);
                }
                else
                {
                    mapSourceContactReferrals.put(sceMap.get(sce.service_contract__c).Contactid, new Set<Id>{sceMap.get(sce.service_contract__c).Referral__c});
                }
                //Offer
                if(mapContactOffers.get(sceMap.get(sce.service_contract__c).Contactid) != null)
                {
                    mapContactOffers.get(sceMap.get(sce.service_contract__c).Contactid).add(sceMap.get(sce.service_contract__c).Offer__c);
                }
                else
                {
                    mapContactOffers.put(sceMap.get(sce.service_contract__c).contactid, new Set<Id>{sceMap.get(sce.service_contract__c).Offer__c});
                }
            }            
            if((isinsert&&sceMap.containsKey(sce.service_contract__c)&&sceMap.get(sce.service_contract__c).referral__c!=null&&sce.NTP_Granted__c!=null&&sceMap.get(sce.service_contract__c).TE_Fund_name__c!=null)
            ||(isupdate&&(sce.NTP_Granted__c!=null&&oldMap.get(sce.id).NTP_Granted__c==null&&sceMap.get(sce.service_contract__c).TE_Fund_name__c!=null))){
                if(mapReferralIdToStatus.get(sceMap.get(sce.service_contract__c).referral__c) != null)
                {
                    mapReferralIdToStatus.get(sceMap.get(sce.service_contract__c).referral__c).add('NTP');
                }
                else
                {
                   mapReferralIdToStatus.put(sceMap.get(sce.service_contract__c).referral__c, new Set<String>{'NTP'});  
                }   
            }
            //Offer NTP
            if((isinsert&&sceMap.containsKey(sce.service_contract__c)&&sceMap.get(sce.service_contract__c).offer__c!=null&&sce.NTP_Granted__c!=null&&sceMap.get(sce.service_contract__c).TE_Fund_name__c != null)
            ||(isupdate&&sce.NTP_Granted__c!=null&&oldMap.get(sce.id).NTP_Granted__c==null&&sceMap.get(sce.service_contract__c).TE_Fund_name__c!=null)){
                if(mapOfferIdToStatus.get(sceMap.get(sce.service_contract__c).offer__c) != null)
                {
                    mapOfferIdToStatus.get(sceMap.get(sce.service_contract__c).offer__c).add('NTP');
                }
                else
                {
                   mapOfferIdToStatus.put(sceMap.get(sce.service_contract__c).offer__c, new Set<String>{'NTP'});    
                }   
            }
            if((isinsert&&sceMap.containsKey(sce.service_contract__c)&&sceMap.get(sce.service_contract__c).Referral__c!=null&&sce.M1_proof_panel_inverter_delivery__c != null)
            ||(isupdate&&(sce.M1_proof_panel_inverter_delivery__c!=null&&oldMap.get(sce.id).M1_proof_panel_inverter_delivery__c==null&&sceMap.get(sce.service_contract__c).TE_Fund_name__c != null))){
                if(mapReferralIdToStatus.get(sceMap.get(sce.service_contract__c).referral__c) != null)
                {
                    mapReferralIdToStatus.get(sceMap.get(sce.service_contract__c).referral__c).add('M1');
                }
                else
                {
                   mapReferralIdToStatus.put(sceMap.get(sce.service_contract__c).referral__c, new Set<String>{'M1'});   
                }   
            }
            //Offer M1
            if((isinsert&&sceMap.containsKey(sce.service_contract__c)&&sceMap.get(sce.service_contract__c).Offer__c!=null&&sce.M1_proof_panel_inverter_delivery__c != null)
            ||(isupdate&&(sce.M1_proof_panel_inverter_delivery__c!=null&&oldMap.get(sce.id).M1_proof_panel_inverter_delivery__c==null&&sceMap.get(sce.service_contract__c).TE_Fund_name__c != null))){
                if(mapOfferIdToStatus.get(sceMap.get(sce.service_contract__c).offer__c) != null)
                {
                    mapOfferIdToStatus.get(sceMap.get(sce.service_contract__c).Offer__c).add('M1');
                }
                else
                {
                   mapOfferIdToStatus.put(sceMap.get(sce.service_contract__c).Offer__c, new Set<String>{'M1'}); 
                }   
            }
            if((isinsert&&sceMap.containsKey(sce.service_contract__c)&&sceMap.get(sce.service_contract__c).Referral__c!=null&&sce.M2_proof_substantial_completion__c != null)
            ||(isupdate&&(sce.M2_proof_substantial_completion__c!=null&&oldMap.get(sce.id).M2_proof_substantial_completion__c==null&&sceMap.get(sce.service_contract__c).TE_Fund_name__c != null))){
                if(mapReferralIdToStatus.get(sceMap.get(sce.service_contract__c).referral__c) != null)
                {
                    mapReferralIdToStatus.get(sceMap.get(sce.service_contract__c).referral__c).add('M2');
                }
                else
                {
                   mapReferralIdToStatus.put(sceMap.get(sce.service_contract__c).referral__c, new Set<String>{'M2'});   
                }   
            }
            //Offer M2
            if((isinsert&&sceMap.containsKey(sce.service_contract__c)&&sceMap.get(sce.service_contract__c).Offer__c!=null&&sce.M2_proof_substantial_completion__c != null)
            ||(isupdate&&(sce.M2_proof_substantial_completion__c!=null&&oldMap.get(sce.id).M2_proof_substantial_completion__c==null&&sceMap.get(sce.service_contract__c).TE_Fund_name__c != null))){
                if(mapOfferIdToStatus.get(sceMap.get(sce.service_contract__c).offer__c) != null)
                {
                    mapOfferIdToStatus.get(sceMap.get(sce.service_contract__c).Offer__c).add('M2');
                }
                else
                {
                   mapOfferIdToStatus.put(sceMap.get(sce.service_contract__c).Offer__c, new Set<String>{'M2'}); 
                }   
            }
            if((isinsert&&sceMap.containsKey(sce.service_contract__c)&&sceMap.get(sce.service_contract__c).Referral__c!=null&&sce.PTO__c != null)
            ||(isupdate&&(sce.PTO__c!=null&&oldMap.get(sce.id).PTO__c==null&&sceMap.get(sce.service_contract__c).TE_Fund_name__c != null))){
                if(mapReferralIdToStatus.get(sceMap.get(sce.service_contract__c).referral__c) != null)
                {
                    mapReferralIdToStatus.get(sceMap.get(sce.service_contract__c).referral__c).add('PTO Granted, Facility Active');
                }
                else
                {
                   mapReferralIdToStatus.put(sceMap.get(sce.service_contract__c).referral__c, new Set<String>{'PTO Granted, Facility Active'}); 
                }   
            }
            //Offer PTO
            if((isinsert&&sceMap.containsKey(sce.service_contract__c)&&sceMap.get(sce.service_contract__c).Offer__c!=null&&sce.PTO__c != null)
            ||(isupdate&&(sce.PTO__c!=null&&oldMap.get(sce.id).PTO__c==null&&sceMap.get(sce.service_contract__c).TE_Fund_name__c != null))){
                if(mapOfferIdToStatus.get(sceMap.get(sce.service_contract__c).offer__c) != null)
                {
                    mapOfferIdToStatus.get(sceMap.get(sce.service_contract__c).Offer__c).add('PTO Granted, Facility Active');
                }
                else
                {
                   mapOfferIdToStatus.put(sceMap.get(sce.service_contract__c).Offer__c, new Set<String>{'PTO Granted, Facility Active'});   
                }   
            }
        }
        
        if(!mapSourceContactReferrals.isEmpty())
        {
           Map<id,ServiceContract> scMap=new Map<id,ServiceContract>([select id,(select NTP_Granted__c,M1_proof_panel_inverter_delivery__c,M2_proof_substantial_completion__c,PTO__c from service_contract_events__r) from ServiceContract where contactid in:mapSourceContactReferrals.keySet()]);     
           for(Referral_Input__c ri:[select id, Service_Contract__c, Source_Contact_Id__c                                          
                                       from Referral_Input__c 
                                      where Service_Contract__c != null
                                        and Source_Contact_Id__c in :mapSourceContactReferrals.keySet()
                                        and Service_contract__r.TE_Fund_name__c != null])
           {
              if(scMap.containsKey(ri.Service_Contract__c)&&scMap.get(ri.Service_Contract__c).service_Contract_events__r.size()>0&&scMap.get(ri.Service_Contract__c).service_Contract_events__r[0].M1_proof_panel_inverter_delivery__c != null)
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
              if(scMap.containsKey(ri.Service_Contract__c)&&scMap.get(ri.Service_Contract__c).service_Contract_events__r.size()>0&&scMap.get(ri.Service_Contract__c).service_Contract_events__r[0].M2_proof_substantial_completion__c != null)
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
              if(scMap.containsKey(ri.Service_Contract__c)&&scMap.get(ri.Service_Contract__c).service_Contract_events__r.size()>0&&scMap.get(ri.Service_Contract__c).service_Contract_events__r[0].NTP_Granted__c != null)
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
              if(scMap.containsKey(ri.Service_Contract__c)&&scMap.get(ri.Service_Contract__c).service_Contract_events__r.size()>0&&scMap.get(ri.Service_Contract__c).service_Contract_events__r[0].PTO__c != null)
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
        Map<id,ServiceContract> scMap=new Map<id,ServiceContract>([select id,(select NTP_Granted__c,M1_proof_panel_inverter_delivery__c,M2_proof_substantial_completion__c,PTO__c from service_contract_events__r) from ServiceContract where contactid in:mapContactOffers.keySet()]);
       for(Offer__c Off:[select id,  Customer_Contact__c ,Service_Contract__c                                     
                                   from Offer__c 
                                  where Service_Contract__c != null
                                    and Customer_Contact__c in :mapContactOffers.keySet()
                                    and Service_Contract__r.TE_Fund_name__c != null])
       {
          if(scMap.containsKey(Off.Service_Contract__c)&&scMap.get(Off.Service_Contract__c).service_Contract_events__r.size()>0&&scMap.get(Off.Service_Contract__c).service_contract_events__r[0].M1_proof_panel_inverter_delivery__c != null)
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
          if(scMap.containsKey(Off.Service_Contract__c)&&scMap.get(Off.Service_Contract__c).service_Contract_events__r.size()>0&&scMap.get(Off.Service_Contract__c).service_contract_events__r[0].M2_proof_substantial_completion__c != null)
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
          if(scMap.containsKey(Off.Service_Contract__c)&&scMap.get(Off.Service_Contract__c).service_Contract_events__r.size()>0&&scMap.get(Off.Service_Contract__c).service_contract_events__r[0].NTP_Granted__c != null)
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
          if(scMap.containsKey(Off.Service_Contract__c)&&scMap.get(Off.Service_Contract__c).service_Contract_events__r.size()>0&&scMap.get(Off.Service_Contract__c).service_contract_events__r[0].PTO__c != null)
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
        /*
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
        */
        for(ServiceContract sc:[select id,TE_Fund_name__c,contactid,(select NTP_Granted__c,M1_proof_panel_inverter_delivery__c,M2_proof_substantial_completion__c,PTO__c from service_contract_events__r) from ServiceContract where contactid in:mapSourceToReferrals.keyset()]){
            if(!sc.service_contract_events__r.isempty()&&sc.service_contract_events__r[0].M1_proof_panel_inverter_delivery__c != null && sc.TE_Fund_name__c != null)
            {
               setQualifiedSourceIds.add(sc.contactid);
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
    if(isinsert){
    	Map<id,id> referralSCEIds=new Map<id,id>();
    	for(Service_contract_Event__c sce:sceList){
    		if(sce.referral_Id__c!=null){
    			referralSCEIds.put(sce.referral_Id__c,sce.id);
    		}
    	}
    	if(!referralSCEIds.isempty()){
    	for(Referral_Input__c r:[select id, service_contract_Event__c from Referral_Input__c where Id in :referralSCEIds.keySet()]){
            r.service_contract_Event__c=referralSCEIds.get(r.id);
            listUpdateReferralsSCId.add(r);
        }
    	}
    	if(!listUpdateReferralsSCId.isEmpty()){
    		update listUpdateReferralsSCId;
    	}
    }
    //check for stage change to see if qualifies for Offer payment
    if(!mapOfferIdToStatus.isEmpty())
    {
    	/*
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
        for(ServiceContract sc:[select id,                                          
                                            TE_Fund_name__c,
                                            Contactid,(select NTP_Granted__c,M1_proof_panel_inverter_delivery__c,M2_proof_substantial_completion__c,PTO__c from service_contract_events__r)
                                       from ServiceContract
                                      where Contactid in :mapContactToOffers.keyset()])
        {
            if(!sc.service_contract_events__r.isempty()&&sc.service_contract_events__r[0].M1_proof_panel_inverter_delivery__c != null && sc.TE_Fund_name__c != null)
            {
               setQualifiedContactIds.add(sc.Contactid);
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
        */
        //If map still has values after evaluating the source GA data and removing as applicable
        //then issue the call to the Referral Service method.
        if(!mapOfferIdToStatus.isEmpty())
        {
           refSvc.setOfferStatus(mapOfferIdToStatus, 'Asset');
        }
    }     
    
    }
}