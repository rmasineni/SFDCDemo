public with sharing class SchedulerApiUpdateAppointmentHandler extends SchedulerApiBaseHandler {
	
    override public String getApiName() {
        return 'SchedulerApiUpdateAppointment';
    }
    
    override public void handleRequest(RestServiceDto.Request req, RestServiceDto.Response resp) {
        String apptId = getRecordIdFromPath('appointments', req);

        initRequest(req, resp);

        Appointment__c appt = queryAppointment(apptId, req, resp);
        
        applyPatch(appt, getSchedulerApiAppointmentFieldMapping(), req);

		saveRecord(appt, req, resp);
        
        //We need to query again as triggers or other workflows could have updated values.
        appt = queryAppointment(apptId, req, resp);
        addToResponse(appt, req, resp);
    }
    
    public JsonReader initRequest(RestServiceDto.Request req, RestServiceDto.Response resp) {
        debug('Comming to initRequest with request ' + req);
        
        processDefaultsAndOverrides(getApiName(), req.jsonReader);
        
        debug('Request after pre-processing ' + req.jsonReader);
        
        resp.stopwatch.markSubElapsedTime();
        
        return req.jsonReader;
    }
    
    public Appointment__c saveRecord(Appointment__c appt, RestServiceDto.Request req, RestServiceDto.Response resp) {
		update appt;
        return appt;
    }
}