public class SchedulerServiceImpl extends BaseScheduling implements SchedulerService  {

	public static String PHONE_CONSULTATION = 'Phone Call';
  	public static String FIELD_CONSULTATION = 'Home Visit';
  	public static String SITE_AUDIT = 'Site Audit';
  	public static String SERVICE = 'Service';
	public static String MODULE_NAME = 'Scheduling Tool';
	public static String CONTACT_SUPPORT = ' Please contact Sunrun Support';

  	public string customerTimeZone = '';
  	public string saTimezone = '';
  	public Integer minSlotSize = 60;
	public Integer apptInterval;
  	public Integer buffertime = 30;
  	public Integer buffertime2 = 30;
  	public String debugLog1 {get;set;}
  	public String debugLog2 {get;set;}
	public Map<String,Map<Date,List<Event>>> existingAppointments;
	public Map<Id, Opportunity> optysForExistingAppts;
	public Map<Id, Account> accountForExistingAppts;
	public Map<Id, String> accountLatlongMap;
	public Map<String, Integer> driveTimeMap;
	public Map<String, Integer> drivetimesExceedingBuffer;
	public String defaultStartLocation{get;set;}
	public Boolean debugValue {get;set;}
	public String purchasedThrough{get;set;}
	public Opportunity inputOptyObj;
	public Account instBranchAcct{get;set;}

	public Map<Id, String> repsLatlongMap;
	public Map<Id, Event> repsPreviousEvent;

	public String optyPrefix = '';
	public String acctPrefix = '';
	public String fsDispatchPrefix = '';
	Public Integer prevApptDuration = -4;
	public SchedulerServiceImpl(){
		debugValue = true;
		debugLog1 = '';
		debugLog2 = '';
		defaultStartLocation = '';
		purchasedThrough = '';
		optyPrefix = Schema.SObjectType.Opportunity.getKeyPrefix();
		acctPrefix = Schema.SObjectType.Account.getKeyPrefix();
		fsDispatchPrefix = Schema.SObjectType.FS_Dispatch__c.getKeyPrefix(); 
		prevApptDuration = String.isEmpty(Label.Scheduling_PrevApptDuration) ? -4 : Integer.valueOf(Label.Scheduling_PrevApptDuration) * -1;
	} 
  	
  	/**
  	** Return the customer information and timezone
  	**/
    public SchedulerServiceDto.ContactInfo getContactInfo(String sobjId) {
		sobjId = getAccountId(sobjId);
		SchedulerServiceDto.ContactInfo contactInfo = new SchedulerServiceDto.ContactInfo();
        Contact contactObj = getPrimaryContactForAccount(sobjId);
        contactInfo.contact = contactObj;
        contactInfo.account = contactObj.account;
		contactInfo.timezoneId = getCustomerTimeZone(contactObj.account);
        System.debug('contactInfo: ' + contactInfo);
		return contactInfo;
    }
    
    public Contact getPrimaryContactForAccount(String sobjId){
		Contact resultContact;
		Map<Id, Contact> contactMap = new Map<Id, Contact>([Select Id,  firstname, lastname, name, email, phone, Account.Id, Account.HasDaylightSavings__c, 
															Account.BillingPostalCode, Account.BillingStreet, Account.BillingState, Account.BillingCountry, 
															Account.BillingCity, Account.TimeZone__c from Contact where accountId =:sobjId]);
		for(OpportunityContactRole roleObj : [Select Id, contactId, isPrimary from OpportunityContactRole where contactId in :contactMap.keySet()]){
			if(resultContact == null || roleObj.isPrimary == true){
				resultContact = contactMap.get(roleObj.contactId);
				if(roleObj.isPrimary == true)
					break;
			}
		}
		if(contactMap != NULL && !contactMap.isEmpty()){
			resultContact = contactMap.values()[0];
		}
		return resultContact;
    }
	
	public void appendToDebugLog(String debugInfo){
		if(debugValue){
			debugLog1 += debugInfo + '\r\n' ;
		}
	}
    
