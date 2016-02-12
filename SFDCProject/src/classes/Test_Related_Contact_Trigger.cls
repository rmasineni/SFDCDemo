@isTest
private class Test_Related_Contact_Trigger {

    static testMethod void TestSetDefaultValues() { 
        Test.startTest();        
         Account a = New Account();
             a.Name = 'TestAccount'; 
             insert a;
             System.debug('Created an Account '+ a.Id);  
          
         ServiceContract sc = new ServiceContract();
              sc.Name = 'Testsc1';
              sc.AccountId = a.Id;
              sc.Legacy_Asset_Number__c = '10082004';
              insert sc;
          System.debug('Created an ServiceContract ' + sc.Id);
               Contact c = new Contact();
               C.FirstName = 'Test';
               C.LastName = 'Contact Test';
               insert C;
            System.debug('Created a Contact' + C.Id);
                         
                               
           Service_Contract_Contact_Rel__c sccr = new Service_Contract_Contact_Rel__c();
               sccr.Contact__c = c.Id;
               sccr.Type__c = 'Billing Contact';
               sccr.ServiceContract__c = sc.Id;
               insert sccr;
                    
              
           System.debug('Created a Related contact'  + sccr.Id); 
                     
           List<servicecontract> sclist = new List<servicecontract>();
              sclist.add(sc);     
           List<Service_Contract_Contact_Rel__c> sccrlist = new List<Service_Contract_Contact_Rel__c>();
              sccrlist.add(sccr);         
                                                         
             Update sclist;
            
           Test.stopTest(); 
    }
}