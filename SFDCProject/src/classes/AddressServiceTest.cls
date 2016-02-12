@IsTest
public class AddressServiceTest {
    
    public static BaseClass utils = new BaseClass();
    public static AddressServiceImpl impl = new AddressServiceImpl();
	public static String MickeyAccountName = Sf.settingsService.getString('AddressServiceTestMickeyLabel', 'Comcast');
    
    testmethod public static void testLeadsStandardization_part1() {
        
        //First we will handle the leads trigger handling and how its status is updated depending on the input.
        insertSettings();
        Sf.settingsService.setString('AddressStandardizationForLeadsEnabled', 'false');
        Sf.settingsService.setString('AddressStandardizationForAcctsEnabled', 'false');
		
        //This is requried to make sure we insert the leads successfully. Some trigger fails if this record is not there.
        Promotion__c promotion = new Promotion__c(Name='Test1', Start_Date__c=Date.Today(), End_Date__c=Date.Today(), Promotion_Type__c='Customer');
        insert promotion;
        promotion.Promotion_Code__c= 'CUS27298';
        update promotion;
		
		//This is required to succesfully create the lead.
        insert new Account(Name=MickeyAccountName); //Workaround to refer to value of System.label.Mickey_Account
        
        //When lead created, when address is updated, it must be set to Standardization Required.
        Lead lead = new Lead(Company='Test Lead', LastName='Test', FirstName='Test');
        insert lead;
        lead = (Lead) utils.queryAllFields('Lead', lead.id);
		System.assertEquals('Standardization Required', lead.Address_Standardization_Status__c);
        
        //Let's set the status as Standardized for a min and update its address. Status should set it back to Standardization Required
        lead.Street = '480 Fell St Apt 3';
        lead.City = 'San Francisco';
        lead.State = 'ca';
        lead.PostalCode = '94102';
        lead.Address_Standardization_Status__c = 'Standardized';
        
		AddressServiceImpl.recordsProcessedMap.clear();
        update lead;
        
        lead = (Lead) utils.queryAllFields('Lead', lead.id);
		System.assertEquals('Standardization Required', lead.Address_Standardization_Status__c);
		
        //If you change a case on the address, it should mark it as standardization required.
        lead.City = 'san francisco';
        lead.Address_Standardization_Status__c = 'Standardized';
		
        AddressServiceImpl.recordsProcessedMap.clear();
        update lead;
        
        lead = (Lead) utils.queryAllFields('Lead', lead.id);
		System.assertEquals('Standardization Required', lead.Address_Standardization_Status__c);
        
        //If lead's standardization in progress is set to true, then status should be left as is.
        lead.Address_Standardization_Status__c = 'Standardized';

        AddressServiceImpl.recordsProcessedMap.clear();
        update lead;
        
        lead = (Lead) utils.queryAllFields('Lead', lead.id);
		System.assertEquals('Standardized', lead.Address_Standardization_Status__c);
    }
	
    //Test was waiting with too many soqls as we were updating the lead quite a bit and hence
    //had to split into two parts.
    testmethod public static void testLeadsStandardization_part2() {
        
        //First we will handle the leads trigger handling and how its status is updated depending on the input.
        insertSettings();
        Sf.settingsService.setString('AddressStandardizationForLeadsEnabled', 'false');
        Sf.settingsService.setString('AddressStandardizationForAcctsEnabled', 'false');
		
        //This is requried to make sure we insert the leads successfully. Some trigger fails if this record is not there.
        Promotion__c promotion = new Promotion__c(Name='Test1', Start_Date__c=Date.Today(), End_Date__c=Date.Today(), Promotion_Type__c='Customer');
        insert promotion;
        promotion.Promotion_Code__c= 'CUS27298';
        update promotion;
		
		//This is required to succesfully create the lead.
        insert new Account(Name=MickeyAccountName);
        Lead lead = new Lead(Company='Test Lead', LastName='Test', FirstName='Test');

        AddressServiceImpl.recordsProcessedMap.clear();
        insert lead;

        //If lead's status is Standardized by UI or Details Required, then status should be left as is.
        lead.Address_Standardization_Status__c = 'Standardized by UI';

        AddressServiceImpl.recordsProcessedMap.clear();
        update lead;
        
        lead = (Lead) utils.queryAllFields('Lead', lead.id);
		System.assertEquals('Standardized by UI', lead.Address_Standardization_Status__c);

        lead.Address_Standardization_Status__c = 'Details Required';

        AddressServiceImpl.recordsProcessedMap.clear();
        update lead;
        
        lead = (Lead) utils.queryAllFields('Lead', lead.id);
		System.assertEquals('Details Required', lead.Address_Standardization_Status__c);

        //If nothing changed in lead address but install branch is updated, then status should be set to Driving Details to be Calculated
        Account account1 = new Account(Name='Sunrun');
		insert account1;
        
        Account account = new Account(Name='Doe', RecordTypeId=utils.getRecordTypeId('Account', 'Branch'), ParentId=account1.id);
        insert account;
        
        lead.Install_Branch_Id__c = account.id;

        AddressServiceImpl.recordsProcessedMap.clear();
        update lead;
        
        lead = (Lead) utils.queryAllFields('Lead', lead.id);
        System.assertEquals('Driving Details to be Calculated', lead.Address_Driving_Details_Status__c);
    }

