public class GoogleCalendarDto {
    public static final String SyncModule = 'GoogleCalendarSync';
    public static final String SfdcToGoogleSync = 'SfdcToGoogleSync';
    public static final String GoogleToSfdcSync = 'GoogleToSfdcSync';
    public static final String GoogleToSfdcSyncJob = 'GoogleCalendarGoogleToSfdcSyncJob';
    public static final String SfdcToGoogleSyncJob = 'GoogleCalendarSfdcToGoogleSyncJob';
    
    public class Event {
        public String gcalEventId {get;set;}
        public String gcalRecurringEventId {get;set;}
        public String summary {get;set;}
        public String description {get;set;}
        public DateTime startTime {get;set;}
        public DateTime endTime {get;set;}
        public Integer sequence {get;set;}
        public String status {get;set;}
        public String email {get;set;}
        public Boolean isAllDayEvent {get;set;}
        public Boolean createdInGoogle {get;set;}
        public String salesforceEventId {get;set;}
        public String transparency {get;set;}
        public Boolean locked {get;set;}
        
        public Event() {
            createdInGoogle = false;
            isAllDayEvent = false;
        }
    }
    
    public class ListEventsResponse {
        public String syncToken {get;set;}
        public List<Event> events {get;set;}
        
        //Indicates if we had to do full sync to complete the events retrieval
        public Boolean fullSync {get;set;}
        
        public ListEventsResponse() {
            fullSync = false;
            events = new List<Event>();
        }
        
        public void addEvent(Event event) {
            events.add(event);
        }
    }
}