trigger trg_credit_after_ins_after_upd on Customer_Credit__c (after insert, after update, before delete){
	
	Boolean skipValidations = false;
	skipValidations = SkipTriggerValidation.performTriggerValidations();
	Map<String, Id> dealIdToCustomerCreditMap = new Map<String, Id>();
	Set<Id> customerCreditRecords = new Set<Id>();
	if(skipValidations == false){
		Map<String, Customer_Credit__c> emailStatusMap = new Map<String, Customer_Credit__c>();
		Customer_Credit__c tempCustomerCredit = new Customer_Credit__c();
		tempCustomerCredit.status__c = '';
		tempCustomerCredit.Date_Pulled__c = null;
		tempCustomerCredit.Date_Submitted__c = null;
		
		if(Trigger.isinsert || Trigger.isupdate){
			for(Customer_Credit__c ccObj:Trigger.New){
				Customer_Credit__c oldCCObj;
				if(Trigger.isinsert){
					if(ccObj.Customer_Email__c != null && ccObj.Customer_Email__c != ''){
						emailStatusMap.put(ccObj.Customer_Email__c, ccObj);
					}
					
				}else if(Trigger.isupdate){
					oldCCObj = Trigger.oldMap.get(ccObj.Id);
					if(oldCCObj.Customer_Email__c != ccObj.Customer_Email__c){
						if(oldCCObj.Customer_Email__c != null && oldCCObj.Customer_Email__c != ''){
							emailStatusMap.put(oldCCObj.Customer_Email__c, tempCustomerCredit);
						}
						if(ccObj.Customer_Email__c != null && ccObj.Customer_Email__c != ''){
							emailStatusMap.put(ccObj.Customer_Email__c, ccObj);
						}
						
					}else if(oldCCObj.status__c != ccObj.status__c 
						|| oldCCObj.Date_Pulled__c != ccObj.Date_Pulled__c 
						|| oldCCObj.Date_Submitted__c != ccObj.Date_Submitted__c
						|| oldCCObj.Sunrun_Credit_Status__c != ccObj.Sunrun_Credit_Status__c
                        || oldCCObj.Credit_Decision_on_Portal__c != ccObj.Credit_Decision_on_Portal__c){
						
						if(ccObj.Customer_Email__c != null && ccObj.Customer_Email__c != ''){
							emailStatusMap.put(ccObj.Customer_Email__c, ccObj);
						}
					}
				}

				if(ccObj.deal_Id__c != null &&  ccObj.deal_Id__c  != '' && ccObj.type__c != 'Sunrun' &&
					(Trigger.isInsert || (Trigger.isUpdate && ccObj.deal_Id__c != oldCCObj.deal_Id__c))){
					customerCreditRecords.add(ccObj.Id);
					dealIdToCustomerCreditMap.put(ccObj.deal_Id__c, ccObj.Id);
				}

			}
		}else if(Trigger.isDelete){
			for(Customer_Credit__c ccObj:Trigger.old){
				if(ccObj.Customer_Email__c != null && ccObj.Customer_Email__c != ''){
					emailStatusMap.put(ccObj.Customer_Email__c, tempCustomerCredit);
				}			
			}
		}
		
		if(dealIdToCustomerCreditMap != null && !dealIdToCustomerCreditMap.isEmpty()){
			ProposalUtil.updateCreditInformation(dealIdToCustomerCreditMap, customerCreditRecords);
		}
	
		try{
			List<Contact> contactList = new List<Contact>();
			for(Contact contactObj : [Select Id, credit_status__c,	DataSourceC__c,Credit_Decision_on_Portal__c, Sunrun_Credit_Status__c, credit_received__c,credit_submitted__c, email from contact 
										where email in :emailStatusMap.keySet() 
										and DataSourceC__c != 'SUNRUN SOUTH'
										]){
				Customer_Credit__c modifiedCustomerCreditObj = emailStatusMap.get(contactObj.email);
				if(modifiedCustomerCreditObj.type__c != 'Sunrun' || (modifiedCustomerCreditObj.type__c == 'Sunrun' && modifiedCustomerCreditObj.Contact__c == contactObj.Id)){
					String tempCreditStatus = (modifiedCustomerCreditObj.Status__c == null || modifiedCustomerCreditObj.Status__c == '' 
												|| modifiedCustomerCreditObj.Status__c.length() <= 255) ? modifiedCustomerCreditObj.Status__c : modifiedCustomerCreditObj.Status__c.substring(0,255);
                    contactObj.Sunrun_Credit_Status__c = modifiedCustomerCreditObj.Sunrun_Credit_Status__c; 
                    contactObj.credit_status__c = (modifiedCustomerCreditObj.status__c == null || modifiedCustomerCreditObj.status__c == '') ? 'Sent' :  modifiedCustomerCreditObj.status__c;
					contactObj.credit_received__c = modifiedCustomerCreditObj.Date_Pulled__c;
					contactObj.credit_submitted__c = modifiedCustomerCreditObj.Date_Submitted__c;
                    contactObj.Credit_Status_on_Portal__c = modifiedCustomerCreditObj.Credit_Decision_on_Portal__c;
                    if(modifiedCustomerCreditObj.Date_Submitted__c != null 
						&& (contactObj.credit_status__c == null || contactObj.credit_status__c == '')){
						contactObj.credit_status__c = 'Sent';	
					}
					contactList.add(contactObj);
                    system.debug('contactObj.Sunrun_Credit_Status__c'+contactObj.Sunrun_Credit_Status__c);
                     
                 
				}
			}
			if(!contactList.isEmpty()){
				update  contactList;
			}
		}catch(Exception exp){
			System.debug('Unable to update credit status on the contact: ' + exp);	
            system.debug('emailStatusMap'+emailStatusMap);
          
		}
	}
}