    /*
    ** Create the Appointment record and update the reps calendar
    ** 
    ** First primary reps and then secondary reps are considred for assignment.
    ** Step -1: Sort the reps by skill level
    ** Step -2.1:  Assign the first reps for phone appointment. No distance calculations are required.  
    ** Step -2.2: In case of home and site audit appointments, calculate the driving time. If the driving time is less than the 
    ** threshold time then assign the rep. 
    ** Step -3: If the rep's driving time is more than the threshold time then sort them by driving time and by skill then assign the reps 
    ** with less driving time and more skill level. 
    ** Repeat the steps 1-3 for the secondary reps if sufficent primary reps are not available to fullfill the appointment. 
    **
    */
    public Appointment__c createAppointment(String sobjectId, String appointmentType, String[] primaryRepIds, 
    											String[] secondaryRepIds,  DateTime startTime, DateTime endTime, 
    											String eventDescription) {		
		
		String actionName = 'Create Appointment';
		appendToDebugLog('**** CreateAppointment API input parameters *****');
		appendToDebugLog('SObject Id: ' + sobjectId + ' Appointment type: ' + appointmentType + ' Start time: ' + startTime + ' End time: ' +  endTime);
		Id inputAcctId = getAccountId(sobjectId);
		String opportunityName = '';
		BusinessException businessExp;
		Appointment__c tempAppointment = new Appointment__c();
		String errorMessage2 = 'Unable to complete '+ actionName + ' API for ';
		try{
			Map<Integer, Set<String>> rempIdMap = new Map<Integer, Set<String>>();
			Set<String> repIds = new Set<String>();
			if(primaryRepIds != null && !primaryRepIds.isEmpty()){
				repIds.addall(primaryRepIds);
				rempIdMap.put(1, repIds);
				appendToDebugLog(' Primary Reps: ' + primaryRepIds);
			}
			if(secondaryRepIds != null && !secondaryRepIds.isEmpty()){
				repIds.addall(secondaryRepIds);
				
				Set<String> tempRempIds = new Set<String>();
				tempRempIds.addall(secondaryRepIds);
				rempIdMap.put(2, tempRempIds);
				appendToDebugLog(' Secondary Reps: ' + secondaryRepIds);
			}
			
			appendToDebugLog('\r\n');
			appendToDebugLog('>>>>>> Retrieving details 1 <<<<<<<<<<');
			
			appointmentType = getNewAppointmentType(appointmentType);
			Appointment_Type__c apptType = 	getAppointmentType(appointmentType);
			Integer minRepCount = (Integer)apptType.Number_of_reps_for_appt__c;
			String contactPhone = '';
			
			appendToDebugLog('AppointmentType ' + appointmentType + ' Appointment record: ' + apptType);
			
			Account accountObj = getAccount(inputAcctId);
			instBranchAcct = getInstallBranch(accountObj.BillingPostalCode);
			opportunityName = accountObj.name;
			String categoryStr = getCategory(appointmentType);
			appendToDebugLog('appointmentType: ' + appointmentType + ' categoryStr ' + categoryStr);
			Appointment_Territory__c territoryObj = getTerritory(accountObj.BillingPostalCode, categoryStr);
			if(Test.isRunningTest()){
				territoryObj = getTerritoryById(accountObj.Appointment_Territory__c);	
			}
			Integer thresholdValue = (Integer)territoryObj.Threshold__c;
			thresholdValue = thresholdValue * 60;
			String localTimezoneId = getCustomerTimeZone(accountObj);
			customerTimeZone = localTimezoneId;
			saTimezone = getLoginUserTimezone();
						
			Integer buffertime = (Integer)territoryObj.Buffer__c;
			if(apptType.appointment_type__c.contains(PHONE_CONSULTATION)){
				buffertime = 0;
			}else if(apptType.appointment_type__c.contains(SITE_AUDIT) || apptType.appointment_type__c.contains(SERVICE) ){
				buffertime = 30;
			}
			buffertime = buffertime * 60; 
			
			appendToDebugLog('\r\n');
			appendToDebugLog(' Name:' + accountObj.name + ', Account Id:' + accountObj.Id  + '\r\n');
			appendToDebugLog('Appointment territory record: ' + territoryObj);
			
			String customerLocation = accountObj.Latitude__c + ',' + accountObj.Longitude__c;
			if(!hasValidLatLong(accountObj)){
				businessExp = new BusinessException('Latitude and Longitide values are not calculated for the customer location.' + CONTACT_SUPPORT);
				Sf.appLogger.log('Exception', MODULE_NAME, actionName , errorMessage2 + opportunityName, debugLog1, sobjectId, businessExp);
				throw businessExp;
			}
			if(instBranchAcct == null || instBranchAcct.Latitude__c == null ||instBranchAcct.Latitude__c == null){
				businessExp = new BusinessException('Latitude and Longitide values are not calculated for the Install branch.' + CONTACT_SUPPORT);
				Sf.appLogger.log('Exception', MODULE_NAME, actionName , errorMessage2 + opportunityName, debugLog1, sobjectId, businessExp);
				throw businessExp;
			}
			defaultStartLocation = instBranchAcct.Latitude__c + ',' + instBranchAcct.Longitude__c;
			appendToDebugLog('Customer location: ' + customerLocation);
			appendToDebugLog('Reps default starting location: ' + defaultStartLocation);			
					
			String email = '';
			String homeOwnerFullName = '';
			String address = getBillingAddress(accountObj);
			String state = '';
			Contact contactObj = getPrimaryContactForAccount(inputAcctId);
			if(contactObj != null){
				contactPhone = contactObj.phone;
				homeOwnerFullName = contactObj.name;
				email = contactObj.email;
				state = contactObj.Account.BillingState;
			}
			
			tempAppointment.Appointment_Type__c = appointmentType;
			tempAppointment.Account__c = inputAcctId;
			if(inputAcctId != sObjectId){
				if(sobjectId.startsWith(fsDispatchPrefix)){
					tempAppointment.FS_Dispatch__c = sObjectId;
				}else if(sobjectId.startsWith(optyPrefix)){
					tempAppointment.Opportunity__c = sObjectId;
				}
			}
			
			Datetime userLocalTime = getUserDisplaytimeWithAdjustedTimezone(startTime);
			tempAppointment.Appointment_Time_Local__c = startTime.format('MM/dd/yyyy hh:mm a', localTimezoneId);
			tempAppointment.Appointment_Date_time__c = startTime;
	        tempAppointment.Appointment_End_Date_Time__c = endTime;
			tempAppointment.Name__c ='APPT: '+ homeOwnerFullName +' '+'/'+' '+ state +' '+'/'+' '+ContactPhone;
			tempAppointment.Appointment_Description__c = (String.isEmpty(eventDescription)) ? '' : eventDescription ;
			eventDescription +=  '' + '\r\n';
	        tempAppointment.Appointment_Description__c += homeOwnerFullName +'\r\n' + address +'\r\n' + ContactPhone+'\r\n'+ email+'\r\n'+System.URL.getSalesforceBaseUrl().toExternalForm() +'/'+sobjectId;  
			
			appendToDebugLog(' Appointment Time Local: ' + tempAppointment.Appointment_Time_Local__c + ' localTimezoneId ' + localTimezoneId + ' Appointment_Date_time__c ' + tempAppointment.Appointment_Date_time__c);
			
			Boolean insertAppointment = false;
			List<String> errorMessages = new List<String>();
			Integer retryCount = 1;
			Set<String> rejectedIds = new Set<String>();
			String unavailableSlotError = 'Unable to create an appointment for ' + opportunityName + '.' + CONTACT_SUPPORT;
			Integer counter = 0;
			do{
				counter++;
				List<Id> assignedRepIds = new List<Id>();
				Integer repCount = 1;
				repIds.removeall(rejectedIds);	
				if(repIds.size() < minRepCount){
					appendToDebugLog(' Minimum number of reps are not available to complete this appointment.');
					break;
				}
				if(counter > 100){
					appendToDebugLog(' Exceeded the maximum number of retries');
					break;
				}
				
				setLatLongForReps(repIds, startTime, endTime);
				
				String salesRepId = '';
				for(Integer key = 1; key <=2; key++){
					Set<String> tempRepIds1 = rempIdMap.get(key);
					if(tempRepIds1 == null)
						continue;
	
					if(repCount > minRepCount)
						break;	
					
					appendToDebugLog('\r\n');
					appendToDebugLog('*****' + ' Reps assignment calculation (1- Primary, 2 - Secondary) ' + key + '*******');
					
					String areaOfExpert = getAreaOfExpert();
					String skillType = getSkillType(appointmentType);
					appendToDebugLog('Skill type: ' + skillType + ' Area of expert: ' + areaOfExpert);

					Map<Id, Contact_Skill__c> repsBySkills = getContactsBySkill(tempRepIds1, '', '');
					if(repsBySkills == null || repsBySkills.isEmpty()){
						businessExp =  new BusinessException('Sales reps are not available with the required skills to complete this appointment. ' + CONTACT_SUPPORT);
						Sf.appLogger.log('Exception', MODULE_NAME, actionName , errorMessage2 + opportunityName, debugLog1, sobjectId, businessExp);
						throw businessExp;
					}
					Map<Integer, Map<Id, Contact_Skill__c>> repsSkillMap = sortContactsBySkill(repsBySkills.values());
					Map<Integer, Map<Integer, Set<Id>>> drivingTimeSkillMap  = new Map<Integer, Map<Integer, Set<Id>>>();
					
					List<Integer> sortedSkills = new List<Integer>();
					sortedSkills.addall(repsSkillMap.keySet());
					sortedSkills.sort();
	
					for(Integer i = sortedSkills.size()-1; i >=0; i--){
						Integer skillLevel = sortedSkills.get(i);
						appendToDebugLog(' Processing the sorted skills. Skill Level: ' + skillLevel);
						 Map<Id, Contact_Skill__c> tempRepsSkills = repsSkillMap.get(skillLevel);
						Set<Id> tempRepIds = tempRepsSkills.keySet();
						for(Id repId : tempRepIds){
							
							if(rejectedIds.contains(repId))
								continue;
								
							Contact_Skill__c contactSkillObj = tempRepsSkills.get(repId);
							if(repCount > minRepCount)
								break;	
							
							String fieldName = 'Event_Assigned_To_Contact' + repCount + '__c';
							if(appointmentType.contains(PHONE_CONSULTATION)){
								tempAppointment.put(fieldName, repId);
								assignedRepIds.add(repId);
								repCount++;
								appendToDebugLog(' Assigning Reps for the phone appointment. Rep Id: ' +  repId + ' Name: ' + contactSkillObj.Contact__r.Name);
							}else{
								Integer drivingTime = getDrivingTime(customerLocation, defaultStartLocation, repsLatlongMap.get(repId));
								Boolean validDriveTime = checkForValidDriveTime(drivingTime, buffertime, defaultStartLocation, repId, startTime);
								if(drivingTime >= 0 && drivingTime <= thresholdValue){
									tempAppointment.put(fieldName, repId);
									assignedRepIds.add(repId);
									repCount++;
									appendToDebugLog(' Rep assignment for driving time less than the threshold time. Rep Id: ' + repId + ' Name: ' + contactSkillObj.Contact__r.Name + ' Driving time: ' + drivingTime + ' ThresholdValue ' + thresholdValue + ' Skill ' + skillLevel);
								}else if(drivingTime >= 0 && validDriveTime == true){
									Map<Integer, Set<Id>> skillMap = drivingTimeSkillMap.containsKey(drivingTime) ? drivingTimeSkillMap.get(drivingTime) : new Map<Integer, Set<Id>>();
									Set<Id> repsForDrivingTime = skillMap.containsKey(skillLevel) ? skillMap.get(skillLevel) : new Set<Id>();
									repsForDrivingTime.add(repId);
									skillMap.put(skillLevel, repsForDrivingTime);
									drivingTimeSkillMap.put(drivingTime, skillMap);							
									appendToDebugLog(' Rep with driving time more than the threshold time. Rep Id: ' + repId + ' Name: ' + contactSkillObj.Contact__r.Name + ' Driving time: ' + drivingTime + ' ThresholdValue ' + thresholdValue + ' Buffer time: ' + buffertime + ' Skill ' + skillLevel);
								}else if(drivingTime >= 0 && validDriveTime == false){
									rejectedIds.add(repId);
									appendToDebugLog(' Drive time for the rep ' + contactSkillObj.Contact__r.name + ' is longer than the buffer value. Driving time: ' + drivingTime + ' ThresholdValue ' + thresholdValue + ' Skill ' + skillLevel);
								}else{
									appendToDebugLog(' Invalid driving time. Driving time: ' + drivingTime + ' ThresholdValue ' + thresholdValue + ' Skill ' + skillLevel);
									rejectedIds.add(repId);
									businessExp = new BusinessException('Unable to calculate the driving time for the Rep: ' + contactSkillObj.Contact__r.Name);
									throw businessExp;
								}
							} //End of else	
						} //End of for(Id repId : tempRepIds)
					} //End of for(Integer skillLevel : sortedSkills)

					System.debug('debugLog1: ' + debugLog1);
					
					List<Integer> sortedDrivingTimes = new List<Integer>();
					sortedDrivingTimes.addall(drivingTimeSkillMap.keySet());
					sortedDrivingTimes.sort();
					
					for(Integer drivingTime : sortedDrivingTimes){
						if(repCount > minRepCount)
								break;	
						Map<Integer, Set<Id>> skillMap = drivingTimeSkillMap.get(drivingTime);
						sortedSkills = new List<Integer>();
						sortedSkills.addall(skillMap.keySet());
						sortedSkills.sort();
						
						for(Integer i = sortedSkills.size()-1; i >=0; i--){
							if(repCount > minRepCount)
								break;
								
							Integer skillLevel = sortedSkills.get(i);
							Set<Id> tempRepIds = skillMap.get(skillLevel);
	
							for(Id tempRepId : tempRepIds){
								if(repCount > minRepCount)
									break;
								
								Contact_Skill__c contactSkillObj = repsBySkills.get(tempRepId);
								String fieldName = 'Event_Assigned_To_Contact' + repCount + '__c';
								tempAppointment.put(fieldName, tempRepId);
								assignedRepIds.add(tempRepId);
								repCount++;
								appendToDebugLog('Rep assignment with drive time more than threshold value. Rep Id: ' + tempRepId + ' Name: ' + contactSkillObj.Contact__r.Name + ' Skill Level: ' + skillLevel + ' Driving Time: ' + drivingTime);
							}
						}			
					}//End of for(Integer i = sortedSkills.size()
				} //End of for(Integer key = 1; key <=2; key++)
	
				String fieldName = 'Event_Assigned_To_Contact1__c';
				Object assignedTo  = tempAppointment.get(fieldName);
				tempAppointment.put('Event_Assigned_To__c', assignedTo);
				
				Datetime esWithBuffer = startTime.addseconds(-1*buffertime);
				Datetime endWithBuffer = endTime.addseconds(1*buffertime);
				appendToDebugLog('esWithBuffer: ' + esWithBuffer + ' startTime: ' + startTime + ' buffertime: ' + buffertime + ' endWithBuffer: ' + endWithBuffer + ' endTime: ' + endTime);
				
				//Check the existing appointments only when all the reps are assigned
				if(assignedRepIds.size() == minRepCount){
					calculateExistingAppointments(esWithBuffer, endWithBuffer, assignedRepIds);
					//Create the appointment when all the reps are assigned and no other appoints are 
					//available at the same time.
					if(Test.isRunningTest()){
						existingAppointments = new Map<String, Map<Date,List<Event>>>();
					}
					
					if(existingAppointments != null && existingAppointments.isEmpty()){
						insert tempAppointment;
						appendToDebugLog('\r\n');
						appendToDebugLog(' Appointment: ' + tempAppointment);	
						appendToDebugLog(' AssignedRepIds: ' + assignedRepIds);
						appendToDebugLog(' Existing Appointments: ' + existingAppointments);
						insertAppointment = true;
						break;							
					}else{
						rejectedIds.addall(existingAppointments.keySet());
						unavailableSlotError = (!existingAppointments.isEmpty()) ? 'Selected time slot is unavailable, it is booked by other customer.' : unavailableSlotError;
						appendToDebugLog(unavailableSlotError + ' Rep Id: ' + existingAppointments.keySet());
						appendToDebugLog(' Existing Appointments: ' + existingAppointments);
						retryCount++;						
					}
				}else{
					unavailableSlotError = 'Selected time slot is unavailable, due to long drive time.';
					appendToDebugLog(unavailableSlotError);
				}

			}while(true);

			if(insertAppointment == false){
				businessExp = new BusinessException(unavailableSlotError);
				Sf.appLogger.log('Exception', MODULE_NAME, actionName , 'Unable to create an appointment for ' + opportunityName, debugLog1, sobjectId, businessExp);
				throw businessExp;					
			}
		
		} catch (BusinessException e) {
			String errorMessage = e.getMessage();
			Sf.appLogger.log('Exception', MODULE_NAME, actionName , errorMessage2 + opportunityName, debugLog1, sobjectId, e);
			throw businessExp;			
		}catch (Exception e) {
			String errorMessage = e.getMessage();
			Sf.appLogger.log('Exception', MODULE_NAME, actionName , 'Unable to create an appointment for ' + opportunityName, debugLog1, sobjectId, e);
            throw new SystemException('Exception while creating the appointment: ' + errorMessage, e);
        }
		System.debug('debugLog1 : ' + debugLog1);
		Sf.appLogger.logDebug(MODULE_NAME, actionName, 'Appointment is created successfully for ' + opportunityName, debugLog1, sobjectId);
		return tempAppointment;                                     
	}
	
