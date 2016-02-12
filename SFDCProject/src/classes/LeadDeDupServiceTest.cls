@IsTest (seeAllData=true)
public class LeadDeDupServiceTest {
   public static testMethod void testLeadDeDupService1(){
       UnitTest_ProposalUtil.disableExternalServices();
       //Test.startTest(); 
       List<Lead> leadList1 = new List<Lead>();
       List<Lead> leadList2 = new List<Lead>();
       Lead lead1p = new lead(lastname='Test',company='Tst', Phone='(925)-499-9000', Channel__c = 'Billboard', Custom_Lead_Source__c= 'Billboard : Brilliant');		
       Lead lead1e = new lead(lastname='Test',company='Tst', Email='leaddedupservice.test@yopmail.com', Channel__c = 'Billboard', Custom_Lead_Source__c= 'Billboard : Brilliant');		
       Lead lead1a = new lead(lastname='Test',company='Tst', Phone='(925)-499-9001', Channel__c = 'Billboard', Custom_Lead_Source__c= 'Billboard : Brilliant',
                              Address_Token__c = 'USA:CA:HAYWARD:A ST:586:94541');		
       Lead lead2p = new lead(lastname='Test',company='Tst', Phone='(925)-499-9000', Channel__c = 'Billboard', Custom_Lead_Source__c= 'Billboard : Brilliant');		
       Lead lead2e = new lead(lastname='Test',company='Tst', Email='leaddedupservice.test@yopmail.com', Channel__c = 'Billboard', Custom_Lead_Source__c= 'Billboard : Brilliant');		
	   Lead lead2a = new lead(lastname='Test',company='Tst', Phone='(925)-499-9002', Channel__c = 'Billboard', Custom_Lead_Source__c= 'Billboard : Brilliant',
                              Address_Token__c = 'USA:CA:HAYWARD:A ST:586:94541');		
      
       /*insert lead1p; 
       insert lead1e;
       insert lead2p; 
       insert lead2e;*/
       
       leadList1.add(lead1p); 
       leadList1.add(lead1e); 
       leadList1.add(lead1a); 
       leadList2.add(lead2p); 
       leadList2.add(lead2e); 
       leadList2.add(lead2a); 
	   insert leadList1;
       insert leadList2;
       //Test.stopTest();
   }
}