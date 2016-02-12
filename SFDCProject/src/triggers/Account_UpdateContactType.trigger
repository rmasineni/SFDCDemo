trigger Account_UpdateContactType on Account (after delete, after update) {
	
	Set<Id> accountIds = new Set<Id>();
	Account oldAccountObj;

	if(Trigger.isDelete){
		for(Account accountObj: Trigger.old){
			if(accountObj.Account_Type__c != null && 
				accountObj.Account_Type__c == PRMLibrary.PARTNER){
				accountIds.add(accountObj.Id);
			}
		}		
	}else if(Trigger.isUpdate){
		for(Account accountObj: Trigger.new){
			oldAccountObj = Trigger.oldMap.get(accountObj.Id);
			if((oldAccountObj.Account_Type__c != null && oldAccountObj.Account_Type__c == PRMLibrary.PARTNER) ||
				(accountObj.Account_Type__c != null && accountObj.Account_Type__c == PRMLibrary.PARTNER)){
				if(oldAccountObj.Account_Type__c != accountObj.Account_Type__c){
					accountIds.add(accountObj.Id);
				}
			}
		}
	}
	if(accountIds.size() > 0){
		PRMLibrary.setContactType(accountIds);
	}
}