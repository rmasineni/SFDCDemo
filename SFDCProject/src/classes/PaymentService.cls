public interface PaymentService {
   
    /**
     * Method prepares for payment posting to Cybersource. It takes the payment details
     * given by the client, injects the server side details (like signature), formats
     * the details as appropriate and returns the parameters as applicable for Cybersource 
     */
    Dto.PreparedPaymentRequest preparePaymentRequest(Dto.PaymentRequest paymentRequest);
    
    /**
     * Validates the payment response parameters from Payment Gateway (Cybersource)
     *
     * 1) Validates the signature
     * 2) Validates the respose is accepted
     * 3) Decodes the parameters into Object
     */
    Dto.PaymentResponse validatePaymentResponse(Map<String, String> paymentResponseParms);
    
    /**
     * Saves the Payment Response into Payment Transaction object.
     */    
    Payment_Transaction__c savePaymentResponse(Dto.PaymentResponse paymentResponse);
    
    /**
     * Returns the Opportunity details (id, name, prospect id) and billing contact based on the associated role
     * and Payment Settings. If there is no contact with specified role associated with Opty, then billing contact
     * would be null.
     *
     * This method is run in "With Sharing" model to make sure we can only access opty if current user has
     * access to. 
     */
    Dto.OptyPaymentInfo getOptyPaymentInfo(Id optyId);
    
    /**
     * For given set of payment transactions, this method would change the owner to corresponding opty owner field.
     *
     * This method is called from the Payment Tx before insert trigger.
     */
    void changeOwnerToOptyOwner(List<Payment_Transaction__c> paymentTxs);
    
    /**
     * Checks if given contact info is already associated with given opty (via email match). If associated,
     * returns that Contact details (contactId, contactNum, etc). If not associated,
     * creates a new contact, associates with Opty as Contact Role (as specified in settings) and returns that
     * new contact.
     * 
     * This method is run in "With Sharing" model to make sure we can only access opty if current user has
     * access to. 
     */
    Dto.CustomContact associatePaymentContactWithOpty(Id optyId, String paymentMode, Dto.CustomContact contactInfo);
    
    /**
     * Sends the payment request email to customer of this opportunity. The contact is selected based on the 
     * configured Contact Role (Settings PaymentOptyContactRole). If such contact role is not defined,
     * then exception is thrown.
     *
     * It uses the email template applicable to send the payment request email.
     */ 
    Contact sendPaymentRequestEmail(Id optyId, Id contactRoleId);
    
    /**
     * Sends the auto payment enrollmet request email to customer of this opportunity. The contact is selected based on the 
     * configured Contact Role (Settings PaymentOptyContactRole). If such contact role is not defined,
     * then exception is thrown.
     *
     * It uses the email template applicable to send the payment request email.
     */ 
    Contact sendRequestForAutoPaymentEmail(Id optyId, Id contactRoleId);
    
    /**
     * For specified Opportunity payment token, returns corresponding Opportunity details (id, name, prospect id) 
     * and billing contact based on the associated role
     * and Payment Settings. If there is no contact with specified role associated with Opty, then billing contact
     * would be null.
     *
     * This method is run in "Without Sharing" model as most of the times user will not have access to opportunity
     * corresponding to the token.
     */
    Dto.OptyPaymentInfo getOptyPaymentInfoForToken(String token);
    
    /**
     * Marks the payment token as consumed.
     */
    void markOptyPaymentTokenConsumed(String token);
    
    /**
     * For given opty id, returns the basic opty details along with all its Contact roles, and corresponding contact details
     */
    Opportunity queryOptyForPaymentAndAllContactRoles(Id optyId);
    
}