	/*
	** This API reuns the available appointment slots for the reps based on the opportunity zip code. 
	**
	*/
	public List<SchedulerServiceDto.AvailableSlot> findAvailableSlots(String sobjectId, Date eventsStartDate, Date eventsEndDate, String localTimezoneId, String appointmentType, 
																		Boolean outOfTerritory, List<Id> salesRepIds, Boolean debug) {
		return 	findAvailableSlots(sobjectId, eventsStartDate, eventsEndDate, localTimezoneId, appointmentType, '', outOfTerritory, salesRepIds, debug);																
	}
	
	public List<SchedulerServiceDto.AvailableSlot> findAvailableSlots(String sobjectId, Date eventsStartDate, Date eventsEndDate, String localTimezoneId, String appointmentType, 
																		String zipCode,  Boolean outOfTerritory, List<Id> salesRepIds, Boolean debug) {
		debugValue = debug;
		//debugValue = true;
		String actionName = 'FindAvailableSlots';
		BusinessException businessExp;
		String opportunityName = '';
		String errorMessage1 = 'Unable to complete '+ actionName + ' API for ' + sobjectId;
		String errorMessage2 = 'Unable to complete '+ actionName + ' API for ';
		try{
			appendToDebugLog('**** ' + actionName + ' API input parameters *****');
			appendToDebugLog('SObject Id: ' + sobjectId + ' Appointment Type: ' + appointmentType +  'zipCode: ' + zipCode + ' outOfTerritory: ' + outOfTerritory);
			appendToDebugLog('Start time: ' + eventsStartDate + ' End Time: ' +  eventsEndDate + ' Localtime zone: ' +  localTimezoneId);
			sobjectId = getAccountId(sobjectId);
			outOfTerritory = false;
			appendToDebugLog('New outOfTerritory: ' + outOfTerritory);
		
			List<SchedulerServiceDto.AvailableSlot> emptySlots = new List<SchedulerServiceDto.AvailableSlot>();
			Map<Datetime, SchedulerServiceDto.AvailableSlot> availableSlots = new Map<Datetime, SchedulerServiceDto.AvailableSlot>();
			Map<Datetime, Integer> slotRepCount = new Map<Datetime, Integer>();
			
			//Get timezone information
			if(String.isEmpty(localTimezoneId)){
				businessExp = new BusinessException('Customer timezone is null or empty');
				Sf.appLogger.log('Exception', MODULE_NAME, actionName , errorMessage1, debugLog1, sobjectId, businessExp);
				throw businessExp;				
			}
			customerTimeZone = localTimezoneId;
			saTimezone = getLoginUserTimezone();	
			
			appendToDebugLog('\r\n >>>>>> Retrieving details <<<<<<<<<<');
			Account accountObj = getAccount(sobjectId);
			opportunityName = accountObj.name;
			if(!hasValidLatLong(accountObj)){
				businessExp = new BusinessException('Latitude and Longitide values are not calculated for the customer location.' + CONTACT_SUPPORT);
				Sf.appLogger.log('Exception', MODULE_NAME, actionName , errorMessage2 + opportunityName, debugLog1, sobjectId, businessExp);
				throw businessExp;
			}
			
			instBranchAcct = getInstallBranch(accountObj.BillingPostalCode);
			if(instBranchAcct == null || instBranchAcct.Latitude__c == null || instBranchAcct.Latitude__c == null){
				businessExp = new BusinessException('Latitude and Longitide values are not calculated for the Install branch.' + CONTACT_SUPPORT);
				Sf.appLogger.log('Exception', MODULE_NAME, actionName , errorMessage2 + opportunityName, debugLog1, sobjectId, businessExp);
				throw businessExp;
			}
			
			defaultStartLocation = instBranchAcct.Latitude__c + ',' + instBranchAcct.Longitude__c;			
			String customerLocation = accountObj.Latitude__c + ',' + accountObj.Longitude__c;
			appendToDebugLog('Name:' + accountObj.name + ', Account Id:' + accountObj.Id  + 'Purchased Through: ' + purchasedThrough + '\r\n');
			if(inputOptyObj != null && inputOptyObj.Sales_Representative__c != null && inputOptyObj.SalesRep__c != null){
				salesRepIds = new List<Id>();
				salesRepIds.add(inputOptyObj.Sales_Representative__c);
				appendToDebugLog('Opty Sales Rep ' + inputOptyObj.Sales_Representative__c);
			}

			//Territory calculations
			appointmentType = getNewAppointmentType(appointmentType);
			String categoryStr = getCategory(appointmentType);
			appendToDebugLog('categoryStr ' + categoryStr + ' appointmentType ' + appointmentType);
			Appointment_Territory__c territoryObj = getTerritory(accountObj.BillingPostalCode, categoryStr);
			if(Test.isRunningTest()){
				territoryObj = getTerritoryById(accountObj.Appointment_Territory__c);	
			}
			
			if(territoryObj == null || String.isEmpty(territoryObj.Territory__c)){
				businessExp = new BusinessException('Territory information is missing for the zip code ' + accountObj.BillingPostalCode + '.' + CONTACT_SUPPORT);
				Sf.appLogger.log('Exception', MODULE_NAME, actionName , errorMessage2 + opportunityName, debugLog1, sobjectId, businessExp);
				throw businessExp;
			}
			appendToDebugLog(' Appointment_Territory__c: ' + territoryObj + '\r\n');
			
			//Buffer vlues are dependent on the territory
			String territory = territoryObj.Territory__c;
			//buffertime = (Integer)territoryObj.Buffer__c;
			buffertime2 = (Integer)territoryObj.Buffer__c;
			buffertime = 30;
			
			//Appointment type calculations
			Appointment_Type__c apptType = 	getAppointmentType(appointmentType);	
			if(apptType == null){
				String tempApptType = (String.isEmpty(appointmentType)) ? '' : appointmentType;
				businessExp = new BusinessException(tempApptType + ' is not a valid appointment type.' + CONTACT_SUPPORT);
				Sf.appLogger.log('Exception', MODULE_NAME, actionName , errorMessage2 + opportunityName, debugLog1, sobjectId, businessExp);
				throw businessExp; 
			}
			appendToDebugLog('Appointment_Type__c ' + apptType + '\r\n');
			
			apptInterval = (Integer)apptType.Default_Duration__c;
			Integer minRepCount = (Integer)apptType.Number_of_reps_for_appt__c;
			if(apptType.appointment_type__c.contains(PHONE_CONSULTATION)){
				buffertime = 30;
				buffertime2 = 0;
			}
			appendToDebugLog('Buffertime ' + buffertime + ' Buffertime2 ' + buffertime2);
			
			Map<Id, Appointment_Region__c> salesReps = new Map<Id, Appointment_Region__c>();
			if(salesRepIds == null || salesRepIds.isEmpty() || (appointmentType.contains(SITE_AUDIT) 
				|| apptType.appointment_type__c.contains(SERVICE))){
				
				if(salesRepIds == null || salesRepIds.isEmpty()){
					appendToDebugLog(' This Opportunity is not associated with a Sales Rep');
				}
				appendToDebugLog(' Retrieving sales rep details for the appointment type ' + appointmentType);
				
				salesRepIds = new List<Id>();
				outOfTerritory = true;
				salesReps = getRepsAppointmentRegion(territory, outOfTerritory);
				if(salesReps == null || salesReps.isEmpty()){
					businessExp =  new BusinessException('No sales reps are assigned to the territory ' + territoryObj.Territory__c + '.' + CONTACT_SUPPORT);
					Sf.appLogger.log('Exception', MODULE_NAME, actionName , errorMessage2 + opportunityName, debugLog1, sobjectId, businessExp);
					throw businessExp;
				}else{
					salesRepIds.addall(salesReps.keySet());
					appendToDebugLog(' Sales Rep Ids By Appointment Region ' + salesRepIds);
				}
				Map<String, Appointment_Group__c> apptGroupMembers = getContactsByApptGroup(salesRepIds, apptType.Group__c);
				appendToDebugLog(' Appointment Groups for Reps ' + apptGroupMembers);
				if(apptGroupMembers == null || apptGroupMembers.isEmpty()){
					businessExp =  new BusinessException('Sales reps are not assigned to the appointment group ' + apptType.Group__c + '. ' + CONTACT_SUPPORT);
					Sf.appLogger.log('Exception', MODULE_NAME, actionName , errorMessage2 + opportunityName, debugLog1, sobjectId, businessExp);
					throw businessExp;
				}
				
				String areaOfExpert = getAreaOfExpert();
				String skillType = getSkillType(appointmentType);
				Map<Id, Contact_Skill__c> repsBySkills = getContactsBySkill(apptGroupMembers.keySet(), skillType, areaOfExpert);
				if(repsBySkills == null || repsBySkills.isEmpty()){
					businessExp =  new BusinessException('Sales reps are not available with the required skills to complete this appointment. ' + CONTACT_SUPPORT);
					Sf.appLogger.log('Exception', MODULE_NAME, actionName , errorMessage2 + opportunityName, debugLog1, sobjectId, businessExp);
					throw businessExp;
				}
				
				salesRepIds.clear();	
				salesRepIds.addall(repsBySkills.keySet());
				appendToDebugLog(' Reps Ids By Skills ' + salesRepIds + '\r\n');				
			
			}else{
				salesReps = getRepsAppointmentRegion(salesRepIds, territory);
				appendToDebugLog(' Using Opty Sales Rep Details. Sales Reps By Appointment Region for Phone call ' + salesReps + '\r\n');
				salesRepIds.clear();	
				salesRepIds.addall(salesReps.keySet());
				if(salesRepIds == null || salesRepIds.isEmpty()){
					businessExp =  new BusinessException('No sales reps are assigned to the territory ' + territoryObj.Territory__c + '.' + CONTACT_SUPPORT);
					Sf.appLogger.log('Exception', MODULE_NAME, actionName , errorMessage2 + opportunityName, debugLog1, sobjectId, businessExp);
					throw businessExp;
				}
			}
			
		
			
			//Datetime calculations
			
			Datetime currentTime = Datetime.now();
			Datetime eventsStartTime = dateTime.newInstance(eventsStartDate,time.newInstance(6,0,0,0)); 
			//Datetime eventsEndTime = dateTime.newInstance(eventsStartDate.adddays(1),time.newInstance(23,0,0,0)); 
			Datetime eventsEndTime = dateTime.newInstance(eventsEndDate,time.newInstance(23,0,0,0)); 
			if(eventsStartDate != null && eventsStartDate < date.today()){
				eventsStartDate = date.today();
			}	

			Datetime gmtStartDateTime = getDatetimeWithAdjustedTimezone(eventsStartTime); 
			Datetime gmtEndDateTime = getDatetimeWithAdjustedTimezone(eventsEndTime); 
	
			Date startDate = gmtStartDateTime.Date();
			Date endDate = gmtEndDateTime.Date();
			
			appendToDebugLog(' gmtStartDateTime ' + gmtStartDateTime + ' gmtEndDateTime ' + gmtEndDateTime  + ' startDate ' + startDate  + ' endDate ' + endDate );
	
			//Get existing events information
			Datetime gmtStartDateTimeWithBuffer = gmtStartDateTime.addminutes(-1*buffertime);
			Datetime gmtEndDateTimeWithBuffer = gmtEndDateTime.addminutes(1*buffertime);
			calculateExistingAppointments(gmtStartDateTimeWithBuffer, gmtEndDateTimeWithBuffer, salesRepIds);
			getDrivetimesForExistingAppointments(appointmentType, customerLocation);
			appendToDebugLog(' Existing Appointments ' + existingAppointments);

			//Calculate the available slots
			availableSlots = calculateAvailableSlots(territoryObj.territory__C, salesRepIds, salesReps, gmtStartDateTime, gmtEndDateTime, appointmentType);
			List<SchedulerServiceDto.AvailableSlot> resultSlots =  getEligibleSlots(availableSlots, minRepCount);
			
			Sf.appLogger.logDebug(MODULE_NAME, actionName, 'Successfully returning the available appoins for ' + accountObj.name , debugLog1, sobjectId);
			System.debug('debugLog1 : ' + debugLog1);
			return resultSlots;
		} catch (BusinessException e) {
			String errorMessage = e.getMessage();
			Sf.appLogger.log('Exception', MODULE_NAME, actionName , errorMessage2 + opportunityName, debugLog1, sobjectId, e);
			throw businessExp;
		} catch (System.DmlException e) {
			String errorMessage = e.getMessage();
			businessExp = new BusinessException(errorMessage.trim());
			Sf.appLogger.log('Exception', MODULE_NAME, actionName , errorMessage2 + opportunityName, debugLog1, sobjectId, e);
			throw businessExp;
		}catch (Exception e) {
			String errorMessage = e.getMessage();
			appendToDebugLog(' Error Log: ' + errorMessage);
			Sf.appLogger.log('Exception', MODULE_NAME, actionName , errorMessage2 + opportunityName, debugLog1, sobjectId, e);
            throw new SystemException('Exception while calculating the available slots ' + e.getMessage(), e);
        }
    	return null;
    }
	
