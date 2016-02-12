@ isTest (seeAllData = true)
public class testWfProjTaskHelper {

     public static testmethod void unitTestOne(){
         
          ServiceContract sc = [select id from ServiceContract limit 1];  
        Test.startTest();
        Project__c proj = new Project__c(name='testProp', service_contract__c = sc.id);
        insert proj;
          Project__c proj1 = new Project__c(name='testProp1', service_contract__c = sc.id,status__c='Blocked');
        insert proj1;
        system.assertNotEquals(null, proj.id) ; 
        Phase__c phase = new Phase__c(name='testPhase', Project__c=proj.Id, Phase_Status__c='INACTIVE');
        
        insert phase;
          Phase.Phase_Status__c = 'OPEN';
         update phase;
          Map<Id, Phase__c> newMap = new Map<Id, Phase__c>();
        Map<Id, Phase__c> oldMap = new Map<Id, Phase__c>();
         newMap.put(phase.id, phase);
         oldMap.put(phase.id, phase);
         projTaskHelper.currentPhase(newMap,oldMap);
        system.assertNotEquals(null, phase.id) ;
        list<Task__c> lstTask = new list<Task__c >();
        for(integer i=1;i<10;i++){
            Task__c tasklocal = new Task__c(name='testTask'+i, Project_Name__c =proj.id, Phase__c = phase.Id);
            lstTask.add(tasklocal );
        }
        insert lstTask;
        system.assertNotEquals(null, lstTask.size()) ; 
        Task__c tasklocal = new Task__c(name='testTask', Project_Name__c =proj.id, Phase__c = phase.Id,category__c='REQUIRED',status__c ='OPEN');
        insert tasklocal ;
        system.assertNotEquals(null, tasklocal.id) ; 
        lstTask[0].status__c = 'ON_HOLD';
        lstTask[1].status__c = 'OPEN';
        lstTask[2].status__c = 'COMPLETE';
        lstTask[3].status__c = 'INACTIVE';
        lstTask[4].category__c= 'OPTIONAL';
        update lstTask;
        tasklocal.status__c = 'COMPLETE';
        update tasklocal ;
        tasklocal.status__c = 'INACTIVE';
        update tasklocal ;
        tasklocal.category__c= 'OPTIONAL';
        update tasklocal ;
        Task__c tasklocal1 = new Task__c(name='Start Installation', Project_Name__c =proj.id, Phase__c = phase.Id,category__c='REQUIRED',status__c ='OPEN');
        insert tasklocal1 ;
          Task__c tasklocal2 = new Task__c(name='Finish Site Audit', Project_Name__c =proj.id, Phase__c = phase.Id,category__c='REQUIRED',status__c ='OPEN');
        insert tasklocal2;
            Task__c tasklocal3 = new Task__c(name=' Submit Post Site-Audit Change Order and Request NTP', Project_Name__c =proj.id, Phase__c = phase.Id,category__c='REQUIRED',status__c ='COMPLETE');
        insert tasklocal3;
       Set<id> setIds=  projTaskHelper.getAllowUsersToModify();
            
       Test.StopTest();
    
     }
    
}