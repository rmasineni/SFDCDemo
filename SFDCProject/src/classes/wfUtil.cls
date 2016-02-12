public class wfUtil {

    public static string OPTIONAL = 'Optional';
    public static string INACTIVE = 'Inactive';
    public static string ON_HOLD = 'On-Hold';
    public static string OPEN = 'Open';
    public static string REQUIRED = 'Required';
    public static string BLOCKED = 'Blocked';
    public static string WAIT = 'Wait';
    public static string CLOSED = 'Complete';
    public static string COMPLETE = 'Complete';
    public static string CANCELLED = 'Cancelled';
    public static string CATEGORY_CHANGE = 'Category Change';
    public static string RE_OPEN = 'Re-Open';
    public static boolean skipTDTrigger = false;
    public static boolean createProject = false;
    public static string ADHOC = 'Adhoc';
    public static string PROJ_BLOCKED = 'Proj-Block';
    public static string ELECTRICAL_SUB= 'Electrical Subcontractor';
    public static string SOLARWATERPROOFING= 'Solar Waterproofing Subcontractor';
    public static string BUILDPARTNER= 'Build Partner';
     public static string PREPAREELESUB= 'Prepare Electrical Subk' ;
     public static string ELESUBSIGNED= 'Get Electrical Subk Signed';
     public static string SOLARWATERPROOFSIGNED= 'Get Solar Waterproofing Subk Signed';
     public static string PREPARESOLARWATERPROOF= 'Prepare Solar Waterproofing Subk';
     public static string INSTALLPACKAGESIGNED= 'Get Installation Package Signed';
     public static string PREPAREINSTALLPACKAGE= 'Prepare Installation Package';
     public static string GRANTINSTALLAPPROVAL= 'Grant Installation Schedule Approval';
     public static string COMPPACKAGE = 'Completion Package';
    public static string SubmitPostSiteAuditCOAndRequestNTP = 'Submit Post Site-Audit Change Order and Request NTP';
    public static string SubmitFinalRebateClaim = 'Submit Final Rebate Claim';
    public static string StandardTask = 'Standard';
    
    
    public static Set<String> wfInstallPartners;
    public static Set<String> wfInstallBranches;
    
    public static Set<String> getWFInstallPartners(){
        if(wfInstallPartners == null || wfInstallPartners == null){
            initializeInstallPartnerDetails();
        }
        return wfInstallPartners;
    }

    public static Set<String> getWFInstallBranches(){
        if(wfInstallBranches == null || wfInstallBranches == null){
            initializeInstallPartnerDetails();
        }       
        return wfInstallBranches;
    }
    
    public static void initializeInstallPartnerDetails(){
        wfInstallPartners = new Set<String>();
        wfInstallBranches = new Set<String>();
        Map<String, WF_Install_Branch__c> wfInstallBranchesMap = WF_Install_Branch__c.getAll();     
        for(WF_Install_Branch__c wfInstallBranchObj : wfInstallBranchesMap.values()){
            if(wfInstallBranchObj.Install_Branch__c != null && wfInstallBranchObj.Install_Branch__c != ''){
                wfInstallBranches.add(wfInstallBranchObj.Install_Branch__c);
            }
            if(wfInstallBranchObj.Install_Partner__c != null && wfInstallBranchObj.Install_Partner__c != ''){
                wfInstallPartners.add(wfInstallBranchObj.Install_Partner__c);
            }
        }
    }
    
    public static Boolean eligibleForWFProject(String installPartner, String installBranch){
        Boolean result = false;
        Set<String> installPartners = getWFInstallPartners();
        Set<String> installBranches = getWFInstallBranches();
        if(installBranches.isEmpty() || installPartners.isEmpty()){
            result = true;
            return result;
        }
        
        if(installPartner == null || installPartner == '' || installBranch == null || installBranch == '' ){
            return result;
        }
        installPartner = installPartner.substring(0, 15);
        installBranch = installBranch.substring(0, 15);
        if(installPartner.contains(installPartner) && installBranches.contains(installBranch)){
            result = true;
        }
        return result;
    } 
        
    public static Set<String> activePojectStages;
    public static Set<String> getActiveProjectStages(){
        if(activePojectStages == null || activePojectStages.isEmpty()){
            activePojectStages = new Set<String>();
            activePojectStages.add(OPEN);
            activePojectStages.add(COMPLETE);
        }
        return activePojectStages;
    }
    
    public static Set<String> projectStagesToAddSC;
     public static Set<String> projectStagesToAddSC(){
        if(projectStagesToAddSC == null || projectStagesToAddSC.isEmpty()){
            projectStagesToAddSC = new Set<String>();
            projectStagesToAddSC.add(OPEN);
            projectStagesToAddSC.add(COMPLETE);
            projectStagesToAddSC.add(BLOCKED);
        }
        return projectStagesToAddSC;
    }
    
    
    
    public static boolean isEmpty(String inputString){
        Boolean result = true;
        if(inputString != null && inputString != '')
            result = false;
        return result;
    }
    
    public static Integer getNotesCount(Id objectId, String objectName){
        Integer recordCount = 0;
        if(objectName == 'All'){
            recordCount = [Select count() from WF_Note__c where project__c =:objectId OR task__r.Phase__r.project__c =:objectId];
        }else if(objectName == 'Project'){
            recordCount = [Select count() from WF_Note__c where project__c =:objectId];
        }else{
            recordCount = [Select count() from WF_Note__c where task__c =:objectId];
        }
        return recordCount;
    }
    
    public static Map<Id, Task__c> getTasks(Set<String> taskIds){

        Map<Id, Task__c> taskMap = new  Map<Id, Task__c>([Select Id, Phase__r.Id, Phase__r.Project__r.status__c, Phase__r.Project__r.Type__c, status__c, Phase__r.project__r.Id, Phase__r.project__r.Proposal__c, phase__r.project__r.Service_Contract__c, 
                        phase__r.project__r.Opportunity__c, phase__r.project__r.Service_Contract_Event_Name__c, Phase__r.project__r.Proposal_Name__c, Phase__r.project__r.Opportunity_Name__c,
                        phase__r.project__r.Service_Contract_Event__c,Task_Description__c, Phase__r.project__r.Service_Contract_Name__c, Task_Owner__c, Task_Owner__r.name, SLA_In_Hours__c, 
                        Related_Task__c, Name, Group_Name__c, Category__c, phase__r.name, phase__r.project__r.name, description__c, reopen__c,Project_Name__c,
                        Display_Field1__c, Display_Field2__c, Display_Field3__c, Display_Field4__c, Display_Field5__c,Type__c,Has_Dependent_Rules__c,
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
                        Field_Name16__c, Field_Name17__c, Field_Name18__c, Field_Name19__c, Field_Name20__c, Task_Number__c,
                        Req1__c,Req2__c,Req3__c, Req4__c, Req5__c, Req11__c,Req12__c,Req13__c, Req14__c, Req15__c, 
                        Req6__c,Req7__c,Req8__c, Req9__c, Req10__c,Req16__c,Req17__c,Req18__c, Req19__c, Req20__c,Reason__c,Sub_Reason__c
                        from Task__C where Id in :taskIds order by Task_Number__c]);
        
        return taskMap;
    }

    public static void initObjectFieldMap(Object objectValue, Object fieldValue, Map<String, Set<String>> objectFieldMap){
        
        String objectNameStr = (objectValue == null) ? '' : (String)objectValue;
        String fieldNameStr =  (fieldValue == null) ? '' : (String)fieldValue;
        if(!wfUtil.isEmpty(objectNameStr) && !wfUtil.isEmpty(fieldNameStr)){
            Set<String> fieldSet =  objectFieldMap.containsKey(objectNameStr) ? objectFieldMap.get(objectNameStr) : new Set<String>();
            fieldSet.add(fieldNameStr);
            objectFieldMap.put(objectNameStr, fieldSet);
        }
        
    }
    
    public static void initSObjectMap(Task__c taskObj, Set<String> objectNames, Map<String, sObject> objectMap){
        for(String objectName : objectNames){
            if(objectName == 'Proposal__c'){
                objectMap.put(objectName, new Proposal__c());
            }else if(objectName == 'Opportunity'){
                objectMap.put(objectName, new Opportunity());
            }else if(objectName == 'ServiceContract'){
                objectMap.put(objectName, new ServiceContract());
            }else if(objectName == 'Service_Contract_Event__c'){
                objectMap.put(objectName, new Service_Contract_Event__c());
            }
            else if(objectName == 'Service_Contract_Partner_Rel__c'){
                objectMap.put(objectName, new Service_Contract_Partner_Rel__c());
            }
             else if(objectName == 'Project__c'){
                objectMap.put(objectName, new Project__c());
            }
        }
    }

    public static Set<Id> closedParentTasks = new Set<Id>();
    public static void processAfterTaskUpdate(Boolean isInsert, Boolean isUpdate, List<Task__c> newList, 
                                                Map<Id, Task__c> newMap, Map<Id, Task__c> oldMap){
        String inactiveStr = wfUtil.INACTIVE;
        string requiredStr = wfUtil.REQUIRED;
        string optionalStr = wfUtil.OPTIONAL;
        string blockedStr = wfUtil.BLOCKED;
        string completedStr = wfUtil.COMPLETE;
        Set<Id> modifiedTaskIds = new Set<Id>();
        for(Task__c tskObj: newList){
            Task__c oldTskObj;
            if(isUpdate){
                oldTskObj = oldMap.get(tskObj.Id);
                if((oldTskObj != null && oldTskObj.status__c != tskObj.status__c && tskObj.status__c == completedStr) 
                    || (oldTskObj != null && oldTskObj.category__c != tskObj.category__c && tskObj.category__c == optionalStr)){
                    modifiedTaskIds.add(tskObj.Id);     
                }
            }
        }
        
        if(modifiedTaskIds != null){
            modifiedTaskIds.removeall(closedParentTasks);
            if(!modifiedTaskIds.isEmpty()){
                WorkflowManagement wfObj = new WorkflowManagement();
                wfObj.startChildTasksImpl(modifiedTaskIds);
            }
        }
    }

    public static void updateProposalWFProjects(Map<Id, Id> proposalOptyMap){

        Map<Id, Project__c> optyProjectMap = new Map<Id, Project__c>();
        Set<String> tempActiveStages = getActiveProjectStages();
        Set<Id> projectIds = new Set<Id>();

        for(Project__c projectObj : [Select Id, Opportunity__c, proposal__c from Project__c where Opportunity__c in :proposalOptyMap.values()
                                            and status__c in :tempActiveStages]){
            optyProjectMap.put(projectObj.Opportunity__c, projectObj);
            projectIds.add(projectObj.Id);
        }
        if(projectIds.isEmpty())
            return;     

        Map<Id, Project__c> modifiedProjects = new Map<Id, Project__c>();
        for(Id proposalId: proposalOptyMap.keySet()){
            Id optyId = proposalOptyMap.get(proposalId);
            Project__c projectObj = optyProjectMap.get(optyId);
            if(projectObj != null){
                projectObj.proposal__c = proposalId;
                modifiedProjects.put(projectObj.Id, projectObj);
            }
        }
        if(!modifiedProjects.isEmpty()){
            update modifiedProjects.values();
        }

    }

    public static Set<String> getTaskNameForProposal(String taskName, String actionName, Project__c projectObj ){
        Set<String> resultSet = new Set<String>();
        String result = taskName;
        if(projectObj != null && !String.isEmpty(actionName) && actionName == RE_OPEN && taskName == Label.WFM_Submit_Proposal && projectObj.Service_Contract__c != null){
            resultSet.add(Label.WFM_Submit_Post_Site_Audit_Change_Order);
        }else if((taskName == Label.WFM_Submit_Proposal) && projectObj != null 
            && projectObj.Service_Contract__c != null){
            resultSet.add(Label.WFM_Approve_Post_Site_Audit_Change_Order);
            resultSet.add(Label.WFM_Submit_Post_Site_Audit_Change_Order);
            resultSet.add(Label.WFM_Submit_Post_Site_Audit_Change_Order_and_Request_NTP);
            resultSet.add(Label.WFM_Submit_Post_Site_Audit_Change_Order_and_Request_NTP_A);
            resultSet.add(Label.WFM_Submit_Post_Site_Audit_Change_Order_and_Request_NTP_B);
            //resultSet.add(Label.WFM_Grant_NTP);    
        }else if((taskName == Label.WFM_Review_And_Approve_Proposal) && projectObj != null 
            && projectObj.Service_Contract__c != null){
            resultSet.add(Label.WFM_Approve_Post_Site_Audit_Change_Order);
           // resultSet.add(Label.WFM_Grant_NTP);    
        }else{
            resultSet.add(result);
        }
        System.debug('getTaskNameForProposal: ' + resultSet);
        return resultSet;       
    }
    
    @future
    public static void updateProposalWFTasks(Map<String, Id> optyMap, Map<String, String> taskNameMap, Map<String, String> reasonMap, Map<String, String> actionMap){
        Set<Id> projectIds = new Set<Id>();
        Set<Id> parentTaskIds = new Set<Id>();
        Set<String> tempActiveStages = getActiveProjectStages();
        Map<Id, Task__c> meterRegTask = new Map<Id, Task__c>();
        Map<Id, Task__c> modifiedTasks = new Map<Id, Task__c>();
        
        for(String keyString : optyMap.keySet()){
            Id optyId = optyMap.get(keyString);
            String tempTaskName = taskNameMap.get(keyString);
            String action = actionMap.get(keyString);
            Project__c projectObj;
            for(Project__c tempProjectObj : [Select Id, Status__c, Opportunity__c, Proposal__c, Service_Contract__c  from Project__c where Opportunity__c =:optyId
                                            and status__c in :tempActiveStages]){
                projectIds.add(tempProjectObj.Id);
                projectObj = tempProjectObj;
            }
            
            
            if(projectObj == null)
                return;
                
            Set<String> taskNames = getTaskNameForProposal(tempTaskName, action,projectObj);
            for(Task__c taskObj : [Select Id, name, start_date__c, end_date__c, status__c, phase__r.project__r.Opportunity__c, phase__r.project__r.proposal__c,
                                    phase__r.project__r.Service_Contract__c from Task__c where phase__r.project__c in :projectIds
                                    and (Name in :taskNames )]){
                
                String taskName = taskObj.Name;
                if((taskName == Label.WFM_Submit_Proposal) 
                    && taskObj.phase__r.project__r.Service_Contract__c != null)
                    continue;

                System.debug('taskName: ' + taskName);
                System.debug('taskObj.status__c: ' + taskObj.status__c);                
                if((taskName == Label.WFM_Approve_Post_Site_Audit_Change_Order  )
                    && taskObj.status__c == wfUtil.COMPLETE
                    && taskObj.phase__r.project__r.Service_Contract__c != null
                    && tempTaskName == Label.WFM_Submit_Proposal){
                    System.debug('WorkflowManagement.reopenTask');
                    WorkflowManagement.reopenTask(taskObj.Id);  
                }else if(taskName == Label.WFM_Submit_Post_Site_Audit_Change_Order && action == RE_OPEN){
                    System.debug('WorkflowManagement.reopenTask');
                    String reopenReason = reasonMap.get(keyString);
                    WorkflowManagement.reopenTask(taskObj.Id, reopenReason);    
                }else if(taskName == Label.WFM_Submit_Proposal && action == RE_OPEN){
                    System.debug('WorkflowManagement.reopenTask');
                    String reopenReason = reasonMap.get(keyString);
                    WorkflowManagement.reopenTask(taskObj.Id, reopenReason);    
                }else if((taskName == Label.WFM_Approve_Post_Site_Audit_Change_Order )  //|| taskName == Label.WFM_Grant_NTP)
                    && taskObj.phase__r.project__r.Service_Contract__c != null){
                    System.debug('Complete --1');
                    if(taskObj.status__c == wfUtil.OPEN){
                        taskObj.status__c = wfUtil.COMPLETE;
                        taskObj.End_date__c = Datetime.now();
                        modifiedTasks.put(taskObj.Id, taskObj);
                        parentTaskIds.add(taskObj.Id);                      
                    }
                }else{
                    System.debug('Complete --2');
                    if(taskObj.status__c != wfUtil.COMPLETE && taskObj.name == taskName && action != RE_OPEN ){
                        taskObj.status__c = wfUtil.COMPLETE;
                        taskObj.End_date__c = Datetime.now();
                        modifiedTasks.put(taskObj.Id, taskObj);
                        parentTaskIds.add(taskObj.Id);
                    }
                }
            }           
        }
        
        if(!modifiedTasks.isEmpty()){
            update modifiedTasks.values();
        }
    }

    public static void completeSCTasks(Map<String, Id> scMap, Map<String, String> taskNameMap){
        Set<Id> projectIds = new Set<Id>();
        Set<Id> parentTaskIds = new Set<Id>();
        Set<String> tempActiveStages = getActiveProjectStages();
        Map<Id, Task__c> modifiedTasks = new Map<Id, Task__c>();
            
        for(String keyString : scMap.keySet()){
            Id scId = scMap.get(keyString);
            String taskName = taskNameMap.get(keyString);
            for(Project__c projectObj : [Select Id, Status__c, Opportunity__c, Proposal__c, Service_Contract__c from Project__c where Service_Contract__c =:scId
                                            and status__c in :tempActiveStages]){
                projectIds.add(projectObj.Id);
            }
            for(Task__c taskObj : [Select Id, name, start_date__c, end_date__c, status__c, phase__r.project__r.Opportunity__c, phase__r.project__r.proposal__c,
                                    phase__r.project__r.Service_Contract__c from Task__c where phase__r.project__c in :projectIds
                                    and (Name =:taskName ) and phase__r.project__r.Service_Contract__c != null and Category__c = 'Required' ]){
                if(taskObj.status__c != wfUtil.COMPLETE && taskObj.name == taskName){
                    taskObj.status__c = wfUtil.COMPLETE;
                    taskObj.End_date__c = Datetime.now();
                    modifiedTasks.put(taskObj.Id, taskObj);
                    parentTaskIds.add(taskObj.Id);
                }
            }       
        }
        
        if(!modifiedTasks.isEmpty()){
            update modifiedTasks.values();
        }
    }
    
    public static void updateWFProjects(Map<Id, Id> scOptyMap){
        Map<Id, Project__c> optyProjectMap = new Map<Id, Project__c>();
        //adding code to associate blocked project to servicecontract 
        Set<String> tempActiveStages = projectStagesToAddSC();
        for(Project__c projectObj : [Select Id, status__c, Opportunity__c, Service_Contract__c, Service_Contract_Event__c from Project__c where Opportunity__c in :scOptyMap.values()
                                        and status__c in :tempActiveStages]){
            optyProjectMap.put(projectObj.Opportunity__c, projectObj);
        }
        
        Map<Id, Project__c> modifiedProjects = new Map<Id, Project__c>();
        for(ServiceContract scObj : [Select Id, Opportunity__c, Proposal__c from  ServiceContract where Id in :scOptyMap.keySet()]){
            Project__c projectObj = optyProjectMap.get(scObj.Opportunity__c);
            if(projectObj != null){
                projectObj.Service_Contract__c = scObj.Id;
                projectObj.Opportunity__c = scObj.Opportunity__c;
                projectObj.proposal__c = scObj.Proposal__c;
                modifiedProjects.put(projectObj.Id, projectObj);
            }
        }
        if(!modifiedProjects.isEmpty()){
            update modifiedProjects.values();
        }
        
    }

    public static void updateWFProjectStatus(Map<Id, String> scStatusModifiedOptyIds){
        String cancelledStr = CANCELLED;
        Map<Id, Project__c> optyProjectMap = new Map<Id, Project__c>();
        Map<Id, Project__c> modifiedProjects = new Map<Id, Project__c>();
        Set<String> tempActiveStages = getActiveProjectStages();
        for(Project__c projectObj : [Select Id, Opportunity__c, Status__c, Service_Contract__c, Service_Contract_Event__c from Project__c 
                                        where Opportunity__c in :scStatusModifiedOptyIds.keySet()]){
            String status = scStatusModifiedOptyIds.get(projectObj.Opportunity__c);
            projectObj.status__c = status;
            modifiedProjects.put(projectObj.Id, projectObj);
        }

        if(!modifiedProjects.isEmpty()){
            update modifiedProjects.values();
        }
        
    }
    
    public static void checkProjectStatus(Boolean isInsert, Boolean isUpdate, List<Task__c> taskList, 
                                                Map<Id, Task__c> newMap, Map<Id, Task__c> oldMap){
        String cancelledStr = CANCELLED;
        if(isInsert || isUpdate){
            Set<Id> phaseIds = new Set<Id>();
            Set<Id> projectIds = new Set<Id>();
            for(Task__c taskObj: taskList){
                Task__C oldTaskObj;
                if(oldMap != null && (isUpdate == true)){
                    oldTaskObj = oldMap.get(taskObj.Id);
                }
                if(taskObj.phase__c != null){
                    phaseIds.add(taskObj.phase__c);
                }
                if(taskObj.project_name__c != null){
                    projectIds.add(taskObj.project_name__c);
                }

                if(oldTaskObj != null && (taskObj.status__c == wfUtil.COMPLETE) && oldTaskObj.Task_Owner__c != null && 
                    oldTaskObj.Task_Owner__c != taskObj.Task_Owner__c){
                    Task__c tempTSKObj = (Test.isRunningTest()) ? taskObj : (Task__c)Trigger.newMap.get(taskObj.Id);
                    tempTSKObj.adderror('You are not allowed to modify the owner for completed task(s)');                   
                }
            }
            
            if(!phaseIds.isEmpty()){
                Map<Id, Phase__c> phaseMap = getPhasesForCancelledProjects(projectIds, phaseIds);
                for(Task__c taskObj: taskList){
                	Task__c tempTSKObj = taskObj;
                    if(taskObj.Id != null && taskObj.phase__c != null && phaseMap.containsKey(taskObj.phase__c)){
						tempTSKObj = (Test.isRunningTest()) ? taskObj : (Task__c)Trigger.newMap.get(taskObj.Id);
                    
					tempTSKObj.adderror('This is not an active project and users are not allowed to modify this task');
                    }
                }               
            }
            
        }
    }
	
	public static Map<Id, Phase__c> cachedPhases = new Map<Id, Phase__c>();
	public static Map<Id, Phase__c> getPhasesForCancelledProjects(Set<Id> projectIds, Set<Id> phaseIds){
		Map<Id, Phase__c> phaseMap = new Map<Id, Phase__c>();
		Boolean runQuery = false;
		if(cachedPhases != null && !cachedPhases.isEmpty()){
			for(Id phaseId : phaseIds){
				if(!cachedPhases.containsKey(phaseId)){
					runQuery = true;
					break;
				}
			}
		}
		
		if(runQuery || cachedPhases == null || cachedPhases.isEmpty()){
			cachedPhases = new Map<Id, Phase__c>([Select Id, Project__r.Status__c from Phase__C where Id in :phaseIds OR Project__r.Id in :projectIds]);			
		}
		String cancelledStr = CANCELLED;
		if(cachedPhases != null && !cachedPhases.isEmpty()){
			for(Id phaseId : phaseIds){
				if(cachedPhases.containsKey(phaseId)){
					Phase__c phaseObj = cachedPhases.get(phaseId);
					if(phaseObj.Project__r.Status__c == cancelledStr){
						phaseMap.put(phaseObj.Id, phaseObj);
					}
				}
			}
		}
		return phaseMap;

	}

    public static Map<Id, Set<String>> getUserGroups(Set<Id> userIds){
        Map<Id, Set<String>> userGroups = new Map<Id, Set<String>>();
        for(User_Group__c uGroup : [SELECT Group__c, Id, Name, User_Active__c, User__c FROM User_Group__c where User__c in :userIds and User_Active__c = true]){
            Set<String> groupNames = userGroups.containsKey(uGroup.User__c) ? userGroups.get(uGroup.User__c) : new Set<String>();
            groupNames.add(uGroup.Group__c);
            userGroups.put(uGroup.User__c, groupNames);
        }
        return userGroups;
    }
    
    public static Set<String> accountAddressKey = new Set<String>();
    public static void updateProjectAddress(Map<Id, Account> modifiedAddressAccountObjs){
        Set<String> tempAddressKey = new Set<String>();
        Set<Id> accountIds = new Set<Id>();
        for(Account newAccountObj : modifiedAddressAccountObjs.values()){
            String tempString =  newAccountObj.Id + '';
            tempString += (newAccountObj.BillingCountry == null ) ? '' : newAccountObj.BillingCountry;
            tempString += (newAccountObj.BillingState == null ) ? '' : newAccountObj.BillingState;
            tempString += (newAccountObj.BillingStreet == null ) ? '' : newAccountObj.BillingStreet;
            tempString += (newAccountObj.BillingPostalCode == null ) ? '' : newAccountObj.BillingPostalCode;
            tempString += (newAccountObj.Zip_6__c == null ) ? '' : newAccountObj.Zip_6__c;
            if(!accountAddressKey.contains(tempString)){
                accountIds.add(newAccountObj.Id);
                accountAddressKey.add(tempString);
            }
        }
        if(!accountIds.isEmpty()){
            updateProjectAddress(accountIds);
        }

    }
    
    public static void updateProjectAddress(Set<Id> accountIds){
        updateProjectAddressImpl(accountIds);
    }
    
    public static String getAddressString(Account accountObj){
        String tempString = (accountObj.BillingStreet == null ) ? '' : accountObj.BillingStreet + ' ';
        tempString += (accountObj.BillingCity == null ) ? '' : accountObj.BillingCity + ' ';
        tempString += (accountObj.BillingState == null ) ? '' : accountObj.BillingState + ' ';
        tempString += (accountObj.BillingCountry == null ) ? '' : accountObj.BillingCountry + ' ';
        tempString += (accountObj.BillingPostalCode == null ) ? '' : accountObj.BillingPostalCode + ' ';     
        return tempString;      
    }
    public static void updateProjectAddressImpl(Set<Id> accountIds){
        Map<Id, Account> accountMap = new Map<Id, Account>([Select Id, name, BillingCity, BillingCountry, BillingState, BillingStreet, BillingPostalCode, 
                                                                Zip_6__c from Account where Id in :accountIds ]);
        Map<Id, Project__C> modifiedProjects = new Map<Id, Project__C>();
        for(Project__C projectObj : [Select Id, Account__c, Address__c from Project__c where Account__c in :accountIds]){
            Account accountObj = accountMap.get(projectObj.Account__c); 
            projectObj.Address__c = getAddressString(accountObj);
            modifiedProjects.put(projectObj.Id, projectObj);
        }
        if(!modifiedProjects.isEmpty()){
            update modifiedProjects.values();
        }
    }
    
    public static void updateTaskTemplates(Set<Id> parentTemplateIds){
        List<Task_Template__c> parenTemplateObjs = new List<Task_Template__c>(); 
        if(parentTemplateIds != null){
            for(Task_Template__c parenTemplateObj : [Select Id, Has_Dependent_Rules__c, (Select Id, name from Workflow_Update_Rules__r limit 1) from Task_Template__c where Id in :parentTemplateIds]){
                if(parenTemplateObj.Workflow_Update_Rules__r != null && !parenTemplateObj.Workflow_Update_Rules__r.isEmpty() && parenTemplateObj.Has_Dependent_Rules__c == false){
                    parenTemplateObj.Has_Dependent_Rules__c = true;
                    parenTemplateObjs.add(parenTemplateObj);
                }else if((parenTemplateObj.Workflow_Update_Rules__r == null || parenTemplateObj.Workflow_Update_Rules__r.isEmpty()) 
                        && parenTemplateObj.Has_Dependent_Rules__c == true){
                    parenTemplateObj.Has_Dependent_Rules__c = false;
                    parenTemplateObjs.add(parenTemplateObj);
                }
            }
            if(!parenTemplateObjs.isEmpty()){
                update parenTemplateObjs;
            }
        }
    }
    
    public static Set<Id> pnOptyIds = new Set<Id>();
    public static void updateJobCode(Map<Id, Opportunity> modifiedProjectNumbers){
        Set<Id> optyIds = modifiedProjectNumbers.keySet();
        if(optyIds != null){
            optyIds.removeall(pnOptyIds);
            if(!optyIds.isEmpty()){
                List<Project__c> modifiedProjects = new List<Project__c>();
                for(Project__c projectObj : [Select Id, job_code__c, Opportunity__c from Project__C where Opportunity__c in :optyIds]){
                    projectObj.job_code__c = modifiedProjectNumbers.get(projectObj.Opportunity__c).Project_Number__c;
                    modifiedProjects.add(projectObj);
                }
                update modifiedProjects;
                pnOptyIds.addall(optyIds);
            }
        }
    }
}