    //In this method we will actually run the lead through full standardization process.
    testmethod public static void testLeadsStandardization_part3() {
        insertSettings();
        Sf.settingsService.setString('AddressStandardizationForLeadsEnabled', 'false');
        Sf.settingsService.setString('AddressStandardizationForAcctsEnabled', 'false');

        BaseClass.testCurrentDateTime = DateTime.now();
		
        //Case 2: Happy path to standardize using google maps, get timezone from timezone and get additional details from cdyne
        //	Geocode api
        //	Timezone api
        //	Cdyne api
        FlexibleCalloutMock flexiMock = new FlexibleCalloutMock();
        flexiMock.ifUrlContainsReturnResource('geocode', 'AddressServiceTestRespGeocodeSuccess');
        flexiMock.ifUrlContainsReturnResource('timezone', 'AddressServiceTestRespTimezoneSuccess');
        flexiMock.ifUrlContainsReturnResource('distancematrix', 'AddressServiceTestRespDistanceSuccess');
        flexiMock.ifUrlContainsReturnResource('VerifyAddressAdvanced', 'AddressServiceTestRespCDyneSuccess');
        Test.setMock(HttpCalloutMock.class, flexiMock);

        //This is requried to make sure we insert the leads successfully. Some trigger fails if this record is not there.
        Promotion__c promotion = new Promotion__c(Name='Test1', Start_Date__c=Date.Today(), End_Date__c=Date.Today(), Promotion_Type__c='Customer');
        insert promotion;
        promotion.Promotion_Code__c= 'CUS27298';
        update promotion;
		
		//This is required to succesfully create the lead.
        insert new Account(Name=MickeyAccountName);
        
        //If nothing changed in lead address but install branch is updated, then status should be set to Driving Details to be Calculated
        Account account1 = new Account(Name='Sunrun');
		insert account1;
        
        Account account = new Account(Name='Doe', RecordTypeId=utils.getRecordTypeId('Account', 'Branch'), ParentId=account1.id, 
                                      BillingStreet='180 Diamond St', BillingCity='San+Francisco', BillingState='CA', BillingPostalCode='94114');
        insert account;
        
        BaseClass.testParams.put('Install_Branch_Id__c', String.valueOf(account.id));

		Lead lead = new Lead(Company='Test Lead', LastName='Test', FirstName='Test', Street='480 Fell St Apt 3', 
                             City='San Francisco', State='CA', PostalCode='94102', Install_Branch_Id__c = account.id,
                            Install_Partner__c=System.Label.Sunrun_Inc_Id);
        insert lead;

        Sf.settingsService.setString('AddressStandardizationForLeadsEnabled', 'true');
        Sf.settingsService.setString('AddressStandardizationForAcctsEnabled', 'true');
        Test.startTest();
		
        new AddressServiceImpl().standardizeLeadsAddress(new String[]{lead.id});
        
		Test.stopTest();
        
        lead = (Lead) utils.queryAllFields('Lead', lead.id);
        System.assertEquals('Standardized', lead.Address_Standardization_Status__c);
        System.assertEquals('Google Maps', lead.Address_Standardization_Source__c);
        System.assertEquals('USA:CA:SAN FRANCISCO:FELL ST:480:3:94102', lead.Address_Token__c);
        System.assertEquals('480 Fell St #3, San Francisco, CA, 94102', lead.Cdyne_Address__c);
        System.assertEquals('480 Fell St #3', lead.Street);
        System.assertEquals('San Francisco', lead.city);
        System.assertEquals('94102', lead.postalCode);
        System.assertEquals('CA', lead.state);
        System.assertEquals('USA', lead.country);
        System.assertEquals('San Francisco', lead.county__c);
        System.assertEquals(37.7758309, lead.latitude__c);
        System.assertEquals(-122.425776, lead.longitude__c);
        System.assertEquals('12', lead.CongressDistrictNumber__c);
        System.assertEquals('017', lead.StateLegislativeLower__c);
        System.assertEquals('011', lead.StateLegislativeUpper__c);
        System.assertEquals('415', lead.areaCode__c);
        System.assertEquals('PST', lead.timeZone__c);
        System.assertEquals('true', lead.HasDaylightSavings__c);
    }
    
    testmethod public static void testAccountsStandardization() {
        
        //First we will handle the leads trigger handling and how its status is updated depending on the input.
        insertSettings();
        Sf.settingsService.setString('AddressStandardizationForLeadsEnabled', 'false');
        Sf.settingsService.setString('AddressStandardizationForAcctsEnabled', 'false');
		
        //When account created, when address is updated, it must be set to Standardization Required.
        Account account = new Account(Name='Test');
        insert account;
        account = (Account) utils.queryAllFields('Account', account.id);
		System.assertEquals('Standardization Required', account.Address_Standardization_Status__c);
        
        //Let's set the status as Standardized for a min and update its address. Status should set it back to Standardization Required
        account.BillingStreet = '480 Fell St Apt 3';
        account.BillingCity = 'San Francisco';
        account.BillingState = 'ca';
        account.BillingPostalCode = '94102';
        account.Address_Standardization_Status__c = 'Standardized';
        
        AddressServiceImpl.recordsProcessedMap.clear();
        update account;
        
        account = (Account) utils.queryAllFields('Account', account.id);
		System.assertEquals('Standardization Required', account.Address_Standardization_Status__c);
		
        //If you change a case on the address, it should mark it as standardization required.
        account.BillingCity = 'san francisco';
        account.Address_Standardization_Status__c = 'Standardized';

        AddressServiceImpl.recordsProcessedMap.clear();
        update account;
        
        account = (Account) utils.queryAllFields('Account', account.id);
		System.assertEquals('Standardization Required', account.Address_Standardization_Status__c);
        
        //If lead's standardization in progress is set to true, then status should be left as is.
        account.Address_Standardization_Status__c = 'Standardized';

        AddressServiceImpl.recordsProcessedMap.clear();
        update account;
        
        account = (Account) utils.queryAllFields('Account', account.id);
		System.assertEquals('Standardized', account.Address_Standardization_Status__c);

        //If lead's status is Standardized by UI or Details Required, then status should be left as is.
        account.Address_Standardization_Status__c = 'Standardized by UI';

        AddressServiceImpl.recordsProcessedMap.clear();
        update account;
        
        account = (Account) utils.queryAllFields('Account', account.id);
		System.assertEquals('Standardized by UI', account.Address_Standardization_Status__c);

        account.Address_Standardization_Status__c = 'Details Required';

        AddressServiceImpl.recordsProcessedMap.clear();
        update account;
        
        account = (Account) utils.queryAllFields('Account', account.id);
		System.assertEquals('Details Required', account.Address_Standardization_Status__c);
    }
    
