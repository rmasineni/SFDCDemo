trigger appointmentBeforeTrigger on Appointment__c (before insert, before update) {

  Set<Id> optyIds = new Set<Id>();
  Map<Id,Id> contactRoleMap = new Map<Id,Id>();
  Map<Id,Contact> appConMap = new Map<Id,Contact>();
  
  for(appointment__c app : trigger.new){
    if(Trigger.isInsert){ 
      optyIds.add(app.Opportunity__c);
    }
  }
  system.debug('-->optyIds'+optyIds);
  if(!optyIds.isEmpty()){
    for(opportunityContactRole OCR : [select Id, contactId,OpportunityId, isPrimary from OpportunityContactRole where isPrimary = true and OpportunityId in: optyIds]){
      contactRoleMap.put(OCR.OpportunityId,OCR.ContactId);
    }
  }
  system.debug('-->contactRoleMap'+contactRoleMap);
  if(!contactRoleMap.isEmpty()){
    for(Contact con : [select Id, Phone,Text_Opt_Out__c from contact where Id in : contactRoleMap.values()]){
      appConMap.put(con.Id,con);
    }
  }
  system.debug('-->appConMap'+appConMap);
  for(Appointment__c appt : trigger.new){
    if(trigger.isInsert && contactRoleMap.containsKey(appt.opportunity__c) && appConMap.containsKey(contactRoleMap.get(appt.opportunity__c))){
      appt.Mobile_for_SMS__c = appConMap.get(contactRoleMap.get(appt.opportunity__c)).Phone;
      appt.Text_Opt_Out__c = appConMap.get(contactRoleMap.get(appt.opportunity__c)).Text_Opt_Out__c;
    }
  }
}