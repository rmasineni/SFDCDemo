@isTest
public class Test_TandCModifyProposalExt {

    @isTest static void constructorTest() {    
        Opportunity opty = new Opportunity(Name='RedirectLMFromTandCExtTest',StageName = 'Created',CloseDate = Date.Today()+30);
/*                               Average_Monthly_Electric_Bill__c = 1000,Square_footage__c = 1500,channel_2__c = 'Billboard',
                               Lead_Source_2__c = 'Billboard: Brilliant',Opportunity_Source_Type__c = 'BB',Utility_Company__c = 'PG&E',
                               Usage_Option__c = 'Basic',territory__c = 'Z', home_type__c = 'Detached single family home',
                               Market_Assignment_Install__c = ma.Id,Market_Assignment_Sales__c = ma.Id,Sales_Partner__c = sAccount.Id, 
                               Install_Partner__c = iAccount.Id, Sales_Rep_Division__c ='TestDiv',Sales_Rep_Email__c = 'test@PartnerLeadDetailTest.com');*/
        insert opty;
        
        Proposal__c prop = new Proposal__c();
        prop.Name='RedirectLMFromTandCExtTest';
        prop.Opportunity__c = Opty.Id;
        prop.Stage__c = 'Created';  
        prop.Sales_Rep_Email__c = 'therepsemail@repemailfake.com';
        prop.Date_Issued__c = Date.Today().addDays(18); 
        prop.Mode_Name__c = '1234';
        prop.System_Size_STC_DC__c  = 5.8;
        prop.Upfront_Payment__c = 20.0;
        prop.Sunrun_Credit_Status__c = 'SR Credit Approved';
        prop.EDP_Phase__c = 'EDP Phase-0';
    	insert prop;
        
        PageReference testPage = Page.TandCModifyProposalError;
        testPage.getParameters().put('returnId',prop.Id);
        testPage.getParameters().put('selectedDesign','Modify Proposal');
        testPage.getParameters().put('returnPage','Proposal');
        testPage.getParameters().put('errorMessage','This is test error message');
        testPage.getParameters().put('errorType','Error');
        testPage.getParameters().put('src','B');
        
        Test.setCurrentPage(testPage);
        
        ApexPages.StandardController controller = new ApexPages.StandardController(prop);
        TandCModifyProposalExt controllerExtn = new TandCModifyProposalExt(controller);
        
        system.assert(controllerExtn.showError);
        PageReference testReturnPage = controllerExtn.goBackToProposal();
        
        PageReference testPage1 = Page.TandCModifyProposalError;
        testPage1.getParameters().put('returnId',prop.Id);
        testPage1.getParameters().put('selectedDesign','Modify Proposal');
        testPage1.getParameters().put('returnPage','Proposal');
        testPage1.getParameters().put('errorMessage','This is test warning message');
        testPage1.getParameters().put('errorType','Warning');
        testPage1.getParameters().put('src','B');
        
        Test.setCurrentPage(testPage1);
        
        ApexPages.StandardController controller1 = new ApexPages.StandardController(prop);
        TandCModifyProposalExt controllerExtn1 = new TandCModifyProposalExt(controller1);
        
        system.assert(controllerExtn1.showWarning);
             
        prop.Proposal_Source__c = 'BB';
        update prop; 
        
        controllerExtn1.redirectToDesignTool();
        
        system.debug('controllerExtn1.redirectURL:' +controllerExtn1.redirectURL);
        system.assert(controllerExtn1.redirectURL.contains('lightmile'));
    }
         
}