trigger trg_send_appointment_email on Appointment__c (after insert, after update) {
    
    //DateTime appDate = Datetime.now().addDays(1);
    Set<Id> appOppIdSet = new Set<Id>();
    Map<Id,Id> oppConMap = new Map<Id,Id>();
    Map<Id,Id> oppConMap2 = new Map<Id,Id>();
    Map<Id,appointment__c> dateTimeMap = new Map<Id,appointment__c>();
    Map<Id,appointment__c> wipeDateTimeMap = new Map<Id,appointment__c>();
    List<Contact> updateConList = new List<Contact>();
    List<Contact> updateConList2 = new List<Contact>();
    String Site_Visit = 'Site Visit';
    String Web_Consultation = 'Web Consultation';
    String Phone_Consultation = 'Phone Consultation';
    String Apt_Cancelled = 'Appointment Cancelled';
    String Apt_Complete = 'Appointment Complete';
    String Apt_In_Progress = 'Appointment in Progress';
    String Flip_The_Switch_Visit = 'Flip the Switch Visit';
    String Contract_signing = 'Contract Signing';
    String Follow_Up = 'Follow Up';
    String Home_Visit = 'Home Visit';
    String Home_Visit_Follow_Up = 'Home Visit Follow Up';
    String Phone_Call = 'Phone Call';
    String Phone_Call_Follow_Up = 'Phone Call Follow Up';
    
    for(Appointment__c app : Trigger.new){
        if( !app.do_not_sync__c&& ( (Trigger.isInsert && app.Appointment_Date_Time__c != null)
            ||(Trigger.isUpdate && (app.Appointment_Type__c != Trigger.oldmap.get(app.Id).Appointment_Type__c ||  app.Status__c != Trigger.oldmap.get(app.Id).Status__c || app.Rescheduled__c != Trigger.oldmap.get(app.Id).Rescheduled__c ) ) ) 
          ){
             if(((Trigger.isInsert || Trigger.isUpdate) && (app.Appointment_Type__c == Site_Visit || app.Appointment_Type__c == Web_Consultation || app.Appointment_Type__c == Phone_Consultation || app.Appointment_Type__c == Home_Visit || app.Appointment_Type__c == Home_Visit_Follow_Up || app.Appointment_Type__c == Phone_Call || app.Appointment_Type__c == Phone_Call_Follow_Up) && (app.Status__c != Apt_Cancelled && app.Status__c != Apt_Complete && app.Rescheduled__c != true) ) ){
                system.debug('If'+app.Status__c );
                appOppIdSet.add(app.Opportunity__c);
                dateTimeMap.put(app.Opportunity__c,app);
             }   
             
            
             if(Trigger.isUpdate && (app.Status__c == Apt_Cancelled || app.Status__c == Apt_Complete || app.Status__c == Apt_In_Progress || app.Appointment_Type__c == Flip_The_Switch_Visit || app.Appointment_Type__c == Contract_signing || app.Appointment_Type__c == Follow_Up || app.Rescheduled__c == true) ){
               system.debug('Else If'+app.Status__c );
               wipeDateTimeMap.put(app.Opportunity__c,app);
               }
           }
       
    }
    if(!appOppIdSet.isEmpty() && !dateTimeMap.isEmpty()){
      for(OpportunityContactRole OCR : [Select Id, ContactId, OpportunityId from OpportunityContactRole where isPrimary = true and OpportunityId in : appOppIdSet]){
        oppConMap.put(OCR.ContactId,OCR.OpportunityId);
      }
    }
    if(!wipeDateTimeMap.isEmpty()){
      for(OpportunityContactRole OCR2 : [Select Id, ContactId, OpportunityId from OpportunityContactRole where isPrimary = true and OpportunityId in : wipeDateTimeMap.keySet()]){
        oppConMap2.put(OCR2.ContactId,OCR2.OpportunityId);
        system.debug('Map 2:'+oppConMap2);
      }
    }
    if(!oppConMap.isEmpty()){
        for(Contact con: [select Id, Appointment_Date_Time__c,Appointment_End_Date_Time__c from Contact where Id in : oppConMap.KeySet()]){
           if(oppConMap.containsKey(con.Id)){
             con.Appointment_Date_Time__c = dateTimeMap.get(oppConMap.get(con.Id)).Appointment_Date_Time__c;
             con.Appointment_End_Date_Time__c = dateTimeMap.get(oppConMap.get(con.Id)).Appointment_End_Date_Time__c; 
             updateConList.add(con);
           }
           
        }
            
    }
    if(!oppConMap2.isEmpty()){
        for(Contact con2: [select Id, Appointment_Date_Time__c,Appointment_End_Date_Time__c from Contact where Id in : oppConMap2.KeySet()]){
           if(oppConMap2.containsKey(con2.Id)){
             con2.Appointment_Date_Time__c = null;
             con2.Appointment_End_Date_Time__c = null;
             updateConList2.add(con2);
             system.debug('list2'+updateConList2);
           }
        }
    }
    if(!updateConList.isEmpty()){    
       update updateConList;
    }
    if(!updateConList2.isEmpty()){
       system.debug('updateConList2'+updateConList2);
       update updateConList2;
    }
}