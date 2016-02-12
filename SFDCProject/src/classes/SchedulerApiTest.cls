@IsTest
public class SchedulerApiTest {
	
    public static List<SchedulerServiceDto.AvailableSlot> availableSlots;
    
    testmethod public static void testGetAvailableSlots() {
		Sf.setTestImplementation('SchedulerServiceImpl', 'SchedulerApiTest.TestSchedulerServiceImpl');
        
        Account acct = new Account(Name='Foo', BillingCity='Dublin', BillingPostalCode='94568');
        insert acct;
        Opportunity opty = new Opportunity(AccountId=acct.id, Name='Foo', StageName='Created');
        insert opty;
        
		availableSlots = new List<SchedulerServiceDto.AvailableSlot>();
        SchedulerServiceDto.AvailableSlot slot1 = 
            new SchedulerServiceDto.AvailableSlot(DateTime.newInstanceGmt(2010, 11, 12, 13, 14, 15), 
                                                  DateTime.newInstanceGmt(2010, 11, 12, 14, 14, 15),
                                                  new String[]{UserInfo.getUserId()}, null);

        SchedulerServiceDto.AvailableSlot slot2 = 
            new SchedulerServiceDto.AvailableSlot(DateTime.newInstanceGmt(2010, 11, 13, 13, 14, 15), 
                                                  DateTime.newInstanceGmt(2010, 11, 13, 14, 14, 15),
                                                  new String[]{UserInfo.getUserId()}, null);
		
        availableSlots.add(slot1);
        availableSlots.add(slot2);
        
        BaseApiTest.setRequest('/v2/appointments/availableslots');
        BaseApiTest.setParam('sobjectId', opty.id);
        BaseApiTest.setParam('startDate', '2010-11-12');
        BaseApiTest.setParam('endDate', '2010-11-13');
        BaseApiTest.setParam('timezoneId', 'America/Los_Angeles');
        BaseApiTest.setParam('appointmentType', 'Sales');
        
        SchedulerApiAvailableSlotsEndpoint.httpGet();
        
        JsonReader reader = BaseApiTest.assertSuccessResponse();
        System.assertEquals(2, reader.getList('').size());
        Map<String, Object> respSlot1 = (Map<String, Object>) reader.getList('').get(0);
        System.assertEquals('2010-11-12T13:14:15.000Z', respSlot1.get('startTime'));
        System.assertEquals('2010-11-12T14:14:15.000Z', respSlot1.get('endTime'));
        System.assertEquals(UserInfo.getUserId(), ((List<Object>) respSlot1.get('primaryRepIds')).get(0));
    }
	
    testmethod public static void testCreateAppointment() {
		Sf.setTestImplementation('SchedulerServiceImpl', 'SchedulerApiTest.TestSchedulerServiceImpl');
		insertSettings();
        
        Account acct = new Account(Name='Foo', BillingCity='Dublin', BillingPostalCode='94568');
        insert acct;
        Opportunity opty = new Opportunity(AccountId=acct.id, Name='Foo', StageName='Created');
        insert opty;

        JsonWriter writer = new JsonWriter();
       	writer.write('sobjectId', opty.id);
       	writer.write('startTime', DateTime.newInstanceGmt(2010, 11, 12, 13, 14, 15));
       	writer.write('endTime', DateTime.newInstanceGmt(2010, 11, 12, 14, 14, 15));
        writer.write('primaryRepIds', new String[]{UserInfo.getUserId()});
       	writer.write('appointmentType', 'Sales');
       	writer.write('notes', 'some notes');
	
        BaseApiTest.setRequest('/v2/appointments/create', writer.toJson());
        SchedulerApiCreateAppointmentEndpoint.httpPost();
        
        JsonReader reader = BaseApiTest.assertSuccessResponse();
        System.assertEquals('2010-11-12T13:14:15.000Z', reader.getString('startTime'));
        System.assertEquals('2010-11-12T14:14:15.000Z', reader.getString('endTime'));
        System.assertEquals('some notes', reader.getString('notes'));
    }
    
