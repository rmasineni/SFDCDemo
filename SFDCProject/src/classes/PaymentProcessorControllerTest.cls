@IsTest
public class PaymentProcessorControllerTest {
    
    testmethod static void testCustomParamsInitialized() {
        PaymentProcessorController controller = new PaymentProcessorController();
        System.assert(controller.customParams != null, 'customParams should have been initialized');
        System.assertEquals('{}', controller.getCustomParamsJson());
    }

    testmethod static void testPaymentResponseNullWithoutParams() {
        PaymentProcessorController controller = new PaymentProcessorController();
        System.assert(controller.paymentResponse == null, 'paymentResponse should have been null');
        System.assertEquals('{}', controller.getPaymentResponseJson());
    }
    
    testmethod static void testPreparePaymentRequest() {
        Map<String, Object> response = PaymentProcessorController.preparePaymentRequest(PaymentServiceImplTest.createPaymentRequest());
        Dto.PreparedPaymentRequest request = (Dto.PreparedPaymentRequest) response.get('body');
        System.assert(request.params.get('signature') != null);    
    }
    
    testmethod static void processPaymentResponse() {
    
        //Core of this functionality is tested as part of PaymentServiceImpl
        new PaymentProcessorController().processPaymentResponse();
    }
}