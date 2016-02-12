@istest()
public class testwfAdhocTaskCompController {
    
   
      public static testmethod void wfAdhocTaskCompController(){
           task__c tsk = new task__c ( name = 'test Task123');
        wfAdhocTaskCompController wfAdhocComp = new wfAdhocTaskCompController(); 
          wfAdhocComp.newtask = tsk;
          wfAdhocComp.viewMode = true;
      }

}