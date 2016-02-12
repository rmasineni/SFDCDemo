public with sharing class OptyApiGetOptyAppointmentsHandler extends OptyApiBaseHandler {
    override public String getApiName() {
        return 'OptyApiGetOptyAppointments';
    }

    override public void handleRequest(RestServiceDto.Request req, RestServiceDto.Response resp) {
        Opportunity opty = queryOpty(req, resp);
        List<Appointment__c> appointments = queryOptyAppointments(opty.id, resp);
        
		prepareResponse(appointments, req, resp);
    }
    
    public List<Appointment__c> queryOptyAppointments(Id optyId, RestServiceDto.Response resp) {
        String soql = createSoqlWithAuditFields(SchedulerApiDto.getSchedulerApiAppointmentFieldMapping().values(), 
				'Appointment__c', 'Opportunity__c = :optyId', 'lastModifiedDate desc');
        
      	List<Appointment__c> appointments = Database.query(soql);
        
        resp.stopWatch.markSubElapsedTime();
        
        return appointments;
    }
    
	public void prepareResponse(List<Appointment__c> appointments, RestServiceDto.Request req, RestServiceDto.Response resp) {
        JsonWriter jsonWriter = resp.jsonWriter;
        if (appointments.isEmpty()) {
            //This writes a default array
            resp.jsonWriter = new JsonWriter(true);
        } else {
            addToResponse(appointments, SchedulerApiDto.getSchedulerApiAppointmentFieldMapping(), true, req, resp);
        }

        resp.stopWatch.markSubElapsedTime();
    }
}