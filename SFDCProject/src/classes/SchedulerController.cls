public class SchedulerController extends BaseClass {

    private static BaseClass utils = new BaseClass();
    public String sobjectId {get;set;} 
    public String schedulingAction {get;set;} 
	public SchedulerServiceDto.ContactInfo contactInfo;
    
	@RemoteAction
    public static List<SchedulerServiceDto.AvailableSlot> findAvailableSlots(String sobjectId, String fromDateString, String toDateString, 
			String timezoneId, String appointmentType, String postalCode, Boolean debug) {
		
       	//If debug parameter is null, using it as boolean would fail so let's init first.
        debug = utils.isTrue(debug);

        try {
            Date fromDate = utils.parseIsoDate(fromDateString);
            Date toDate = utils.parseIsoDate(toDateString);
            List<SchedulerServiceDto.AvailableSlot> availableSlots = 
				new schedulerServiceImpl().findAvailableSlots(sobjectId, fromDate, toDate, timezoneId, appointmentType, postalCode, false, null, debug);
            
            for (SchedulerServiceDto.AvailableSlot availableSlot : availableSlots) {
                availableSlot.startTimeString = formatAsIsoDateTime(availableSlot.startTime, timezoneId);
                availableSlot.endTimeString = formatAsIsoDateTime(availableSlot.endTime, timezoneId);
            }
            
            return availableSlots;

        } catch (Exception e) {
            throw handleError(debug, e);
        }
    }

    @RemoteAction
    public static Id createAppointment(String sobjectId, String appointmentType, 
			String[] primaryRepIds, String[] secondaryRepIds, 
			String startTimeString, String endTimeString, String notes, Boolean debug) {
        try {
            
            Appointment__c appointmentObj = new schedulerServiceImpl().createAppointment(
                sobjectId, appointmentType, primaryRepIds, secondaryRepIds, 
                parseAsIsoDateTime(startTimeString), parseAsIsoDateTime(endTimeString), notes);
            
            return appointmentObj.id;
            
        } catch (Exception e) {
            throw handleError(debug, e);
        }
	}
    
    public static DateTime parseAsIsoDateTime(String dateTimeString) {
		return (DateTime)json.deserialize('"' + dateTimeString + '"', DateTime.class);
    }
    
    public static String formatAsIsoDateTime(DateTime dateTimeVal, String timezoneId) {
        if (dateTimeVal == null) {
            return null;
        }

        if (timezoneId == null) {
	        return dateTimeVal.formatGmt('yyyy-MM-dd\'T\'HH:mm:ssZ');
        }
        
		return dateTimeVal.format('yyyy-MM-dd\'T\'HH:mm:ssZ', timezoneId);
    }
    

    public SchedulerServiceDto.ContactInfo getContactInfo() {
        if (contactInfo == null) {
            contactInfo = new SchedulerServiceImpl().getContactInfo(getParameter('id'));
            contactInfo.timezoneId = (String) firstNonNull(getParameter('timezoneId'), contactInfo.timezoneId);
            contactInfo.timezoneId = (String) firstNonNull(nullIfEmpty(contactInfo.timezoneId), 'America/Los_Angeles');
            contactInfo.timezoneName = new BaseScheduling().getTimezoneName(contactInfo.timezoneId);
        }
    	return contactInfo;
    }
    
    public static BusinessException handleError(Boolean debug, Exception e) {
        String message = null;
        if (e instanceof BusinessException) {
            message = e.getMessage();
        } else {
            message = 'Error while processing your request. Please try again. If error persists, please contact Sunrun Support.';
		}
        
        if (debug) {
            message += '<br/><br/>Details [' + utils.getExceptionDetails(e) + ']';
        }
        
        return new BusinessException(message);
    }
    
    public String getReturnToRecordLabel() {
        return getSobjectName(sobjectId)=='Opportunity'?'opportunity':'FS Dispatch';
    }
}