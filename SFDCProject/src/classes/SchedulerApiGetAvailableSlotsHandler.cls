public with sharing class SchedulerApiGetAvailableSlotsHandler extends SchedulerApiBaseHandler {
	
    override public String getApiName() {
        return 'SchedulerApiGetAvailableSlots';
    }

    override public void handleRequest(RestServiceDto.Request req, RestServiceDto.Response resp) {
        String zipCode = req.getStringParam(Field_ZipCode);
        String sobjId = req.getRequiredStringParam(Field_SobjectId);
        
        if (String.isBlank(zipCode)) {
            List<Opportunity> opties = [
                select Account.BillingPostalCode from Opportunity where Id = :sobjId
            ];
            if (!opties.isEmpty()) {
                zipCode = opties.get(0).Account.BillingPostalCode;
            }
        }
        
        List<SchedulerServiceDto.AvailableSlot> availableSlots = Sf.schedulerService.findAvailableSlots(
            sobjId, 
            req.getRequiredDateParam(Field_StartDate),
			req.getRequiredDateParam(Field_EndDate), 
            req.getRequiredStringParam(Field_TimezoneId), 
            req.getRequiredStringParam(Field_AppointmentType),
            zipCode,
            false, 
            null,
            req.isDebug()
        );
        
        if (availableSlots.isEmpty()) {
            resp.jsonWriter = new JsonWriter(true);
        } else {
            for (Integer i = 0; i < availableSlots.size(); i++) {
                resp.jsonWriter.with(i);
                addToResponse(availableSlots.get(i), req, resp);
                resp.jsonWriter.endWith();
            }
        }
    }
    
    public void addToResponse(SchedulerServiceDto.AvailableSlot slot, RestServiceDto.Request req, RestServiceDto.Response resp) {
        resp.jsonWriter.write(Field_StartTime, slot.startTime);
        resp.jsonWriter.write(Field_EndTime, slot.endTime);
        
        if (slot.primaryRepIds != null && !slot.primaryRepIds.isEmpty()) {
	        resp.jsonWriter.write(Field_PrimaryRepIds, slot.primaryRepIds);
        }
        
        if (slot.secondaryRepIds != null && !slot.secondaryRepIds.isEmpty()) {
	        resp.jsonWriter.write(Field_SecondaryRepIds, slot.secondaryRepIds);
        }
    }
}