	/*
	** Calulate the available slots for eligible reps.
	**
	*/
	public Map<Datetime, SchedulerServiceDto.AvailableSlot> calculateAvailableSlots(String territory, List<Id> salesRepIds, Map<Id, Appointment_Region__c> salesReps,
																						Datetime gmtStartDateTime, Datetime gmtEndDateTime, String appointmentType){

		Map<Datetime, SchedulerServiceDto.AvailableSlot> availableSlots = new Map<Datetime, SchedulerServiceDto.AvailableSlot>();
		Map<Datetime, Integer> slotRepCountMap = new Map<Datetime, Integer>();
		Date startDate = gmtStartDateTime.Date();
		Date endDate = gmtEndDateTime.Date();
		Integer numberOfDays = startDate.daysBetween(endDate);
		Integer maxPhoneRepCount = Sf.settingsService.getInteger('PhoneAppointmentMaxRepCount', 5);
		Boolean isPhoneAppointment = (appointmentType.contains(PHONE_CONSULTATION)) ? true : false;
		
		Datetime todaysTime = getStartTime(appointmentType, startDate);
		for(Id contactId : salesRepIds){
			Map<Date,List<Event>> repEventMap = existingAppointments.containsKey(contactId) ? existingAppointments.get(contactId) : new Map<Date,List<Event>>();
			for(Integer dayCount = 0; dayCount <= numberOfDays; dayCount++){
				Date newStartDate = startDate.addDays(dayCount);
					
				List<Event> eventsList = repEventMap.containsKey(newStartDate) ? repEventMap.get(newStartDate) : new List<Event>();
				calculateBlockedSlots(eventsList, appointmentType);

				Integer starthour = 6;
				Integer startminutes = 0;
				Integer endHour = (23 - starthour);
				Datetime startTime = getStartTimeslotGMT(newStartDate,starthour, startminutes);
				Datetime endTime = startTime.addhours(endHour);
				if(dayCount == 0 && todaysTime > startTime){
					startTime = todaysTime;
				}
				
				if(dayCount == numberOfDays){
					endTime = (endTime >= gmtEndDateTime) ? gmtEndDateTime : endTime;
				}

				Datetime beginSlotStartTime = startTime;
				Datetime slotEndTime1 = beginSlotStartTime.addminutes(apptInterval);
				Datetime endSlotStartTime = endTime.addminutes(-1*apptInterval);	
				Boolean createSlot = false;
				
				if(dayCount == 0 && ((beginSlotStartTime > endTime))){  //|| (slotEndTime1 > endSlotStartTime)
					continue;
				}
				
				do{
					String tempStr = beginSlotStartTime.format() + slotEndTime1.format();
					Integer repCount = slotRepCountMap.containsKey(beginSlotStartTime) ? slotRepCountMap.get(beginSlotStartTime) : 0;
					if(!isPhoneAppointment || (isPhoneAppointment && repCount <= maxPhoneRepCount)){
						if(isSlotAvailable(eventsList, beginSlotStartTime, slotEndTime1, appointmentType)){
						     createSlot(territory, availableSlots, salesReps, beginSlotStartTime, slotEndTime1, contactId, appointmentType);
						     repCount ++;
						     slotRepCountMap.put(beginSlotStartTime, repCount);
						}
					}
					//else{  //Commented the following lined due to a production defect
						
						//Datetime tempBeginTime2 = beginSlotStartTime.addminutes(-60); 
						//Datetime beginSlotStartTime2 = tempBeginTime2.addminutes(buffertime); 
						//Datetime slotEndTime2 = beginSlotStartTime2.addminutes(apptInterval);
						//do{
						//	String tempStr2 = beginSlotStartTime2.format() + slotEndTime2.format();
						//	if(isSlotAvailable(eventsList, beginSlotStartTime2, slotEndTime2, appointmentType)){
								//Following line has been commented before the defect
								//createSlot(availableSlots, salesReps, beginSlotStartTime2, slotEndTime2, contactId, appointmentType);
						//	}
						//	beginSlotStartTime2 = beginSlotStartTime2.addminutes(buffertime); //buffertime
				    	//	slotEndTime2 = beginSlotStartTime2.addminutes(apptInterval);	
						//}while(beginSlotStartTime2 < slotEndTime1 && slotEndTime2 <= endTime);
					//}
					beginSlotStartTime = beginSlotStartTime.addminutes(buffertime); //buffertime
					slotEndTime1 = beginSlotStartTime.addminutes(apptInterval);
				    createSlot = false;					
				}while(beginSlotStartTime <= endSlotStartTime);

			}
		}
		return availableSlots;
	}				


