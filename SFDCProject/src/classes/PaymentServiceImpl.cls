public virtual without sharing class PaymentServiceImpl extends BaseClass implements PaymentService {
    
    public static Integer MAX_CUSTOM_PARAMS = 100;
    
    public static String PaymentType_Card = 'card';
    public static String TransactionType_Sale = 'sale';
    public static String PaymentTokenStatus_Consumed = 'Consumed';
    public static String Language_Spanish = 'Spanish';
    public static String LanguageCode_Spanish = 'es';
    public static String LanguageCode_English = 'en';
    public static String PaymentMode_OneTime = 'OneTime';
    public static String PaymentMode_Recurring = 'Recurring';

    public Payment_Transaction__c savePaymentResponse(Dto.PaymentResponse paymentResponse) {
        debug('Saving the payment transaction ' +paymentResponse);
        
        try {
            Payment_Transaction__c paymentTransaction = new Payment_Transaction__c(
                Status__c = paymentResponse.paymentGatewayHeader.status,
                Status_Message__c = paymentResponse.paymentGatewayHeader.statusMessage,
                Status_Code__c = paymentResponse.paymentGatewayHeader.statusCode,
                Payment_Type__c = paymentResponse.paymentTransaction.paymentType,
                Transaction_Type__c = paymentResponse.paymentTransaction.transactionType,
                Reference_Num__c = paymentResponse.paymentTransaction.transactionReferenceNum,
                Transaction_Id__c = paymentResponse.paymentTransaction.transactionId,
                Payment_Token__c = paymentResponse.paymentTransaction.paymentToken,
                Amount__c = paymentResponse.paymentTransaction.amount,
                Payment_Gateway_Reference_Num__c = paymentResponse.paymentTransaction.paymentGatewayReferenceNum,
                Payment_Gateway_Transaction_Id__c = paymentResponse.paymentTransaction.paymentGatewayTransactionId,
                Profile_Id__c = paymentResponse.paymentAuth.profileId,
                Access_Key__c = paymentResponse.paymentAuth.accessKey,
                Transaction_DateTime__c = paymentResponse.paymentAuth.signedDateTime,
                Invalid_Field_Names__c = paymentResponse.paymentAuth.invalidFieldNames,
                Street__c = paymentResponse.billingAddress.street,
                City__c = paymentResponse.billingAddress.city,
                State__c = paymentResponse.billingAddress.state,
                Postal_Code__c = paymentResponse.billingAddress.postalCode,
                First_Name__c = paymentResponse.billingContact.FirstName,
                Last_Name__c = paymentResponse.billingContact.LastName,
                Email__c = paymentResponse.billingContact.Email,
                Custom_Parameters__c = Json.serialize(paymentResponse.customParams),
                Payment_Page_Url__c = paymentResponse.paymentPageUrl
            );
            
            if (paymentResponse.decodedCustomParams != null) {
                paymentTransaction.Opportunity__c = paymentResponse.decodedCustomParams.opportunityId;
                paymentTransaction.Prospect_Id__c = paymentResponse.decodedCustomParams.prospectId;
                paymentTransaction.Contact__c = paymentResponse.decodedCustomParams.contactId;
                paymentTransaction.Contact_Number__c = paymentResponse.decodedCustomParams.contactNum;
            }
            
            insert paymentTransaction;
            
            //If somethihg goes wrong while updating the opty or contract, let's treat that as success but log a error log.
            try {
                //If this payment transaction is for an opportunity and if that opportunity 
                //belongs to any Service Contracts, and if this transaction is create payment token
                //we need to set flag "Enrolled for Auto Payment".
                if (equalsIc(paymentResponse.paymentGatewayHeader.status, Constants.PaymentStatus_Accept)
                        && equalsIc(paymentResponse.paymentTransaction.transactionType, Constants.TransactionType_CreatePaymentToken)
                        && paymentResponse.decodedCustomParams != null 
                        && isNotEmpty(paymentResponse.decodedCustomParams.opportunityId)) {
                    
                    Opportunity opty = queryOptyForPaymentAndAllContactRoles(paymentResponse.decodedCustomParams.opportunityId);
                    if (opty != null) {
                        info('Updating the opty [' + opty + '] with payment mode [' + Constants.ServiceContractPaymentMode_Recurring + ']');
                        opty.Payment_Mode__c = Constants.ServiceContractPaymentMode_Recurring;
                        
                        update opty;
                    }
                            
                    List<ServiceContract> contracts = queryServiceContractForPaymentAndAllContactRoles(paymentResponse.decodedCustomParams.opportunityId);
                    if (!contracts.isEmpty()) {
                        //We need to update only for first one, per requirement
                        ServiceContract contract = contracts.get(0);
                        
                        info('Updating the Service contract [' + contract + '] with payment mode [' + Constants.ServiceContractPaymentMode_Recurring + ']');
                        contract.Payment_Mode__c = Constants.ServiceContractPaymentMode_Recurring;
    
                        update contract;
                    }
                }
            } catch (Exception e) {
                ExceptionLogger.logException('PaymentService/savePaymentResponse', 'Error while updating opty/service contract for payment txn ' + paymentTransaction, paymentTransaction.id, e);
            }

            return paymentTransaction;
        } catch (Exception e) {
            throw new SystemException('Exception while saving the tx '+ getStackTrace(e));
        }
    }

    public Dto.PreparedPaymentRequest preparePaymentRequest(Dto.PaymentRequest paymentRequest) {
        Map<String, String> paymentParams = new Map<String, String>();
        Dto.PaymentConfig config = getPaymentConfig(paymentRequest.paymentTransaction.transactionType);
        List<String> signedFields = new List<String>();

        addSignedParam('access_key', config.accessKey, paymentParams, signedFields);
        addSignedParam('profile_id', config.profileId, paymentParams, signedFields);
        addSignedParam('transaction_uuid', Test.isRunningTest()?(String)BaseClass.testParams.get('transaction_uuid'):getRandomLongString(), paymentParams, signedFields);
        addSignedParam('signed_date_time', getCurrentUtcIsoDateTime(), paymentParams, signedFields);
        addSignedParam('locale', 'en', paymentParams, signedFields);
        addSignedParam('echeck_sec_code', 'WEB', paymentParams, signedFields);
        
        addSignedParam('transaction_type', paymentRequest.paymentTransaction.transactionType, paymentParams, signedFields);
        addSignedParam('currency', 'USD', paymentParams, signedFields);
        addSignedParam('amount', String.valueOf(paymentRequest.paymentTransaction.amount), paymentParams, signedFields);
        addSignedParam('payment_method', paymentRequest.paymentTransaction.paymentType, paymentParams, signedFields);
        
        Dto.CustomContact contact = paymentRequest.billingContact != null?paymentRequest.billingContact:new Dto.CustomContact();
        addSignedParam('bill_to_forename', contact.firstName, paymentParams, signedFields);
        addSignedParam('bill_to_surname', contact.lastName, paymentParams, signedFields);
        addSignedParam('bill_to_email', contact.email, paymentParams, signedFields);
        addSignedParam('bill_to_phone', contact.phone, paymentParams, signedFields);
        
        Dto.Address address = paymentRequest.billingAddress != null?paymentRequest.billingAddress:new Dto.Address();
        addSignedParam('bill_to_address_line1', emptyIfNull(address.street), paymentParams, signedFields);
        addSignedParam('bill_to_address_city', emptyIfNull(address.city), paymentParams, signedFields);
        addSignedParam('bill_to_address_state', emptyIfNull(address.state), paymentParams, signedFields);
        addSignedParam('bill_to_address_country', firstNonEmpty(address.country, 'US'), paymentParams, signedFields);
        addSignedParam('bill_to_address_postal_code', emptyIfNull(address.postalCode), paymentParams, signedFields);
        
        //We would want the response to come back to same url where currently payment
        //widget is hosted. This way, we could reuse the widget in multiple places
        //without having to configure the url in Cybersource side.
        if (isNotEmpty(paymentRequest.currentPageUrl)) {
            addSignedParam('override_custom_receipt_page', paymentRequest.currentPageUrl, paymentParams, signedFields);
        }
        
        String referenceNum = null;
        if (paymentRequest.customParams != null) {
            for (Integer key : paymentRequest.customParams.keySet()) {
                addSignedParam('merchant_secure_data' + key, paymentRequest.customParams.get(key), paymentParams, signedFields);
                
                //One of these custom parameters contains a json with opportunity id in it (which can serialize to Dto.PaymentCustomParameters)
                //If so, extract the opty id, get the Deal Id, which serves as the Reference_Num__c. If opty cannot be identified
                //then generate a random number.
                try {
                    Dto.PaymentCustomParameters customParams = (Dto.PaymentCustomParameters) Json.deserialize(paymentRequest.customParams.get(key), Dto.PaymentCustomParameters.class);
                    if (customParams != null && isNotEmpty(customParams.opportunityId)) {
                        referenceNum = [select Deal_Id__c from Opportunity where id = :customParams.opportunityId limit 1].Deal_Id__c;
                    }
                } catch (Exception e) {
                    //ignore as json string doesn't match the expected class
                }
            }
        }
        
        referenceNum = firstNonEmpty(referenceNum, getRandomString(Constants.DealIdLength)); //Length matching the opty dealid
        
        //We need to prefix and suffix two different values depending if it is deposit or recurring setup. These values would be read from the 
        //custom settings.
        if (equalsIc(paymentRequest.paymentTransaction.transactionType, TransactionType_Sale)) {
            referenceNum = Sf.settingsService.getString(Constants.PaymentDepositDealIdPrefix, '') + referenceNum
                    + Sf.settingsService.getString(Constants.PaymentDepositDealIdSuffix, '');
        } else {
            referenceNum = Sf.settingsService.getString(Constants.PaymentAchDealIdPrefix, '') + referenceNum
                    + Sf.settingsService.getString(Constants.PaymentAchDealIdSuffix, '');
        }
        
        //After prefix, suffix, we need 5 digit random numer.
        referenceNum += getRandomString(Constants.RefNumRandomStringLength);
        
        addSignedParam('reference_number', Test.isRunningTest()?(String)BaseClass.testParams.get('reference_number'):referenceNum, paymentParams, signedFields);
        
        if (equalsIc(paymentRequest.paymentTransaction.paymentType, PaymentType_Card)) {
            addSignedParam('unsigned_field_names', 'card_type,card_number,card_cvn,card_expiry_date', paymentParams, signedFields);
        } else {
            addSignedParam('unsigned_field_names', 'echeck_account_type,echeck_routing_number,echeck_account_number', paymentParams, signedFields);
        }
        
        //Concatenate all signed fields and include it as additional parameter
        signedFields.add('signed_field_names');
        paymentParams.put('signed_field_names', join(signedFields, ','));
        
        //Finally calculate the signature based on all the information and add to the request.        
        paymentParams.put('signature', signParameters(paymentParams, config));
    
        Dto.PreparedPaymentRequest response = new Dto.PreparedPaymentRequest();
        response.params = paymentParams;
        response.paymentServiceFormPostUrl = Sf.settingsService.getString(Constants.CybersourceFormPostUrl);
    
        return response;            
    }
 
    private void addSignedParam(String key, String value, Map<String, String> paymentParams, List<String> signedFields) {
        paymentParams.put(key, value);
        signedFields.add(key);
    }
 
    public Dto.PaymentResponse validatePaymentResponse(Map<String, String> paymentResponseParams) {
        Dto.PaymentResponse response = extractResponseParameters(paymentResponseParams);
        
        Dto.PaymentConfig config = getPaymentConfig(response.paymentTransaction.transactionType);
        String responseSignature = response.paymentAuth.signature;
        String calculatedSignature = signParameters(paymentResponseParams, config);
        
        response.header = new Dto.ResponseHeader();
        if (responseSignature.equals(calculatedSignature)) {
            System.debug('Signature ' + calculatedSignature + ' matched the response signature');
            if (equalsIc(response.paymentGatewayHeader.status, Constants.PaymentStatus_Accept)) {
                response.header.success('Validated the signature successfully');
            } else {
                response.header.error('Payment Gateway returned non-successful response (' + response.paymentGatewayHeader.status + ' ' +response.paymentGatewayHeader.statusMessage + ')');
            }
            
        } else {
            response.header.error('Returned Signature ' + responseSignature + ' doesn\'t match the calculated signature ' + calculatedSignature);
        }
    
        return response;            
    }

    public Dto.PaymentResponse extractResponseParameters(Map<String, String> paymentResponseParams) {
        Dto.PaymentResponse response = new Dto.PaymentResponse();
        response.paymentGatewayHeader = new Dto.ResponseHeader();
        response.paymentGatewayHeader.status = paymentResponseParams.get('decision').toLowerCase();
        response.paymentGatewayHeader.statusCode = paymentResponseParams.get('reason_code');
        response.paymentGatewayHeader.statusMessage = paymentResponseParams.get('message');
    
        response.billingContact = new Dto.CustomContact();
        response.billingContact.firstName = paymentResponseParams.get('req_bill_to_forename');
        response.billingContact.lastName = paymentResponseParams.get('req_bill_to_surname');
        response.billingContact.email = paymentResponseParams.get('req_bill_to_email');
        response.billingContact.phone = paymentResponseParams.get('req_bill_to_phone');
        
        response.billingAddress = new Dto.Address();
        response.billingAddress.street = paymentResponseParams.get('req_bill_to_address_line1');
        response.billingAddress.city = paymentResponseParams.get('req_bill_to_address_city');
        response.billingAddress.state = paymentResponseParams.get('req_bill_to_address_state');
        response.billingAddress.postalCode = paymentResponseParams.get('req_bill_to_address_postal_code');
        response.billingAddress.country = paymentResponseParams.get('req_bill_to_address_country');
        
        response.paymentTransaction = new Dto.PaymentTransaction();
        if (isNotEmpty(paymentResponseParams.get('auth_amount'))) {
            response.paymentTransaction.amount = Double.valueOf(paymentResponseParams.get('auth_amount'));
            
        } else if (isNotEmpty(paymentResponseParams.get('req_amount'))) {
            response.paymentTransaction.amount = Double.valueOf(paymentResponseParams.get('req_amount'));
        }
        
        response.paymentTransaction.currencyCode = paymentResponseParams.get('req_currency');
        response.paymentTransaction.paymentType = paymentResponseParams.get('req_payment_method');
        response.paymentTransaction.transactionType = paymentResponseParams.get('req_transaction_type');
        response.paymentTransaction.transactionReferenceNum = paymentResponseParams.get('req_reference_number');
        response.paymentTransaction.transactionId = paymentResponseParams.get('req_transaction_uuid');
        response.paymentTransaction.paymentGatewayTransactionId = paymentResponseParams.get('transaction_id');
        response.paymentTransaction.paymentGatewayReferenceNum = paymentResponseParams.get('auth_trans_ref_no');
        response.paymentTransaction.paymentToken = paymentResponseParams.get('payment_token');
        
        response.paymentAuth = new Dto.PaymentAuth();
        response.paymentAuth.signature = paymentResponseParams.get('signature');
        if (isNotEmpty(paymentResponseParams.get('signed_date_time'))) {
            response.paymentAuth.signedDateTime = parseAsUtcIsoDateTime(paymentResponseParams.get('signed_date_time'));
        }
        response.paymentAuth.invalidFieldNames = paymentResponseParams.get('invalid_fields');
        response.paymentAuth.signedFieldNames = paymentResponseParams.get('signed_field_names');
        response.paymentAuth.profileId = paymentResponseParams.get('req_profile_id');
        response.paymentAuth.accessKey = paymentResponseParams.get('req_access_key');
        response.paymentPageUrl = paymentResponseParams.get('req_override_custom_receipt_page');
        
        if (equalsIc(response.paymentTransaction.paymentType, PaymentType_Card)) {
            response.cardDetails = new Dto.CreditCard();
            response.cardDetails.type = paymentResponseParams.get('req_card_type');
            String expiryDate = paymentResponseParams.get('req_card_expiry_date');
            if (isNotEmpty(expiryDate)) {
                response.cardDetails.expiryMonth = expiryDate.split('-')[0];
                response.cardDetails.expiryYear = expiryDate.split('-')[1];
            }
        } else {
            response.echeck = new Dto.ECheck();
            response.echeck.echeckType = paymentResponseParams.get('req_echeck_account_type');
        }
        
        response.customParams = new Map<Integer, String>();
        for(Integer i = 1; i <= MAX_CUSTOM_PARAMS; i++) {
            String value = paymentResponseParams.get('req_merchant_secure_data' + i);
            if (isNotEmpty(value)) {
                response.customParams.put(i, value);
            }
        }
        
        return response;
    }

    public String signParameters(Map<String, String> paymentParams, Dto.PaymentConfig config) {
        //Serializing the parameters for debug otherwise, sfdc wont log all details
        System.debug('Signing the payment request with parameters ' + Json.serialize(paymentParams) + ' using config ' + config);
        
        List<String> signedFieldNames = String.valueOf(paymentParams.get('signed_field_names')).split(',');
        List<String> dataToSign = new List<String>();
        for (String signedFieldName : signedFieldNames) {
            dataToSign.add(signedFieldName + '=' + String.valueOf(paymentParams.get(signedFieldName)));
        }

        String stringToSign = join(dataToSign, ',');
        System.debug('Computed Payment String to sign ' + stringToSign);
        
        Blob hmacData = Crypto.generateMac('HmacSHA256', Blob.valueOf(stringToSign), Blob.valueOf(config.secretKey));
        String signature = EncodingUtil.base64Encode(hmacData);
        System.debug('Calculated Signature is ' + signature);
        
        return signature;
    }
 
    public Dto.PaymentConfig getPaymentConfig(String transactionType) {
        Dto.PaymentConfig config = new Dto.PaymentConfig();
        if (equalsIc(transactionType, TransactionType_Sale)) {
            config.accessKey = Sf.settingsService.getString(Constants.CybersourceDepAccessKey);
            config.secretKey = Sf.settingsService.getString(Constants.CybersourceDepSecretKeyPart1) 
                + Sf.settingsService.getString(Constants.CybersourceDepSecretKeyPart2);
            config.profileId = Sf.settingsService.getString(Constants.CybersourceDepProfileId);
        } else {
            config.accessKey = Sf.settingsService.getString(Constants.CybersourceAchAccessKey);
            config.secretKey = Sf.settingsService.getString(Constants.CybersourceAchSecretKeyPart1) 
                + Sf.settingsService.getString(Constants.CybersourceAchSecretKeyPart2);
            config.profileId = Sf.settingsService.getString(Constants.CybersourceAchProfileId);
        }
        return config;
    }
    
    public virtual Dto.OptyPaymentInfo getOptyPaymentInfo(Id optyId) {
        throw new BusinessException('This operation (getOptyPaymentInfo) is not supported in this implementaiton (PaymentServiceImpl)');
    }

    public void changeOwnerToOptyOwner(List<Payment_Transaction__c> paymentTxs) {
        Map<Id, SObject> optyMap = getIdMap([
            select
                Id,
                OwnerId
            from Opportunity
            where Id in :getUniqueIdList(paymentTxs, 'Opportunity__c')
        ]);
        
        for(Payment_Transaction__c paymentTx : paymentTxs) {
            Opportunity opty = (Opportunity) optyMap.get(paymentTx.Opportunity__c);
            if (opty != null) {
                paymentTx.OwnerId = opty.OwnerId;
            }
        }
    }
    
    public virtual Contact sendPaymentRequestEmail(Id optyId, Id roleId) {
        throw new BusinessException('This operation (sendPaymentRequestEmail) is not not supported in this implementation (PaymentServiceImpl)');
    }
    
    public virtual Contact sendRequestForAutoPaymentEmail(Id optyId, Id roleId) {
        throw new BusinessException('This operation (sendRequestForAutoPaymentEmail) is not not supported in this implementation (PaymentServiceImpl)');
    }
    
    public Dto.OptyPaymentInfo getOptyPaymentInfoForToken(String token) {
        List<Opportunity> opties = [
                Select
                    id,
                    Name,
                    Prospect_Id__c,
                    AccountId,
                    Payment_Request_Token_Status__c,
                    Payment_Request_Contact_Role_Id__c,
                    Number_of_Proposals__c,
                    (
                        select
                            Id,
                            Role,
                            ContactId,
                            Contact.Id,
                            Contact.FirstName,
                            Contact.LastName,
                            Contact.Email,
                            Contact.Phone,
                            Contact.Contact_Number__c,
                            Contact.MailingStreet,
                            Contact.MailingCity,
                            Contact.MailingState,
                            Contact.MailingPostalCode
                        from OpportunityContactRoles                        
                    )
                from Opportunity
                where Payment_Request_Token__c = :token
        ];
        if (opties.isEmpty()) {
            return null;
        }
        
        system.debug('paymentToken:'+ token);
        Dto.OptyPaymentInfo info = new Dto.OptyPaymentInfo();
        info.paymentContactRole = Sf.settingsService.getString(Constants.PaymentOptyContactRole);
        info.opty = opties.get(0);

        OpportunityContactRole role = getOptyContactRoleById(info.opty, info.opty.Payment_Request_Contact_Role_Id__c);
        if (role != null) {
            info.billingContact = role.Contact;
        }
           system.debug('paymentTokeninfo:'+ info);
        
        return info;
        
    }     
    
    /**
     * For specified Opty with corresponidng OpportunityContactRoles, method filters out the OpportunityContactRole with given
     * role and returns that contact role. If none found, then returns null.
     */
    public OpportunityContactRole getOptyContactRoleByRole(Opportunity opty, String role) {
        for (OpportunityContactRole optyRole : opty.OpportunityContactRoles) {
            if (equalsIc(optyRole.Role, role)) {
                return optyRole;
            }
        }
        
        return null;
    }

    /**
     * For specified Opty with corresponidng OpportunityContactRoles, method filters out the OpportunityContactRole with given
     * role and returns that contact role. If none found, then returns null.
     */
    public OpportunityContactRole getOptyContactRoleById(Opportunity opty, Id roleId) {
        for (OpportunityContactRole optyRole : opty.OpportunityContactRoles) {
            if (optyRole.id == roleId) {
                return optyRole;
            }
        }
        
        return null;
    }

    /**
     * For specified Opty with corresponidng OpportunityContactRoles, method filters out the OpportunityContactRole with given
     * role contact email and returns that contact role. If none found, then returns null.
     */
    public OpportunityContactRole getOptyContactRoleByEmail(Opportunity opty, String email) {
        for (OpportunityContactRole role : opty.OpportunityContactRoles) {
            if (equalsIc(role.Contact.Email, email)) {
                return role;
            }
        }
        
        return null;
    }

    /**
     * For specified Opty with corresponidng OpportunityContactRoles, method filters out the OpportunityContactRole with given
     * role contact email and returns that contact role. If none found, then returns null.
     */
    public OpportunityContactRole getOptyContactRoleByEmailAndRole(Opportunity opty, String email, String roleName) {
        for (OpportunityContactRole role : opty.OpportunityContactRoles) {
            if (equalsIc(role.Contact.Email, email) && equalsIc(role.Role, roleName)) {
                return role;
            }
        }
        
        return null;
    }

    /**
     * For specified ServiceContract with ContactRels, method filters out the ContactRel with given
     * role and contact email and returns that contact role. If none found, then returns null.
     */
    public Service_Contract_Contact_Rel__c getServiceContractContactRoleByEmailAndRole(ServiceContract serviceContract, String email, String roleName) {
        for (Service_Contract_Contact_Rel__c contact : serviceContract.Service_Contract_Contact_Rels__r) {
            if (equalsIc(contact.Contact__r.Email, email) && equalsIc(contact.Type__c, roleName)) {
                return contact;
            }
        }
        
        return null;
    }
    
    public void markOptyPaymentTokenConsumed(String token) {
        Dto.OptyPaymentInfo info = getOptyPaymentInfoForToken(token);
        if (info == null) {
            return;
        }
        
        if (!equalsIc(info.opty.Payment_Request_Token_Status__c, PaymentTokenStatus_Consumed)) {
            info.opty.Payment_Request_Token_Status__c = PaymentTokenStatus_Consumed;
            update info.opty;
        }
    }   
    
    /**
     * For given opty id, queries the basic opty details for payment processing, corresponding all contact roles and
     * contact details.
     */
    public Opportunity queryOptyForPaymentAndAllContactRoles(Id optyId) {
        List<Opportunity> opties = [
                Select
                    id,
                    Name,
                    Prospect_Id__c,
                    AccountId,
                    Number_of_Proposals__c,
                    Sales_Partner__r.Name,
                    Preferred_Language__c,
                     (
                        select
                            Id,
                            Role,
                            ContactId,
                            Contact.Id,
                            Contact.FirstName,
                            Contact.LastName,
                            Contact.Email,
                            Contact.Phone,
                            Contact.Contact_Number__c,
                            Contact.MailingStreet,
                            Contact.MailingCity,
                            Contact.MailingState,
                            Contact.MailingPostalCode
                        from OpportunityContactRoles
                        order by Contact.FirstName, Contact.LastName                    
                    )
                from Opportunity
                where Id = :optyId
        ];
        
        return opties.isEmpty()?null:opties.get(0);
    }

    /**
     * For given opty id, queries the basic service contract details, and all corresponding contact roles and contact details. Service contracts
     * are ordered by CreatedDate, with latest first.
     */
    public List<ServiceContract> queryServiceContractForPaymentAndAllContactRoles(Id optyId) {
        return [
                Select
                    id,
                    Name,
                    Opportunity__c,
                    (
                        select
                            Id,
                            Type__c,
                            Contact__c,
                            Contact__r.Id,
                            Contact__r.FirstName,
                            Contact__r.LastName,
                            Contact__r.Email,
                            Contact__r.Phone,
                            Contact__r.Contact_Number__c,
                            Contact__r.MailingStreet,
                            Contact__r.MailingCity,
                            Contact__r.MailingState,
                            Contact__r.MailingPostalCode
                           from Service_Contract_Contact_Rels__r                     
                    )
                from ServiceContract
                where Opportunity__c = :optyId
                order by CreatedDate desc
        ];
    }

    public Dto.CustomContact associatePaymentContactWithOpty(Id optyId, String paymentMode, Dto.CustomContact contactInfo) {
        debug('Querying with optyid ' + optyId);
        
        Opportunity opty = queryOptyForPaymentAndAllContactRoles(optyId);

        if (opty == null) {
            return null;
        }
        
        debug('Returned opties for contact association are ' + opty + ' ' + opty.OpportunityContactRoles);
        
        String paymentRole = null;
        if (equalsIc(paymentMode, Constants.PaymentMode_AutoPayment)) {
            paymentRole = Sf.settingsService.getString(Constants.PaymentOptyAutoPaymentContactRole);
        } else {
            paymentRole = Sf.settingsService.getString(Constants.PaymentOptyOneTimePaymentContactRole);
        }

        OpportunityContactRole role = getOptyContactRoleByEmailAndRole(opty, contactInfo.email, paymentRole);
        debug('Matched role for email is ' + role);

        Contact contact = null;
        if (role == null || !equalsIc(role.role, paymentRole)) {
            contact = new Contact();
             RecordType residentialRecordType = PRMLibrary.getResidentialContactRecordType();
            contact.RecordTypeId = residentialRecordType.Id;
            role = new OpportunityContactRole();
            role.OpportunityId = optyId;
            role.Role = paymentRole;
        } else {
            contact = role.Contact;
        }
        
        contact.FirstName = contactInfo.FirstName;
        contact.LastName = contactInfo.LastName;
        contact.Email = contactInfo.Email;
        contact.Phone = contactInfo.Phone;
        contact.MailingStreet = contactInfo.MailingStreet;
        contact.MailingCity = contactInfo.MailingCity;
        contact.MailingState = contactInfo.MailingState;
        contact.MailingPostalCode = contactInfo.MailingPostalCode;
        contact.MailingCountry = 'US';
        //adding Preferred Language
        contact.Preferred_Language__c = opty.Preferred_Language__c;
        
        if (contact.AccountId == null) {
            contact.AccountId = opty.AccountId;
        }
        
        //In Service contract trigger (trg_sc_cont_after_insert_update), they have some logic which requires
        //this field to be set to true if Role is Billing Contact. As Billing Contact role is applicable
        //only in autopayment mode, we are setting this to true.
        if (equalsIc(paymentRole, Constants.PaymentMode_AutoPayment)) {
            contact.ERP_Contact_of_Record__c = true;
        }
        
        saveObject1(contact);
        role.ContactId = contact.id;
        saveObject1(role);
        
        //Whenever we update the OpportunityContactRole, we need to replicate the contact into ServiceContractContact Rel 
        //relationship of ServiceContract, corresponding to this opportunity.
        List<ServiceContract> serviceCotracts = queryServiceContractForPaymentAndAllContactRoles(optyId);

        if (!serviceCotracts.isEmpty()) {
            
            //Returned list is sorted by created date (latest first) so pick the latest.
            ServiceContract serviceContract = serviceCotracts.get(0);

            Service_Contract_Contact_Rel__c contactRel = getServiceContractContactRoleByEmailAndRole(serviceContract, contact.Email, paymentRole);
            
            if (contactRel == null) {
                contactRel = new Service_Contract_Contact_Rel__c(
                    Type__c = paymentRole,
                    Contact__c = contact.id,
                    ServiceContract__c = serviceContract.id
                );
                
                insert contactRel;
            }
        }
        
        contactInfo.id = contact.id;
        contactInfo.contactNumber = contact.Contact_Number__c;
        
        debug('Returning the contactInfo '  +contactInfo);
        return contactInfo;
    }
    
    public void saveObject1(SObject sobj) {
        if (sobj.id == null){
            insert sobj;
        } else {
            update sobj;
        }
    }

    public Opportunity createPaymentUrl(String optyId, String paymentMode) {
        Opportunity opty = queryOptyForPaymentAndAllContactRoles(optyId);
        if (opty == null) {
            throw new BusinessException('Opportunity not found with Id ' + optyId);
        }
        
        //By default use the contact role available in the opty with role Homeowner.
        //If not, throw error.
        if (opty.OpportunityContactRoles.isEmpty()) {
            throw new BusinessException('There are no Contacts defined in the opportunity with role Homeowner');
        }

        OpportunityContactRole homeOwnerRole = null;
        for (OpportunityContactRole role : opty.OpportunityContactRoles) {
            if (role.Role == 'Homeowner') {
                homeOwnerRole = role;
                break;
            }
        }

        createPaymentUrl(opty, paymentMode, homeOwnerRole==null?null:homeOwnerRole.id, null, null);
        
        update opty;
        return opty;
    }
    
    public Opportunity createPaymentUrl(Opportunity opty, String paymentMode, String optyContactRoleId, String salesPartnerName, String languageCode) {
        
        if (salesPartnerName == null) {
            salesPartnerName = getSalesPartnerName(opty.id);
        }
        
        if (languageCode == null) {
            languageCode = getPaymentLanguageCode(opty.id);
        }

        //The payment request url would look like below
        //https://majdev-sunrun.cs9.force.com/partner/apex/{VfPage}?token={Token}&&language={preferredLanguageParam}
        String paymentRequestUrl = Sf.settingsService.getString('PaymentRequestUrl');
        String token = generateVerificationToken();
        
        Map<String, String> parms = new Map<String, String>();
        parms.put('VfPage', getPaymentPage(paymentMode, getSalesPartnerName(opty.id)));
        parms.put('Token', token);
        parms.put('Language', languageCode);
        paymentRequestUrl = replaceMergeTokens(paymentRequestUrl, parms);
        
        opty.Payment_Request_Url__c = paymentRequestUrl;
        opty.Payment_Request_Token__c = token;
        opty.Payment_Request_Token_Status__c = 'Valid';
        opty.Payment_Request_Contact_Role_Id__c =  optyContactRoleId;
        
        return opty;
    }
    
    public String getPaymentPage(String paymentMode, String salesPartnerName) {
        String paymentPageSetting = paymentMode==PaymentMode_OneTime?'PaymentBrandingOptyPaymentPage':'PaymentBrandingOptyAutoPaymentPage';
        String defaultPaymentPage = paymentMode==PaymentMode_OneTime?'CustomerOptyPayment':'CustomerOptyAutoPayment';
        
        Map<String, String> pageMap = Sf.settingsService.getStringMap(paymentPageSetting, new Map<String, String>());
        
        String vfPage = (String) firstNonNull(pageMap.get(salesPartnerName), defaultPaymentPage);
        
        return vfPage;
    }

    public String getPaymentEmailTemplate(String paymentMode, String salesPartnerName, String languageCode) {
        String emailTemplateSetting = paymentMode==PaymentMode_OneTime?'PaymentBrandingOptyPaymentEmail':'PaymentBrandingOptyAutoPaymentEmail';
        String defaultEmailTemplate;
        if (paymentMode == PaymentMode_OneTime) {
            defaultEmailTemplate = LanguageCode_Spanish == languageCode?'Request_For_Payment_SPANISH':'Request_For_Payment';
        } else {
            defaultEmailTemplate = LanguageCode_Spanish == languageCode?'Request_For_Auto_Payment_SPANISH':'Request_For_Auto_Payment';
        }
        
       	Map<String, String> emalTemplateMap = Sf.settingsService.getStringMap(emailTemplateSetting, new Map<String, String>());
        return (String) firstNonNull(emalTemplateMap.get(salesPartnerName), defaultEmailTemplate);
    }

    public String getPaymentLanguageCode(String optyId) {
        String languageCode;
        OpportunityContactRole con  = [
            select  
            ContactId,  
            contact.preferred_language__c 
            from OpportunityContactRole 
            where OpportunityId = :optyId and IsPrimary = true limit 1];
        
        if (Language_Spanish == con.Contact.preferred_language__c) {
            languageCode = LanguageCode_Spanish;
        }
        
        return (String) firstNonNull(languageCode, LanguageCode_English);
    }

    public String getSalesPartnerName(Id optyId) {
        Opportunity opty = [select id, (select Partner_Name__r.Name from Partner_Roles__r where Role__c = 'Sales') from Opportunity where id = :optyId limit 1];
        if (!opty.Partner_Roles__r.isEmpty()) {
            return opty.Partner_Roles__r.get(0).Partner_Name__r.Name;
        }
        
        return null;
    }
}