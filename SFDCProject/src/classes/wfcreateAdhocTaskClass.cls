public class wfcreateAdhocTaskClass {
  public boolean editModeSec{get;set;}
    //public task__c originalTask {get; set;} 
    public task__c newtask{get; set;}
    DateTime dT = System.now();
    list<Task__c> openTasks {get; set;}
    public DateTime CurrentDate = DateTime.newinstance(dT.getTime()); 
    public id projectId = System.currentPagereference().getParameters().get('projectId');
    public  String returnUrl = System.currentPagereference().getParameters().get('returnUrl');
    public List<Opportunity_Team__c> optyRoleList {get;set;}
    
    public wfcreateAdhocTaskClass(ApexPages.StandardController controller) {
        system.debug('returnUrl:' + returnUrl);
        this.newtask = (Task__c)Controller.getRecord();
        if(newTask == null){
            editModeSec = true;
            newTask = new task__c();
            initialize();
            system.debug('newtask Null');
        }
        if(newTask.id != null){
            newTask = [select id, name, Type__c,Status__c,Phase__r.name,Project_Name__c,Group_Name__c,Reason__c,Sub_Reason__c,
                       Task_Description__c,phase__r.Project__r.name,Task_Owner__c, Category__c,Open_Date__c,Start_Date__c,Notify_Owner__c from task__c where id =: newTask.Id];
            initialize();
            system.debug('NewTask Not Null');
        }
        else{
            system.debug('else');
            editModeSec = true;
            initialize();
            
        }
      system.debug('STANDARD CONTROLLER CONSTRUCTOR');
    }
    
    private void initialize(){
        newTask.Type__c = 'Adhoc';
        newTask.Category__c = 'Required';
        newTask.Start_Date__c = CurrentDate; 
        newtask.Project_Name__c =  ProjectId;
        newTask.Status__c = 'Open';
    }
    
    public PageReference backToSearch() {
         // editModeSec = true;
        if(returnUrl != null){
            pageReference returnToTaskView;
            returnToTaskView = new pageReference(returnUrl);
            return returnToTaskView;
        } else {
            pageReference returnToPrjctSearch;
            returnToPrjctSearch = new pageReference('/apex/wfProjectDetails?id='+projectId);
            return returnToPrjctSearch;
          //return page.TaskSearchOffset;
            
        }
          
    }
    
    public PageReference editTask() {
        
        editModeSec =true;
        PageReference pageRef = new PageReference('/apex/wfCreateAdhocTaskOnproject?id='+newtask.id + '&gmaps=1'); 
        return pageRef;  
    }
    
    
     //Method to assign optyTeam contact user as adhoc task owner based role & group information
    private void assignOptyTeamRoleToTaskOwner(task__c task)
    {
        String optyId=[SELECT Opportunity__r.id  FROM Project__c where Id=:projectId limit 1].Opportunity__r.id;  
        system.debug('optyId:::::' + optyId);
        optyRoleList =[SELECT Id, Role__c, user__c, Opportunity__c FROM Opportunity_Team__c where Opportunity__c=:optyId];
        for(Opportunity_Team__c optyRole : optyRoleList) {
            If(optyRole.Role__c==task.Group_Name__c)
            {
                task.Task_Owner__c= optyRole.user__c;
            }
        }
        update task;
    } 
    
    public  void saveAdhocTask(){

       System.Savepoint sp1 = Database.setSavepoint();
       try{
       
               editModeSec = false;
               upsert newTask;
               system.debug('Inserted Task:: '+newTask);
               String message ='Task Cloned Successfully';
               ApexPages.Message myMsg = new ApexPages.Message(ApexPages.severity.Info, 'Success', message);
               ApexPages.addMessage(myMsg);
               if(newTask.id != null)
                   newTask = [select id, name, Type__c,Status__c,Notify_Owner__c,Phase__r.name,Group_Name__c,Task_Description__c,phase__r.Project__r.name,Task_Owner__c, Project_Name__c,
                              Category__c,Open_Date__c,Start_Date__c,Reason__c,Sub_Reason__c from task__c where id =: newTask.Id]; 
               assignOptyTeamRoleToTaskOwner(newTask);
           
       } catch (System.DmlException e) {
            system.debug('error: ' + e);
            Database.rollback(sp1);
            for (Integer i=0; i < e.getNumDml(); i++) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, e.getDmlMessage(i)));
            } 
       } catch(Exception e){
        ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error, e.getmessage() ));
            }
            
    }
    
        // show all open tasks related to a project
   /* public list<task__c> getShowOpenTasks(){
        if(projectId != null){
            openTasks = [select Id, Name, Status__c,Open_Date__c,Start_Date__c, Category__c ,Project_Name__c from task__c 
                         where Project_Name__c =:projectId and Status__c ='Open'] ;  
        }
        return openTasks;
    }*/
    

    
}