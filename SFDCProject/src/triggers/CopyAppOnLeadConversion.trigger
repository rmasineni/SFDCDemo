trigger CopyAppOnLeadConversion on Opportunity (After insert) {
    Set <Id> LeadIdSet =  New Set<Id>();
    Map<Id,Id> LeadToOppMap = New Map<Id,Id>();
    List<Appointment__c> AppointmentList = New List<Appointment__c>();
    
    for (Opportunity opp: Trigger.New){
        if(opp.Lead_Id__c!=null && opp.Lead_Id__c!=''){
            LeadtoOppMap.put(opp.Lead_Id__c,opp.Id);
            LeadIdSet.add(opp.Lead_Id__c);
        }
    }
    AppointmentList = [Select Id,Lead__c,Status__c,Opportunity__c,Appointment_Date_Time__c,Appointment_End_Date_Time__c,Event_Assigned_To__c from Appointment__c where Lead__c IN:LeadIdSet];
    if (!AppointmentList.isEmpty()){
        for (Appointment__c app: AppointmentList){
            if (app.Status__c != 'Appointment Cancelled' && (app.Appointment_Date_Time__c!=null || app.Appointment_End_Date_Time__c!=null))
            app.Opportunity__c = LeadToOppMap.get(app.Lead__c);
            }
         }
    
    update AppointmentList;
}