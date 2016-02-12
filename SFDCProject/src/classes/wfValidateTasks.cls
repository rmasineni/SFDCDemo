public class wfValidateTasks {
	public static String CANCELLED = 'Cancelled';
	public static String COMPLETE = 'Complete';
	public static String REQUIRED = 'Required';
	public static String OPTIONAL = 'Optional';
	
	//public static Map<Id, Map<Id, Set<String>>> validationReport = new  Map<Id, Map<Id, Set<String>>>();
	public static void validateProjects(List<String> projectIds, Map<Id, Map<Id, Set<String>>> validationReport){
		string requiredStr = REQUIRED;
		string completedStr = COMPLETE;
        Set<String> scCancelledStages = new Set<String>();
		scCancelledStages.add('Deal Cancelled');
        scCancelledStages.add('Deal Cancelled due to credit');
				
		for(Project__c projectObj : [Select Id, name, status__c, Service_Contract__r.name, Service_Contract__r.status__C
						 from Project__C where Id in :projectIds]){

			String errorMessage = '\r\n Status review for Project: ' + projectObj.name ;
			Map<Id, Set<String>> tempMap = validationReport.containsKey(projectObj.Id) ? validationReport.get(projectObj.Id) : new  Map<Id, Set<String>>();
			Set<String> errorMessages = tempMap.containsKey(projectObj.Id) ? tempMap.get(projectObj.Id) : new Set<String>();
			errorMessages.add(errorMessage);
			if((scCancelledStages.contains(projectObj.Service_Contract__r.status__C) && projectObj.status__c != CANCELLED) 
			|| (!scCancelledStages.contains(projectObj.Service_Contract__r.status__C) && projectObj.status__c == CANCELLED)){
				
				errorMessage = '\r\n Project: ' + projectObj.name + ' \r\n Service Contract: ' + projectObj.Service_Contract__r.name ;
				errorMessage += ' \r\n Project and Service Contract Status values are not matching. ';
				errorMessages.add(errorMessage);
			}
			tempMap.put(projectObj.Id, errorMessages);
			validationReport.put(projectObj.Id, tempMap);
		}


		for(Phase__c phaseObj : [Select Id, name, phase_status__c, project__r.name, (Select Id, name, category__c, status__c from Tasks__r) 
									from Phase__C where project__c in :projectIds order by project__c]){
			
			Set<String> taskStatuses = new Set<String>();
			for(Task__c taskObj : phaseObj.Tasks__r){
				String tempStatus = '';
				if(taskObj.category__c == requiredStr && (taskObj.status__C == 'Open' || taskObj.status__C == 'Blocked' || taskObj.status__C == 'On-Hold')){
					tempStatus = 'Open';
				}else if(taskObj.category__c == requiredStr && taskObj.status__C == COMPLETE){
					tempStatus = COMPLETE;
				}else if(taskObj.category__c == requiredStr && taskObj.status__C == 'Inactive'){
					tempStatus = 'Inactive';
				}else if(taskObj.category__c == 'Optional'){
					tempStatus = 'Open';
				}
				taskStatuses.add(tempStatus);
			}
			String errorMessage = '';
			errorMessage = '\r\n Project: ' + phaseObj.project__r.name + ' \r\n Phase: ' + phaseObj.name ;
			errorMessage += ' \r\n Review the phase status. ';
			String errorMessage1 = '';
			if((phaseObj.phase_status__c == null || phaseObj.phase_status__c == '') && !taskStatuses.isEmpty()){
				errorMessage1 += ' \r\n Actual Phase Status: <<Empty OR Null>>' ;
			}else if(phaseObj.phase_status__c == COMPLETE && (taskStatuses.contains('Inactive') || taskStatuses.contains('Open') )){
				errorMessage1 += ' \r\n Actual Phase Status: ' + phaseObj.phase_status__c + '; One OR more tasks are in Inactive OR Open status.' ;
			}else if(phaseObj.phase_status__c == 'Open' && (!taskStatuses.contains('Open'))){
				errorMessage1 += ' \r\n Actual Phase Status: ' + phaseObj.phase_status__c + '; Found no Open tasks.' ;
			}
			if(errorMessage1 != ''){
				errorMessage += errorMessage1;
				Map<Id, Set<String>> tempMap = validationReport.containsKey(phaseObj.project__c) ? validationReport.get(phaseObj.project__c) : new  Map<Id, Set<String>>();
				Set<String> errorMessages = tempMap.containsKey(phaseObj.Id) ? tempMap.get(phaseObj.Id) : new Set<String>();
				errorMessages.add(errorMessage);
				tempMap.put(phaseObj.Id, errorMessages);
				validationReport.put(phaseObj.project__c, tempMap);
			}		

		}

		
		for(Task__c taskObj : [Select Id, name, status__c, category__c, phase__r.project__c, phase__r.name,  phase__r.Id, phase__r.phase_status__c,phase__r.project__r.name,
								(Select Id, parent_task__r.status__c, parent_task__r.name, Name, Child_Task__c, Parent_Task__c, parent_task__r.category__c, Task__c 
									From Task_Dependencys__r  where parent_task__r.status__c != :completedStr and parent_task__r.category__c =:requiredStr)
						 		from Task__c where phase__R.Project__c in :projectIds order by phase__R.Project__c]){
			
			if(taskObj.status__c == completedStr && taskObj.Task_Dependencys__r != null && !taskObj.Task_Dependencys__r.isEmpty()){
				
				String errorMessage = '\r\n Project: ' + taskObj.phase__r.project__r.name + ' \r\n Task: ' + taskObj.name ;
				errorMessage += ' \r\n Review the task status. Following predecessor tasks are not complete. ';
				for(Task_Dependency__c tdObj : taskObj.Task_Dependencys__r){
					errorMessage += ' \r\n Parent Task: ' + tdObj.parent_task__r.name + ' ; Status: ' + tdObj.parent_task__r.status__c;
				}
				Map<Id, Set<String>> tempMap = validationReport.containsKey(taskObj.phase__r.project__c) ? validationReport.get(taskObj.phase__r.project__c) : new  Map<Id, Set<String>>();
				Set<String> errorMessages = tempMap.containsKey(taskObj.Id) ? tempMap.get(taskObj.Id) : new Set<String>();
				errorMessages.add(errorMessage);
				tempMap.put(taskObj.Id, errorMessages);
				validationReport.put(taskObj.phase__r.project__c, tempMap);				
			}
		}		

		System.debug('******** validationReport: '  +validationReport);
		for(Id projectId : validationReport.keySet()){
			Map<Id, Set<String>> validations = validationReport.get(projectId);
			for(Id objectId : validations.keySet()){
				Set<String> errorMessages = validations.get(objectId);
				for(String errorMessage : errorMessages){
					System.debug('?????? ' + errorMessage);
				}
			}
		}
	
	}

	public static void emailValidationReport(Map<Id, Map<Id, Set<String>>> validationReport){
		Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
		String emailString = Label.WFM_Email;
		List<String> emails = emailString.split(';');
		//String[] toAddresses = new String[] {Label.WFM_Email};
        mail.setToAddresses(emails);
        mail.setSubject('Workflow Project Validation Report');
        String emailBody = 'Please review the Workflow Project Status Report: ';
		for(Id projectId : validationReport.keySet()){
			Map<Id, Set<String>> validations = validationReport.get(projectId);
			for(Id objectId : validations.keySet()){
				Set<String> errorMessages = validations.get(objectId);
				for(String errorMessage : errorMessages){
					emailBody += '\r\n ' + errorMessage;
				}
				emailBody += '\r\n';
			}
			emailBody += '\r\n' + '***************************************************************************************************************';
			emailBody += '\r\n' + '***************************************************************************************************************';
		}
		        
        mail.setPlainTextBody(emailBody);
        try{
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }
        catch(exception e){
        system.debug(e);
        }
	}
	
	public static void validateAndEmailProjectTasks(LiST<String> projectIds){
		Map<Id, Map<Id, Set<String>>> validationReport = new  Map<Id, Map<Id, Set<String>>>();
		validateProjects(projectIds, validationReport);
		emailValidationReport(validationReport);
	}

}