public interface SchedulerService {
	SchedulerServiceDto.ContactInfo getContactInfo(String sobjId);
	List<SchedulerServiceDto.AvailableSlot> findAvailableSlots(String sobjectId, Date eventsStartDate, Date eventsEndDate, String localTimezoneId, String appointmentType, 
																		String zipCode,  Boolean outOfTerritory, List<Id> salesRepIds, Boolean debug);
    Appointment__c createAppointment(String sobjectId, String appointmentType, String[] primaryRepIds, 
    											String[] secondaryRepIds,  DateTime startTime, DateTime endTime, 
    											String eventDescription);
    
    void cancelAppointment(Id appointmentId);
}