trigger trg_lmsinfo_aft_ins_upd on LMSInfo__c (after insert, after update) {

	Set<String> contactIds = new Set<String>();
	Set<String> lmsInfoIds = new Set<String>();
	for(LMSInfo__c lmsInfoObj:Trigger.New)
	{
		if(lmsInfoObj.Contact__C == null){
			lmsInfoObj.adderror('Contact Id is Null OR Empty');

		} 
		if(lmsInfoObj.Certification_Name__c == null 
			|| lmsInfoObj.Certification_Name__c == ''){
			lmsInfoObj.adderror('Certification name is Null OR Empty');
		}			
		contactIds.add(lmsInfoObj.Contact__C);
		lmsInfoIds.add(lmsInfoObj.Id);
	}

	Map<Id, Contact> contactsMap = new Map<Id, Contact>( [Select Id, Accreditation_date__c, Accreditation_Status__c from Contact where Id in :contactIds]);
	for(Id lmsInfoId : lmsInfoIds){
		LMSInfo__c lmsInfoObj = Trigger.NewMap.get(lmsInfoId);
		Contact contactObj = contactsMap.get(lmsInfoObj.Contact__c);        	
		if(contactObj != null){
			if(lmsInfoObj.Status__c == 'Pass'){
				contactObj.Accreditation_Status__c = 'Accredited';
				contactObj.Accreditation_date__c = lmsInfoObj.Exam_Date__c;
			}else {
				contactObj.Accreditation_Status__c = 'Not Accredited';
			}
		}
	}
	if(contactsMap.size() > 0){
		update contactsMap.values();
	}

}