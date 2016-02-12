trigger trg_sc_pro_after_insert_update on ServiceContract (after insert, after update) {
    
    Boolean skipValidations = false;
    skipValidations = SkipTriggerValidation.performTriggerValidations();
    if(skipValidations == false){   
        Map<Id,Id> serviceContractToProposal = new Map<Id,Id>();
        Map<Id,Id> scToProp = new Map<Id,Id>(); 
        Map<Id, Id> scOptyMap = new  Map<Id, Id>();
        Set<String> scCancelledStages = new Set<String>();
    scCancelledStages.add('Deal Cancelled');
        scCancelledStages.add('Deal Cancelled due to credit');
    Map<Id, String> scStatusModifiedOptyIds = new Map<Id, String>();
        
        if(Trigger.isinsert || Trigger.isUpdate) {
        
            for(servicecontract sc: Trigger.new){
            
        
                servicecontract oldservicecontract;
                if(Trigger.isUpdate){
                    oldservicecontract = trigger.oldMap.get(sc.Id);
                    System.debug('>>>>> Update1');
                }
                if(sc.Proposal__c != null && (Trigger.isinsert || (Trigger.isUpdate && oldservicecontract.Proposal__c != sc.Proposal__c))){ 
                    serviceContractToProposal.put(sc.Id, sc.Proposal__c);
                    scOptyMap.put(sc.Id, sc.Opportunity__c);
                }
                
                if(sc.Opportunity__c != null && (Trigger.isinsert || (Trigger.isUpdate && oldservicecontract.Opportunity__c != sc.Opportunity__c))){ 
                    scOptyMap.put(sc.Id, sc.Opportunity__c);
                }                
        
        if(oldservicecontract != null && sc.opportunity__c != null){ 
          if(oldservicecontract.status__c != sc.status__c && scCancelledStages.contains(sc.status__c)){
            scStatusModifiedOptyIds.put(sc.Opportunity__c, wfUtil.CANCELLED);
          }else if(oldservicecontract.status__c != sc.status__c && scCancelledStages.contains(oldservicecontract.status__c) 
            && !scCancelledStages.contains(sc.status__c)){
            scStatusModifiedOptyIds.put(sc.Opportunity__c, wfUtil.OPEN);
          }
        }
                    
                if (!Test.isRunningTest() && ServiceContractUtil.skipSCAuditTrail == false){
                    ServiceContractUtil.trackFieldChanges(sc, oldservicecontract);
                }  
            }
            Map<Id, Proposal__c> proposalMp = new Map<Id, Proposal__c>();
            List<Proposal__c> proposalList = new List<Proposal__c>();
            String asBuiltStr = ProposalUtil.AS_BUILT;
            if(serviceContractToProposal != null && !serviceContractToProposal.isEmpty()){
            
               proposalMp = new Map<Id, Proposal__c>([SELECT Id, Service_Contract__c, Proposal_Scenarios__c,Proposal_Source__c, Change_Order_Information__c, Last_Customer_Signed_Proposal__c,Signed__c,Original_Proposal_ID__c,Original_Proposal_ID__r.Last_Customer_Signed_Proposal__c, Original_Proposal_ID__r.signed__c,
                                                       (SELECT  Id,Proposal__c,Guranteed_Output__c,Year__c,Refund_Rate__c From Proposal_Performance_Guarantee__r) FROM Proposal__c WHERE id IN :serviceContractToProposal.values()]);
                  
            }
            
            System.debug('>>>>> serviceContractToProposal Empty' + serviceContractToProposal.isEmpty());
            for(Id scId: serviceContractToProposal.keySet()){
                Id proposalId = serviceContractToProposal.get(scId);
                 if(proposalMp.containsKey(proposalId)){
                   Proposal__c prop = proposalMp.get(proposalId);
                    
                    if(prop.Proposal_Source__c != null && prop.Proposal_Source__c == ProposalUtil.BLACK_BIRD) {
                        if(prop.Last_Customer_Signed_Proposal__c != null ){
                            scToProp.put(scId, Prop.Last_Customer_Signed_Proposal__c);
                        }
                        else if (prop.Change_Order_Information__c != null ) {
                        if (( prop.Proposal_Source__c.equals('BB') && (prop.Change_Order_Information__c.containsIgnoreCase('CUSTOMER_CHANGE_ORDER') || prop.Change_Order_Information__c.containsIgnoreCase('FULL_PROPOSAL')))){

                            scToProp.put(scId, Prop.id);
                        }
                    }    
                  }
                }
                if(proposalMp.containsKey(proposalId)){
                    Proposal__c proposalObj = proposalMp.get(proposalId);
                    proposalObj.Service_Contract__c = scId;
                    proposalList.add(proposalObj);
                }
            }
            
             if(scToProp != null && !scToProp.isEmpty()){
            
                proposalMp.putAll([SELECT Id, Service_Contract__c, Proposal_Scenarios__c,Proposal_Source__c, Change_Order_Information__c, Last_Customer_Signed_Proposal__c,Signed__c,Original_Proposal_ID__c,Original_Proposal_ID__r.Last_Customer_Signed_Proposal__c, Original_Proposal_ID__r.signed__c,
                                                       (SELECT  Id,Proposal__c,Guranteed_Output__c,Year__c,Refund_Rate__c From Proposal_Performance_Guarantee__r) FROM Proposal__c WHERE id IN :scToProp.values()]);
                System.debug('>>>>> ProposalMP' + proposalMp );    
            
            }
            
            
            PerformanceGuaranteeUtil.performanceguaranteeservicecontract(trigger.isInsert,trigger.isupdate,Trigger.new,Trigger.oldMap, serviceContractToProposal, proposalMp);
            PerformanceGuaranteeUtil.performanceGuaranteeServiceContractForBB(trigger.isInsert,trigger.isupdate,Trigger.new,Trigger.oldMap, serviceContractToProposal, proposalMp, scToProp);
         
            if(!proposalList.isEmpty()){
                update proposalList;
            }
                   
        } 
        ServiceContractUtil.processServiceContractPostUpdate(trigger.isInsert, trigger.isUpdate, Trigger.newMap, Trigger.oldmap);  
        if(Trigger.isAfter && ServiceContractUtil.skipSCAuditTrail != true){
            if(Trigger.isUpdate){
            ServiceContractUtil.UpdateDateCancelledSCE(trigger.new,trigger.oldMap);
            }            
            if(checkRecursiveTrigger.SCrunOnce()){
            ReferralOfferUtil.ReferralOfferServiceContract(trigger.isInsert,trigger.isUpdate,trigger.new,trigger.oldMap,trigger.newMap.keyset());
            }
        }
        ServiceContractUtil.insertSCAuditTrail();
        Referral_SC_SalesRepEmailUtil.updateSalesRepEmail(trigger.isInsert,trigger.isUpdate,trigger.new,trigger.oldMap);
        if(scOptyMap != null && !scOptyMap.isEmpty()){
            wfUtil.updateWFProjects(scOptyMap);
        }
    if(scStatusModifiedOptyIds != null && !scStatusModifiedOptyIds.isEmpty()){
      wfUtil.updateWFProjectStatus(scStatusModifiedOptyIds);
        }
        RefferalStatusUpdate.updateSolarInstall(Trigger.new,trigger.oldmap,trigger.isinsert,trigger.isupdate);
    }
    
    //update ContractDB based contact info from ServiceContract
   
    set<String> conIds = new set<String>();
    for(servicecontract sc: Trigger.New){
        If(Trigger.IsInsert|| (Trigger.IsUpdate&& trigger.oldMap.get(sc.Id).ContactId!=trigger.newMap.get(sc.Id).ContactId)){
            if(sc.Agreement_Number__c!=null &&sc.Agreement_Number__c!=''){
            		conIds.add(sc.Agreement_Number__c);
            }
        }
    }
    If(!conIds.isEmpty()){
        system.debug('<<<conIds>>>>>>' +  conIds);
       
       ContractDBUtil.updateContractDBInfo(conIds);
    }

    
    //update milestone information on service contract
   If(Trigger.isUpdate && Trigger.isAfter){
        Map<Id,ServiceContract> MapServiceContract= new  Map<Id,ServiceContract>();
        List<ServiceContract> serviceContractList = new List<ServiceContract>();
        Map<Id,String> OldSceMap =  new  Map<Id,String>();
        Map<Id,String> NewSceMap =  new Map<Id,String>();
      /*for(Service_Contract_Event__c oldSce :[SELECT M0_Terms__c, Service_Contract__c ,id FROM Service_Contract_Event__c where 
                                               Service_Contract__c in:trigger.OldMap.Keyset()]){
                                                   OldSceMap.put(oldSce.Service_Contract__c, oldSce.M0_Terms__c) ;
                                               }
        for(Service_Contract_Event__c newSce :[SELECT M0_Terms__c, Service_Contract__c ,id FROM Service_Contract_Event__c where 
                                               Service_Contract__c in:trigger.NewMap.Keyset()]){
                                                   NewSceMap.put(newSce.Service_Contract__c, newSce.M0_Terms__c) ;
                                               }*/
        
        for(ServiceContract SC: Trigger.new){
            If(SC.Install_Partner_Id__c!= null && SC.Service_Contract_Event__c!=null){
               if(Trigger.newMap.get(sc.Id).M1_Terms__c!= Trigger.oldmap.get(sc.Id).M1_Terms__c || Trigger.newMap.get(sc.Id).M2_Terms__c!= Trigger.oldmap.get(sc.Id).M2_Terms__c || Trigger.newMap.get(sc.Id).M3_Terms__c!= Trigger.oldmap.get(sc.Id).M3_Terms__c ){
                    serviceContractList.add(SC);
                    MapServiceContract.put(SC.Id, SC);
                }
            }
            
        }
        If(!serviceContractList.isEmpty()){
            system.debug('pppp>');
            ServiceContractMilestoneProof.updateMileStoneDetails(serviceContractList,MapServiceContract,trigger.oldMap); 
        }
    }
    
    /* BSKY-6575 user story Logic Start */
    If(Trigger.isUpdate)
    {
        Map<Id,ServiceContract> ServiceContractMap = new Map<Id,ServiceContract>();
        for (ServiceContract sc: Trigger.New) 
        {
            System.debug('>> Deal Canncelled');
            if (Trigger.newMap.get(sc.Id).Status__c != Trigger.oldmap.get(sc.Id).Status__c && sc.Status__c == 'Deal Cancelled' && sc.Canceling_party__c == 'Customer' && !checkRecursive.scIdforSendCancelMail.contains(sc.id)  ) 
            {
                
                ServiceContractMap.put(sc.Id,sc);
                checkRecursive.scIdforSendCancelMail.add(sc.id) ;  
                System.debug('>> ServiceCOntractMpa'+ ServiceContractMap);
            }
        }
        if(ServiceContractMap.size()>0 && !ServiceContractMap.isEmpty())
        {
            SCETriggerClass.CancellationStatus(ServiceContractMap);
        }
    }
    /* BSKY-6575 user story Logic End */ 
    
}