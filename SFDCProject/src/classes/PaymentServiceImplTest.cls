@IsTest
public with sharing class PaymentServiceImplTest {
    public static BaseClass utils = new BaseClass();
    public static PaymentServiceImpl paymentServiceImpl = new PaymentServiceImpl ();

    testmethod static void testSavePaymentResponse() {
        Opportunity opty = new Opportunity();
        opty.name = 'Test Opty';
        opty.StageName = 'New';
        opty.AccountId = BaseClassTest.createTestAccount().id;
        insert opty;
    
        Dto.PaymentResponse paymentResponse = new Dto.PaymentResponse();
        paymentResponse.paymentGatewayHeader = new Dto.ResponseHeader();
        paymentResponse.header = new Dto.ResponseHeader();
        paymentResponse.paymentAuth = new Dto.PaymentAuth();
        paymentResponse.paymentTransaction = new Dto.PaymentTransaction();
        paymentResponse.billingAddress = new Dto.Address();
        paymentResponse.billingContact = new Dto.CustomContact();
        
        paymentResponse.paymentGatewayHeader.status = 'accept';
        paymentResponse.paymentGatewayHeader.statusMessage = 'Request Processed';
        paymentResponse.paymentGatewayHeader.statusCode = '100';
        paymentResponse.paymentTransaction.paymentType = 'card';
        paymentResponse.paymentTransaction.transactionType = 'authorization';
        paymentResponse.paymentTransaction.transactionReferenceNum = '1234567890';
        paymentResponse.paymentTransaction.transactionId = '1234567890987654321';
        paymentResponse.paymentTransaction.paymentToken = 'abcdef';
        paymentResponse.paymentTransaction.amount = 10987.00;
        paymentResponse.paymentTransaction.paymentGatewayReferenceNum = '123';
        paymentResponse.paymentTransaction.paymentGatewayTransactionId = '765';
        paymentResponse.paymentAuth.profileId = 'profile';
        paymentResponse.paymentAuth.accessKey = '22laifafoiu23kjsdf';
        paymentResponse.paymentAuth.signedDateTime = utils.parseAsUtcIsoDateTime('2014-01-01T12:30:45Z');
        paymentResponse.paymentAuth.invalidFieldNames = 'card_number';
        paymentResponse.billingAddress.street = '150 Spear St';
        paymentResponse.billingAddress.city = 'San Francisco';
        paymentResponse.billingAddress.state = 'CA';
        paymentResponse.billingAddress.postalCode = '90001';
        paymentResponse.billingContact.FirstName = 'John';
        paymentResponse.billingContact.LastName = 'Doe';
        paymentResponse.billingContact.Email = 'john.doe@yopmail.com';
        
        Map<Integer, String> customParams = new Map<Integer, String>();
        customParams.put(1, '{"opportunityId":"' + opty.id + '"}');
        paymentResponse.customParams = customParams;
        paymentResponse.decodedCustomParams = (Dto.PaymentCustomParameters) JSON.deserialize(customParams.get(1), Dto.PaymentCustomParameters.class);
        paymentResponse.paymentPageUrl = 'https://force.salesforce.com';
        
        Payment_Transaction__c tx = Sf.paymentService.savePaymentResponse(paymentResponse);
        
        System.assertEquals('accept', tx.Status__c);
        System.assertEquals('Request Processed', tx.Status_Message__c);
        System.assertEquals('100', tx.Status_Code__c);
        System.assertEquals('card', tx.Payment_Type__c);
        System.assertEquals('authorization', tx.Transaction_Type__c);
        System.assertEquals('1234567890', tx.Reference_Num__c);
        System.assertEquals('1234567890987654321', tx.Transaction_Id__c);
        System.assertEquals('abcdef', tx.Payment_Token__c);
        System.assertEquals(10987.00, tx.Amount__c);
        System.assertEquals('123', tx.Payment_Gateway_Reference_Num__c);
        System.assertEquals('765', tx.Payment_Gateway_Transaction_Id__c);
        System.assertEquals('profile', tx.Profile_Id__c);
        System.assertEquals('22laifafoiu23kjsdf', tx.Access_Key__c);
        System.assertEquals(utils.parseAsUtcIsoDateTime('2014-01-01T12:30:45Z'), tx.Transaction_DateTime__c);
        System.assertEquals('card_number', tx.Invalid_Field_Names__c);
        System.assertEquals('150 Spear St', tx.Street__c);
        System.assertEquals('San Francisco', tx.City__c);
        System.assertEquals('CA', tx.State__c);
        System.assertEquals('90001', tx.Postal_Code__c);
        System.assertEquals('John', tx.First_Name__c);
        System.assertEquals('Doe', tx.Last_Name__c);
        System.assertEquals('john.doe@yopmail.com', tx.Email__c);
        System.assertEquals('{"1":"{\\"opportunityId\\":\\"' + opty.id + '\\"}"}', tx.Custom_Parameters__c);
        System.assertEquals('https://force.salesforce.com', tx.Payment_Page_Url__c);
        System.assertEquals(opty.id, tx.Opportunity__c);
        System.assertEquals(null, [select Payment_Mode__c from Opportunity where id = :opty.id].Payment_Mode__c);
        
        //Test for recurring transaction
        paymentResponse.paymentTransaction.transactionType = 'create_payment_token';
        
        tx = Sf.paymentService.savePaymentResponse(paymentResponse);
        System.assertEquals('Recurring', [select Payment_Mode__c from Opportunity where id = :opty.id].Payment_Mode__c);
        
    }
    
    testmethod static void testPreparePaymentRequest() {
        
        Dto.PaymentRequest paymentRequest = createPaymentRequest();
        
        //Custom parameters are not tested yet as we need to change the way are managing the custom data.
        //Currently we are using 1 secure data with json object, we need to chanage to individual parameters
        
        Dto.PreparedPaymentRequest preparedRequest = Sf.paymentService.preparePaymentRequest(paymentRequest);
        Map<String, String> params = preparedRequest.params;
        
        System.assertEquals('https://testsecureacceptance.cybersource.com/silent/pay', preparedRequest.paymentServiceFormPostUrl);
        System.assertEquals('c8dafd5e2af334bf9680df2c2cc6275c', params.get('access_key'));
        System.assertEquals('partner', params.get('profile_id'));
        System.assert(params.get('transaction_uuid') != null);
        System.assertEquals('2014-01-01T05:30:45Z', params.get('signed_date_time'));
        System.assert(params.get('reference_number') != null);
        System.assertEquals('en', params.get('locale'));
        System.assertEquals('WEB', params.get('echeck_sec_code'));
        System.assertEquals('authorization', params.get('transaction_type'));
        System.assertEquals('USD', params.get('currency'));
        System.assertEquals('100.65', params.get('amount'));
        System.assertEquals('card', params.get('payment_method'));
        System.assertEquals('John', params.get('bill_to_forename'));
        System.assertEquals('Doe', params.get('bill_to_surname'));
        System.assertEquals('john.doe@yopmail.com', params.get('bill_to_email'));
        System.assertEquals('111-222-3333', params.get('bill_to_phone'));
        System.assertEquals('150 Spear St', params.get('bill_to_address_line1'));
        System.assertEquals('San Francisco', params.get('bill_to_address_city'));
        System.assertEquals('CA', params.get('bill_to_address_state'));
        System.assertEquals('US', params.get('bill_to_address_country'));
        System.assertEquals('90001', params.get('bill_to_address_postal_code'));
        System.assertEquals('https://force.salesforce.com', params.get('override_custom_receipt_page'));
        System.assertEquals('card_type,card_number,card_cvn,card_expiry_date', params.get('unsigned_field_names'));
        System.assertEquals('access_key,profile_id,transaction_uuid,signed_date_time,locale,echeck_sec_code,transaction_type,currency,amount,payment_method,bill_to_forename,bill_to_surname,bill_to_email,bill_to_phone,bill_to_address_line1,bill_to_address_city,bill_to_address_state,bill_to_address_country,bill_to_address_postal_code,override_custom_receipt_page,reference_number,unsigned_field_names,signed_field_names', params.get('signed_field_names'));

        //Because we are using fixed date time and values, it should always produce the same signature.
        System.assertEquals('YpQ0CrBDdWEHMSbup9qhp1HQPPrGjrbYDO5woV75Vac=', params.get('signature'));
        
        //Test echeck trans.
        paymentRequest.paymentTransaction.paymentType = 'echeck';
        preparedRequest = Sf.paymentService.preparePaymentRequest(paymentRequest);
        params = preparedRequest.params;
        
        System.assertEquals('https://testsecureacceptance.cybersource.com/silent/pay', preparedRequest.paymentServiceFormPostUrl);
        System.assertEquals('c8dafd5e2af334bf9680df2c2cc6275c', params.get('access_key'));
        System.assertEquals('partner', params.get('profile_id'));
        System.assert(params.get('transaction_uuid') != null);
        System.assertEquals('2014-01-01T05:30:45Z', params.get('signed_date_time'));
        System.assert(params.get('reference_number') != null);
        System.assertEquals('en', params.get('locale'));
        System.assertEquals('WEB', params.get('echeck_sec_code'));
        System.assertEquals('authorization', params.get('transaction_type'));
        System.assertEquals('USD', params.get('currency'));
        System.assertEquals('100.65', params.get('amount'));
        System.assertEquals('echeck', params.get('payment_method'));
        System.assertEquals('John', params.get('bill_to_forename'));
        System.assertEquals('Doe', params.get('bill_to_surname'));
        System.assertEquals('john.doe@yopmail.com', params.get('bill_to_email'));
        System.assertEquals('111-222-3333', params.get('bill_to_phone'));
        System.assertEquals('150 Spear St', params.get('bill_to_address_line1'));
        System.assertEquals('San Francisco', params.get('bill_to_address_city'));
        System.assertEquals('CA', params.get('bill_to_address_state'));
        System.assertEquals('US', params.get('bill_to_address_country'));
        System.assertEquals('90001', params.get('bill_to_address_postal_code'));
        System.assertEquals('https://force.salesforce.com', params.get('override_custom_receipt_page'));
        System.assertEquals('echeck_account_type,echeck_routing_number,echeck_account_number', params.get('unsigned_field_names'));
        System.assertEquals('access_key,profile_id,transaction_uuid,signed_date_time,locale,echeck_sec_code,transaction_type,currency,amount,payment_method,bill_to_forename,bill_to_surname,bill_to_email,bill_to_phone,bill_to_address_line1,bill_to_address_city,bill_to_address_state,bill_to_address_country,bill_to_address_postal_code,override_custom_receipt_page,reference_number,unsigned_field_names,signed_field_names', params.get('signed_field_names'));

        //Because we are using fixed date time and values, it should always produce the same signature.
        System.assertEquals('DYePermbM3I4HXQd+7vO2dyHw4Hf6SCSr3yAchTqq7s=', params.get('signature'));
        
        //Test with amount more than 1000
        paymentRequest.paymentTransaction.amount = 10870.97;
                
        preparedRequest = Sf.paymentService.preparePaymentRequest(paymentRequest);
        System.assertEquals('10870.97', preparedRequest.params.get('amount'));
   } 
    
    
    public static Dto.PaymentRequest createPaymentRequest() {
        
        insertPaymentRelatedSettings();

        BaseClass.testCurrentDateTime = utils.parseAsUtcIsoDateTime('2014-01-01T05:30:45Z');
        BaseClass.testParams.put('transaction_uuid', '8537016866902116768');
        BaseClass.testParams.put('reference_number', '1795339710775428165');

        //Testing Credit card authorization
        Dto.PaymentRequest paymentRequest = new Dto.PaymentRequest();
        paymentRequest.paymentTransaction = new Dto.PaymentTransaction();
        paymentRequest.paymentTransaction.transactionType = 'authorization';
        paymentRequest.paymentTransaction.paymentType = 'card';
        paymentRequest.paymentTransaction.amount = 100.65;

        paymentRequest.billingContact = new Dto.CustomContact();
        paymentRequest.billingContact.firstName = 'John';
        paymentRequest.billingContact.lastName = 'Doe';
        paymentRequest.billingContact.email = 'john.doe@yopmail.com';
        paymentRequest.billingContact.phone = '111-222-3333';
        
        paymentRequest.billingAddress = new Dto.Address();
        paymentRequest.billingAddress.street = '150 Spear St';
        paymentRequest.billingAddress.city = 'San Francisco';
        paymentRequest.billingAddress.state = 'CA';
        paymentRequest.billingAddress.country = 'US';
        paymentRequest.billingAddress.postalCode = '90001';
        
        paymentRequest.currentPageUrl = 'https://force.salesforce.com';
        
        return paymentRequest;    
    }
    
    testmethod static void testValidatePaymentResponse() {
        
        Map<String, String> responseParams = new Map<String, String>();
        responseParams.put('decision', '');
        responseParams.put('reason_code', '');
        responseParams.put('message', '');
        responseParams.put('req_bill_to_forename', '');
        responseParams.put('req_bill_to_surname', '');
        responseParams.put('req_bill_to_email', '');
        responseParams.put('req_bill_to_phone', '');
        responseParams.put('req_bill_to_address_line1', '');
        responseParams.put('req_bill_to_address_city', '');
        responseParams.put('req_bill_to_address_state', '');
        responseParams.put('req_bill_to_address_postal_code', '');
        responseParams.put('req_bill_to_address_country', '');
        responseParams.put('auth_amount', '');
        responseParams.put('req_amount', '');
        responseParams.put('req_currency', '');
        responseParams.put('req_reference_number', '');
        responseParams.put('req_transaction_uuid', '');
        responseParams.put('transaction_id', '');
        responseParams.put('auth_trans_ref_no', '');
        responseParams.put('payment_token', '');
        responseParams.put('signed_date_time', '');
        responseParams.put('req_profile_id', '');
        responseParams.put('req_access_key', '');
        responseParams.put('req_override_custom_receipt_page', '');
        responseParams.put('req_card_type', '');
        responseParams.put('req_card_expiry_date', '');
        responseParams.put('req_echeck_account_type', '');
        responseParams.put('req_merchant_secure_data', '');

        //Test card authorization
        responseParams.put('req_payment_method', 'card');
        responseParams.put('req_transaction_type', 'authorization');
    }
    
    
    testmethod static void testChangeOwnerToOptyOwner() {
        
        Profile pfl = [select id from profile where name='Standard User'];
        User user = new User(alias = 'u1', email='payment-user@sunrun.com.test',
            emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
            localesidkey='en_US', profileid = pfl.Id,  country='United States', CommunityNickname = 'u1',
            timezonesidkey='America/Los_Angeles', username='payment-user@sunrun.com.test');
        insert user;                    
                
        Opportunity opty = new Opportunity();
        opty.name = 'Test Opty';
        opty.StageName = 'New';
        opty.OwnerId = user.id;
        opty.AccountId = BaseClassTest.createTestAccount().id;
        
        insert opty;
        
        //If opty is set, then ownerid must be same as opty ownerid.
        Payment_Transaction__c tx = new Payment_Transaction__c();
        tx.Opportunity__c = opty.id;
        tx.ownerId = UserInfo.getUserId();
        
        Sf.paymentService.changeOwnerToOptyOwner(new Payment_Transaction__c[]{tx});
        System.assertEquals(opty.OwnerId, tx.OwnerId);
        
        //If opty is not set, then ownerid is not changed.
        tx = new Payment_Transaction__c();
        tx.ownerId = UserInfo.getUserId();
        
        Sf.paymentService.changeOwnerToOptyOwner(new Payment_Transaction__c[]{tx});
        System.assertEquals(UserInfo.getUserId(), tx.OwnerId);
    }
    
    /*
    testmethod static void testGetOptyPaymentInfo() {
        try {
            Sf.paymentService.getOptyPaymentInfo('id');
            System.assert(false, 'Expecting an exception');
        } catch (Exception e) {}
    }

    testmethod static void testsendPaymentRequestEmail() {
        try {
            Sf.paymentService.sendPaymentRequestEmail('id');
            System.assert(false, 'Expecting an exception');
        } catch (Exception e) {}
    }

    testmethod static void testsendRequestForAutoPaymentEmail() {
        try {
            Sf.paymentService.sendRequestForAutoPaymentEmail('id');
            System.assert(false, 'Expecting an exception');
        } catch (Exception e) {}
    }
    */
    
    testmethod static void testGetOpryContactRoleandOthers() {
        Opportunity opty = new Opportunity();
        opty.name = 'Test Opty';
        opty.StageName = 'New';
        opty.OwnerId = UserInfo.getUserId();
        opty.AccountId = BaseClassTest.createTestAccount().id;
        
        insert opty;
        
        Contact contact = BaseClassTest.createTestContact('john.doe1@yopmail.com', BaseClassTest.createTestAccount());

        Contact contact2 = BaseClassTest.createTestContact('john.doe2@yopmail.com', BaseClassTest.createTestAccount());

        Contact contact3 = BaseClassTest.createTestContact('john.doe3@yopmail.com', BaseClassTest.createTestAccount());
        
        Proposal__c prop = new Proposal__c(Opportunity__c =opty.Id,System_Size_STC_DC__c=5.85,Upfront_Payment__c = 1200,Mode_Name__c='Sunrun - REC - CSI',Name ='PKRDC1439VC1-H',Sales_Rep_Email__c ='abc@gmail.com',Date_Issued__c = system.today());
        insert prop;
    
        OpportunityContactRole role = new OpportunityContactRole(OpportunityId=opty.Id, ContactId=contact.id, Role='Role1');     
        insert role;
        
        role = new OpportunityContactRole(OpportunityId=opty.Id, ContactId=contact2.id, Role='Role2');       
        insert role;

        role = new OpportunityContactRole(OpportunityId=opty.Id, ContactId=contact3.id, Role='Role3');       
        insert role;
        
    
        Opportunity opty2 = paymentServiceImpl.queryOptyForPaymentAndAllContactRoles(opty.id);
        System.assertEquals(3, opty2.OpportunityContactRoles.size());
        system.assertEquals(1,opty2.Number_of_Proposals__c);
                
        PaymentServiceImpl impl = new PaymentServiceImpl();
        
        OpportunityContactRole roleNew = impl.getOptyContactRoleByEmailAndRole(opty2, 'john.doe1@yopmail.com', 'Role1');
        System.assertEquals('Role1', roleNew.Role);
        System.assertEquals('john.doe1@yopmail.com', roleNew.Contact.Email);
        
        roleNew = impl.getOptyContactRoleByEmail(opty2, 'john.doe2@yopmail.com');
        System.assertEquals('Role2', roleNew.Role);
        System.assertEquals('john.doe2@yopmail.com', roleNew.Contact.Email);
        
        roleNew = impl.getOptyContactRoleByRole(opty2, 'Role3');
        System.assertEquals('Role3', roleNew.Role);
        System.assertEquals('john.doe3@yopmail.com', roleNew.Contact.Email);
    }
    
    
    testmethod static void testGetServiceContractContactRoleandOthers() {
    
        //Querying with wrong opty id, should return empty list.
        System.assert(paymentServiceImpl.queryServiceContractForPaymentAndAllContactRoles('810g00000009V5X').isEmpty());
        
        Opportunity opty = new Opportunity();
        opty.name = 'Test Opty';
        opty.StageName = 'New';
        opty.OwnerId = UserInfo.getUserId();
        opty.AccountId = BaseClassTest.createTestAccount().id;
        
        insert opty;

        ServiceContract contract = new ServiceContract(name='Test First', Agreement_Number__c='Ag1', Opportunity__c=opty.id);
        insert contract;
        
        Contact contact = BaseClassTest.createTestContact('john.doe1@yopmail.com', BaseClassTest.createTestAccount());

        insert new Service_Contract_Contact_Rel__c (Type__c='Role1', Contact__c=contact.id, ServiceContract__c=contract.id);
        insert new Service_Contract_Contact_Rel__c (Type__c='Role2', Contact__c=contact.id, ServiceContract__c=contract.id);
        insert new Service_Contract_Contact_Rel__c (Type__c='Role3', Contact__c=contact.id, ServiceContract__c=contract.id);
        
        //We need to test to make sure two service contracts returned in the reverse order of created date. To test it,
        //we will simulate a second delay and insert second contract. Then will query and test.        
        utils.sleep(1000);
        
        ServiceContract contract2 = new ServiceContract(name='Test Second', Agreement_Number__c='Ag2', Opportunity__c=opty.id);
        insert contract2;

        List<ServiceContract> serviceContracts = paymentServiceImpl.queryServiceContractForPaymentAndAllContactRoles(opty.id);
        System.assertEquals(2, serviceContracts.size());
        System.assertEquals('Test Second', serviceContracts.get(0).name);
        System.assertEquals('Test First', serviceContracts.get(1).name);
        System.assertEquals(3, serviceContracts.get(1).Service_Contract_Contact_Rels__r.size());
        
        System.assert(paymentServiceImpl.getServiceContractContactRoleByEmailAndRole(serviceContracts.get(1), 'john.doe1@yopmail.com', 'Role1') != null);
        System.assert(paymentServiceImpl.getServiceContractContactRoleByEmailAndRole(serviceContracts.get(1), 'john.doe2@yopmail.com', 'Role1') == null);
    }
    
    testmethod static void testAssociatePaymentContactWithOpty() {
        
        Opportunity opty = new Opportunity();
        opty.name = 'Test Opty';
        opty.StageName = 'New';
        opty.OwnerId = UserInfo.getUserId();
        Opty.AccountId = BaseClassTest.createTestAccount().id;
        insert opty;
        
        Proposal__c prop = new Proposal__c(Opportunity__c =opty.Id,System_Size_STC_DC__c=5.85,Upfront_Payment__c = 1200,Mode_Name__c='Sunrun - REC - CSI',Name ='PKRDC1439VC1-H',Sales_Rep_Email__c ='abc@gmail.com',Date_Issued__c = system.today());
        insert prop;
        
        ServiceContract contract = new ServiceContract(name='Test First', Agreement_Number__c='Ag1', Opportunity__c=opty.id);
        insert contract;
        
        insertSetting('PaymentOptyOneTimePaymentContactRole', 'OneTimePaymentRole');
        insertSetting('PaymentOptyAutoPaymentContactRole', 'AutoPaymentRole');
        
        Dto.CustomContact contact = new Dto.CustomContact();
        contact.FirstName = 'John';
        contact.lastName = 'Doe';
        contact.email = 'john.doe@yopmail.com';
        
        //When we associate contact to an opty which has no contacts, it should create contact and associate with opty
        //in this role
        contact = paymentServiceImpl.associatePaymentContactWithOpty(opty.id, 'onetime-payment', contact);
        System.assert(contact.id != null);
        
        opty = paymentServiceImpl.queryOptyForPaymentAndAllContactRoles(opty.id);
        System.assertEquals(contact.id, opty.OpportunityContactRoles.get(0).ContactId);
        System.assertEquals('john.doe@yopmail.com', opty.OpportunityContactRoles.get(0).Contact.Email);
        System.assertEquals('OneTimePaymentRole', opty.OpportunityContactRoles.get(0).Role);
        system.assertEquals(1,opty.Number_of_Proposals__c);
        
        //It should also associate the same contact with service contract in that role        
        List<ServiceContract> contracts = paymentServiceImpl.queryServiceContractForPaymentAndAllContactRoles(opty.id);
        System.assertEquals(contact.id, contracts.get(0).Service_Contract_Contact_Rels__r.get(0).Contact__c);
        System.assertEquals('john.doe@yopmail.com', contracts.get(0).Service_Contract_Contact_Rels__r.get(0).Contact__r.Email);
        System.assertEquals('OneTimePaymentRole', contracts.get(0).Service_Contract_Contact_Rels__r.get(0).Type__c);

        //Same thing but with different payment role.
        
        opty = new Opportunity();
        opty.name = 'Test Opty2';
        opty.StageName = 'New';
        opty.OwnerId = UserInfo.getUserId();
        opty.AccountId = BaseClassTest.createTestAccount().id;
        
        insert opty;

        contract = new ServiceContract(name='Test First2', Agreement_Number__c='Ag1', Opportunity__c=opty.id);
        insert contract;

        contact = new Dto.CustomContact();
        contact.FirstName = 'Moon';
        contact.lastName = 'Rock';
        contact.email = 'moon.rock@yopmail.com';
        
        contact = paymentServiceImpl.associatePaymentContactWithOpty(opty.id, 'auto-payment', contact);
        System.assert(contact.id != null);
        
        opty = paymentServiceImpl.queryOptyForPaymentAndAllContactRoles(opty.id);
        System.assertEquals(contact.id, opty.OpportunityContactRoles.get(0).ContactId);
        System.assertEquals('moon.rock@yopmail.com', opty.OpportunityContactRoles.get(0).Contact.Email);        
        System.assertEquals('AutoPaymentRole', opty.OpportunityContactRoles.get(0).Role);
        
        contracts = paymentServiceImpl.queryServiceContractForPaymentAndAllContactRoles(opty.id);
        System.assertEquals(contact.id, contracts.get(0).Service_Contract_Contact_Rels__r.get(0).Contact__c);
        System.assertEquals('moon.rock@yopmail.com', contracts.get(0).Service_Contract_Contact_Rels__r.get(0).Contact__r.Email);
        System.assertEquals('AutoPaymentRole', contracts.get(0).Service_Contract_Contact_Rels__r.get(0).Type__c);
        
    }
    
    testmethod static void getOptyPaymentInfoForToken() {
        
        //Will insert a opty with some token. Will query for that opty using that token and check the values.
        insertSetting('PaymentOptyContactRole', 'Homeowner');

        Opportunity opty = new Opportunity();
        opty.name = 'Test Opty2';
        opty.StageName = 'New';
        opty.OwnerId = UserInfo.getUserId();
        opty.Payment_Request_Token__c = 'Token';
        opty.AccountId = BaseClassTest.createTestAccount().id;
        insert opty;
        
        Contact contact1 = BaseClassTest.createTestContact('john.doe1@yopmail.com', BaseClassTest.createTestAccount());

        OpportunityContactRole role1 = new OpportunityContactRole(OpportunityId=opty.Id, ContactId=contact1.id, Role='Homeowner');     
        insert role1;
   
        Contact contact2 = BaseClassTest.createTestContact('john.doe2@yopmail.com', BaseClassTest.createTestAccount());
    
        OpportunityContactRole role2 = new OpportunityContactRole(OpportunityId=opty.Id, ContactId=contact2.id, Role='SomeOtherRole');     
        insert role2;
        
        System.assertEquals(null, Sf.paymentService.getOptyPaymentInfoForToken('TokenNotExists'));
         
        Dto.OptyPaymentInfo optyInfo = Sf.paymentService.getOptyPaymentInfoForToken('Token');
        System.assertNotEquals(null, optyInfo);
        System.assertEquals(opty.id, optyInfo.opty.id);
        System.assertEquals(null, optyInfo.billingContact);
        
        System.assertEquals(true, optyInfo.opty.Payment_Request_Token_Status__c == 'Invalid' || optyInfo.opty.Payment_Request_Token_Status__c == null);
                        
        //We should have fetched opty info with Homeowner role
        opty.Payment_Request_Contact_Role_Id__c = role2.id;
        update opty;

        optyInfo = Sf.paymentService.getOptyPaymentInfoForToken('Token');
        System.assertEquals('john.doe2@yopmail.com', optyInfo.billingContact.email);
        
   }
   
   testmethod static void markOptyPaymentTokenConsumed() {
   
        //Will insert a opty with some token. Will query for that opty using that token and check the values.
        insertSetting('PaymentOptyContactRole', 'Homeowner');

        Opportunity opty = new Opportunity();
        opty.name = 'Test Opty2';
        opty.StageName = 'New';
        opty.Payment_Request_Token__c = 'Token';
        insert opty;
        
        //test that non-existing token has no impact
        Sf.paymentService.markOptyPaymentTokenConsumed('NonExistingToken');
        
        //Now update the actual opty
        Dto.OptyPaymentInfo optyInfo = Sf.paymentService.getOptyPaymentInfoForToken('Token');
        System.assertEquals(true, optyInfo.opty.Payment_Request_Token_Status__c == 'Invalid' || optyInfo.opty.Payment_Request_Token_Status__c == null);

        Sf.paymentService.markOptyPaymentTokenConsumed('Token');
        
        //Test that status reads it as Consumed
        optyInfo = Sf.paymentService.getOptyPaymentInfoForToken('Token');
        System.assertEquals('Consumed', optyInfo.opty.Payment_Request_Token_Status__c);
    }
    
    
    testmethod static void validatePaymentResponse() {
    
        insertPaymentRelatedSettings();
    
        Map<String, String> params = new Map<String, String>();
        params.put('req_bill_to_address_country', 'US');
        params.put('req_bill_to_phone', '111-222-3333');
        params.put('decision', 'ACCEPT');
        params.put('req_bill_to_address_state', 'CA');
        params.put('signed_field_names', 'transaction_id,decision,req_access_key,req_profile_id,req_transaction_uuid,req_transaction_type,req_reference_number,req_amount,req_currency,req_locale,req_payment_method,req_override_custom_receipt_page,req_merchant_secure_data4,req_bill_to_forename,req_bill_to_surname,req_bill_to_email,req_bill_to_phone,req_bill_to_address_line1,req_bill_to_address_city,req_bill_to_address_state,req_bill_to_address_country,req_bill_to_address_postal_code,req_echeck_account_number,req_echeck_routing_number,req_echeck_account_type,req_echeck_sec_code,message,reason_code,echeck_debit_ref_no,echeck_debit_submit_time,signed_field_names,signed_date_time');
        params.put('req_payment_method', 'echeck');
        params.put('req_transaction_type', 'authorization');
        params.put('req_echeck_account_type', 'C');
        params.put('signature', 'HKRy0OtnzZlh7h/oMwq8UB2kVHGU6y+cW4efN2DV6HU=');
        params.put('req_locale', 'en');
        params.put('reason_code', '100');
        params.put('req_bill_to_address_postal_code', '94105');
        params.put('req_echeck_account_number', 'xxxxx0439');
        params.put('req_bill_to_address_line1', '1 Main St');
        params.put('req_echeck_sec_code', 'WEB');
        params.put('req_bill_to_address_city', 'San Francisco');
        params.put('signed_date_time', '2014-06-24T23:24:29Z');
        params.put('req_currency', 'USD');
        params.put('req_reference_number', '619251595490749350');
        params.put('req_merchant_secure_data4', '{"opportunityId":"006g0000004FHHwAAO","prospectId":"1765523408","contactId":"003g000000GFkgsAAD"}');
        params.put('req_echeck_routing_number', 'xxxxx0439');
        params.put('transaction_id', '4036522676730176195663');
        params.put('req_amount', '500.00');
        params.put('message', 'Request was processed successfully.');
        params.put('echeck_debit_ref_no', '02WWNTOGHWTEVNI5');
        params.put('req_profile_id', 'partner');
        params.put('req_transaction_uuid', '4764704643802877453');
        params.put('echeck_debit_submit_time', '2014-06-24T232428Z');
        params.put('req_bill_to_surname', 'Ivan');
        params.put('req_bill_to_forename', 'Mara');
        params.put('req_bill_to_email', 'mivan@sunrunhome.com');
        params.put('req_override_custom_receipt_page', 'https://c.cs17.visual.force.com/apex/CallcenterOptyPayment?id=006g0000004FHHwAAO');
        params.put('req_access_key', 'c8dafd5e2af334bf9680df2c2cc6275c');
        
        Dto.paymentResponse resp = Sf.paymentService.validatePaymentResponse(params);
        System.assertEquals('success', resp.header.status);
        
        //Change something and it should fail.
        params.put('req_amount', '600.00');
        
        resp = Sf.paymentService.validatePaymentResponse(params);
        System.assertEquals('error', resp.header.status);
    }
 
    public static void insertPaymentRelatedSettings() {
    
        insertSetting('CybersourceDepAccessKey', '639c33b6ecbe3eec925681b44c3d38ee');
        insertSetting('CybersourceDepSecretKeyPart1', '0a6db04ed09749a498849dafd1f68a9f80772bb1d9a045e8b56e35379b1ad8382c127afc54254fb1a2b26b37bed95a6dbddc');
        insertSetting('CybersourceDepSecretKeyPart2', '8e128f264e47b63542d484d93f2482ad4b97e5a64f6d8752702fcbe2097d73dfa7e9f0154248906f5233087412cc4752be855b3541fe940e9ac867cb6408d425395a2d9b45c297c385f92f9037c6');
        insertSetting('CybersourceDepProfileId', 'ppccard');
        
        insertSetting('CybersourceAchAccessKey', 'c8dafd5e2af334bf9680df2c2cc6275c');
        insertSetting('CybersourceAchSecretKeyPart1', 'ee23dc66e8914d299ba4b6b852c04494503e2d21b8e2413eb79f5c77d8279de7e5398569d04f4bf39266c621ed907ee72954');
        insertSetting('CybersourceAchSecretKeyPart2', '68f197cc4a07b22988863c98b238f6b8889dd3cc4dbba09c59931db207512b96b86272de4decaa0529cc394155985c20a00f546744f1ba8ded5fdfb1fc4c1e0c4d9df8d9406ca73038f344fce6ab');
        insertSetting('CybersourceAchProfileId', 'partner');
        insertSetting('CybersourceFormPostUrl', 'https://testsecureacceptance.cybersource.com/silent/pay');
    
    }
        
    static void insertSetting(String key, String value) {
        Settings__c setting = new Settings__c(Name=key, Value1__c=value);
        insert setting;
    }
 
    
}