@IsTest
public class OptyPaymentControllerTest {
    
    private static BaseClass utils = new BaseClass();
    
    testmethod public static void testCustomParamNumber() {
        System.assertEquals(4, OptyPaymentController.CUSTOM_PARAM_NUM);
    }

    testmethod public static void testExceptionWithoutoptyId() {
        Test.setCurrentPage(new PageReference('/apex/CallCenterOptyPayment'));
        new OptyPaymentController();
        System.assert(utils.getHasErrorMessages(), 'Expected error message as there is no opty id');
    }

    testmethod public static void testErrorMessageWithoutContactRoleForOpty() {
        Sf.settingsService.setString(Constants.PaymentOptyContactRole, 'Homeowner');
        Opportunity opty = new Opportunity(Name='Test Opty', StageName='New');
        insert opty;
    
        PageReference page = new PageReference('/apex/CallCenterOptyPayment?id=' + opty.id);
        Test.setCurrentPage(page);
        OptyPaymentController controller = new OptyPaymentController();
        System.assert(utils.getHasErrorMessages(), 'Expected error message as we dont have opty contact role');
    }

    testmethod public static void testSuccessfulInit() {
        
        Sf.settingsService.setString(Constants.PaymentOptyContactRole, 'Homeowner');
        Opportunity opty = new Opportunity(Name='Test Opty', StageName='New');
        insert opty;
    
        PageReference page = new PageReference('/apex/CallCenterOptyPayment?id=' + opty.id);
        Test.setCurrentPage(page);
        
        Contact contact = new Contact(FirstName='Joe', LastName='Doe');
        insert contact;
        
        OpportunityContactRole role = new OpportunityContactRole(ContactId=contact.id, OpportunityId=opty.id, Role='Homeowner');
        insert role;
        
        OptyPaymentController controller = new OptyPaymentController();
        System.assert(!utils.getHasErrorMessages(), 'Expected no error message as we defined a opty contact role');
        System.assert(controller.customParams.get(4).indexOf(opty.id)>=0);
    }
    
    testmethod static void associatePaymentContactWithOpty() {
        Opportunity opty = new Opportunity(Name='Test Opty', StageName='New');
        insert opty;
        
        Dto.CustomContact contact = new Dto.CustomContact();
        contact.FirstName = 'John';
        contact.LastName = 'Doe';
        contact.Email = 'john.doe@yopmail.com';
        
        OptyPaymentController.associatePaymentContactWithOpty(opty.id, 'one-time payment', contact);
    }
    
    testmethod static void processPaymentResponse() {
        Opportunity opty = new Opportunity(Name='Test Opty', StageName='New');
        insert opty;
    
        PageReference page = new PageReference('/apex/CallCenterOptyPayment?id=' + opty.id);
        Test.setCurrentPage(page);
        OptyPaymentController controller = new OptyPaymentController();
      
        controller.processPaymentResponse();
    }
}