    //In this test case we will run the account through full run and check its values.
    testmethod public static void testAccountsStandardization_Part2() {
        insertSettings();
        Sf.settingsService.setString('AddressStandardizationForLeadsEnabled', 'false');
        Sf.settingsService.setString('AddressStandardizationForAcctsEnabled', 'false');

        BaseClass.testCurrentDateTime = DateTime.now();
		
        //Case 2: Happy path to standardize using google maps, get timezone from timezone and get additional details from cdyne
        //	Geocode api
        //	Timezone api
        //	Cdyne api
        FlexibleCalloutMock flexiMock = new FlexibleCalloutMock();
        flexiMock.ifUrlContainsReturnResource('geocode', 'AddressServiceTestRespGeocodeSuccess');
        flexiMock.ifUrlContainsReturnResource('timezone', 'AddressServiceTestRespTimezoneSuccess');
        flexiMock.ifUrlContainsReturnResource('VerifyAddressAdvanced', 'AddressServiceTestRespCDyneSuccess');
        Test.setMock(HttpCalloutMock.class, flexiMock);
        
		Account account = new Account(Name='Test', core_logic_override__c = true, BillingStreet='480 Fell St Apt 3', BillingCity='San Francisco', BillingState='CA', BillingPostalCode='94102');        
        insert account;
        Sf.settingsService.setString('AddressStandardizationForLeadsEnabled', 'true');
        Sf.settingsService.setString('AddressStandardizationForAcctsEnabled', 'true');

        Test.startTest();
		
        new AddressServiceImpl().standardizeAccountsAddress(new String[]{account.id});
        
		Test.stopTest();
        
        account = (Account) utils.queryAllFields('Account', account.id);
        
        System.assertEquals('Standardized', account.Address_Standardization_Status__c);
        System.assertEquals('Google Maps', account.Address_Standardization_Source__c);
        System.assertEquals('USA:CA:SAN FRANCISCO:FELL ST:480:3:94102', account.Address_Token__c);
        System.assertEquals('480 Fell St #3, San Francisco, CA, 94102', account.Cdyne_Address__c);
        System.assertEquals('480 Fell St #3', account.BillingStreet);
        System.assertEquals('San Francisco', account.Billingcity);
        System.assertEquals('94102', account.BillingpostalCode);
        System.assertEquals('CA', account.Billingstate);
        System.assertEquals('USA', account.Billingcountry);
        System.assertEquals('San Francisco', account.county__c);
        System.assertEquals(37.7758309, account.latitude__c);
        System.assertEquals(-122.425776, account.longitude__c);
        System.assertEquals('12', account.CongressDistrictNumber__c);
        System.assertEquals('017', account.StateLegislativeLower__c);
        System.assertEquals('011', account.StateLegislativeUpper__c);
        System.assertEquals('415', account.areaCode__c);
        System.assertEquals('PST', account.timeZone__c);
        System.assertEquals('true', account.HasDaylightSavings__c);

    }
    
    testmethod public static void testStandardizeAddress() {
		
        insertSettings();
        
        //Case 1
		//Test to check it returns error if at least city and state is not populated.
		AddressServiceDto.Address address = new AddressServiceDto.Address();
		AddressServiceDto.StandardizeAddressResponse response = impl.standardizeAddress(address);
        System.assertEquals('Standardization Missing Address', response.status);
		
        //Even if city state is empty response, it is same error.
        address.city = '';
        address.state = '  ';
		response = impl.standardizeAddress(address);
        System.assertEquals('Standardization Missing Address', response.status);
        
        BaseClass.testCurrentDateTime = DateTime.now();
		
        //Case 2: Happy path to standardize using google maps, get timezone from timezone and get additional details from cdyne
        //	Geocode api
        //	Timezone api
        //	Cdyne api
        FlexibleCalloutMock flexiMock = new FlexibleCalloutMock();
        flexiMock.ifUrlContainsReturnResource('geocode', 'AddressServiceTestRespGeocodeSuccess');
        flexiMock.ifUrlContainsReturnResource('timezone', 'AddressServiceTestRespTimezoneSuccess');
        flexiMock.ifUrlContainsReturnResource('VerifyAddressAdvanced', 'AddressServiceTestRespCDyneSuccess');
        Test.setMock(HttpCalloutMock.class, flexiMock);
        
        Test.startTest();
        AddressServiceDto.StandardizeAddressResponse resp = impl.standardizeAddress(new AddressServiceDto.Address('480 Fell St Apt 3', 'San Francisco', 'CA', '94102'));
        Test.stopTest();

        System.assertEquals('Standardized', resp.status);
        System.assertEquals('Google Maps', resp.source);
        System.assertEquals('USA:CA:SAN FRANCISCO:FELL ST:480:3:94102', resp.address.addressToken);
        System.assertEquals('480 Fell St #3', resp.address.street);
        System.assertEquals('San Francisco', resp.address.city);
        System.assertEquals('94102', resp.address.postalCode);
        System.assertEquals('CA', resp.address.state);
        System.assertEquals('USA', resp.address.country);
        System.assertEquals('San Francisco', resp.address.county);
        System.assertEquals(37.7758309, resp.addressAdditionalInfo.latitude);
        System.assertEquals(-122.425776, resp.addressAdditionalInfo.longitude);
        System.assertEquals('12', resp.addressAdditionalInfo.congressionalDistrictNumber);
        System.assertEquals('017', resp.addressAdditionalInfo.stateLegislativeLower);
        System.assertEquals('011', resp.addressAdditionalInfo.stateLegislativeUpper);
        System.assertEquals('415', resp.addressAdditionalInfo.areaCode);
        System.assertEquals('PST', resp.addressAdditionalInfo.timeZone);
        System.assertEquals(true, resp.addressAdditionalInfo.hasDaylightSavings);
    }

