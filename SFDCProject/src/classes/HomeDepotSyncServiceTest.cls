@isTest
public class HomeDepotSyncServiceTest {
    public static Lead createLead(){
        Lead lead = new Lead(FirstName='TEST1',LastName='TEST Home Depot Lead1',
                     Company='TESTC', phone='1234567890',Email='test1customer@yopmail.com',
                     Country='USA',County__c='sfo', Prospect_Id__c='9999999999',
                     street='180 diamond st',city='San Francisco', state='CA',postalcode='94114',
                     channel__c='Retail',custom_lead_source__c='Home Depot',Lead_Type__c='In Store',
                     Lead_Organization_Location_2__c=system.label.LeadOrgHomedepot,
                     salesrep__c=userinfo.getuserid(),sales_rep_division__c='Inside Sales',called_in__c=true,
                     CDYNE_Status__c='Success',Field_Marketing_Branch__c='South Bay'
                     ); 
        insert lead;
        return lead;
    }

    static testmethod void TestMockWS(){
       List<Lead> list_Lead=new List<Lead>();
       HomeDepotSyncServiceImpl implObj = new HomeDepotSyncServiceImpl();
        Sf.settingsService.setBoolean('HomeDepotLeadSyncEnabled', true);        
    // Set mock callout class 
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
                             market_Assignment_sales__c=ma.id,market_Assignment_install__c=ma.id,Field_Marketing_Branch__c='South Bay'
                             );        
        
        
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
        
        DateTime dateTimeObj = DateTime.Now();
        string errorLookupDate = dateTimeObj.format('MM/dd/yyyy');
        implObj.errorLogLookup(errorLookupDate);
        
        HomeDepotErrorLookupLeadBatch errorleadbatch = new HomeDepotErrorLookupLeadBatch();
        HomeDepotErrorLookupDto errLookupDTO = new HomeDepotErrorLookupDto();
        
        List<Id> opportunityIds = new List<Id>();
        opportunityIds.add(optyObj.Id);
        
        
        implObj.getOpportunityRoleMap(opportunityIds);
    }


    static testmethod void testHomedepotLeadSync(){
       List<Lead> list_Lead=new List<Lead>();
       
        Sf.settingsService.setBoolean('HomeDepotLeadSyncEnabled', true);        
    // Set mock callout class 
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
                             market_Assignment_sales__c=ma.id,market_Assignment_install__c=ma.id,Field_Marketing_Branch__c='South Bay'
                             );        
        
        
        Test.startTest();
        list_Lead.add(lead);
        insert list_Lead;               
        Test.stopTest();
        
        lead.FirstName = 'TEST12';
        update lead;
        
        lead.FirstName = 'TEST1';
        lead.External_Sync_InProgress__c = true;
        update lead;
    }
    
    static testmethod void testOptyStatusReason(){

        String optyStage = '9. Closed Lost';
        String optyStatus = 'Not Interested';
        String reason =  'Upfront Cost Too High';
        HomeDepotSyncServiceImpl implObj = new HomeDepotSyncServiceImpl();
        String result = implObj.getOpportunityStatusReason(optyStage, optyStatus, reason); 
        reason = 'Contract Terms';
        result = implObj.getOpportunityStatusReason(optyStage, optyStatus, reason); 
        reason = 'Unable To Reach';
        result = implObj.getOpportunityStatusReason(optyStage, optyStatus, reason); 
        
        optyStatus = 'Unqualified';
        reason = 'Credit';
        result = implObj.getOpportunityStatusReason(optyStage, optyStatus, reason); 

        optyStatus = 'Unqualified';
        reason = 'Out of Service Territory';
        result = implObj.getOpportunityStatusReason(optyStage, optyStatus, reason);             
        
        optyStatus = 'Competitor';
        reason = '';
        result = implObj.getOpportunityStatusReason(optyStage, optyStatus, reason);  
        
        optyStage =  '9. Closed Lost';
        result = implObj.getOpportunityStatus(optyStage);

        String leadStage = 'Closed Lost' ;
        String leadStatus = 'Not Interested';
        result = implObj.getLeadStatusReason(leadStage, leadStatus);
        
        leadStatus = 'Working with Partner';
        result = implObj.getLeadStatusReason(leadStage, leadStatus);
        
        leadStatus = 'Bad Contact Info';
        result = implObj.getLeadStatusReason(leadStage, leadStatus);
        leadStatus = '';
        result = implObj.getLeadStatusReason(leadStage, leadStatus);
        leadStage = 'Out of Market' ;
        result = implObj.getLeadStatusReason(leadStage, leadStatus);

        leadStage =  'Closed Lost';
        result = implObj.getLeadStatus(leadStage);
        
        Date dateObj = date.today();
        implObj.errorLogLookup(dateObj.format());
        
        String batchNumber = '1234567890';
        implObj.lookupOpportunities(batchNumber, dateObj.format());
    }


    static testmethod void TestOptySyncJob(){
       List<Lead> list_Lead=new List<Lead>();
       HomeDepotSyncServiceImpl implObj = new HomeDepotSyncServiceImpl();
        Sf.settingsService.setBoolean('HomeDepotLeadSyncEnabled', true);        
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
                             market_Assignment_sales__c=ma.id,market_Assignment_install__c=ma.id,Field_Marketing_Branch__c='South Bay'
                             );        

        insert lead;               
        ConvertLead.doConvert(lead.id);
        
        Lead lead2 = [Select Id, convertedAccountId, convertedcontactId, convertedOpportunityId from Lead where Id = :lead.Id];
        Account convertedAccount = [Select Id, BillingStreet, (Select Id, FirstName from Contacts), (Select Id, External_Sync_InProgress__c, stagename FROM Opportunities) from Account where Id = :lead2.convertedAccountId];
        Test.startTest();
            Opportunity optyObj = convertedAccount.Opportunities[0];
            optyObj.External_Sync_InProgress__c = false;
            optyObj.stagename = '3. Proposal Presented to Customer';
            optyObj.External_Sync_System__c = 'Home Depot';
            optyObj.External_Sync_Status__c =  BaseClass.Status_ToBeSynced;
            optyObj.External_Sync_InProgress__c = false;
            optyObj.Lead_Source_2__c = 'Home Depot';
            optyObj.Channel_2__c = 'Retail';
            update optyObj;
            HomeDepotOpportunitySyncBatch batchObj = new HomeDepotOpportunitySyncBatch();
            id batchinstanceid = database.executeBatch(batchObj,10);
        Test.stopTest(); 
    }

