@isTest(SeeAllData=true)
public class Test_CreateServiceContractController{

    static
    {
        //Create_Service_Contract_Proposal_Stage__c cscps1 = new Create_Service_Contract_Proposal_Stage__c(Name = 'Created');
        //insert cscps1;
    }


    //Working
        
    public static TestMethod void Test_CreateServiceContractController()
    {
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
        
        ApexPages.StandardController controller = new ApexPages.StandardController(proposal);
        CreateServiceContractController serviceContractController = new CreateServiceContractController(controller);
        PageReference page = serviceContractController.create();
        //get object id from page reference
        String objectId = page.getURL().right(page.getURL().length() - 1);
        
        ServiceContract serviceContract = [select Id, Name, Yr_1_Avoided_Power_Cost__c, Proposal__c from ServiceContract where Id = :objectId];

        
        // Added by Ankita
        proposal.Sunrun_Credit_Status__c = null;    
        update proposal;
        
        ApexPages.StandardController controller1 = new ApexPages.StandardController(proposal);
        CreateServiceContractController serviceContractController1 = new CreateServiceContractController(controller1); 
        PageReference page1 = serviceContractController1.create();
        // 
            
    }    


    public static TestMethod void Test_CreateServiceContractControllerWithAssetInformation()
    {
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
		        
        Asset_Information__c assetInformation = new Asset_Information__c(Count__c = 5, Type__c = 'Panel', Manufacturer__c='Test Manu', Model__c = 'Test Model', ProposalName__c = proposal.Id);
        insert assetInformation;
                
        ApexPages.StandardController controller = new ApexPages.StandardController(proposal);
        CreateServiceContractController serviceContractController = new CreateServiceContractController(controller);
        PageReference page = serviceContractController.create();
    }    


    //Working
    public static TestMethod void Test_CreateServiceContractControllerMultipleTimes()
    {
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
		        
        Asset_Information__c assetInformation = new Asset_Information__c(Count__c = 5, Type__c = 'Panel', Manufacturer__c='Test Manu', Model__c = 'Test Model', ProposalName__c = proposal.Id);
        insert assetInformation;
                
        ApexPages.StandardController controller = new ApexPages.StandardController(proposal);
        CreateServiceContractController serviceContractController = new CreateServiceContractController(controller);
        PageReference page = serviceContractController.create();
        //get object id from page reference
        String objectId = page.getURL().right(page.getURL().length() - 1);
        
        ServiceContract serviceContract = [select Id, Name, Yr_1_Avoided_Power_Cost__c, Proposal__c from ServiceContract where Id = :objectId];
		
		Test.startTest();

        ApexPages.StandardController controller2 = new ApexPages.StandardController(proposal);
        CreateServiceContractController serviceContractController2 = new CreateServiceContractController(controller2);
        PageReference page2 = serviceContractController2.create();
        Test.stopTest();

    }        

    //Working method ...    
    public static TestMethod void Test_CreateServiceContractControllerWithInvalidProposalStatus()
    {
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
        Asset_Information__c assetInformation = new Asset_Information__c(Count__c = 5,  Manufacturer__c='Test Manu', Model__c = 'Test Model', ProposalName__c = proposal.Id,Type__c = ServiceContractUtil.ASSET_TYPE_METER );
        insert assetInformation;
                
        ApexPages.StandardController controller = new ApexPages.StandardController(proposal);
        CreateServiceContractController serviceContractController = new CreateServiceContractController(controller);
        PageReference page = serviceContractController.create();
	}       
		// Added By Ankita
    public static TestMethod void Test_CreateServiceContractControllerWithIdStage()
    {
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
        proposal.Sunrun_Credit_Status__c = EDPUtil.CREDIT_APPROVED;
        update proposal;     
        
         
        CreateServiceContractController serviceContractController = new CreateServiceContractController(proposal.Id,proposal.Stage__c);   
        PageReference page = serviceContractController.ReturnToProposal();
        String rv = serviceContractController.createServiceContract();
        CreateServiceContractController serviceContractController1 = new CreateServiceContractController();   
        String rv1 = serviceContractController1.createServiceContract();
            
        proposal.Sunrun_Credit_Status__c = null;    
        update proposal;
        
        CreateServiceContractController serviceContractController2 = new CreateServiceContractController(proposal.Id,proposal.Stage__c); 
        String rv2 = serviceContractController2.createServiceContract();
          
    }
}