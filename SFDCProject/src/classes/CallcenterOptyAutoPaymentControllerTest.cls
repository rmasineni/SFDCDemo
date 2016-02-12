@IsTest
public class CallcenterOptyAutoPaymentControllerTest {
    
        public static BaseClass utils = new BaseClass();
    
        testmethod static void testController() {
        Sf.settingsService.setString(Constants.PaymentOptyContactRole, 'Homeowner');
        Account account = BaseClassTest.createTestAccount();
        Opportunity opty = new Opportunity();
        opty.name = 'Test Opty3';
        opty.StageName = 'New';
        opty.AccountId = account.id;
        insert opty;
        
        Test.setCurrentPage(new PageReference('/apex/CallcenterOptyAutoPayment?id=' + opty.id));      
        
        Contact contact1 = new Contact(firstName='Test1', lastName='Doe4', email='john.doe2@yopmail.com', MailingStreet='1 Main St', MailingCity='San F', MailingState='CA', MailingCountry='US');
        contact1.AccountId = account.id;
        contact1.Is_Billing_Contact__c = true;
        insert contact1;
        
        OpportunityContactRole role1 = new OpportunityContactRole(OpportunityId=opty.Id, ContactId=contact1.id, Role='Homeowner');     
        insert role1;    
        
        Test.setCurrentPage(new PageReference('/apex/CallcenterOptyAutoPaymen?id=' + opty.id));
        CallcenterOptyAutoPaymentController controller = new CallcenterOptyAutoPaymentController(null);
        System.assertEquals(true, utils.getHasErrorMessagesContains('Please generate a proposal before initiating a financial transaction.'));
        
        Proposal__c prop = new Proposal__c(Opportunity__c =opty.Id,System_Size_STC_DC__c=5.85,Upfront_Payment__c = 1200,Mode_Name__c='Sunrun - REC - CSI',Name ='PKRDC1439VC1-H',Sales_Rep_Email__c ='abc@gmail.com',Date_Issued__c = system.today());
        insert prop;
            
        Proposal__c prop1 = new Proposal__c(Opportunity__c =opty.Id,System_Size_STC_DC__c=5.85,Upfront_Payment__c = 1200,Mode_Name__c='Sunrun - REC - CSI',Name ='PKRDC1439VC1-H',Sales_Rep_Email__c ='abc@gmail.com',Date_Issued__c = system.today());
        insert prop1;   
        
        OptyPaymentController optyc = new OptyPaymentController(); 
        Dto.optyPaymentInfo optyPaymentInfo = optyc.getOptyPaymentInfo();
        
        controller = new CallcenterOptyAutoPaymentController(null);
        System.assertEquals(opty.id, controller.opty.id);
        System.assertEquals(true, controller.renderPanel);    
}
}