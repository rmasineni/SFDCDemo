trigger Trg_populate_events_before_ins_after_ins on Appointment__c (after insert, before insert) {
    
    Sf.costcoSyncService.handleAppointmentsTrigger();
}