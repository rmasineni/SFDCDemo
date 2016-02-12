@isTest
public class HomeDepotErrorLookupDtoTest{

    /* testmethod public static void errorLogLookupLeadTest(){
 
 BaseClass utils = new BaseClass();
 HomeDepotSyncServiceImpl impl = new HomeDepotSyncServiceImpl();
 
 Sf.settingsService.setBoolean('HomeDepotLeadSyncEnabled', true);
 
 DateTime dateToday = DateTime.Now().addDays(-1);
 String todayDate = dateToday.format('MM/dd/yyyy');
 string createdDate = '';
 createdDate = todayDate + ' ' + label.Home_Depot_Lead_Sync_Start_Time; 
 
 
  //boolean isSandbox = utils.isSandbox();
  
  string errorLogURL = impl.getErrorLogUrl();
  string errorLogRequestBody = impl.getErrorLogRequestBody(createdDate);
  
  //String userId = Sf.settingsService.getString('HomeDepotUserId');
  //String password = Sf.settingsService.getString('HomeDepotPassword');
  //String authToken = impl.getAuthToken();
  //String userId = 'XXS9245';
  //String password = 'XML872191';
  
  Sf.settingsService.setString('HomeDepotUserId','XXS9245');
  Sf.settingsService.setString('HomeDepotPassword','XML872191');
  Sf.settingsService.setString('HomeDepotOAuth2ClientId','wb8qRLqwySOcCl7GTx7O9zkNSkAM5FST');
  Sf.settingsService.setString('HomeDepotOAuth2ClientSecret','Xf4iC4WWgvzXm3Nz');
  Sf.settingsService.setString('HomeDepotOAuth2AuthzUrl','https://qa1.api.hs.homedepot.com/iconx/v1/auth/accesstoken');
  
  String clientId = Sf.settingsService.getString('HomeDepotOAuth2ClientId');
  String clientSecret = Sf.settingsService.getString('HomeDepotOAuth2ClientSecret');
  String oAuth2Authurl = impl.getOAuth2AuthzUrl();
  
  String userId = Sf.settingsService.getString('HomeDepotUserId');
  String password = Sf.settingsService.getString('HomeDepotPassword');
  system.debug('oAuth2Authurl'+oAuth2Authurl);
  system.debug('errorLogRequestBody '+errorLogRequestBody );
  system.debug('clientId '+clientId );
  system.debug('clientSecret'+clientSecret);
  
  Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator()); 
  
  
  //BaseClass.HttpDetails httpdet = new BaseClass.HttpDetails();
  
  HttpRequest req = new HttpRequest();
  req.setEndpoint(errorLogURL);
  req.setMethod('POST');
  req.setBody(errorLogRequestBody);
  
  baseclass.HttpDetails httpdet = new baseclass.HttpDetails();
  httpdet details = new httpdet();
  details.request = req;
  details.requestHeaders = headers;

  HttpResponse res = utils.sendHttpRequest(details);
  details.response = res;

  httpdet = utils.httpGetDetails(oAuth2Authurl,new Map<String, String>{'Authorization'=>utils.base64Encode(clientId+':'+clientSecret)}, new Map<String, String>{'grant_type'=>'client_credentials'}, null);
  
  
  string response = utils.httpGet(oAuth2Authurl,new Map<String, String>{'Authorization'=>utils.base64Encode(clientId+':'+clientSecret)}, new Map<String, String>{'grant_type'=>'client_credentials'}, null);
  
  string token = utils.getOAuth2AccessToken(oAuth2Authurl,clientId,clientSecret);
  
  String authToken = impl.getAuthToken();
  
  Map<String, String> headers = new Map<String, String>{
            'appToken' => authToken,
            'x-clientid' => utils.base64Encode(userId +':'+ password),
            'Content-Type' => 'application/json'
  };
  
  string resp = utils.httpGet(oAuth2Authurl,null,null);
      
  String oAuth2AccessToken = utils.getOAuth2AccessToken(oAuth2Authurl,clientId,clientSecret);
  system.debug('oAuth2AccessToken '+oAuth2AccessToken );
  
  
  
  string httget = utils.httpGet(oAuth2Authurl);
  
  impl.errorLogLookup(createdDate);
  JsonReader testReader = impl.homeDepotHttpPost(errorLogURL,errorLogRequestBody);
  
  
  
  
    //string httpget = utils.httpGet (errorLogURL);  
    //htdetails details = utils.httpPostDetails(errorLogURL,errorLogRequestBody,headers,60000);
    //string httppost = utils.httpPost(errorLogURL,errorLogRequestBody);                          
    //string body = utils.httpGetDetails (errorLogURL,errorLogRequestBody,headers,60000);
 }
*/ 

