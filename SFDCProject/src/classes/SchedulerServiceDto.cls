public class SchedulerServiceDto {
	
    public class ContactInfo {
        public Contact contact {get;set;}
        public Account account {get;set;}
        public String timezoneId {get;set;}
        public String timezoneName {get;set;}
		public ContactInfo() {
            timezoneId = 'America/Los_Angeles';
        }
    }
    
    public class AvailableSlot {
        public DateTime startTime {get;set;}
        public DateTime endTime {get;set;}
        public String startTimeString {get;set;}
        public String endTimeString {get;set;}
        public List<Id> primaryRepIds {get;set;}
        public List<Id> secondaryRepIds {get;set;}
        public Integer repCount {get;set;}
        public AvailableSlot() {
            primaryRepIds = new List<Id>();
            secondaryRepIds = new List<Id>();
            repCount = 0;
        }

        public AvailableSlot(DateTime startTime, DateTime endTime, List<Id> primaryRepIds, List<Id> secondaryRepIds) {
			initialize(startTime, endTime, primaryRepIds, secondaryRepIds);
        }
        
        public AvailableSlot(DateTime startTime, DateTime endTime, List<Id> primaryRepIds) {
			initialize(startTime, endTime, primaryRepIds, null);
        }
        
        public void initialize(DateTime startTime, DateTime endTime, List<Id> primaryRepIds, List<Id> secondaryRepIds){
        	this.startTime = startTime;
            this.endTime = endTime;
            this.primaryRepIds = primaryRepIds;
            if(secondaryRepIds != null){
            	this.secondaryRepIds = secondaryRepIds;
            }
        }
    }
}