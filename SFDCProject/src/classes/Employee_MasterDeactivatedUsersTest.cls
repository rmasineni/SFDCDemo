@isTest
private class Employee_MasterDeactivatedUsersTest {

    static testmethod void test() {
        
       // Test Employee Master data to be used by the batch job.
       Employee_Master__c[] Eml = new List<Employee_Master__c>();
       for (Integer i=0;i<5;i++) {
           Employee_Master__c m = new Employee_Master__c(EMAIL_ADDRESS__c='EmployeeMaster' + i +'@sunrunhome.com',Deactivate__c='TRUE');
           Eml.add(m);
       }
       
       for (Integer i=0;i<5;i++) {
           Employee_Master__c m = new Employee_Master__c(EMAIL_ADDRESS__c='EmployeeMaster' + i +'@sunrun.com',Deactivate__c='FALSE');
           Eml.add(m);
       }
       Employee_Master__c m1 = new Employee_Master__c(EMAIL_ADDRESS__c='mohammed.mohsin1@sunrunhome.com',Deactivate__c='TRUE');
       Eml.add(m1);
       
       Employee_Master__c m2 = new Employee_Master__c(EMAIL_ADDRESS__c='ashish.tiwari@sunrun.com',Deactivate__c='TRUE');
       Eml.add(m2);
       
       insert Eml;

            
        /*Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User u = new User(Alias = 'standt', Email='EmployeeMaster1@sunrunhome.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='EmployeeMaster1@sunrunhome.com', IsActive=True);
            
        insert u;*/
        
        //Calling the deactivation User method
        
       Test.startTest();
       Employee_MasterDeactivatedUsers EM = new Employee_MasterDeactivatedUsers();
       EM.DeactivatedUser();
       Test.stopTest();
       
    }
}