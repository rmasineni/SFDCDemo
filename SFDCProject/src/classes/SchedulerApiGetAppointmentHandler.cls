public class SchedulerApiGetAppointmentHandler extends SchedulerApiBaseHandler {
	
    override public String getApiName() {
        return 'SchedulerApiGetAppointment';
    }
    
    override public void handleRequest(RestServiceDto.Request req, RestServiceDto.Response resp) {
		String appntId = getRecordIdFromPath(req, 'appointments');
        
        Appointment__c appnt = queryAppointment(appntId, req, resp);
        
        addToResponse(appnt, req, resp);
    }
    
}