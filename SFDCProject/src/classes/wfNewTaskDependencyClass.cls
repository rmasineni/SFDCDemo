public class wfNewTaskDependencyClass{
    public Task_Dependency__c taskDepend{get;set;}
    string id;
    public String relatedKey {get;set;}
    public boolean readOnly {get; set;}
    public task__c newtask{get; set;}
    public List<Task__c> taskList= new List<Task__c>();
    
    public wfNewTaskDependencyClass(ApexPages.StandardController controller) {
        
        String prefix = Schema.getGlobalDescribe().get('task_Dependency__c').getDescribe().getKeyPrefix();
        String idVal = null;
        Map<String, String> params = ApexPages.currentPage().getParameters();
        for (String key : params.keySet()) {
            if (key.startsWith('CF') && key.endsWith('lkid')) {
                relatedKey = key;
                idVal   = params.get(key);
                system.debug ('>>>idVal ' + idVal );
                system.debug ('>>>prefixxx' + prefix );
                break;
                
            }
        }
        
        /*  String TaskDependencyLkp = Label.wfTaskDependencyLkpId;
        
        if (relatedKey == TaskDependencyLkp )
        {  System.debug('>> lkpId' + TaskDependencyLkp);
        readOnly = true;}
        else 
        readOnly = false;   */              
        
        this.taskDepend = (Task_Dependency__c)Controller.getRecord();
        id= idVal ;     
        system.debug('>>>'+id); 
        
        if (id != null ) {
            if(this.taskDepend.Parent_Task__c == id)
                readOnly = true;
            else if(this.taskDepend.Task__c == id)
                readOnly = false;    
            system.debug ('>>> Inside newtask');
            //taskDepend.Task__c = id;
            newtask= [select Name,id, Project_Name__c from Task__c  where id =: Id Limit 1]; 
            taskDepend.Project_Name__c = newtask.project_name__c;
            
        }
    }
    
    public wfNewTaskDependencyClass(Id tskId) {
        
        taskDepend = new Task_Dependency__c();
        id = tskId; 
        system.debug('>>>'+id); 
        taskDepend.Task__c = tskId;
    }
    
    
    
    public pageReference taskSave(){
        pageReference returnToAdhocTask;
        System.Savepoint sp1 = Database.setSavepoint();
        
        //get the selected task category for depend task creation  
        
        String Category=''; 
        If(this.taskDepend.Parent_Task__c == id){ 
            
             taskList=[select id,Category__c from Task__c  where id =: taskDepend.Task__c and Status__c!='Complete' ];
            
         } 
        else { 
              taskList=[select id,Category__c from Task__c  where id =: taskDepend.Parent_Task__c and Status__c!='Complete' ];
             
         } 
        if(!taskList.isEmpty()){
            Category = taskList[0].Category__c;
        }
        
        try{
            
            if(taskDepend != null && this.taskDepend.Parent_Task__c == NULL){
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.severity.ERROR, 'You must enter a value');
                ApexPages.addMessage(myMsg);
                return null;
            }
             else if(taskDepend != null && this.taskDepend.Parent_Task__c == this.taskDepend.Task__c){
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.severity.ERROR, 'Predecessor and Successor Tasks cannot be same');
                ApexPages.addMessage(myMsg);
                return null;
            } 
            else if (taskDepend!=null && Category !='Required') { 
              	 ApexPages.Message myMsg = new ApexPages.Message(ApexPages.severity.ERROR, 'Category of the selected task should be required'); 
	             ApexPages.addMessage(myMsg); 
                  return null; 
           } 
          else {
                insert taskDepend;
                if(taskDepend != null && id != Null){
                    taskDepend = [select Id, task__r.id, Parent_Task__c, Project_Name__c from Task_Dependency__c where Id =:taskDepend.id ];
                    returnToAdhocTask = new pageReference('/apex/wfcreateAdhocTaskOnProject?id='+id);
                    returnToAdhocTask.getParameters().put('projectID', taskDepend.Project_Name__c);
                    return returnToAdhocTask;
                }
            }
            
            
        }catch (System.DmlException e) {
            system.debug('error: ' + e);
            Database.rollback(sp1);
            for (Integer i=0; i < e.getNumDml(); i++) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, e.getDmlMessage(i)));
            }
            return null;
        }catch(Exception expObj){
            ApexPages.addMessages(expObj);   
           return null;
        }  
        return null;   
    }
    
    
    public PageReference backToTask() {
        // editModeSec = true;
        pageReference returnToAdhocTask;
        
        returnToAdhocTask = new pageReference('/apex/wfcreateAdhocTaskOnProject?id='+id);
        returnToAdhocTask.getParameters().put('projectID', taskDepend.Project_Name__c);
        return returnToAdhocTask;
        
    }
    
    
}