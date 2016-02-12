trigger EventTrigger on Event (before insert, before update, before delete, after insert, after update, after delete) {
    if((Trigger.isInsert || Trigger.isUpdate ) && Trigger.isBefore){
    	for(Event eventObj : Trigger.new){
    		eventObj.IsVisibleInSelfService = true;
    	}
    }
	Sf.googleCalendarService.handleEventsTrigger();
}