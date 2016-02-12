trigger SendEmailServiceContract on Service_Contract_Event__c (Before Update) {
	Boolean skipValidations = false;
	skipValidations = SkipTriggerValidation.performTriggerValidations();
    Set<Id>SceNtpSet = New Set<Id>();
    Set<Id>ScePtoSet = New Set<Id>();
    for (Service_Contract_Event__c scetemp : Trigger.New) {
		if(skipValidations == false && scetemp.marked_for_deletion__c == 'Yes'){
			scetemp.adderror(SunrunErrorMessage.getErrorMessage('ERROR_000028').error_message__c);
		}
        if(SendEmailClass.checkptosend == false){
            if (Trigger.oldmap.get(scetemp.Id).NTP_Granted__c == null && scetemp.NTP_Granted__c!= null) {
                SceNtpSet.add(scetemp.Service_Contract__c);
            }
            if (Trigger.oldmap.get(scetemp.Id).PTO__c == null && scetemp.PTO__c != null){
                ScePtoSet.add(scetemp.Service_Contract__c);
            }
        }
    }
    if(!SceNtpSet.isEmpty()){
        List<ServiceContract> ScNtpList = [Select Id,Billing_Method__c,Agreement_Type__c,Opportunity__c,Customer_Email__c,ContactId from ServiceContract where Id IN:SceNtpSet];
        Map<Id,ServiceContract> ScNtpMap = new Map<Id,ServiceContract>();
        for (ServiceContract sctemp : ScNtpList){
            if(sctemp.Billing_Method__c == 'Pay by Check' && (sctemp.Customer_Email__c != null ) && (sctemp.Opportunity__c != null || sctemp.Opportunity__c != '') && (sctemp.Agreement_Type__c == 'custom' || sctemp.Agreement_Type__c == 'custom lease' || sctemp.Agreement_Type__c == 'custom PPA Fixed' || sctemp.Agreement_Type__c == 'Low Upfront' || sctemp.Agreement_Type__c== 'Low Upfront Lease' || sctemp.Agreement_Type__c == 'Low Upfront PPA Fixed')) {
                ScNtpMap.put(sctemp.Id,sctemp);
            }
        }
      
        SendEmailClass SMail = new SendEmailClass();
        SMail.SendEmailSCNtp(ScNtpMap.values());
    }
    
    if(!ScePtoSet.isEmpty()){
        List<ServiceContract> ScPtoList = [Select Id,Billing_Method__c,Agreement_Type__c,Opportunity__c,Customer_Email__c,ContactId from ServiceContract where Id IN:ScePtoSet];
        Map<Id,ServiceContract> ScPtoMap = new Map<Id,ServiceContract>();
        for (ServiceContract sctemp1 : ScPtoList){
            if(sctemp1.Billing_Method__c == 'Pay by Check' &&
               (sctemp1.Customer_Email__c != null ) && 
               (sctemp1.Opportunity__c != null || sctemp1.Opportunity__c != '') && 
               (sctemp1.Agreement_Type__c == 'custom' || sctemp1.Agreement_Type__c == 'custom lease' || sctemp1.Agreement_Type__c == 'custom PPA Fixed' || sctemp1.Agreement_Type__c == 'Low Upfront' || sctemp1.Agreement_Type__c== 'Low Upfront Lease' || sctemp1.Agreement_Type__c == 'Low Upfront PPA Fixed'))
            {
                ScPtoMap.put(sctemp1.Id,sctemp1);
                system.debug('ScPtoMap'+ScPtoMap);
            }
        }
        SendEmailClass SMail = new SendEmailClass();
        SMail.SendEmailSCPto(ScPtoMap.values());
    }
}