global class InstallDateLogicSC_Scheduler implements Schedulable{

    global string query;
    public InstallDateLogicSC_Scheduler(){
                
    }
    
    global void execute(SchedulableContext SC) {
    
    query = 'Select Id, Install_Partner_Id__c, Install_date__c,Service_Contract_Event__c, Process_Install_Date__c,Photo_Requirements_Apply__c from ServiceContract where Marked_For_Deletion__c != \'Yes\' and Process_Install_Date__c=true';
    if(Test.isRunningtest()){
      query = 'Select Id, Install_Partner_Id__c, Install_date__c,Service_Contract_Event__c, Process_Install_Date__c,Photo_Requirements_Apply__c from ServiceContract where Marked_For_Deletion__c != \'Yes\' and Process_Install_Date__c=true limit 1';
     }
    BatchInstallDateLogicSC batchObj = new BatchInstallDateLogicSC(query);
    id batchinstanceid = database.executeBatch(batchObj,50);  
     
    }
}