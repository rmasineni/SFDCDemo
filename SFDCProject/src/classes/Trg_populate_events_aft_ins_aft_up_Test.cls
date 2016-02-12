@isTest
private class Trg_populate_events_aft_ins_aft_up_Test {
    
    private static testmethod void test(){
        Account acc = BaseClassTest.createTestAccount();
        User us = New User(LastName='Smith',Alias ='John',Email='smith@yopmail.com',Username='smith@yopmail.com',Profileid ='00e60000000nGtn',EmailEncodingKey ='UTF-8', LocaleSidKey= 'en_US',TimeZoneSidKey= 'GMT',LanguageLocaleKey = 'en_US');
        insert us;
        Opportunity opp = new Opportunity(Name='TestOpportunity',StageName='Prospecting',salesrep__c=us.id,Accountid =acc.Id);
        insert opp;        
        Contact con = new Contact(LastName='Smith',Email='smith@yopmail.com',AccountId =acc.Id,Title='Sales Rep',Job_Function__c='Sales',SunRun_User__c=us.Id);
        insert con;
        Appointment__c app = new Appointment__c(opportunity__c = opp.Id ,Appointment_Date_Time__c=system.today(),Appointment_End_Date_Time__c=system.today(),Event_Assigned_To__c=con.Id,Status__c='Appointment Set',Appointment_Description__c='This is a site Visit');
        insert app;

        event ev = [Select AppointmentId__c from event where AppointmentId__c=:app.Id];
        system.assertEquals(app.Id,ev.AppointmentId__c);
        
        app.Appointment_Description__c = 'Updated appointment';
        update app;
        app.Status__c = 'Appointment Conmplete';
        update app;
        app.Appointment_Type__c = 'Site Audit';
        update app;
        
        app.Status__c = 'Appointment Cancelled';
        app.Cancellation_Reason__c = 'Customer Not Interested';
        update app;
        
    }
}