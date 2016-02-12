trigger trg_fs_dispatch_after_update on FS_Dispatch__c (after update) {
	Boolean skipValidations = false;
	skipValidations = SkipTriggerValidation.performTriggerValidations();
	if(skipValidations == false){
	   Set<Id> setCaseIds = new Set<Id>();
	   Set<Id> caseIdsForUpdate = new Set<Id>();
	   Set<Id> closeCaseFSDIds = new Set<Id>();
	   Set<Id> fsDisplatchForTaskUpdate = new Set<Id>();
	   
	   Set<Id> donotSendSurveyCaseIds = new Set<Id>();
	   Map<Id, Id> mapCaseToFSD = new Map<Id, Id>();
	   Map<Id, Id> mapCasetoGA = new Map<Id, Id>();
	   Map<Id, Id> mapCasetoSC = new Map<Id, Id>();
	   Set<Id> setGaIds = new Set<Id>();
	   Set<Id> setSCIds = new Set<Id>();
	   Map<Id, String> mapCaseToType = new Map<Id, String>();
	   Map<Id, String> mapContactToEmail = new Map<Id, String>();
	   for(FS_Dispatch__c FSD:Trigger.New)
	   {
	   		if((FSD.FS_Parent_Case__c != null && FSD.FS_Approve_Findings__c == true) 
	   			&& (FSD.Close_Case__c == true && FSD.Close_Case__c != Trigger.oldMap.get(FSD.Id).Close_Case__c) ){
	   			caseIdsForUpdate.add(FSD.FS_Parent_Case__c);
	   			closeCaseFSDIds.add(FSD.Id);
			}
			//if(FSD.Request_for_update__c == true && FSD.Request_for_update__c != Trigger.oldMap.get(FSD.Id).Request_for_update__c){
			//	fsDisplatchForTaskUpdate.add(FSD.Id);
			//}
			//System.debug('fsDisplatchForTaskUpdate: ' + fsDisplatchForTaskUpdate);
	
	      if(FSD.FS_Dispatch_State__c != null 
	         && (FSD.FS_Dispatch_State__c == 'Dispatched' || FSD.FS_Dispatch_State__c == 'Dispatch Findings Approved')
	         && FSD.FS_Dispatch_State__c != Trigger.oldMap.get(FSD.Id).FS_Dispatch_State__c)
	      {     
			 caseIdsForUpdate.add(FSD.FS_Parent_Case__c);
	         setCaseIds.add(FSD.FS_Parent_Case__c);
	         mapCaseToFSD.put(FSD.FS_Parent_Case__c, FSD.Id);
	         if(FSD.FS_Generation_Asset__c != null){
		         mapCasetoGA.put(FSD.FS_Parent_Case__c, FSD.FS_Generation_Asset__c);
		         setGaIds.add(FSD.FS_Generation_Asset__c);
	         }
	         if(FSD.FS_Service_Contract__c != null){
		         mapCasetoSC.put(FSD.FS_Parent_Case__c, FSD.FS_Service_Contract__c);
		         setSCIds.add(FSD.FS_Service_Contract__c);
	         }
	         mapCaseToType.put(FSD.FS_Parent_Case__c, FSD.FS_Dispatch_State__c);
			System.debug('FSD.Don_t_send_dispatch_email_to_customer__c: ' + FSD.Don_t_send_dispatch_email_to_customer__c); 
	         if(FSD.Don_t_send_dispatch_email_to_customer__c == true){
	         	donotSendSurveyCaseIds.add(FSD.FS_Parent_Case__c);
	         }
	      } 
	      //
	   }
	   System.debug('donotSendSurveyCaseIds: ' + donotSendSurveyCaseIds); 
	   
	   Map<Id, Case> caseMap = new Map<Id, Case>([select Id, Status, Reason from Case where id in :caseIdsForUpdate]);
	   
	   List<Case> listCaseForUpdate = new List<Case>();
	   Map<Id, Case> caseMapForUpdate = new Map<Id, Case>();       
	   if(!setCaseIds.isEmpty())
	   {
	      // get GA Contact Ids
	      Map<Id, Id> mapGAtoContact = new Map<Id, Id>();
		  Map<Id, Id> mapSCtoContact = new Map<Id, Id>();
	      for(Generation_Assets__c ga:[select id, Customer_Contact__c, Customer_Contact__r.Email from Generation_Assets__c where id in :setGaIds])
	      {
	        if(ga.Customer_Contact__r.Email != null && ga.Customer_Contact__r.Email != '')
	        {
	          mapGAtoContact.put(ga.Id, ga.Customer_Contact__c);
	          mapContactToEmail.put(ga.Customer_Contact__c, ga.Customer_Contact__r.Email);          
	        }
	      }     
	      
	      for(ServiceContract sc:[select id, ContactId, Customer_Email__c from ServiceContract where id in :setSCIds])
	      {
	        if(sc.Customer_Email__c != null && sc.Customer_Email__c != '')
	        {
	          mapSCtoContact.put(sc.Id, sc.ContactId);
	          mapContactToEmail.put(sc.ContactId, sc.Customer_Email__c);          
	        }
	      }
	      //
	      Id FSNotificationTemplateId = null;
	      Map<String, Id> mapTemplateNameToId = new Map<String, Id>();
	      //
	      for(EmailTemplate et:[Select Id, Name From EmailTemplate where Name in ('FS Customer Notification', 'FS Customer Survey')])
	      {
	          mapTemplateNameToId.put(et.Name, et.Id);
	      } 
	      //
	      Id emailfromid = null;
	      String sunrunCustomerCareEmail = Label.Sunrun_Customer_Care_Email;
	      for(OrgWideEmailAddress owea:[select Id from OrgWideEmailAddress where Address =:sunrunCustomerCareEmail ])
	      {
	         emailfromid = owea.Id;
	      }           
	      //
	      for(Id caseId : setCaseIds)
	      {
	         Case cs = caseMap.get(caseId);
	         
	         if(cs == null)
	         	continue;
	         	
	         cs.Status = 'Service Request Initiated';
	         //listCaseForUpdate.add(cs);
	         caseMapForUpdate.put(cs.Id, cs);
	
			if(cs.Reason != null && cs.Reason != '' && cs.Reason == 'System Removal')
				continue;
			
			System.debug('donotSendSurveyCaseIds1: ' + donotSendSurveyCaseIds);
			if(((cs.Reason != 'System Removal' && mapCaseToType.get(cs.Id) == 'Dispatched') 
	             || (mapCaseToType.get(cs.Id) == 'Dispatch Findings Approved'))
	             		&& (donotSendSurveyCaseIds.contains(cs.Id) == false))
	         {
	            // Send email using "FS Customer Notification" Email Template.                       
	            if((mapCasetoGA.get(cs.Id) != null && mapGAtoContact.get(mapCasetoGA.get(cs.Id)) != null) || 
	            	(mapCasetoSC.get(cs.Id) != null && mapSCtoContact.get(mapCasetoSC.get(cs.Id)) != null) ) 
	            {
	               Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();               
	               if(mapCaseToType.get(cs.Id) == 'Dispatched')
	               {
	                  mail.setTemplateId(mapTemplateNameToId.get('FS Customer Notification'));  
	               }            
	               if(mapCaseToType.get(cs.Id) == 'Dispatch Findings Approved')
	               {
	                  mail.setTemplateId(mapTemplateNameToId.get('FS Customer Survey'));  
	               }                              
	               // Target must be user, contact, or lead id.
	               mail.setOrgWideEmailAddressId(emailfromid); 
	               
	                if(mapCasetoGA.get(cs.Id) != null && mapGAtoContact.get(mapCasetoGA.get(cs.Id)) != null){
	               		mail.setTargetObjectId(mapGAtoContact.get(mapCasetoGA.get(cs.Id)));
	                }
					System.debug('mapSCtoContact: ' + mapSCtoContact);
					if(mapCasetoSC.get(cs.Id) != null && mapSCtoContact.get(mapCasetoSC.get(cs.Id)) != null){
	               		mail.setTargetObjectId(mapSCtoContact.get(mapCasetoSC.get(cs.Id)));
	                }
	                
	               // To assist in getting the merge fields, set the what id.
	               mail.setWhatId(mapCaseToFSD.get(cs.Id));  
	               //mail.setWhatId(cs.Id);
	               //           
	               try{
	                  Messaging.sendEmail(new Messaging.SingleEmailMessage[]{mail});
	               }
	               catch(Exception e){
	                   // If email fails to send, per BSKY-705, ignore!!!     
	                   String emailaddr = '';
						if(mapCasetoGA.get(cs.Id) != null && mapGAtoContact.get(mapCasetoGA.get(cs.Id)) != null){
		                   if(mapContactToEmail.get(mapGAtoContact.get(mapCasetoGA.get(cs.Id))) != null)
		                   {
		                       emailaddr = mapContactToEmail.get(mapGAtoContact.get(mapCasetoGA.get(cs.Id)));
		                   }              
						}
						if(mapCasetoSC.get(cs.Id) != null && mapSCtoContact.get(mapCasetoSC.get(cs.Id)) != null){
		                   if(mapContactToEmail.get(mapSCtoContact.get(mapCasetoSC.get(cs.Id))) != null)
		                   {
		                       emailaddr = mapContactToEmail.get(mapSCtoContact.get(mapCasetoSC.get(cs.Id)));
		                   }              
						}
	                   System.Debug('Invalid email address: ' + emailaddr);
	               }        
	            }       
	         }
	         //
	      }
	   }
	   
	   //if(!listCaseForUpdate.isEmpty())
	   //{
	   //    update listCaseForUpdate;
	   //}
	
		/*
		List<Task> taskList = new List<Task>();
		for(Id fsdID : fsDisplatchForTaskUpdate){
			FS_Dispatch__c FSD = Trigger.newMap.get(fsdID);
			Task taskObj = new Task();
			taskObj.WhatId = FSD.Id;
			taskObj.status = 'Open';
			taskObj.ActivityDate = date.today();
			taskObj.subject = 'Customer needs follow up';
			taskObj.priority = 'Normal';
			taskObj.Activity_Channel__c = 'Phone';
			taskObj.ownerId = FSD.OwnerId;
			taskList.add(taskObj);
		}
		
		if(taskList.size() > 0 ){
			insert taskList;
		}
		*/
		
		for(Id fsdID : closeCaseFSDIds){
			Id caseId = Trigger.newMap.get(fsdID).FS_Parent_Case__c;
			Case cs = caseMap.get(caseId);
			if(cs != null && cs.Status != 'Closed')
			{	
				cs.Status = 'Closed';
				caseMapForUpdate.put(cs.Id, cs);
			}
		}
	
	   if(caseMapForUpdate.size() > 0)
	   {
	       update caseMapForUpdate.values();
	   }
	}
}