    testmethod public static void testStandardizeAddressWithCDyneSecondary() {
		
        insertSettings();
        AddressServiceImpl.AddressStandardizationCDyneSecondary = true;
        
        BaseClass.testCurrentDateTime = DateTime.now();
		
        //Case 2: Happy path to standardize using google maps, get timezone from timezone and get additional details from cdyne
        //	Geocode api
        //	Timezone api
        //	Cdyne api
        FlexibleCalloutMock flexiMock = new FlexibleCalloutMock();
        flexiMock.ifUrlContainsReturnResource('geocode', 'AddressServiceTestRespGeocodeZeroResults');
        flexiMock.ifUrlContainsReturnResource('VerifyAddressAdvanced', 'AddressServiceTestRespCDyneSuccess');
        Test.setMock(HttpCalloutMock.class, flexiMock);
        
        Test.startTest();
        AddressServiceDto.StandardizeAddressResponse resp = impl.standardizeAddress(new AddressServiceDto.Address('150 Spear St', 'San Francisco', 'CA', '94102'));
        Test.stopTest();

        System.assertEquals('Standardized', resp.status);
        System.assertEquals('CDyne', resp.source);
        
        System.assertEquals('USA:CA:SAN FRANCISCO:SPEAR ST:150:94102', resp.address.addressToken);
        System.assertEquals('150 Spear St', resp.address.street);
        System.assertEquals('San Francisco', resp.address.city);
        System.assertEquals('94102-5037', resp.address.postalCode);
        System.assertEquals('CA', resp.address.state);
        System.assertEquals('USA', resp.address.country);
        System.assertEquals('San Francisco', resp.address.county);
        System.assertEquals(37.7756325, resp.addressAdditionalInfo.latitude);
        System.assertEquals(-122.425252, resp.addressAdditionalInfo.longitude);
        System.assertEquals('12', resp.addressAdditionalInfo.congressionalDistrictNumber);
        System.assertEquals('017', resp.addressAdditionalInfo.stateLegislativeLower);
        System.assertEquals('011', resp.addressAdditionalInfo.stateLegislativeUpper);
        System.assertEquals('415', resp.addressAdditionalInfo.areaCode);
        System.assertEquals('PST', resp.addressAdditionalInfo.timeZone);
        System.assertEquals(true, resp.addressAdditionalInfo.hasDaylightSavings);
    }
    
    //Tests parsing various responses conditions from geocode api
    testmethod public static void testParseGoogleGeocodeResponse() {
        AddressServiceDto.StandardizeAddressResponse response = null;
        response = new AddressServiceImpl().parseGoogleGeocodeResponse('{"status": "ZERO_RESULTS"}', new AddressServiceDto.StandardizeAddressResponse());
        System.assertEquals('Standardization No Match', response.status);

        response = new AddressServiceImpl().parseGoogleGeocodeResponse('{"status": "REQUEST_DENIED"}', new AddressServiceDto.StandardizeAddressResponse());
        System.assertEquals('Standardization Error', response.status);

        response = new AddressServiceImpl().parseGoogleGeocodeResponse('{"status": "OVER_QUERY_LIMIT"}', new AddressServiceDto.StandardizeAddressResponse());
        System.assertEquals('Standardization Error', response.status);

        response = new AddressServiceImpl().parseGoogleGeocodeResponse('{"status": "UNKNOWN_ERROR"}', new AddressServiceDto.StandardizeAddressResponse());
        System.assertEquals('Standardization Error', response.status);

        response = new AddressServiceImpl().parseGoogleGeocodeResponse('{"status": "INVALID_REQUEST"}', new AddressServiceDto.StandardizeAddressResponse());
        System.assertEquals('Standardization Missing Address', response.status);
    }
    
    testmethod static void testCreateAddressToken() {
        System.assertEquals('', impl.createAddressToken(new AddressServiceDto.Address(null, null, null, null, null)));
        System.assertEquals('94903', impl.createAddressToken(new AddressServiceDto.Address(null, null, null, '94903', null)));
        System.assertEquals('94903', impl.createAddressToken(new AddressServiceDto.Address(null, null, null, '94903-1234', null)));
        System.assertEquals('USA:94903', impl.createAddressToken(new AddressServiceDto.Address(null, null, null, '94903', 'USA')));
        System.assertEquals('USA:CA:94903', impl.createAddressToken(new AddressServiceDto.Address(null, null, 'ca', '94903', 'USA')));
        System.assertEquals('USA:CA:SPEAR ST', impl.createAddressToken(new AddressServiceDto.Address('Spear St', null, 'ca', null, 'USA')));
        System.assertEquals('USA:CA:SAN FRANCISCO:SPEAR ST:94903', impl.createAddressToken(new AddressServiceDto.Address('Spear St', 'san francisco', 'ca', '94903', 'USA')));
        System.assertEquals('USA:CA:SAN FRANCISCO:SPEAR ST:150:94903', impl.createAddressToken(new AddressServiceDto.Address('150 Spear St', 'san francisco', 'ca', '94903', 'USA')));
        System.assertEquals('USA:CA:SAN FRANCISCO:SPEAR ST:150:A654:94903', impl.createAddressToken(new AddressServiceDto.Address('150 Spear St #a654', 'san francisco', 'ca', '94903', 'USA')));
        System.assertEquals('USA:CA:SAN FRANCISCO:SPEAR ST:150:A654:94903', impl.createAddressToken(new AddressServiceDto.Address('150 Spear St #a654', 'san francisco', 'ca', '94903-1112', 'USA')));
    }

    testmethod public static void normalizeAddressComponent() {
        System.assertEquals('', impl.normalizeAddressComponent(null));
        System.assertEquals('', impl.normalizeAddressComponent(''));
        System.assertEquals('', impl.normalizeAddressComponent(' '));
        System.assertEquals('', impl.normalizeAddressComponent('\t'));
        System.assertEquals('', impl.normalizeAddressComponent('      '));
        System.assertEquals('US', impl.normalizeAddressComponent('us'));
        System.assertEquals('SAN FRANCISCO', impl.normalizeAddressComponent('     san      francisco     '));
    }
    
    testmethod public static void addressSeparator() {
        System.assertEquals('', impl.addressSeparator(null));
        System.assertEquals('', impl.addressSeparator(' '));
        System.assertEquals('', impl.addressSeparator('\t'));
        System.assertEquals(':', impl.addressSeparator('US'));
        System.assertEquals(':', impl.addressSeparator('us'));
    }
    
