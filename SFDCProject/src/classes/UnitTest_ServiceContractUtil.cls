@isTest(SeeAllData=true)
public class UnitTest_ServiceContractUtil {
    
    public static ServiceContract scObj;
    public static Service_Contract_Event__C scEventObj;
    
    private static Map<String, Test_Partner_User__c> testPartnerUserMap = new Map<String, Test_Partner_User__c>();

    static
    {              
        testPartnerUserMap = Test_Partner_User__c.getAll();       
    }
        
    public static Test_Partner_User__c getBlackBirdSalesRep(){
        Test_Partner_User__c partnerUser;
        if(testPartnerUserMap != null && testPartnerUserMap.containsKey('Black Bird Sales Rep')){
            partnerUser = testPartnerUserMap.get('Black Bird Sales Rep');
        }
        return partnerUser;
    }

    public static Map<String, Partners_For_Service_Contrac_Batch__c> partnersForSCBatchMap = new Map<String, Partners_For_Service_Contrac_Batch__c>();
    public Static Set<String> partnerIds = new Set<String>();
    public static void getPartnerIdsForBatch(){
        partnersForSCBatchMap = Partners_For_Service_Contrac_Batch__c.getAll();
        for(Partners_For_Service_Contrac_Batch__c scBatchObj: partnersForSCBatchMap.values()){
            if(scBatchObj.Partner_Id__c != null && scBatchObj.Partner_Id__c != ''){
                partnerIds.add(scBatchObj.Partner_Id__c);
            }
        }
    }
    
    public static Proposal__c createProposal(Id optyId){
        UnitTest_ProposalUtil.disableExternalServices();
        getPartnerIdsForBatch();
        Set<String> salesPartnerIds = partnerIds;
        System.debug('salesPartnerIds: ' + salesPartnerIds);
        Proposal__c proposal = new Proposal__c();
        proposal.Stage__c = EDPUtil.SR_OPS_APPROVED;
        proposal.Credit_Status__c = 'Passed Credit Check';
        proposal.Opportunity__c = optyId;
        proposal.Sales_Rep_Email__c = 'Salesrep@repsfortesting.com';
        proposal.Date_Issued__c = Date.Today().addDays(18);
        proposal.Mode_Name__c = 'Mode323';
        proposal.System_Size_STC_DC__c = 12;
        proposal.Upfront_Payment__c = 1290;
       // insert proposal;
        proposal.Array_1_Panel_Type__c = 'TestPanelType1';
        proposal.Array_1_No_of_Panels__c = 1;
        proposal.Array_2_Panel_Type__c = 'TestPanelType2';
        proposal.Array_2_No_of_Panels__c = 2;
        proposal.Array_3_Panel_Type__c = 'TestPanelType3';
        proposal.Array_3_No_of_Panels__c = 3;
        proposal.Array_4_Panel_Type__c = 'TestPanelType4';
        proposal.Array_4_No_of_Panels__c = 4;
        proposal.Array_5_Panel_Type__c = 'TestPanelType5';
        proposal.Array_5_No_of_Panels__c = 5;
        proposal.Array_6_Panel_Type__c = 'TestPanelType6';
        proposal.Array_6_No_of_Panels__c = 6;    
        proposal.Name = 'TestProposal';  
        proposal.Agreement_Term_Years__c = 15;
        proposal.Agreement_Type__c= 'Test Agreement Type';
        proposal.Base_Lease_Payment_Amount__c = 101;
        proposal.Buyout_per_Watt__c = 102;
        proposal.EPC_Price__c = 103;
        proposal.EPC_price_per_watt__c = 104;
        proposal.Estimated_Rebate_Amount__c = 105;
        proposal.Est_Yr_1_Generation__c = 106;
        proposal.Full_System_cost__c = 107;
        proposal.Local_Rebate__c = 108;
        proposal.Prepay_Amount__c = 109;
        proposal.Prepay_Discount_Rate__c = 10;
        proposal.Prepay_payment_for_electricity__c = 110;
        proposal.Prepay_payment_for_RECs__c = 111;
        proposal.Price_per_kWh__c = 112;
        proposal.Production_Estimate_Source__c = 'Test Production Estimate Source';
        proposal.Production_Estimate_Source_Adjust_Ratio__c = 200;
        proposal.Product_Type__c = 'Test Product Type';
        proposal.Upfront_Payment__c = 4000;
        proposal.Year_1_monthly_payment__c =  5000;
        proposal.Yr_1_Avoided_Power_Cost__c = 6000;
        proposal.Utility__c='PSE&G';
        proposal.Create_Service_Contract__c = 'Yes';
        List<String> partnerIdSet = new  List<Id>();
        partnerIdSet.addall(salesPartnerIds);
        proposal.Sales_Partner__c = partnerIdSet[0];
        proposal.Sunrun_Credit_Status__c = EDPUtil.CREDIT_APPROVED;
        system.debug('<>><>>>proposal'+ proposal);
        return proposal;
    }
    
