@IsTest
public class CustomerOptyPaymentControllerTest {
    
    public static BaseClass utils = new BaseClass();
    
    testmethod static void testController() {
        
        Sf.settingsService.setString('PaymentOptyContactRole', 'Homeowner');
        
        Account account = BaseClassTest.createTestAccount();
        
        Opportunity opty = new Opportunity();
        opty.name = 'Test Opty2';
        opty.StageName = 'New';
        opty.OwnerId = UserInfo.getUserId();
        opty.Payment_Request_Token__c = 'Token';
        opty.Payment_Request_Token_Status__c = 'Valid';
        opty.AccountId = account.id;
        
        insert opty;
        
        Contact contact1 = new Contact(firstName='Test', lastName='Doe3', email='john.doe1@yopmail.com', MailingStreet='1 Main St', MailingCity='San F', MailingState='CA', MailingCountry='US');
        contact1.AccountId = account.id;
        insert contact1;
        
        OpportunityContactRole role1 = new OpportunityContactRole(OpportunityId=opty.Id, ContactId=contact1.id, Role='Homeowner');     
        insert role1;
    
        opty.Payment_Request_Contact_Role_ID__c = role1.id;
        update opty;
        
        PageReference page = new PageReference('/apex/CustomerOptyPayment?token=Token&&language=en');
        Test.setCurrentPage(page);
        
        CustomerOptyPaymentController controller = new CustomerOptyPaymentController();
        System.assertNotEquals(null, controller.optyPaymentInfo);
        System.assertEquals('1 Main St', controller.billingAddress.Street);
        System.assertEquals('john.doe1@yopmail.com', controller.billingContact.email);
        System.assertEquals(true, controller.validToken);
        System.assertEquals(opty.id, controller.getOptyId());
        System.assertEquals(opty.name, controller.getOptyName());
        System.assertEquals(controller.optyPaymentInfo.opty.Prospect_Id__c, controller.getOptyProspectId());
        
        page = new PageReference('/apex/CustomerOptyPayment?token=TokenNotExists&&language=en');
        Test.setCurrentPage(page);
        
        controller = new CustomerOptyPaymentController();
        System.assertEquals(true, utils.getHasErrorMessagesContains('We couldn\'t find details corresponding to this link.'));
            
        opty.Payment_Request_Token_Status__c = 'Consumed';
        update opty;
        
        page = new PageReference('/apex/CustomerOptyPayment?token=TokenNotExists&&language=en');
        Test.setCurrentPage(page);
        
        controller = new CustomerOptyPaymentController();
        System.assertEquals(false, controller.validToken);
        //System.assertEquals(true, utils.getHasErrorMessagesContains('Successful payment has already been made using this payment link'));
    }
    
    testmethod static void associatePaymentContactWithOptyForToken() {
    
        Sf.settingsService.setString('PaymentOptyContactRole', 'Homeowner');
    
        Opportunity opty = new Opportunity();
        opty.name = 'Test Opty2';
        opty.StageName = 'New';
        opty.OwnerId = UserInfo.getUserId();
        opty.Payment_Request_Token__c = 'Token';
        opty.Payment_Request_Token_Status__c = 'Valid';
        opty.AccountId = BaseClassTest.createTestAccount().id;
        
        insert opty;

        Dto.CustomContact contact = new Dto.CustomContact();
        contact.FirstName = 'Joe';
        contact.LastName = 'Doe';
        contact.Email = 'joe.doe@yopmail.com';
        
        CustomerOptyPaymentController.associatePaymentContactWithOptyForToken('Token', 'onetime-payment', contact);
        Dto.OptyPaymentInfo info = Sf.paymentService.getOptyPaymentInfoForToken('Token');
        
        System.assertEquals(false, utils.getHasErrorMessages());
    }
}