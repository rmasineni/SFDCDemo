@isTest(SeeAllData=true)
public class Test_InstallAuditService {

    public static testmethod void Test_InstallAuditService(){
    
        //DataSetup  
        List<Audit_Criteria__c> criterias = new List<Audit_Criteria__c>();
        Audit_Criteria__c criteria1 = new Audit_Criteria__c(Active__c = true, Criteria_Description__c = 'Test Criteria 1', Criteria_Id__c = '01-01', 
                                                Criteria_Type__c = 'EPC Compliance', Notes_Evaluation__c = 'Test Notes 1', Point_Value__c = 5, 
                                                Priority_Criteria__c = 'Y', System_Component__c = 'Test Comp 1');
        criterias.add(criteria1);
        
        Audit_Criteria__c criteria2 = new Audit_Criteria__c(Active__c = true, Criteria_Description__c = 'Test Criteria 2', Criteria_Id__c = '01-02', 
                                                Criteria_Type__c = 'Test Type', Notes_Evaluation__c = 'Test Notes 2', Point_Value__c = 5, 
                                                Priority_Criteria__c = 'N', System_Component__c = 'Test Comp 2');
        criterias.add(criteria2);     
        
        Audit_Criteria__c criteria3 = new Audit_Criteria__c(Active__c = false, Criteria_Description__c = 'Test Criteria 3', Criteria_Id__c = '01-03', 
                                                Criteria_Type__c = 'Test Type', Notes_Evaluation__c = 'Test Notes 3', Point_Value__c = 5, 
                                                Priority_Criteria__c = 'Y', System_Component__c = 'Test Comp 3');
        criterias.add(criteria3);    
        insert criterias;        
                                                       
        Account a = new Account(name='Test Acct1');
        insert a;
        Generation_Assets__c ga = new Generation_Assets__c(Account_Name__c=a.id, Name='99887' ); 
        insert ga;
        Install_Audit__c  ia = new Install_Audit__c();
        ia.Generation_Asset__c = ga.Id;
        insert ia;   
        
        Contact contactObj1 = TestPRMLibrary.insertContact('Test',
                                       PRMLibrary.PARTNER, 
                                       'TestLastName',
                                       'testlastname223@gmail.comintdev');
        contactObj1.AccountId = a.Id;
        update contactObj1;     
        
        //Contact c = new Contact(last_na
                
        Opportunity oppty = new Opportunity();
        oppty.AccountId = a.Id;
        oppty.Name = 'NewCC Test';
        oppty.StageName = 'Qualified';
        oppty.CloseDate = Date.Today().addDays(18);
        insert oppty;
            //
		Proposal__c proposal = UnitTest_ServiceContractUtil.createProposal(oppty.Id);
		insert proposal;   
        
        ga.Proposal_Unique_ID__c = proposal.Name;
        update ga;
        
        Site_Characteristic__c char1 = new Site_Characteristic__c(Install_Audit__c = ia.Id);
        insert char1;     
        
        Site_Characteristic__c char2 = new Site_Characteristic__c(Install_Audit__c = ia.Id);
        insert char2;       
                        
        Site_Characteristic__c char3 = new Site_Characteristic__c(Install_Audit__c = ia.Id);
        insert char3;     
        
        Site_Characteristic__c char4 = new Site_Characteristic__c(Install_Audit__c = ia.Id);
        insert char4; 

        Site_Characteristic__c char5 = new Site_Characteristic__c(Install_Audit__c = ia.Id);
        insert char5;     
        
        Site_Characteristic__c char6 = new Site_Characteristic__c(Install_Audit__c = ia.Id);
        insert char6;                               
                        
        InstallAuditService installAuditService = new InstallAuditService();
        //System.AssertEquals(1, installAuditService.getProposalSiteCharacteristics(proposal.Name).size());        
        //System.AssertEquals(2, installAuditService.getContactsForAuditorAccount(a.Id).size());
        
        a.Partner_Type__c = 'Auditor';
        update a;
        //System.AssertEquals(2, installAuditService.getAuditorAccounts().size());   
        
        installAuditService.getAccountNameFromUser();
        installAuditService.getActiveAuditCriteria();     
    }
    
}