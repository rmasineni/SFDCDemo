@isTest(seealldata=true)

Public class Test_BatchInstallDateLogicSC{

@isTest static void BatchInstallDateTestMethod(){

Test.startTest();

String query =  'Select Id, Install_Partner_Id__c, Install_date__c,Service_Contract_Event__c, Process_Install_Date__c,Photo_Requirements_Apply__c from ServiceContract where Marked_For_Deletion__c != \'Yes\' and Process_Install_Date__c=true limit 5';
BatchInstallDateLogicSC batchObj = new BatchInstallDateLogicSC(query);


 id batchinstanceid = database.executeBatch(batchObj);
 
 InstallDateLogicSC_Scheduler sch1 = new InstallDateLogicSC_Scheduler(); 
 System.schedule('Scheduled Job 2', '0 15 * * * ?', sch1);

Test.stopTest();
}

}