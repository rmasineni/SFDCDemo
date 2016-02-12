Trigger Trg_populate_events_aft_ins_aft_up on Appointment__c (after insert, after update) {
    
	Boolean skipValidations = false;
    skipValidations = SkipTriggerValidation.performTriggerValidations();
    if(skipValidations == false){ 
        
        Set<Id> ContactIdset = New Set<Id>();
        List<Contact> ContactuserList = New List<Contact>();
        Map<Id,Id> userIdToContactIdMap = New Map<Id,Id>();
        id salesRepId=system.label.Costco_Dummy_Contact;
        Set<Id> optyIds = new Set<Id>();
        for (Appointment__c appcon : Trigger.New){
			if(appcon.Event_Assigned_to__c !=null){
				ContactIdset.add(appcon.Event_Assigned_to__c);   
			}else{
				for(Integer counter=1; counter <= 4 ; counter++){
	          		String fieldName = 'Event_Assigned_To_Contact' + counter + '__c';
	          		Object Idval = appcon.get(fieldName);
	          		if(Idval != null){
	          			ContactIdset.add((Id)Idval); 
	          		}
	          	}
			}
			if(appcon.Opportunity__c != NULL){
				optyIds.add(appcon.Opportunity__c);
			}
		}
        System.debug('ContactIdset: ' + ContactIdset);
        if(!ContactIdset.isEmpty()){
        	contactuserlist = [Select Id,SunRun_User__c from Contact where Id IN: ContactIdset];
        }
        
        Map<Id, Opportunity> optyMap = new Map<Id, Opportunity>(); 
        if(!optyIds.isEmpty()){
        	optyMap = new Map<Id, Opportunity>([Select Id, name, Account.Latitude__c, Account.Longitude__c from Opportunity where Id in :optyIds]);
        }
        
        if(!contactuserlist.isEmpty()){
            for (Contact con: contactuserlist){
                userIdToContactIdMap.put(con.Id,con.SunRun_User__c);
            }
        }
        
        if (Trigger.isInsert){        
            List<Event> Eventlist = new List <Event>();
            for (Appointment__c app :Trigger.new){
            	Opportunity optyObj = optyMap.get(app.Opportunity__c);
				if(app.Event_Assigned_to__c == null){
					
					for(Integer counter=1; counter <= 4 ; counter++){
		          		String fieldName = 'Event_Assigned_To_Contact' + counter + '__c';
		          		Object Idval = app.get(fieldName);
		          		if(Idval != null){
		          			Id contactId = (Id) Idval;
							Event ev = new Event();
			                ev.StartDateTime = app.Appointment_Date_Time__c;
			                ev.EndDateTime = app.Appointment_End_Date_Time__c;
			                ev.Subject = app.Name__c;
			                ev.WhoId = contactId;
							// ev.WhatId = app.Opportunity__c;
							ev.FS_Dispatch__c = app.FS_Dispatch__c;
							ev.Opportunity__c = app.Opportunity__c;
							ev.Related_To_Id__c = app.account__c;
							if(optyObj != null){
								ev.Latitude__c = optyObj.Account.Latitude__c;
								ev.Longitude__c = optyObj.Account.Longitude__c;
							}
			                if(userIdToContactIdMap.containskey(contactId)){
			                    ev.OwnerId = userIdToContactIdMap.get(contactId);
			                } 
			                ev.appointmentid__c= app.Id;
			                ev.Description = app.Appointment_Description__c;
			                Eventlist.add(ev);	          			
		          		}
	          		}
				}else if(app.Event_Assigned_to__c!=null){
	               	
	               	Event ev = new Event();
	                ev.StartDateTime = app.Appointment_Date_Time__c;
	                ev.EndDateTime = app.Appointment_End_Date_Time__c;
	                ev.Subject = app.Name__c;
	                ev.WhoId = app.Event_Assigned_To__c;
	                //ev.WhatId = app.Opportunity__c;
	                ev.FS_Dispatch__c = app.FS_Dispatch__c;
					ev.Opportunity__c = app.Opportunity__c;
					ev.Related_To_Id__c = app.account__c;
					if(optyObj != null){
						ev.Latitude__c = optyObj.Account.Latitude__c;
						ev.Longitude__c = optyObj.Account.Longitude__c;
					}
	                if(userIdToContactIdMap.get(app.Event_Assigned_To__c) != null){
	                    ev.OwnerId = userIdToContactIdMap.get(app.Event_Assigned_To__c);
	                } 
	                ev.appointmentid__c= app.Id;
	                ev.Description = app.Appointment_Description__c;
	                Eventlist.add(ev);
	            }
			}
            
            if (!EventList.isEmpty()){
                insert Eventlist;
            }
        }
        
        if (Trigger.isUpdate ){  
            List<Event> EventListDelete = New List<Event>();
            Map<Id, Map<Id, Event>> EventsMaps = New Map<Id, Map<Id, Event>>();
            Set<Id> AppointmentIdset = New Set<Id>();
            
            for (Appointment__c ap : Trigger.new){
            	AppointmentIdset.add(ap.Id);
            }
            
            if(!AppointmentIdset.isEmpty()){
				for(Event eventObj : [Select AppointmentId__c,Id,StartDateTime,EndDateTime,whoid,whatid from Event where AppointmentId__c IN:AppointmentIdset]){
					Map<Id, Event> tempEventMap = EventsMaps.containskey(eventObj.AppointmentId__c) ? EventsMaps.get(eventObj.AppointmentId__c) : new Map<Id, Event>();
					tempEventMap.put(eventObj.Id, eventObj);
					EventsMaps.put(eventObj.AppointmentId__c, tempEventMap);
				}
            }

			if(!EventsMaps.isEmpty()){
				for (Appointment__c app :Trigger.new ){
					if(app.Status__c == 'Appointment Cancelled'){
						Map<Id, Event> tempEventMap = EventsMaps.get(app.Id);
	                   	if(tempEventMap != null && !tempEventMap.isEmpty()){
	                   		EventListdelete.addall(tempEventMap.values());
	                    }
					} //if(app.Status__c == 'Appointment Cancelled')
				} //for (Appointment__c app :Trigger.new )
			} //if(!EventsMaps.isEmpty())
            
            System.debug('EventListDelete : ' + EventListDelete);
            if (!EventListDelete.isEmpty()){      
                delete EventListDelete;
            }

        }
             
        Map<Id,Opportunity> salesRepMap = new Map<Id,Opportunity>();
        Map<Id,Id> appOppMap = new Map<Id,Id>();
        Map<Id, Opportunity> OptyUpdateList = new Map<Id, Opportunity>();
        List<Opportunity> optyAptDateList = new List<Opportunity>();
        List<Appointment__c> apptList = new List<Appointment__c>();
        If((Trigger.isInsert) && !userIdToContactIdMap.isEmpty()){
            for(Appointment__c appt : Trigger.new){
                appOppMap.put(appt.Id,appt.Opportunity__c);
                apptList.add(appt);
                system.debug('appOppMap'+appOppMap);
            }
        }
        if(!appOppMap.isEmpty()){
			for(Opportunity Opp : [select Id, SalesRep__c, Appointment_Date_Time__c, Site_Audit_Scheduled__c, Has_Appointments__c, Date_when_Site_Audit_was_Scheduled__c  from Opportunity where Id in : appOppMap.values()]){
				salesRepMap.put(Opp.Id,Opp);
				system.debug('salesRepMap'+salesRepMap);
			}
        }
        if(!salesRepMap.isEmpty()){
			for(Appointment__c appt : apptList){
	            if(appt.Opportunity__c != null && appt.Event_Assigned_to__c != null && userIdToContactIdMap.containsKey(appt.Event_Assigned_to__c)){
	                Opportunity opp = salesRepMap.get(appt.Opportunity__c);
	                opp.Appointment_Date_Time__c = appt.Appointment_Date_Time__c;
	                System.debug('opp.SalesRep__c: ' + opp.SalesRep__c);
	                opp.Has_Appointments__c = true;
					if(appt.Appointment_Type__c != NULL && !appt.Appointment_Type__c.contains('Site Audit') && opp.SalesRep__c == null 
						&& salesRepMap.get(appt.Opportunity__c).SalesRep__c != userIdToContactIdMap.get(appt.Event_Assigned_to__c)){
						opp.SalesRep__c = userIdToContactIdMap.get(appt.Event_Assigned_to__c);                   
	                }
	                
	                if(appt.Appointment_Type__c != NULL && appt.Appointment_Type__c.contains('Site Audit')){
	                	opp.Site_Audit_Scheduled__c = appt.Appointment_Date_Time__c;
	                	opp.Date_when_Site_Audit_was_Scheduled__c = appt.createddate.date();
	                }
	                System.debug('After opp.SalesRep__c: ' + opp.SalesRep__c);
	                OptyUpdateList.put(opp.Id, opp);
	            }
			}
        }
        if(!OptyUpdateList.isEmpty()){
            update OptyUpdateList.values();
        }
    }
    
}