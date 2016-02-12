global class Dto {

    global class Address {
        public String street {get;set;}
        public String city {get;set;}
        public String state {get;set;}
        public String postalCode {get;set;}
        public String country {get;set;}
    }
    
    /**
     * In case of Opty Payment Request page, we need to transfer contact info to guest users.
     * As their profile doesn't usually allow read access for contact, we will not be able to
     * refer to Contact fields in VF page. In such cases, we will use this DTO ojbect to transfer
     * the details from controller to VF page
     */
    global class CustomContact {
        public String FirstName {get;set;}
        public String LastName {get;set;}
        public String Email {get;set;}
        public String Phone {get;set;}
        public String MailingStreet {get;set;}
        public String MailingCity {get;set;}
        public String MailingState {get;set;}
        public String MailingPostalCode {get;set;}
        public String Id {get;set;}
        public String contactNumber {get;set;}
    }
    
    global class AddressResponse {
        public String message {get;set;}
        public Address address {get;set;}
    }

    global class PaymentConfig {
        public String accessKey {get;set;}
        public String secretKey {get;set;}
        public String profileId {get;set;}
    }
    
    global class PaymentAuth {
        public String profileId {get;set;}
        public String accessKey {get;set;}
        public String signature {get;set;}
        public DateTime signedDateTime {get;set;}
        public String signedFieldNames {get;set;}
        public String invalidFieldNames {get;set;}
    }
    
    global class PaymentTransaction {
        public String paymentType {get;set;}
        public String echeckType {get;set;}
        public String transactionType {get;set;}
        public String transactionReferenceNum {get;set;}
        public String transactionId {get;set;}
        public String paymentToken {get;set;}
        public Double amount {get;set;}
        public String currencyCode {get;set;}
        public String paymentGatewayTransactionId {get;set;}
        public String paymentGatewayReferenceNum {get;set;}
    }
    
    global class PaymentDetails {
        public Decimal amount {get;set;}
        public Address billingAddress {get;set;}
        public Contact billingContact {get;set;}
    }
    
    global class PaymentRequest {
        public String currentPageUrl {get;set;}
        public PaymentTransaction paymentTransaction {get;set;}
        public Address billingAddress {get;set;}
        public CustomContact billingContact {get;set;}
        public Map<Integer, String> customParams {get;set;}
    }

    global class PaymentResponse {
        public ResponseHeader header {get;set;}
        public ResponseHeader paymentGatewayHeader {get;set;}
        public PaymentAuth paymentAuth {get;set;}
        public PaymentTransaction paymentTransaction {get;set;}
        public Address billingAddress {get;set;}
        public CustomContact billingContact {get;set;}
        public CreditCard cardDetails {get;set;}
        public ECheck echeck {get;set;}
        public Map<Integer, String> customParams {get;set;}
        public PaymentCustomParameters decodedCustomParams {get;set;}
        public String optyId {get;set;}
        public String paymentPageUrl {get;set;}
    }
    
    global class CreditCard {
        public String expiryMonth {get;set;}
        public String expiryYear {get;set;}
        public String type {get;set;}
    }
    
    global class PaymentCustomParameters {
        public String opportunityId {get;set;}
        public String prospectId {get;set;}
        public String contactId {get;set;}
        public String contactNum {get;set;}
    }
    
    public class OptyPaymentInfo {
        public Opportunity opty {get;set;}
        public Contact billingContact {get;set;}
        public String paymentContactRole {get;set;}
    }
    
    global class ECheck {
        public String echeckType {get;set;}
        public String routingNumber {get;set;}
    }

    global class PreparedPaymentRequest {
        public String paymentServiceFormPostUrl {get;set;}
        public Map<String, String> params {get;set;}        
    }
    
    global class ResponseHeader {
        public String status {get;set;}
        public String statusCode {get;set;}
        public String statusMessage {get;set;}
        public String detailedMessage {get;set;}
        
        public Boolean isSuccess() {
            return 'success'.equalsIgnoreCase(status);
        }
        
        public Boolean isError() {
            return 'error'.equalsIgnoreCase(status);
        }
        
        public ResponseHeader success() {
            status = 'success';
            return this;
        }
        
        global ResponseHeader success(String statusMessage) {
            this.status = 'success';
            this.statusMessage = statusMessage;
            return this;
        }

        public ResponseHeader error(String statusMessage) {
            status = 'error';
            this.statusMessage = statusMessage;
            return this;
        }
        
        public ResponseHeader error(String statusMessage, String detailedMessage) {
            status = 'error';
            this.statusMessage = statusMessage;
            this.detailedMessage = detailedMessage;
            return this;
        }
    }
    
    public static Map<String, Object> successMapResponse(SObject sobj) {
        Map<String, Object> response = new Map<String, Object>();
        response.put('header', new ResponseHeader().success());
        response.put('body', sobj);
        
        return response;
    }

    public static Map<String, Object> successMapResponse(Object obj) {
        Map<String, Object> response = new Map<String, Object>();
        response.put('header', new ResponseHeader().success());
        response.put('body', obj);
        
        return response;
    }

    public static Map<String, Object> errorMapResponse(String message, String details) {
        Map<String, Object> response = new Map<String, Object>();
        response.put('header', new ResponseHeader().error(message, details));
        return response;
    }
}