    public static Proposal__c createTestProposal(){
        Id partnerRecordTypeId;
        Id residentialRecordTypeId;
        Map<Id, RecordType> accountRecordTypeMap = PRMLibrary.getAccountRecordTypes();
        for(RecordType recordTypeObj : accountRecordTypeMap.values()){
            if(recordTypeoBJ.name == PRMLibrary.PARTNER){
                partnerRecordTypeId = recordTypeoBJ.Id;
            }else if(recordTypeoBJ.name == AccountUtil.RESIDENTIAL){
                residentialRecordTypeId = recordTypeoBJ.Id;
            }
        } 
       
        RecordType recordTypeObj = PRMLibrary.getResidentialContactRecordType();
        List<Contact> contactList = [Select Id,accountId, name, recordTypeId, account.BillingStreet, account.BillingCity, 
                                        account.BillingState, account.BillingPostalCode from Contact where recordTypeId =:recordTypeObj.Id
                                        and account.BillingState != '' and account.BillingPostalCode != '' and account.BillingCity != '' limit 1];
        Id accountId;
        system.debug('>>>>contactList' +  contactList);
        if(contactList != null && !contactList.isEmpty()){
            accountId = contactList[0].accountId;
        }else {

            Account a = new Account(name='Test Acct1', recordTypeId=residentialRecordTypeId);
            a.BillingStreet = '595 Market Street';
            a.BillingCity = 'San Francisco';
            a.BillingState = 'CA';
            a.BillingPostalCode = '94105';
            insert a;
            accountId = a.Id;
            
            Contact contactObj = new Contact(firstname= 'James', Lastname ='Smith', email='JamesTest1.Smith@yopmail.com', recordTypeId=recordTypeObj.Id, accountId= a.id);

        }
        
        Opportunity oppty = new Opportunity();
        oppty.AccountId = accountId;
        oppty.Name = 'NewCC Test';
        oppty.StageName = 'Qualified';
        oppty.CloseDate = Date.Today().addDays(18);
        insert oppty;
        system.debug('>>>oppty.Id' + oppty.Id);
        Proposal__c proposal = createProposal(oppty.Id);
        return proposal;
    }
    

