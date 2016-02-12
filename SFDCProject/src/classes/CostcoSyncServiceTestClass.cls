@istest
public class CostcoSyncServiceTestClass{    
    static testmethod void CostcoSyncServiceTest(){
         insertSettings();
         String leadOrgLoc;
         Sf.settingsService.setBoolean('CostcoLeadSyncEnabled', true);        
         BaseClass base=new BaseClass();
         CostcoSyncServiceImpl cssi=new CostcoSyncServiceImpl();
         RestContext.request = new RestRequest();
         RestContext.response = new RestResponse();
         for(Costco_Lead_Org_Location_Test_Data__c cld:Costco_Lead_Org_Location_Test_Data__c.getAll().values()){
            leadOrgLoc=cld.Lead_Org_Id__c;
         }  
         if(leadOrgLoc==null){
            leadOrgLoc='0016000000ws0ZD';         
         }
         Lead lead = new Lead(FirstName='TEST',phone='1231231234',email='test33@yopmail.com',LastName='TEST Costco Ld',Company='TESTC',Lead_Type__c='Special Event',street='180 diamond st',city='San Francisco', state='CA',postalcode='94114',channel__c='Retail',custom_lead_source__c='Costco',Lead_Organization_Location_2__c=leadOrgLoc,Purchased_Thru__c='Costco');              
         //BaseClass.sendHttpRequest();
         Lead lead2=new Lead(lastname='Test2',company='Test');
         List<Lead> list_Lead=new List<Lead>();
         list_Lead.add(lead);
         list_Lead.add(lead2);
         insert list_Lead;
         Test.StartTest();        
         Map<String, String> cPar= cssi.createNewLeadRequestParms(lead,'','','');
         cssi.createUpdateCustomerRequestParms(lead);
         cssi.retrieveLeads();
         xmlReader xmlread=new xmlReader('<root><lead.id></lead.id></root>');
         cssi.createLeadUsingLeadApi(xmlread);  
         cssi.isCostcoLeadChanged(lead,lead);
         List<id> ids=new List<id>();
         ids.add(lead.id);    
         base.enqueueJobWithCheck(new CostcoLeadSyncJob((ids)));   
         SendLeadToCosctoButton.sendLead(lead.id);                             
         Test.StopTest();
         lead.status='Closed Lost'; 
         lead.purchased_thru__c=null;
         update lead;
                  
    }  
    static testmethod void TestMockWS(){
         insertSettings();
         CostcoSyncServiceImpl cssi=new CostcoSyncServiceImpl();
         Lead lead2=new Lead(lastname='Test2',company='Test');
         insert lead2;
         Test.StartTest();  
         Map<String,String> cPar=new Map<String,String>();        
          // Set mock callout class 
         Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());   
         cssi.costcoHttpPost('add_lead',cPar);     
         cssi.costcoHttpRequest('POST','add_lead',cPar);
         cssi.acknowledgeLead((String)lead2.id);
         cssi.retrieveLeads();
         cssi.getNewLeadIds();
         try{
         cssi.getAdcodeId();
         }
         catch(exception e){}
         cssi.handleAppointmentsTrigger();
         cssi.updateLeadsEstimateDate(new List<id>());
         cssi.handleProposalsTrigger();
         cssi.updateLeadsQuoteAmount(new List<id>());
         cssi.cancelLeadRequestParms(lead2,'1134');
         cssi.isCostcoCancelLeadChanged(lead2,lead2);       
         CostcoLeadSyncJob cs=new CostcoLeadSyncJob();                  
         Test.StopTest();
    } 
    static testmethod void TestOpportunity(){
    insertSettings();
    Opportunity optyObj1 = TestPRMLibrary.insertOpportunity('ResidentialAccount-3', 'Residential',
                                                                'ResOpty-3', 'Platinum');
        optyObj1.stageName='9. Closed Lost';
        optyObj1.Opportunity_Status__c='Competitor';
        optyObj1.External_Id__c='12324';
        optyObj1.Channel_2__c='Retail';
        optyObj1.Lead_Source_2__c='Costco';
        optyObj1.Lead_Created_Date_Time__c=system.now();
        update optyObj1;
        Proposal__C proposalObj = new Proposal__C();
        proposalObj.Name = 'Proposal-1';
        proposalObj.Opportunity__c = optyObj1.Id;
        proposalObj.Upfront_Payment__c = 1000;
        proposalObj.Proposal_ID__c = 2441242;
        proposalObj.System_Size_STC_DC__c = 1;
        proposalObj.Mode_Name__c = 'Mode-1';
        proposalObj.Date_Issued__c =  date.today();
        proposalObj.Sales_Rep_Email__c = 'test@gmail.com';    
        insert proposalObj;
        Contact contactObj1 = TestPRMLibrary.insertContact('PRMTestAccount1', 
                      PRMLibrary.PARTNER, 
                      'PRMTestLastName1',
                      'prmcontact1@sunrun.com');
        Appointment__c appointment=new Appointment__c();
        appointment.Event_Assigned_To__c=contactObj1.id;
        appointment.opportunity__c=optyObj1.id;
        appointment.Appointment_Date_Time__c=system.now();
        appointment.Appointment_End_Date_Time__c=system.now();            
        insert appointment;
        CostcoSyncServiceImpl cssi=new CostcoSyncServiceImpl();
        cssi.cancelLeadRequestParms(optyObj1,'1134');  
        cssi.updateLeadEstimateDateDummyRequestParms(proposalObj,'','');
        //cssi.updateLeadEstimateDateRequestParms(appointment,-2,4);
        CostcoOpptySyncJob co=new CostcoOpptySyncJob();
        CostcoLeadUpdateQuoteAmountJob cupq=new CostcoLeadUpdateQuoteAmountJob();
        CostcoLeadUpdateEstimateDateJob cued=new CostcoLeadUpdateEstimateDateJob();      
        
    }
    static testmethod void TestDisableCostco(){
        CostcoSyncServiceImpl cssi=new CostcoSyncServiceImpl();
        insert new Settings__c(Name='CostcoLeadSyncEnabled', Value1__c='false');
        cssi.syncOpptys(new List<id>{});
        cssi.updateLeadsEstimateDate(new List<id>{});
        cssi.updateLeadsQuoteAmount(new List<id>{});
        cssi.syncLeads(new list<id>{});
    }
     public static void insertSettings() {
        insert new Settings__c(Name='CostcoSyncServiceName', Value1__c='Solar Panel');
        insert new Settings__c(Name='CostcoSyncUserId', Value1__c='fcole');
        insert new Settings__c(Name='CostcoSyncPassword', Value1__c='Password1');
        insert new Settings__c(Name='CostcoSyncUrl', Value1__c='https://costcous.centah.com/xml.php');
        insert new Settings__c(Name='CostcoSyncAdcodeName', Value1__c='Brochure at Warehouse'); 
        insert new Settings__c(Name='CostcoLeadSyncEnabled', Value1__c='true');
        insert new Costco_Cancellation_Codes__c(name='lead123',key__c='Closed Lost',value__c='1134');
        insert new Costco_Cancellation_Codes__c(name='oppty123',key__c='9. Closed Lost+Competitor',value__c='1134');
     }
}