public class SchedulerApiCreateAppointmentHandler extends SchedulerApiBaseHandler {
	
    override public String getApiName() {
        return 'SchedulerApiCreateAppointment';
    }

    override public void handleRequest(RestServiceDto.Request req, RestServiceDto.Response resp) {
        validateRequiredFields(new String[]{Field_SobjectId, Field_AppointmentType, Field_PrimaryRepIds, 
            Field_StartTime, Field_EndTime}, req);
        
        String sobjectId = req.jsonReader.getString(Field_SobjectId);
        String appointmentType = req.jsonReader.getString(Field_AppointmentType);
        String[] primaryRepIds = req.jsonReader.getStringList(Field_PrimaryRepIds);
        String[] secondaryRepIds = req.jsonReader.getStringList(Field_SecondaryRepIds);
        DateTime startTime = req.jsonReader.getDateTime(Field_StartTime);
        DateTime endTime = req.jsonReader.getDateTime(Field_EndTime);
        String notes = req.jsonReader.getString(Field_Notes);
        
		Appointment__c appnt = Sf.schedulerService.createAppointment(sobjectId, appointmentType,
			primaryRepIds, secondaryRepIds, startTime, endTime, notes);

        appnt = queryAppointment(appnt.id, req, resp);
        
        addToResponse(appnt, req, resp);
    }
    
}