  static testmethod void testErrorlogLookupDTO(){
    List<Lead> list_Lead=new List<Lead>();
      
    //insert lead;
    
    HomeDepotSyncServiceImpl implObj = new HomeDepotSyncServiceImpl();
    Sf.settingsService.setBoolean('HomeDepotLeadSyncEnabled', true);
    
    Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
    
    user u=new user(id=userinfo.getuserid());
    List<RecordType> rt = [ Select Id from RecordType Where sObjectType='Account' AND Name='Partner'];  
    Account Acc  = new Account(Name='REC Solar', recordtypeid=rt[0].id,Active__c=true, lead_eligible__c=true,channel_type__c='Retail', Office_Location__c='Headquarters',   Stage__c='Confirmed',CDYNE_Status__c='Success' );
    insert Acc;
    Market__c market=new Market__c(state__c='CA',Utility_company__c='Test',Number_of_Leads__c=10);
    insert market;
    Market_Assignment__c ma = new Market_Assignment__c(market__c=market.id,partner__c=acc.id,Start_date__c=system.today()-1,end_date__c=system.today()+1,role__c='Sales,Install',Zipcodes__c='00000',Install_Partner_age_distribution__c=0.10,Sales_Partner_age_distribution__c=0.10);
    insert ma;
  
    Lead lead = new Lead(FirstName='TEST1',LastName='TEST Home Depot Lead1',
                   Company='TESTC', phone='1234567890',Email='test1customer@yopmail.com',
                   Country='USA',County__c='sfo', Prospect_Id__c='9999999999',
                             street='180 diamond st',city='San Francisco', state='CA',postalcode='94114',
                             channel__c='Retail',custom_lead_source__c='Home Depot',Lead_Type__c='In Store',
                             Lead_Organization_Location_2__c=system.label.LeadOrgHomedepot,
                             salesrep__c=userinfo.getuserid(),sales_rep_division__c='Inside Sales',called_in__c=true,
                             CDYNE_Status__c='Success',lead_qualifier__c=u.id,sales_partner__c=acc.id,Install_partner__c=acc.id,
                             market_Assignment_sales__c=ma.id,market_Assignment_install__c=ma.id,Field_Marketing_Branch__c='South Bay');
                             
  
    Test.startTest();
    list_Lead.add(lead);
    insert list_Lead;               
    Test.stopTest();
    
    lead.FirstName = 'TEST12';
    update lead;
        
    lead.FirstName = 'TEST1';
    lead.External_Sync_InProgress__c = true;
    update lead;
        
    String sunrunBatchId = '2345678902';
    Id leadId = lead.Id;
    String soql = 'select FirstName, External_Sync_Batch_ID_Inbound__c, Status, Lead_Status__c, LastName, Country, County__c, Title, Street, City, State,PostalCode, Phone, Alternate_Phone__c, Email, Notes__c, Contact_Costco_Member_ID__c, External_Id__c, Lead_Organization_Location_2__r.AccountNumber,  Prospect_Id__c, External_Sync_Batch_ID_Outbound__c, External_Sync_Status__c, External_Sync_Details__c,CreatedDate from Lead ';
    soql += ' where IsConverted = false  and Id =:leadId ';
    List<Lead> leads = Database.query(soql);
    implObj.syncLeads(sunrunBatchId, leads);       
        
    ConvertLead.doConvert(lead.id);
    
    Lead lead2 = [Select Id, convertedAccountId, convertedcontactId, convertedOpportunityId from Lead where Id = :lead.Id];
    Account convertedAccount = [Select Id, BillingStreet, (Select Id, FirstName from Contacts), (Select Id, External_Sync_InProgress__c, stagename FROM Opportunities) from Account where Id = :lead2.convertedAccountId];
    convertedAccount.BillingStreet = '180 diamond street';
    update convertedAccount;
    
    Contact contactObj =  convertedAccount.Contacts[0];  
    contactObj.FirstName = 'Test123';
    update contactObj;
  
    Opportunity optyObj = convertedAccount.Opportunities[0];
    optyObj.External_Sync_InProgress__c = false;
    optyObj.stagename = '3. Proposal Presented to Customer';
    update optyObj;

    optyObj.External_Sync_InProgress__c = true;
    optyObj.stagename = '1. Created';
    update optyObj;

    sunrunBatchId = '2245678902';
    Id optyId = optyObj.Id;
    String soql2 = 'select Id ,Lead_Source_2__c, StageName, accountId, External_Id__c, Prospect_Id__c, External_Sync_Batch_ID_Outbound__c, External_Sync_Status__c, External_Sync_Details__c, ';
    soql2 += ' Lead_Organization_Location_2__r.AccountNumber, CreatedDate, ';
    soql2 += ' Account.Id, Account.BillingStreet, Account.BillingCity, Account.BillingCountry, Account.County__c, Account.BillingPostalCode, Account.BillingState from Opportunity ';
    soql2 += ' where Id =:optyId ';
    List<Opportunity> opportunities = Database.query(soql2);
    implObj.syncOpportunities(sunrunBatchId, opportunities);  

    Date dateObj = date.today();
    implObj.lookupOpportunities(sunrunBatchId, dateObj.format());
    DateTime dateTimeNow = DateTime.Now();
    string errorLookupDate = dateTimeNow.format('MM/dd/yyyy');
    implObj.errorLogLookup(errorLookupDate);
    
    HomeDepotErrorLookupLeadBatch errorleadbatch = new HomeDepotErrorLookupLeadBatch();
    
    HomeDepotErrorLookupDto errLookupDTO = new HomeDepotErrorLookupDto();
  }

}