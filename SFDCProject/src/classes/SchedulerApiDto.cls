public class SchedulerApiDto {
    public static Map<String, String> getSchedulerApiAppointmentFieldMapping() {
	   return RestServiceDto.getFieldMapping('Scheduler Api', 'Appointment__c');
    }
}