	/*
	** Check the available slots with minimum rep count to handle the appointment
	** Appointments like Site Audit and Installations require more than one rep.
	*/
	public List<SchedulerServiceDto.AvailableSlot> getEligibleSlots(Map<Datetime, SchedulerServiceDto.AvailableSlot> availableSlots, Integer minRepCount){
    	List<SchedulerServiceDto.AvailableSlot> eligibleSlots = new List<SchedulerServiceDto.AvailableSlot>();
    	appendToDebugLog('\r\n');
    	for(SchedulerServiceDto.AvailableSlot availableSlotObj : availableSlots.values()){
    		if(availableSlotObj.repCount >= minRepCount){
				appendToDebugLog('StartTime ' + availableSlotObj.startTime + ' EndTime ' + availableSlotObj.endTime + ' PrimaryIds ' + availableSlotObj.primaryRepIds + ' SecondaryIds ' + availableSlotObj.secondaryRepIds + ' Rep Count ' + availableSlotObj.repCount);	
    			eligibleSlots.add(availableSlotObj);
    		}
    	}
    	if(eligibleSlots.isEmpty()){
    		System.debug('Not found the minimum number of sales reps');
    	}
    	return eligibleSlots;
    }
	
	/*
	** Get latitude and logitude information for the reps
	** Install branch location on the opportunity is the default starting location 
	** if the reps deos't have a prior appointment
	**
	** If the reps have a prior appointment then the prior appointment location is the starting point
	**
	*/
	public void setLatLongForReps(Set<String> repIds,  DateTime startTime, DateTime endTime){
		repsLatlongMap = new Map<Id, String>();
		repsPreviousEvent = new Map<Id, Event>();
		Datetime tempStartTime = startTime.addhours(prevApptDuration);
		Map<Id, Id> repOptyMap = new Map<Id, Id>();
		Map<Id, String> accountLatlongMap = new Map<Id, String>();
		for(Event eventObj : [Select id, whatId, Related_To_Id__c, Latitude__c, Longitude__c, Subject,StartDateTime,EndDateTime,who.name,who.id,IsAllDayEvent,ActivityDate, Opportunity__c FROM Event WHERE 
														who.id IN:repIds and EndDateTime >= :tempStartTime and EndDateTime < :startTime order by EndDateTime desc]){
			
			String tempWhatIdStr = '';
			Id tempWhatId = getWhatId(eventObj);
			if(tempWhatId != null){
				tempWhatIdStr = '' + tempWhatId ;
			}
			if((tempWhatIdStr.startswith(optyPrefix) || tempWhatIdStr.startswith(acctPrefix))  && (!String.isEmpty(eventObj.Related_To_Id__c))){
				String latLongStr = eventObj.Latitude__c + ','+ eventObj.Longitude__c;
				accountLatlongMap.put(tempWhatId, latLongStr);			
			}
			if(tempWhatIdStr.startswith(optyPrefix) || tempWhatIdStr.startswith(acctPrefix) && !repOptyMap.containskey(eventObj.whoId)){
				repsPreviousEvent.put(eventObj.whoId, eventObj);
				repOptyMap.put(eventObj.whoId, tempWhatId);
				appendToDebugLog(' Latest Prior Appointments: ' + eventObj.Id + ' Start time: ' + eventObj.StartDateTime + ' End Time: ' + eventObj.EndDateTime + ' who Id: ' + eventObj.whoId + ' what Id: ' + tempWhatId);
			}
			appendToDebugLog(' Prior Appointments: ' + eventObj.Id + ' Start time: ' + eventObj.StartDateTime + ' End Time: ' + eventObj.EndDateTime);
		}		
		
		if(!repOptyMap.isEmpty()){
			for(Account acctObj : getAccounts(repOptyMap.values()).values()){
				String latLongStr = acctObj.Latitude__c + ','+ acctObj.Longitude__c;
				appendToDebugLog(' Account: ' + acctObj.Id  + ' Prior Appointment Latlong: ' + latLongStr);
				if(hasValidLatLong(acctObj)){
					accountLatlongMap.put(acctObj.Id, latLongStr);
				}
			}
		}
		for(Id repId : repOptyMap.keySet()){
			Id whatId = repOptyMap.get(repId);
			String latLongStr = accountLatlongMap.get(whatId);
			if(!String.isEmpty(latLongStr)){
				repsLatlongMap.put(repId, latLongStr);
			}
			appendToDebugLog(' Prior Appointments for : ' + repId  + ' Prior Appointment Latlong: ' + latLongStr);
		}
		//return repsLatlongMap;
	}
	
	/*
	** Calculate driving time
	**
	*/
	public static Map<String, AddressServiceDto.DrivingDetails> drivetimesMap = new Map<String, AddressServiceDto.DrivingDetails>();
	public Integer getDrivingTime(String customerLocation, String defaultStartLocation, String previousEventLocation){
		String startLocation = (String.isEmpty(previousEventLocation)) ? defaultStartLocation : previousEventLocation;
		AddressServiceDto.DrivingDetails drivingDetails = new AddressServiceDto.DrivingDetails();
		List<AddressServiceDto.DrivingDetails> drivingList = new List<AddressServiceDto.DrivingDetails>();
		List<String> destinations = new List<String>();

		String tempLocation = startLocation + customerLocation;
		if(drivetimesMap.containskey(tempLocation)){
			drivingDetails = drivetimesMap.get(tempLocation);
		}else{
			//drivingDetails.origin = startLocation;
			//drivingDetails.destination = customerLocation;
			destinations.add(startLocation);
			if(!Test.isRunningTest()){
				//drivingDetails = Sf.addressService.calculateDrivingDetails(drivingDetails);
				drivingList = Sf.addressService.calculateDrivingDetails(customerLocation, destinations);
				if(!drivingList.isEmpty()){
					drivingDetails = drivingList[0];
				}
			}else{
				drivingDetails.drivingTime = 1200;
			}
			drivetimesMap.put(tempLocation, drivingDetails);	
		}
		appendToDebugLog('Driving Details ' + drivingDetails);
		return drivingDetails.drivingTime;
	}
	
	public Boolean checkForValidDriveTime(Integer drivingTime, Integer buffertime, String defaultStartLocation, Id repId, Datetime startTime){
		Boolean result = true;
		String previousEventLocation = repsLatlongMap.get(repId);
		appendToDebugLog(' DrivingTime ' +  drivingTime + ' Buffertime ' + buffertime + ' DefaultStartLocation ' + defaultStartLocation + 'Previous Location ' + previousEventLocation);
		if(drivingTime > buffertime && (!String.isEmpty(previousEventLocation))){
			Event eventObj = repsPreviousEvent.get(repId);
			if(eventObj != null){
				Decimal seconds = (startTime.gettime() - eventObj.EndDateTime.gettime())/1000;
				appendToDebugLog(' StartTime ' +  StartTime + ' EventObj.EndDateTime ' + eventObj.EndDateTime + ' Seconds ' + seconds);
				if(seconds < drivingTime){
					result = false;
				}
			}
		}
		return result;
	}
	
	/*
	**
	**
	*/
	//public Map<Integer, Set<Id>> getDrivingTimeForReps(Set<String> repIds, Map<Id, String> repsLatlongMap, String customerLocation, String defaultStartLocation){
	//	Map<Integer, Set<Id>> drivingTimeMap = new Map<Integer, Set<Id>>();
		
	//	for(String repId : repIds){
	//		String startLocation = (repsLatlongMap.containskey(repId)) ? repsLatlongMap.get(repId) : defaultStartLocation;
			
	//		AddressServiceDto.DrivingDetails drivingDetails = new AddressServiceDto.DrivingDetails();
	//		drivingDetails.origin = startLocation;
	//		drivingDetails.destination = customerLocation;
	//		drivingDetails = Sf.addressService.calculateDrivingDetails(drivingDetails);
			
	//		if(drivingDetails.drivingTime > 0){
	//			Set<Id> repsForDrivingTime = drivingTimeMap.containsKey(drivingDetails.drivingTime) ? drivingTimeMap.get(drivingDetails.drivingTime) : new Set<Id>();
	//			repsForDrivingTime.add(repId);
	//			drivingTimeMap.put(drivingDetails.drivingTime, repsForDrivingTime);
	//		}
	//	}
	//	return drivingTimeMap;
	//} 

	public Map<String, Appointment_Group__c> getContactsByApptGroup(List<Id> repIds, String groupName){
		Map<String, Appointment_Group__c> apptGroupMembers = new Map<String, Appointment_Group__c>();
		appendToDebugLog('Retrieving Sales reps for group ' + groupName + '. Rep IdS: ' + repIds);
		for(Appointment_Group__c apptGroup : [Select Id, Contact__c, Group__c, Contact__r.Sunrun_User__r.IsActive, Contact__r.Sunrun_User__r.TimeZoneSidKey FROM Appointment_Group__c 
													WHERE Group__c =:groupName AND Contact__c IN :repIds AND Contact__r.Sunrun_User__r.IsActive = true order by lastmodifieddate desc]){
			if(!apptGroupMembers.containskey(apptGroup.Contact__c) || apptGroup.Group__c == groupName){
				apptGroupMembers.put(apptGroup.Contact__c, apptGroup);	
				appendToDebugLog('Sales Rep by group ' +  apptGroup);
			}
		}
		appendToDebugLog('End of Sales reps for group ' +  groupName + '\r\n');
		return apptGroupMembers;
	}

    public Appointment_Territory__c getTerritoryById(String territoryId){
    	Appointment_Territory__c territory;
		List<Appointment_Territory__c> territories = [Select Id, name, Territory__c, Zip_Code__c, Buffer__c, Threshold__c from Appointment_Territory__c where Id =:territoryId];    	
    	if(!territories.isEmpty()){
    		territory = territories[0];
    	}
    	System.debug('territory : ' + territory);
    	return territory;
    }