    public static void createServiceContractData(){
        Proposal__c proposal  = createTestProposal();
        insert proposal;        
    
        ApexPages.StandardController controller = new ApexPages.StandardController(proposal);
        CreateServiceContractController serviceContractController = new CreateServiceContractController(controller);
        PageReference page = serviceContractController.create();
        //get object id from page reference
        String objectId = page.getURL().right(page.getURL().length() - 1);
        
        Set<Id> contractIds = new Set<Id>();
        contractIds.add(objectId);
        Map<Id, ServiceContract> contractMap = ServiceContractUtil.getServiceContractMap(contractIds);
        scObj = contractMap.get(objectId);   
        scobj.Install_Partner_Id__c='0016000000owsk8';
        
        if(scObj.Service_Contract_Events__r != null && !scObj.Service_Contract_Events__r.isEmpty()){
            scEventObj = scObj.Service_Contract_Events__r[0];
        } 
        List<ServiceContract> scList =  new  List<ServiceContract>();
        scList.add(scObj);
               
       List<Service_Contract_Partner_Rel__c> scPartnerList= [select Id from Service_Contract_Partner_Rel__c where servicecontract__c=:scObj.Id];
            
        List<Asset__c> assetList = [Select Id, name from asset__c where ServiceContract__c = :scObj.Id];
        System.debug('assetList: ' + assetList);
        
        //scObj = [select Id, Name, Yr_1_Avoided_Power_Cost__c, Proposal__c from ServiceContract where Id = :objectId limit 1];
        
        //scEventObj = [select Id, Name, service_contract__c, NTP_Granted__c,Initial_Deposit_Amount__c,
        //                                       M1_Status__c, M2_Status__c, M3_Status__c,
       //                                         Initial_Deposit_Amount_Received__c, Initial_Deposit_Processed__c, SR_Signoff__c,
        //                                        Customer_Signoff__c, Complete_Deal_Received__c, Facility_Design_Approval_Requested__c,
         //                                       Facility_Design_Approved__c, Rebate_Conf_Rec_d__c, Final_Rebate_Amount__c
         //                                       from Service_Contract_Event__c where service_contract__c = :scObj.Id];
                                             
        scEventObj.NTP_Granted__c = Date.Today();
        scEventObj.Initial_Deposit_Amount__c = 123.00;
        scEventObj.Initial_Deposit_Amount_Received__c = 123.00;
        scEventObj.Initial_Deposit_Processed__c = Date.Today();
        scEventObj.SR_Signoff__c = DateTime.now();
        scEventObj.Customer_Signoff__c = DateTime.now();
        scEventObj.Complete_Deal_Received__c = Date.today();
        scEventObj.Facility_Design_Approval_Requested__c = Date.today();
        scEventObj.Facility_Design_Approved__c = Date.today();
        scEventObj.Rebate_Conf_Rec_d__c = Date.Today();
        scEventObj.Final_Rebate_Amount__c = 123;
        update scEventObj;

        String cancelledStatus1 = 'Deal Cancelled';
        String cancelledStatus2 = 'Deal Cancelled due to credit';

    
        List<Service_Contract_Event__c> scEventList = [Select Id, Service_Contract__c, Service_Contract__r.Customer_Name__c, 
                                                        Service_Contract__r.Cust_Ref_Num__c, Service_Contract__r.Customer_Mailing_Address__c 
                                                        from Service_Contract_Event__c where NTP_Granted__c != null and Asset_Status__c NOT IN (:cancelledStatus1, :cancelledStatus2) limit 1];
        
        if(scEventList != null && !scEventList.isEmpty()){
            scEventObj = scEventList[0];
        }

        serviceContractController.generateNewSC = true;
        serviceContractController.generateNewServiceContract();
       
        //ServiceContractUtil.updateMileStoneDetails(scList,contractMap);
        
    }
    