    testmethod public static void normalizeCountry() {
        System.assertEquals('USA', impl.normalizeCountry(null));
        System.assertEquals('USA', impl.normalizeCountry(''));
        System.assertEquals('USA', impl.normalizeCountry('  '));
        System.assertEquals('USA', impl.normalizeCountry('USA'));
        System.assertEquals('USA', impl.normalizeCountry('usa'));
        System.assertEquals('USA', impl.normalizeCountry('us'));
        System.assertEquals('India', impl.normalizeCountry('India'));
        System.assertEquals('india', impl.normalizeCountry('india'));
    }
    
    
    testmethod static void testCreateAddressString() {
        System.assertEquals('', impl.createAddressString(new AddressServiceDto.Address()));
		System.assertEquals('150 Spear St', impl.createAddressString(new AddressServiceDto.Address('150 Spear St', null, null, null, null)));
		System.assertEquals('USA', impl.createAddressString(new AddressServiceDto.Address(null, null, null, null, 'USA')));
        System.assertEquals('150 Spear St, USA', impl.createAddressString(new AddressServiceDto.Address('150 Spear St', null, null, null, 'USA')));
		System.assertEquals('150 Spear St, San Francisco, USA', impl.createAddressString(new AddressServiceDto.Address('150 Spear St', 'San Francisco', null, null, 'USA')));
        System.assertEquals('150 Spear St, San Francisco, CA, 94901, USA', impl.createAddressString(new AddressServiceDto.Address('150 Spear St', 'San Francisco', 'CA', '94901', 'USA')));
    }
    
    testmethod static void testIsAddressUpdated() {
        AddressServiceDto.Address addr1 = new AddressServiceDto.Address('150 Spear St', 'San Francisco', 'CA', '94901', 'USA');
        System.assertEquals(false, impl.isAddressUpdated(addr1, new AddressServiceDto.Address('150 Spear St', 'San Francisco', 'CA', '94901', 'USA')));
        System.assertEquals(true, impl.isAddressUpdated(addr1, new AddressServiceDto.Address('150 Spear st', 'San Francisco', 'CA', '94901', 'USA')));
        System.assertEquals(true, impl.isAddressUpdated(addr1, new AddressServiceDto.Address('150 Spear St', 'san francisco', 'CA', '94901', 'USA')));
        System.assertEquals(true, impl.isAddressUpdated(addr1, new AddressServiceDto.Address('150 Spear St', 'San Francisco', 'ca', '94901', 'USA')));
        System.assertEquals(true, impl.isAddressUpdated(addr1, new AddressServiceDto.Address('150 Spear St', 'San Francisco', 'CA', '94902', 'USA')));
        System.assertEquals(true, impl.isAddressUpdated(addr1, new AddressServiceDto.Address('150 Spear St', 'San Francisco', 'CA', '94901', 'usa')));
        
        Lead lead1 = new Lead(Street='150 Spear St', City='San Francisco', State='CA', PostalCode='94901', Country='USA');
        System.assertEquals(false, impl.isAddressUpdated(lead1, new Lead(Street='150 Spear St', City='San Francisco', State='CA', PostalCode='94901', Country='USA')));
        System.assertEquals(true, impl.isAddressUpdated(lead1, new Lead(Street='150 Spear st', City='San Francisco', State='CA', PostalCode='94901', Country='USA')));
        System.assertEquals(true, impl.isAddressUpdated(lead1, new Lead(Street='150 Spear St', City='san francisco', State='CA', PostalCode='94901', Country='USA')));
        System.assertEquals(true, impl.isAddressUpdated(lead1, new Lead(Street='150 Spear St', City='San Francisco', State='ca', PostalCode='94901', Country='USA')));
        System.assertEquals(true, impl.isAddressUpdated(lead1, new Lead(Street='150 Spear St', City='San Francisco', State='CA', PostalCode='94902', Country='USA')));
        System.assertEquals(true, impl.isAddressUpdated(lead1, new Lead(Street='150 Spear St', City='San Francisco', State='CA', PostalCode='94901', Country='usa')));
        
        Account account = new Account(BillingStreet='150 Spear St', BillingCity='San Francisco', BillingState='CA', BillingPostalCode='94901', BillingCountry='USA');
        System.assertEquals(false, impl.isAddressUpdated(account, new Account(BillingStreet='150 Spear St', BillingCity='San Francisco', BillingState='CA', BillingPostalCode='94901', BillingCountry='USA')));
        System.assertEquals(true, impl.isAddressUpdated(account, new Account(BillingStreet='150 Spear st', BillingCity='San Francisco', BillingState='CA', BillingPostalCode='94901', BillingCountry='USA')));
        System.assertEquals(true, impl.isAddressUpdated(account, new Account(BillingStreet='150 Spear St', BillingCity='san francisco', BillingState='CA', BillingPostalCode='94901', BillingCountry='USA')));
        System.assertEquals(true, impl.isAddressUpdated(account, new Account(BillingStreet='150 Spear St', BillingCity='San Francisco', BillingState='ca', BillingPostalCode='94901', BillingCountry='USA')));
        System.assertEquals(true, impl.isAddressUpdated(account, new Account(BillingStreet='150 Spear St', BillingCity='San Francisco', BillingState='CA', BillingPostalCode='94902', BillingCountry='USA')));
        System.assertEquals(true, impl.isAddressUpdated(account, new Account(BillingStreet='150 Spear St', BillingCity='San Francisco', BillingState='CA', BillingPostalCode='94901', BillingCountry='usa')));
    }
    
