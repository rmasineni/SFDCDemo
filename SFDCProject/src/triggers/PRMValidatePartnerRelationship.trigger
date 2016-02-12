trigger PRMValidatePartnerRelationship on Partner_Relationship__c (before insert, before update) {

	Set<Id> accountList = new 	Set<Id>();
	
	Partner_Relationship__c oldRelationshipObj;
	for(Partner_Relationship__c relationshipObj: Trigger.New ){

		String fieldNames = '';
		String errorMessage = '';
		if(relationshipObj.Related_From_Account__c == null){
			fieldNames = ' \'Related From Account\' ';
		}
			
		if(relationshipObj.Related_To_Account__c == null){
			fieldNames += (fieldNames != '') ?  ', \'Related To Account\' ' : ' \'Related To Account\' ';
		}

		if(relationshipObj.From_Relationship__c == null){
			fieldNames += (fieldNames != '') ?  ', \'Relationship Type\' ' : ' \'Relationship Type\' ';
		}
		
		if(fieldNames != ''){
			errorMessage = 'Select values for  ' +  fieldNames;
			relationshipObj.addError(errorMessage);
			continue;
		}

		if(relationshipObj.Related_From_Account__c == relationshipObj.Related_To_Account__c ){
			errorMessage = 'Partner relationship with the same account is not allowed';
			relationshipObj.addError(errorMessage);
			continue;			
		}
		
		if(Trigger.isUpdate){
			oldRelationshipObj = Trigger.oldMap.get(relationshipObj.Id);
			if(oldRelationshipObj.Related_From_Account__c != relationshipObj.Related_From_Account__c ||
				oldRelationshipObj.Related_To_Account__c != relationshipObj.Related_To_Account__c) {
				accountList.add(relationshipObj.Related_From_Account__c);
				accountList.add(relationshipObj.Related_To_Account__c);
			}
		}else if(Trigger.isInsert){
			accountList.add(relationshipObj.Related_From_Account__c);
			accountList.add(relationshipObj.Related_To_Account__c);			
		}
		
	}
	
	if(accountList.size() > 0){
		//Map<Id, Set<Id>> fromToAccountMap = new Map<Id, Set<Id>>();
		//Map<Id, Set<Id>> toFromAccountMap = new Map<Id, Set<Id>>();

		Map<Id, Map<Id, Partner_Relationship__c>> fromToAccountMap = new Map<Id, Map<Id, Partner_Relationship__c>>();
		Map<Id, Map<Id, Partner_Relationship__c>> toFromAccountMap = new Map<Id, Map<Id, Partner_Relationship__c>>();
		
		Map<Id, Partner_Relationship__c> fromPartnerRelationshipMap;
		Map<Id, Partner_Relationship__c> toPartnerRelationshipMap;
		for(Partner_Relationship__c relationshipObj : [Select Id, Related_From_Account__c,
															Related_From_Account__r.Id, Related_From_Account__r.Name,
															Related_To_Account__c,
															Related_To_Account__r.Id, Related_To_Account__r.Name
															from Partner_Relationship__c 
															where Related_From_Account__c in :accountList OR 
															Related_To_Account__c in :accountList]){
			Id fromAccount = relationshipObj.Related_From_Account__c;
			Id toAccount = relationshipObj.Related_To_Account__c;
			
			toPartnerRelationshipMap = fromToAccountMap.containsKey(fromAccount) ? 
									fromToAccountMap.get(fromAccount) : new Map<Id, Partner_Relationship__c>();
			toPartnerRelationshipMap.put(toAccount, relationshipObj);
			fromToAccountMap.put(fromAccount,toPartnerRelationshipMap);

			fromPartnerRelationshipMap = toFromAccountMap.containsKey(toAccount) ? 
									toFromAccountMap.get(toAccount) : new Map<Id, Partner_Relationship__c>();
			fromPartnerRelationshipMap.put(fromAccount, relationshipObj);
			toFromAccountMap.put(toAccount,fromPartnerRelationshipMap);
		}

		for(Partner_Relationship__c relationshipObj: Trigger.New ){
			
			Id fromAccountId = relationshipObj.Related_From_Account__c;
			Id toAccountId = relationshipObj.Related_To_Account__c;
			
			if(fromToAccountMap.containsKey(fromAccountId)){
				toPartnerRelationshipMap = fromToAccountMap.get(fromAccountId);
				if(toPartnerRelationshipMap.containsKey(toAccountId)){
					Partner_Relationship__c tempRelObj = toPartnerRelationshipMap.get(toAccountId);
					String errorTest = 'There is an existing partner relationship between the Accounts ';
					errorTest += '\'' + tempRelObj.Related_From_Account__r.Name + '\' , ' ;
					errorTest += '\'' + tempRelObj.Related_To_Account__r.Name + '\'' ;
					relationshipObj.addError( errorTest);

					//relationshipObj.addError('There is an existing partner relationship between the Accounts ' + fromAccountId + ' , ' + toAccountId);
				}
			}else if(toFromAccountMap.containsKey(fromAccountId)){
				fromPartnerRelationshipMap = toFromAccountMap.get(fromAccountId);
				if(fromPartnerRelationshipMap.containsKey(toAccountId)){
					Partner_Relationship__c tempRelObj = fromPartnerRelationshipMap.get(toAccountId);
					String errorTest = 'There is an existing partner relationship between the Accounts ';
					errorTest += '\'' + tempRelObj.Related_From_Account__r.Name + '\' , ' ;
					errorTest += '\'' + tempRelObj.Related_To_Account__r.Name + '\'' ;
					relationshipObj.addError( errorTest);					
					//relationshipObj.addError('There is an existing partner relationship between the Accounts ' + fromAccountId + ' , ' + toAccountId);
				}
			}
			
		}
		
		
	}

}