        /*
     public static testMethod void testSCGenericMethods(){
        Set<String> ntpStages = ServiceContractUtil.getBeforeNTPStages();
        Set<String> ntpAfterStages = ServiceContractUtil.getAfterNTPStages();
        Set<String> ntpBeforeStages = ServiceContractUtil.getNTPStages();
        
        ServiceContract scObj1 = new ServiceContract();
        scObj1.ACH_Required__c = true;
        ServiceContractUtil.trackSCFieldChanges(scObj1, null);
        
        ServiceContract scObj2 = new ServiceContract();
        scObj2.ACH_Required__c = false;
        ServiceContractUtil.trackSCFieldChanges(scObj1, scObj2);
        
        Service_Contract_Event__c scEventObj1 = new Service_Contract_Event__c();
        scEventObj1.Build_able_as_Sold__c = 'Test1';
        ServiceContractUtil.trackSCEventFieldChanges(scEventObj1, null);
        
        Service_Contract_Event__c scEventObj2 = new Service_Contract_Event__c();
        scEventObj2.Build_able_as_Sold__c = 'Test2';
        ServiceContractUtil.trackSCEventFieldChanges(scEventObj1, scEventObj2);
        
        Contact contactObj = new Contact();
        contactObj.FirstName = 'FTest1';
        contactObj.Lastname = 'LTest1';
        String name = ServiceContractUtil.getContactName(contactObj);
        String soql = ServiceContractUtil.getContactSOQL();
        
        Contact targetContact = new Contact();
        ServiceContractUtil.cloneERPContact(contactObj, targetContact);
        Contact erpContact = ServiceContractUtil.getERPContact('test1@gmail.com');
        
    }
    
    public static testMethod void testSCSchedule(){
        CreateServiceContract_Schedulable  schedule = new CreateServiceContract_Schedulable();
        //schedule.execute(null);
    }

    public static testMethod void testSCBatch(){    
        ServiceContract_Batch scBatch = new ServiceContract_Batch(false);
        Account a = new Account(name='Test Acct1');
        insert a;
        
        Opportunity oppty = new Opportunity();
        oppty.AccountId = a.Id;
        oppty.Name = 'NewCC Test';
        oppty.StageName = 'Qualified';
        oppty.CloseDate = Date.Today().addDays(18);
        insert oppty;
        Proposal__c proposal = createProposal(oppty.Id);
        insert proposal; 
        
        Test.startTest();
            ID batchprocessid = Database.executeBatch(scBatch, 1); 
            System.debug('batchprocessid: ' + batchprocessid);
            Map<Id, String> proposalStageMap  = new Map<Id, String>();
            proposalStageMap.put(proposal.Id, EDPUtil.SR_OPS_APPROVED);
            
            ServiceContractUtil.updateServiceContract_future(proposalStageMap);
        Test.stopTest();
    }
    
    public static testMethod void testSkipTriggerValidations(){
        Users_For_Trigger_Validations__c triggerValidationObj = new Users_For_Trigger_Validations__c();
        triggerValidationObj.Name = 'TestUser1';
        triggerValidationObj.User_Id__c = Userinfo.getUserId();
        insert triggerValidationObj;
        
        SkipTriggerValidation.performTriggerValidations();
        
    }
    */
    
    
    public static testMethod void testServiceContractMeterRegistration(){
        UnitTest_ProposalUtil.disableExternalServices();
        String cancelledStatus1 = 'Deal Cancelled';
        String cancelledStatus2 = 'Deal Cancelled due to credit';
        String acctName = '';
        String custRefNum = '';
        String custMailAddress = '';
         
        Test_Partner_User__c testPartnerUserObj = UnitTest_ServiceContractUtil.getBlackBirdSalesRep();
        User u = [Select Id from User where ContactID != NULL and IsActive = true and Id =:testPartnerUserObj.User_Id__c  limit 1];
        System.runAs(u) {  
            UnitTest_ServiceContractUtil.createServiceContractData();
            System.debug('scObj: ' + scObj);
            System.debug('scEventObj: ' + scEventObj);
            scObj.Status__c = 'Deal Not Signed, Back to Sales';
            scObj.TE_Fund_Name__c  = 'Test Fund';
            update scObj;
         
            Map<Id, Boolean> result = new Map<Id, Boolean>();
             /*
            String objectName = 'Opportunity';
            Set<Id> objectIds1 = new  Set<Id>();
            if(scObj.Opportunity__c!=null){
           	 objectIds1.add(scObj.Opportunity__c);
            result = ServiceContractUtil.checkForCompletedServiceContracts(objectName, objectIds1);
             }*/
            
           /* 
           string objectName3 = 'Proposal';
            Set<Id> objectIds3 = new  Set<Id>();
            if(scObj.Proposal__c!=null){
            objectIds3.add(scObj.Proposal__c);             
            result = ServiceContractUtil.checkForCompletedServiceContracts(objectName3, objectIds3);
            }*/
             Test.startTest();
             String objectName = 'Contact';
            Set<Id> objectIds4 = new  Set<Id>();
            if(scObj.ContactId!=null){
            objectIds4.add(scObj.ContactId);             
            result = ServiceContractUtil.checkForCompletedServiceContracts(objectName, objectIds4);
             }
              project__c project = new project__c ( name = 'test project', Account__c= scObj.AccountId , Opportunity__c= scObj.Opportunity__c, Proposal__c = scObj.Proposal__c, service_contract__c = scObj.id); 
            insert project; 
                   
            ServiceContractUtil.updateERPContactDetails_Future(objectIds4);
            ServiceContractUtil.updateServiceContractEmail(objectIds4);
             Test.stoptest();
                        
        }
    }
    
