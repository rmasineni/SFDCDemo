trigger InstallAudit_AccountAssigned on Install_Audit__c (before update, after insert) {

	Boolean skipValidations = false;
	skipValidations = SkipTriggerValidation.performTriggerValidations();
	if(skipValidations == false){
		
		Set<Id> accountIds = new Set<Id>();
		Set<Id> oldAccountIds = new Set<Id>();
		Set<Id> insertServiceContractIds = new Set<Id>();  
		Set<Id> serviceContractIds = new Set<Id>();  
		Set<Id> installAuditIds = new Set<Id>();
		Set<Id> insertAuditIds = new Set<Id>();    
		for (Install_Audit__c ia: Trigger.new) {
	       	if(Trigger.isupdate){
		       	Install_Audit__c oldAudit = Trigger.oldMap.get(ia.ID);
				if(ia.Auditor_Account__c != oldAudit.Auditor_Account__c) {
					
					if(ia.Auditor_Account__c != null){
						accountIds.add(ia.Auditor_Account__c);
					}
					
					if(oldAudit.Auditor_Account__c != null){
						oldAccountIds.add(oldAudit.Auditor_Account__c);
					}
					if(ia.Service_Contract__c != null){
						serviceContractIds.add(ia.Service_Contract__c);
					}
					installAuditIds.add(ia.Id);
				}       		
	       	}
	       	if(Trigger.isInsert && ia.Service_Contract__c != null){
	       		insertServiceContractIds.add(ia.Service_Contract__c );
	       		installAuditIds.add(ia.Id );
	       	}
		}
		
		if(oldAccountIds != null && !oldAccountIds.isEmpty()){
			accountIds.addall(oldAccountIds);
		}
		
		Map<Id, Set<Id>> installPartnerToSC = new Map<Id,Set<Id>>();
		Set<Id> tempAccountIds = new Set<Id>();
		if(insertServiceContractIds != null && !insertServiceContractIds.isEmpty()){
			String installStr = ServiceContractUtil.INSTALL;
			for(Service_Contract_Partner_Rel__c scPartnerRelObj : [Select Id, Account__c, Type__c, ServiceContract__c from Service_Contract_Partner_Rel__c 
																		where Type__c =:installStr and ServiceContract__c in :insertServiceContractIds
																		and Account__c != null]){
				Set<Id> installerIds = installPartnerToSC.containsKey(scPartnerRelObj.ServiceContract__c) ? installPartnerToSC.get(scPartnerRelObj.ServiceContract__c) : new Set<Id>();
				installerIds.add(scPartnerRelObj.Account__c);
				tempAccountIds.add(scPartnerRelObj.Account__c);
				installPartnerToSC.put(scPartnerRelObj.ServiceContract__c, installerIds);														
			}
		}
		
		if(tempAccountIds != null && !tempAccountIds.isEmpty()){
			accountIds.addall(tempAccountIds);
		}
		
		Map<Id, Account> accountMap = new Map<Id, Account>();
		Set<String> oldGroupIds = new Set<String>();
		if(accountIds != null && !accountIds.isEmpty()){
			for(Account accountObj : [Select Id, group_Id__c from Account where Id in :accountIds and group_Id__c != null and group_Id__c  != '']){
				if(oldAccountIds.contains(accountObj.Id)){
					oldGroupIds.add(accountObj.group_Id__c);
				}
				accountMap.put(accountObj.Id, accountObj);
			}
		}
	
		List<ServiceContractShare> oldSCObjectsShares = new List<ServiceContractShare>();
		List<Install_Audit__Share> oldInstallAuditsShares = new List<Install_Audit__Share>();
		
		if(oldGroupIds != null && oldGroupIds.isEmpty()){
			oldSCObjectsShares = [select Id from ServiceContractShare where ParentId in :serviceContractIds and RowCause = 'Manual'
	                             		and UserOrGroupId in :oldGroupIds];
	
			oldInstallAuditsShares = [select Id from Install_Audit__Share where ParentId in :serviceContractIds and RowCause = 'Manual'
	                             		and UserOrGroupId in :oldGroupIds];
			
			if(oldSCObjectsShares != null && !oldSCObjectsShares.isEmpty())
				delete oldSCObjectsShares;
	
			if(oldInstallAuditsShares != null && !oldInstallAuditsShares.isEmpty())
				delete oldInstallAuditsShares;
	
		}
		
		List<ServiceContractShare> scObjectShares = new List<ServiceContractShare>();
		List<Install_Audit__Share> installAuditShares = new List<Install_Audit__Share>();   
		
		for (Id installAuditId : installAuditIds) {
			Install_Audit__c newAudit = Trigger.newMap.get(installAuditId);
			System.debug('newAudit: ' + newAudit);
			if(Trigger.isupdate){
				if (newAudit.Auditor_Account__c != null && newAudit.Service_Contract__c != null 
					&& accountMap != null && accountMap.containsKey(newAudit.Auditor_Account__c)) {
					Account accountObj = accountMap.get(newAudit.Auditor_Account__c);
					ServiceContractShare share = new ServiceContractShare();
					share.ParentId = newAudit.Service_Contract__c;
					share.UserOrGroupId = accountObj.group_Id__c;
					share.AccessLevel = 'edit';             
					scObjectShares.Add(share);
		
					Install_Audit__Share installAuditShare = new Install_Audit__Share();
					installAuditShare.ParentId = newAudit.Id;
					installAuditShare.UserOrGroupId = accountObj.group_Id__c;
					installAuditShare.AccessLevel = 'edit';             
					installAuditShares.Add(installAuditShare);			
				}
			}
			
			System.debug('installPartnerToSC: ' + installPartnerToSC);
			if(Trigger.isInsert && newAudit.Service_Contract__c != null 
				&& installPartnerToSC.containsKey(newAudit.Service_Contract__c)){
				Set<id> installerIds = installPartnerToSC.get(newAudit.Service_Contract__c);
				for(Id installerId: installerIds){
					if(accountMap != null && accountMap.containsKey(installerId)) {
						Account accountObj = accountMap.get(installerId);
	
						Install_Audit__Share installAuditShare = new Install_Audit__Share();
						installAuditShare.ParentId = newAudit.Id;
						installAuditShare.UserOrGroupId = accountObj.group_Id__c;
						installAuditShare.AccessLevel = 'Edit';             
						installAuditShares.Add(installAuditShare);						
					}
				}
				
			}
		}
		
		if(scObjectShares != null && !scObjectShares.isEmpty()){
			Database.SaveResult[] shareInsertResult = Database.insert(scObjectShares,false);
		}	
	
		if(installAuditShares != null && !installAuditShares.isEmpty()){
			Database.SaveResult[] shareInsertResult = Database.insert(installAuditShares,false);
		}
	}
}