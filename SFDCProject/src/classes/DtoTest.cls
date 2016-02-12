@IsTest
public with sharing class DtoTest {
    
    testmethod static void testCreatingObjects() {
        new Dto.Address();
        new Dto.CustomContact();
        new Dto.AddressResponse();
        new Dto.PaymentConfig();
        new Dto.PaymentAuth();
        new Dto.PaymentTransaction();
        new Dto.PaymentDetails();
        new Dto.PaymentRequest();
        new Dto.PaymentResponse();
        new Dto.CreditCard();
        new Dto.PaymentCustomParameters();
        new Dto.OptyPaymentInfo();
        new Dto.ECheck();
        new Dto.PreparedPaymentRequest();
        new Dto.AddressResponse();
        new Dto.PaymentDetails();
        new Dto.CreditCard();
        
        Dto.ResponseHeader resp = new Dto.ResponseHeader();
        resp.status = 'success';
        System.assertEquals(true, resp.isSuccess());

        resp.status = 'error';
        System.assertEquals(true, resp.isError());
        System.assertEquals(true, resp.success().isSuccess());
        System.assertEquals('foo', resp.error('foo', 'bar').statusMessage);
        
        Map<String, Object> mapResp = Dto.successMapResponse(new Contact());
        System.assertNotEquals(null, mapResp.get('body'));
        System.assertEquals('success', ((Dto.ResponseHeader)mapResp.get('header')).status);
        
        mapResp = Dto.successMapResponse(new Dto.Address());
        System.assertNotEquals(null, mapResp.get('body'));
        System.assertEquals('success', ((Dto.ResponseHeader)mapResp.get('header')).status);        

        mapResp = Dto.errorMapResponse('foo', 'bar');
        System.assertEquals(null, mapResp.get('body'));
        System.assertEquals('error', ((Dto.ResponseHeader)mapResp.get('header')).status);        
    }
}