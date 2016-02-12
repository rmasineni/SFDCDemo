public class SchedulerApiCancelAppointmentHandler extends SchedulerApiBaseHandler {
	
    override public String getApiName() {
        return 'SchedulerApiCancelAppointment';
    }
    
    override public void handleRequest(RestServiceDto.Request req, RestServiceDto.Response resp) {
        String apptId = getRecordIdFromPath(req, 'appointments');
        
        Appointment__c appt = queryAppointment(apptId, req, resp);
        
        if (appt.Status__c != 'Appointment Cancelled') {
			Sf.schedulerService.cancelAppointment(appt.id);
	        appt = queryAppointment(apptId, req, resp);
        }
        
        addToResponse(appt, req, resp);
    }
}