    testmethod public static void testSchedulerAccounts()  {
        
        //We are just testing if scheduling and deleting the jobs would work out fine.
        insertSettings();
        
        //Create few leads, accounts with various statuses so that it will be picked up by the batch job.
        //All of these records address status shoudl be set to error or something.
        Sf.settingsService.setString('AddressStandardizationForLeadsEnabled', 'false');
        Sf.settingsService.setString('AddressStandardizationForAcctsEnabled', 'false');
        
		//Setup data. 
		//
		//We need to update the requried address status while updating becuase during insert, the status is overridden to Standardization Required
        Account account1 = new Account(Name='Test', BillingStreet='150 Spear St', BillingCity='San Francisco');
        insert account1;
        account1.Address_Standardization_Status__c = 'Standardization Error';
        update account1;
        
        Account account2 = new Account(Name='Test', BillingStreet='150 Spear St', BillingCity='San Francisco');
        insert account2;
        account2.Address_Standardization_Status__c = 'Standardization Required';
        update account2;

        Account account3 = new Account(Name='Test', BillingStreet='150 Spear St', BillingCity='San Francisco');
        insert account3;
        account3.Address_Standardization_Status__c = 'Standardized by UI';
        update account3;
        
        Account account4 = new Account(Name='Test', BillingStreet='150 Spear St', BillingCity='San Francisco');
        insert account4;
        account4.Address_Standardization_Status__c = 'Details Required';
        update account4;
        
        Sf.settingsService.setString('AddressStandardizationForLeadsEnabled', 'true');
        Sf.settingsService.setString('AddressStandardizationForAcctsEnabled', 'true');
        
        Test.startTest();
			new AddressStandardizationScheduler().execute(null);
        Test.stopTest();
        
        //Now for all account lead records, address status must be set to error.
        //
        //We are just checking if batch jobs are picking the accounts and leads with predefined address status
        //and running through the standardization process. None of these will succeed, becuase we havne't setup 
        //any mocks for outbound calls.
		System.assertEquals('Standardization Error', utils.queryAccount(account1.id).Address_Standardization_Status__c);
        System.assertEquals('Standardization Error', utils.queryAccount(account2.id).Address_Standardization_Status__c);
        System.assertEquals('Standardization Error', utils.queryAccount(account3.id).Address_Standardization_Status__c);
        System.assertEquals('Standardization Error', utils.queryAccount(account4.id).Address_Standardization_Status__c);
    }

    testmethod public static void testSchedulerLeads()  {
        
        //We are just testing if scheduling and deleting the jobs would work out fine.
        insertSettings();
        
        //Create few leads, accounts with various statuses so that it will be picked up by the batch job.
        //All of these records address status shoudl be set to error or something.
        Sf.settingsService.setString('AddressStandardizationForLeadsEnabled', 'false');
        Sf.settingsService.setString('AddressStandardizationForAcctsEnabled', 'false');
        
		//Setup data. 
		//
		//We need to update the requried address status while updating becuase during insert, the status is overridden to Standardization Required
        //This is requried to make sure we insert the leads successfully. Some trigger fails if this record is not there.
        Promotion__c promotion = new Promotion__c(Name='Test1', Start_Date__c=Date.Today(), End_Date__c=Date.Today(), Promotion_Type__c='Customer');
        insert promotion;
        promotion.Promotion_Code__c= 'CUS27298';
        update promotion;
		
		//This is required to succesfully create the lead.
        insert new Account(Name=MickeyAccountName);
        
        //When lead created, when address is updated, it must be set to Standardization Required.
        Lead lead1 = new Lead(Company='Test Lead', LastName='Test', FirstName='Test', Street='150 Spear St', City='San Francisco');
        insert lead1;
        lead1.Address_Standardization_Status__c = 'Standardized by UI';
        update lead1;

        Lead lead2 = new Lead(Company='Test Lead', LastName='Test', FirstName='Test', Street='150 Spear St', City='San Francisco');
        insert lead2;
        lead2.Address_Standardization_Status__c = 'Standardization Required';
        update lead2;
        
        Sf.settingsService.setString('AddressStandardizationForLeadsEnabled', 'true');
        Sf.settingsService.setString('AddressStandardizationForAcctsEnabled', 'true');
        
        Test.startTest();
			new AddressStandardizationScheduler().execute(null);
        Test.stopTest();
        
        //Now for all account lead records, address status must be set to error.
        //
        //We are just checking if batch jobs are picking the accounts and leads with predefined address status
        //and running through the standardization process. None of these will succeed, becuase we havne't setup 
        //any mocks for outbound calls.
		System.assertEquals('Standardization Error', utils.queryLead(lead1.id).Address_Standardization_Status__c);
        System.assertEquals('Standardization Error', utils.queryLead(lead2.id).Address_Standardization_Status__c);
    }

    //We are getting too many soql error while creating test data. So we will split some lead
    //scenarios into separate method.
    testmethod public static void testSchedulerLeads_Part2()  {
        
        //We are just testing if scheduling and deleting the jobs would work out fine.
        insertSettings();
        
        //Create few leads, accounts with various statuses so that it will be picked up by the batch job.
        //All of these records address status shoudl be set to error or something.
        Sf.settingsService.setString('AddressStandardizationForLeadsEnabled', 'false');
        Sf.settingsService.setString('AddressStandardizationForAcctsEnabled', 'false');
        
		//Setup data. 
		//
		//We need to update the requried address status while updating becuase during insert, the status is overridden to Standardization Required
        //This is requried to make sure we insert the leads successfully. Some trigger fails if this record is not there.
        Promotion__c promotion = new Promotion__c(Name='Test1', Start_Date__c=Date.Today(), End_Date__c=Date.Today(), Promotion_Type__c='Customer');
        insert promotion;
        promotion.Promotion_Code__c= 'CUS27298';
        update promotion;
		
		//This is required to succesfully create the lead.
        insert new Account(Name=MickeyAccountName);
        
        //When lead created, when address is updated, it must be set to Standardization Required.
        Lead lead3 = new Lead(Company='Test Lead', LastName='Test', FirstName='Test', Street='150 Spear St', City='San Francisco');
        insert lead3;
        lead3.Address_Standardization_Status__c = 'Standardized by UI';
        update lead3;
        
        Lead lead4 = new Lead(Company='Test Lead', LastName='Test', FirstName='Test', Street='150 Spear St', City='San Francisco');
        insert lead4;
        lead4.Address_Standardization_Status__c = 'Details Required';
        update lead4;
        
        Sf.settingsService.setString('AddressStandardizationForLeadsEnabled', 'true');
        Sf.settingsService.setString('AddressStandardizationForAcctsEnabled', 'true');
        
        Test.startTest();
			new AddressStandardizationScheduler().execute(null);
        Test.stopTest();
        
        //Now for all account lead records, address status must be set to error.
        //
        //We are just checking if batch jobs are picking the accounts and leads with predefined address status
        //and running through the standardization process. None of these will succeed, becuase we havne't setup 
        //any mocks for outbound calls.
        System.assertEquals('Standardization Error', utils.queryLead(lead3.id).Address_Standardization_Status__c);
        System.assertEquals('Standardization Error', utils.queryLead(lead4.id).Address_Standardization_Status__c);
    }    
 
