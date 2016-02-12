public class wfProjectDetails {
    public string searchString{get;set;}
    public CustomLookup__c customLookup{get;set;}
    public Opportunity optyObj{get;set;}
    public Contact contactObj{get;set;}
    public string  projId {get; set;}
    public Project__c projectObj{
        get;
        set;
    }
    public Boolean showRequired{get;set;}
    public String getBaseURL() {
        String baseURL = EDPUtil.getBaseURL();
        return baseURL;
    }
    public List<PhaseWrapper> phaseWList { get; set; }
    Integer counter {get;set;}
    public boolean showBlockButton{get; set;}
    
    Public wfProjectDetails(ApexPages.StandardController controller){
        try{
            showRequired = true;
            if(customLookup == null){
                customLookup = new CustomLookup__c();
            }
            projectObj = (project__c) controller.getRecord();
            customLookup.project__c = projectObj.Id;
            projId = projectObj.Id;
            initialize(); 
        }catch(Exception exceptionObj){
            String errorMessage = exceptionObj.getMessage();
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,errorMessage));
        }
    }   
    
    public wfProjectDetails(){
        if(customLookup == null){
            customLookup = new CustomLookup__c();
        }
        
        String projectId = System.currentPagereference().getParameters().get('Id');
        if(projectId != null && projectId != ''){
            customLookup.project__c = projectId;
        }

        projectObj = new Project__c();
        projectObj.Start_Date__c = null;
        projectObj.End_Date__c = null;
        initialize();
    }
    
    public void initialize(){
        getProjectDetails();
        showBlockButton = true;
        if (projectObj.Status__c == 'Blocked'  )
            showBlockButton = false;
    }

    public void intializeCustomerDetails(){
        String primaryContactId = '';
        if(projectObj.Opportunity__c != null){
            String tempObjectId = projectObj.Opportunity__c;
            String soqlStr = 'Select name, Id, (Select Id, contactId, OpportunityId, isPrimary from OpportunityContactRoles ) from Opportunity where Id =:tempObjectId ';
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
                if(primaryContactId != null && primaryContactId != ''){
                    System.debug('primaryContactId: ' + primaryContactId);
                    soqlStr = 'Select name, email, Id, Phone from Contact where Id =:primaryContactId ';
                    List<Contact> contactList = Database.query(soqlStr);
                    if(contactList != null && !contactList.isEmpty()){
                        contactObj = contactList[0];
                    }
                }
            }
        }
    }
    
    public PageReference cancelEditTask() {
        return getProjectDetails();     
    }

    public PageReference saveTasks() {
        ApexPages.getMessages().clear();
        try{
            Set<Id> modifiedOwnerIds = new Set<Id>();
            Map<Id, Task__c> modifiedTasks = new Map<Id, Task__c>();
            System.debug('projectObj.Type__c: ' + projectObj.Type__c);
            List <task__c> updateTask = new List<task__c> ();
            Map<Id, Task__c> tempTaskMap = new Map<Id, Task__c>([Select Id, Group_Name__c, Task_Owner__c from Task__c where Phase__r.Project__c =:projId]);
            for(PhaseWrapper phaseWObj : phaseWList){
                for(TaskWrapper tskWObj : phaseWObj.taskList){
                    Task__c tempTaskObj = tskWObj.taskObj;
                    Task__C originalTskObj = tempTaskMap.get(tempTaskObj.Id);
                    //updateTask.add(tempTaskObj);
                    if(originalTskObj != null && originalTskObj.Task_Owner__c != tempTaskObj.Task_Owner__c){
                        if(tempTaskObj.Task_Owner__c != null){
                            modifiedOwnerIds.add(tempTaskObj.Task_Owner__c);
                        }
                        modifiedTasks.put(tempTaskObj.Id, tempTaskObj);
                    }
                }
            }
            System.debug('modifiedOwnerIds : ' + modifiedOwnerIds);
            if(!modifiedOwnerIds.isEmpty()){
                Map<Id, Set<String>> userGroups = wfUtil.getUserGroups(modifiedOwnerIds);
                System.debug('userGroups : ' + userGroups);
                for(Task__c tskObj : modifiedTasks.values()){
                    if(tskObj.Task_Owner__c != null){
                        System.debug('tskObj.Task_Owner__c : ' + tskObj.Task_Owner__c);
                        Set<String> groupNames = userGroups.get(tskObj.Task_Owner__c);
                        System.debug('groupNames : ' + groupNames);
                        if(groupNames == null || !groupNames.contains(tskObj.Group_Name__c)){
                             ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Task owner doesn\'t belongs to the task group'));
                             return null;
                        }
                    }
                }
            }
            System.debug('Size: ' + updateTask.size());
            if(!modifiedTasks.isEmpty()){
                update modifiedTasks.values();
            }
        }catch(DMLException exceptionObj){
            String errorMessage = exceptionObj.getMessage();
            ApexPages.addMessages(exceptionObj);
        }catch(Exception exceptionObj){
            String errorMessage = exceptionObj.getMessage();
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,errorMessage));
        }       
        return null;
    }
    
    public Pagereference initializeProjectDetails(){
        searchString = '';
        if(customLookup.project__c != null){
            ApexPages.currentPage().getParameters().put('Id', customLookup.project__c);
        }else{
            ApexPages.currentPage().getParameters().put('Id', '');
        }
        return getProjectDetails();
    }
    
    public Pagereference refreshPage(){
        searchString = '';
        return getProjectDetails();
    }
    
    public Pagereference getProjectDetails(){
        Pagereference ref;
        phaseWList = new List<PhaseWrapper>(); 
        if(customLookup.project__c == null){
            String projectId = System.currentPagereference().getParameters().get('Id');
            if(projectId != null && projectId != ''){
                customLookup.project__c = projectId;
            }
        }
        String tempStr = (searchString != null && searchString != '') ? '%' + searchString + '%' : '';
        String categoryStr = (showRequired == true) ? 'Required' : '';
        if(customLookup.project__c != null){
            String projectIdStr = customLookup.project__c;
            projectObj = [Select Id, Type__c, status__C, Opportunity__C, Start_Date__c, End_Date__c, Service_Contract__c, current_phase__c, Proposal__C, Proposal_Name__c, Service_Contract_Name__c,
                                VIP_Customer__c, product_type__c, Sales_Person__c, Opportunity_Name__c, Install_Partner__c, Sales_Partner__c, Build_Parter__c, Install_Branch__c,Agreement_Type__c,
                                Expected_Construction_Start_Date__c, Job_Code__c, Address__c, Service_Contract_Event__c,Service_Contract_Event_Name__c,Project_Age__c,Site_Revisit_Required__c,
                                Service_Contract__r.status__c,  Account__c
                            from Project__C where Id =:customLookup.Project__C];
            
            String phaseSQLStr = 'Select Id, name, project__c , Phase_Number__c, Phase_Status__c from Phase__c where project__c =:projectIdStr ';
            
            if(searchString != null && searchString != ''){
                phaseSQLStr += ' and (name like :tempStr OR Phase_Status__c like :tempStr OR Phase_Number__c like :tempStr ) ';
            }
            
            phaseSQLStr += ' order by Phase_Number__c ';
            List<Phase__c> phaseList = new List<Phase__c>();
            Set<Id> phaseIds = new Set<Id>();
            for(Phase__c phaseObj : Database.query(phaseSQLStr)){
                phaseIds.add(phaseObj.Id);
                phaseList.add(phaseObj);
            }
            
            intializeCustomerDetails();

            String taskSqlStr = 'Select Id, name, sla_status__c, Category__c, Task_Owner__c, Task_Owner__r.Name, Group_Name__c, Status__c, Start_Date__c, End_Date__c, ';
            taskSqlStr += ' Phase__r.Id, Phase__r.name, Phase__r.project__C, Phase__r.Phase_Number__c, Phase__r.Phase_Status__c ';
            taskSqlStr += ' from Task__c where Phase__r.project__c =:projectIdStr' ; 
            if(searchString != null && searchString != ''){
                taskSqlStr += ' and (name like :tempStr OR sla_status__c like :tempStr OR Category__c like :tempStr OR Task_Owner__r.Name like :tempStr OR Group_Name__c like :tempStr OR Status__c like :tempStr) ';
            }
            if(!String.isEmpty(categoryStr)){
                taskSqlStr += ' and category__c =:categoryStr ';
            }
            taskSqlStr += ' order by Phase__r.Phase_Number__c,  Task_Number__c ';
            System.debug(taskSqlStr);
            Map<Id, List<Task__c>> taskMap = new Map<Id, List<Task__c>>();
            for(Task__C taskObj : Database.query(taskSqlStr)){
                List<Task__c> tempTasklList = taskMap.containsKey(taskObj.phase__c) ? taskMap.get(taskObj.phase__c) : new List<Task__c>(); 
                tempTasklList.add(taskObj);
                taskMap.put(taskObj.phase__c, tempTasklList);
                Phase__c phaseObj = taskObj.Phase__r;
                if(!phaseIds.contains(phaseObj.Id) && phaseObj != null && phaseObj.Id != null){
                    phaseIds.add(phaseObj.Id);
                    phaseList.add(phaseObj);                    
                }
            }

            System.debug('phaseList: ' + phaseList);
            for(Phase__c phaseObj : phaseList){
                List<TaskWrapper> twList = new List<TaskWrapper>();
                if(taskMap.containsKey(phaseObj.Id)){
                    List<Task__c> tempTasklList = taskMap.get(phaseObj.Id);
                    for(Task__c taskObj : tempTasklList){
                        twList.add(new TaskWrapper(taskObj));
                    }
                }
                phaseWList.add(new PhaseWrapper(phaseObj,false,twList));
            }
            
            /*
            for(Phase__c phaseObj : [Select Id, name, project__C, Phase_Number__c, Phase_Status__c, 
                                        (Select Id, name, sla_status__c, Category__c, Task_Owner__c, Task_Owner__r.Name, Group_Name__c, Status__c, 
                                            Start_Date__c, End_Date__c from Tasks__r order by Task_Number__c asc) 
                                        from Phase__C where project__C =:projectObj.Id order by Phase_Number__c asc]){
                
                List<TaskWrapper> twList = new List<TaskWrapper>();
                for(Task__c taskObj : phaseObj.Tasks__r){
                    twList.add(new TaskWrapper(taskObj));
                }
                phaseWList.add(new PhaseWrapper(phaseObj,false,twList));
            }
            */
        }
        return ref;
    }


    
    public class PhaseWrapper{
        public Phase__c phaseObj{get;set;}
        public Integer taskCount{
            get{
                return (taskList != null && !taskList.isEmpty()) ? taskList.size() : 0;
            }
            
            set;
       }
        public boolean isSelected{get;set;}
        public List<TaskWrapper> taskList{get;set;}
        public PhaseWrapper(Phase__c pObj,boolean selected, List<TaskWrapper> twList){
            phaseObj=pObj;
            isSelected= selected;
            taskList = twList;            
        }
    }

    public class TaskWrapper{
        public Task__c taskObj{get;set;}
        public boolean isSelected{get;set;}        
        public TaskWrapper(Task__c tObj){
            taskObj=tObj;
            isSelected=false;                       
        }
    }
    
 
    public PageReference newTask() {
      // editModeSec = true;
       PageReference pageRef = page.wfCreateAdhocTaskOnProject;
        
        
       pageRef.getParameters().put('projectID', projId);
      // pageRef.getParameters().put('case',myCase.id);
       return pageRef ;
      
        
    }
    
    
    
    

}