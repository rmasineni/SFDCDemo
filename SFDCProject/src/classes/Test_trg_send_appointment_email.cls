@isTest

public class Test_trg_send_appointment_email {


 public static testmethod void AppointmentDateTimeTest(){
 
  Account TestAccAppointment = new Account();
  TestAccAppointment.Name = 'Test Appointment Account';
  insert TestAccAppointment;
 
  
  Opportunity appOpp = new Opportunity();
  appOpp.Name = 'Test Appt Oppty';
  appOpp.StageName = 'Open';
  appOpp.CloseDate = date.Today().addDays(90);
  appOpp.AccountId = TestAccAppointment.Id;
  insert appOpp;
  
  Contact appCon = new Contact();
  appCon.LastName = 'Test App';
  appCon.FirstName = 'AppTest';
  appCon.AccountId = TestAccAppointment.Id;
  insert appCon;
  
  OpportunityContactRole OCRTest = new OpportunityContactRole(OpportunityId = appOpp.Id, ContactId = appCon.Id, IsPrimary = True, Role = 'HomeOwner');
  insert OCRTest;
  
  Appointment__c TestAppt1 = new Appointment__c();
  TestAppt1.Name__c = '';
  TestAppt1.Appointment_Date_Time__c = dateTime.Now();
  TestAppt1.Appointment_End_Date_Time__c = dateTime.Now().addHours(1);
  TestAppt1.Appointment_Type__c = 'Site Visit';
  TestAppt1.Status__c = 'Appointment Set';
  TestAppt1.Opportunity__c = appOpp.Id;
  insert TestAppt1;
  
  TestAppt1.Status__c = 'Appointment Complete';
  update TestAppt1;
 
 }






}