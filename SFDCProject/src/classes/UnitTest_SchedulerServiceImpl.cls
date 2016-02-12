@isTest
public with sharing class UnitTest_SchedulerServiceImpl {
	
	public static Id salesRepId;
	public static Opportunity createSchedulingData(String appointmentType, String appointmentGroup, String skillType, Integer buffer, Integer threshold){
		UnitTest_ProposalUtil.disableExternalServices();
		List<String> primaryRepIds = new List<String>();
		List<String> secondaryIds = new List<String>();
		
		//Insert install branch
		ZipUtility__c zipUtility = new ZipUtility__c(State__c='CA',Sales_Branch__c='East Bay Area',Install_Branch__c='East Bay Area',Utility_Company__c='PG&E',
														City__c='Pleasanton',Territory__c='X',Zip_Code__c='94566');
		insert zipUtility;
		
		Account parentAccount = new Account(name='Sunrun', partner_type__c='Full Service', recordTypeId='01260000000YK2jAAG', 
												timezone__c ='PST', 
												Latitude__c=37.789341300000000, longitude__c=-122.400751400000000);
		insert parentAccount; 
		
		Account installBranchAccount = new Account(RecordtypeId='01260000000YKgIAAW', ParentId=parentAccount.Id, name='East Bay Area',site='East Bay Area',Latitude__c=37.70601389999999, longitude__c=-121.9144086);
		insert installBranchAccount;
		
		Opportunity optyObj1 = TestPRMLibrary.insertOpportunity('ResidentialAccount-01', 'Residential',
                                                                'ResOpty-01', 'Platinum');  

        List<Contact> contacts = new List<Contact>();
        Id contactRecordTypeId = TestPRMLibrary.getRecordTypeId('Residential', 'Contact');
        Contact contact = new Contact();
        contact.FirstName = 'FirstName-1';
        contact.LastName = 'LastName-1';
        contact.AccountId = optyObj1.AccountId;
        contact.RecordTypeId = contactRecordTypeId;
        contact.email = 'test4@gmail.com';
        contacts.add(contact);

		Id userId = UserInfo.getUserId();
		RecordType empRecordTypeObj = PRMLibrary.getEmployeeContactRecordType();
		Contact userContact = new Contact(AccountId=parentAccount.Id,Sunrun_User__c=userId, 	Contact_Type__c='Partner',
										RecordTypeId=empRecordTypeObj.Id, Division__c = 'Inside Sales',
										LastName='LSunrun', Firstname='FSunrun', email='testemail1@partnersunrun.com',
										Ultimate_Parent_Account__c=parentAccount.Id);

        contacts.add(userContact);
        insert contacts; 
        salesRepId = userContact.Id;

		List<OpportunityContactRole> contactRolelist = new List<OpportunityContactRole>();
		OpportunityContactRole contactRoleObj = new OpportunityContactRole();
		contactRoleObj.ContactId = contact.Id;
		contactRoleObj.OpportunityId = optyObj1.Id;
		contactRoleObj.Role = 'Other';
		contactRoleObj.IsPrimary = true;
		contactRolelist.add(contactRoleObj);	  
		insert 	contactRolelist;
		
		Account acctObj = [Select name, TimeZone__c, HasDaylightSavings__c, BillingStreet,  BillingCity,  
										Id, Latitude__c, Longitude__c, BillingState, BillingPostalCode from Account where Id =:optyObj1.AccountId];
		
		String territoryName =  '94566_1';
		SchedulerServiceImpl scImplObj = new SchedulerServiceImpl();
		Boolean result = scImplObj.hasValidLatLong(acctObj);        
		Appointment_Territory__c territoryObj;
		//territoryObj = scImplObj.getTerritory(acctObj.BillingPostalCode);
		if(territoryObj == null || territoryObj.Id == null){
			territoryObj = new Appointment_Territory__c();
			territoryObj.Territory__c = territoryName;
			territoryObj.Buffer__c = buffer;
			territoryObj.Threshold__c = threshold;
			territoryObj.Zip_Code__c = '94566';
			insert territoryObj;
		}
		System.debug('Territoty Object: ' + territoryObj);
		
		Appointment_Type__c apptType;
		//apptType = 	scImplObj.getAppointmentType(appointmentType);	
		if(apptType == null){
			apptType = new Appointment_Type__c();
			apptType.Default_Duration__c =  120;
			apptType.Group__c = appointmentGroup;
			apptType.Number_of_reps_for_appt__c = 1;
			apptType.Appointment_Type__c = appointmentType;
			insert 	apptType;	
		}		
		Map<Id, Appointment_Region__c> salesRepsRegions;
		//salesRepsRegions = scImplObj.getRepsAppointmentRegion(territoryObj.Territory__c, false);
		Appointment_Region__c regionObj;
		List<Id> repIds = new List<Id>();
		Set<String> repIdsSet = new Set<String>();
		if(salesRepsRegions == null || salesRepsRegions.isEmpty()){
			salesRepsRegions = new Map<Id, Appointment_Region__c>();
			regionObj = new Appointment_Region__c();
			regionObj.Branch__c = 'East Bay';
			regionObj.Priority__c = 'P';
			regionObj.Region__c = 'Nor Cal';
			regionObj.Sales_Rep__c = salesRepId;
			regionObj.Territory__c = territoryObj.Territory__c;
			insert regionObj;
			salesRepsRegions.put(regionObj.Sales_Rep__c, regionObj);
		}else{
			regionObj = salesRepsRegions.values()[0];
		}
		repIds.add(regionObj.Sales_Rep__c);
		repIdsSet.add(regionObj.Sales_Rep__c);
		
		Map<String, Appointment_Group__c> apptGroupMembers;
		//apptGroupMembers = scImplObj.getContactsByApptGroup(repIds, apptType.Group__c);
		if(apptGroupMembers == null || apptGroupMembers.isEmpty()){
			apptGroupMembers = new Map<String, Appointment_Group__c>();
			Appointment_Group__c groupObj = new Appointment_Group__c();
			groupObj.Contact__c = regionObj.Sales_Rep__c;
			groupObj.Group__c = appointmentGroup;
			insert groupObj;
		}
		
		Map<Id, Contact_Skill__c> repsBySkills;
		//repsBySkills = scImplObj.getContactsBySkill(repIdsSet, '', '');
		Contact_Skill__c skillObj;
		if(repsBySkills == null || repsBySkills.isEmpty()){
			 skillObj = new Contact_Skill__c();
			 skillObj.Contact__c = repIds[0];
		}else{
			skillObj = repsBySkills.values()[0];
		}
		skillObj.Skill_Type__c = skillType;
		skillObj.Skill_Level__c = '5'; 
		skillObj.Area_of_Expertise2__c = 'Costco'; 
		upsert skillObj;	
		System.debug('skillObj: ' + skillObj);
		
		List<Event> eventsList = new List<Event>();
		Event eventObj1 = new Event();
		eventObj1.StartDateTime = date.today().adddays(2);
		eventObj1.EndDateTime = date.today().adddays(2);
		eventObj1.Subject = 'Test Appointment';
		eventObj1.WhoId = salesRepId;
		eventObj1.IsAllDayEvent = true;
		eventObj1.WhatId = optyObj1.Id;
		eventsList.add(eventObj1);	

		Event eventObj2 = new Event();
		eventObj2.StartDateTime = dateTime.newInstance(date.today().adddays(1),time.newInstance(10,0,0,0)); 
		eventObj2.EndDateTime = eventObj2.StartDateTime.addhours(2);
		eventObj2.Subject = 'Test Appointment';
		eventObj2.WhoId = salesRepId;
		eventObj2.IsAllDayEvent = true;
		eventObj2.WhatId = optyObj1.Id;		
		eventsList.add(eventObj2);	
		insert eventsList;
		
		Datetime eventsStartTime = Datetime.now();
		Datetime eventsEndTime = Datetime.now().adddays(1);
		List<Id> salesRepIds = new List<Id>();
		salesRepIds.add(eventObj2.WhoId);
		
		String customerLocation = acctObj.Latitude__c + ',' + acctObj.Longitude__c;
		String appointmentType2 = 'Site Audit';
		scImplObj.calculateExistingAppointments(eventsStartTime, eventsEndTime,salesRepIds);
		scImplObj.getDrivetimesForExistingAppointments(appointmentType2, customerLocation);

		scImplObj.calculateBlockedSlots(eventsList, 'Field Consultation');
		scImplObj.isSlotAvailable(eventsList, Datetime.now(),  Datetime.now().addhours(2), appointmentType2);
		scImplObj.isSlotAvailable(eventsList, eventObj2.StartDateTime,  eventObj2.EndDateTime, appointmentType2);
		scImplObj.isSlotAvailable(eventsList, eventObj2.StartDateTime.addhours(-2),  eventObj2.EndDateTime, appointmentType2);
		scImplObj.isSlotAvailable(eventsList, eventObj2.StartDateTime.addhours(-2),  eventObj2.EndDateTime.addhours(-1), appointmentType2);
		scImplObj.isSlotAvailable(eventsList, eventObj2.StartDateTime.addminutes(30),  eventObj2.EndDateTime.addminutes(-30), appointmentType2);
		
		String territory = territoryObj.Territory__c;
		scImplObj.getRepsAppointmentRegion(salesRepIds, territory);

		acctObj.TimeZone__c = 'PST';
		acctObj.HasDaylightSavings__c = 'true';
		acctObj.BillingStreet = '4107 Stanley Blvd';
		acctObj.BillingCity = 'Pleasanton';
		acctObj.BillingState = 'CA';
		acctObj.BillingCountry = 'USA';
		acctObj.BillingPostalCode = '94566';
		acctObj.Latitude__c = 37.666959700000000;
		acctObj.Longitude__c = -121.870533200000000;
		
		if(appointmentType == 'Home Visit'){
			territoryName = 'East Bay 1';
		}else{
			territoryName = '[115G]SR - East Bay Area';
		}
		
		acctObj.Appointment_Territory__c = territoryObj.Id;
		update acctObj;
		
		primaryRepIds.add(eventObj1.WhoId);
		secondaryIds.add(eventObj1.WhoId);
		try{
			//scImplObj.createAppointment(optyObj1.Id, appointmentType2, primaryRepIds, secondaryIds, eventsStartTime, eventsEndTime, 'Test Description-1');
		}catch(Exception expObj){
			
		}
		
		optyObj1.Install_Branch_Id__c = Label.Scheduling_InstallBranch;
        update optyObj1;
		try{
			//scImplObj.createAppointment(optyObj1.Id, appointmentType2, primaryRepIds, secondaryIds, eventsStartTime, eventsEndTime, 'Test Description-1');
		}catch(Exception expObj){
			
		}
		
		Event eventObj = new Event(Subject='Test-1', StartDateTime=Datetime.now().adddays(2), EndDateTime=Datetime.now().adddays(3), whoId=salesRepId,Related_To_Id__c=optyObj1.Id,
									 Latitude__c=37.666959700000000, Longitude__c=-121.870533200000000, ActivityDate=Date.today().adddays(2));
		insert eventObj;
		
		//Select id,Subject,StartDateTime,EndDateTime,who.name,who.id,whatId, Related_To_Id__c, Latitude__c, Longitude__c, Opportunity__c,IsAllDayEvent,ActivityDate FROM Event

		return optyObj1;	
	}
	

	public static testmethod void testFindAvailableSlotsForFieldSales(){

		Integer threshold = 10;
		String appointmentType = 'Field Consultation';
		String appointmentGroup = 'Inside Sales';
		String skillType = 'Sales';
		Integer buffer = 30;
		Opportunity optyObj1 = createSchedulingData(appointmentType, appointmentGroup, skillType, buffer, threshold);

		SchedulerServiceImpl scImplObj = new SchedulerServiceImpl();
        Boolean result = scImplObj.hasValidLatLong(optyObj1);
        String timeZone = scImplObj.getCustomerTimeZone(optyObj1);
		Test.startTest();	
			try{		
				SchedulerServiceDto.ContactInfo contactInfo = scImplObj.getContactInfo(optyObj1.Id);
				List<SchedulerServiceDto.AvailableSlot> availableSlots = scImplObj.findAvailableSlots(optyObj1.Id, Date.today(), Date.today().adddays(5), 'America/Los_Angeles', appointmentType, '', false, null, true);
				System.debug('AvailableSlots: ' + availableSlots);
				
				List<String> primaryRepIds = new List<String>();
				List<String> secondaryIds = new List<String>();
				Datetime datetimeNow = Datetime.now().addhours(4);
				Datetime eventsStartTime = dateTime.newInstance(date.today(),time.newInstance(10,0,0,0)); 
				Datetime eventsEndTime = dateTime.newInstance(date.today(),time.newInstance(12,0,0,0)); 
				for(SchedulerServiceDto.AvailableSlot availableSlotObj : availableSlots){
					if(availableSlotObj.primaryRepIds != null && !availableSlotObj.primaryRepIds.isEmpty()){
						for(Id repId : availableSlotObj.primaryRepIds){
							primaryRepIds.add(repId+'');
							secondaryIds.add(repId+'');
							System.debug('');
						}
						eventsStartTime = availableSlotObj.startTime;
						eventsEndTime = availableSlotObj.endTime;
						break;
					}
				}
				
				//scImplObj.createAppointment(optyObj1.Id, appointmentType, primaryRepIds, secondaryIds, eventsStartTime, eventsEndTime, 'Test Description-1');
				//availableSlots = scImplObj.findAvailableSlots(optyObj1.Id, Date.today(), Date.today().adddays(5), 'America/Los_Angeles', appointmentType, '', false, null);
			}catch(Exception expObj){
				System.debug('expObj ' + expObj);
			}
			System.debug('Start Debug for testFindAvailableSlotsForFieldSales1' + scImplObj.debugLog1);
			System.debug('Debug Log: ' + scImplObj.debugLog1);
			System.debug('End of Debug for testFindAvailableSlotsForFieldSales1');
		Test.stoptest();
	}


	public static testmethod void testFindAvailableSlotsForService(){
		Integer threshold = 10;
		String appointmentType = 'Home Visit';
		String appointmentGroup = 'Site Auditors';
		String skillType = 'Quality';
		Integer buffer = 30;
		Opportunity optyObj1 = createSchedulingData(appointmentType, appointmentGroup, skillType, buffer, threshold);
		
		SchedulerServiceImpl scImplObj = new SchedulerServiceImpl();
		Test.startTest();	
			try{		
				SchedulerServiceDto.ContactInfo contactInfo = scImplObj.getContactInfo(optyObj1.Id);
				List<SchedulerServiceDto.AvailableSlot> availableSlots = scImplObj.findAvailableSlots(optyObj1.Id, Date.today(), Date.today().adddays(5), 'America/Los_Angeles', appointmentType, '', false, null, true);
				System.debug('AvailableSlots: ' + availableSlots);
				
				List<String> primaryRepIds = new List<String>();
				Datetime datetimeNow = Datetime.now().addhours(4);
				Datetime eventsStartTime = dateTime.newInstance(datetimeNow.date(),time.newInstance(datetimeNow.hour(),0,0,0)); 
				Datetime eventsEndTime = dateTime.newInstance(datetimeNow.date(),time.newInstance(datetimeNow.hour()+2,0,0,0)); 
				for(SchedulerServiceDto.AvailableSlot availableSlotObj : availableSlots){
					if(availableSlotObj.primaryRepIds != null && !availableSlotObj.primaryRepIds.isEmpty()){
						for(Id repId : availableSlotObj.primaryRepIds){
							primaryRepIds.add(repId+'');
						}
						eventsStartTime = availableSlotObj.startTime;
						eventsEndTime = availableSlotObj.endTime;
						break;
					}
				}
				scImplObj.createAppointment(optyObj1.Id, appointmentType, primaryRepIds, null, eventsStartTime, eventsEndTime, 'Test Description-1');
				availableSlots = scImplObj.findAvailableSlots(optyObj1.Id, Date.today(), Date.today().adddays(5), 'America/Los_Angeles', appointmentType, '', false, null, true);
			}catch(Exception expObj){
				System.debug('expObj ' + expObj);
			}
			System.debug('Start Debug for testFindAvailableSlotsForService ' + scImplObj.debugLog1);
			System.debug('Debug Log: ' + scImplObj.debugLog1);
			System.debug('End of Debug for testFindAvailableSlotsForService ');
		Test.stoptest();
	}


	public static testmethod void testFindAvailableSlotsForFieldSales2(){

		Integer threshold = 10;
		String appointmentType = 'Field Consultation';
		String appointmentGroup = 'Field Sales';
		String skillType = 'Sales';
		Integer buffer = 30;
		Opportunity optyObj1 = createSchedulingData(appointmentType, appointmentGroup, skillType, buffer, threshold);

		SchedulerServiceImpl scImplObj = new SchedulerServiceImpl();
		Test.startTest();	
			try{		
				SchedulerServiceDto.ContactInfo contactInfo = scImplObj.getContactInfo(optyObj1.Id);
				List<SchedulerServiceDto.AvailableSlot> availableSlots = scImplObj.findAvailableSlots(optyObj1.Id, Date.today(), Date.today().adddays(5), 'America/Los_Angeles', appointmentType, '', false, null, true);
				System.debug('AvailableSlots: ' + availableSlots);
				
				List<String> primaryRepIds = new List<String>();
				List<String> secondaryIds = new List<String>();
				Datetime datetimeNow = Datetime.now().addhours(4);
				Datetime eventsStartTime = dateTime.newInstance(date.today(),time.newInstance(10,0,0,0)); 
				Datetime eventsEndTime = dateTime.newInstance(date.today(),time.newInstance(12,0,0,0)); 
				for(SchedulerServiceDto.AvailableSlot availableSlotObj : availableSlots){
					if(availableSlotObj.primaryRepIds != null && !availableSlotObj.primaryRepIds.isEmpty()){
						for(Id repId : availableSlotObj.primaryRepIds){
							primaryRepIds.add(repId+'');
							secondaryIds.add(repId+'');
						}
						eventsStartTime = availableSlotObj.startTime;
						eventsEndTime = availableSlotObj.endTime;
						break;
					}
				}
				scImplObj.createAppointment(optyObj1.Id, appointmentType, primaryRepIds, secondaryIds, eventsStartTime, eventsEndTime, 'Test Description-1');
				availableSlots = scImplObj.findAvailableSlots(optyObj1.Id, Date.today(), Date.today().adddays(5), 'America/Los_Angeles', appointmentType, '', false, null, true);
			}catch(Exception expObj){
				System.debug('expObj ' + expObj);
			}
			System.debug('Start Debug for testFindAvailableSlotsForFieldSales2 ' + scImplObj.debugLog1);
			System.debug('Debug Log: ' + scImplObj.debugLog1);
			System.debug('End of Debug for testFindAvailableSlotsForFieldSales2 ');
		Test.stoptest();
	}

	
	public static testmethod void testFindAvailableSlotsForService2(){

		Integer threshold = 10;
		String appointmentType = 'Site Audit';
		String appointmentGroup = 'Site Auditors';
		String skillType = 'Quality';
		Integer buffer = 30;
		Opportunity optyObj1 = createSchedulingData(appointmentType, appointmentGroup, skillType, buffer, threshold);
		
		SchedulerServiceImpl scImplObj = new SchedulerServiceImpl();
		Test.startTest();	
			try{		
				SchedulerServiceDto.ContactInfo contactInfo = scImplObj.getContactInfo(optyObj1.Id);
				List<SchedulerServiceDto.AvailableSlot> availableSlots = scImplObj.findAvailableSlots(optyObj1.Id, Date.today(), Date.today().adddays(5), 'America/Los_Angeles', appointmentType, '', false, null, true);
				System.debug('AvailableSlots: ' + availableSlots);
				
				List<String> primaryRepIds = new List<String>();
				Datetime datetimeNow = Datetime.now().addhours(4);
				Datetime eventsStartTime = dateTime.newInstance(datetimeNow.date(),time.newInstance(datetimeNow.hour(),0,0,0)); 
				Datetime eventsEndTime = dateTime.newInstance(datetimeNow.date(),time.newInstance(datetimeNow.hour()+2,0,0,0)); 
				for(SchedulerServiceDto.AvailableSlot availableSlotObj : availableSlots){
					if(availableSlotObj.primaryRepIds != null && !availableSlotObj.primaryRepIds.isEmpty()){
						for(Id repId : availableSlotObj.primaryRepIds){
							primaryRepIds.add(repId+'');
						}
						eventsStartTime = availableSlotObj.startTime;
						eventsEndTime = availableSlotObj.endTime;
						break;
					}
				}
				scImplObj.createAppointment(optyObj1.Id, appointmentType, primaryRepIds, null, eventsStartTime, eventsEndTime, 'Test Description-1');
				availableSlots = scImplObj.findAvailableSlots(optyObj1.Id, Date.today(), Date.today().adddays(5), 'America/Los_Angeles', appointmentType, '', false, null, true);
			}catch(Exception expObj){
				System.debug('expObj ' + expObj);
			}
			System.debug('Start Debug for testFindAvailableSlotsForService ' + scImplObj.debugLog1);
			System.debug('Debug Log: ' + scImplObj.debugLog1);
			System.debug('End of Debug for testFindAvailableSlotsForService ');
		Test.stoptest();
	}

	public static testmethod void testFindAvailableSlotsForPhoneConsultation(){
		Integer threshold = 10;
		String appointmentType = 'Phone Consultation';
		String appointmentGroup = 'Inside Sales';
		String skillType = 'Sales';
		Integer buffer = 30;
		Opportunity optyObj1 = createSchedulingData(appointmentType, appointmentGroup, skillType, buffer, threshold);
		
		SchedulerServiceImpl scImplObj = new SchedulerServiceImpl();
		Test.startTest();	
			try{		
				SchedulerServiceDto.ContactInfo contactInfo = scImplObj.getContactInfo(optyObj1.Id);
				List<SchedulerServiceDto.AvailableSlot> availableSlots = scImplObj.findAvailableSlots(optyObj1.Id, Date.today(), Date.today().adddays(5), 'America/Los_Angeles', appointmentType, '', false, null, true);
				System.debug('AvailableSlots: ' + availableSlots);
				
				List<String> primaryRepIds = new List<String>();
				Datetime datetimeNow = Datetime.now().addhours(4);
				Datetime eventsStartTime = dateTime.newInstance(datetimeNow.date(),time.newInstance(datetimeNow.hour(),0,0,0)); 
				Datetime eventsEndTime = dateTime.newInstance(datetimeNow.date(),time.newInstance(datetimeNow.hour()+2,0,0,0)); 
				for(SchedulerServiceDto.AvailableSlot availableSlotObj : availableSlots){
					if(availableSlotObj.primaryRepIds != null && !availableSlotObj.primaryRepIds.isEmpty()){
						for(Id repId : availableSlotObj.primaryRepIds){
							primaryRepIds.add(repId+'');
						}
						eventsStartTime = availableSlotObj.startTime;
						eventsEndTime = availableSlotObj.endTime;
						break;
					}
				}
				scImplObj.createAppointment(optyObj1.Id, appointmentType, primaryRepIds, null, eventsStartTime, eventsEndTime, 'Test Description-1');
				availableSlots = scImplObj.findAvailableSlots(optyObj1.Id, Date.today(), Date.today().adddays(5), 'America/Los_Angeles', appointmentType, '', false, null, true);
			}catch(Exception expObj){
				System.debug('expObj ' + expObj);
			}
			System.debug('Start Debug for testFindAvailableSlotsForPhoneConsultation ' + scImplObj.debugLog1);
			System.debug('Debug Log: ' + scImplObj.debugLog1);
			System.debug('End of Debug for testFindAvailableSlotsForPhoneConsultation ');
		Test.stoptest();
	}

	public static testmethod void testAppointmentTrigger(){

		Integer threshold = 10;
		String appointmentType = 'Field Consultation';
		String appointmentGroup = 'Field Sales';
		String skillType = 'Sales';
		Integer buffer = 30;
		Opportunity optyObj1 = createSchedulingData(appointmentType, appointmentGroup, skillType, buffer, threshold);

		Appointment__c newAppt = new Appointment__c();
		newAppt.Event_Assigned_To_Contact1__c = salesRepId;
		newAppt.Appointment_Date_Time__c = Datetime.now();
		newAppt.Appointment_End_Date_Time__c = Datetime.now().addhours(2);
		newAppt.Status__c = 'Appointment Set';
		newAppt.Opportunity__c = optyObj1.Id;
		insert newAppt;

		Test.startTest();	
			newAppt.Status__c = 'Appointment Cancelled';
			newAppt.Cancellation_Reason__c = 'Customer No Show';
			update newAppt;

			Appointment__c newAppt2 = new Appointment__c();
			newAppt2.Event_Assigned_To__c = salesRepId;
			newAppt2.Appointment_Date_Time__c = Datetime.now().addhours(3);
			newAppt2.Appointment_End_Date_Time__c = Datetime.now().addhours(5);
			newAppt2.Status__c = 'Appointment Set';
			newAppt2.Opportunity__c = optyObj1.Id;
			insert newAppt2;
			
			newAppt2.Status__c = 'Appointment Cancelled';
			newAppt2.Cancellation_Reason__c = 'Customer No Show';
			update newAppt2;
			
			SchedulerServiceImpl scImplObj = new SchedulerServiceImpl();
			scImplObj.cancelAppointment(newAppt2.Id);
		Test.stoptest();
	}
    
    public static testmethod void testBaseSheduler(){
        SchedulerServiceImpl scImplObj = new SchedulerServiceImpl();
        String result = scImplObj.getStringValue('TestValue');
        String timezoneStr = 'EST';
        Boolean hasDaylightSavings = true;
		String timeZone = scImplObj.getCustomerTimeZone(timezoneStr, hasDaylightSavings);
        timezoneStr = 'MST';
        timeZone = scImplObj.getCustomerTimeZone(timezoneStr, hasDaylightSavings);
        timezoneStr = 'HST';
        timeZone = scImplObj.getCustomerTimeZone(timezoneStr, hasDaylightSavings);
		timezoneStr = 'CST';
        timeZone = scImplObj.getCustomerTimeZone(timezoneStr, hasDaylightSavings);
        
        string timezoneName = scImplObj.getTimezoneName('America/Los_Angeles');
        timezoneName = scImplObj.getTimezoneName('America/New_York');
        timezoneName = scImplObj.getTimezoneName('America/Chicago');
        timezoneName = scImplObj.getTimezoneName('America/Denver');
        timezoneName = scImplObj.getTimezoneName('America/Adak');
        scImplObj.getTimezone(timezoneName);
        Datetime datetimeObj = Datetime.now();
        scImplObj.getOffset(datetimeObj, timezoneName);
        
        timezoneName = scImplObj.getTimezoneName('');
	}
	
	public static testmethod void testSchedulerServiceDto(){
		SchedulerServiceDto.AvailableSlot availableSlots;
		List<Id> primaryRepIds = new List<Id>();
		List<Id> secondaryRepIds = new List<Id>();
		availableSlots = new SchedulerServiceDto.AvailableSlot(DateTime.now(), DateTime.now().addhours(2), primaryRepIds ,secondaryRepIds);
		availableSlots = new SchedulerServiceDto.AvailableSlot(DateTime.now(), DateTime.now().addhours(2), primaryRepIds);
		availableSlots = new SchedulerServiceDto.AvailableSlot();
		availableSlots.startTimeString = '';
		availableSlots.endTimeString = '';
	}
	/*
	public static testmethod void testSchedulerController(){
		Integer threshold = 10;
		String appointmentType = 'Phone Call';
		String appointmentGroup = 'Inside Sales';
		String skillType = 'Sales';
		Integer buffer = 30;
		Opportunity optyObj1 = createSchedulingData(appointmentType, appointmentGroup, skillType, buffer, threshold);
		System.currentPagereference().getParameters().put('id', optyObj1.Id);

		SchedulerController scControler = new SchedulerController();
		SchedulerServiceDto.ContactInfo contactInfo = scControler.getContactInfo();
		Test.startTest();	
			String sobjectId = optyObj1.Id;
			String fromDateString = '2016-02-15';
			String toDateString =   '2016-02-19'; 
			String timezoneId = 'America/Los_Angeles'; 
			String postalCode = '94566';
			Boolean debug = true;
			List<SchedulerServiceDto.AvailableSlot> availableSlots = SchedulerController.findAvailableSlots(sobjectId, fromDateString, toDateString, timezoneId, appointmentType, postalCode, debug); 
		Test.stopTest();
	}
	*/
	
	public static testmethod void testSchedulerControllerCreateAppointment(){
		Integer threshold = 10;
		String appointmentType = 'Site Audit';
		String appointmentGroup = 'Site Auditors';
		String skillType = 'Quality';
		Integer buffer = 30;
		Opportunity optyObj1 = createSchedulingData(appointmentType, appointmentGroup, skillType, buffer, threshold);
		System.currentPagereference().getParameters().put('id', optyObj1.Id);

		SchedulerController scControler = new SchedulerController();
		SchedulerServiceDto.ContactInfo contactInfo = scControler.getContactInfo();
		Test.startTest();	
			String sobjectId = optyObj1.Id;
			String startTimeString = '2016-01-14T16:26:48.000Z';
			String endTimeString =   '2016-01-14T18:26:48.000Z'; 
			String timezoneId = 'America/Los_Angeles'; 
			String notes = 'Test Notes';
			Boolean debug = true;
			try{
				SchedulerController.createAppointment(sobjectId, appointmentType,  new String[]{}, new String[]{}, startTimeString, endTimeString, notes, debug); 
				SchedulerServiceImpl scImplObj = new SchedulerServiceImpl();
				String customerLocation = '37.666959700000000,-121.870533200000000';
				scImplObj.getDrivetimesForExistingAppointments(appointmentType, customerLocation);
			}catch(Exception e){
				BusinessException expObj = SchedulerController.handleError(true, e);
			}			
		Test.stopTest();
			try{		
				String test1;
				test1.split(',');
			}catch(Exception e){
				BusinessException expObj = SchedulerController.handleError(true, e);
			}	
	}
}