    public Appointment_Territory__c getTerritory(String zipCode, String categoryStr){
    	Appointment_Territory__c territory;
		List<Appointment_Territory__c> territories = [Select Id, Territory__c, Zip_Code__c, Buffer__c, Threshold__c from Appointment_Territory__c 
															where Zip_Code__c =:zipCode and category__c =:categoryStr];    	
    	if(!territories.isEmpty()){
    		territory = territories[0];
    	}
    	return territory;
    }
    
    public String getCategory(String appointmentType){
    	String result = 'Sales';
		if(appointmentType.contains(SITE_AUDIT)){
			result = SITE_AUDIT;
		}else if(appointmentType.contains(SERVICE)){
			result = SERVICE;
		}
    	return result;
    }
    
	public Map<Id, Appointment_Region__c> getRepsAppointmentRegion(String territory, Boolean outOfTerritory){
		Map<Id, Appointment_Region__c> salesReps = new Map<Id, Appointment_Region__c>();
		Set<String> priorityvalues = new Set<String>();
		priorityvalues.add('P');
		if(outOfTerritory == true){
			//priorityvalues.add('S');
			//priorityvalues.add('T');
		}
		for(Appointment_Region__c region : [Select Id, Branch__c, Priority__c, Region__c, Sales_Rep__c, Territory__c from Appointment_Region__c where 
												Territory__c =:territory and Priority__c in :priorityvalues and Sales_Rep__c != null order by Priority__c asc, lastmodifieddate desc]){
			
			if(!salesReps.containskey(region.Sales_Rep__c ) || (region.Territory__c == territory)){
				salesReps.put(region.Sales_Rep__c, region);
				appendToDebugLog(' Sales Reps By Appointment Region ' + region);
			}
		}
		return salesReps;		
	}

	public Map<Id, Appointment_Region__c> getRepsAppointmentRegion(List<Id> salesRepIds, String territory){
		Map<Id, Appointment_Region__c> salesReps = new Map<Id, Appointment_Region__c>();
		for(Appointment_Region__c region : [Select Id, Branch__c, Priority__c, Region__c, Sales_Rep__c, Territory__c from Appointment_Region__c where 
												Sales_Rep__c in :salesRepIds order by Priority__c asc, lastmodifieddate desc]){
			if(!salesReps.containskey(region.Sales_Rep__c) || (region.Territory__c == territory)){
				salesReps.put(region.Sales_Rep__c, region);
				appendToDebugLog(' Sales Reps By Appointment Region ' + region + ' Territory: ' + territory);
			}
		}
		return salesReps;		
	}

    public String getNewAppointmentType(String appointmentType){
    	return appointmentType;
    }
    

	public void createSlot(String territory, Map<Datetime, SchedulerServiceDto.AvailableSlot> availableSlots, Map<Id, Appointment_Region__c> salesReps, 
							Datetime beginSlotStartTime, Datetime slotEndTime1, Id contactId, String appointmentType){
		SchedulerServiceDto.AvailableSlot availableSlot = availableSlots.containskey(beginSlotStartTime) ?  availableSlots.get(beginSlotStartTime) : new SchedulerServiceDto.AvailableSlot();
		availableSlot.startTime = beginSlotStartTime;
		availableSlot.endTime = slotEndTime1;
		if(salesReps.containskey(contactId)){
			Appointment_Region__c apptRegion = salesReps.get(contactId);
			if(!appointmentType.contains(PHONE_CONSULTATION) && apptRegion != null && (apptRegion.Territory__c != territory)){ //(apptRegion.Priority__c == 'S' || apptRegion.Priority__c == 'T')){
				availableSlot.secondaryRepIds.add(contactId);
				availableSlot.repCount++;
			}else{
				availableSlot.primaryRepIds.add(contactId);
				availableSlot.repCount++;
			}
		}else{
			availableSlot.primaryRepIds.add(contactId);
			availableSlot.repCount++;
		}
		availableSlots.put(beginSlotStartTime, availableSlot);		
	}
	
	public void calculateExistingAppointments(Datetime eventsStartTime, Datetime eventsEndTime, List<Id> salesRepIds){
		 
		existingAppointments = new Map<String, Map<Date,List<Event>>>();
		accountLatlongMap = new Map<Id, String>();
		List<Id> optyIds = new List<Id>();
		List<Id> accountIds = new List<Id>();
		optysForExistingAppts = new Map<Id, Opportunity>();
		accountForExistingAppts =  new Map<Id, Account>();
		Date startDate = eventsStartTime.Date();
		Date endDate = eventsEndTime.Date();
		System.debug('eventsStartTime: ' + eventsStartTime + ' eventsEndTime ' + eventsEndTime + ' salesRepIds ' + salesRepIds);
		for(Event eventObj:[Select id,Subject,StartDateTime,EndDateTime,who.name,who.id,whatId, Related_To_Id__c, Latitude__c, Longitude__c, Opportunity__c,IsAllDayEvent,ActivityDate FROM Event WHERE 
													((StartDateTime <= :eventsStartTime AND EndDateTime > :eventsStartTime) OR 
														(StartDateTime >= :eventsStartTime AND EndDateTime <= :eventsEndTime) OR 
														(StartDateTime < :eventsEndTime AND EndDateTime >= :eventsEndTime) OR
														(ActivityDate >= :startDate AND ActivityDate <= :endDate AND IsAllDayEvent = true)) 
													AND who.id IN:salesRepIds]){

			String tempWhatIdStr = '' ;
			Id tempWhatId = getWhatId(eventObj);
			if(tempWhatId != null){
				tempWhatIdStr = '' + tempWhatId ;
			}
			if(tempWhatIdStr.startswith(optyPrefix) || tempWhatIdStr.startswith(acctPrefix)){
				optyIds.add(tempWhatId);
				accountIds.add(tempWhatId);
				if(!String.isEmpty(eventObj.Related_To_Id__c)){
					String latLongStr = eventObj.Latitude__c + ','+ eventObj.Longitude__c;
					accountLatlongMap.put(tempWhatId, latLongStr);							
				}
			}		
			appendToDebugLog(' tempWhatIdStr: ' + tempWhatIdStr);	
			appendToDebugLog(' accountIds: ' + accountIds);
			
			Map<Date,List<Event>> ChildMap = (existingAppointments.containsKey(eventObj.WhoId)) ? existingAppointments.get(eventObj.WhoId) : new Map<Date,List<Event>>();
			Date tempDate = eventObj.StartDateTime.date();
			Date tempEndDate = eventObj.EndDateTime.date();
			if(eventObj.IsAllDayEvent == true){
                tempDate = eventObj.ActivityDate;
                eventObj.StartDateTime = getStartTimeslotGMT(tempDate);
                eventObj.EndDateTime =  eventObj.StartDateTime.addhours(17);
				if((eventObj.StartDateTime >= eventsEndTime) || (eventsStartTime >= eventObj.EndDateTime)){
					continue;
                }
            }
			
			do{
				List<Event> ChildList = (ChildMap.containsKey(tempdate)) ? ChildMap.get(tempdate) : new List<Event>();  
				ChildList.add(eventObj);
				ChildMap.put(tempDate,ChildList);						                    
	            existingAppointments.put(eventObj.WhoId,ChildMap);	
	            tempDate = tempDate.adddays(1);			
			}while(tempDate <= tempEndDate);

        }
        if(!accountIds.isEmpty()){
        	appendToDebugLog(' accountIds: ' + accountIds);
			//optysForExistingAppts = getAccounts(optyIds);
			accountForExistingAppts = getAccounts(accountIds);
			for(Account accountObj : accountForExistingAppts.values()){
				String latlongStr = accountObj.Latitude__c + ',' + accountObj.Longitude__c;
				appendToDebugLog(' accountObj.Id: ' + accountObj.Id + ' latlongStr: ' + latlongStr);
				if(hasValidLatLong(accountObj)){
					accountLatlongMap.put(accountObj.Id, latlongStr);
				}
			}
        }
		//System.debug('existingAppointments: ' + existingAppointments);	
	}

	public void getDrivetimesForExistingAppointments(String appointmentType, String customerLocation){
		driveTimeMap = new Map<String, Integer>();
		drivetimesExceedingBuffer = new Map<String, Integer>();
		if((!appointmentType.contains(SITE_AUDIT) && !appointmentType.contains(SERVICE))|| accountLatlongMap.isEmpty()){
			return;
		}
		List<AddressServiceDto.DrivingDetails> drivingList = new List<AddressServiceDto.DrivingDetails>();
		List<String> destinations = new List<String>();
		for(String startLocation : accountLatlongMap.values()){
			appendToDebugLog(' startLocation: ' + startLocation + ' customerLocation: ' + customerLocation);
			//drivingList.add(new AddressServiceDto.DrivingDetails(startLocation,customerLocation));
			destinations.add(startLocation);
		}
		Integer tempBufferTime = buffertime * 60;
		if(!destinations.isEmpty()){
			if(!Test.isRunningTest()){
				//drivingList = Sf.addressService.calculateDrivingDetails(drivingList);
				drivingList = Sf.addressService.calculateDrivingDetails(customerLocation,destinations);
			}
			for(AddressServiceDto.DrivingDetails drDetails : drivingList){
				
				if(Test.isRunningTest()){
					drDetails.drivingTime = 1200;
				}
				
				appendToDebugLog(' drDetails.destination: ' + drDetails.destination + ' drDetails.origin: ' + drDetails.origin + ' drDetails.drivingTime: ' + drDetails.drivingTime);
				if(drDetails.drivingTime >= 0){
					driveTimeMap.put(drDetails.destination, drDetails.drivingTime);
					appendToDebugLog(' drDetails.destination: ' + drDetails.destination + '1.drDetails.origin: ' + drDetails.origin + ' drDetails.drivingTime: ' + drDetails.drivingTime + ' tempBufferTime ' + tempBufferTime );
					if(drDetails.drivingTime > tempBufferTime){
						drivetimesExceedingBuffer.put(drDetails.destination, drDetails.drivingTime);
						appendToDebugLog(' drDetails.destination: ' + drDetails.destination + '2.drDetails.origin: ' + drDetails.origin + ' drDetails.drivingTime: ' + drDetails.drivingTime + ' tempBufferTime ' + tempBufferTime );
					}
				}
			}
		}
	}