/*
    static testmethod void TestOptyLookupJob(){
       List<Lead> list_Lead=new List<Lead>();
       HomeDepotSyncServiceImpl implObj = new HomeDepotSyncServiceImpl();
        Sf.settingsService.setBoolean('HomeDepotLeadSyncEnabled', true);        
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
                             market_Assignment_sales__c=ma.id,market_Assignment_install__c=ma.id,Field_Marketing_Branch__c='South Bay'
                             );        

        insert lead;               
        ConvertLead.doConvert(lead.id);
        
        Lead lead2 = [Select Id, convertedAccountId, convertedcontactId, convertedOpportunityId from Lead where Id = :lead.Id];
        Account convertedAccount = [Select Id, BillingStreet, (Select Id, FirstName from Contacts), (Select Id, External_Sync_InProgress__c, stagename FROM Opportunities) from Account where Id = :lead2.convertedAccountId];
        Test.startTest();
            Opportunity optyObj = convertedAccount.Opportunities[0];
            optyObj.External_Sync_InProgress__c = true; 
            optyObj.External_Sync_Batch_ID_Outbound__c = '1234567890';  
            optyObj.stagename = '3. Proposal Presented to Customer';
            optyObj.External_Sync_System__c = 'Home Depot';
            optyObj.External_Sync_Status__c =  BaseClass.Status_ToBeSynced;
            optyObj.Lead_Source_2__c = 'Home Depot';
            optyObj.Channel_2__c = 'Retail';
            update optyObj;
            HomeDepotOpportunityLookupBatch batchObj = new HomeDepotOpportunityLookupBatch();
            id batchinstanceid = database.executeBatch(batchObj,10);
        Test.stopTest(); 
    }*/
 
    public static testMethod void testLeadSyncBatch(){
        Test.startTest();
            Lead leadObj = createLead();
            leadObj.Custom_Lead_Source__c = 'Home Depot';
            leadObj.External_Sync_System__c = 'Home Depot';
            leadObj.External_Sync_Status__c = BaseClass.Status_ToBeSynced;
            leadObj.External_Sync_InProgress__c = false;
            update leadObj;
            HomeDepotLeadSyncBatch batchObj = new HomeDepotLeadSyncBatch();
            id batchinstanceid = database.executeBatch(batchObj,10);
        Test.stopTest(); 
        
        leadObj.External_Sync_Status__c = BaseClass.Status_ToBeSynced;
        leadObj.External_Sync_InProgress__c = false;
        update leadObj;
    }
    
    /*
    public static testMethod void testLeadLookupBatch(){
        Test.startTest();
            Lead leadObj = createLead();
            leadObj.Custom_Lead_Source__c = 'Home Depot';
            leadObj.External_Sync_System__c = 'Home Depot';
            leadObj.External_Sync_Status__c = BaseClass.Status_ToBeSynced;
            leadObj.External_Sync_InProgress__c = true; 
            leadObj.External_Sync_Batch_ID_Outbound__c = '1234567890';      
            update leadObj;
            HomeDepotLeadLookupBatch batchObj = new HomeDepotLeadLookupBatch();
            id batchinstanceid = database.executeBatch(batchObj,10);
            
        Test.stopTest(); 
    }*/   

    public static testMethod void testHomeDepotLeadLookupDto(){
        HomeDepotLeadLookupDto dtoObj1 = new HomeDepotLeadLookupDto();
        HomeDepotLeadLookupDto dtoObj2 = new HomeDepotLeadLookupDto(null);
        Map<String, HomeDepotLeadLookupDto.LeadDTO> map1= dtoObj1.leadDTOMap;
        List<HomeDepotLeadLookupDto.LeadDTO> listDTO = dtoObj1.leadDTOsWithNoSFDCId;
        String code1 = dtoObj1.code;
        String message = dtoObj1.message;
    }

    public static testMethod void testAPIRequestLog(){
        API_Request_Log__c apiReq = new API_Request_Log__c(); 
        apiReq.Object_Name__c = 'lead';
        apiReq.External_Sync_System__c = 'Home Depot';
        apiReq.Prospect_Id__c = '1234244081';
        apiReq.Request_Type__c = 'HD Lead Look-up';
        apiReq.Request_Status__c = 'Ready To Look-up';
        apiReq.Name = apiReq.Request_Type__c+apiReq.Prospect_Id__c; 
        insert apiReq; 
        
        apiReq.Request_Status__c = 'Look-up In Progress';
        update apiReq;
        
        HomeDepotSyncServiceImpl implObj = new HomeDepotSyncServiceImpl();
        implObj.lookupLead(apiReq.Id, '70755000003DTLkAAO_1',apiReq.Prospect_Id__c);
        
    }

}