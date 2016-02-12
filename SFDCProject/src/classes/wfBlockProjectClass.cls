public class wfBlockProjectClass {
	list<Task__c> taskActionList = new list<task__c>();
    list<Task__c> allTasks = new list<task__c>();
    public id projectId = System.currentPagereference().getParameters().get('Id');
    public  set<string> statusValues = new set<string>{'Complete','Inactive'};
    public boolean showBlockButton{get;set;}    
    list<project__c> projectList = new list<project__c> ();
        
    public wfBlockProjectClass(){
       showBlockButton = true; 
        if(projectId != null){  
            projectList = [select Id, Name, Status__c from project__c where id = :projectId ];
             
            allTasks = [select Id, Name, Status__c,Open_Date__c,Start_Date__c, Category__c ,Project_Name__c , Blocked_Status__c, Blocked_Project__c from task__c 
                            where Project_Name__c =:projectId ] ;    
        }
      if(projectList.size()>0){
          
            if(projectList[0].Status__c == 'Blocked')
            showBlockButton = false;
      	}
    }
    
     public list<task__c> getTasksToUpdate(){
         if(projectList.size()>0){
             if(projectList[0].Status__c != 'Blocked')
                 taskActionList = [select Id, Name, Status__c,Open_Date__c,Start_Date__c, Category__c ,Project_Name__c,Blocked_Status__c, Blocked_Project__c from task__c 
                                   where Project_Name__c =:projectId and Status__c NOT IN : statusValues ] ;
             else
                 taskActionList = [select Id, Name, Status__c,Open_Date__c,Start_Date__c, Category__c ,Project_Name__c,Blocked_Status__c, Blocked_Project__c from task__c 
                                   where Project_Name__c =:projectId and Status__c =: wfUtil.BLOCKED and  Blocked_Status__c != null ] ;            
         }
         return taskActionList;
    }
    

    // Method to Block the Project  
    public pageReference blockProject(){
        set<string> statusValues = new set<string>{'Complete','Inactive'};
        System.Savepoint sp1 = Database.setSavepoint();
       try {

        for (task__c tsk: allTasks ) {
            integer i = 0;
            if(tsk.Status__c != wfUtil.COMPLETE && tsk.Status__c != wfUtil.INACTIVE ) {
                tsk.Blocked_Status__c = tsk.status__c;
                tsk.Blocked_Project__c = true;
                tsk.status__c = 'Blocked'; 
                system.debug( 'Modified Status' +  tsk.status__c + 'Previous status' + tsk.Blocked_Status__c  );
           	  }
            else {
                tsk.Blocked_Project__c = true;
            	}
            i++;
        	}

        if(allTasks.size()>0){
            update allTasks;
        	}
      
       } catch (System.DmlException e) {
            system.debug('error: ' + e);
            Database.rollback(sp1);
            for (Integer i=0; i < e.getNumDml(); i++) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, e.getDmlMessage(i)));
            }
           
        } catch(Exception e){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO, e.getmessage() ));
            
        }
        return null;
    }
    
    
     // Method to copy the Previous_Status__c value to Status__c field
    public pageReference unBlockProject(){
         list<task__c> existingTasks = new list<task__c>();
         System.Savepoint sp1 = Database.setSavepoint();
     
        try {  
             
            for(task__c tsk : allTasks){
                if(tsk.Blocked_Status__c != null && tsk.Blocked_Project__c) {
                    tsk.status__c = tsk.Blocked_Status__c;
                    tsk.Blocked_Project__c = false;
                    tsk.Blocked_Status__c = '';
                } else {
                    tsk.Blocked_Project__c = false;
                }
            }
                if(allTasks.size()>0){
                    update allTasks;
            }
      
        } catch (System.DmlException e) {
            system.debug('error: ' + e);
            Database.rollback(sp1);
            for (Integer i=0; i < e.getNumDml(); i++) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, e.getDmlMessage(i)));
            }
            
        } catch(Exception e){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO, e.getmessage() ));         
        } 		
         return null;  
    }
   
    
}