	public Datetime getStartTime(String appointmentType, Date startDate){
		
		Datetime tempTime = Datetime.now();
		Datetime currentTime = dateTime.newInstance(tempTime.date(),time.newInstance(tempTime.hour(),tempTime.minute(),0,0));  //Make sure the seconds and milli seconds part is zero
		Integer hour = currentTime.hour();
		if(!appointmentType.contains(PHONE_CONSULTATION)){
			currentTime = currentTime.addminutes(buffertime);
		}
		Integer minutes = currentTime.minute();
		
		if(minutes > 0 && minutes > 30){
			currentTime = currentTime.addminutes(60 - minutes);
		}else if(minutes > 0){
			currentTime = currentTime.addminutes(30 - minutes);
		}	
		Datetime tempCurrentTime = getStartTimeslotGMT(currentTime.date(), currentTime.hour(), currentTime.minute(), 0);
		return currentTime;
	}

    public Datetime getStartTimeslotGMT(Date dateVal, Integer startHour, Integer startMinutes, Integer r){
		DateTime FirstSlot;
		
		FirstSlot = dateTime.newInstance(dateVal,time.newInstance(startHour,(r*minSlotSize)+ startMinutes,0,0)); 
		FirstSlot = getDatetimeWithAdjustedTimezone(FirstSlot);
		return FirstSlot;
    }
	
	public Datetime getStartTimeslotGMT(Date dateVal){
		return getStartTimeslotGMT(dateVal, 6, 0, 0);
    }

	public Datetime getStartTimeslotGMT(Date dateVal, Integer startHour, Integer startMinutes){
		return getStartTimeslotGMT(dateVal, startHour, startMinutes, 0);
    }
	
	public Datetime getUserDisplaytimeWithAdjustedTimezone(Datetime datetimeVal){
		Integer ctz = getTimezoneOffSet(datetimeVal, customerTimeZone);
		Integer satz = getTimezoneOffSet(datetimeVal, saTimezone);
		Integer zoneDiff = (ctz - satz);
		Datetime tempDatetimeVal = datetimeVal.addhours(zoneDiff);
		return tempDatetimeVal;
	}
	
	public Datetime getDatetimeWithAdjustedTimezone(Datetime datetimeVal){
		Integer ctz = getTimezoneOffSet(datetimeVal, customerTimeZone);
		Integer satz = getTimezoneOffSet(datetimeVal, saTimezone);
		Integer zoneDiff = (satz - ctz);
		//appendToDebugLog(' zoneDiff: ' + zoneDiff + ' satz: ' + satz + ' ctz: ' + ctz);
		Datetime tempDatetimeVal = datetimeVal.addhours(zoneDiff);
		return tempDatetimeVal;
	}

	public Boolean isSlotAvailable(List<Event> eventsList, Datetime ss, Datetime se, String appointmentType){
		Boolean result = true;
		for(Event eventObj :eventsList){
			Datetime es = eventObj.StartDateTime;
			Datetime ee = eventObj.EndDateTime;		
			if(	((ee <= ss) || (es > se)) 
				|| (((ee <= ss) || (es >= se)) && (buffertime2 > 0 
				|| (!appointmentType.contains(SITE_AUDIT) && !appointmentType.contains(SERVICE)) ) )){
				//System.debug('Continue ...');
				//printdates('Continue - 1', ss, se, es, ee);
			}else if((buffertime2 <= 0 && (es > ss && es < se)) || 
				( (buffertime2 > 0 || (appointmentType.contains(SITE_AUDIT) || appointmentType.contains(SERVICE))) && (es > ss && es <= se))) {
				//System.debug('Condition - 1');
				//printdates('Condition - 1', ss, se, es, ee);
				result = false;
				break;
			}else if(ee > ss && ee <= se){
				//System.debug('Condition - 2 ');
				//printdates('Condition - 2' + ' Event Id: ' + eventObj.Id , ss, se, es, ee);
				result = false;
				break;
			}else if((buffertime2 <= 0 && (es <= ss && es <= se && ee > ss && ee >= se)) 
				|| ((buffertime2 > 0 || (appointmentType.contains(SITE_AUDIT) || appointmentType.contains(SERVICE))) && (es <= ss && es < se && ee > ss && ee >= se))) {			
				//System.debug('Condition - 3');
				//printdates('Condition - 3' + ' Event Id: ' + eventObj.Id , ss, se, es, ee);
				result = false;
				break;
			}else if(es >= ss && es <= se && ee > ss && ee <= se){
				//System.debug('Condition - 4');
				//printdates('Condition - 4' + ' Event Id: ' + eventObj.Id , ss, se, es, ee);
				result = false;
				break;
			}
			
			Id tempWhatId = getWhatId(eventObj);
			if(result == true){
				appendToDebugLog(' WhatId: ' + tempWhatId + ' EventId: ' + eventObj.Id + ' appointmentType: ' + appointmentType);
			}
			if(tempWhatId != null && (appointmentType.contains(SITE_AUDIT) || appointmentType.contains(SERVICE)) && result == true){
				String tempWhatIdStr = '';
				if(tempWhatId != null){
					tempWhatIdStr = '' + tempWhatId;
					if(tempWhatIdStr.startswith(optyPrefix) || tempWhatIdStr.startswith(acctPrefix)){
						Id optyId = tempWhatId;
						if(accountLatlongMap != null && accountLatlongMap.containskey(optyId)){
							String latLongStr = accountLatlongMap.get(optyId);
							if(!String.isEmpty(latLongStr) && drivetimesExceedingBuffer.containskey(latLongStr)){
								Integer driveTime = drivetimesExceedingBuffer.get(latLongStr);
								Datetime tempEE = ee.addminutes(-1*buffertime);
								Datetime tempES = es.addminutes(1*buffertime);
								//Datetime tempEE = ee.addminutes(-1*buffertime2);
								Decimal seconds1 = (ss.gettime() - tempEE.gettime())/1000;
								Decimal seconds2 = (tempES.gettime() - se.gettime())/1000;
								Integer tempSeconds1 = seconds1.intValue();
								Integer tempSeconds2 = seconds2.intValue();
								if((tempSeconds1 >= 0 && tempSeconds1 < driveTime) 
									|| (tempSeconds2 >= 0 && tempSeconds2 < driveTime)){
									result = false;
									break;											
								}
								appendToDebugLog(' latLongStr: ' + latLongStr + ' drivetimesExceedingBuffer: ' + drivetimesExceedingBuffer);
								appendToDebugLog(' es: ' + es + ' tempEE: ' + tempEE  + ' ss: ' + ss  + ' se: ' + se);
								appendToDebugLog('result: ' + result + ' tempSeconds1: ' + tempSeconds1 + ' driveTime: ' + driveTime  + ' tempSeconds2: ' + tempSeconds2 );
							}
						}	
					}
				}
			}

		}
		return result;
	}
	public void printdates(String condition, Datetime ss, Datetime se, Datetime es, Datetime ee){
		//String tempStr = 'printdates: ';
		//tempStr += 'condition ***' + condition;
		//tempStr += 'ss - ' + ss;
		//tempStr += 'se - ' + se;
		//tempStr += 'es - ' + es;
		//tempStr += 'ee - ' + ee;
		//appendToDebugLog(tempStr);
	}
	
	public static Set<Id> modifiedEvents = new Set<Id>();
	public void calculateBlockedSlots(List<Event> eventsList, String appointmentType){
		
		//Set<String> bookedSlots = new Set<String>();
		for(Event eventObj :eventsList){
			
			if(!modifiedEvents.contains(eventObj.Id)){
				modifiedEvents.add(eventObj.Id);
			}else{
				continue;
			}
			Datetime tempEventStartTime = eventObj.StartDateTime;
			Datetime tempEventEndTime = eventObj.EndDateTime;
			
			//System.debug('tempEventStartTime: ' + tempEventStartTime);
			//System.debug('tempEventEndTime: ' + tempEventEndTime);
			//appendToDebugLog('Before Change: ' + eventObj.Id + ' Start Date:' + eventObj.StartDateTime + ' End Date:'+eventObj.EndDateTime);
			if(!appointmentType.contains(SITE_AUDIT) && !appointmentType.contains(SERVICE)){
				tempEventStartTime = tempEventStartTime.addminutes(-1 * buffertime2);
				tempEventEndTime = tempEventEndTime.addminutes(buffertime2);
			}else{
				tempEventStartTime = tempEventStartTime.addminutes(-1 * buffertime);
				tempEventEndTime = tempEventEndTime.addminutes(buffertime);
			}
			
			if(buffertime2  > 0){
				Integer gmtStartMinutes = tempEventStartTime.minuteGMT();
				Integer gmtEndMinutes = tempEventEndTime.minuteGMT();
						
				if(gmtStartMinutes < 30){           //if(gmtStartMinutes < buffertime2){
					tempEventStartTime = tempEventStartTime.addminutes(-1*gmtStartMinutes);
				}else if(gmtStartMinutes > 30){  //}else if(gmtStartMinutes > buffertime2){
					tempEventStartTime = tempEventStartTime.addminutes(-1*(gmtStartMinutes - 30));
				}
				
				if(gmtEndMinutes > 0 && gmtEndMinutes < 30){  //if(gmtEndMinutes > 0 && gmtEndMinutes < buffertime2){
				  tempEventEndTime = tempEventEndTime.addminutes(buffertime2 - 30);
				}else if(gmtEndMinutes > 30){  //}else if(gmtEndMinutes > buffertime2){
				  tempEventEndTime = tempEventEndTime.addminutes((60 -gmtEndMinutes));
				}
			}
			
			eventObj.StartDateTime = tempEventStartTime;
			eventObj.EndDateTime = tempEventEndTime;
		}
	}
	
