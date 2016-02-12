trigger trg_proposal_after_insert on Proposal__c (after insert, after update) {
  Boolean skipValidations = false;
  skipValidations = SkipTriggerValidation.performTriggerValidations();
  if(skipValidations == false){  
    
    try{

        Set<Id> optyIdsForNewProposal = new Set<Id>(); 
        Set<Id> optyIdsForCustOffer = new Set<Id>();
        Set<Id> optyIdsModifiedCustOffer = new Set<Id>();
        Set<Id> CustOfferIds = new Set<Id>();
        Map<Id, Id> optyProposalMap = new  Map<Id, Id>();
        Map<Id, String> projectTypeMap = new Map<Id, String>(); 
        Map<Id, Set<Id>> optyProposalMap2 = new Map<Id, Set<Id>>();
    
		Map<String, Partners_For_Proposal_Upload__c> partnersForProposalUpload = Partners_For_Proposal_Upload__c.getAll();
		Map<Id, Id> opportunityToSalesPartner = new Map<Id, Id>();
		Map<Id, Id> opportunityToInstallPartner = new Map<Id, Id>();
		String salesPartnerId = (Trigger.new[0].Sales_Partner__c != null) ? Trigger.new[0].Sales_Partner__c + '' : '';
		if( (Trigger.new[0].Mode_Name__c != null && Trigger.new[0].Mode_Name__c == 'Sungevity - Bulk Load Only')){
        	//Code changes for Bob's project
		}else{
			
			Set<Id> signedProposalIds = new Set<Id>();
            Map<Id, Id> proposalToGenAssetMap = new Map<Id, Id>();
            Map<Id, Proposal__c> scProposalMap = new Map<Id, Proposal__c>();
            Map<Id, Id> proposalToOptyMap = new Map<Id, Id>();
            Map<Id, Proposal__C> creditProposalMap = new Map<Id, Proposal__C>();
            Map<Id, Set<Id>> proposalTreeMap = new Map<Id, Set<Id>>();
            Map<Id, Set<Id>> opportunityProposalMap = new Map<Id, Set<Id>>(); 
            Map<Id, Proposal__c> newNodeProposalMap = new Map<Id, Proposal__c>();
            Map<Id, Proposal__c> submittedNodeMap = new Map<Id, Proposal__c>();
            Map<Id, String> signedProposalMap = new Map<Id, String>();
            Set<Id> ultimateProposalIds = new Set<Id>();
            for(Proposal__c proposalObj: Trigger.new){
                if(Trigger.isInsert){
                    if(proposalObj.Proposal_Source__c != null 
                        && proposalObj.Proposal_Source__c == ProposalUtil.BLACK_BIRD 
                        && proposalObj.Original_Proposal_ID__c != null){
                        newNodeProposalMap.put(proposalObj.Id, proposalObj);
                        String signedRootId = ProposalUtil.getSignedRootId(proposalObj, true);
                        if(signedRootId != null && signedRootId != ''){
                            signedProposalMap.put(proposalObj.Id, signedRootId);
                        }
                    }
                    
                    if(proposalObj.Original_Proposal_ID__c == null){
                    	Set<Id> tempIds = optyProposalMap2.containsKey(proposalObj.Opportunity__c) ? optyProposalMap2.get(proposalObj.Opportunity__c) : new Set<Id>();
                    	tempIds.add(proposalObj.Id);
                    	optyProposalMap2.put(proposalObj.Opportunity__c, tempIds);
                    }
				}

				if(trigger.isInsert || (trigger.isUpdate && trigger.oldmap.get(proposalObj.id).Opportunity__c != proposalObj.Opportunity__c)){
	              	optyIdsForNewProposal.add(proposalObj.opportunity__c);
					Set<Id> tempIds = optyProposalMap2.containsKey(proposalObj.Opportunity__c) ? optyProposalMap2.get(proposalObj.Opportunity__c) : new Set<Id>();
					tempIds.add(proposalObj.Id);
					optyProposalMap2.put(proposalObj.Opportunity__c, tempIds);
	            }
        
				Proposal__c oldProposalObj;
                if(Trigger.isUpdate){
                    oldProposalObj = Trigger.oldMap.get(proposalObj.Id);
          			if(oldProposalObj.Opportunity__c != proposalObj.Opportunity__c){
                		optyIdsForCustOffer.add(proposalObj.Opportunity__c);
                		optyIdsForCustOffer.add(oldProposalObj.Opportunity__c);
              		}

          			if(oldProposalObj.Customer_Offer__c != proposalObj.Customer_Offer__c &&  proposalObj.Customer_Offer__c == true){
						CustOfferIds.add(proposalObj.id);
						optyIdsForCustOffer.add(proposalObj.opportunity__c);
              		}else if(oldProposalObj.Customer_Offer__c != proposalObj.Customer_Offer__c &&  proposalObj.Customer_Offer__c == false){
						optyIdsModifiedCustOffer.add(proposalObj.opportunity__c);
					}
          
					System.debug('proposalObj.signed__c: ' + proposalObj.signed__c);
					if((oldProposalObj.signed__c != proposalObj.signed__c &&  proposalObj.signed__c == true) 
						|| (oldProposalObj.Create_Workflow_Project__c != proposalObj.Create_Workflow_Project__c &&  proposalObj.Create_Workflow_Project__c == true) 
						|| (proposalObj.Proposal_Source__c != ProposalUtil.BLACK_BIRD && oldProposalObj != null && oldProposalObj.Stage__c != proposalObj.Stage__c 
						&& proposalObj.Stage__c == EDPUtil.SUBMITTED)){
					    //TODO: 
					    System.debug('proposalObj.Opportunity_Install_Partner__c: ' + proposalObj.Opportunity_Install_Partner__c);
					    System.debug('proposalObj.Opportunity_Install_Branch__c: ' + proposalObj.Opportunity_Install_Branch__c);
					    if(wfUtil.eligibleForWFProject(proposalObj.Opportunity_Install_Partner__c, proposalObj.Opportunity_Install_Branch__c)){
					      optyProposalMap.put(proposalObj.Opportunity__c, proposalObj.Id);
					      String projectType = (proposalObj.install_partner__c == System.Label.Sunrun_Inc_Id) ? 'Direct' : 'Channel' ;
					      projectTypeMap.put(proposalObj.Opportunity__c, projectType);
					    }
					}
					System.debug('projectTypeMap: ' + projectTypeMap);
				}
                
                if(proposalObj.Proposal_Source__c != ProposalUtil.BLACK_BIRD && proposalObj.Install_Partner__c != null && (Trigger.isInsert || 
                    (oldProposalObj != null && oldProposalObj.Install_Partner__c != proposalObj.Install_Partner__c))){
                    opportunityToInstallPartner.put(proposalObj.Opportunity__c, proposalObj.Install_Partner__c);
                }
                if(proposalObj.Proposal_Source__c != ProposalUtil.BLACK_BIRD && proposalObj.Sales_Partner__c != null && (Trigger.isInsert || 
                    (oldProposalObj != null && oldProposalObj.Sales_Partner__c != proposalObj.Sales_Partner__c))){
                    opportunityToSalesPartner.put(proposalObj.Opportunity__c, proposalObj.Sales_Partner__c);
                }
            }            
            
            if(Trigger.isInsert && !newNodeProposalMap.isEmpty()){
                ProposalUtil.processNewlyCreatedBBProposals(newNodeProposalMap, signedProposalMap, false, false);
            }
      
			if(optyIdsModifiedCustOffer != null && !optyIdsModifiedCustOffer.isEmpty()){
				Set<Id> optyIdsWithCustOffer = ProposalUtil.getoptyIdsWithCustOffer(optyIdsModifiedCustOffer);
				Proposal__c oldProposalObj;
                if(Trigger.isUpdate){
					for(Proposal__c proposalObj: Trigger.new){
						oldProposalObj = Trigger.oldMap.get(proposalObj.Id);
						if(oldProposalObj.Customer_Offer__c != proposalObj.Customer_Offer__c 
							&&  proposalObj.Customer_Offer__c == false && !optyIdsWithCustOffer.contains(proposalObj.opportunity__c)){
							proposalObj.addError(SunrunErrorMessage.getErrorMessage('ERROR_000031').error_message__c); 
						}
					}
				}
			}
			
			System.debug('optyProposalMap2: ' + optyProposalMap2);
			if(!optyProposalMap2.isEmpty() && !Test.isRunningTest()){
				ProposalUtil.copySRAttachmentsToProposal(optyProposalMap2);
			}
			
            Map<Id, ServiceContract> modifiedServiceContractMap = new Map<Id, ServiceContract>();
            Set<Id> VoidProposalId = new Set <Id>();
            Set<Id> contractOptyIds = new Set <Id>();
            Set<Id> pendingServiceContractProposalIds = new Set <Id>(); 
            Set<Id> pendingServiceContractOptyIds = new Set <Id>(); 
            Set<Id> srApprovedProposalIds = new Set <Id>(); 
            Set<Id> srApprovedOptyIds = new Set <Id>();
            Map<Id, Id> srApprovedProposalOptyMap = new Map<Id, Id>(); 
            if(Trigger.isupdate){
                Set<Id> processSignedProposals = new Set<Id>();
    
                Set<String> inactiveProposalStages = new set<String>();
                inactiveProposalStages.add(ProposalUtil.ACCOUNT_ADDRESS_CHANGE);  
                inactiveProposalStages.add(ProposalUtil.CONTACT_NAME_CHANGE);
                inactiveProposalStages.add(ProposalUtil.OPPORTUNITY_CHANGE);
                inactiveProposalStages.add(ProposalUtil.UTILITY_CHANGE); 
                inactiveProposalStages.add(ProposalUtil.MONTHLY_USAGE_CHANGE);
                for(Proposal__c proposalObj: Trigger.new){
                    Proposal__c oldProposalObj = Trigger.oldMap.get(proposalObj.Id);
                    if (proposalobj.Stage__c != null && proposalobj.Stage__c.equals('Voided')
                        && proposalobj.Status_Reason__c != null && proposalobj.Status_Reason__c != ''  
                        && inactiveProposalStages.contains(proposalobj.Status_Reason__c.touppercase())){    
                        VoidProposalId.add(proposalobj.id);
                        contractOptyIds.add(proposalobj.Opportunity__c);
                    }
                    
                    if(oldProposalObj != null && oldProposalObj.Signed__c != proposalObj.Signed__c && proposalObj.Signed__c == true){
                        contractOptyIds.add(proposalobj.Opportunity__c);
                        pendingServiceContractProposalIds.add(proposalobj.id);
                        pendingServiceContractOptyIds.add(proposalobj.Opportunity__c);
                        
                    }
                    
                    if(oldProposalObj != null && oldProposalObj.Stage__c != proposalObj.Stage__c && proposalObj.Stage__c == EDPUtil.SR_OPS_APPROVED){
                        contractOptyIds.add(proposalobj.Opportunity__c);
                        srApprovedProposalIds.add(proposalobj.id);
                        srApprovedOptyIds.add(proposalobj.Opportunity__c);
                        srApprovedProposalOptyMap.put(proposalobj.id, proposalobj.Opportunity__c);
                    }
                    
                    if(proposalObj.Generation_Asset__c != null || proposalObj.Service_Contract__c != null) 
                        if((proposalObj.Generation_Asset__c != oldProposalObj.Generation_Asset__c)
                            || (proposalObj.Service_Contract__c != oldProposalObj.Service_Contract__c)
                            || (proposalObj.Customer_SignOff_Date__c != oldProposalObj.Customer_SignOff_Date__c 
                                && proposalObj.Customer_SignOff_Date__c != null)
                            || (proposalObj.SR_Signoff__c != oldProposalObj.SR_Signoff__c 
                                && proposalObj.SR_Signoff__c != null)
                            || (proposalObj.Revised_SR_Signoff__c != oldProposalObj.Revised_SR_Signoff__c 
                                && proposalObj.Revised_SR_Signoff__c != null)) {
                        
                        if(proposalObj.Generation_Asset__c != null){
                            proposalToGenAssetMap.put(proposalObj.Id, proposalObj.Generation_Asset__c );
                        }
                        if(proposalObj.Service_Contract__c != null){
                            scProposalMap.put(proposalObj.Id, proposalObj);
                        }
                    }
                    
                    if(proposalObj.Proposal_Source__c != null && proposalObj.Proposal_Source__c == ProposalUtil.BLACK_BIRD && proposalObj.Signed__c == true
                        && (oldProposalObj.Signed__c == null || oldProposalObj.Signed__c == false)){

                        if(proposalObj.Original_Proposal_ID__c != null){
                            submittedNodeMap.put(proposalObj.Id, proposalObj);
                        }
                        
                        Set<Id> tempProposalIds = opportunityProposalMap.containsKey(proposalObj.Opportunity__c) ? opportunityProposalMap.get(proposalObj.Opportunity__c) : new set<Id>();
                        tempProposalIds.add(proposalObj.Id);
                        opportunityProposalMap.put(proposalObj.Opportunity__c, tempProposalIds);
                        signedProposalIds.add(proposalObj.Id);
                        String signedRootId = ProposalUtil.getSignedRootId(proposalObj, true);
                        if(signedRootId != null && signedRootId != ''){
                            signedProposalMap.put(proposalObj.Id, signedRootId);
                        }
    
                        if(proposalObj.Ultimate_Parent_Proposal__c != null){
                            ultimateProposalIds.add(proposalObj.Ultimate_Parent_Proposal__c);
                        }
                    }           
                }
                
                System.debug('scProposalMap2: ' + scProposalMap);
                ServiceContractUtil.updateServiceContracts(scProposalMap);
                
                Map<Id, List<ServiceContract>> serviceContractMap = new Map<Id, List<ServiceContract>> ();
                System.debug('contractOptyIds: ' + contractOptyIds);
                if(!contractOptyIds.isEmpty()){
                    serviceContractMap = ServiceContractUtil.getServiceContracts('Opportunity', contractOptyIds);
                }
                System.debug('serviceContractMap: ' + serviceContractMap);

                if(submittedNodeMap.size() > 0 ){
                    ProposalUtil.processNewlyCreatedBBProposals(submittedNodeMap, signedProposalMap, true, true);
                }
                
                if(opportunityProposalMap.size() > 0){
                    ProposalUtil.inactivateChildProposals(opportunityProposalMap, signedProposalIds, ultimateProposalIds);
                }
        
                System.debug('proposalToOptyMap: ' + proposalToOptyMap);
                Map<Id, Opportunity> optyMap = new Map<Id, Opportunity>();
                if(proposalToOptyMap.values() != null && proposalToOptyMap.values().size() > 0){
                    optyMap = new Map<Id, Opportunity>([Select Id, sr_credit_status__c from Opportunity 
                                                        where Id in :proposalToOptyMap.values()]);      
                }          
        
                System.debug('proposalToGenAssetMap: ' + proposalToGenAssetMap);
                Map<Id, Generation_Assets__c> genAssetMap = new Map<Id, Generation_Assets__c>();
                if(proposalToGenAssetMap.values() != null && !proposalToGenAssetMap.values().isEmpty()){
                    genAssetMap = new Map<Id, Generation_Assets__c>([Select Id, Customer_Signoff__c, SR_Signoff__c from Generation_Assets__c 
                                                        where Id in :proposalToGenAssetMap.values()]);
                }


                System.debug('pendingServiceContractProposalIds: ' + pendingServiceContractProposalIds);
                for(Id objectId : serviceContractMap.keySet()){
                    List <ServiceContract> lSC = serviceContractMap.get(objectId);
                    for(ServiceContract contractObj : lSC){
                        System.debug('contractObj.proposal__c : ' + contractObj.proposal__c);
                        
                        if(contractObj.proposal__c != null){
                            if(voidProposalId.contains(contractObj.proposal__c)){
                                contractObj.Service_Contract_Status__c = 'Inactive';
                                modifiedServiceContractMap.put(contractObj.Id, contractObj);
                            }
                        }
                        System.debug('contractObj.Opportunity__c : ' + contractObj.Opportunity__c);
                        if(contractObj.Opportunity__c != null){
              Set<String> contractStages = new Set<String>();
              contractStages.addall(ServiceContractUtil.getNTPStages());
              contractStages.addall(ServiceContractUtil.getAfterNTPStages());
                            if(pendingServiceContractOptyIds.contains(contractObj.Opportunity__c) && contractStages.contains(contractObj.Status__c)){
                                contractObj.Previous_Status__c = (contractObj.Previous_Status__c != ServiceContractUtil.PENDING) ? contractObj.Status__c : contractObj.Previous_Status__c;
                                contractObj.Status__c = ServiceContractUtil.PENDING;
                                modifiedServiceContractMap.put(contractObj.Id, contractObj);                            
                            }                       
                        }
                        System.debug('After changes ...');
                    }                
                }
                
               // Map<Id, String> proposalStageMap = new Map<Id, String>();
                //for(Id tempProposalId : srApprovedProposalOptyMap.keySet()){
                //    Id optyId = srApprovedProposalOptyMap.get(tempProposalId);
                 //   if(serviceContractMap.containsKey(optyId)){
                 //       proposalStageMap.put(tempProposalId, EDPUtil.SR_OPS_APPROVED);
                //    }
               // }
                
                //if(!proposalStageMap.isEmpty()){
                //    ServiceContractUtil.updateServiceContract(proposalStageMap);
                //}
                
                System.debug('modifiedServiceContractMap : ' + modifiedServiceContractMap);
                if(!modifiedServiceContractMap.isEmpty()){
                    update modifiedServiceContractMap.values();
                }
            }
        }
        if(trigger.isInsert&&trigger.isAfter){
            ProposalUtil.PopulateProposalPerformanceGuarantee(trigger.new);
            ProposalUtil.PopulateLegacyPartnersOppty(trigger.new);
        }
        else if(Trigger.isUpdate){
            List<Proposal__c> proposalList=new List<Proposal__c>();
            for(Proposal__c proposal:trigger.new){
                if(proposal.Opportunity__c!=null&&(proposal.Sales_Partner__c!=trigger.oldmap.get(proposal.id).sales_partner__c||proposal.install_partner__c!=trigger.oldmap.get(proposal.id).install_partner__c)){
                    proposalList.add(proposal);
                }
            }
            if(!proposalList.isempty()){
                ProposalUtil.PopulateLegacyPartnersOppty(proposalList);
            }
        }
        
    //Please invoke the below codeafter ProposalUtil.PopulateLegacyPartnersOppty
    if((opportunityToSalesPartner != null && !opportunityToSalesPartner.isEmpty()) || 
        (opportunityToInstallPartner != null && !opportunityToInstallPartner.isEmpty())){
        ProposalUtil.createPartnerRoles(opportunityToSalesPartner, opportunityToInstallPartner);
    }
    
    if(ProposalUtil.copyCreditInfoProposalIds != null && !ProposalUtil.copyCreditInfoProposalIds.isEmpty()){
      Set<Id> tempProposalIds = new Set<Id>();
      tempProposalIds.addall(ProposalUtil.copyCreditInfoProposalIds);
      ProposalUtil.copyCreditInfoProposalIds = new Set<Id>();
      for(Id tempId : tempProposalIds){
        EDPWebServices.updateCreditInformation(tempId);
      }
    }

    if(!optyIdsForNewProposal.isempty()){
      ProposalUtil.updateLastCreatedProposal(optyIdsForNewProposal);
      }
    
    
    if(!optyIdsForCustOffer.isempty()){
      ProposalUtil.updateCustomerOfferInfo(optyIdsForCustOffer, CustOfferIds);
      }

      if(projectTypeMap != null && !projectTypeMap.isEmpty()){
      ProposalUtil.createProject(optyProposalMap, projectTypeMap);
      }
      
    if(trigger.isUpdate){ 
      ProposalUtil.processWFTasks(trigger.newmap, trigger.oldmap);
       }
     Sf.costcoSyncService.handleProposalsTrigger();
     
    }    
    catch(Exception expObj){
        System.debug('After Trigger: Proposal Exception: ' + expObj);
        System.debug('Cause: ' + expObj.getCause());
        System.debug('LineNumber: ' + expObj.getLineNumber());
        for(Proposal__c proposalObj : Trigger.new){
            proposalObj.adderror(expObj.getMessage());
        }
    } 
    }  
}