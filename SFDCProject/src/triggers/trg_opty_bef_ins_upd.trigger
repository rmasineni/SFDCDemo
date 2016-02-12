trigger trg_opty_bef_ins_upd on Opportunity (before insert, before update) {

    Integer size = 0;
    Integer counter = 0;
    Map<Id, String> optyReasonMap = new Map<Id, String>();
    Set<Id> opportunityIds = new Set<Id>();
    Set<Id> optyIdsForProposals = new Set<Id>();
    Map<Id,Opportunity> OpportunityMap = new Map<Id,Opportunity>(); //added for 6792 user story
    List<Opportunity> siteAuditScheduledOpptyList = new List<Opportunity>();
    Map<Id, Id> opptyAcctMap = new Map<Id, Id>(); 
    Map<Id, Account> opptyIdAcctMap = new Map<Id, Account>(); 
    BaseScheduling bas=new BaseScheduling();

    Boolean skipValidations = false;
  skipValidations = SkipTriggerValidation.performTriggerValidations();
  if(skipValidations == false){ 
       //update Energy Efficiency Program/Energy Efficiency Amount
      for(Opportunity opptyObj:Trigger.New){
          if(opptyObj.SalesOrganizationName__c== Label.PosigenID){
              if(Trigger.isinsert||(Trigger.isupdate&&Trigger.oldmap.get(opptyObj.id).SalesOrganizationName__c!=opptyObj.SalesOrganizationName__c)){
                  opptyObj.Energy_Efficiency_Program__c=true;
                  opptyObj.Energy_Efficiency_Amount__c=10;
                  
              }
          }
          
      }
         
      for(Opportunity optyObj:Trigger.New)
      {   
          if(optyObj.Opportunity_Division_Custom__c==null||(Trigger.isupdate&&Trigger.oldmap.get(optyObj.id).Division!=optyObj.Division)){
              optyObj.Opportunity_Division_Custom__c=optyObj.Division;
          }           
          //Change code from closed/won to Unqualified(2/19/14)
          if(Trigger.isInsert && 'Unqualified' == optyObj.StageName)
          {
              optyObj.addError(EDPUtil.OPPTY_CLOSED_WON_ERROR);
          }else if(Trigger.isUpdate && 'Unqualified' == optyObj.StageName)
          {
              opportunityIds.add(optyObj.Id);
          }
          
          if(optyObj.Prospect_Id__c == null || optyObj.Prospect_Id__c == ''){
              size++;
          }
          
          if(Trigger.isUpdate){
              //UpdateConstructionOpptyField.VerifyConstrctionDate(Trigger.New, Trigger.oldMap, Trigger.isInsert,Trigger.isUpdate);
            if(optyObj.Scheduled_Construction_Start_Date__c != trigger.oldmap.get(optyObj.Id).Scheduled_Construction_Start_Date__c){
                UpdateConstructionOpptyField.VerifyConstrctionDate(Trigger.New, Trigger.OldMap, Trigger.isInsert, Trigger.isUpdate);
            }
            
              Opportunity oldOpportunityObj = Trigger.oldMap.get(optyObj.Id);
              String reason = '';
              Map<Id, String> resultMap = OpportunityUtil.isUtilityInformationChanged(optyObj, oldOpportunityObj);
              if(resultMap.containsKey(optyObj.Id)){          
              //if((OpportunityUtil.isUtilityInformationChanged(optyObj, oldOpportunityObj, reason))){
                  optyIdsForProposals.add(optyObj.Id);
                  OpportunityUtil.reasonMap.put(optyObj.Id, resultMap.get(optyObj.Id));
                  System.debug('OpportunityUtil.reasonMap: ' + OpportunityUtil.reasonMap);
              }

              if(optyObj.Site_Audit_Scheduled__c != null && optyObj.Site_Audit_Scheduled__c != oldOpportunityObj.Site_Audit_Scheduled__c){
                 siteAuditScheduledOpptyList.add(optyObj);  
                 opptyAcctMap.put(optyObj.AccountId, optyObj.Id);
              }
          }//End isUpdate

          if(Trigger.isInsert && optyObj.Site_Audit_Scheduled__c != null) {
                 siteAuditScheduledOpptyList.add(optyObj);    
                 opptyAcctMap.put(optyObj.AccountId, optyObj.Id);
          }//End isInsert

      }
      
      //Translate Site Audit Site Scheduled date to date with Customer TimeZone. 
          for(Account acct: [select Id, TimeZone__c, HasDaylightSavings__c from Account where id in :opptyAcctMap.keySet()]){
              opptyIdAcctMap.put(opptyAcctMap.get(acct.Id), acct);  
          }
          

          for(Opportunity opp: siteAuditScheduledOpptyList){
              Account acct = opptyIdAcctMap.get(opp.id); 
              Boolean hasDaylightSavings = (acct.HasDaylightSavings__c == 'true') ? true : false;
              String custTimeZone = bas.getCustomerTimeZone(acct.TimeZone__c, hasDaylightSavings);
              System.debug('Time Zone : ' +custTimeZone); 
              opp.Site_Audit_Scheduled_Local__c = bas.getFormattedDatetime(opp.Site_Audit_Scheduled__c, custTimeZone); 
          }  
         // System.debug('Trigger.NewMap: ' + Trigger.NewMap);
         //Comment Auto calculation of usage(BSKY-4086) 
      //OpportunityUtil.calculateMonUsage(trigger.new,trigger.oldMap,trigger.isinsert,trigger.isupdate) ;
  
      List<String> randomNumners = null;
      if(size > 0){
          randomNumners = OpptyUtil.getUniqueProspectNumbers(size);
      }
      if(optyIdsForProposals.size() > 0){
        Map<Id, Map<Id, Proposal__C>> optyProposalmap = ProposalUtil.getActiveProposalsForOpportunities(optyIdsForProposals);
        if(optyProposalmap != null && optyProposalmap.size() > 0){
            for(Id optyId : optyProposalmap.keySet()){
                Map<Id, Proposal__c> activeProposalMap = optyProposalmap.get(optyId);
                Opportunity tempOpportunityObj = Trigger.newmap.get(optyId);
                if(activeProposalMap.size() > 0){
                    if(tempOpportunityObj.Void_Proposals__c == true || OpportunityUtil.eligibleForVoid.contains(tempOpportunityObj.Id)){
                        OpportunityUtil.eligibleForVoid.add(tempOpportunityObj.Id);
                       
                        tempOpportunityObj.Void_Proposals__c = false;
                    }else{
                        //String errormessage = 'Modifying the Contact Information,Utility Information or Home Type will void the active proposals associated with this Opportunity. Select \'Void Proposals\' checkbox to confirm your changes.';
                        String errorMessage = OpportunityUtil.getVoidProposalErroMessage();
                        tempOpportunityObj.adderror(errormessage);              
                    }                   
                }
            }
        }
    }         
      if(opportunityIds != null && !opportunityIds.isEmpty()){
          for(Opportunity optyObj: [Select Id, name, stagename, 
                                          (Select Id, name, Stage__c, Change_Order_Type__c,
                                           Opportunity__c from Proposals__r 
                                           where Stage__c =:EDPUtil.SR_OPS_APPROVED limit 1) 
                                      from Opportunity where Id in :opportunityIds]){
              
              if(optyObj.Proposals__r != null && optyObj.Proposals__r.size() > 0){
                  continue;
              }else{
                  Trigger.Newmap.get(optyObj.Id).addError(EDPUtil.OPPTY_CLOSED_WON_ERROR);
              }
          }
      }
      
      for(Opportunity Oppty:Trigger.new){
          
          if(Trigger.isUpdate && Oppty.Void_Proposals__c == true){
              Oppty.Void_Proposals__c = true;
          }
  
          if((counter < size) && (Oppty.Prospect_Id__c == null || Oppty.Prospect_Id__c == '')){
              Oppty.Prospect_Id__c = randomNumners[counter];
              counter++;
          } 
          /*
          if(Oppty.Offer__c != null && (trigger.isInsert || (trigger.isupdate && Oppty.Offer__c != Trigger.oldMap.get(Oppty.Id).Offer__c))){
            
            List<Offer__c> offerObjList = [select id,Promotion__c from Offer__c where id =: Oppty.Offer__c];
            Offer__c  OfferObj = new Offer__c();
            
            if(offerObjList != null && offerObjList.size() > 0){
              OfferObj = offerObjList[0];
            
            
            system.debug('Offer Object' + OfferObj);
            List<Promotion__c> promoObjList = [Select id, Promotion_Code__c, Name from Promotion__c where id =: OfferObj.Promotion__c limit 1];
  
            if(promoObjList != null && promoObjList.size() > 0){
              Oppty.Offer_Promotion_Name__c = promoObjList[0].id;
            }
            }
         
          }
          */
      }
      Set<id> referralSet=new Set<id>();
      Set<id> OfferSet=new Set<id>();
      for(Opportunity Oppty:Trigger.new){
  
          if(Oppty.Referral__c != null && (trigger.isInsert || (trigger.isupdate && Oppty.Referral__c != Trigger.oldMap.get(Oppty.Id).Referral__c))){
            referralSet.add(oppty.referral__c);
          }
            /*
            List<Referral_Input__c> referralObjList = [select id,Promotion__c from Referral_Input__c where id =: Oppty.Referral__c];
            Referral_Input__c  ReferralObj = new Referral_Input__c();
            
            if(referralObjList != null && referralObjList.size() > 0){
              ReferralObj = referralObjList[0];
            
            
            system.debug('Refferal Object' + ReferralObj);
            List<Promotion__c> promoObjList = [Select id, Promotion_Code__c, Name from Promotion__c where id =: ReferralObj.Promotion__c limit 1];
  
            if(promoObjList != null && promoObjList.size() > 0){
              Oppty.Referral_Promotion_Name__c = promoObjList[0].id;
            }
            }
            }
           */   
           if(Oppty.Offer__c != null && (trigger.isInsert || (trigger.isupdate && Oppty.Offer__c != Trigger.oldMap.get(Oppty.Id).Offer__c))){
              OfferSet.add(oppty.offer__c);
           }    
      }
      if(!referralSet.isempty()){
          Map<id,id> opptyreferralMap=new Map<id,id>();
          for(Referral_Input__c ri:[select id,Promotion__c from Referral_Input__c where id in:referralSet]){
              opptyreferralMap.put(ri.id,ri.promotion__c);
          }
          for(Opportunity Oppty:Trigger.new){
          if(Oppty.Referral__c != null && (trigger.isInsert || (trigger.isupdate && Oppty.Referral__c != Trigger.oldMap.get(Oppty.Id).Referral__c))){
              if(opptyreferralMap.containsKey(oppty.referral__c)){
              Oppty.Referral_Promotion_Name__c = opptyreferralMap.get(oppty.referral__c);
              }   
          }   
          }
      }
      if(!OfferSet.isempty()){
          Map<id,id> opptyOfferMap=new Map<id,id>();
          for(Offer__c offer:[select id,Promotion__c from Offer__c where id in:OfferSet]){
              opptyOfferMap.put(offer.id,offer.promotion__c);
          }
          for(opportunity oppty:trigger.new){
              if(Oppty.Offer__c != null && (trigger.isInsert || (trigger.isupdate && Oppty.Offer__c != Trigger.oldMap.get(Oppty.Id).Offer__c))){
                  if(opptyOfferMap.containsKey(oppty.offer__c)){
                      oppty.Offer_Promotion_Name__c=opptyOfferMap.get(oppty.offer__c);
                  }
              }
          }
      }
    
  }
/*
  if(Trigger.isInsert || Trigger.isUpdate){
        Sf.homeDepotSyncService.handleOpportunitiesTrigger();    
    }*/
   
    
    /*
    Contact contobj = PRMContactUtil.getLoginUserContact();
    for(Opportunity newoppty:Trigger.New){
        if(contObj != null){
            if(contobj.AccountId != null && Trigger.isInsert){
                newoppty.Lead_Gen_Partner__c = contobj.accountId;
                newoppty.Install_Partner__c = contobj.accountId;
                newoppty.Sales_Partner__c = contobj.accountId;
            
            List<Partner_contract__c> PCObjlist = new List<Partner_contract__c>();
            Partner_contract__c PCObj = new Partner_contract__c();
            Id userId = UserInfo.getUserId();
        
            //Install Partner
            PCObjlist = [select id, name, contract_type__c, effective_date__c, Contract_Status__c, expiration_Date__c , Account__c,Account__r.Site from Partner_contract__c where  Account__c =: newOppty.Install_Partner__c and Contract_Status__c = 'Active' and expiration_date__c > today and Contract_Type__c ='Full Service Contract' ];
            system.debug('Partner contract' + PCObjlist);
            if(PCObjlist.size() > 0 && PCObjlist != null){
                PCObj = PCObjlist[0];
                newoppty.EPCPartnerName__c = PCObj.Account__c;
                newoppty.EPCExecutionDate__c = PCObj.Effective_Date__c;
                newoppty.InstallationOffice__c = PCObj.Account__r.Site;
                newoppty.CorporatePartner__c = null;
            }else {
                PCObjlist = [select id, name, contract_type__c, effective_date__c, Contract_Status__c, expiration_Date__c , Account__c ,Account__r.Site from Partner_contract__c where Account__c =: newOppty.Install_Partner__c and Contract_Status__c = 'Active' and expiration_date__c > today and Contract_Type__c ='Installation Contract' ];
                system.debug('Partner contract Lead' + PCObjlist);
                
                if(PCObjlist.size() > 0 && PCObjlist != null){
                    PCObj = PCObjlist[0];
                    newoppty.EPCPartnerName__c = PCObj.Account__c;
                    newoppty.EPCExecutionDate__c = PCObj.Effective_Date__c;
                    newoppty.InstallationOffice__c = PCObj.Account__r.Site;
                    newoppty.CorporatePartner__c = null;
                }
            }
        
            //Lead-Gen Partner
            PCObjlist = [select id, name, contract_type__c, effective_date__c, Contract_Status__c, expiration_Date__c , Account__c,Account__r.Site from Partner_contract__c where  Account__c =: newoppty.Lead_Gen_Partner__c and Contract_Status__c = 'Active' and expiration_date__c > today and Contract_Type__c ='Full Service Contract' ];
            system.debug('Partner contract' + PCObjlist);
            if(PCObjlist.size() > 0 && PCObjlist != null){
                PCObj = PCObjlist[0];
                newoppty.LeadOrganizationName__c = PCObj.Account__c ;
                newoppty.LeadOrganizationOffice__c = PCObj.Account__r.Site;
                newoppty.CorporatePartner__c = null;
            }
        
            //Sales Partner
            PCObjlist = [select id, name, contract_type__c, effective_date__c, Contract_Status__c, expiration_Date__c , Account__c,Account__r.Site from Partner_contract__c where  Account__c =: newoppty.Sales_Partner__c and Contract_Status__c = 'Active' and expiration_date__c > today and Contract_Type__c ='Full Service Contract' ];
            system.debug('Partner contract' + PCObjlist);
            if(PCObjlist.size() > 0 && PCObjlist != null){
                PCObj = PCObjlist[0];
                 newoppty.SalesCellPhone__c = contobj.phone;
                 newoppty.SalesEmail__c = contobj.email;
                 newoppty.SalesOrganizationName__c = PCObj.Account__c ;
                 newoppty.SalesOrgContractExecutionDate__c = PCObj.Effective_Date__c;
                 newoppty.SalesRep__c = userId;
                 newoppty.CorporatePartner__c = null;
            }else {
                PCObjlist = [select id, name, contract_type__c, effective_date__c, Contract_Status__c, expiration_Date__c , Account__c,Account__r.Site from Partner_contract__c where Account__c =: newoppty.Sales_Partner__c and Contract_Status__c = 'Active' and expiration_date__c > today and Contract_Type__c ='Sales Contract' ];
                system.debug('Partner contract sales' + PCObjlist);
                
                if(PCObjlist.size() > 0 && PCObjlist != null){
                    PCObj = PCObjlist[0];
                    newoppty.SalesCellPhone__c = contobj.phone;
                     newoppty.SalesEmail__c = contobj.email;
                     newoppty.SalesOrganizationName__c = PCObj.Account__c ;
                     newoppty.SalesOrgContractExecutionDate__c = PCObj.Effective_Date__c;
                     newoppty.SalesRep__c = userId;
                     newoppty.CorporatePartner__c = null;
                }
            }
        }
        newoppty.Lead_Gen_Partner__c = null;
        newoppty.Install_Partner__c = null;
        newoppty.Sales_Partner__c = null;
        
    }  
        
    }
    */
    
     /* BSKY-6792 logic start */
    If(Trigger.isUpdate)
    {
   //  Map<Id,Opportunity> OpportunityMap = new Map<Id,Opportunity>();
     for(Opportunity oppty : Trigger.new)
     {
      if(((Trigger.oldMap.get(oppty.ID).StageName =='8. Future Prospect' || Trigger.oldMap.get(oppty.ID).StageName =='9. Closed Lost') && (oppty.StageName == '1. Created' ||oppty.StageName == '2. Appointment Process'||oppty.StageName == '3. Proposal Presented to Customer'||oppty.StageName == '4. Verbal Commit')))
      {
     
       OpportunityMap.put(oppty.ID,Oppty);
        system.debug('inside map details--->'+OpportunityMap);
      }
     }
    }
    if(OpportunityMap.size()>0)
    {
      ProjectStatusUpdateClass.OpptyProjectStatUpdate(OpportunityMap);
    }
    /* BSKY-6792 logic End */
    
    
}