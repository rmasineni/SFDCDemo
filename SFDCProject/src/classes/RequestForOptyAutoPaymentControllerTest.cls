@IsTest
public class RequestForOptyAutoPaymentControllerTest {

    public static BaseClass utils = new BaseClass();
    
    testmethod static void testController() {
		insert new Settings__c(Name='PaymentRequestUrl', Value1__c='http://majdev.force.com'); //some dummy url
        
        Account account = BaseClassTest.createTestAccount();
        Opportunity opty = new Opportunity();
        opty.name = 'Test Opty3';
        opty.StageName = 'New';
        opty.AccountId = account.id;
        insert opty;

        Test.setCurrentPage(new PageReference('/apex/RequestForOptyAutoPayment?id=' + opty.id));

        RequestForOptyAutoPaymentController controller = new RequestForOptyAutoPaymentController(null);
       // System.assertEquals(true, utils.getHasErrorMessagesContains('There are no contact roles defined for the Opportunity. Please return to Opportunity, add Contact Roles and try again.'));
        
        
        Contact contact1 = new Contact(firstName='Test1', lastName='Doe4', email='john.doe2@yopmail.com', MailingStreet='1 Main St', MailingCity='San F', MailingState='CA', MailingCountry='US');
        contact1.AccountId = account.id;
        insert contact1;
        
        OpportunityContactRole role1 = new OpportunityContactRole(OpportunityId=opty.Id, ContactId=contact1.id, Role='Homeowner');     
        insert role1;    
        
        Test.setCurrentPage(new PageReference('/apex/RequestForOptyAutoPayment?id=' + opty.id));

        RequestForOptyAutoPaymentController controller1 = new RequestForOptyAutoPaymentController(null);
      //  System.assertEquals(true, utils.getHasErrorMessagesContains('Please generate a proposal before initiating a financial transaction.'));
        
        Proposal__c prop = new Proposal__c(Opportunity__c =opty.Id,System_Size_STC_DC__c=5.85,Upfront_Payment__c = 1200,Mode_Name__c='Sunrun - REC - CSI',Name ='PKRDC1439VC1-H',Sales_Rep_Email__c ='abc@gmail.com',Date_Issued__c = system.today());
        insert prop;
      
        controller = new RequestForOptyAutoPaymentController(null);
        controller.returnToOpty();
        System.assertEquals(opty.id, controller.opty.id);
        System.assertEquals(true, controller.autoPaymentEmail);
        
        controller.sendRequestForPaymentEmail();
        System.assertEquals(true, utils.getHasErrorMessagesContains('Please select a Contact to send Payment Request email'));
        
        controller.contactRoleId = role1.id;
        controller.sendRequestForPaymentEmail();
       
        //RequestForOptyAutoPaymentController controller2 = new RequestForOptyAutoPaymentController(null);
        //System.assertEquals(true, controller2.autoPaymentEmail);
        
    }
    
}