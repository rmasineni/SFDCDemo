public with sharing class WorkflowManagement {
	public static Integer START_BUSINESS_HOUR = 0;
	public static Integer END_BUSINESS_HOUR = 24;
	
	public void createProject(Map<Id, Id> optyProposalMap, Map<Id, String> projectTypeMap){
		
		Savepoint savePoint1;   
		try{
			if(optyProposalMap.isEmpty())
				return;
			
			wfUtil.skipTDTrigger = true;
			Set<Id> existingOptyIds = new Set<Id>();
			Map<Id, Project__C> modifiedProjects = new Map<Id, Project__C>();
			for(Project__C projectObj : [Select Id, Opportunity__c from Project__C where Opportunity__c in :optyProposalMap.keySet()]){
				existingOptyIds.add(projectObj.Opportunity__c);
				Id proposalId = optyProposalMap.get(projectObj.Opportunity__c);
				projectObj.proposal__c = proposalId;
				modifiedProjects.put(projectObj.Id, projectObj);
			}
			
			Set<Id> tempOptyIds = optyProposalMap.keySet();
			if(!existingOptyIds.isEmpty()){
				tempOptyIds.removeall(existingOptyIds);
			}
			
			if(!modifiedProjects.isEmpty()){
				update modifiedProjects.values();
			}
			
			if(tempOptyIds.isEmpty()){
				System.debug('Existing Opty Ids: ' + modifiedProjects.keySet());
				return;
			}
			
			Date todaysDate = Date.today();

			Map<Id, ServiceContract> scMap = new Map<Id, ServiceContract>();
			for(ServiceContract scObj : [Select Id, name, Opportunity__r.Id,Opportunity__r.name, Opportunity__c  from ServiceContract where Opportunity__C in:tempOptyIds]){
				scMap.put(scObj.Opportunity__c, scObj);
			}

			Map<String, Project_Template__c> projectTemplateMap = new Map<String, Project_Template__c>();
			Set<Id> projectTemplateIds = new Set<Id>();
			for(Project_Template__c projectTemplateObj : [Select Id, Type__c, Description__c, start_date__c, End_Date__c, 
															(Select Start_Date__c, Project_Template__c, Phase_Status__c, Phase_Number__c, Name, Id, End_Date__c, Description__c from Phase_Templates__r) from 
															Project_Template__c where 	Type__c IN :projectTypeMap.values() 
															and Start_Date__c <= :todaysDate and End_Date__c >= :todaysDate]){
				projectTemplateMap.put(projectTemplateObj.Type__c, projectTemplateObj);
				projectTemplateIds.add(projectTemplateObj.Id);
			}
			
			Map<String, List<Task_Template__c>> taskTemplateMap = new Map<String, List<Task_Template__c>>();
			Map<String, List<Task_Dependency_Template__c>> tdTemplateMap = new Map<String, List<Task_Dependency_Template__c>>();
			Set<String> proposalFields = new Set<String>();
			Set<String> optyFields = new Set<String>();
			for(Task_Template__c taskTemplateObj : [Select Phase_Template__r.name, Phase_Template__r.Id, Phase_Template__r.Project_Template__r.Type__c,Task_Description__c,Type__c,
														Display_Field1__c, Display_Field2__c, Display_Field3__c, Display_Field4__c, Display_Field5__c,
														Display_Object1__c, Display_Object2__c, Display_Object3__c,  Display_Object4__c, Display_Object5__c,
														Object_Name1__c, Object_Name2__c, Object_Name3__c,  Object_Name4__c, Object_Name5__c,
														Field_Name1__c, Field_Name2__c, Field_Name3__c, Field_Name4__c, Field_Name5__c, Has_Dependent_Rules__c,
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
														Req6__c,Req7__c,Req8__c, Req9__c, Req10__c,Req16__c,Req17__c,Req18__c, Req19__c, Req20__c,
														Task_Owner__c, SLA_In_Hours__c, Related_Task__c, Phase_Template__c,   Name, LastModifiedDate,
														LastModifiedById, Group_Name__c, Category__c, 	Task_Number__c,
														(Select Id, name, Action__c, Dependent_Task_Template_Name__c, 
															Field_Name1__c, Field_Value1__c, Object_Name1__c,
														 	Field_Name2__c, Field_Value2__c, Object_Name2__c,
														 	Field_Name3__c, Field_Value3__c, Object_Name3__c,
														 	Field_Name4__c, Field_Value4__c, Object_Name4__c,
														 	Field_Name5__c, Field_Value5__c, Object_Name5__c,
														 	Is_Required__c 
															from Workflow_Creation_Rules__r),
														(Select Id, name, Task_Template__c, Task_Template__r.name, Parent_Task_Template__r.name, Child_Task_Template__r.name, 
														Parent_Task_Template__r.Category__c from Task_Dependency_Templates__r) 
														from Task_Template__c where Phase_Template__r.Project_Template__c in :projectTemplateIds]){
				
				List<Task_Template__c> tempTaskList = taskTemplateMap.containsKey(taskTemplateObj.Phase_Template__r.Project_Template__r.Type__c) ? 
														taskTemplateMap.get(taskTemplateObj.Phase_Template__r.Project_Template__r.Type__c) : new List<Task_Template__c>();
				tempTaskList.add(taskTemplateObj);
				taskTemplateMap.put(taskTemplateObj.Phase_Template__r.Project_Template__r.Type__c, tempTaskList);
	
				List<Task_Dependency_Template__c> tempTDList = tdTemplateMap.containsKey(taskTemplateObj.Phase_Template__r.Project_Template__r.Type__c) ? 
																tdTemplateMap.get(taskTemplateObj.Phase_Template__r.Project_Template__r.Type__c) : new List<Task_Dependency_Template__c>();
				for(Task_Dependency_Template__c tdObj : taskTemplateObj.Task_Dependency_Templates__r){
					tempTDList.add(tdObj);
					tdTemplateMap.put(taskTemplateObj.Phase_Template__r.Project_Template__r.Type__c, tempTDList);
				}
				
				for(Workflow_Creation_Rule__c wfCreationRuleObj : taskTemplateObj.Workflow_Creation_Rules__r){
					for(Integer i=1; i<=5; i++){
						String objectName = 'Object_Name' + i + '__c';
						String fieldName = 'Field_Name' + i + '__c';
						String fieldNameFinal = getFieldName(String.valueOf(wfCreationRuleObj.get(objectName)), String.valueOf(wfCreationRuleObj.get(fieldName)));
						if(!String.isEmpty(fieldNameFinal)){
							proposalFields.add(fieldNameFinal);
						}
					}
				}
			}
			Map<Id, Proposal__c> proposalMap = new Map<Id, Proposal__c>();
			proposalFields.add('name');
			proposalFields.add('Opportunity__c');
			proposalFields.add('Opportunity__r.accountId');
			proposalFields.add('Opportunity__r.Opportunity_Number__c');
			proposalFields.add('Opportunity__r.Id');
			proposalFields.add('Opportunity__r.name');
			proposalFields.add('Opportunity__r.Account.BillingStreet');
			proposalFields.add('Opportunity__r.Account.BillingCity');
			proposalFields.add('Opportunity__r.Account.BillingState');
			proposalFields.add('Opportunity__r.Account.BillingCountry');
			proposalFields.add('Opportunity__r.Account.BillingPostalCode');
			proposalFields.add('Opportunity__r.Project_Number__c');
			String proposalSOQLStr = 'Select ';
			for(String fieldName : proposalFields){
				proposalSOQLStr += fieldName + ', ';
			}
			
			List<Id> proposalIds = optyProposalMap.values();
			proposalSOQLStr += ' Id from Proposal__c where Opportunity__c in:tempOptyIds and Id in :proposalIds ';
			System.debug('proposalSOQLStr: ' + proposalSOQLStr);
			proposalMap = new Map<Id,Proposal__c>((List<Proposal__c>)Database.query(proposalSOQLStr));			
			
			//Map<Id, Proposal__c> proposalMap = new Map<Id, Proposal__c>([Select Id, name, 
																		//Opportunity__r.accountId, Opportunity__r.Opportunity_Number__c, Opportunity__r.Id,Opportunity__r.name, 
			//															Opportunity__r.Account.BillingStreet, Opportunity__r.Account.BillingCity, Opportunity__r.Account.BillingState, 
			//															Opportunity__r.Account.BillingCountry, 
			//															Opportunity__r.Account.BillingPostalCode, Opportunity__r.Project_Number__c,
			//															Opportunity__c from Proposal__c where Opportunity__C in:tempOptyIds and Id in :optyProposalMap.values()]);
			
			//Database.query(proposalSOQLStr);

			
			savePoint1 = Database.setSavepoint();
			System.debug('Test2');
			for(Id optyId : tempOptyIds){
                
                // fill the map with optyTeam based on opty
                List<Opportunity_Team__c> listOptyTeam = new List<Opportunity_Team__c>();
                Map<String,String> OptyTeamMap =  new Map<String,String>();       
                listOptyTeam = [Select role__c,user__c from Opportunity_Team__c where Opportunity__c=:optyId];
                for(Opportunity_Team__c optyTeam : listOptyTeam){
                    OptyTeamMap.put(optyTeam.Role__c,optyTeam.User__c);
                }       
                        
                
				String templateName = projectTypeMap.get(optyId);
				Project_Template__c projectTemplateObj = projectTemplateMap.get(templateName);
				Id proposalId = optyProposalMap.get(optyId);
				ServiceContract scObj = scMap.get(optyId);
				Proposal__C proposalObj = proposalMap.get(proposalId);
				Project__c projectObj = createProject(projectTemplateObj, proposalObj, scObj);
				System.debug('projectObj: ' + projectObj);
				
				Map<String, Phase__c> phaseMap = createPhases(projectTemplateObj, projectObj);
				System.debug('phaseMap: ' + phaseMap);
				Map<String, Task__c> taskMap = createTasks(projectTemplateObj, phaseMap, taskTemplateMap.get(projectTemplateObj.type__c), proposalObj,OptyTeamMap);
				System.debug('tdTemplateMap: ' + tdTemplateMap);
				List<Task_Dependency__c> taskDependencyList = createTaskDependency(tdTemplateMap.get(projectTemplateObj.type__c), taskMap, projectObj.Id);
			}
			
		}catch(Exception expObj){
			System.debug('From Catch ' + expObj);
        	System.debug('Cause: ' + expObj.getCause());
        	System.debug('LineNumber: ' + expObj.getLineNumber());
			Database.rollback(savePoint1);  
		}
	}
	
	public String getFieldName(String objectName, String fieldName){
		String result = '';
		System.debug('objectName : ' + objectName);
		System.debug('fieldName : ' + fieldName);
		if(!String.isEmpty(objectName) && !String.isEmpty(fieldName)){
			if(objectName.trim().equalsIgnoreCase('Opportunity')){
				result = 'Opportunity__r.' + fieldName.trim();
			}else if(objectName.trim().equalsIgnoreCase('Proposal__c')){
				result = fieldName.trim();
			}			
		}
		System.debug('result : ' + result);
		return result;
	}
	
	public Project__c createProject(Project_Template__c projectTemplateObj, Proposal__C proposalObj, ServiceContract scObj){
		Project__c projectObj = new Project__c();
		projectObj.Start_Date__c = Date.today();
		String tempProjectName = ServiceContractUtil.getProjectNameFromOptyNumber(proposalObj.Opportunity__r.Opportunity_Number__c);
		tempProjectName = (tempProjectName == '') ? proposalObj.Opportunity__r.name : tempProjectName;
		projectObj.name = tempProjectName;
		projectObj.account__c = proposalObj.Opportunity__r.accountId;
		projectObj.opportunity__c = proposalObj.Opportunity__c;
		projectObj.proposal__c = proposalObj.Id;
		projectObj.type__c = projectTemplateObj.type__c;
		projectObj.status__c = wfUtil.OPEN;
		projectObj.job_code__c = proposalObj.Opportunity__r.Project_Number__c;
		if(scObj != null){
			projectObj.service_Contract__c = scObj.Id;
		}
		projectObj.Address__c = wfUtil.getAddressString(proposalObj.Opportunity__r.Account);
		insert projectObj;
		
		return projectObj;
	}
	
	public Map<String, Phase__c> createPhases(Project_Template__c projectTemplateObj, Project__c projectObj){
		Map<String, Phase__c> phaseMap = new Map<String, Phase__c>();
		for(Phase_Template__c phaseTemplateObj : projectTemplateObj.Phase_Templates__r){
			Phase__c phaseObj = new Phase__c();
			phaseObj.name = phaseTemplateObj.name;
			phaseObj.Phase_Status__c = phaseTemplateObj.Phase_Status__c;
			phaseObj.project__c = projectObj.Id;
			phaseObj.Phase_Number__c = phaseTemplateObj.Phase_Number__c;
			phaseObj.Description__c = phaseTemplateObj.Description__c;
			phaseMap.put(phaseObj.name, phaseObj);
		}
		insert phaseMap.values();
		
		return phaseMap;
	}

	public Map<String, Task__c> createTasks(Project_Template__c projectTemplateObj, Map<String, Phase__c> phaseMap, List<Task_Template__c> taskTemplates, Proposal__c proposalObj,Map<String,String> OptyTeamMap){
		Opportunity optyObj = proposalObj.opportunity__r;
		Map<String, Task__c> taskMap = new Map<String, Task__c>();
		for(Task_Template__c taskTemplateObj : taskTemplates){
			Task__c taskObj = new Task__c();
			Phase__c phaseObj = phaseMap.get(taskTemplateObj.Phase_Template__r.name);
			taskObj.Name = taskTemplateObj.Name;
			taskObj.phase__c = phaseObj.Id;

			taskObj.Type__c = taskTemplateObj.Type__c;
			taskObj.Task_Owner__c = taskTemplateObj.Task_Owner__c;
			taskObj.SLA_In_Hours__c = taskTemplateObj.SLA_In_Hours__c;
			taskObj.Related_Task__c = taskTemplateObj.Related_Task__c;
			taskObj.Group_Name__c = taskTemplateObj.Group_Name__c;
			taskObj.Category__c = taskTemplateObj.Category__c;
			taskObj.project_name__c = phaseObj.Project__c;
			taskObj.Has_Dependent_Rules__c = taskTemplateObj.Has_Dependent_Rules__c;
			 //assign the optyTeam user as Task owner if task group name matches with optyTeam Role
            If(taskTemplateObj.Group_Name__c!=null && taskTemplateObj.Group_Name__c!=''){
                If(OptyTeamMap.containsKey(taskTemplateObj.Group_Name__c)){
                    taskObj.Task_Owner__c=OptyTeamMap.get(taskTemplateObj.Group_Name__c);
                }
            }
			if(taskTemplateObj.Workflow_Creation_Rules__r != null && !taskTemplateObj.Workflow_Creation_Rules__r.isEmpty()){
				Set<String> result = new Set<String>();
				String actionStr = '';
				String actualRuleName = '';
				String ruleName = 'National Grid - Receive Final Rebate Claim With Customer Signature to';
				for(Workflow_Creation_Rule__c wfCreationRuleObj : taskTemplateObj.Workflow_Creation_Rules__r){
					actualRuleName = wfCreationRuleObj.name;
					String ruleId = wfCreationRuleObj.Id;
					Set<String> tempResult = new Set<String>();
					for(Integer i=1; i<=5; i++){
						String objectNameStr = String.valueOf(wfCreationRuleObj.get('Object_Name' + i + '__c'));
						String fieldNameStr = String.valueOf(wfCreationRuleObj.get('Field_Name' + i + '__c'));
						
						String expectedValue = '';
						String actualValue = '';
						Boolean isValidField = false;
						if(!String.isEmpty(objectNameStr) && objectNameStr.trim().equalsIgnoreCase('Opportunity')){
							expectedValue = String.valueOf(wfCreationRuleObj.get('Field_Value' + i + '__c'));
							actualValue = 	String.valueOf(optyObj.get(fieldNameStr));	
							isValidField = true;						
						}else if(!String.isEmpty(objectNameStr) && objectNameStr.trim().equalsIgnoreCase('Proposal__c')){
							expectedValue = String.valueOf(wfCreationRuleObj.get('Field_Value' + i + '__c'));
							actualValue = 	String.valueOf(proposalObj.get(fieldNameStr)) ;
							isValidField = true;	
						}						
						
						if(isValidField){
							if(!String.isEmpty(expectedValue) && !String.isEmpty(actualValue)){
								expectedValue = expectedValue.trim().toLowerCase();
								actualValue = actualValue.trim().toLowerCase();
								if(expectedValue == actualValue){
									tempResult.add('true');
								}else{
									tempResult.add('false');
								}
							}else{
								tempResult.add('false');
							}
						}
					}
					if(!tempResult.isEmpty() && !tempResult.contains('false') && tempResult.contains('true')){
						result.add('true');
						actionStr = wfCreationRuleObj.action__c;
					}else if(wfCreationRuleObj.Is_Required__c != true){
						result.add('optional');
					}else{
						result.add('false');
					}

					if(taskObj.Name == 'Receive Final Rebate Claim With Customer Signature' && wfCreationRuleObj.name.contains(ruleName)){
						System.debug('tempResult1 : ' + tempResult + ' result1 : ' + result + ' wfCreationRuleObj.Is_Required__c1 : ' + wfCreationRuleObj.Is_Required__c + ' actionStr: ' + actionStr);
					}

				}
				
				if(!result.isEmpty() && (!result.contains('false') && result.contains('true') && !String.isEmpty(actionStr) && taskTemplateObj.category__c != actionStr)){
					taskObj.Category__c = actionStr;
				}
				if(taskObj.Name == 'Receive Final Rebate Claim With Customer Signature' && actualRuleName.contains(ruleName)){
					System.debug('taskTemplateObj.category__c3 : ' + taskTemplateObj.category__c + ' result3 : ' + result );
				}				
			}
			System.debug('taskObj.Category__c : ' + taskObj.Category__c );

			Boolean openTask = true;
			if(taskTemplateObj.Category__c != wfUtil.REQUIRED){
				openTask = false;
			}else if(taskTemplateObj.Task_Dependency_Templates__r != null && !taskTemplateObj.Task_Dependency_Templates__r.isEmpty()){
				for(Task_Dependency_Template__c tdTemplateObj : taskTemplateObj.Task_Dependency_Templates__r){
					if(tdTemplateObj.Parent_Task_Template__r.Category__c != null && tdTemplateObj.Parent_Task_Template__r.Category__c  == wfUtil.REQUIRED){
						openTask = false;
						break;
					}
				}
			}
			
			if(!openTask){
                System.debug('taskObj.status__c ' + taskObj.status__c);
				taskObj.status__c = wfUtil.INACTIVE;
				taskObj.start_date__c = null;
                System.debug('taskObj.status__c--2 ' + taskObj.status__c);
			}else{
				System.debug('taskObj.Name: ' + taskObj.Name);
				taskObj.status__c = wfUtil.OPEN;
				taskObj.start_date__c = Datetime.now();
				if(taskObj.SLA_In_Hours__c > 0){
					setSLAEndTimeImpl(taskObj);
				}
			}

			for(Integer i=1; i<=20; i++){
				String field1 = 'Display_Object' + i + '__c';
				String field2 = 'Display_Field' + i + '__c';
				String field3 = 'Object_Name' + i + '__c';
				String field4 = 'Field_Name' + i + '__c';
				String field5 = 'Req' + i + '__c';
				taskObj.put(field1, taskTemplateObj.get(field1));
				taskObj.put(field2, taskTemplateObj.get(field2));
				taskObj.put(field3, taskTemplateObj.get(field3));
				taskObj.put(field4, taskTemplateObj.get(field4));
				taskObj.put(field5, taskTemplateObj.get(field5));
			}
			taskObj.Task_Description__c = taskTemplateObj.Task_Description__c;
			taskObj.Task_Number__c = taskTemplateObj.Task_Number__c;
			taskMap.put(taskObj.Name, taskObj);
		}
		
		insert taskMap.values();
		return taskMap;
	}
	
	public List<Task_Dependency__c> createTaskDependency(List<Task_Dependency_Template__c> tdTemplateList, Map<String, Task__c> taskMap, String projectId){
		if(tdTemplateList == null || tdTemplateList.isEmpty())
			return null;
			
		List<Task_Dependency__c> tasDependencies = new List<Task_Dependency__c>();
		for(Task_Dependency_Template__c taskTemplateObj : tdTemplateList){
			Task_Dependency__c td = new Task_Dependency__c();
			td.name = taskTemplateObj.name;
			td.project_name__c = projectId;
			td.task__c = taskMap.get(taskTemplateObj.Task_Template__r.name).Id;
			if(taskTemplateObj.Parent_Task_Template__r != null && taskTemplateObj.Parent_Task_Template__r.Id != null){
				td.parent_task__c = taskMap.get(taskTemplateObj.Parent_Task_Template__r.name).Id;
			}
			
			if(taskTemplateObj.Child_Task_Template__r != null && taskTemplateObj.Child_Task_Template__r.Id != null){
				td.child_task__c = taskMap.get(taskTemplateObj.Child_Task_Template__r.name).Id;
			}
			
			tasDependencies.add(td);
		}
		insert tasDependencies;
		return tasDependencies;	
	}
	
	static Set<Date> sunrunHolidays;
	public static Set<Date> getHolidays(){
		if(sunrunHolidays == null){
			Date currentDate = Date.today();
			Date endDate = Date.today().adddays(365);
			sunrunHolidays = new Set<Date>();
			Boolean active = true;
			for(Holiday__c holidayObj : [Select Id, Holiday_Date__c from Holiday__c where Holiday_Date__c >= :currentDate and Holiday_Date__c <= :endDate AND Active__c =:active ]){
				sunrunHolidays.add(holidayObj.Holiday_Date__c);
			}
		}
		return sunrunHolidays;
	}
	
	/*
	** Calculate the Expected End Datetime using start time and SLA hours.
	**
	*/
	
	public static void setSLAEndTime(Task__c taskObj){
		WorkflowManagement wfObj = new WorkflowManagement();
		wfObj.setSLAEndTimeImpl(taskObj);		
	}
	
	public void setSLAEndTimeImpl(Task__c taskObj){
		Decimal slaInHours = 0.0;
		if(taskObj != null && taskObj.SLA_In_Hours__c != null){
			slaInHours = taskObj.SLA_In_Hours__c;
		}
		Datetime slaDateTime = getSLATimeImpl(Datetime.now(), Integer.valueOf(slaInHours));
		taskObj.Expected_Close_Date__c = slaDateTime;
		
		Datetime slaDateTime2 = getSLATimeImpl2(Datetime.now(), Integer.valueOf(slaInHours));
		taskObj.Expected_Close_Date2__c = slaDateTime2;
	}

	public static DateTime getSLATime2(Datetime startTime, Integer slaHours){
		WorkflowManagement wfObj = new WorkflowManagement();
		return wfObj.getSLATimeImpl2(startTime, slaHours);
	}

	public DateTime getSLATimeImpl2(Datetime startTime, Integer slaHours){
		DateTime salEndTime = startTime;
		if(startTime == null)
			return null;
		
		if(slaHours <= 0){
			return startTime;
		}
		Double tempSlaHours = (Double) (slaHours * 0.8);
		return getSLATime(startTime, tempSlaHours);
	}

	public static DateTime getSLATime(Datetime startTime, Integer slaHours){
		WorkflowManagement wfObj = new WorkflowManagement();
		return wfObj.getSLATimeImpl(startTime, slaHours);
	}

	public DateTime getSLATimeImpl(Datetime startTime, Integer slaHours){
		DateTime salEndTime = startTime;
		if(startTime == null)
			return null;
		
		if(slaHours <= 0){
			return startTime;
		}
		Double tempSlaHours = (Double) (slaHours * 1.0);
		return getSLATime(startTime, tempSlaHours);
	}

	public static DateTime getSLATime(Datetime startTime, Double slaHours){
		WorkflowManagement wfObj = new WorkflowManagement();
		return wfObj.getSLATimeImpl(startTime, slaHours);
	}
	
	public DateTime getSLATimeImpl(Datetime startTime, Double slaHours){
		DateTime salEndTime = startTime;
		if(startTime == null)
			return null;
		
		if(slaHours <= 0){
			return startTime;
		}

		//Calculate Start Datetime for SLA
		Datetime tempStartTime = startTime;	
		tempStartTime = getWorkingDateTime(tempStartTime);	
		Integer currentHour = tempStartTime.hour();
		Integer millSeconds = tempStartTime.millisecond();
		/*
		** 
		//Following code has ben commented.
		if(currentHour < START_BUSINESS_HOUR){ // If the current time is before the 9:00 am
			tempStartTime = createBusinessDateTime(tempStartTime, false);
		}else if(currentHour >= END_BUSINESS_HOUR && millSeconds > 0){ // If the current time is after the 5:00 pm
			tempStartTime = tempStartTime.adddays(1);  //Add one day to the current date
			tempStartTime = createBusinessDateTime(tempStartTime, false); // Set the time to 9:00 am
			tempStartTime = getWorkingDateTime(tempStartTime);	//check the for the holidays
		}
		//
		**
		*/
		
		
		Datetime endofBusinessDay = createBusinessDateTime(tempStartTime, true);
		decimal decimalminutes = ((endofBusinessDay.getTime())/1000/60) - ((tempStartTime.getTime())/1000/60);
		System.debug('decimalminutes: ' + decimalminutes);
		decimal slaMinutes = slaHours * 60;
		if(decimalminutes >= slaMinutes){
			salEndTime = tempStartTime.addminutes(Integer.valueOf(slaMinutes));
		}else{
			Decimal tempMinutes= slaMinutes - decimalminutes;
			Decimal previousValue = 0;
			Integer count = 0;
			salEndTime = tempStartTime;
			while (tempMinutes > 0){
				Count = count + 1;
				previousValue = tempMinutes;
				tempMinutes = (tempMinutes - (24 * 60));
				salEndTime = salEndTime.adddays(1);  //Add one day to the current date
				salEndTime = createBusinessDateTime(salEndTime, false); // Set the time to 9:00 am
				salEndTime = getWorkingDateTime(salEndTime);	//check the for the holidays
				System.debug('**** previousValue *** ' + previousValue);
			}
			if(previousValue > 0 && previousValue < (24 * 60)){
				salEndTime = salEndTime.addminutes(Integer.valueOf(previousValue));
				salEndTime = getWorkingDateTime(salEndTime);
			}
		}
		System.debug('salEndTime: ' + salEndTime);
		return salEndTime;
	}
	
	public DateTime getWorkingDateTime(Datetime startTime){	
		System.debug('Input: getWorkingDateTime ' + startTime);
		Set<Date> tempHolidays = WorkflowManagement.getHolidays();
		while(true){
			if(!tempHolidays.contains(startTime.dateGMT())){
				break;
			}
			startTime = createBusinessDateTime(startTime, false);
			startTime = startTime.adddays(1);
		}
		System.debug('Working Date: ' + startTime);
		return startTime;
	}
	
	public DateTime createBusinessDateTime(Date startDate, Boolean isEOD){
		Integer hour = (isEOD == true) ? END_BUSINESS_HOUR : START_BUSINESS_HOUR;
		//Following line is commented for 24 hours business logic
		//return DateTime.newInstance(startDate.year(), startDate.month(), startDate.day(), START_BUSINESS_HOUR, 0, 0);
		return DateTime.newInstance(startDate.year(), startDate.month(), startDate.day(), hour, 0, 0);
	}

	public DateTime createBusinessDateTime(Datetime startDateTime, Boolean isEOD){
		Integer hour = (isEOD == true) ? END_BUSINESS_HOUR : START_BUSINESS_HOUR;
		Integer minutes = (isEOD == true) ? 59 : 0;
		//Following line is commented for 24 hours business logic
		//return DateTime.newInstance(startDateTime.year(), startDateTime.month(), startDateTime.day(), hour, 0, 0);
		return DateTime.newInstance(startDateTime.year(), startDateTime.month(), startDateTime.day(), hour, 0, 0);
	}

	/*
	** This method will be invoked to Open the successor task after closing the predecessor tasks.
	**
	*/
	
	@future
	public static void startChildTasks(Set<Id> parentTaskIds){
		if(parentTaskIds == null || parentTaskIds.isEmpty())
			return;
		WorkflowManagement wfObj = new WorkflowManagement();
		wfObj.startChildTasksImpl(parentTaskIds);
	}

	public void startChildTasksImpl(Set<Id> parentTaskIds){	
		Set<Id> childTaskIds = new Set<Id>();
		String inactiveStr = wfUtil.INACTIVE;
		string requiredStr = wfUtil.REQUIRED;
		string blockedStr = wfUtil.BLOCKED;
		string completedStr = wfUtil.COMPLETE;
		
		for(Task_Dependency__c tdObj : [Select Id, task__c,  parent_task__c, task__r.status__c, task__r.start_date__c
											from Task_Dependency__c where parent_task__c in :parentTaskIds 
											and task__c != null and (task__r.status__c =:inactiveStr OR task__r.status__c =:blockedStr) 
											and task__r.category__c =:requiredStr
										]){
			childTaskIds.add(tdObj.task__c);
		}
		System.debug('childTaskIds: ' + childTaskIds);
		List<Task__C> modifiedTasks = new List<Task__C>();
		for(Task__C taskObj : [Select Id, status__c, Blocked_Start_date__c, Blocked_End_date__c, start_date__c, SLA_In_Hours__c, Expected_Close_Date__c,
									(Select Id, parent_task__r.status__c, Name, Child_Task__c, Parent_Task__c, parent_task__r.category__c, Task__c 
										From Task_Dependencys__r  where parent_task__r.status__c != :completedStr and parent_task__r.category__c =:requiredStr) 
								from Task__c where Id in :childTaskIds]) {
			if(taskObj.Task_Dependencys__r == null || (taskObj.Task_Dependencys__r != null && taskObj.Task_Dependencys__r.isEmpty())){
				taskObj.status__c = wfUtil.OPEN;
				taskObj.start_date__c =  (taskObj.start_date__c == null) ? Datetime.now() : taskObj.start_date__c ;
				taskObj.end_date__c = null;
				if(taskObj.Blocked_Start_date__c != null){
					taskObj.Blocked_End_date__c = Datetime.now();
				}
				System.debug('SLA_In_Hours__c : ' + taskObj.SLA_In_Hours__c);
				System.debug('Expected_Close_Date__c : ' + taskObj.Expected_Close_Date__c);
				if(taskObj.SLA_In_Hours__c > 0 && taskObj.Expected_Close_Date__c == null){
					setSLAEndTimeImpl(taskObj);
				}
                else if(taskObj.Status__c == wfUtil.INACTIVE )  
                    continue;                         
                else {taskObj.status__c = wfUtil.BLOCKED;}                        
              
				modifiedTasks.add(taskObj);
			}
		}
		
		if(!modifiedTasks.isEmpty()){
			update modifiedTasks;
		}
	}

	
	


	/*
	** Following method will be invoked when the task categroy changes from Optional to Required.
	**
	*/
	//@future
	public static void updateTaskCategory(Map<String, String> taskActionMap){
		System.debug('taskActionMap: ' + taskActionMap);
		Task__c parentTaskObj;
		String reasonStr = 'Task category has been modified from Optional to Required';
		Map<Id, Task__c> taskMap = wfUtil.getTasks(taskActionMap.keySet());
		Map<Id, Task__c> modifiedOptionalTasks = new Map<Id, Task__c>();
		for(Task__c taskObj : taskMap.values()){
			WorkflowManagement wfObj = new WorkflowManagement();
			String actionStr = taskActionMap.get(taskObj.Id);
			System.debug('actionStr: ' + actionStr);
			taskObj.category__c = actionStr;
			if(actionStr == wfUtil.REQUIRED){
				wfObj.updateTaskCategoryImpl(taskObj, actionStr, reasonStr);
			}else if(actionStr == wfUtil.OPTIONAL){
				taskObj.category__c = wfUtil.OPTIONAL;
				taskObj.start_date__c = null;
				taskObj.End_date__c = null;
				taskObj.Status__c = wfUtil.INACTIVE;
				taskObj.Expected_Close_Date__c = null;
				taskObj.Expected_Close_Date2__c = null;
				modifiedOptionalTasks.put(taskObj.Id, taskObj);
			}
		}
		
		if(!modifiedOptionalTasks.isEmpty()){
			System.debug('modifiedOptionalTasks.keySet(): ' + modifiedOptionalTasks.keySet());
			update modifiedOptionalTasks.values();
		}
	}
	

	public String updateTaskCategoryImpl(Task__c parentTaskObj, String actionName, String reasonStr){	
		System.debug('actionName: ' + actionName);
		String result = '';
		Savepoint savePoint1; 
		String requiredStr = wfUtil.REQUIRED;
		String complete = wfUtil.COMPLETE;
		Set<Id> tempParentIds = new Set<Id>();
		try{
			if(parentTaskObj == null || parentTaskObj.Id == null){
				result = 'Task record is null OR empty';
				return result;
			}
			savePoint1 = Database.setSavepoint();
			Map<Id, Task__C> modifiedTasks = new Map<Id, Task__C>();
			Set<Id> projectIds = new Set<Id>();
			if(parentTaskObj != null && parentTaskObj.Id != null){
				
				Task__c tempParentTask = [Select Id, status__c, start_date__c, Expected_Close_Date__c, Phase__r.Project__c,
									Blocked_start_date__c, Blocked_Reason__c,
									(Select Id, task__c, parent_task__r.Id, parent_task__r.category__c from Task_Dependencys__r 
										where parent_task__c != null and parent_task__r.category__c =:requiredStr and 
										parent_task__r.status__c != :complete) 
									from Task__c where Id =:parentTaskObj.Id];
				if(parentTaskObj.Phase__r.Project__c != null){
					projectIds.add(tempParentTask.Phase__r.Project__c);
				}
				if(actionName == wfUtil.CATEGORY_CHANGE || actionName == wfUtil.REQUIRED){
					tempParentIds.add(tempParentTask.Id);
					tempParentTask.category__c = wfUtil.REQUIRED;
                    system.debug('>>tempParentTask.category__c' + tempParentTask.category__c);
                    system.debug('>>tempParentTask.Status__c' + tempParentTask.status__c);
					if(tempParentTask.Task_Dependencys__r == null || tempParentTask.Task_Dependencys__r.isEmpty()){
                        system.debug('>>tempParentTask.Status__c2::' + tempParentTask.status__c);
						tempParentTask.status__c = wfUtil.OPEN; 
						tempParentTask.start_date__c = Datetime.now();
						tempParentTask.end_date__c = null;
						if(tempParentTask.SLA_In_Hours__c > 0 && tempParentTask.Expected_Close_Date__c == null){
							setSLAEndTimeImpl(tempParentTask);
						}
					}
					modifiedTasks.put(tempParentTask.Id, tempParentTask);	
                    system.debug('>>tempParentTask.Status__c33::' + tempParentTask.status__c);
				}		
			}
			
			/*
			//Following code makes the dependent tasks also as REQUIRED
			Map<Id, Task__C> tasksMap = new Map<Id, Task__C>();
			Map<Id, Set<Id>> taskIds = new Map<Id, Set<Id>>();
			for(Task__c taskObj : [Select Id, status__c, start_date__c, Expected_Close_Date__c, Phase__r.Project__c,
									Blocked_start_date__c, Blocked_Reason__c,
									(Select Id, task__c, parent_task__r.Id, parent_task__r.category__c from Task_Dependencies1__r 
										where task__c != null) 
									from Task__c where Phase__r.Project__c in :projectIds]){
	
				Set<Id> childTaskIds = taskIds.containsKey(taskObj.Id) ? taskIds.get(taskObj.Id) : new Set<Id>();
				if(taskObj.Task_Dependencies1__r != null){
					for(Task_Dependency__c tskDependency : taskObj.Task_Dependencies1__r){
						childTaskIds.add(tskDependency.task__c);
					}
				}
				taskIds.put(taskObj.Id, childTaskIds);
				tasksMap.put(taskObj.Id, taskObj);
			}
	
			Boolean condition = true;
			Set<Id> tempChildIds = new Set<Id>();

			while(condition){
				for(Id taskParentId : tempParentIds){
					tempChildIds = new Set<Id>();
					for(Id childTaskId : taskIds.get(taskParentId)){
						Task__c tempTaskObj = tasksMap.get(childTaskId);
						if(actionName == wfUtil.CATEGORY_CHANGE  || actionName == wfUtil.REQUIRED){
							tempTaskObj.category__c = wfUtil.REQUIRED;
						}						
						if(isTaskEligbleForBlocked(tempTaskObj)){
							tempTaskObj.status__c = wfUtil.BLOCKED; 
							tempTaskObj.end_date__c = null;
							tempTaskObj.Blocked_start_date__c = Datetime.now() ;
							tempTaskObj.Blocked_Reason__c = reasonStr ;
						}
						tempChildIds.add(tempTaskObj.Id);
						modifiedTasks.put(tempTaskObj.Id, tempTaskObj);
					}
				}
				System.debug('tempChildIds: ' + tempChildIds);
				if(tempChildIds != null && !tempChildIds.isEmpty()){
					tempParentIds = new Set<Id>();
					tempParentIds.addall(tempChildIds);
				}else{
					break;
				}
			}
			*/
			
			if(!modifiedTasks.isEmpty()){
				update modifiedTasks.values();
			}
		}catch(Exception expObj){
			result = expObj.getmessage();
			System.debug('From Catch ' + expObj);
        	System.debug('Cause: ' + expObj.getCause());
        	System.debug('LineNumber: ' + expObj.getLineNumber());
			Database.rollback(savePoint1);
		}
		return result;
	}
	
	/*
	**
	**
	*/
	public static void reopenTask(Id taskId, String reopenReason){
		List<Task__c> taskList = [Select Id, name, start_date__c, end_date__c, status__c, reopen__c, SLA_In_Hours__c, Phase__r.Project__c, Expected_Close_Date__c 
								from Task__c where Id =:taskId]; 
		if(!taskList.isEmpty()){
			WorkflowManagement wfObj = new WorkflowManagement();
			taskList[0].Reopen_Reason__c = reopenReason;
			wfObj.reopenTasksImpl(taskList[0]);
		}
	}
	
	public static void reopenTask(Id taskId){
		reopenTask(taskId, '');
	}

	public String reopenTasksImpl(Task__c parentTaskObj){	
		String result = '';
		Savepoint savePoint1; 
		String requiredStr = wfUtil.REQUIRED;
		Set<Id> tempParentIds = new Set<Id>();
		try{
			
			if(parentTaskObj == null || parentTaskObj.Id == null){
				result = 'Task record is null OR empty';
				return result;
			}
			
			savePoint1 = Database.setSavepoint();
			Map<Id, Task__C> modifiedTasks = new Map<Id, Task__C>();
			Set<Id> projectIds = new Set<Id>();
			if(parentTaskObj != null && parentTaskObj.Id != null){
				tempParentIds.add(parentTaskObj.Id);
				if(parentTaskObj.Phase__r.Project__c != null){
					projectIds.add(parentTaskObj.Phase__r.Project__c);
				}
				parentTaskObj.status__c = wfUtil.OPEN;
				parentTaskObj.Reopen__C = true ;
				parentTaskObj.end_date__c = null;
				if(parentTaskObj.SLA_In_Hours__c > 0 && parentTaskObj.Expected_Close_Date__c == null){
					setSLAEndTimeImpl(parentTaskObj);
				}
				modifiedTasks.put(parentTaskObj.Id, parentTaskObj);				
			}
			
			Map<Id, Task__C> tasksMap = new Map<Id, Task__C>();
			Map<Id, Set<Id>> taskIds = new Map<Id, Set<Id>>();
			for(Task__c taskObj : [Select Id, status__c, start_date__c, Expected_Close_Date__c, Phase__r.Project__c,
									Blocked_start_date__c, Blocked_Reason__c,
									(Select Id, task__c, parent_task__r.Id, parent_task__r.category__c from Task_Dependencies1__r 
										where task__c != null and parent_task__r.category__c =:requiredStr) 
									from Task__c where Phase__r.Project__c in :projectIds]){
	
				Set<Id> childTaskIds = taskIds.containsKey(taskObj.Id) ? taskIds.get(taskObj.Id) : new Set<Id>();
				if(taskObj.Task_Dependencies1__r != null){
					for(Task_Dependency__c tskDependency : taskObj.Task_Dependencies1__r){
						childTaskIds.add(tskDependency.task__c);
					}
				}
				taskIds.put(taskObj.Id, childTaskIds);
				tasksMap.put(taskObj.Id, taskObj);
			}
	
			Boolean condition = true;
			Set<Id> tempChildIds = new Set<Id>();

			while(condition){
				for(Id taskParentId : tempParentIds){
					tempChildIds = new Set<Id>();
					for(Id childTaskId : taskIds.get(taskParentId)){
						Task__c tempTaskObj = tasksMap.get(childTaskId);
						if(isTaskEligbleForBlocked(tempTaskObj)){
							tempTaskObj.status__c = wfUtil.BLOCKED;
							tempTaskObj.Reopen__C = true ;
							tempTaskObj.end_date__c = null;
							tempTaskObj.Blocked_start_date__c = Datetime.now() ;
							tempTaskObj.Blocked_Reason__c = 'Re-Opened predecessor task' ;
							tempChildIds.add(tempTaskObj.Id);
							modifiedTasks.put(tempTaskObj.Id, tempTaskObj);
						}
					}
				}
				System.debug('tempChildIds: ' + tempChildIds);
				if(tempChildIds != null && !tempChildIds.isEmpty()){
					tempParentIds = new Set<Id>();
					tempParentIds.addall(tempChildIds);
				}else{
					break;
				}
			}
			
			if(!modifiedTasks.isEmpty()){
				update modifiedTasks.values();
			}
	}catch(Exception expObj){
			result = expObj.getmessage();
			System.debug('From Catch ' + expObj);
        	System.debug('Cause: ' + expObj.getCause());
        	System.debug('LineNumber: ' + expObj.getLineNumber());
			Database.rollback(savePoint1);
		}
		return result;
	}
	
	public static Boolean isTaskEligbleForBlocked(Task__c taskObj){
		Boolean result = false;
		System.debug('taskObj.status__c: ' + taskObj.status__c);
		if(taskObj.status__c != wfUtil.INACTIVE 
			&& taskObj.status__c != wfUtil.ON_HOLD && taskObj.status__c != wfUtil.BLOCKED){
			result = true;		
		}
		return result;
	}
	
	//@future
	public static void updateSuccessorTasks(set<Id> parentIds){
		String requiredStr = wfUtil.REQUIRED;
		String closedStr = wfUtil.CLOSED;
		String optionalStr = wfUtil.OPTIONAL;
		Savepoint savePoint1; 
		try{
			savePoint1 = Database.setSavepoint();
			for(Id parentId : parentIds){
				Map<Id, Task__C> modifiedTasks = new Map<Id, Task__C>();
				Set<Id> projectIds = new Set<Id>();
				for(Task__c taskObj : [Select Id,SLA_In_Hours__c, Reopen__C, category__c, status__c, start_date__c, end_date__c, Expected_Close_Date__c, Phase__r.Project__c,
										(Select Id, task__c, parent_task__r.Id, parent_task__r.category__c from Task_Dependencys__r 
											where task__c != null and parent_task__r.category__c =:requiredStr and parent_task__r.status__c != :closedStr)
										from Task__c where Id = :parentId ]){
					if(taskObj.Phase__r.Project__c != null){
						projectIds.add(taskObj.Phase__r.Project__c);
					}
					if(taskObj.category__c == requiredStr){
						if(taskObj.Task_Dependencys__r != null && !taskObj.Task_Dependencys__r.isEmpty() 
							&& isTaskEligbleForBlocked(taskObj)){
								taskObj.status__c = wfUtil.BLOCKED; 
								taskObj.Blocked_start_date__c = Datetime.now() ;
								taskObj.Blocked_Reason__c = 'Created Adhoc Task' ;
								modifiedTasks.put(taskObj.Id, taskObj);
						}else if(taskObj.Task_Dependencys__r == null || taskObj.Task_Dependencys__r.isEmpty()){
                           
							taskObj.status__c = wfUtil.OPEN; 
							taskObj.Blocked_end_date__c = (taskObj.Blocked_start_date__c != null) ? Datetime.now() : null;
							taskObj.end_date__c = null;
							if(taskObj.SLA_In_Hours__c > 0 && taskObj.Expected_Close_Date__c == null){
								Datetime slaDateTime = getSLATime(Datetime.now(), Integer.valueOf(taskObj.SLA_In_Hours__c));
								taskObj.Expected_Close_Date__c = slaDateTime;
							}
							modifiedTasks.put(taskObj.Id, taskObj);							
						}
					}
								
				}
	
				Map<Id, Task__C> tasksMap = new Map<Id, Task__C>();
				Map<Id, Set<Id>> taskIds = new Map<Id, Set<Id>>();
				for(Task__c taskObj : [Select Id, status__c, start_date__c, Expected_Close_Date__c, Phase__r.Project__c,
										Blocked_start_date__c, Blocked_Reason__c, category__c,
										//(Select Id, task__c, parent_task__r.Id, parent_task__r.category__c from Task_Dependencys__r 
											//where task__c != null and parent_task__r.category__c =:requiredStr and parent_task__r.status__c != :closedStr), 
										(Select Id, task__c, parent_task__r.Id, parent_task__r.category__c from Task_Dependencies1__r 
											where task__c != null and parent_task__r.category__c =:requiredStr) 
										from Task__c where Phase__r.Project__c in :projectIds]){
		
					Set<Id> childTaskIds = taskIds.containsKey(taskObj.Id) ? taskIds.get(taskObj.Id) : new Set<Id>();
					if(taskObj.Task_Dependencies1__r != null){
						for(Task_Dependency__c tskDependency : taskObj.Task_Dependencies1__r){
							childTaskIds.add(tskDependency.task__c);
						}
					}
					taskIds.put(taskObj.Id, childTaskIds);
					tasksMap.put(taskObj.Id, taskObj);
				}
						
				Boolean condition = true;
				Set<Id> tempChildIds = new Set<Id>();
				Set<Id> tempParentIds = new Set<Id>();
				tempParentIds.add(parentId);
				while(condition){
					for(Id taskParentId : tempParentIds){
						tempChildIds = new Set<Id>();
						for(Id childTaskId : taskIds.get(taskParentId)){
							Task__c tempTaskObj = tasksMap.get(childTaskId);
							Task__c tempParentTskObj = tasksMap.get(taskParentId);
							if(tempParentTskObj.category__c == requiredStr){
								tempTaskObj.category__c = wfUtil.REQUIRED;
								if(tempParentTskObj.status__c != wfUtil.CLOSED && 
									(isTaskEligbleForBlocked(tempTaskObj))){
									tempTaskObj.status__c = wfUtil.BLOCKED; 
									tempTaskObj.Blocked_start_date__c = Datetime.now() ;
									tempTaskObj.Blocked_Reason__c = 'Created Adhoc Task' ;
									tempChildIds.add(tempTaskObj.Id);
									modifiedTasks.put(tempTaskObj.Id, tempTaskObj);
								}
								modifiedTasks.put(tempTaskObj.Id, tempTaskObj);	
							}
						}
					}
					System.debug('tempChildIds: ' + tempChildIds);
					if(tempChildIds != null && !tempChildIds.isEmpty()){
						tempParentIds = new Set<Id>();
						tempParentIds.addall(tempChildIds);
					}else{
						break;
					}
				}
				
				if(!modifiedTasks.isEmpty()){
					update modifiedTasks.values();
				}
			}
			
		}catch(Exception expObj){
			System.debug('From Catch ' + expObj);
        	System.debug('Cause: ' + expObj.getCause());
        	System.debug('LineNumber: ' + expObj.getLineNumber());
			Database.rollback(savePoint1);
		}
	}

	/*
	** This method is not in use ....
	**
	*/
	/*
	public static void reopenTasks(Set<Id> parentTaskIds){
		if(parentTaskIds == null || parentTaskIds.isEmpty())
			return;
		WorkflowManagement wfObj = new WorkflowManagement();
		wfObj.reopenTasksImpl(parentTaskIds);
	}	
	
	public void reopenTasksImpl(Set<Id> parentTaskIds){	
		Savepoint savePoint1; 
		String requiredStr = wfUtil.REQUIRED;
		try{
			savePoint1 = Database.setSavepoint();
			Map<Id, Task__C> modifiedTasks = new Map<Id, Task__C>();
			Set<Id> projectIds = new Set<Id>();
			for(Task__c taskObj : [Select Id,SLA_In_Hours__c, Reopen__C, status__c, start_date__c, end_date__c, Expected_Close_Date__c, Phase__r.Project__c 
									from Task__c where Id in :parentTaskIds]){
				if(taskObj.Phase__r.Project__c != null){
					projectIds.add(taskObj.Phase__r.Project__c);
				}
				taskObj.status__c = wfUtil.OPEN;
				taskObj.Reopen__C = true ;
				taskObj.end_date__c = null;
				if(taskObj.SLA_In_Hours__c > 0){
					setSLAEndTimeImpl(taskObj);
				}
				modifiedTasks.put(taskObj.Id, taskObj);				
			}
			
			Map<Id, Task__C> tasksMap = new Map<Id, Task__C>();
			Map<Id, Set<Id>> taskIds = new Map<Id, Set<Id>>();
			for(Task__c taskObj : [Select Id, status__c, start_date__c, Expected_Close_Date__c, Phase__r.Project__c,
									Blocked_start_date__c, Blocked_Reason__c,
									(Select Id, task__c, parent_task__r.Id, parent_task__r.category__c from Task_Dependencies1__r 
										where task__c != null and parent_task__r.category__c =:requiredStr) 
									from Task__c where Phase__r.Project__c in :projectIds]){
	
				Set<Id> childTaskIds = taskIds.containsKey(taskObj.Id) ? taskIds.get(taskObj.Id) : new Set<Id>();
				if(taskObj.Task_Dependencies1__r != null){
					for(Task_Dependency__c tskDependency : taskObj.Task_Dependencies1__r){
						childTaskIds.add(tskDependency.task__c);
					}
				}
				taskIds.put(taskObj.Id, childTaskIds);
				tasksMap.put(taskObj.Id, taskObj);
			}
	
			Boolean condition = true;
			Set<Id> tempChildIds = new Set<Id>();
			Set<Id> tempParentIds = new Set<Id>();
			tempParentIds.addall(parentTaskIds);
			while(condition){
				for(Id taskParentId : tempParentIds){
					tempChildIds = new Set<Id>();
					for(Id childTaskId : taskIds.get(taskParentId)){
						Task__c tempTaskObj = tasksMap.get(childTaskId);
						if(isTaskEligbleForBlocked(tempTaskObj)){
							tempTaskObj.status__c = wfUtil.BLOCKED; 
							tempTaskObj.Blocked_start_date__c = Datetime.now() ;
							tempTaskObj.Blocked_Reason__c = 'Re-Opened predecessor tasks' ;
							tempChildIds.add(tempTaskObj.Id);
							modifiedTasks.put(tempTaskObj.Id, tempTaskObj);
						}
					}
				}
				System.debug('tempChildIds: ' + tempChildIds);
				if(tempChildIds != null && !tempChildIds.isEmpty()){
					tempParentIds = new Set<Id>();
					tempParentIds.addall(tempChildIds);
				}else{
					break;
				}
			}
			
			if(!modifiedTasks.isEmpty()){
				update modifiedTasks.values();
			}
		}catch(Exception expObj){
			System.debug('From Catch ' + expObj);
        	System.debug('Cause: ' + expObj.getCause());
        	System.debug('LineNumber: ' + expObj.getLineNumber());
			Database.rollback(savePoint1);
		}
	}
	*/
	
	public static void processsUpdateRules(Task__c parentTaskObj, Map<String, sObject> objectMap){
		string completedStr = wfUtil.COMPLETE;
		Map<String, List<Workflow_Update_Rule__c>> updateRuleMap = new Map<String, List<Workflow_Update_Rule__c>>();
		for(Workflow_Update_Rule__c ruleObj : [Select Id, name, Action__c, 	Dependent_Task_Template_Name__c, 
													Field_Name1__c, Field_Value1__c, Object_Name1__c,	
													Field_Name2__c, Field_Value2__c, Object_Name2__c,	
													Field_Name3__c, Field_Value3__c, Object_Name3__c,	
													Field_Name4__c, Field_Value4__c, Object_Name4__c,	
													Field_Name5__c, Field_Value5__c, Object_Name5__c,	
													Task_Field_Name1__c, Task_Field_Value1__c,
													Task_Field_Name2__c, Task_Field_Value2__c,
													Task_Field_Name3__c, Task_Field_Value3__c,
													Task_Field_Name4__c, Task_Field_Value4__c,
													Task_Field_Name5__c, Task_Field_Value5__c,
													Is_Required__c, 
													Parent_Task_Template_Name__c from  Workflow_Update_Rule__c where Parent_Task_Template_Name__c =:parentTaskObj.name]){
			
			List<Workflow_Update_Rule__c> updateRules = updateRuleMap.containsKey(ruleObj.Dependent_Task_Template_Name__c) ?  updateRuleMap.get(ruleObj.Dependent_Task_Template_Name__c) : new List<Workflow_Update_Rule__c>();
			updateRules.add(ruleObj);
			updateRuleMap.put(ruleObj.Dependent_Task_Template_Name__c, updateRules);
		}
		System.debug('Rulemap : ' + updateRuleMap.keySet());
		
		if(!updateRuleMap.isEmpty()){
			Map<String, Task__c> dependentTaskMap = new Map<String, Task__c>();
			for(Task__c taskObj : [Select Id,name, Category__c, status__c from Task__c where name in:updateRuleMap.keySet() and Project_Name__c =:parentTaskObj.Project_Name__c 
										and status__c != :completedStr]){
				dependentTaskMap.put(taskObj.name, taskObj);
			}
			System.debug('dependentTaskMap : ' + dependentTaskMap.keySet());
			
			//Map<Id, Task__c> modifiedTasks = new Map<Id, Task__c>();
			Map<String, String> modifiedTasksActionMap = new Map<String, String>();
			Map<Id, Task__c> modifiedTaskMap = new Map<Id, Task__c>();
			for(String taskName : updateRuleMap.keySet()){
				List<Workflow_Update_Rule__c> updateRules = updateRuleMap.get(taskName);
				Task__C tempTask = dependentTaskMap.get(taskName);
				if(tempTask != null && updateRules != null && !updateRules.isEmpty()){
					Set<String> result = new Set<String>();
					String actionStr = '';
					for(Workflow_Update_Rule__c ruleObj : updateRules){
						System.debug('tempTask.category__c: ' + tempTask.category__c);
						System.debug('ruleObj.Parent_Task_Template_Name__c: ' + ruleObj.Parent_Task_Template_Name__c);
						System.debug('parentTaskObj.name: ' + parentTaskObj.name);
						//ruleObj.action__c != tempTask.category__c &&
						if( ruleObj.Parent_Task_Template_Name__c == parentTaskObj.name){
							System.debug('ruleObj: ' + ruleObj);
							Set<String> tempResult = new Set<String>();
							for(Integer i=1; i<=5; i++){
								String objectNameStr = String.valueOf(ruleObj.get('Object_Name' + i + '__c'));
								String fieldNameStr = String.valueOf(ruleObj.get('Field_Name' + i + '__c'));
								
								String expectedValue = '';
								String actualValue = '';							
								if(!String.isEmpty(objectNameStr) && !String.isEmpty(fieldNameStr)){
									expectedValue = String.valueOf(ruleObj.get('Field_Value' + i + '__c'));
									SObject tempSObject = objectMap.get(objectNameStr);
									actualValue = String.valueOf(tempSObject.get(fieldNameStr));
								}

								if(!String.isEmpty(expectedValue) && !String.isEmpty(actualValue)){
									expectedValue = expectedValue.trim().toLowerCase();
									actualValue = actualValue.trim().toLowerCase();
									if(expectedValue == actualValue){
										tempResult.add('true');
									}else{
										tempResult.add('false');
									}
								}
								
							} //for(Integer i=1; i<=5; i++)

							if(!tempResult.isEmpty() && !tempResult.contains('false') && tempResult.contains('true')){
								result.add('true');
								for(Integer jj=1; jj<=5; jj++){
									String tskFieldName = String.valueOf(ruleObj.get('Task_Field_Name' + jj + '__c'));
									String tskFieldValue = String.valueOf(ruleObj.get('Task_Field_Value' + jj + '__c'));		
									System.debug('tskFieldName ' + tskFieldName);
									System.debug('tskFieldValue ' + tskFieldValue);			
									if(!String.isEmpty(tskFieldName) && !String.isEmpty(tskFieldValue)){
										if(tskFieldName == 'Category__c'){
											modifiedTasksActionMap.put(tempTask.Id, tskFieldValue);		
										}else{
											tempTask.put(tskFieldName, tskFieldValue);
											modifiedTaskMap.put(tempTask.Id, tempTask);
										}
									}
									
								} //for(Integer i=1; i<=5; i++)								
								//actionStr = wfCreationRuleObj.action__c;
							}else if(ruleObj.Is_Required__c != true){
								result.add('optional');
							}else{
								result.add('false');
							}							
						}

						System.debug('actionStr: ' + actionStr);
					}
				}
			}
			System.debug('modifiedTaskMap.KeySet() ' + modifiedTaskMap.keySet());
			if(!modifiedTaskMap.isEmpty()){
				update modifiedTaskMap.values();
			}
			
			if(!modifiedTasksActionMap.isEmpty()){
				System.debug('modifiedTasksActionMap: ' + modifiedTasksActionMap);
				updateTaskCategory(modifiedTasksActionMap);
			}
		}
	}
	
}