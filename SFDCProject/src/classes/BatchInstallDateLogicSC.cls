global class BatchInstallDateLogicSC implements Database.Batchable<sObject>,Database.AllowsCallouts,database.StateFul{

global string query;
global string errormsgs = '';
global List<exception__c> listExceptions{get;set;}
global Set<Id> excepIds{get;set;}
global BatchInstallDateLogicSC(string q){
query = q;
listExceptions = new List<exception__c>();
excepIds = new Set<Id>();
}

global Database.QueryLocator start (DataBase.BatchableContext BC){

return Database.getQueryLocator(query);
}

global void execute(DataBase.BatchableContext BC, List<sObject> scope){
 
List<ServiceContract> sclist = new List<ServiceContract>();
List<ServiceContract> toBeUpdateList = new List<ServiceContract>(); 
Map<Id,Partner_Contract__c> pcMap = new Map<Id,Partner_Contract__c>();
Map<Id,Service_Contract_Event__c> sceMap = new Map<Id,Service_Contract_Event__c>();
set<Id> sceIds = new Set<Id>();
set<Id> pcIds = new Set<Id>();

  
 for(sObject s:scope){
  ServiceContract sc = (ServiceContract)s;
  if(sc.Process_Install_Date__c==true)
  {
    pcIds.add(sc.Install_Partner_Id__c);
    sceIds.add(sc.Service_Contract_Event__c);
    sc.Process_Install_Date__c = false;
    sclist.add(sc);
  }
  
 }
 
 /*pcMap = new Map<Id,Partner_Contract__c>();
 for(Partner_Contract__c pcObj:[Select Id, Account__c,Effective_Date__c,Photo_Requirements_Apply__c,Contract_Type__c from Partner_Contract__c where Account__c In: pcIds and Contract_Status__c = 'Active' and Contract_Type__c in ( 'Full Service Contract', 'Full Service', 'Install', 'Install Only')]){
   pcMap.put(pcObj.Account__c,pcObj);
     system.debug('pcMap'+pcMap);
 }*/
 sceMap = new Map<Id,Service_Contract_Event__c>([Select Id, Completion_of_Construction__c, M1_Terms__c, M1_proof_panel_inverter_delivery__c, Customer_Signoff__c,M2_proof_substantial_completion__c from Service_Contract_Event__c where Id In: sceIds]);
     system.debug('sceMap'+sceMap);
 if(!sclist.isEmpty()){
 for(ServiceContract sc:sclist){
  if(!sceMap.isEmpty()){ //!pcMap.isEmpty() &&
   if(sc.Install_Partner_Id__c == System.Label.Sunrun_Inc_Id){
     if( sceMap.containsKey(sc.service_contract_event__c)&&sceMap.get(sc.service_contract_event__c).Completion_of_Construction__c!=Null){
      sc.Install_date__c = sceMap.get(sc.service_contract_event__c).Completion_of_Construction__c;
      system.debug('sc.Install_date__c'+sc.Install_date__c);
     }
     else if( sceMap.containsKey(sc.service_contract_event__c)&&sceMap.get(sc.service_contract_event__c).Completion_of_Construction__c==Null){
      sc.Install_date__c = Null;
      system.debug('sc.Install_date__c'+sc.Install_date__c);   
     }
    }
   else if(sc.Install_Partner_Id__c != System.Label.Sunrun_Inc_Id){ 
     if(sceMap.containsKey(sc.service_contract_event__c)&&sceMap.get(sc.service_contract_event__c).M1_Terms__c>=0.8){
       if(sceMap.get(sc.service_contract_event__c).M1_proof_panel_inverter_delivery__c != null && sceMap.get(sc.service_contract_event__c).M2_proof_substantial_completion__c == null ||
          sceMap.get(sc.service_contract_event__c).M1_proof_panel_inverter_delivery__c <= sceMap.get(sc.service_contract_event__c).M2_proof_substantial_completion__c){
         sc.Install_date__c = sceMap.get(sc.service_contract_event__c).M1_proof_panel_inverter_delivery__c;
         system.debug('sc.Install_date__c'+sc.Install_date__c);
       }
       else{
         sc.Install_date__c = sceMap.get(sc.service_contract_event__c).M2_proof_substantial_completion__c;  
         system.debug('sc.Install_date__c'+sc.Install_date__c);
       }  
     }
     else if( sc.Install_Partner_Id__c != System.Label.Sungevity_Inc_Id && sceMap.containsKey(sc.service_contract_event__c)&&sceMap.get(sc.service_contract_event__c).M1_Terms__c<0.8 && sc.Photo_Requirements_Apply__c == true){
       if(sceMap.get(sc.service_contract_event__c).M1_proof_panel_inverter_delivery__c != null && sceMap.get(sc.service_contract_event__c).M2_proof_substantial_completion__c == null ||
          sceMap.get(sc.service_contract_event__c).M1_proof_panel_inverter_delivery__c <= sceMap.get(sc.service_contract_event__c).M2_proof_substantial_completion__c){
         sc.Install_date__c = sceMap.get(sc.service_contract_event__c).M1_proof_panel_inverter_delivery__c;
         system.debug('sc.Install_date__c'+sc.Install_date__c);
       }
       else{
         sc.Install_date__c = sceMap.get(sc.service_contract_event__c).M2_proof_substantial_completion__c;  
         system.debug('sc.Install_date__c'+sc.Install_date__c);
       }  
     }
     else{
      if(sceMap.containsKey(sc.service_contract_event__c)){
      sc.Install_date__c = sceMap.get(sc.service_contract_event__c).M2_proof_substantial_completion__c;
      system.debug('sc.Install_date__c'+sc.Install_date__c);
      }
     }
   } 
   toBeUpdateList.add(sc);
  }
 }
}  
  if(!toBeUpdateList.isEmpty()){
  try{
     DataBase.SaveResult[] results = Database.update(toBeUpdateList,false);
     if(results!=null){
       Integer recordId = 0;
       for(DataBase.SaveResult result : results){
         if(!result.isSuccess()){
           this.errormsgs += 'Service Contract Record: ' + toBeUpdateList[recordId].Id +' - ' + result.geterrors()[0].getMessage() + '\r\n';
           excepIds.add(toBeUpdateList[recordId].Id);
         }
         recordId++;
        }
        if(this.errormsgs.length() > 0){
            Exception__c exp = new Exception__c(Details__c = this.errormsgs, Class__c = 'BatchInstallDateLogicSC'); 
            listExceptions.add(exp);
            system.debug('--> 0 listExceptions'+listExceptions);
          }
       } 
     
   }
   catch(Exception e){
    //system.debug(e.getTypeName() + '-' +e.getCause() + ':'+e.getMessage());
    listExceptions.add(new exception__c(Details__c = 'Error : ' + e.getMessage() + 'Stack Tracing : '+ e.getStackTraceString(), Class__c = 'BatchInstallDateLogicSC', message__c = 'This is Fatal error '));
    system.debug('-->ListExceptions'+listExceptions);
   }
  system.debug('-->2 list Exceptions'+listExceptions);
  }
  system.debug('-->5 list exceptions'+listExceptions);
}

	global void finish(DataBase.BatchableContext BC){
	
		if(!listExceptions.isEmpty()){
			system.debug('-->3 ListExceptions'+listExceptions);
			insert listExceptions;
		}
		AsyncApexJob a = [Select Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email from AsyncApexJob where Id =:BC.getJobId()];
	
		Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
		String[] toAddresses = new String[] {a.CreatedBy.Email,label.Install_Date_Batch_Email, Label.BatchUserId};
		Mail.setToAddresses(toAddresses);
		Mail.setSubject('Install Date Batch job successfully done');
		Mail.setPlainTextBody('The Install Date Batch job processed ' +a.TotalJobItems + ' Batches with ' +a.NumberOfErrors + ' failures and ' + listExceptions.size() + ' Exceptions' + ' with Record Ids : ' + excepIds);
		try{
	    	Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
	   	}catch(exception e){
	   		system.debug(e);
		}
	
	}


}