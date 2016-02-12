/****************************************************************************
Author  : Raghu Masineni (rmasineni@sunrunhome.com)
Date    : April 2012
Description: Deactivate/Activate the related contacts

*****************************************************************************/
trigger Account_ModifyContacts on Account (after update) {
	
    Boolean skipValidations = false;
	skipValidations = SkipTriggerValidation.performTriggerValidations();
	if(skipValidations == false){
		try{
	
		    Account oldAccountObj;
		    Set<Id> deactivateAccountIds = new Set<Id>();
		    Set<Id> activateContacts = new Set<Id>();
			Set<Id> modifiedAccounts = new Set<Id>();
		    Set<Id> nameChangeAccountIds = new Set<Id>(); 
			Set<Id> lmsModifiedAccountIds = new Set<Id>();
			Set<Id> accountIdsForContactActivation = new Set<Id>();
			Set<Id> proposalIdsForVoid = new Set<Id>();
			Map<Id, Proposal__c> voidedProposals = new Map<Id, Proposal__c>();
	
			Id partnerRecordTypeId ;
			Id residentialRecordTypeId ;
			Map<Id, Boolean> modifiedResidentialAccounts = new Map<Id, Boolean>();
			Map<Id, Boolean> modifiedAddressAccounts = new Map<Id, Boolean>();
			Map<Id, Account> modifiedAddressAccountObjs = new Map<Id, Account>();
			Set<Id> modifiedPartnerAccounts = new Set<Id>();
			
			Map<Id, RecordType> accountRecordTypeMap = PRMLibrary.getAccountRecordTypes();
			for(RecordType recordTypeObj : accountRecordTypeMap.values()){
				if(recordTypeoBJ.name == PRMLibrary.PARTNER){
					partnerRecordTypeId = recordTypeoBJ.Id;
				}else if(recordTypeoBJ.name == AccountUtil.RESIDENTIAL){
					residentialRecordTypeId = recordTypeoBJ.Id;
				}
			}
			
			Map<Id, Map<Id, Proposal__C>> accountProposalmap = ProposalUtil.getActiveProposalsForAccounts(null);
		    for(Account accountObj: Trigger.new){
		    	if(Trigger.isUpdate){
					oldAccountObj = Trigger.oldMap.get(accountObj.Id);
					
					if(partnerRecordTypeId != null && accountObj.RecordTypeId  == partnerRecordTypeId){
						modifiedPartnerAccounts.add(accountObj.Id);
					}
					Boolean addressModified = false;
					if(accountObj.RecordTypeId == residentialRecordTypeId && (AccountUtil.isAddressInformationChanged(accountObj, oldAccountObj))){
						addressModified = true;
						modifiedAddressAccounts.put(accountObj.Id, true);
						modifiedAddressAccountObjs.put(accountObj.Id, accountObj);
					}
					if(residentialRecordTypeId != null && accountObj.RecordTypeId  == residentialRecordTypeId){
						modifiedResidentialAccounts.put(accountObj.Id, addressModified);
					}				
	
					if((AccountUtil.eligibleForVoid.contains(accountObj.Id) 
						//&& AccountUtil.isZip6Changed(accountObj, oldAccountObj)
						) 
						&& !AccountUtil.voidedAccountIds.contains(accountObj.Id)){
						
						AccountUtil.voidedAccountIds.add(accountObj.Id);
						if(accountProposalmap != null && accountProposalmap.size() > 0){
							Map<Id, Proposal__C> proposalMap = accountProposalmap.get(accountObj.Id);
							System.debug('proposalMap: '  + proposalMap);
							if(proposalMap != null && !proposalMap.isEmpty()){
								voidedProposals.putAll(proposalMap);
							}
						}
					}
		    	}    
				if(accountObj.Account_Type__c == null || accountObj.Account_Type__c != PRMLibrary.PARTNER)
					continue;
			
		        /*
		        if(accountObj.Active__c != null){
		        	if(accountObj.Active__c == false ){
		 				if(Trigger.isUpdate && (oldAccountObj.Active__c != accountObj.Active__c)){
							//deactivateAccountIds.add(accountObj.Id); 
		 				}	
					}else if(accountObj.Active__c == true){
		        		if(Trigger.isUpdate  && (oldAccountObj.Active__c != accountObj.Active__c)){
							//activateContacts.add(accountObj.Id);
		        		}
					}
		        }
		        */
		        
		        if(oldAccountObj != null){
		        	if(accountObj.ParentId != null && (accountObj.ParentId  != oldAccountObj.ParentId)){
						modifiedAccounts.add(accountObj.Id);
		        	}
		        	
		        	if(accountObj.Name != oldAccountObj.Name){
						nameChangeAccountIds.add(accountObj.Id);
		        	}
		        	
		        	System.debug('Start: ');
		        	if(accountObj.ParentId == null 
		        		&& (oldAccountObj.active__c != accountObj.active__c 
		        			|| oldAccountObj.Stage__c != accountObj.Stage__c 
		        			|| oldAccountObj.ParentId != accountObj.ParentId) 
		        		&& accountObj.Stage__c  != null 
		        		&& accountObj.active__c == true
		        		&& (accountObj.stage__c == 'Confirmed' || accountObj.stage__c.contains('Contract Negotiation'))){
		        		
		        		if(!lmsModifiedAccountIds.contains(accountObj.Id)){
		        			lmsModifiedAccountIds.add(accountObj.Id);
		        			
		        			//Activate the Contacts only if the Account stage 
		        			//changes to 'Confirmed' OR 'Contract Negotiation'
		        			//for the first time from any other value.
		        			if((accountObj.stage__c == 'Confirmed' 
		        				|| accountObj.stage__c.contains('Contract Negotiation'))
		        				&&(	oldAccountObj.stage__c == null || 
		        					(oldAccountObj.stage__c != 'Confirmed' 
		        					&& !oldAccountObj.stage__c.contains('Contract Negotiation')))){
		        				
		        				if(!LMSInfoManager.accountTriggerActiveIds.contains(accountObj.Id)){
									accountIdsForContactActivation.add(accountObj.Id);
									LMSInfoManager.accountTriggerActiveIds.add(accountObj.Id);   					
		        				}
							}
		        		}
			       	}
			       	System.debug('End: ');
				}
		    }
			
			if(voidedProposals != null && !voidedProposals.isEmpty()){
				Map<Id, String> reasonMap = new Map<Id, String>();
				for(Proposal__c tempProposalObj : voidedProposals.values()){
					reasonMap.put(tempProposalObj.Id, ProposalUtil.ACCOUNT_ADDRESS_CHANGE);
				}
				ProposalUtil.voidProposals(voidedProposals, reasonMap, true);
			}
			
			System.debug('lmsModifiedAccountIds: ' + lmsModifiedAccountIds);
			if(lmsModifiedAccountIds.size() > 0){
				LMSInfoManager.processAllPartnerContacts(lmsModifiedAccountIds, accountIdsForContactActivation);	
			}
		
		    if(nameChangeAccountIds.size() > 0){
		    	PRMLibrary.modifyChildAccountsName(nameChangeAccountIds);
		    }
		    
		    System.debug('modifiedAccounts: '  + modifiedAccounts);
		    if(modifiedAccounts.size() > 0){
		    	PRMLibrary.createContactRoles(modifiedAccounts);
		    }
		    
		    try{
				if(modifiedResidentialAccounts != null && !modifiedResidentialAccounts.isEmpty()){
			    	ServiceContractUtil.updateServiceContractsForAccount(modifiedResidentialAccounts, datetime.now());
			    }
		
				if(modifiedAddressAccounts != null && !modifiedAddressAccounts.isEmpty()){
			    	ServiceContractUtil.updateSCDescriptionForAccount(modifiedAddressAccounts);
					wfUtil.updateProjectAddress(modifiedAddressAccountObjs);
			    }
		    }catch(Exception expObj){
		    	System.debug('expObj: ' + expObj);
		    }
	
		   // if(modifiedPartnerAccounts != null && !modifiedPartnerAccounts.isEmpty()){
		    //	ServiceContractUtil.updateServiceContractsForInstallPartners(modifiedPartnerAccounts, datetime.now());
		   // }
		    
		}catch(Exception exceptionObj){
			System.debug('After Trigger: Account Exception: ' + exceptionObj);
			for(Account accountObj : Trigger.new){
				accountObj.adderror(exceptionObj.getMessage());
			}
		}
	}
}