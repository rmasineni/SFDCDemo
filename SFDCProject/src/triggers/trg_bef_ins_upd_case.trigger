trigger trg_bef_ins_upd_case on Case (before insert,before update) {
 
	Boolean skipValidations = false;
	skipValidations = SkipTriggerValidation.performTriggerValidations();
	if(skipValidations == false){    
		Set<Id> scId = new Set<Id>();
	    RecordType partnerConcRecType = [Select Id from RecordType where Name = 'Partner Concierge' and SobjectType = 'Case']; 
		List<Case> caseListForSC = new List<Case>();
	    for (Integer i = 0; i < Trigger.new.size(); i++)  
	    {
	    	Case caseObj = Trigger.new[i];
	        if ( Trigger.new[i].RecordTypeId == partnerConcRecType.Id &&  Trigger.new[i].ContactId != null && (Trigger.IsInsert || Trigger.old[i].RecordTypeId != Trigger.new[i].RecordTypeId || Trigger.old[i].ContactId != Trigger.new[i].ContactId ) ) 
	        {
	            Contact contRec = [Select Account.Account_Manager__r.Email from Contact where Id = :Trigger.new[i].ContactId];
	            Trigger.new[i].Email_Address_of_Account_Manager__c   = contRec.Account.Account_Manager__r.Email;       
	        }
	        Case oldCaseObj;
	        If(Trigger.isUpdate){
	        	oldCaseObj = Trigger.oldMap.get(Trigger.new[i].Id);
	        }
			
			if(caseObj.service_contract__c != null && (Trigger.isInsert || (caseObj.service_contract__c != oldCaseObj.service_contract__c))){
				scId.add(caseObj.service_contract__c);
				caseListForSC.add(caseObj);
			}
		}
		
		if(scId != null && !scId.isEmpty()){
			Map<Id, Id> scToEventIdMap = new Map<Id, Id>();
			for(Service_Contract_Event__c scEventObj : [Select Id, service_Contract__c from Service_Contract_Event__c where service_Contract__c in :scId]){
				scToEventIdMap.put(scEventObj.service_Contract__c, scEventObj.Id);
			}
			for(Case caseObj :caseListForSC){
				if(caseObj.service_contract__c != null && scToEventIdMap.containsKey(caseObj.service_contract__c )){
					caseObj.service_Contract_Event__c = scToEventIdMap.get(caseObj.service_contract__c );
				}
			}
		}
	}
}