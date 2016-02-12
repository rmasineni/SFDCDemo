@ isTest (seeAllData = true)
public class testWfObjectFieldController {
     public static testmethod void wfObjectFieldController_Test(){
      project_template__c prjTemplate = new project_template__c ( name = 'test project Template', Type__c= 'Direct' , Start_Date__c= Date.Today(), End_Date__c =Date.Today().addDays(18)); 
            insert prjTemplate;
            
            Phase_Template__c phaseTemplate = new phase_Template__c( name = 'Project Initiation' , Project_Template__c = prjTemplate.id, Phase_Number__c = '1.0', Start_Date__c= Date.Today(), End_Date__c =Date.Today().addDays(18) );
            insert phaseTemplate;
            
            Task_Template__c taskTemplate = new Task_Template__c( name = 'Verification Call' , Project_Template2__c = prjTemplate.id, Phase_Template__c = phaseTemplate.id, Group_Name__c = 'Barnch Manager',
                                                     Category__c= 'Required', Type__c = 'Standdard', SLA_In_Hours__c = 40 ,Start_Date__c= Date.Today(), End_Date__c =Date.Today().addDays(18) );
            insert taskTemplate;
 
            ApexPages.StandardController con = new ApexPages.standardController(taskTemplate);
            ApexPages.currentPage().getParameters().put('id',taskTemplate.id);
            wfObjectFieldController  obj1 = new wfObjectFieldController(con);
			Task_Template__c taskTemplate2 = new  Task_Template__c ();
         	taskTemplate2 = obj1.tskObj;
         	system.assertEquals(taskTemplate.id, taskTemplate2.id);
         	
     }
}