public with sharing class ReferralOfferUtil {
    public static void ReferralOfferServiceContract(boolean isinsert,boolean isupdate,List<ServiceContract> scList,Map<id,ServiceContract> oldMap,set<id> scKeys){
    Map<Id, ServiceContract> mapReferralServiceContract = new Map<Id, ServiceContract>();
    Map<Id, Id> mapOfferServiceContract = new Map<Id, Id>();
    Map<Id, Id> mapServiceContractContact = new Map<Id, Id>();
    Map<Id, Id> mapServiceContractIdConId = new Map<Id, Id>();
    Map<Id, Id> mapServiceContractIdAccountId = new Map<Id, Id>(); 
    Map<Id, Set<String>> mapReferralIdToStatus = new Map<Id, Set<String>>();
    Map<Id, Set<String>> mapOfferIdToStatus = new Map<Id, Set<String>>();
    ReferralService refSvc = new ReferralService(); 
    List<Referral_Input__c> listUpdateReferralsSCId = new List<Referral_Input__c>();
    List<Offer__c> listUpdateOffersSCId = new List<Offer__c>();
    List<Offer__c> listUpdateOffersContactId = new List<Offer__c>();
    List<Referral_Input__c> listUpdateReferralInput = new List<Referral_Input__c>();
    Set<Id> opportunityIds = new Set<Id>();
    Set<id> sce_TE_Keys=new Set<id>();
    Set<String> proposalNames = new Set<String>();
    Map<String, Proposal__C> proposalMap = new Map<String, Proposal__C>();
    Set<Id> setSourceContacts = new Set<Id>();
    Map<Id,Set<Id>> mapSourceContactReferrals = new Map<Id, Set<Id>>();
    Map<Id,Set<Id>> mapContactOffers = new Map<Id, Set<Id>>();
    Map<id,ServiceContract> scMap;
    for(ServiceContract sc:scList){
        if(sc.TE_Fund_Name__c!=null){
            sce_TE_Keys.add(sc.id);
        }
    }
    if(!sce_TE_Keys.isempty()){
        scMap=new Map<id,ServiceContract>([select id,(select id,NTP_Granted__c,M1_proof_panel_inverter_delivery__c,M2_proof_substantial_completion__c,PTO__c from service_contract_events__r) from serviceContract where id in:sce_TE_Keys]);
    }
    for(ServiceContract sc:scList){     
        ServiceContract oldServiceContract;
        if(Trigger.isUpdate){
            oldServiceContract = oldMap.get(sc.Id);
        }
        if(isInsert && sc.Opportunity__c != null){
            opportunityIds.add(sc.Opportunity__c);
        }
        if(sc.Proposal__c != null  
            && (isInsert || (isUpdate &&  oldServiceContract.Proposal__c != sc.Proposal__c))){
            proposalNames.add(sc.Proposal__c);
        }
        
        if(isupdate&&((sc.TE_Fund_Name__c!=null||sc.TE_Fund_Name__c!='')&&(oldMap.get(sc.id).TE_Fund_Name__c==null||oldMap.get(sc.id).TE_Fund_Name__c==''))){
            if(sc.Contactid!=null){
            setSourceContacts.add(sc.Contactid);
            }
            if(mapSourceContactReferrals.get(sc.Contactid) != null)
            {
                mapSourceContactReferrals.get(sc.contactid).add(sc.Referral__c);
            }
            else
            {
                if(sc.Contactid!=null){
                mapSourceContactReferrals.put(sc.Contactid, new Set<Id>{sc.Referral__c});
                }
            }
            //Offer
            if(mapContactOffers.get(sc.Contactid) != null)
            {
                mapContactOffers.get(sc.Contactid).add(sc.Offer__c);
            }
            else
            {
                if(sc.Contactid!=null){
                mapContactOffers.put(sc.Contactid, new Set<Id>{sc.Offer__c});
                }
            }   
        } 
        if((isinsert&&sc.referral__c!=null)||(isupdate&&sc.referral__c!=null&&(oldMap.get(sc.id).referral__c==null||sc.referral__c!=oldMap.get(sc.id).referral__c))){
            mapReferralServiceContract.put(sc.referral__c,sc);
        }
        if((isinsert&&sc.offer__c!=null)||(isupdate&&sc.offer__c!=null&&(oldMap.get(sc.id).offer__c==null||sc.offer__c!=oldMap.get(sc.id).offer__c))){
            mapOfferServiceContract.put(sc.offer__c,sc.id);
        }
        if((isinsert&&sc.contactid!=null&&sc.offer__c!=null)||(isupdate&&sc.contactid!=null&&sc.offer__c!=null&&(oldMap.get(sc.id).contactid==null||sc.offer__c!=oldMap.get(sc.id).contactid))){
            mapServiceContractContact .put(sc.offer__c,sc.contactid);
        }
        if((isinsert&&(sc.contactid!=null||sc.accountid!=null))||(isupdate&&((sc.contactid!=null&&oldMap.get(sc.id).contactid==null)
        ||(sc.contactid!=null&&oldMap.get(sc.id).contactid!=null&&sc.contactid!=oldMap.get(sc.id).contactid)
        ||(sc.accountid!=null&&oldMap.get(sc.id).accountid==null)
        ||(sc.accountid!=null&&oldMap.get(sc.id).accountid!=null&&sc.accountid!=oldMap.get(sc.id).accountid)))){
            mapServiceContractIdConId.put(sc.id,sc.contactid);
            mapServiceContractIdAccountId.put(sc.id,sc.accountid);
        }
        if(isupdate&&(sc.TE_Fund_Name__c!=null&&oldMap.get(sc.id).TE_Fund_Name__c==null&&scMap.containskey(sc.id)&&scMap.get(sc.id).service_contract_events__r.size()>0&&scMap.get(sc.id).service_contract_events__r[0].NTP_Granted__c!=null&&sc.referral__c!=null)){
            if(mapReferralIdToStatus.get(sc.Referral__c) != null)
            {
                mapReferralIdToStatus.get(sc.Referral__c).add('NTP');
            }
            else
            {
               mapReferralIdToStatus.put(sc.Referral__c, new Set<String>{'NTP'});   
            }    
        }
        if(isupdate&&(sc.TE_Fund_Name__c!=null&&oldMap.get(sc.id).TE_Fund_Name__c==null&&scMap.containskey(sc.id)&&scMap.get(sc.id).service_contract_events__r.size()>0&&scMap.get(sc.id).service_contract_events__r[0].NTP_Granted__c!=null&&sc.offer__c!=null)){
            if(mapOfferIdToStatus.get(sc.Offer__c) != null)
            {
                mapOfferIdToStatus.get(sc.Offer__c).add('NTP');
            }
            else
            {
               mapOfferIdToStatus.put(sc.Offer__c, new Set<String>{'NTP'}); 
            }    
        }
         if(isupdate&&(sc.TE_Fund_Name__c!=null&&oldMap.get(sc.id).TE_Fund_Name__c==null&&scMap.containskey(sc.id)&&scMap.get(sc.id).service_contract_events__r.size()>0&&scMap.get(sc.id).service_contract_events__r[0].M1_proof_panel_inverter_delivery__c!=null&&sc.referral__c!=null)){
            if(mapReferralIdToStatus.get(sc.Referral__c) != null)
            {
                mapReferralIdToStatus.get(sc.Referral__c).add('M1');
            }
            else
            {
               mapReferralIdToStatus.put(sc.Referral__c, new Set<String>{'M1'});    
            }    
        }
        if(isupdate&&(sc.TE_Fund_Name__c!=null&&oldMap.get(sc.id).TE_Fund_Name__c==null&&scMap.containskey(sc.id)&&scMap.get(sc.id).service_contract_events__r.size()>0&&scMap.get(sc.id).service_contract_events__r[0].M1_proof_panel_inverter_delivery__c!=null&&sc.offer__c!=null)){
            if(mapOfferIdToStatus.get(sc.Offer__c) != null)
            {
                mapOfferIdToStatus.get(sc.Offer__c).add('M1');
            }
            else
            {
               mapOfferIdToStatus.put(sc.Offer__c, new Set<String>{'M1'});  
            }    
        }
        if(isupdate&&(sc.TE_Fund_Name__c!=null&&oldMap.get(sc.id).TE_Fund_Name__c==null&&scMap.containskey(sc.id)&&scMap.get(sc.id).service_contract_events__r.size()>0&&scMap.get(sc.id).service_contract_events__r[0].M2_proof_substantial_completion__c!=null&&sc.referral__c!=null)){
            if(mapReferralIdToStatus.get(sc.Referral__c) != null)
            {
                mapReferralIdToStatus.get(sc.Referral__c).add('M2');
            }
            else
            {
               mapReferralIdToStatus.put(sc.Referral__c, new Set<String>{'M2'});    
            }    
        }
        if(isupdate&&(sc.TE_Fund_Name__c!=null&&oldMap.get(sc.id).TE_Fund_Name__c==null&&scMap.containskey(sc.id)&&scMap.get(sc.id).service_contract_events__r.size()>0&&scMap.get(sc.id).service_contract_events__r[0].M2_proof_substantial_completion__c!=null&&sc.offer__c!=null)){
            if(mapOfferIdToStatus.get(sc.Offer__c) != null)
            {
                mapOfferIdToStatus.get(sc.Offer__c).add('M2');
            }
            else
            {
               mapOfferIdToStatus.put(sc.Offer__c, new Set<String>{'M2'});  
            }    
        }
         if(isupdate&&(sc.TE_Fund_Name__c!=null&&oldMap.get(sc.id).TE_Fund_Name__c==null&&scMap.containskey(sc.id)&&scMap.get(sc.id).service_contract_events__r.size()>0&&scMap.get(sc.id).service_contract_events__r[0].PTO__c!=null&&sc.referral__c!=null)){
            if(mapReferralIdToStatus.get(sc.Referral__c) != null)
            {
                mapReferralIdToStatus.get(sc.Referral__c).add('PTO Granted, Facility Active');
            }
            else
            {
               mapReferralIdToStatus.put(sc.Referral__c, new Set<String>{'PTO Granted, Facility Active'});  
            }    
        }
        if(isupdate&&(sc.TE_Fund_Name__c!=null&&oldMap.get(sc.id).TE_Fund_Name__c==null&&scMap.containskey(sc.id)&&scMap.get(sc.id).service_contract_events__r.size()>0&&scMap.get(sc.id).service_contract_events__r[0].PTO__c!=null&&sc.offer__c!=null)){
            if(mapOfferIdToStatus.get(sc.Offer__c) != null)
            {
                mapOfferIdToStatus.get(sc.Offer__c).add('PTO Granted, Facility Active');
            }
            else
            {
               mapOfferIdToStatus.put(sc.Offer__c, new Set<String>{'PTO Granted, Facility Active'});    
            }    
        }
    }
    if(!proposalNames.isempty()){
        proposalMap = ProposalUtil.getProposalMapForGenAsset();
        if(!proposalMap.isEmpty()){
            ProposalUtil.updateCreditInformationForChangeOrders(proposalMap);
        }
    }
    Map<Id, Proposal__C> approvedProposalMap = new Map<Id, Proposal__C>();
    if(opportunityIds.size() > 0){
        approvedProposalMap = EDPUtil.getApprovedProposals(opportunityIds);
    }
     if(isInsert && approvedProposalMap.size() > 0){
        Map<id,date> SRSignOffDateMap=new Map<id,date>();
        Map<id,date> CustSignOffDateMap=new Map<id,date>();
        Map<id,date> RevisedSignOffDateMap=new Map<id,date>();
        Set<id> scIds=new Set<id>();
        for(ServiceContract sc:scList)
        {
            if(sc.Opportunity__c != null){
                Proposal__c approvedProposalObj = approvedProposalMap.get(sc.Opportunity__c);
                if(approvedProposalObj != null){
                    if(approvedProposalObj.SR_Signoff__c != null){
                        scIds.add(sc.id);
                        SRSignOffDateMap.put(sc.id,Date.newInstance(approvedProposalObj.SR_Signoff__c.year(),approvedProposalObj.SR_Signoff__c.month(), approvedProposalObj.SR_Signoff__c.day()));
                    }
                    if(approvedProposalObj.Customer_Signoff_Date__c != null){
                        scIds.add(sc.id);
                       CustSignOffDateMap.put(sc.id,Date.newInstance(approvedProposalObj.Customer_Signoff_Date__c.year(),approvedProposalObj.Customer_Signoff_Date__c.month(), approvedProposalObj.Customer_Signoff_Date__c.day()));
                    }
                    if(approvedProposalObj.Revised_SR_Signoff__c != null){
                        scIds.add(sc.id);
                        RevisedSignOffDateMap.put(sc.id, Date.newInstance(approvedProposalObj.Revised_SR_Signoff__c.year(),approvedProposalObj.Revised_SR_Signoff__c.month(), approvedProposalObj.Revised_SR_Signoff__c.day()));
                    }
                }
            }
        }
        if(!scIds.isempty()){
        List<Service_Contract_Event__c> scEventList=new List<Service_Contract_Event__c>();  
        for(Service_Contract_Event__c sce:[select Service_Contract__c, SR_Signoff__c,Customer_Signoff__c,Revised_SR_Signoff__c from Service_Contract_Event__c where Service_Contract__c in:scIds]){
 
                if(SRSignOffDateMap.containsKey(sce.Service_Contract__c)){
                    sce.SR_Signoff__c=SRSignOffDateMap.get(sce.Service_Contract__c);
                }
                if(CustSignOffDateMap.containsKey(sce.Service_Contract__c)){
                    sce.Customer_Signoff__c=CustSignOffDateMap.get(sce.Service_Contract__c);
                }
                if(RevisedSignOffDateMap.containsKey(sce.Service_Contract__c)){
                    sce.Revised_SR_Signoff__c=RevisedSignOffDateMap.get(sce.Service_Contract__c);
                }
            scEventList.add(sce);   
        }
        if(!scEventList.isempty())
        update scEventList;
        }       
    }
    if(!mapSourceContactReferrals.isEmpty())
        {
           Map<id,ServiceContract> sercMap=new Map<id,ServiceContract>([select id,(select NTP_Granted__c,M1_proof_panel_inverter_delivery__c,M2_proof_substantial_completion__c,PTO__c from service_contract_events__r) from ServiceContract where contactid in:mapSourceContactReferrals.keySet()]);       
           for(Referral_Input__c ri:[select id, Service_Contract__c, Source_Contact_Id__c                                          
                                       from Referral_Input__c 
                                      where Service_Contract__c != null
                                        and Source_Contact_Id__c in :mapSourceContactReferrals.keySet()
                                        and Service_contract__r.TE_Fund_name__c != null])
           {
              if(sercMap.containsKey(ri.Service_Contract__c)&&sercMap.get(ri.Service_Contract__c).service_Contract_events__r.size()>0&&sercMap.get(ri.Service_Contract__c).service_Contract_events__r[0].M1_proof_panel_inverter_delivery__c != null)
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
              if(sercMap.containsKey(ri.Service_Contract__c)&&sercMap.get(ri.Service_Contract__c).service_Contract_events__r.size()>0&&sercMap.get(ri.Service_Contract__c).service_Contract_events__r[0].M2_proof_substantial_completion__c != null)
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
              if(sercMap.containsKey(ri.Service_Contract__c)&&sercMap.get(ri.Service_Contract__c).service_Contract_events__r.size()>0&&sercMap.get(ri.Service_Contract__c).service_Contract_events__r[0].NTP_Granted__c != null)
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
              if(sercMap.containsKey(ri.Service_Contract__c)&&sercMap.get(ri.Service_Contract__c).service_Contract_events__r.size()>0&&sercMap.get(ri.Service_Contract__c).service_Contract_events__r[0].PTO__c != null)
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
        Map<id,ServiceContract> sercMap=new Map<id,ServiceContract>([select id,(select NTP_Granted__c,M1_proof_panel_inverter_delivery__c,M2_proof_substantial_completion__c,PTO__c from service_contract_events__r) from ServiceContract where contactid in:mapContactOffers.keySet()]);
       for(Offer__c Off:[select id,  Customer_Contact__c ,Service_Contract__c                                     
                                   from Offer__c 
                                  where Service_Contract__c != null
                                    and Customer_Contact__c in :mapContactOffers.keySet()
                                    and Service_Contract__r.TE_Fund_name__c != null])
       {
          if(sercMap.containsKey(Off.Service_Contract__c)&&sercMap.get(Off.Service_Contract__c).service_Contract_events__r.size()>0&&sercMap.get(Off.Service_Contract__c).service_contract_events__r[0].M1_proof_panel_inverter_delivery__c != null)
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
          if(sercMap.containsKey(Off.Service_Contract__c)&&sercMap.get(Off.Service_Contract__c).service_Contract_events__r.size()>0&&sercMap.get(Off.Service_Contract__c).service_contract_events__r[0].M2_proof_substantial_completion__c != null)
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
          if(sercMap.containsKey(Off.Service_Contract__c)&&sercMap.get(Off.Service_Contract__c).service_Contract_events__r.size()>0&&sercMap.get(Off.Service_Contract__c).service_contract_events__r[0].NTP_Granted__c != null)
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
          if(sercMap.containsKey(Off.Service_Contract__c)&&sercMap.get(Off.Service_Contract__c).service_Contract_events__r.size()>0&&sercMap.get(Off.Service_Contract__c).service_contract_events__r[0].PTO__c != null)
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
    if(!mapReferralServiceContract.isempty()){
        for(Referral_Input__c r:[select id, service_contract__c,Service_Contract_Event__c from Referral_Input__c where Id in :mapReferralServiceContract.keySet()]){
            r.service_contract__c=mapReferralServiceContract.get(r.id).id;
        r.Service_Contract_Event__c=mapReferralServiceContract.get(r.id).Service_Contract_Event__c; 
            listUpdateReferralsSCId.add(r);
        }
    }
    if(!listUpdateReferralsSCId.isempty()){
        update listUpdateReferralsSCId;
    }
    if(!mapOfferServiceContract.isempty()){
        for(Offer__c o:[select id, service_contract__c from offer__c where Id in :mapOfferServiceContract.keySet()]){
            o.service_contract__c=mapOfferServiceContract.get(o.id);
            listUpdateOffersSCId.add(o);
        }
    }
    system.debug('---'+listUpdateOffersSCId);
    if(!listUpdateOffersSCId.isempty()){
        update listUpdateOffersSCId;
    }
    //Customer Update on Offer
    if(!mapServiceContractContact.isEmpty())
    {
        for(Offer__c Offer:[select id, Customer_Contact__c from Offer__c where Id in :mapServiceContractContact.keySet()])
        {
            Offer.Customer_Contact__c = mapServiceContractContact.get(Offer.Id);
            listUpdateOffersContactId.add(Offer);   
        }
    }
    if(!listUpdateOffersContactId.isempty())
    {
         Update listUpdateOffersContactId;
    }
    if(!mapServiceContractIdConId.isEmpty() || !mapServiceContractIdAccountId.isEmpty())
    {
      for(Referral_Input__c r:[select id, Name, Target_Contact_Id__c, Target_Account_Id__c, 
                                    Opportunity__c, Service_Contract__c,
                                    Milestone_1_Status__c, Milestone_2_Status__c, Milestone_3_Status__c
                               from Referral_Input__c 
                              where service_contract__c in :mapServiceContractIdConId.KeySet()
                                 or service_contract__c in :mapServiceContractIdAccountId.KeySet()])
      {
        if(   r.Milestone_1_Status__c == null
           && r.Milestone_2_Status__c == null
           && r.Milestone_3_Status__c == null)
        {
           if(mapServiceContractIdConId.get(r.Service_Contract__c) != null)
           {
              r.Target_Contact_Id__c = mapServiceContractIdConId.get(r.Service_Contract__c);
           }
           if(mapServiceContractIdAccountId.get(r.Service_Contract__c) != null)
           {
               r.Target_Account_Id__c = mapServiceContractIdAccountId.get(r.Service_Contract__c);
           }
           listUpdateReferralInput.add(r);
        }
      }
    }
    if(!listUpdateReferralInput.isempty())
    {
       Update listUpdateReferralInput;
    }
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
        for(ServiceContract sc:[select id,TE_Fund_name__c,contactid,(select NTP_Granted__c,M1_proof_panel_inverter_delivery__c,M2_proof_substantial_completion__c,PTO__c from service_contract_events__r) from ServiceContract where contactid in:mapSourceToReferrals.keyset()]){
            if(sc.service_contract_events__r.size()>0&&sc.service_contract_events__r[0].M1_proof_panel_inverter_delivery__c != null && sc.TE_Fund_name__c != null)
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
        for(ServiceContract sc:[select id,                                          
                                            TE_Fund_name__c,
                                            Contactid,(select NTP_Granted__c,M1_proof_panel_inverter_delivery__c,M2_proof_substantial_completion__c,PTO__c from service_contract_events__r)
                                       from ServiceContract
                                      where Contactid in :mapContactToOffers.keyset()])
        {
            if(sc.service_contract_events__r.size()>0&&sc.service_contract_events__r[0].M1_proof_panel_inverter_delivery__c != null && sc.TE_Fund_name__c != null)
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
        //If map still has values after evaluating the source GA data and removing as applicable
        //then issue the call to the Referral Service method.
        if(!mapOfferIdToStatus.isEmpty())
        {
           refSvc.setOfferStatus(mapOfferIdToStatus, 'Asset');
        }
    }     
    
    }
}