	public Appointment_Type__c getAppointmentType(String appointmentType){
		Appointment_Type__c apptObj;
		for(Appointment_Type__c tempObj : [Select Id, Appointment_Type__c, Default_Duration__c, Buffer__c, Group__c, Number_of_reps_for_appt__c from Appointment_Type__c 
												where Appointment_Type__c =:appointmentType order by lastmodifieddate desc]){
			apptObj = tempObj;
			break;
		}
		return apptObj;
	}
	
	public Account getAccount(Id accountId){
		Account resutAccount;
		List<Id> accountIds = new List<Id>();
		accountIds.add(accountId);
		Map<Id, Account> accountMap = getAccounts(accountIds);
		return accountMap.get(accountId);
	}

	public Map<Id, Account> getAccounts(List<Id> accountIds){
		Map<Id, Account> accountMap = new Map<Id, Account>();
		for(Account accountObj : [Select id, name, TimeZone__c, HasDaylightSavings__c, BillingStreet,  BillingCity, Appointment_Territory__c,  
									Latitude__c, Longitude__c, BillingState, BillingPostalCode, BillingCountry from Account where id in :accountIds]){
			accountMap.put(accountObj.Id, accountObj);
		}
		return accountMap;
	}
	
	/*
	public Map<Id, Opportunity> getOpportunities(List<Id> optyIds){
		Map<Id, Opportunity> optyMap = new Map<Id, Opportunity>();
		for(Opportunity optyObj : [Select id, Sales_Representative__c, Purchased_Thru__c,AccountId,State__c, Phone__c,Sales_Branch__c,Address__c,Name, Homeowner_Full_Name__c, 
										Homeowner_Email__c,Appointment_Type_Requested_del__c, SalesRep__c, Install_Branch_Id__R.Latitude__c, Install_Branch_Id__R.Longitude__c,
										Account.name, Account.TimeZone__c, Account.HasDaylightSavings__c, Account.BillingStreet,  Account.BillingCity, Appointment_Territory__c,  
										Account.Id, Account.Latitude__c, Account.Longitude__c, Account.BillingState, Account.BillingPostalCode, 
										(select id, ContactId, OpportunityId, Contact.Id, Contact.FirstName, Contact.LastName, Contact.Email, Contact.Phone from OpportunityContactRoles where IsPrimary = true)
									from Opportunity where id in :optyIds]){
			
			//if(optyObj.Account.Latitude__c != 0	|| 	optyObj.Account.Longitude__c != 0){
				//throw new BusinessException('Latitude and longitude information is missing for the account ' + optyObj.Account.name + ' with Id : ' + optyObj.Account.Id);
			//}		
			optyMap.put(optyObj.Id, optyObj);
		}
		return optyMap;
	}
	*/
	
	public Map<Id, Contact_Skill__c> getContactsBySkill(Set<String> repIds, String skillType, String areaOfExpert){
		Map<Id, Contact_Skill__c> contactMap = new Map<Id, Contact_Skill__c>();
		String soqlStr = ' Select Id, Contact__c, Skill_Type__c, Area_of_Expertise2__c, Skill_Level__c, Contact__r.name, Contact__r.Sunrun_User__r.IsActive, Contact__r.Sunrun_User__r.TimeZoneSidKey FROM Contact_Skill__c ';
		soqlStr += ' WHERE Contact__c IN :repIds AND Contact__r.Sunrun_User__r.IsActive = true AND Skill_Level__c!= Null  ';
		if(!String.isEmpty(skillType)){
			soqlStr += ' AND skill_type__c =:skillType ';
		}		
		if(!String.isEmpty(areaOfExpert)){
			soqlStr += ' AND (Area_of_Expertise2__c includes ' + '(\''+ areaOfExpert + '\') ) ';
		}
		soqlStr += ' ORDER BY Skill_Level__c, lastmodifieddate desc';
		
		appendToDebugLog('\r\n');
		appendToDebugLog('&&&&& Get Contacts By Skills &&&&&&&&&&&&&&');
		appendToDebugLog(' SOQL ' + soqlStr + ' RepIds: ' + repIds + ' SkillType: ' + skillType + ' AreaOfExpert: ' + areaOfExpert );	
		appendToDebugLog('Start: Reps By Skills ');	
		for(Contact_Skill__c contactSkillObj : Database.query(soqlStr)){
			contactMap.put(contactSkillObj.Contact__c, contactSkillObj);
			appendToDebugLog('Rep Details -- Id: ' + contactSkillObj.Contact__c + ' Name:' +  contactSkillObj.Contact__r.Name + ' Skill:' + contactSkillObj.skill_type__c + ' Skill level:' + contactSkillObj.Skill_Level__c + ' Area of expert: ' + contactSkillObj.Area_of_Expertise2__c);	
		}
		appendToDebugLog('End: Reps By Skills ');	
		return contactMap;
	}	

	public Map<Integer, Map<Id, Contact_Skill__c>> sortContactsBySkill(List<Contact_Skill__c> contactSkills){
		Map<Integer, Map<Id, Contact_Skill__c>> result = new Map<Integer, Map<Id, Contact_Skill__c>>();
		for(Contact_Skill__c cSkillsObj : contactSkills){
			Integer skillLevel = Integer.valueof(cSkillsObj.Skill_Level__c);
			Map<Id, Contact_Skill__c> contactMap = result.containskey(skillLevel) ? result.get(skillLevel) : new Map<Id, Contact_Skill__c>();
			contactMap.put(cSkillsObj.Contact__c, cSkillsObj);
			result.put(skillLevel, contactMap);
		}
		return result;
	}

	public string getAreaOfExpert(){
		String result = '';
		if(!String.isEmpty(purchasedThrough) && (purchasedThrough == 'Costco' || purchasedThrough == 'Comcast')){
			result = purchasedThrough;
		}
		return result;
	}

	public String getSkillType(String appointmentType){
		String result = 'Sales';
		if(appointmentType.contains(PHONE_CONSULTATION)){
			result = 'Sales';
		}else if(appointmentType.contains(FIELD_CONSULTATION)){
			result = 'Sales';
		}else if(appointmentType.contains(SITE_AUDIT)){
			result = 'Quality';
		}else if(appointmentType.contains(SERVICE)){
			result = 'Service';
		}
		return result;
	}
	

    public void cancelAppointment(Id appointmentId) {

		String actionName = 'cancelAppointment';
		appendToDebugLog('**** CancelAppointment API input parameters *****');
		appendToDebugLog('appointmentId: ' + appointmentId);
		String opportunityName = '';
		BusinessException businessExp;        
        try{
        	List<Appointment__c> appointmentMents = [Select Id, Opportunity__r.name,Status__c, Opportunity__r.Id from Appointment__c where Id =:appointmentId];
        	if(!appointmentMents.isEmpty()){
        		appointmentMents[0].Status__c = 'Appointment Cancelled';
				update appointmentMents;
        	}
		} catch (BusinessException e) {
			String errorMessage = e.getMessage();
			Sf.appLogger.log('Exception', MODULE_NAME, actionName , errorMessage, '', appointmentId, e);
			throw businessExp;			
		}catch (Exception e) {
			String errorMessage = e.getMessage();
			Sf.appLogger.log('Exception', MODULE_NAME, actionName , 'Unable to cancel the appointment ' + appointmentId, errorMessage, appointmentId, e);
            throw new SystemException('Exception while cancel the appointment: ' + errorMessage, e);
        }
    }

	
	public Id getWhatId(Event eventObj){    
    	Id tempOptyId;
    	if(eventObj.Related_To_Id__c != null){
			tempOptyId = eventObj.Related_To_Id__c ;
		}else if(eventObj.Opportunity__c != null){
			tempOptyId = eventObj.Opportunity__c ;
		}else if(eventObj.whatId != null){
			tempOptyId = eventObj.whatId ;
		} 
		return tempOptyId;
	}

	public Id getAccountId(String objectId){
		Id accountId = objectId;
		if(objectId != null && objectId.startsWith(fsDispatchPrefix)){
			FS_Dispatch__c fsdObj = [Select Id, FS_Service_Contract__r.Account.Id from FS_Dispatch__c where Id =:objectId];
			accountId = fsdObj.FS_Service_Contract__r.Account.Id;
		}else if(objectId != null && objectId.startsWith(optyPrefix)){
			inputOptyObj = [Select Id, sales_Representative__c, salesRep__c, accountId, purchased_thru__c from Opportunity where Id =:objectId];
			accountId = inputOptyObj.AccountId;
			purchasedThrough = inputOptyObj.purchased_thru__c;
		}
		return accountId;
	}
	
	public Account getInstallBranch(String postalCode){
		List<ZipUtility__c> zipUtilityList = [select Name,State__c,Sales_Branch__c,Install_Branch__c,Utility_Company__c,Territory__c,Zip_Code__c 
													from ZipUtility__c where Zip_Code__c =:postalCode];
		if(zipUtilityList != null && !zipUtilityList.isEmpty()){
			ZipUtility__c objZipUtility = zipUtilityList[0];
			Id BranchRectypeId=Schema.SObjectType.Account.RecordTypeInfosByName.get('Branch').RecordTypeId;
			List<Account> accountList = [select id,name,site,Latitude__c, longitude__c from Account where site =:objZipUtility.Install_Branch__c and RecordtypeId =:BranchRectypeId];
			if(accountList != null && !accountList.isEmpty()){
				instBranchAcct = accountList[0];
			}
		}
		return instBranchAcct;
	}
	
	public string getBillingAddress(Account accountObj){
		String addressStr = getStringValue(accountObj.BillingStreet) + ', ' + getStringValue(accountObj.BillingCity) + ', ' + getStringValue(accountObj.BillingState) + ', ' +  getStringValue(accountObj.BillingCountry) + ', ' + getStringValue(accountObj.BillingPostalCode);
		return addressStr;
	}
}