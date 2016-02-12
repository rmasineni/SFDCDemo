/**
Peter Alexander Mandy
11012012:10:51:26
Salesforce.com Test Method for CDYNE Related Code
 */
@isTest(SeeAllData=true)
private class testCDYNEService {

static testMethod void myUnitTest() {
    String xmlResponse = '<PavResponse xmlns="pav3.cdyne.com" xmlns:i="http://www.w3.org/2001/XMLSchema-instance"><CensusInfo><CMSA/><CensusBlockNumber>2008</CensusBlockNumber><CensusTractNumber>0124.00</CensusTractNumber><FIPS>42055</FIPS><MA>097</MA><MSA/><PMSA/></CensusInfo><CityName>Waynesboro</CityName><Country>USA</Country><County>FRANKLIN</County><CountyNum>055</CountyNum><FinanceNumber>418968</FinanceNumber><FirmOrRecipient/><GeoLocationInfo><AreaCode>717</AreaCode><AvgLatitude>39.7552905</AvgLatitude><AvgLongitude>-77.577190</AvgLongitude><FromLatitude>39.755039</FromLatitude><FromLongitude>-77.576701</FromLongitude><HasDaylightSavings>true</HasDaylightSavings><TimeZone>EST</TimeZone><ToLatitude>39.755542</ToLatitude><ToLongitude>-77.577679</ToLongitude></GeoLocationInfo><IntelligentMailBarcodeKey>v8PV/x6tidAG79JtWT9ZuA==</IntelligentMailBarcodeKey><LegislativeInfo><CongressionalDistrictNumber>09</CongressionalDistrictNumber><StateLegislativeLower>090</StateLegislativeLower><StateLegislativeUpper>033</StateLegislativeUpper></LegislativeInfo><MailingIndustryInfo><CSKey>X1B841</CSKey><CarrierRoute>C005</CarrierRoute><CheckDigit>0</CheckDigit><DefaultFlag>true</DefaultFlag><DeliveryPoint>99</DeliveryPoint><DpvConfirmationIndicator>D</DpvConfirmationIndicator><DpvCrmaIndicator>N</DpvCrmaIndicator><DpvFootnote1>AA</DpvFootnote1><DpvFootnote2>N1</DpvFootnote2><DpvFootnote3/><DpvNoStatIndicator>N</DpvNoStatIndicator><DpvVacantIndicator>N</DpvVacantIndicator><ELOTAscDesc>A</ELOTAscDesc><ELOTSequenceNumber>0037</ELOTSequenceNumber><EwsFlag>false</EwsFlag><LACSFlag/><LACSIndicator/><LACSReturnCode/><RecordTypeCode>H</RecordTypeCode><SuiteLinkReturnCode/></MailingIndustryInfo><MultipleMatches><AddressInfo><CarrierRoute>C005</CarrierRoute><FinanceNumber>418968</FinanceNumber><Firm/><Plus4High>1676</Plus4High><Plus4Low>1676</Plus4Low><PostDirectional/><PreDirectional>E</PreDirectional><PrimaryEO>E</PrimaryEO><PrimaryHigh>28</PrimaryHigh><PrimaryLow>28</PrimaryLow><RecordTypeCode>H</RecordTypeCode><SecondaryAbbreviation>APT</SecondaryAbbreviation><SecondaryEO>B</SecondaryEO><SecondaryHigh>2H</SecondaryHigh><SecondaryLow>2A</SecondaryLow><StreetName>MAIN</StreetName><Suffix>ST</Suffix><ZipCode>17268</ZipCode></AddressInfo><AddressInfo><CarrierRoute>C005</CarrierRoute><FinanceNumber>418968</FinanceNumber><Firm/><Plus4High>1656</Plus4High><Plus4Low>1656</Plus4Low><PostDirectional/><PreDirectional>E</PreDirectional><PrimaryEO>E</PrimaryEO><PrimaryHigh>28</PrimaryHigh><PrimaryLow>28</PrimaryLow><RecordTypeCode>H</RecordTypeCode><SecondaryAbbreviation>APT</SecondaryAbbreviation><SecondaryEO>B</SecondaryEO><SecondaryHigh>8</SecondaryHigh><SecondaryLow>3</SecondaryLow><StreetName>MAIN</StreetName><Suffix>ST</Suffix><ZipCode>17268</ZipCode></AddressInfo><AddressInfo><CarrierRoute>C005</CarrierRoute><FinanceNumber>418968</FinanceNumber><Firm/><Plus4High>1634</Plus4High><Plus4Low>1634</Plus4Low><PostDirectional/><PreDirectional>E</PreDirectional><PrimaryEO>E</PrimaryEO><PrimaryHigh>44</PrimaryHigh><PrimaryLow>24</PrimaryLow><RecordTypeCode>S</RecordTypeCode><SecondaryAbbreviation/><SecondaryEO/><SecondaryHigh/><SecondaryLow/><StreetName>MAIN</StreetName><Suffix>ST</Suffix><ZipCode>17268</ZipCode></AddressInfo><AddressInfo><CarrierRoute>C005</CarrierRoute><FinanceNumber>418968</FinanceNumber><Firm/><Plus4High>1656</Plus4High><Plus4Low>1656</Plus4Low><PostDirectional/><PreDirectional>E</PreDirectional><PrimaryEO>E</PrimaryEO><PrimaryHigh>28</PrimaryHigh><PrimaryLow>28</PrimaryLow><RecordTypeCode>H</RecordTypeCode><SecondaryAbbreviation>APT</SecondaryAbbreviation><SecondaryEO>B</SecondaryEO><SecondaryHigh>2</SecondaryHigh><SecondaryLow>1</SecondaryLow><StreetName>MAIN</StreetName><Suffix>ST</Suffix><ZipCode>17268</ZipCode></AddressInfo></MultipleMatches><PMBDesignator/><PMBNumber/><PostDirectional/><PostnetBarcode>f172681656990f</PostnetBarcode><PreDirectional>E</PreDirectional><PreferredCityName>Waynesboro</PreferredCityName><Primary>28</Primary><PrimaryDeliveryLine>28 E Main St</PrimaryDeliveryLine><PrimaryEO>E</PrimaryEO><PrimaryHigh>28</PrimaryHigh><PrimaryLow>28</PrimaryLow><ResidentialDeliveryIndicator>Y</ResidentialDeliveryIndicator><ReturnCode>103</ReturnCode><Secondary/><SecondaryAbbreviation/><SecondaryDeliveryLine/><SecondaryEO>B</SecondaryEO><SecondaryHigh/><SecondaryLow/><StateAbbreviation>PA</StateAbbreviation><StreetName>MAIN</StreetName><Suffix>ST</Suffix><Urbanization/><ZipCode>17268-1656</ZipCode></PavResponse>';
//CDYNE_Return_Codes__c
    List<CDYNE_Return_Codes__c> listCRC = new List<CDYNE_Return_Codes__c>();
    try{      
      CDYNE_Return_Codes__c CRC100 = new CDYNE_Return_Codes__c(Name='100',Description__c='PAV_ADDRESS_IS_DPV: Input address is USPS Delivery Point Valid (DPV) for all components.');
      CDYNE_Return_Codes__c CRC200 = new CDYNE_Return_Codes__c(Name='200',Description__c='PAV_CANADIAN: Canadian address on input. Verified on City level only.');
      listCRC.add(CRC100);
      listCRC.add(CRC200);
      insert listCRC;
    }
    catch(Exception e)
    {
        System.Debug('Testing Error: ' + e.getMessage());
    }
//ACCOUNTS   
    List<Account> listA = new List<Account>();
    Set<String> setAcctIds = new Set<String>();
    Id RTId = [select id from RecordType where sObjectType = 'Account' and Name = 'Residential'].Id;
    Account aBase = new Account(RecordTypeId = RTId, name='Test Account Base', BillingCity = 'Mill Valley', BillingState = 'CA', BillingPostalCode = '94941', Zip_6__c = '1234567890A');
    listA.add(aBase);        
    Account a = new Account(RecordTypeId = RTId, name='Test Account', BillingCity = 'Mill Valley', BillingState = 'CA', BillingPostalCode = '94941');
    listA.add(a);    
    Account a2 = new Account(RecordTypeId = RTId, name='Test Account 2', BillingCity = 'Mill Valley', BillingState = 'CA', BillingPostalCode = '94941');    
    listA.add(a2);   
    insert listA; 
    //a2.BillingStreet = '160A Miller Avenue';
    //update a2;
    setAcctIds.add(String.Valueof(a.Id));
    setAcctIds.add(String.Valueof(a2.Id));    
//LEADS
    List<Lead> listLead = new List<Lead>();
    Set<String> setLeadIds = new Set<String>();
    Lead L1 = new Lead();
    L1.Company = 'Test Company';
    L1.Email = 'test@test.com';
    L1.LastName = 'Tester';
    L1.FirstName = 'Joe';
    L1.LeadSource = 'Referral - Customer Portal';
    L1.Street = '31 Miller Avenue';
    L1.State = 'CA';
    L1.PostalCode = '94941';
    listLead.add(L1);
    Lead L2 = new Lead();
    L2.Company = 'Test2 Company';
    L2.Email = 'test2@test.com';
    L2.LastName = 'Tester2';
    L2.FirstName = 'Joe2';
    L2.LeadSource = 'Referral - Customer Portal';
    L2.Street = '31 Miller Avenue';    
    L2.State = 'CA';
    L2.PostalCode = '94941';
    listLead.add(L2);    
    insert listLead;

    //
    setLeadIds.add(String.ValueOf(L1.Id));
    setLeadIds.add(String.ValueOf(L2.Id));
    CDYNEService CDYNE = new CDYNEService();
    Map<String, String> mapCDYNEReturnCodes = CDYNE.getMapCDYNEReturnCodes();
    //
    CDYNEService.CDYNEInformation CDYNEInfoSuccess = new CDYNEService.CDYNEInformation(mapCDYNEReturnCodes, '100', '52100009999', '100 Main St.', 'Tuscaloosa', '', '11111', 'Success','','','','','','','','','','','','','','','','','','','','','');
    CDYNEService.CDYNEInformation CDYNEInfoFailure = new CDYNEService.CDYNEInformation(mapCDYNEReturnCodes, '200', '52100009999', '2112 Canada Lane', 'YYZ', '', '11111', 'Failure','','','','','','','','','','','','','','','','','','','','','');
    
    Map<String, CDYNEService.CDYNEInformation> mapCDYNE = new Map<String, CDYNEService.CDYNEInformation>();
    mapCDYNE.put(String.ValueOf(L2.Id), CDYNEInfoSuccess);
    CDYNE.updateLead(L2, mapCDYNE);
    //
    mapCDYNE.clear();
    mapCDYNE.put(String.ValueOf(L2.Id), CDYNEInfoFailure);
    CDYNE.updateLead(L2, mapCDYNE);
    //
    mapCDYNE.clear();
    mapCDYNE.put(String.ValueOf(a.Id), CDYNEInfoSuccess);
    CDYNE.updateAccount(a, mapCDYNE);
    //
    mapCDYNE.clear();
    mapCDYNE.put(String.ValueOf(a.Id), CDYNEInfoFailure);
    CDYNE.updateAccount(a, mapCDYNE);
    //
    for(Account acct:listA)
    {
        if(acct.Name == 'Test Account 2')
        {
           acct.Zip_6__c = '1234567890A';
        }
    }
    CDYNE.processLeadUpdates(listLead);
    CDYNE.processAccountUpdates(listA);    
    //
    DOM.Document doc = new DOM.Document();      
    try {
      doc.load(xmlResponse);    
      DOM.XMLNode root = doc.getRootElement();
      String callparser = CDYNE.walkThrough(root);
    }
    catch(Exception e)
    {
        System.Debug('Testing Error: ' + e.getMessage());
    }
    //
    try{
      Map<String, CDYNEService.CDYNEInformation> MapCDYNEInfo = CDYNE.parse(L2, xmlResponse, mapCDYNEReturnCodes);
    }
    catch(Exception e)
    {
        System.Debug('Testing error: ' + e.getMessage());
    }
    //
    try{    
          CDYNE.processZipPlusSixForAccountsImmediate(setAcctIds);          
    }
    catch(Exception e)
    {
        System.Debug('Testing error: ' + e.getMessage());
    }   
    try{    
         CDYNE.processZipPlusSixForLeadsImmediate(setLeadIds);          
    }
    catch(Exception e)
    {
        System.Debug('Testing error: ' + e.getMessage());
    }       
    try{    
     // OTHER TESTS....
     Map<String, CDYNEService.CDYNEInformation> testMap = new Map<String, CDYNEService.CDYNEInformation>();     
     testMap = CDYNE.parse(a, xmlResponse, mapCDYNEReturnCodes);
     testMap = CDYNE.parse(L1, xmlResponse, mapCDYNEReturnCodes);
     //          
    }
    catch(Exception e)
    {
        System.Debug('Testing error: ' + e.getMessage());
    }    
    //
    CDYNEService.processZipPlusSixForLeads(setLeadIds);
    CDYNEService.processZipPlusSixForAccounts(setAcctIds); 
    //
    // Set fields intentionally left out earlier to now test triggers.
    //
    L1.City = 'Mill Valley';
    L2.City = 'Mill Valley';
    L2.Street = '160A Miller Avenue';
    update listLead;   
    a.BillingStreet = '31 Miller Ave';
    a2.BillingStreet = '31 Miller Ave';
    aBase.BillingStreet = '31 Miller Ave';
    update listA;
    //
    try{
       ApexPages.StandardController scAcct = new ApexPages.StandardController(a);
       AccountExtensionForCDYNE AExtCdyne = new AccountExtensionForCDYNE(scAcct);       
       PageReference pr = AExtCdyne.getPageRef();
       AExtCdyne.init();
    }
    catch(Exception e)
    {
        System.Debug('Testing error: ' + e.getMessage());
    }
    try{
      ApexPages.StandardController scLead = new ApexPages.StandardController(L2);
      LeadExtensionForCDYNE LExtCdyne = new LeadExtensionForCDYNE(scLead);
      PageReference pr = LExtCdyne.getPageRef();
      LExtCdyne.init();      
    }
    catch(Exception e)
    {
       System.Debug('Testing error: ' + e.getMessage());
    }
    //
    }
}