 testmethod public static void testCopyStandardizationResponseToSObject() {
	AddressServiceDto.CdyneResponse cdyne = new AddressServiceDto.CdyneResponse();
	cdyne.responseMessage = 'CDyne Message';
	cdyne.ReturnCode = 100;
	cdyne.PrimaryDeliveryLine = '150 Spear St';
	cdyne.CityName = 'San Francisco';
	cdyne.StateAbbreviation = 'CA';
	cdyne.ZipCode = '94901';
	cdyne.Country = 'USA';
	cdyne.County = 'San Francisco';
	cdyne.legislativeInfo = new AddressServiceDto.CdyneLegislativeInfo();
	cdyne.legislativeInfo.CongressionalDistrictNumber = '10';
	cdyne.legislativeInfo.StateLegislativeUpper = '20';
	cdyne.legislativeInfo.StateLegislativeLower = '30';
	cdyne.geoLocationInfo = new AddressServiceDto.CdyneGeoLocationInfo();
	cdyne.geoLocationInfo.AreaCode = '415';
	cdyne.geoLocationInfo.TimeZone = 'PST';
	cdyne.geoLocationInfo.HasDaylightSavings = true;
	cdyne.geoLocationInfo.AvgLatitude = 37.123;
	cdyne.geoLocationInfo.AvgLongitude = -122.123;
	AddressServiceDto.StandardizeAddressResponse resp = new AddressServiceDto.StandardizeAddressResponse(cdyne);
	resp.status = 'Standardized';
	resp.googleMapsMessage = 'Google Maps Message';
	resp.source = 'Google Maps';
	resp.address.addressToken = 'USA:CA:SAN FRANCISCO:SPEAR ST:150';
    
	Account account = new Account();
	new AddressServiceImpl().copyStandardizationResponseToSObject(resp, account);
    System.assertEquals('Google Maps', account.Address_Standardization_Source__c);
    System.assertEquals('CDyne Message', account.Address_Standardization_Cdyne_Message__c);
    System.assertEquals('Google Maps Message', account.Address_Standardization_Google_Message__c);
    System.assertEquals(37.123, account.Latitude__c);
    System.assertEquals(-122.123, account.Longitude__c);
    System.assertEquals('PST', account.TimeZone__c);
    System.assertEquals('415', account.AreaCode__c);
    System.assertEquals('true', account.HasDaylightSavings__c);
    System.assertEquals('10', account.CongressDistrictNumber__c);
    System.assertEquals('20', account.StateLegislativeUpper__c);
    System.assertEquals('30', account.StateLegislativeLower__c);
    System.assertEquals('USA:CA:SAN FRANCISCO:SPEAR ST:150', account.Address_Token__c);
    System.assertEquals('San Francisco', account.County__c);

    Lead lead = new Lead();
	new AddressServiceImpl().copyStandardizationResponseToSObject(resp, lead);
    System.assertEquals('Google Maps', lead.Address_Standardization_Source__c);
    System.assertEquals('CDyne Message', lead.Address_Standardization_Cdyne_Message__c);
    System.assertEquals('Google Maps Message', lead.Address_Standardization_Google_Message__c);
    System.assertEquals(37.123, lead.Latitude__c);
    System.assertEquals(-122.123, lead.Longitude__c);
    System.assertEquals('PST', lead.TimeZone__c);
    System.assertEquals('415', lead.AreaCode__c);
    System.assertEquals('true', lead.HasDaylightSavings__c);
    System.assertEquals('10', lead.CongressDistrictNumber__c);
    System.assertEquals('20', lead.StateLegislativeUpper__c);
    System.assertEquals('30', lead.StateLegislativeLower__c);
    System.assertEquals('USA:CA:SAN FRANCISCO:SPEAR ST:150', lead.Address_Token__c);
    System.assertEquals('San Francisco', lead.County__c);
    
    //If address status is Standardized by UI, then we will not copy the latlng
    resp.addressAdditionalInfo.latitude = 38.123;
    resp.addressAdditionalInfo.longitude = -123.123;
    
    account.Address_Standardization_Status__c = 'Standardized by UI';
	new AddressServiceImpl().copyStandardizationResponseToSObject(resp, account);
    System.assertEquals(37.123, account.Latitude__c);
    System.assertEquals(-122.123, account.Longitude__c);
    
    lead.Address_Standardization_Status__c = 'Standardized by UI';
	new AddressServiceImpl().copyStandardizationResponseToSObject(resp, lead);
    System.assertEquals(37.123, lead.Latitude__c);
    System.assertEquals(-122.123, lead.Longitude__c);
}
    