      public static testMethod void testServiceContractMeterRegistration4(){
        UnitTest_ProposalUtil.disableExternalServices();
        String cancelledStatus1 = 'Deal Cancelled';
        String cancelledStatus2 = 'Deal Cancelled due to credit';
        String acctName = '';
        String custRefNum = '';
        String custMailAddress = '';
         
        Test_Partner_User__c testPartnerUserObj = UnitTest_ServiceContractUtil.getBlackBirdSalesRep();
        User u = [Select Id from User where ContactID != NULL and IsActive = true and Id =:testPartnerUserObj.User_Id__c  limit 1];
        System.runAs(u) {  
            UnitTest_ServiceContractUtil.createServiceContractData();
            System.debug('scObj: ' + scObj);
            System.debug('scEventObj: ' + scEventObj);
            scObj.Status__c = 'Deal Not Signed, Back to Sales';
            scObj.TE_Fund_Name__c  = 'Test Fund';
            update scObj;
         
            Map<Id, Boolean> result = new Map<Id, Boolean>();
            Test.startTest();
            string objectName2 = 'Proposal';
            Set<Id> objectIds2 = new  Set<Id>();
            if(scObj.AccountId!=null){
            objectIds2.add(scObj.AccountId);           
            result = ServiceContractUtil.checkForCompletedServiceContracts(objectName2, objectIds2);
            }
            Test.StopTest();
             
                        
        }
    }
    
    
    
     public static testMethod void testServiceContractMeterRegistration2(){
        UnitTest_ProposalUtil.disableExternalServices();
        String cancelledStatus1 = 'Deal Cancelled';
        String cancelledStatus2 = 'Deal Cancelled due to credit';
        String acctName = '';
        String custRefNum = '';
        String custMailAddress = '';
         
        Test_Partner_User__c testPartnerUserObj = UnitTest_ServiceContractUtil.getBlackBirdSalesRep();
        User u = [Select Id from User where ContactID != NULL and IsActive = true and Id =:testPartnerUserObj.User_Id__c  limit 1];
        System.runAs(u) {  
            UnitTest_ServiceContractUtil.createServiceContractData();
            System.debug('scObj: ' + scObj);
            System.debug('scEventObj: ' + scEventObj);
            scObj.Status__c = 'Deal Not Signed, Back to Sales';
            scObj.TE_Fund_Name__c  = 'Test Fund';
            update scObj;
         
            Map<Id, Boolean> result = new Map<Id, Boolean>();
            Test.startTest();
            string objectName2 = 'Opportunity';
            Set<Id> objectIds2 = new  Set<Id>();
            if(scObj.AccountId!=null){
            objectIds2.add(scObj.AccountId);           
            result = ServiceContractUtil.checkForCompletedServiceContracts(objectName2, objectIds2);
            }
            Test.StopTest();
             
                        
        }
    }
    
    
    
   public static testMethod void testServiceContractMeterRegistration1(){
        UnitTest_ProposalUtil.disableExternalServices();
        String cancelledStatus1 = 'Deal Cancelled';
        String cancelledStatus2 = 'Deal Cancelled due to credit';
        String acctName = '';
        String custRefNum = '';
        String custMailAddress = '';
         
        Test_Partner_User__c testPartnerUserObj = UnitTest_ServiceContractUtil.getBlackBirdSalesRep();
        User u = [Select Id from User where ContactID != NULL and IsActive = true and Id =:testPartnerUserObj.User_Id__c  limit 1];
        System.runAs(u) {  
            UnitTest_ServiceContractUtil.createServiceContractData();
            System.debug('scObj: ' + scObj);
            System.debug('scEventObj: ' + scEventObj);
            scObj.Status__c = 'Deal Not Signed, Back to Sales';
            scObj.TE_Fund_Name__c  = 'Test Fund';
            update scObj;
         
            Map<Id, Boolean> result = new Map<Id, Boolean>();
            Test.startTest();
            string objectName2 = 'Account';
            Set<Id> objectIds2 = new  Set<Id>();
            if(scObj.AccountId!=null){
            objectIds2.add(scObj.AccountId);           
            result = ServiceContractUtil.checkForCompletedServiceContracts(objectName2, objectIds2);
            }
            Test.StopTest();
             
                        
        }
    }
    
    public static testMethod void testSecondContractmethods(){
        ServiceContractUtil.getNTPStagesForDealCancel();
        ServiceContractUtil.getIgnoreScStatusForVoid();
        
        Opportunity optyObj = new Opportunity();
        ServiceContractUtil.initializeOracleERPFields(optyObj);
        Proposal__c proposal  = createTestProposal();
        insert proposal; 
        proposal = [Select Id, Opportunity__r.Id, Opportunity__c, Opportunity__r.AccountId from Proposal__C where Id =:proposal.Id]; 
        Opportunity cloneOpty = ServiceContractUtil.cloneDataForSecondProject(proposal);    
    } 

}