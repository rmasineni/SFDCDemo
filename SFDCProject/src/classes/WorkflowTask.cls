public class WorkflowTask {

  public Id taskId{get;set;}
  public Id projectId{get;set;}
  public string notes{get;set;}
  public boolean showEdit{get;set;}
  public boolean showTaskComplete{get;set;}
  public boolean showReopen{get;set;}
  public boolean isStandardTask{get;set;}  
  public string pageType {get;set;}
  public Task__c taskObj{get;set;}
  public ServiceContract scObj{get;set;}
  public Opportunity optyObj{get;set;}
  public Proposal__c proposalObj{get;set;}
  public Service_Contract_Event__c sceObj{get;set;}
  public Account accountObj{get;set;}
  public Contact contactObj{get;set;}
  public boolean showBlock{get;set;}
  public boolean showFields{get;set;}
  public boolean showPredecessors{get;set;}
  public boolean showSuccessors{get;set;}
  public string notesLabel{get;set;}
  public string projectNotesLabel{get;set;}
  public List<Task__c> predecessorTaskList{get;set;}
  public List<Task__c> successorTaskList{get;set;}
  public string categroyLabel{get;set;}
  public Service_Contract_Partner_Rel__c scprObj{get;set;}  
  public Project__c  projectObj{get;set;}  
  public boolean showOnHold{
    get{
      if(taskObj != null && (taskObj.status__c == wfUtil.OPEN || taskObj.status__c == wfUtil.ON_HOLD)){
        return true;
      }
      return false;
    }
    set;
  }
  public boolean showTaskDependency{get; set;}

  Map<String, sObject> objectMap;
  Map<String, Set<String>> updateObjectFieldMap;
  Set<String> requiredFields;
  Map<String, Set<String>> displayObjectFieldMap;

  Map<String, string> objectVariableMap;

    Public WorkflowTask(ApexPages.StandardController controller){
        try{
            taskObj = (Task__c) controller.getRecord();
            taskId = taskObj.Id;
            initialize();           
        }catch(Exception exceptionObj){
          showFields = false;
            String errorMessage = exceptionObj.getMessage();
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,errorMessage));
        }
    }
  
  public WorkflowTask() { 
    
    try{
      initialize();  
    }catch(Exception exceptionObj){
      showFields = false;
            String errorMessage = exceptionObj.getMessage();
            System.debug('Error Message: ' + errorMessage);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'Unable to read task details'));      
    }

    
    //Test code
    /*

    objectMap.put('Service_Contract_Event__c', sceObj);
    objectMap.put('ServiceContract', scObj);
    Set<String> fieldSet1 = new Set<String>();
    fieldSet1.add('Installation_Type__c');
    fieldSet1.add('Large_system_NTP_form__c');

    Set<String> fieldSet2 = new Set<String>();
    fieldSet2.add('Attached_Home_Approved__c');
    fieldSet2.add('Facility_Design_Approved__c');
    fieldSet2.add('NTP_Granted__c');
        
    updateObjectFieldMap.put('ServiceContract', fieldSet1);
    updateObjectFieldMap.put('Service_Contract_Event__c', fieldSet2);
    sceObj.NTP_Granted__c = Date.today();
    scObj.Large_system_NTP_form__c  =true;

    Set<String> fieldSet3 = new Set<String>();
    fieldSet3.add('Installation_Type__c');
    fieldSet3.add('Large_system_NTP_form__c');

    Set<String> fieldSet4 = new Set<String>();
    fieldSet4.add('Attached_Home_Approved__c');
    fieldSet4.add('Facility_Design_Approved__c');
    fieldSet4.add('NTP_Granted__c');
        
    displayObjectFieldMap.put('ServiceContract', fieldSet3);
    displayObjectFieldMap.put('Service_Contract_Event__c', fieldSet4);
    */
    
  }
  
  public PageReference showSC() {
    return null;
  }

  public PageReference viewTask() {
    String baseUrl = EDPUtil.getBaseURL();
    String viewURL = baseUrl + '/apex/wfTask_View?id=' + taskId + '&retURL=%2F' + taskId + '&&sfdc.override=1' ;
    PageReference ref = new PageReference(viewURL);
    ref.setRedirect(true);
    return ref;    
  }  

  public PageReference editTask() {
    if(!isTaskOwner(taskObj.Task_Owner__c)){
      ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Only task owners or group members can update or close the task'));
      return null;
    }    
    String editURL = '/' + taskId + '/e?retURL=' +  '/' + taskId ;
    PageReference ref = new PageReference(editURL);
    ref.setRedirect(true);
    return ref;
  }

  public PageReference toggleTaskCategory(){
    PageReference returnValue = null;
    try{
      if(taskObj.category__c == wfUtil.OPTIONAL){
        taskObj.category__c = wfUtil.REQUIRED;
        WorkflowManagement wfObj = new WorkflowManagement();
        String actionName =  wfUtil.CATEGORY_CHANGE;
        String reasonStr = 'Task category has been modified from Optional to Required';
        String result = wfObj.updateTaskCategoryImpl(taskObj, actionName, reasonStr);
        if(result != null && result != ''){
          ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, result));
          System.debug('TEST1 ....');
          return null;          
        }
      }else{
        taskObj.category__c = wfUtil.OPTIONAL;
        taskObj.start_date__c = null;
        taskObj.End_date__c = null;
        taskObj.Status__c = wfUtil.INACTIVE;
        taskObj.Expected_Close_Date__c = null;
        taskObj.Expected_Close_Date2__c = null;
        update taskObj;

        //Set<Id> taskIds = new Set<Id>();
        //taskIds.add(taskObj.Id);
        //WorkflowManagement wfObj = new WorkflowManagement();
        //wfObj.startChildTasksImpl(taskIds);
      }
      returnValue = viewTask();
    }catch(Exception exceptionObj){
            String errorMessage = exceptionObj.getMessage();
            System.debug('Error Message: ' + errorMessage);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'Unable modify the task category'));  
    }
    initializeButtonDisplay();
    return returnValue;    
  }

  public PageReference reOpenTask(){
    /*
    Transient Savepoint sp;
    try{
      sp = Database.setSavepoint();
      Set<Id> taskIds = new Set<Id>();
      taskIds.add(taskObj.Id);
      WorkflowManagement.reopenTasks(taskIds);
      showEdit = true;
      showTaskComplete = true;
      showReopen = false;
      return viewTask();
    }catch(Exception exceptionObj){
            String errorMessage = exceptionObj.getMessage();
            System.debug('Error Message: ' + errorMessage);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'Unable to save task details'));
      Database.rollback(sp);    
    }
    */
    return null;    
  }

  public PageReference saveRelatedObjects(){
    if(!isTaskOwner(taskObj.Task_Owner__c)){
      ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Only task owners or group members can update or close the task'));
      return null;
    }
    Transient Savepoint sp;
    try{
      
      sp = Database.setSavepoint();
      for(String objectName : updateObjectFieldMap.keySet()){
        SObject tempSObject = objectMap.get(objectName);
        if(tempSObject != null && tempSObject.Id != null){
          System.debug('?????? ' + tempSObject);
          update tempSObject;
        }else{
           ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, objectName + ' is not null. Please create ' + objectName + ' to save the value.'));
        }
      }
      
      if(taskObj.Has_Dependent_Rules__c == true){
        Workflowmanagement.processsUpdateRules(taskObj, objectMap);
      }
      
      if(taskObj.Task_Owner__c == null){
        taskObj.Task_Owner__c = UserInfo.getUserId();
        update taskObj;
      }
      
      return viewTask();
    }catch(Exception exceptionObj){
            String errorMessage = exceptionObj.getMessage();
            System.debug('Error Message: ' + errorMessage);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'Unable to save task details'));
      Database.rollback(sp);    
    }
    return null;    
  }

  public string getObjectLabel(String objectName){
    String label = objectName;
    if(objectName == 'Service_Contract_Event__c'){
      label = 'Service Contract';
    }if(objectName == 'Proposal__c'){
      label = 'Proposal';
    }if(objectName == 'Service_Contract_Partner_Rel__c'){
        label = 'Related Partner';
    }if(objectName == 'Project__c'){
      label = 'Project';
    }
    return label;
  }


  public PageReference taskSave() {
    if(!isTaskOwner(taskObj.Task_Owner__c)){
      ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Only task owners or group members can update or close the task'));
      return null;
    }
    
    Transient Savepoint sp;
    try{
      sp = Database.setSavepoint();
      for(String objectName : updateObjectFieldMap.keySet()){
        SObject tempSObject = objectMap.get(objectName);
        if(tempSObject != null && tempSObject.Id != null){
          System.debug('?????? ' + tempSObject);
          Set<String> updateFields = updateObjectFieldMap.get(objectName);
          if(updateFields != null && !updateFields.isEmpty()){
            for(String fieldName : updateFields ){
              System.debug(String.valueOf(tempSObject.get(fieldName)));
              if(requiredFields != null && requiredFields.contains(fieldName) && 
                (tempSObject.get(fieldName) == null || (String.valueOf(tempSObject.get(fieldName)) == '') 
                  || (String.valueOf(tempSObject.get(fieldName)) == 'null'))){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Enter values for the required fields.'));
                return null;
              }              
            }
          }          
          update tempSObject;
        }else{
          String errorMessage = 'No ' + getObjectLabel(objectName) + ' exists for this project. Please make sure a ';
          errorMessage += getObjectLabel(objectName) + ' exists before completing this task.';
          ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, errorMessage));
          return null;
        }
      }
      taskObj.status__c = wfUtil.CLOSED;
      taskObj.End_Date__c = Datetime.now(); 
      taskObj.OnHoldEndDate__c = null;
      taskObj.On_Hold_Reason__c = '';
      if(taskObj.Task_Owner__c == null){
        taskObj.Task_Owner__c = UserInfo.getUserId();
      }
      update taskObj;
      showEdit = false;
      showTaskComplete = false;
      showReopen = true;
      System.debug('taskObj.status__c: ' + taskObj.status__c);
      if(taskObj.Has_Dependent_Rules__c == true){
        Workflowmanagement.processsUpdateRules(taskObj, objectMap);
      }
      Set<Id> taskIds = new Set<Id>();
      taskIds.add(taskObj.Id);
      WorkflowManagement.startChildTasks(taskIds);
      return viewTask();
    }catch(Exception exceptionObj){
            String errorMessage = exceptionObj.getMessage();
            System.debug('Error Message: ' + errorMessage);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'Unable to save task details'));
      Database.rollback(sp);    
    }
    return null;
  }  
  
  public void initialize(){
    showFields = true;
    showPredecessors = false;
    showSuccessors = false;
    showEdit = false;
    showReopen = false;
    showBlock = true;
    isStandardTask = false;
    
    scObj = new ServiceContract();
    sceObj = new Service_Contract_Event__c();
    scprObj = new Service_Contract_Partner_Rel__c();
    projectObj =  new Project__c();
    objectMap = new Map<String, sObject>();
    updateObjectFieldMap = new Map<String, Set<String>>();
    displayObjectFieldMap = new Map<String, Set<String>>();
    requiredFields = new Set<String>();
    predecessorTaskList = new List<Task__c>();
    successorTaskList = new List<Task__c>();

    objectVariableMap = new Map<String, string>();
    objectVariableMap.put('Service_Contract_Event__c', 'sceObj');
    objectVariableMap.put('ServiceContract', 'scObj');
    objectVariableMap.put('Opportunity', 'optyObj');
    objectVariableMap.put('Proposal__c', 'proposalObj');  
    objectVariableMap.put('Account', 'accountObj');
    objectVariableMap.put('Contact', 'contactObj');
    objectVariableMap.put('Service_Contract_Partner_Rel__c', 'scprObj');
    objectVariableMap.put('Project__c', 'projectObj');  
      
    taskId = System.currentPagereference().getParameters().get('Id');
    taskObj = [Select Phase__r.Id, Phase__r.Project__r.Type__c, status__c, Phase__r.project__r.Id, Phase__r.project__r.Proposal__c, phase__r.project__r.Service_Contract__c, OnHoldEndDate__c, 
            phase__r.project__r.Opportunity__c, phase__r.project__r.Service_Contract_Event_Name__c, Phase__r.project__r.Proposal_Name__c, Phase__r.project__r.Opportunity_Name__c,
             phase__r.project__r.Service_Contract_Event__c,Task_Description__c, Phase__r.project__r.Job_Code__c, Phase__r.project__r.Service_Contract_Name__c, Task_Owner__c, SLA_In_Hours__c, 
             sla_status__c, Start_Date__c,End_Date__c,reopen__c,Type__c, Has_Dependent_Rules__c, Project_Name__c,
             Related_Task__c, Name, Group_Name__c, Category__c, phase__r.name, phase__r.project__r.name, description__c,Reason__c, Sub_Reason__c,
            
            Display_Field1__c, Display_Field2__c, Display_Field3__c, Display_Field4__c, Display_Field5__c,
            Display_Object1__c, Display_Object2__c, Display_Object3__c,  Display_Object4__c, Display_Object5__c,
            Object_Name1__c, Object_Name2__c, Object_Name3__c,  Object_Name4__c, Object_Name5__c,
            Field_Name1__c, Field_Name2__c, Field_Name3__c, Field_Name4__c, Field_Name5__c, 
            
            Display_Field11__c, Display_Field12__c, Display_Field13__c, Display_Field14__c, Display_Field15__c,
            Display_Object11__c, Display_Object12__c, Display_Object13__c,  Display_Object14__c, Display_Object15__c,
            Object_Name11__c, Object_Name12__c, Object_Name13__c,  Object_Name14__c, Object_Name15__c,
            Field_Name11__c, Field_Name12__c, Field_Name13__c, Field_Name14__c, Field_Name15__c, 
            
            Display_Field6__c, Display_Field7__c, Display_Field8__c, Display_Field9__c, Display_Field10__c,
            Display_Object6__c, Display_Object7__c, Display_Object8__c,  Display_Object9__c, Display_Object10__c,
            Object_Name6__c, Object_Name7__c, Object_Name8__c,  Object_Name9__c, Object_Name10__c,
            Field_Name6__c, Field_Name7__c, Field_Name8__c, Field_Name9__c, Field_Name10__c, 
            Display_Field16__c, Display_Field17__c, Display_Field18__c, Display_Field19__c, Display_Field20__c,
            Display_Object16__c, Display_Object17__c, Display_Object18__c,  Display_Object19__c, Display_Object20__c,
            Object_Name16__c, Object_Name17__c, Object_Name18__c,  Object_Name19__c, Object_Name20__c,
            Field_Name16__c, Field_Name17__c, Field_Name18__c, Field_Name19__c, Field_Name20__c, 
             
            Req1__c,Req2__c,Req3__c, Req4__c, Req5__c, Req11__c,Req12__c,Req13__c, Req14__c, Req15__c, 
            Req6__c,Req7__c,Req8__c, Req9__c, Req10__c,Req16__c,Req17__c,Req18__c, Req19__c, Req20__c        
             from Task__C where Id =:taskId];
    initializeButtonDisplay();    
    notesLabel = 'New Note (' + wfUtil.getNotesCount(taskObj.Id, 'Task') + ')';
    projectNotesLabel = 'View All Notes (' + wfUtil.getNotesCount(taskObj.Phase__r.project__r.Id, 'All') + ')';
    categroyLabel = (taskObj.category__c == wfUtil.OPTIONAL) ? 'Make ' +  wfUtil.REQUIRED : 'Make ' + wfUtil.OPTIONAL;
    projectId = taskObj.phase__r.project__r.Id;
   // if(taskObj.status__c == wfUtil.BLOCKED || taskObj.status__c == wfUtil.INACTIVE){
      initializepredecessors();
      initializesuccessors();
   // }
    
    for(Integer i=1; i<=20; i++){
      String field1 = 'Display_Object' + i + '__c';
      String field2 = 'Display_Field' + i + '__c';
      String field3 = 'Object_Name' + i + '__c';
      String field4 = 'Field_Name' + i + '__c';
      String field5 = 'Req' + i + '__c';
      
      Object objectValue3 = taskObj.get(field3);
      Object objectValue4 = taskObj.get(field4);
      Object objectValue5 = taskObj.get(field5);
      Boolean required = (objectValue5 == null) ? false : (boolean)objectValue5;
      String fieldNameStr =  (objectValue4 == null) ? '' : (String)objectValue4;
      if(required && fieldNameStr != ''){
        requiredFields.add(fieldNameStr);
      }
      System.debug('requiredFields: ' + requiredFields);
      wfUtil.initObjectFieldMap(taskObj.get(field1), taskObj.get(field2), displayObjectFieldMap);
      wfUtil.initObjectFieldMap(objectValue3, objectValue4, updateObjectFieldMap);
    }

    Set<String> objectNames = new Set<String>();
    objectNames.addall(updateObjectFieldMap.keySet());
    objectNames.addall(displayObjectFieldMap.keySet());
    initSObjectMap(objectNames);
    
  }
  
  public void initializeButtonDisplay(){
    showTaskComplete = false;
    showEdit = false;
    if(taskObj.status__c == wfUtil.OPEN || taskObj.status__c == wfUtil.BLOCKED 
      || taskObj.status__c == wfUtil.WAIT || taskObj.status__c == wfUtil.ON_HOLD){
      showEdit = true;
    }
      if(taskObj.Type__c == wfUtil.StandardTask) {
          isStandardTask = true;
      }
    if(taskObj.status__c == wfUtil.CLOSED){
      showReopen = true;
      showBlock = false;
    }
    if(taskObj.status__c == wfUtil.INACTIVE || taskObj.category__c == wfUtil.OPTIONAL){
      showBlock = false;
    }
    if(taskObj.status__c == wfUtil.OPEN || taskObj.status__c == wfUtil.WAIT || taskObj.status__c == wfUtil.ON_HOLD){
      showTaskComplete = true;
    } 
        if( taskObj.type__c == wfUtil.ADHOC && (taskObj.status__c == wfUtil.OPEN || taskObj.status__c == wfUtil.WAIT || taskObj.status__c == wfUtil.ON_HOLD )){
            showTaskDependency = true;
        }
  }

  public void initializepredecessors(){
    String requiredStr = wfUtil.REQUIRED;
    String closedStr = wfUtil.CLOSED;
    for(Task_Dependency__c tdObj : [Select Id, task__c, Parent_Task__r.Id, Parent_Task__r.Name, Parent_Task__r.status__c,
                    Parent_Task__r.group_name__c, Parent_Task__r.Task_Owner__r.Name, Parent_Task__r.phase__r.name
                    from Task_Dependency__c where task__c =:taskId and Parent_Task__C != null
                    //and Parent_Task__r.status__c !=:closedStr
                    and Parent_Task__r.category__c =:requiredStr ORDER BY Parent_Task__r.Name
                   ]){
      predecessorTaskList.add(tdObj.Parent_Task__r); 
      showPredecessors = true;
    }
  }
    public void initializesuccessors(){
    String requiredStr = wfUtil.REQUIRED;
    String closedStr = wfUtil.CLOSED;
    for(Task_Dependency__c tdObj1 : [Select Id, task__c, task__r.Id, task__r.Name, task__r.status__c,
                    task__r.group_name__c, task__r.Task_Owner__r.Name, task__r.phase__r.name
                    from Task_Dependency__c where parent_task__c =:taskId and task__c != null
                    //and task__r.status__c !=:closedStr
                    and task__r.category__c =:requiredStr ORDER BY task__r.Name
                    ]){
      successorTaskList.add(tdObj1.task__r);
      showSuccessors = true;
    }
  }

  private String getSOQLFields(String objectName){
    System.debug('**** objectName: ' + objectName);
    String result = '';
    if(updateObjectFieldMap.containsKey(objectName)){
      for(String fieldName : updateObjectFieldMap.get(objectName)){
        result += fieldName + ', ' ;
      }      
    }
    System.debug('result1: ' + result);
    if(displayObjectFieldMap.containsKey(objectName)){
      for(String fieldName : displayObjectFieldMap.get(objectName)){
        if(!result.contains(fieldName))
          result += fieldName + ', ' ;
      }      
    }
    System.debug('result2: ' + result);
    return result;
  }

  public void initSObjectMap(Set<String> objectNames){
    
    String tempObjectName = 'Proposal__c';
    proposalObj = new Proposal__c();
    if(taskObj.phase__r.project__r.Proposal__c != null){
      String tempProposalId = taskObj.phase__r.project__r.Proposal__c;
      String tempResult = getSOQLFields(tempObjectName);
      String proposalSOQLStr = 'Select ' + tempResult + ' Id from ' + tempObjectName + ' where Id =:tempProposalId ';
      List<Proposal__c> proposalsList = Database.query(proposalSOQLStr);
      if(proposalsList != null && !proposalsList.isEmpty()){
        proposalObj = proposalsList[0];
      }
    }
    objectMap.put(tempObjectName, proposalObj);

    tempObjectName = 'ServiceContract';
    scObj = new ServiceContract();
    if(taskObj.phase__r.project__r.Service_Contract__c != null){
      String tempObjectId = taskObj.phase__r.project__r.Service_Contract__c;
      String tempResult = getSOQLFields(tempObjectName);
      String soqlStr = 'Select ' + tempResult + ' Id from ' + tempObjectName + ' where Id =:tempObjectId ';
      List<ServiceContract> scList = Database.query(soqlStr);
      if(scList != null && !scList.isEmpty()){
        scObj = scList[0];
      }
    }
    objectMap.put(tempObjectName, scObj);

    tempObjectName = 'Service_Contract_Event__c';
    sceObj = new Service_Contract_Event__c();
    if(taskObj.phase__r.project__r.Service_Contract_Event__c != null && taskObj.phase__r.project__r.Service_Contract_Event__c != ''){
      String tempObjectId = taskObj.phase__r.project__r.Service_Contract_Event__c;
      String tempResult = getSOQLFields(tempObjectName);
      String soqlStr = 'Select ' + tempResult + ' Id from ' + tempObjectName + ' where Id =:tempObjectId ';
      List<Service_Contract_Event__c> sceList = Database.query(soqlStr);
      if(sceList != null && !sceList.isEmpty()){
        sceObj = sceList[0];
      }
    }
    objectMap.put(tempObjectName,sceObj);

    String primaryContactId = '';
    tempObjectName = 'Opportunity';
    optyObj = new Opportunity();
    if(taskObj.phase__r.project__r.Opportunity__c != null){
      String tempObjectId = taskObj.phase__r.project__r.Opportunity__c;
      String tempResult = getSOQLFields(tempObjectName);
      if(tempResult != null && !tempResult.contains('AccountId,')){
        tempResult += 'AccountId, '; 
      }
      String soqlStr = 'Select ' + tempResult + ' Id, (Select Id, contactId, OpportunityId, isPrimary from OpportunityContactRoles ) from ' + tempObjectName + ' where Id =:tempObjectId ';
      List<Opportunity> optyList = Database.query(soqlStr);
      if(optyList != null && !optyList.isEmpty()){
        optyObj = optyList[0];
        for(OpportunityContactRole roleObj : optyObj.OpportunityContactRoles){
          if(primaryContactId == '' && roleObj.contactId != null){
            primaryContactId = roleObj.contactId;
          }
          
          if(roleObj.contactId != null && roleObj.isPrimary == true){
            primaryContactId = roleObj.contactId;
          }
        }
        System.debug('primaryContactId: ' + primaryContactId);
      }
    }
    objectMap.put(tempObjectName, optyObj);

    tempObjectName = 'Account';
    accountObj = new Account();
    if(optyObj != null && optyObj.Id != null && optyObj.AccountId != null){
      String tempObjectId = optyObj.AccountId;
      String tempResult = getSOQLFields(tempObjectName);
      String soqlStr = 'Select ' + tempResult + ' Id from ' + tempObjectName + ' where Id =:tempObjectId ';
      List<Account> accountList = Database.query(soqlStr);
      if(accountList != null && !accountList.isEmpty()){
        accountObj = accountList[0];
      }
    }
    objectMap.put(tempObjectName, accountObj);
    
    tempObjectName = 'Contact';
    contactObj = new Contact();
    if(primaryContactId != null){
      String tempObjectId = primaryContactId;
      System.debug('tempObjectId: ' + tempObjectId);
      String tempResult = getSOQLFields(tempObjectName);
      if(tempResult != null && !tempResult.contains('Name,')){
        tempResult += 'Name, '; 
      }
      String soqlStr = 'Select ' + tempResult + ' Id from ' + tempObjectName + ' where Id =:tempObjectId ';
      List<Contact> contactList = Database.query(soqlStr);
      if(contactList != null && !contactList.isEmpty()){
        contactObj = contactList[0];
      }
    }
    objectMap.put('Contact', contactObj);
     //Service_Contract_Partner_Rel__c
     tempObjectName = 'Service_Contract_Partner_Rel__c';
     scprObj = new Service_Contract_Partner_Rel__c();
      If(taskObj.phase__r.project__r.Service_Contract__c!=null){
        String serviceContractID = taskObj.phase__r.project__r.Service_Contract__c;
          List<Service_Contract_Partner_Rel__c> tempObjectList = new List<Service_Contract_Partner_Rel__c>();
       If(taskObj.Name==wfutil.PREPAREELESUB || taskObj.Name==wfutil.ELESUBSIGNED){   
           tempObjectList = [select Id from Service_Contract_Partner_Rel__c where servicecontract__c=:serviceContractID  and Type__c=: wfutil.ELECTRICAL_SUB];
       }
        If(taskObj.Name==wfutil.SOLARWATERPROOFSIGNED || taskObj.Name==wfutil.PREPARESOLARWATERPROOF){  
           tempObjectList = [select Id from Service_Contract_Partner_Rel__c where servicecontract__c=:serviceContractID  and Type__c=: wfutil.SOLARWATERPROOFING];
        }
        If(taskObj.Name==wfutil.INSTALLPACKAGESIGNED || taskObj.Name==wfutil.PREPAREINSTALLPACKAGE||   
           taskObj.Name==wfutil.GRANTINSTALLAPPROVAL || taskObj.Name==wfutil.COMPPACKAGE){
               tempObjectList = [select Id from Service_Contract_Partner_Rel__c where servicecontract__c=:serviceContractID  and Type__c=: wfutil.BUILDPARTNER];
           }
             If(!tempObjectList.isEmpty()){   
                 String tempObjectId = tempObjectList[0].Id;
                 String tempResult = getSOQLFields(tempObjectName);
                 String soqlStr = 'Select ' + tempResult + ' Id from ' + tempObjectName + ' where Id =:tempObjectId ';
                  List<Service_Contract_Partner_Rel__c> scprList = Database.query(soqlStr);
                 if(scprList != null && !scprList.isEmpty()){
                        scprObj = scprList[0];
                 }   
             }
      }
      objectMap.put(tempObjectName,scprObj);
      
      //Project__c 
      tempObjectName = 'Project__c';
      projectObj = new Project__c();
      if(taskObj.phase__r.project__c != null){
          String tempProjectId = taskObj.phase__r.project__c;
      String tempResult = getSOQLFields(tempObjectName);
      String projectSOQLStr = 'Select ' + tempResult + ' Id from ' + tempObjectName + ' where Id =:tempProjectId ';
      List<Project__c> projectList = Database.query(projectSOQLStr);
      if(projectList != null && !projectList.isEmpty()){
          projectObj = projectList[0];
      }
      }
    objectMap.put(tempObjectName, projectObj);      
          
  }
  
  public Component.Apex.Pageblocksection getTaskDisplayFields(){
    //Information-1
    Component.Apex.Pageblocksection pbSection = new Component.Apex.Pageblocksection(title='Task Display Fields', columns=1, collapsible=false);
    for(String objectName : displayObjectFieldMap.keySet()){
      Sobject tempSobject = objectMap.get(objectName);
      String objectVariableName = objectVariableMap.get(objectName);
      Set<String> filedNames = displayObjectFieldMap.get(objectName);
      if(filedNames != null && !filedNames.isEmpty()){
        for(String fieldName : filedNames ){
          String expressionStr = '{!' + objectVariableName + '.' + fieldName + '}' ;
          String labelStr = '{!$ObjectType.' + objectName + '.fields.' + fieldName + '.label}' ;
          System.debug('expressionStr : '  + expressionStr );
          
          //sectionItemLabel
          Component.Apex.PageBlockSectionItem pbsItem = new Component.Apex.PageBlockSectionItem(labelStyle='text-align:right; width: 40%; max-width: 40%;border-bottom: none;',  dataStyle='text-align:left; width: 60%; max-width: 60%;border-bottom: none;') ;
          //Component.Apex.PageBlockSectionItem pbsItem = new Component.Apex.PageBlockSectionItem(labelStyleClass ='sectionItemLabel',  dataStyleClass='sectionItemData') ;
          Component.Apex.OutputLabel outputLabel = new Component.Apex.OutputLabel();
          outputLabel.expressions.value = labelStr;
          pbsItem.childComponents.add( outputLabel);

          Component.Apex.Outputfield outputField = new Component.Apex.Outputfield();
          outputField.expressions.value = expressionStr;
          pbsItem.childComponents.add( outputField);
          
          //Component.Apex.Outputfield outputField = new Component.Apex.Outputfield();
          //outputField.expressions.value = expressionStr;
          
          
          pbSection.childComponents.add( pbsItem);  
        }
      }    
    }
    return pbSection;
    }

  public Component.Apex.Pageblocksection getViewFields(){
    //Information-2
    Component.Apex.Pageblocksection pbSection = new Component.Apex.Pageblocksection(title='Task Update Fields', columns=2,collapsible=false);
    for(String objectName : updateObjectFieldMap.keySet()){
      System.debug('objectName: ' + objectName);
      Sobject tempSobject = objectMap.get(objectName);
      System.debug('tempSobject: ' + tempSobject);
      String objectVariableName = objectVariableMap.get(objectName);
      Set<String> filedNames = updateObjectFieldMap.get(objectName);
      if(filedNames != null && !filedNames.isEmpty()){
        for(String fieldName : filedNames ){
          String expressionStr = '{!' + objectVariableName + '.' + fieldName + '}' ;
          System.debug('expressionStr : '  + expressionStr );

          String labelStr = '{!$ObjectType.' + objectName + '.fields.' + fieldName + '.label}' ;
          System.debug('labelStr : '  + labelStr );
          
          Component.Apex.PageBlockSectionItem pbsItem = new Component.Apex.PageBlockSectionItem(labelStyle='text-align:right; width: 20%; max-width: 20%;border-bottom: none;',  dataStyle='text-align:left; width: 20%; max-width: 20%;border-bottom: none;') ;
          Component.Apex.OutputLabel outputLabel = new Component.Apex.OutputLabel();
          outputLabel.expressions.value = labelStr;
          pbsItem.childComponents.add( outputLabel);

          Component.Apex.Outputfield outputField = new Component.Apex.Outputfield();
          outputField.expressions.value = expressionStr;
          pbsItem.childComponents.add( outputField);
          pbSection.childComponents.add( pbsItem);
          //Component.Apex.Outputfield outputField = new Component.Apex.Outputfield();
          //outputField.expressions.value = expressionStr;
          //pbSection.childComponents.add( outputField );  
        }
      }    
    }
    return pbSection;
    }

  public Component.Apex.Pageblocksection getTaskEditFields(){
    //Information-2
    Component.Apex.Pageblocksection pbSection = new Component.Apex.Pageblocksection(title='Task Update Fields', columns=1,collapsible=false);
    for(String objectName : updateObjectFieldMap.keySet()){
      System.debug('objectName: ' + objectName);
      Sobject tempSobject = objectMap.get(objectName);
      System.debug('tempSobject: ' + tempSobject);
      String objectVariableName = objectVariableMap.get(objectName);
      Set<String> filedNames = updateObjectFieldMap.get(objectName);
      if(filedNames != null && !filedNames.isEmpty()){
        for(String fieldName : filedNames ){
          String expressionStr = '{!' + objectVariableName + '.' + fieldName + '}' ;
          System.debug('expressionStr : '  + expressionStr );

          String labelStr = '{!$ObjectType.' + objectName + '.fields.' + fieldName + '.label}' ;
          System.debug('labelStr : '  + labelStr );
          
          Component.Apex.PageBlockSectionItem pbsItem = new Component.Apex.PageBlockSectionItem(labelStyle='text-align:right; width: 40%; max-width: 40%; border-bottom: none;',  dataStyle='text-align:left; width: 60%; max-width: 60%;border-bottom: none;') ;

          if(!requiredFields.contains(fieldName)){
            Component.Apex.OutputLabel outputLabel = new Component.Apex.OutputLabel();
            outputLabel.expressions.value = labelStr;
            pbsItem.childComponents.add( outputLabel);
  
            Component.Apex.InputField inputfiled1 = new Component.Apex.InputField(value=tempSoBject.get(fieldName));
            inputfiled1.expressions.value = expressionStr;
            pbsItem.childComponents.add( inputfiled1);
            pbSection.childComponents.add( pbsItem );
          }else{
            Component.Apex.Outputpanel outputpanel = new Component.Apex.Outputpanel();
            Component.Apex.OutputLabel outputLabel = new Component.Apex.OutputLabel();
            outputLabel.expressions.value = labelStr;
            outputpanel.childComponents.add( outputLabel);
            pbsItem.childComponents.add( outputpanel);

            Component.Apex.Outputpanel outputpanel2 = new Component.Apex.Outputpanel(layout='block', styleClass='requiredInput');
            Component.Apex.Outputpanel outputpanel3 = new Component.Apex.Outputpanel(layout='block', styleClass='requiredBlock');
            outputpanel2.childComponents.add( outputpanel3);
            
            if(tempSoBject != null){
              Component.Apex.InputField inputfiled1 = new Component.Apex.InputField(value=tempSoBject.get(fieldName));
              inputfiled1.expressions.value = expressionStr;            
              outputpanel2.childComponents.add( inputfiled1);
            }
            pbsItem.childComponents.add( outputpanel2);
            pbSection.childComponents.add( pbsItem );            
          }  
        }
      }    
    }
    return pbSection;
    }

  public Boolean isTaskOwner(Id taskOner){
    Id userId = UserInfo.getUserId();
    Boolean result = false;
      Set<Id> userIds = new Set<Id>();
      userIds.add(userId);
    Map<Id, Set<String>> userGroupMap = wfUtil.getUserGroups(userIds);    
    Set<String> userGroups = userGroupMap.get(userId);
    if((taskObj.Task_Owner__c == userId ) || (taskObj.Task_Owner__c == null && userGroups != null && userGroups.contains(taskObj.Group_Name__c))){
      result = true;
    }
    return result;
  }

    public String getBaseURL() {
        String baseURL = EDPUtil.getBaseURL();
        return baseURL;
    }
    
      public PageReference showAdhocTask() {

        PageReference pageRef = page.wfCreateAdhocTaskOnProject; 
        pageRef.getParameters().put('projectID', taskObj.phase__r.project__r.Id);
        pageRef.getParameters().put('id', taskId);
        pageRef.getParameters().put('returnUrl', getPageURL());
        return pageRef ;
        
    }
    public String getPageURL() {    
       
         String pageUrl = getBaseURL()+ '/apex/wfTask_View?id=' + taskId + '&sfdc.override=1' ;
        return pageUrl;
    }
}