   testmethod  public static void testCalculateDrivingDetails() {
        insertSettings();
        BaseClass.testCurrentDateTime = DateTime.now();
		
        Sf.settingsService.setString('AddressStandardizationForLeadsEnabled', 'false');
        Sf.settingsService.setString('AddressStandardizationForAcctsEnabled', 'false');
        
        //Case 2: Happy path to standardize using google maps, get timezone from timezone and get additional details from cdyne
        //	Geocode api
        //	Timezone api
        //	Cdyne api
        FlexibleCalloutMock flexiMock = new FlexibleCalloutMock();
        flexiMock.ifUrlContainsReturnResource('distancematrix', 'AddressServiceTestRespDistanceSuccess');
        Test.setMock(HttpCalloutMock.class, flexiMock);
		
        //If nothing changed in lead address but install branch is updated, then status should be set to Driving Details to be Calculated
        Account account1 = new Account(Name='Sunrun');
		insert account1;
        
        Account account = new Account(Name='Doe', RecordTypeId=utils.getRecordTypeId('Account', 'Branch'), ParentId=account1.id, 
                                      BillingStreet='180 Diamond St', BillingCity='San Francisco', BillingState='CA', BillingPostalCode='94114');
        insert account;

        Lead lead = new Lead();

        new AddressServiceImpl().calculateDrivingDistanceToInstallBranch(lead);
        System.assertEquals('Install Branch Missing', lead.Address_Driving_Details_Status__c);

        BaseClass.testParams.put('Install_Branch_Id__c', String.valueOf(account.id));
        BaseClass.testParams.put('Install_Branch_Id__r', account);
		
        new AddressServiceImpl().calculateDrivingDistanceToInstallBranch(lead);
        System.assertEquals('Address Missing', lead.Address_Driving_Details_Status__c);
        
        lead = new Lead(Company='Test Lead', LastName='Test', FirstName='Test', Street='480 Fell St', 
                             City='San Francisco', State='CA', PostalCode='94102', Install_Branch_Id__c = account.id,
                            Install_Partner__c=System.Label.Sunrun_Inc_Id);
		Test.startTest();
		new AddressServiceImpl().calculateDrivingDistanceToInstallBranch(lead);
        Test.stopTest();
        
        //Check for driving details calculated.
        System.assertEquals('Driving Details Calculated', lead.Address_Driving_Details_Status__c);
        System.assertEquals('1.6 mi', lead.Driving_Distance_to_Install_Branch__c);
        System.assertEquals('6 mins', lead.Driving_Time_to_Install_Branch__c);
    }
    
     
    testmethod public static void testSchedulerDeleteScheduleJobs()  {
    	AddressStandardizationScheduler.scheduleJobs();
    }

    testmethod public static void testSplitBySize() {
        List<String> values = new String[]{'', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', ''};
		System.assertEquals(1, new AddressServiceImpl().splitBySize(values, 22).size());
		System.assertEquals(1, new AddressServiceImpl().splitBySize(values, 21).size());
		System.assertEquals(2, new AddressServiceImpl().splitBySize(values, 20).size());            
		System.assertEquals(21, new AddressServiceImpl().splitBySize(values, 1).size());
		System.assertEquals(1, new AddressServiceImpl().splitBySize(values, 22).size());
		System.assertEquals(5, new AddressServiceImpl().splitBySize(values, 5).size());
    }
    
    testmethod public static void testCalculateDrivingDetailsNew() {
        insertSettings();

        String response = '{"destination_addresses" : [ "San Francisco, CA, USA", "Los Angeles, CA, USA", "" ], "origin_addresses" : [ "Dublin, CA, USA" ], "rows" : [{"elements" : [{"distance" : {"text" : "34.9 mi", "value" : 56195 }, "duration" : {"text" : "43 mins", "value" : 2580 }, "status" : "OK"}, {"distance" : {"text" : "350 mi", "value" : 563122 }, "duration" : {"text" : "5 hours 8 mins", "value" : 18484 }, "status" : "OK"}, {"status" : "NOT_FOUND"} ] } ], "status" : "OK"}';
        new FlexibleCalloutMock(200, response);
 		
        Test.startTest();
        List<AddressServiceDto.DrivingDetails> details = Sf.addressService.calculateDrivingDetails('Dublin CA', new String[]{'San Francisco CA', 'Los Angeles CA', 'CityDoesNotExist'});
        Test.stopTest();
        
        System.assertEquals('Driving Details Calculated', details.get(0).status);
        System.assertEquals('Dublin CA', details.get(0).origin);
        System.assertEquals('San Francisco CA', details.get(0).destination);
        System.assertEquals(56195, details.get(0).distance);
        System.assertEquals(2580, details.get(0).drivingTime);
        
        System.assertEquals('Driving Details Calculated', details.get(1).status);
        System.assertEquals('Dublin CA', details.get(1).origin);
        System.assertEquals('Los Angeles CA', details.get(1).destination);
        System.assertEquals(563122, details.get(1).distance);
        System.assertEquals(18484, details.get(1).drivingTime);

        System.assertEquals('Dublin CA', details.get(2).origin);
        System.assertEquals('CityDoesNotExist', details.get(2).destination);
        System.assertEquals('Driving Details No Match', details.get(2).status);
    }
    
    testmethod public static void testCalculateDrivingDetailsNewBatch() {
        insertSettings();
		Sf.settingsService.setString('GoogleDistanceMatrixApiBatchSize', '1');
        String response = '{"destination_addresses" : [ "San Francisco, CA, USA", "Los Angeles, CA, USA", "" ], "origin_addresses" : [ "Dublin, CA, USA" ], "rows" : [{"elements" : [{"distance" : {"text" : "34.9 mi", "value" : 56195 }, "duration" : {"text" : "43 mins", "value" : 2580 }, "status" : "OK"}, {"distance" : {"text" : "350 mi", "value" : 563122 }, "duration" : {"text" : "5 hours 8 mins", "value" : 18484 }, "status" : "OK"}, {"status" : "NOT_FOUND"} ] } ], "status" : "OK"}';
        new FlexibleCalloutMock(200, response);
 		
        Test.startTest();
        List<AddressServiceDto.DrivingDetails> details = Sf.addressService.calculateDrivingDetails('Dublin CA', new String[]{'San Francisco CA', 'Los Angeles CA', 'CityDoesNotExist'});
        Test.stopTest();
		
		System.assertEquals(3, details.size());        
    }

    public static void insertSettings() {
    	insert new Settings__c(Name='GoogleMapsClientId', Value1__c='12345');
        insert new Settings__c(Name='GoogleMapsClientSecretKey', Value1__c='12345');
 		//If we don't set this, it will fail with message System.UnexpectedException: No more than one executeBatch can be called from within a testmethod.  Please make sure the iterable returned from your start method matches the batch size, resulting in one executeBatch invocation.
       	insert new Settings__c(Name='AddressStandardizationLeadsBatchSize', Value1__c='20');
        insert new Settings__c(Name='AddressStandardizationAcctsBatchSize', Value1__c='20');
    	insert new Settings__c(Name='AddressStandardizationForLeadsEnabled', Value1__c='true');
        insert new Settings__c(Name='AddressStandardizationForAcctsEnabled', Value1__c='true');
    	insert new Settings__c(Name='AddressStandardizationCdyneApiKey', Value1__c='1234567890');
    }
}