    testmethod public static void testGetAppointment() {
		insertSettings();
         
        Appointment__c appt = new Appointment__c();
        appt.Appointment_Date_Time__c = DateTime.newInstanceGmt(2010, 11, 12, 13, 14, 15);
        appt.Appointment_End_Date_Time__c = DateTime.newInstanceGmt(2010, 11, 12, 14, 14, 15);
        appt.Appointment_Description__c = 'some notes';
        appt.Status__c = 'Appointment Set';
        
        insert appt;
		
        BaseApiTest.setRequest('/v2/appointments/' + appt.id);
        SchedulerApiAppointmentEndpoint.httpGet();
        
        JsonReader reader = BaseApiTest.assertSuccessResponse();
        System.assertEquals('Appointment Set', reader.getString('status'));
        System.assertEquals('2010-11-12T13:14:15.000Z', reader.getString('startTime'));
        System.assertEquals('2010-11-12T14:14:15.000Z', reader.getString('endTime'));
        System.assertEquals('some notes', reader.getString('notes'));
        System.assertNotEquals(null, reader.getString('createdBy'));
        System.assertNotEquals(null, reader.getString('createdDate'));
        System.assertNotEquals(null, reader.getString('lastModifiedBy'));
        System.assertNotEquals(null, reader.getString('lastModifiedDate'));
    }

    testmethod public static void testUpdateAppointment() {
		insertSettings();
         
        Appointment__c appt = new Appointment__c();
        appt.Appointment_Date_Time__c = DateTime.newInstanceGmt(2010, 11, 12, 13, 14, 15);
        appt.Appointment_End_Date_Time__c = DateTime.newInstanceGmt(2010, 11, 12, 14, 14, 15);
        appt.Appointment_Description__c = 'some notes1';
        
        insert appt;
		
        JsonWriter writer = new JsonWriter();
       	writer.write('notes', 'some notes2');
        
        BaseApiTest.setRequest('/v2/appointments/' + appt.id, writer.toJson());
        SchedulerApiAppointmentEndpoint.httpPatch();
        
        JsonReader reader = BaseApiTest.assertSuccessResponse();
        System.assertEquals('some notes2', reader.getString('notes'));
    }
    
    testmethod public static void testCancelAppointment() {
		insertSettings();
        
        Appointment__c appt = new Appointment__c();
        appt.Appointment_Date_Time__c = DateTime.newInstanceGmt(2010, 11, 12, 13, 14, 15);
        appt.Appointment_End_Date_Time__c = DateTime.newInstanceGmt(2010, 11, 12, 14, 14, 15);
        appt.Appointment_Description__c = 'some notes1';
        
        insert appt;
		
        BaseApiTest.setRequest('/v2/appointments/' + appt.id +  '/cancel');
        SchedulerApiCancelAppointmentEndpoint.httpPatch();
        
        JsonReader reader = BaseApiTest.assertSuccessResponse();
        System.assertEquals('Appointment Cancelled', reader.getString('status'));
    }

    public static void insertSettings() {
        RestServiceDto.insertFieldMapping('Scheduler Api', 'Appointment__c', 'startTime=Appointment_Date_Time__c,endTime=Appointment_End_Date_Time__c,notes=Appointment_Description__c,appointmentId=Id,status=Status__c');
    }
    
    public class TestSchedulerServiceImpl implements SchedulerService {
        public SchedulerServiceDto.ContactInfo getContactInfo(String sobjId) {
            return null;
       	}
		public List<SchedulerServiceDto.AvailableSlot> findAvailableSlots(String sobjectId, Date eventsStartDate, Date eventsEndDate, String localTimezoneId, String appointmentType, 
                                                                          String zipCode,  Boolean outOfTerritory, List<Id> salesRepIds, Boolean debug){
        	return availableSlots;                                                                      
		}
        
    	public Appointment__c createAppointment(String sobjectId, String appointmentType, String[] primaryRepIds, 
    											String[] secondaryRepIds,  DateTime startTime, DateTime endTime, 
                                                String notes){
			Appointment__c appt = new Appointment__c();
			appt.Appointment_Date_Time__c = startTime;
			appt.Appointment_End_Date_Time__c = endTime;
			appt.Appointment_Description__c = notes;
                                                    
			insert appt;			

			//We will just validate these three fields as fields assignments are dynamic
			//in production
			return appt;
        }
    
        public void cancelAppointment(Id appointmentId) {
		            
        }
        
    }
    
    
}