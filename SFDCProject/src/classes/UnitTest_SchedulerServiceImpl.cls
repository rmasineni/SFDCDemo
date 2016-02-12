@isTest(SeeAllData=true)
public with sharing class UnitTest_SchedulerServiceImpl {
	
	public static Opportunity createSchedulingData(String appointmentType, String appointmentGroup, String skillType, Integer buffer, Integer threshold){

		List<String> primaryRepIds = new List<String>();
		List<String> secondaryIds = new List<String>();

		UnitTest_ProposalUtil.disableExternalServices();
		Opportunity optyObj1 = TestPRMLibrary.insertOpportunity('ResidentialAccount-01', 'Residential',
                                                                'ResOpty-01', 'Platinum');  

        Id contactRecordTypeId = TestPRMLibrary.getRecordTypeId('Residential', 'Contact');
        Contact contact = new Contact();
        contact.FirstName = 'FirstName-1';
        contact.LastName = 'LastName-1';
        contact.AccountId = optyObj1.AccountId;
        contact.RecordTypeId = contactRecordTypeId;
        contact.email = 'test4@gmail.com';
        insert contact; 

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
			regionObj.Sales_Rep__c = Label.Scheduling_SalesRep;
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
		eventObj1.WhoId = Label.Scheduling_SalesRep;
		eventObj1.IsAllDayEvent = true;
		eventObj1.WhatId = optyObj1.Id;
		eventsList.add(eventObj1);	

		Event eventObj2 = new Event();
		eventObj2.StartDateTime = dateTime.newInstance(date.today().adddays(1),time.newInstance(10,0,0,0)); 
		eventObj2.EndDateTime = eventObj2.StartDateTime.addhours(2);
		eventObj2.Subject = 'Test Appointment';
		eventObj2.WhoId = Label.Scheduling_SalesRep;
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
		update acctObj;
		
		primaryRepIds.add(eventObj1.WhoId);
		secondaryIds.add(eventObj1.WhoId);
		try{
			//scImplObj.createAppointment(optyObj1.Id, appointmentType2, primaryRepIds, secondaryIds, eventsStartTime, eventsEndTime, 'Test Description-1');
		}catch(Exception expObj){
			
		}
		
		optyObj1.Install_Branch_Id__c = Label.Scheduling_InstallBranch;
		optyObj1.Appointment_Territory__c = territoryName;
        update optyObj1;
		try{
			//scImplObj.createAppointment(optyObj1.Id, appointmentType2, primaryRepIds, secondaryIds, eventsStartTime, eventsEndTime, 'Test Description-1');
		}catch(Exception expObj){
			
		}

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


	public static testmethod void testFindAvailableSlotsForService(){

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

}