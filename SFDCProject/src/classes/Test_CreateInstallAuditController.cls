@isTest(SeeAllData=true)
public class Test_CreateInstallAuditController {

    public static testmethod void Test_CreateInstallAuditController (){
    
        Profile p = [SELECT Id FROM Profile WHERE Name='Operations - Fleet Ops']; 
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/Los_Angeles', UserName='test1231232@testorg1234.com');

        List<Audit_Criteria__c> criterias = new List<Audit_Criteria__c>();
        Audit_Criteria__c criteria1 = new Audit_Criteria__c(Active__c = true, Criteria_Description__c = 'Test Criteria 1', Criteria_Id__c = '01-01', 
                                                Criteria_Type__c = 'EPC Compliance', Notes_Evaluation__c = 'Test Notes 1', Point_Value__c = 5, 
                                                Priority_Criteria__c = 'Y', System_Component__c = 'Test Comp 1');
        criterias.add(criteria1);
        
        Audit_Criteria__c criteria2 = new Audit_Criteria__c(Active__c = true, Criteria_Description__c = 'Test Criteria 2', Criteria_Id__c = '01-02', 
                                                Criteria_Type__c = 'Test Type', Notes_Evaluation__c = 'Test Notes 2',  Point_Value__c = 5, 
                                                Priority_Criteria__c = 'N', System_Component__c = 'Test Comp 2');
        criterias.add(criteria2);     
        
        Audit_Criteria__c criteria3 = new Audit_Criteria__c(Active__c = false, Criteria_Description__c = 'Test Criteria 3', Criteria_Id__c = '01-03', 
                                                Criteria_Type__c = 'Test Type', Notes_Evaluation__c = 'Test Notes 3', Point_Value__c = 5, 
                                                Priority_Criteria__c = 'Y', System_Component__c = 'Test Comp 3');
        criterias.add(criteria3);    
        insert criterias;        
                                
        //DataSetup  
        Account a = new Account(name='Test Acct1');
        insert a;
        
        Opportunity oppty = new Opportunity();
        oppty.AccountId = a.Id;
        oppty.Name = 'NewCC Test';
        oppty.StageName = 'Qualified';
        oppty.CloseDate = Date.Today().addDays(18);
        insert oppty;
        //
		Proposal__c proposal = UnitTest_ServiceContractUtil.createProposal(oppty.Id);
		insert proposal;       
        
        Generation_Assets__c ga = new Generation_Assets__c(Account_Name__c=a.id, Name='99887', Proposal_Unique_ID__c = proposal.Name ); 
        insert ga;
        System.AssertEquals(6, proposal.Array_6_No_of_Panels__c);           
        System.AssertEquals(proposal.Name, ga.Proposal_Unique_ID__c );

        ApexPages.StandardController controller = new ApexPages.StandardController(ga);
        CreateInstallAuditController createInstallAuditTest = new CreateInstallAuditController(controller);  
        createInstallAuditTest.create();
                   
    }
	
	public static testmethod void testServiceContractInstallAuditController (){
		
		Test_Partner_User__c testPartnerUserObj = UnitTest_ServiceContractUtil.getBlackBirdSalesRep();
		User u = [Select Id from User where ContactID != NULL and IsActive = true and Id =:testPartnerUserObj.User_Id__c  limit 1];
		ServiceContract scObj;
		Service_Contract_Event__c scEventObj;
		String custRefNum = '';
		String acctName = '';
		String custMailAddress = '';
		System.runAs(u) {  
			Test.startTest();
        		UnitTest_ServiceContractUtil.createServiceContractData();
        		scObj = UnitTest_ServiceContractUtil.scObj;
				scEventObj = UnitTest_ServiceContractUtil.scEventObj;
				System.currentPagereference().getParameters().put('id', scEventObj.Id);
				custRefNum = scObj.Cust_Ref_Num__c;
				acctName = scObj.Customer_Name__c;
				custMailAddress = scObj.Customer_Mailing_Address__c;
         	Test.stopTest();
			List<Audit_Criteria__c> criterias = new List<Audit_Criteria__c>();
	        Audit_Criteria__c criteria1 = new Audit_Criteria__c(Active__c = true, Criteria_Description__c = 'Test Criteria 1', Criteria_Id__c = '01-01', 
	                                                Criteria_Type__c = 'EPC Compliance', Notes_Evaluation__c = 'Test Notes 1', Point_Value__c = 5, 
	                                                Priority_Criteria__c = 'Y', System_Component__c = 'Test Comp 1');
	        criterias.add(criteria1);
	        
	        Audit_Criteria__c criteria2 = new Audit_Criteria__c(Active__c = true, Criteria_Description__c = 'Test Criteria 2', Criteria_Id__c = '01-02', 
	                                                Criteria_Type__c = 'Test Type', Notes_Evaluation__c = 'Test Notes 2',  Point_Value__c = 5, 
	                                                Priority_Criteria__c = 'N', System_Component__c = 'Test Comp 2');
	        criterias.add(criteria2);     
	        
	        Audit_Criteria__c criteria3 = new Audit_Criteria__c(Active__c = false, Criteria_Description__c = 'Test Criteria 3', Criteria_Id__c = '01-03', 
	                                                Criteria_Type__c = 'Test Type', Notes_Evaluation__c = 'Test Notes 3', Point_Value__c = 5, 
	                                                Priority_Criteria__c = 'Y', System_Component__c = 'Test Comp 3');
	        criterias.add(criteria3);    
	        insert criterias;        

	        ApexPages.StandardController controller = new ApexPages.StandardController(scObj);
	        ServiceContractInstallAuditController createInstallAuditTest = new ServiceContractInstallAuditController(controller);  
	        createInstallAuditTest.create();
		}               
    }
}