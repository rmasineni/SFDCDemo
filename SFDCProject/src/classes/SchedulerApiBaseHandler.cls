public abstract class SchedulerApiBaseHandler extends RestService {

    public static final String Field_SobjectId = 'sobjectId';
    public static final String Field_AppointmentType = 'appointmentType';
    public static final String Field_PrimaryRepIds = 'primaryRepIds';
    public static final String Field_SecondaryRepIds = 'secondaryRepIds';
    public static final String Field_StartTime = 'startTime';
    public static final String Field_EndTime = 'endTime';
    public static final String Field_Notes = 'notes';
    public static final String Field_ZipCode = 'zipCode';
    public static final String Field_TimezoneId = 'timezoneId';
    public static final String Field_StartDate = 'startDate';
    public static final String Field_EndDate = 'endDate';
    
    public static Map<String, String> getSchedulerApiAppointmentFieldMapping() {
	   return SchedulerApiDto.getSchedulerApiAppointmentFieldMapping();
    }

    public void addToResponse(Appointment__c appnt, RestServiceDto.Request req, RestServiceDto.Response resp) {
        addToResponse(appnt, getSchedulerApiAppointmentFieldMapping(), true, req, resp);
    }
    
    public Appointment__c queryAppointment(String appointmentId, RestServiceDto.Request req, RestServiceDto.Response resp) {
        String soql = createSoqlWithAuditFields(getSchedulerApiAppointmentFieldMapping().values(), 'Appointment__c', 'id = :appointmentId');

        List<Appointment__c> appnts = Database.query(soql);
		
        if (appnts.isEmpty()) {
            throw createBusinessException(RestServiceDto.Error_NotFound, 'Appointment with specified Appointment Id [' + appointmentId + '] not found');
        }
        
        resp.stopWatch.markSubElapsedTime();

        return appnts.get(0);
    }
}