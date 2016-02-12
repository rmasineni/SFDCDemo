public with sharing class projTaskHelper {

 	 Static  set<id> allowUsersToModify = new set<id>();

    
 public static void updatePhaseStatus(map<Id,task__c>newMap, map<Id,task__c> oldMap){
            set<Id> phaseIds = new set<Id>();
            set<Id> projectIds = new set<Id>();
            map<Id,Phase__c> phaseMap = new map<Id,Phase__c>();
            map<Id, phase__c> phaseMapReq = new map <Id, phase__c>();
            set<Phase__c> phasesToUpdate = new set<Phase__c>();
            set<string> statusValues = new set<string>();
            map<string, set<string>> phaseMapStatus = new map<string, set<string>>();
     		             
            // at insert
            if(oldMap == null){
                for(task__c task: [select Id, Phase__c,Type__c from task__c where Id in:newMap.keyset()]){
                    phaseIds.add(task.Phase__c); 
                  
                }
            }
            // at update
            else if(oldMap != null){
                for(task__c task: newMap.values()){
                    if(task.Status__c != oldMap.get(task.Id).Status__c && task.Status__c != wfUtil.CANCELLED  ){
                        phaseIds.add(task.Phase__c);
                      
                    }
                }
            
            } 
            
            if(phaseIds.size() > 0) {
                phaseMapReq = new map <Id, Phase__c> ([select Id, phase_status__c, Project__c, Project__r.Status__c, (select Id , status__c, phase__c, category__c, Type__c, Task_Description__c,Blocked_Project__c from tasks__r ) from phase__c where id in: phaseIds ]);
                               
                //phaseMap = new map <Id, Phase__c> ([select Id, phase_status__c, (select Id , status__c, phase__c from tasks__r where Category__c = :wfUtil.OPTIONAL) from phase__c where id in: phaseIds ]);
                            
            }
            
            if(phaseMapReq.size() > 0) {
               for( phase__c phase: phaseMapReq.values()) {
                   system.debug('Project Status' + phase.Project__r.Status__c  );
                    for(task__c tsk : phase.tasks__r) { 
                        boolean t = tsk.Type__c == wfUtil.PROJ_BLOCKED? true:false;
                       
                        if (tsk.Blocked_Project__c  && tsk.Status__c == wfUtil.BLOCKED  ) { 
                            if (phaseMapStatus.containsKey(tsk.phase__c))
                                phaseMapStatus.get(tsk.phase__c).add(wfUtil.PROJ_BLOCKED); 
                            else                        
                                phaseMapStatus.put(tsk.phase__c, new set<string> {wfUtil.PROJ_BLOCKED});  
                            System.debug('>> Blocked task' + phaseMapStatus);                            
                        }   
                        else if (tsk.category__c == wfUtil.REQUIRED && ( (tsk.status__c == wfUtil.OPEN )|| tsk.status__c == wfUtil.ON_HOLD || tsk.status__c == wfUtil.BLOCKED )) {
                            if (phaseMapStatus.containsKey(tsk.phase__c))
                                phaseMapStatus.get(tsk.phase__c).add(wfUtil.OPEN); 
                            else                        
                                phaseMapStatus.put(tsk.phase__c, new set<string> {wfUtil.OPEN});    
                            System.debug('>> PhaseMapstatus:' + phaseMapStatus);
                        }
                        
                        
                        else if (tsk.category__c == wfUtil.REQUIRED && tsk.status__c == wfUtil.COMPLETE){
                            if (phaseMapStatus.containsKey(tsk.phase__c))
                                phaseMapStatus.get(tsk.phase__c).add(wfUtil.COMPLETE); 
                            else                        
                                phaseMapStatus.put(tsk.phase__c, new set<string> {wfUtil.COMPLETE});                   
                        }
                        else if((tsk.category__c == wfUtil.REQUIRED && tsk.status__c == wfUtil.INACTIVE)) {
                            if (phaseMapStatus.containskey(tsk.phase__c))
                                phaseMapStatus.get(tsk.phase__c).add(wfUtil.INACTIVE);
                            else
                                phaseMapStatus.put(tsk.phase__c, new set<string> {wfUtil.INACTIVE});
                        }
                        else if(tsk.category__c == wfUtil.OPTIONAL) {
                            if (phaseMapStatus.containskey(tsk.phase__c))
                                phaseMapStatus.get(tsk.phase__c).add(wfUtil.OPTIONAL);
                            else
                                phaseMapStatus.put(tsk.phase__c, new set<string> {wfUtil.OPTIONAL});
                        }      
                    }  
               }  
            }
                
                System.debug('>>phaseMapStatus.size()' + phaseMapStatus.size());
                
            if(phaseMapStatus.size() > 0) {
            
                for (phase__c phase :  phaseMapReq.values()) {
               
                    if (phaseMapStatus.containskey(phase.id) && (phaseMapStatus.get(phase.id).contains(wfUtil.OPEN) || phaseMapStatus.get(phase.id).contains(wfUtil.ON_HOLD) 
                                                                 || phaseMapStatus.get(phase.id).contains(wfUtil.BLOCKED)) && !phaseMapStatus.get(phase.id).contains(wfUtil.PROJ_BLOCKED)) {
                            System.Debug('Staus Open');
                            phase.phase_status__c = wfUtil.OPEN;                    
                            phasesToUpdate.add(phase);
                    } 
                    else if (phaseMapStatus.containskey(phase.id) && phaseMapStatus.get(phase.id).contains(wfUtil.PROJ_BLOCKED)) {
                            System.Debug('Staus Project blocked');
                            phase.phase_status__c = wfUtil.PROJ_BLOCKED ;                    
                            phasesToUpdate.add(phase);
                    } 
                   else if(phaseMapStatus.containskey(phase.id) && phaseMapStatus.get(phase.id).contains(wfUtil.COMPLETE) && !phaseMapStatus.get(phase.id).contains(wfUtil.INACTIVE) )  {
                            System.Debug('Staus Complete---');
                            phase.phase_status__c = wfUtil.COMPLETE;
                           phasesToUpdate.add(phase);   
                            
                        }
                   else if(phaseMapStatus.containskey(phase.id) && phaseMapStatus.get(phase.id).contains(wfUtil.INACTIVE) &&  !phaseMapStatus.get(phase.id).contains(wfUtil.COMPLETE) )  {
                       System.Debug('Staus Inactive' +phaseMapStatus.get(phase.id).contains(wfUtil.COMPLETE) + phaseMapStatus.get(phase.id).contains(wfUtil.INACTIVE) );    
                       phase.phase_status__c = wfUtil.INACTIVE;
                       phasesToUpdate.add(phase); 
                   }     
                     else {
                      phase.phase_status__c = wfUtil.OPEN;
                      phasesToUpdate.add(phase);        
                     }    
                  }
                }    
         
           if(phasesToUpdate.size()>0){
                list<Phase__c> phaseList = new list<Phase__c>();
                phaseList.addAll(phasesToUpdate);
                update phaseList;
            }
            
    
         }
         
  /* public static void updateTaskDependency(list<Task_Dependency__c> nList){
            set<Id> taskTempIds = new set<Id>();
            map<Id,Task__c> mapIdTaskTemp = new map<Id,Task__c>();
            for(Task_Dependency__c tTemp : nList){
                //system.debug(tTemp.Task__r.Project_Name__c+'<<<<>>>>'+tTemp.Task__c);
                if(tTemp.Task__c != null)
                    taskTempIds.add(tTemp.Task__c);
                if(tTemp.Parent_Task__c != null)
                    taskTempIds.add(tTemp.Parent_Task__c);
                    
            }
            
            if(taskTempIds.size()>0){
                mapIdTaskTemp = new map<Id,Task__c>([select id,Project_Name__c from Task__c where Id in:taskTempIds]);
            }
            
            for(Task_Dependency__c tTemp : nList){
                system.debug(mapIdTaskTemp+'<<<<2>>>>'+tTemp.Task__c);
                if(mapIdTaskTemp.size()>0 && mapIdTaskTemp.containsKey(tTemp.Task__c)){
                    tTemp.Project_Name__c = mapIdTaskTemp.get(tTemp.Task__c).Project_Name__c;
                    //system.debug('>>>>>'+tTemp.Dependent_Task_Project_Template__c); 
                }
                
                if(mapIdTaskTemp.size()>0 && mapIdTaskTemp.containsKey(tTemp.Parent_Task__c)){
                    tTemp.Project_Name__c = mapIdTaskTemp.get(tTemp.Parent_Task__c).Project_Name__c;
                    //system.debug('>>>>>'+tTemp.Dependent_Task_Project_Template__c); 
                }
            }
        
    }     */
         
    
public static void updateProjectStatus(map<Id,Phase__c>newMap, map<Id,Phase__c> oldMap){
    
            set<Id> projectIds = new set<Id>();
            set<Project__c> projectsToUpdate = new set<Project__c>();
            set<string> statusValues = new set<string>();
            map<string, set<string>> phaseMapStatus = new map<string, set<string>>();
            
              // at insert
            if(oldMap == null){
                for(phase__c phase: [select Id, Project__c from phase__c where Id in:newMap.keyset()]){
                    projectIds.add(phase.project__c);
                    System.debug('projectId:' +phase.project__c ) ;
                }
            }
            // at update
            else if(oldMap != null){
                for(phase__c phase: newMap.values()){
                    if(phase.phase_status__c != oldMap.get(phase.Id).phase_status__c){                       
                        projectIds.add(phase.project__c);
                    System.debug('projectId:' +phase.project__c ) ;
                    }
                }
            
            }     
            
        
            map<Id, Project__c> projMapPhase = new map <Id, Project__c> ([select Id, Status__c, (select Id ,Project__c, Phase_Status__c from Phases__r ) 
                                                                          from project__c where id in: projectIds ]);

            if(projMapPhase.size() > 0) {
               for( project__c proj: projMapPhase.values()) {
                for(phase__c phase : proj.Phases__r) { 
                     if ( (phase.Phase_Status__c == wfUtil.PROJ_BLOCKED )) {
                        if (phaseMapStatus.containsKey(phase.project__c))
                            phaseMapStatus.get(phase.project__c).add(wfUtil.PROJ_BLOCKED); 
                        else                        
                             phaseMapStatus.put(phase.project__c, new set<string> {wfUtil.PROJ_BLOCKED});                   
                        }
                   else if ( (phase.Phase_Status__c == wfUtil.OPEN )) {
                        if (phaseMapStatus.containsKey(phase.project__c))
                            phaseMapStatus.get(phase.project__c).add(wfUtil.OPEN); 
                        else                        
                             phaseMapStatus.put(phase.project__c, new set<string> {wfUtil.OPEN});                   
                        }
                   else if ( phase.Phase_Status__c == wfUtil.COMPLETE){
                        if (phaseMapStatus.containsKey(phase.project__c))
                            phaseMapStatus.get(phase.project__c).add(wfUtil.COMPLETE); 
                        else                        
                             phaseMapStatus.put(phase.project__c, new set<string> {wfUtil.COMPLETE});                   
                        }
                   else if(phase.Phase_Status__c == wfUtil.INACTIVE) {
                        if (phaseMapStatus.containskey(phase.project__c))
                            phaseMapStatus.get(phase.project__c).add(wfUtil.INACTIVE);
                        else
                            phaseMapStatus.put(phase.project__c, new set<string> {wfUtil.INACTIVE});
                        }
    
                    }  
                  }  
                }
                
                System.debug('phaseMapStatus.size():' + phaseMapStatus.size());
                
            if(phaseMapStatus.size() > 0) {
            
                for (project__c proj :  projMapPhase.values()) {
 
                    if (phaseMapStatus.containskey(proj.id) && phaseMapStatus.get(proj.id).contains(wfUtil.PROJ_BLOCKED )) {
                       
                        if (proj.status__c != wfUtil.CANCELLED ) {
                            proj.status__c = wfUtil.BLOCKED;                    
                            projectsToUpdate.add(proj);
                        }
                    }
                   else if (phaseMapStatus.containskey(proj.id) && phaseMapStatus.get(proj.id).contains(wfUtil.OPEN)) {
                        System.Debug('Project Staus Open:');
                        if (proj.status__c != wfUtil.CANCELLED ) {
                        proj.status__c = wfUtil.OPEN;                    
                        projectsToUpdate.add(proj);
                        }
                        }
                        
                    else if(phaseMapStatus.containskey(proj.id) && phaseMapStatus.get(proj.id).contains(wfUtil.COMPLETE) && !phaseMapStatus.get(proj.id).contains(wfUtil.INACTIVE) )  {
                       System.Debug('Project Staus Complete:');
                        if (proj.status__c != wfUtil.CANCELLED ) {
                        proj.status__c = wfUtil.COMPLETE;
                        projectsToUpdate.add(proj);    
                        }
                        }
                   else if(phaseMapStatus.containskey(proj.id) && phaseMapStatus.get(proj.id).contains(wfUtil.INACTIVE) &&  !phaseMapStatus.get(proj.id).contains(wfUtil.COMPLETE) )  {
                        System.Debug('Project Staus Inactive:' +phaseMapStatus.get(proj.id).contains(wfUtil.COMPLETE) + phaseMapStatus.get(proj.id).contains(wfUtil.INACTIVE) );    
                       if (proj.status__c != wfUtil.CANCELLED ) {   
                        proj.status__c = wfUtil.OPEN;
                        projectsToUpdate.add(proj);  
                            }
                        }  
                     else {
                      proj.status__c = wfUtil.OPEN;
                      projectsToUpdate.add(proj);        
                     }    
                    }
                }           
                        
           if(projectsToUpdate.size()>0){
                list<project__c> projList = new list<project__c>();
                projList.addAll(projectsToUpdate);
                update projList;
            }
                
         }
    
    public static Set<id> getAllowUsersToModify()
    {
        if(allowUsersToModify.isEmpty())
        {
            allowUsersToModify.add('00560000002wFeg');
            allowUsersToModify.add('00560000002IYlA');
             allowUsersToModify.add('00560000001PIAp');
             allowUsersToModify.add('00560000001PYJn');
             allowUsersToModify.add('00560000003fBGB');
             allowUsersToModify.add('00560000002Gw3H');
            allowUsersToModify.add('00532000004kJzp');
            allowUsersToModify.add('00560000003f4r5');
            allowUsersToModify.add('00532000004kYqT');
            allowUsersToModify.add('00532000004OVnI');
        }
        return allowUsersToModify;
    }
    
    public static void restrictTaskChangeOnBlockedProject(map<Id,task__c>newMap, map<Id,task__c> oldMap, list<task__c> tNew){
      
        //Profile sysAdminProfile = [select Id,Name from Profile where Name = 'System Administrator' limit 1];
        id userProfileId = userinfo.getProfileId();
        id userId = userinfo.getUserId();
        
        //id sysAdminId = sysAdminProfile.id;
        id sysAdminId = system.label.System_Admin_Profile_Id;
        System.debug('userprofileId:' + userProfileId + 'sysAdmin:' + sysAdminId);
        map<Id, Project__c> projMapReq = new map <Id, Project__c>();
      set<Id>  projectIds = new set<Id>();
        for(task__c tsk : tNew){
        if(tsk.Project_Name__c != null)
          projectIds.add(tsk.Project_Name__c);
      }
      if(projectIds.size()>0){
       // projMapReq = new map <Id, Project__c>([select Id, Status__c from Project__c where id IN : projectIds]);
		projMapReq = getProjectsById(projectIds);
      }
        for(task__c tsk : tNew){
        if(tsk.Project_Name__c != null && projMapReq.size() > 0 ){
          if(projMapReq.containsKey(tsk.Project_Name__c) && projMapReq.get(tsk.Project_Name__c).Status__c == wfUtil.BLOCKED 
             && tsk.Blocked_Project__c == true  && userProfileId != sysAdminId &&  !getAllowUsersToModify().contains(userId) ){
             tsk.addError('Task Changes not allowed on Blocked Project');
          }
        }
      }
        
    }
    
    public static Map<Id, Project__C> staticProjectMap = new Map<Id, Project__C>();
    public static Map<Id, Project__C> getProjectsById(Set<Id> projectIds){
    	Boolean runQuery = false;
    	if(staticProjectMap != null && !staticProjectMap.isEmpty()){
	    	for(Id projectId : projectIds){
	    		if(!staticProjectMap.containskey(projectId)){
	    			runQuery = true;
	    			break;
	    		}
	    	}
    	}
    	if(runQuery || staticProjectMap == null || staticProjectMap.isEmpty()){
			staticProjectMap = new map <Id, Project__c>([select Id, Status__c from Project__c where id IN : projectIds]);
    	}
    	return staticProjectMap;
    }
    
    public static void cancelTasks(map<Id,project__c>newMap, map<Id,project__c> oldMap){
            set<Id> projectIds = new set<Id>();
             map<Id, task__c> taskMap = new map <Id, task__c>();
            Set<String> taskStatustoUpdate = new Set<String>();
            taskStatustoUpdate.add('Blocked');
            taskStatustoUpdate.add('On-Hold');
            taskStatustoUpdate.add('Open'); 
          //taskStatustoUpdate.add('Cancelled'); 
          list<task__c> modifiedTaskList = new list<task__c>();
      
             if(oldMap != null){
                for(project__c prj: newMap.values()){
                    if(prj.Status__c != null && prj.Status__c != oldMap.get(prj.Id).Status__c && prj.Status__c == wfUtil.CANCELLED  ){
                        projectIds.add(prj.id);
                      System.debug('Project Status new and OLD' + prj.Status__c + oldMap.get(prj.Id).Status__c );
                    }
                }
            
            } 
            
                 
             if(projectIds.size() > 0) {
                for (task__c tsk: [select Id , status__c, phase__c, category__c, Type__c, Task_Description__c,Blocked_Project__c ,Previous_Status__c
                                                  from task__c Where Project_Name__c in :projectIds and Status__c in :taskStatustoUpdate ] ) {
                    
                        tsk.Previous_Status__c = tsk.status__c;
                        tsk.status__c = wfUtil.CANCELLED; 
                        system.debug( 'Modified Status' +  tsk.status__c + 'Previous status' + tsk.Previous_Status__c  );
            modifiedTaskList.add(tsk);
                }
                
                if(modifiedTaskList.size()>0){
                    update modifiedTaskList;
                }
            } 
              
        }
    
    public static void reOpenedProject(map<Id,project__c>newMap, map<Id,project__c> oldMap){
            set<Id> reopenedProjectIds = new set<Id>();
             map<Id, task__c> taskMap = new map <Id, task__c>();
            Set<String> taskStatustoUpdate = new Set<String>();
            //taskStatustoUpdate.add('Blocked');
           // taskStatustoUpdate.add('On-Hold');
           // taskStatustoUpdate.add('Open'); 
          taskStatustoUpdate.add('Cancelled'); 
          list<task__c> modifiedTaskList = new list<task__c>();
      
             if(oldMap != null){
                for(project__c prj: newMap.values()){
                    if(prj.Status__c != null && prj.Status__c != oldMap.get(prj.Id).Status__c && oldMap.get(prj.Id).Status__c == wfUtil.CANCELLED  ){
                        reopenedProjectIds.add(prj.id);
                      System.debug('Project Status new and OLD:' + prj.Status__c + oldMap.get(prj.Id).Status__c );
                    }
                }
            
            } 
                             
             if(reopenedProjectIds.size() > 0) {
                for (task__c tsk: [select Id , status__c, phase__c, category__c, Type__c, Task_Description__c,Blocked_Project__c ,Previous_Status__c
                                                  from task__c Where Project_Name__c in :reopenedProjectIds and Status__c in :taskStatustoUpdate ] ) {
                  //  if(tsk.Previous_Status__c != null)
                         tsk.status__c = tsk.Previous_Status__c ;
                         system.debug( 'Modified Status:' +  tsk.status__c + ':Previous status:' + tsk.Previous_Status__c  );
            modifiedTaskList.add(tsk);
                }
                
                if(modifiedTaskList.size()>0){
                    update modifiedTaskList;
                }
            } 
              
        }
       
    public static void currentPhase( map<id, Phase__c> newPhaseMap, map<id, phase__c > oldPhaseMap) {
     set<id> projectIds = new set<id>();
        map<id, Project__c> projectIdMap = new map<id,Project__c>();
        set<project__c> projectToUpdate = new set<project__c>();
      
            if(oldPhaseMap != null )
            {
                for( phase__c  ph: newPhaseMap.values()  )
                    if( ph.Phase_Status__c !=  oldPhaseMap.get(ph.id).Phase_Status__c  && !checkRecursive.phaseIds.Contains(ph.id)  ){ 
                        projectIds.add(ph.Project__c );
            checkRecursive.phaseIds.add(ph.id);
                    }
                
            }
            if(projectIds.size()>0 ) {
                for( project__c proj : [Select id, name,Status__c, Current_Phase__c, (Select id , Phase_Number__c, Phase_Status__c , name 
                                                          from phases__r where  Phase_Status__c =: wfUtil.OPEN order by Phase_Number__c limit 1) 
                                        from project__C where id in :projectIds]) {
                                            projectIdMap.put(proj.Id, proj );
                                        }
            }
            
            if( projectIdMap.size() > 0 && !projectIdMap.isEmpty() )    {    
                for (project__c prj :projectIdMap.values() ){
                    for(phase__c ph: prj.phases__r ){
                        if ( prj.Status__c == wfUtil.OPEN &&  prj.Current_Phase__c  != ph.name ){
                            prj.Current_Phase__c = ph.name;
                            projectToUpdate.add(prj);
                                
                                }
                    }      
                } 
            }
            System.debug(' projectToUpdate.size() ' + projectToUpdate.size());
            if(projectToUpdate.size() > 0){
                list<project__c> projList = new list<project__c>();
                projList.addAll(projectToUpdate);
                update projList;
                
            }
      
    }
    
    public static void updateSCEFields(map<Id,task__c>newMap, map<Id,task__c> oldMap){
        set <id> ProjectIds = new set<id>();
        list <service_contract_event__c> sceIds = new list<service_contract_event__c>();
        map <id, set<id>> ScToTaskNameMap = new map<id, Set<id>> ();    
        map <id, Service_Contract_event__c> scToSceMap = new map<id,Service_Contract_event__c>(); 
        Service_Contract_event__c sceObj = New Service_Contract_event__c();
        if(oldMap != null){
            for(task__c task: newMap.values()){  
                if( ( task.name.containsIgnoreCase(wfUtil.SubmitPostSiteAuditCOAndRequestNTP) || 
                     task.name.ContainsIgnoreCase(wfUtil.SubmitFinalRebateClaim) ) 
                   && task.Status__c != oldMap.get(task.Id).Status__c && task.Status__c == wfUtil.COMPLETE 
                   && !checkRecursive.taskIds.contains(task.id)  ){
                       // ProjectIds.add(task.project__c);
                       if (ScToTaskNameMap.containsKey(task.Service_Contract__c) )
                       {
                           ScToTaskNameMap.get(task.Service_Contract__c).add(task.id);
                       }
                       else {
                           ScToTaskNameMap.put(task.Service_Contract__c,new set<id> {task.id});
                       }
                       //ScToTaskIdMap.put(task.Service_Contract__c,task.id);
                       checkRecursive.taskIds.add(task.id);
                   }
            }    
        }   
        if (ScToTaskNameMap.size() >0 && !ScToTaskNameMap.isEmpty()) {
            for(serviceContract sc: [Select Id, Name, (Select id, name,NTP_Requested__c,Rebate_Form_Sent__c  from Service_Contract_Events__r) 
                                     from serviceContract where id in :ScToTaskNameMap.keyset() ]){
                                         
                                         for(service_Contract_Event__c sce : sc.Service_Contract_Events__r)
                                         {
                                             scToSceMap.put(sc.id , sce);
                                         }
                                     }
        }
        
        if(scToSceMap.size() > 0 && !scToSceMap.isEmpty()){
            for (task__c task: newMap.values()){
                if ( scToSceMap.containsKey(task.Service_Contract__c)  )
                    sceObj=  scToSceMap.get(task.Service_Contract__c);
                {
                    if( task.name.containsIgnoreCase(wfUtil.SubmitPostSiteAuditCOAndRequestNTP) && sceObj.NTP_Requested__c == NUll ){
                        sceObj.NTP_Requested__c = system.today();
                        sceIds.add(sceObj);
                        
                        
                    }
                    else if( (task.name.ContainsIgnoreCase(wfUtil.SubmitFinalRebateClaim))  
                            && task.Status__c != oldMap.get(task.Id).Status__c && task.Status__c == wfUtil.COMPLETE ){
                                sceObj.Rebate_Form_Sent__c = system.today();
                                sceIds.add(sceObj);                  
                            }
                    
                }
            }
        }   
        if (sceIds.size()>0 && ! sceids.isEmpty()    ){
            update sceIds;
        }           
    }
 
    public static void updateUtilityDelayUntilDate(boolean IsInsert, boolean IsUpdate, map<Id,task__c> newMap, map<Id,task__c> oldMap){
        
        Set<string> taskNames =  new Set<string>();
        Map<Id,Task__c> MapupdateTask =  new  Map<Id,Task__c>();
        Map<string,decimal> getUtilityDelayDays =  new  Map<string,decimal>();
        DateTime StartDateSinceLastOpen= DateTime.now();
        DateTime SiteAuditScheduled =DateTime.now();
        DateTime ScheduledInstallDate =DateTime.now();
        Map<string,string> taskNameMap= new  Map<string,string>();
        
        List<Task__c> tskObjList = [Select Id, Name,Utility__c,Status__c,Start_Date_Since_Last_Open__c,Utility_Delay_Until__c,
                                    Project_Name__r.Service_Contract__r.Service_Contract_Event__r.Scheduled_Install_Date__c , 
                                    Project_Name__r.Service_Contract__r.Service_Contract_Event__r.Site_Audit_Scheduled__c  from Task__c where Id in :newMap.keySet() 
                                    and  Status__c=:wfutil.OPEN]; 
        
        for(task__c taskObj : newMap.values()){
            
            if(IsInsert|| (IsUpdate && newMap.get(taskObj.id).Start_Date_Since_Last_Open__c!=oldMap.get(taskObj.id).Start_Date_Since_Last_Open__c)){
                taskNames.add(taskObj.Name);
            }
        }
        system.debug('taskNames' +  taskNames);
        
        If(taskNames.size()>0){
            
            for(Utility_Delay_Days__c uddc:[select Utility_Company__c,Utility_Delay_Days__c ,Task_Name__c from Utility_Delay_Days__c where Task_Name__c in:taskNames ]){
                getUtilityDelayDays.put(uddc.Utility_Company__c,uddc.Utility_Delay_Days__c);
                taskNameMap.put(uddc.Task_Name__c, uddc.Task_Name__c);
            }
            
            
            If(getUtilityDelayDays.size() > 0){
                for(task__c tskObj: tskObjList ){
                    
                    If(tskObj.Start_Date_Since_Last_Open__c !=null ){
                        StartDateSinceLastOpen = tskObj.Start_Date_Since_Last_Open__c;
                    }                    
                    If(tskObj.Project_Name__r.Service_Contract__r.Service_Contract_Event__r.Scheduled_Install_Date__c  !=null ){
                        Date scheduleDate = tskObj.Project_Name__r.Service_Contract__r.Service_Contract_Event__r.Scheduled_Install_Date__c;
                        ScheduledInstallDate =  datetime.newInstance(scheduleDate.year(), scheduleDate.month(),scheduleDate.day()); 
                    }
                    
                    If(tskObj.Project_Name__r.Service_Contract__r.Service_Contract_Event__r.Site_Audit_Scheduled__c !=null ){
                        SiteAuditScheduled = tskObj.Project_Name__r.Service_Contract__r.Service_Contract_Event__r.Site_Audit_Scheduled__c;
                    }
                    
                    
                    If(tskObj.Name=='Start Installation'){
                        tskObj.Utility_Delay_Until__c =   ScheduledInstallDate.addDays(Integer.valueof(getUtilityDelayDays.get('DEFAULT')));
                       MapupdateTask.put(tskObj.Id, tskObj);
                      
                    } else if (tskObj.Name=='Finish Site Audit'){
                        tskObj.Utility_Delay_Until__c =   SiteAuditScheduled.addDays(Integer.valueof(getUtilityDelayDays.get('DEFAULT')));
                         MapupdateTask.put(tskObj.Id, tskObj);
                    }else{
                        If(getUtilityDelayDays.containsKey(tskObj.Utility__c)){                            
                            tskObj.Utility_Delay_Until__c =   StartDateSinceLastOpen.addDays(Integer.valueof(getUtilityDelayDays.get(tskObj.Utility__c)));
                        }else {
                            tskObj.Utility_Delay_Until__c =   StartDateSinceLastOpen.addDays(Integer.valueof(getUtilityDelayDays.get('DEFAULT')));
                        }                        
                         MapupdateTask.put(tskObj.Id, tskObj);
                        system.debug('MapupdateTask>>>'  + MapupdateTask);
                    }
                    
                }
            }
            
        }
        for(task__c tskObj: tskObjList ){
            
            If(Trigger.IsInsert|| (Trigger.IsUpdate && newMap.get(tskObj.id).Start_Date_Since_Last_Open__c!=oldMap.get(tskObj.id).Start_Date_Since_Last_Open__c)){
                If (!taskNameMap.containsKey(tskObj.Name)){
                    If(tskObj.Start_Date_Since_Last_Open__c !=null ){
                        StartDateSinceLastOpen = tskObj.Start_Date_Since_Last_Open__c;
                    } 
                    tskObj.Utility_Delay_Until__c =StartDateSinceLastOpen ;
                    MapupdateTask.put(tskObj.Id, tskObj);
                }
            }
            
        }
        
        if(!MapupdateTask.isEmpty()){
            system.debug('MapupdateTask>>' +  MapupdateTask);
            update MapupdateTask.values();
        }
        
    }
    
    
 }