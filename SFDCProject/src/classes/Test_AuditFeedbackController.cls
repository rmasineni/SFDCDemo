@isTest(SeeAllData=true)
public class Test_AuditFeedbackController {

    public static testmethod void Test_AuditTemplateControllerWithNoFeedback (){
    
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
                        
        //Sun_Run_Audit_List_Settings__c listSettings = new Sun_Run_Audit_List_Settings__c(Name = 'Pagination Rows', Value__c = 100); 
        //insert listSettings;
        
        PageReference pageRef = Page.AuditFeedback;
        Test.setCurrentPage(pageRef);   
        ApexPages.currentPage().getParameters().put('Install_Audit__c', ia.Id);
        
        AuditFeedbackController controller = new AuditFeedbackController(null);  
    }
    
    public static testmethod void Test_AuditTemplateControllerWithFeedback (){
    
      //DataSetup  
        List<Audit_Criteria__c> criterias = new List<Audit_Criteria__c>();
        Audit_Criteria__c criteria1 = new Audit_Criteria__c(Active__c = true, Criteria_Description__c = 'Test Criteria 1', Criteria_Id__c = '01-01', 
                                                Criteria_Type__c = 'EPC Compliance', Notes_Evaluation__c = 'Test Notes 1', Point_Value__c = 5, 
                                                Priority_Criteria__c = 'Y', System_Component__c = 'Test Comp 1');
        criterias.add(criteria1);
        
        Audit_Criteria__c criteria2 = new Audit_Criteria__c(Active__c = true, Criteria_Description__c = 'Test Criteria 2', Criteria_Id__c = '01-02', 
                                                Criteria_Type__c = 'Test Type', Notes_Evaluation__c = 'Test Notes 2', Point_Value__c = 5, 
                                                Priority_Criteria__c = 'N', System_Component__c = 'Test Comp 2', Auto_Calculated__c = true);
        criterias.add(criteria2);     
        
        Audit_Criteria__c criteria3 = new Audit_Criteria__c(Active__c = false, Criteria_Description__c = 'Test Criteria 3', Criteria_Id__c = '01-03', 
                                                Criteria_Type__c = 'Test Type', Notes_Evaluation__c = 'Test Notes 3', Point_Value__c = 5, 
                                                Priority_Criteria__c = 'Y', System_Component__c = 'Test Comp 3');

        criterias.add(criteria3); 

        Audit_Criteria__c criteria4 = new Audit_Criteria__c(Active__c = false, Criteria_Description__c = 'Test Criteria 3', Criteria_Id__c = '01-04', 
                                                Criteria_Type__c = 'Test Type', Notes_Evaluation__c = 'Test Notes 3', Point_Value__c = 5, 
                                                Priority_Criteria__c = 'Y', System_Component__c = 'Test Comp 3', Auto_Calculated__c = true);                                                
        criterias.add(criteria4);    
        insert criterias;        
                                                       
        Account a = new Account(name='Test Acct1');
        insert a;
        Generation_Assets__c ga = new Generation_Assets__c(Account_Name__c=a.id, Name='99887', Proposal_Unique_ID__c = 'TestProposal' ); 
        insert ga;
        Install_Audit__c  ia = new Install_Audit__c();
        ia.Generation_Asset__c = ga.Id;
        insert ia;   
                
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
                        
       // Sun_Run_Audit_List_Settings__c listSettings = new Sun_Run_Audit_List_Settings__c(Name = 'Pagination Rows', Value__c = 100); 
        //insert listSettings;
        
        List<Audit_Feedback__c> feedbacks = new List<Audit_Feedback__c>();
        Audit_Feedback__c feedback1 = new Audit_Feedback__c(Install_Audit__c = ia.Id, Audit_Criteria__c = criteria1.Id);
        feedbacks.add(feedback1);
        Audit_Feedback__c feedback2 = new Audit_Feedback__c(Install_Audit__c = ia.Id, Audit_Criteria__c = criteria2.Id, QA_Score__c = 'Fail', Comments__c = 'Fail');
        feedbacks.add(feedback2);
        Audit_Feedback__c feedback3 = new Audit_Feedback__c(Install_Audit__c = ia.Id, Audit_Criteria__c = criteria3.Id);
        feedbacks.add(feedback3);
        insert feedbacks;
                      
        PageReference pageRef = Page.AuditFeedback;
        Test.setCurrentPage(pageRef);   
        ApexPages.currentPage().getParameters().put('Install_Audit__c', ia.Id);
        
        AuditFeedbackController controller = new AuditFeedbackController(null); 
        controller.nextPhotosPage();
        controller.previousCriteriaPage();
        controller.SaveAudit(); 
        controller.SubmitAudit(); 
               
        controller.RejectAudit();
       // //System.AssertEquals('Rejected', controller.installAudit.Status__c);
        
        controller.ApproveAudit();
        ////System.AssertEquals('SR Approved', controller.installAudit.Status__c);
        
        controller.CancelAuditFeedbackEdits();
        
        controller.ReturnToInstallAudit();
        
        controller.UserType = 'Auditor';
        ////System.AssertEquals(true, controller.getIsAuditor());
        
        controller.UserType = 'Partner';
        ////System.AssertEquals(true, controller.getIsPartner());
        
        controller.UserType = 'Sunrun';
        ////System.AssertEquals(true, controller.getIsSunrun());  
       // //System.AssertEquals(false, controller.getIsAdmin());
        //System.AssertEquals(false, controller.getIsAuditor());
        //System.AssertEquals(false, controller.getIsPartner());
        
        controller.UserType = 'Admin';
        //System.AssertEquals(true, controller.getIsAdmin());
                      
             
    }    
    
    public static testmethod void Test_AuditTemplateControllerWithFeedbackNewChanges (){
    
      //DataSetup  
        List<Audit_Criteria__c> criterias = new List<Audit_Criteria__c>();
        Audit_Criteria__c criteria1 = new Audit_Criteria__c(Active__c = true, Criteria_Description__c = 'Test Criteria 1', Criteria_Id__c = '01-01', 
                                                Criteria_Type__c = 'EPC Compliance', Notes_Evaluation__c = 'Test Notes 1', Point_Value__c = 5, 
                                                Priority_Criteria__c = 'Y', System_Component__c = 'Test Comp 1');
        criterias.add(criteria1);
        
        Audit_Criteria__c criteria2 = new Audit_Criteria__c(Active__c = true, Criteria_Description__c = 'Test Criteria 2', Criteria_Id__c = '01-02', 
                                                Criteria_Type__c = 'EPC Compliance', Notes_Evaluation__c = 'Test Notes 2', Point_Value__c = 5, 
                                                Priority_Criteria__c = 'N', System_Component__c = 'Test Comp 2', Auto_Calculated__c = true);
        criterias.add(criteria2);     
        
        Audit_Criteria__c criteria3 = new Audit_Criteria__c(Active__c = true, Criteria_Description__c = 'Test Criteria 3', Criteria_Id__c = '01-03', 
                                                Criteria_Type__c = 'Test Type', Notes_Evaluation__c = 'Test Notes 3', Point_Value__c = 5, 
                                                Priority_Criteria__c = 'Y', System_Component__c = 'Test Comp 3');

        criterias.add(criteria3); 

        Audit_Criteria__c criteria4 = new Audit_Criteria__c(Active__c = true, Criteria_Description__c = 'Test Criteria 4', Criteria_Id__c = '01-04', 
                                                Criteria_Type__c = 'Test Type', Notes_Evaluation__c = 'Test Notes 4', Point_Value__c = 5, 
                                                Priority_Criteria__c = 'Y', System_Component__c = 'Test Comp 4', Auto_Calculated__c = true);                                                
        criterias.add(criteria4);    
        insert criterias;        
                                                       
        Account a = new Account(name='Test Acct1');
        insert a;
        Generation_Assets__c ga = new Generation_Assets__c(Account_Name__c=a.id, Name='99887' ); 
        insert ga;
                 
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
        
       // Sun_Run_Audit_List_Settings__c settings = new Sun_Run_Audit_List_Settings__c (Name = 'Pagination Rows', Value__c = 100);
        //insert settings;
        
        ApexPages.StandardController standardController = new ApexPages.StandardController(ga);
        CreateInstallAuditController controller = new CreateInstallAuditController(standardController);
        controller.create();
        
        List<Install_Audit__c> installAudits = [select Id, Name, Substantial_Fails__c, Total_Points_Accrued__c, Total_Points_Possible__c, 
                                              Corporate_Metric__c, Partner_Metric__c, Priority_Criteria_Missed__c, EPC_Discrepancies__c 
                                              From Install_Audit__c];
        
        //System.AssertEquals(1, installAudits.size());
        //System.AssertEquals(20, installAudits[0].Total_Points_Possible__c);
        //System.AssertEquals(0, installAudits[0].Total_Points_Accrued__c);
        
        List<Audit_Feedback__c> feedbacks = [select Id, Name, QA_Score__c, Point_Value__c, Audit_Criteria__r.Point_Value__c, EPC_Compliance_Criteria__c, Priority_Criteria__c
                                             from Audit_Feedback__c where Install_Audit__c = :installAudits[0].Id];
                                             
        for(Audit_Feedback__c feedback: feedbacks)
        {
            //System.AssertEquals(null, feedback.QA_Score__c);
            
        } 
        
        List<Site_Characteristic__c> sites = [select Id, Name, EPC_Average_Annual_Shading__c, EPC_Azimuth__c,
                                                 EPC_Tilt__c, Inverter_Count__c, Inverter_Manufacturer__c,Observed_Average_Annual_Shading__c,Observed_Azimuth__c,Observed_Tilt__c,Panel_Count__c,Panel_Manufacturer__c,Proposal_Name__c
                                               from Site_Characteristic__c where Install_Audit__c = :installAudits[0].Id];
        ////System.AssertEquals(6, sites.size());  
        
        //for(Site_Characteristic__c site:sites)
        //{
        //    if(site.Panel_Manufacturer__c == 'Test Panel 6')
        //       //System.AssertEquals(1, site.EPC_Average_Annual_Shading__c);
        //       //System.AssertEquals(null, site.Observed_Average_Annual_Shading__c);
        //}
                                             
        PageReference pageRef = Page.AuditFeedback;
        Test.setCurrentPage(pageRef);   
        ApexPages.currentPage().getParameters().put('Install_Audit__c', installAudits[0].Id);
        
        AuditFeedbackController feedbackController = new AuditFeedbackController(null);  
        //feedbackController.CalculateAutoCriteria1();
        feedbackController.SaveAudit();
        
        
        List<Audit_Feedback__c> feedbacks2 = [select Id, Audit_Criteria__r.Criteria_Id__c, Name, QA_Score__c, Point_Value__c, Audit_Criteria__r.Point_Value__c, EPC_Compliance_Criteria__c, Priority_Criteria__c
                                             from Audit_Feedback__c where Install_Audit__c = :installAudits[0].Id];
                                             
        for(Audit_Feedback__c feed:feedbacks2)
        {
            if(feed.Audit_Criteria__r.Criteria_Id__c == '01-01')
            {
                //System.AssertEquals(null, feed.QA_Score__c);
            }
            if(feed.Audit_Criteria__r.Criteria_Id__c == '01-02')
            {
                //System.AssertEquals('Fail', feed.QA_Score__c);
            }
            if(feed.Audit_Criteria__r.Criteria_Id__c == '01-03')
            {
                //System.AssertEquals(null, feed.QA_Score__c);    
            }
            //if(feed.Audit_Criteria__r.Criteria_Id__c == '01-04')
                //System.AssertEquals('Fail', feed.QA_Score__c);        
        }
        
        for(AuditFeedbackController.AuditFeedbackModel afm: feedbackController.auditFeedbackList)
        {
            if(afm.ac.Criteria_Id__c == '01-01' || afm.ac.Criteria_Id__c == '01-03' )
                afm.af.QA_Score__c = 'Pass';
        }
        
        feedbackController.SaveAudit();
 
        List<Install_Audit__c> installAudits2 = [select Id, Name, Substantial_Fails__c, Total_Points_Accrued__c, Total_Points_Possible__c, 
                                              Corporate_Metric__c, Partner_Metric__c, Priority_Criteria_Missed__c, EPC_Discrepancies__c, Score__c 
                                              From Install_Audit__c];
        
        //System.AssertEquals(1, installAudits2.size());
        //System.AssertEquals(20, installAudits2[0].Total_Points_Possible__c);
        //System.AssertEquals(10, installAudits2[0].Total_Points_Accrued__c);
        //System.AssertEquals(50, installAudits2[0].Score__c);
        //System.AssertEquals(1, installAudits2[0].Priority_Criteria_Missed__c);
        //System.AssertEquals(1, installAudits2[0].EPC_Discrepancies__c);
        //System.AssertEquals('Fail', installAudits2[0].Corporate_Metric__c);
        //System.AssertEquals('Fail', installAudits2[0].Partner_Metric__c); 
        //System.AssertEquals(0, installAudits2[0].Substantial_Fails__c);      
        
        for(SiteCharacteristic s:feedbackController.siteCharacteristics)
        {
            s.SiteCharacteristic.Observed_Azimuth__c = 100;
            s.SiteCharacteristic.Observed_Tilt__c = 0;
            s.SiteCharacteristic.Observed_Average_Annual_Shading__c = 1;
        }
        
        feedbackController.CalculateAutoCriteria1();
        
        for(SiteCharacteristic s2:feedbackController.siteCharacteristics)
        {
            //System.AssertEquals(1, s2.SiteCharacteristic.Observed_Average_Annual_Shading__c);
            //System.AssertEquals(100, s2.SiteCharacteristic.Observed_Azimuth__c);
            //System.AssertEquals(0, s2.SiteCharacteristic.Observed_Tilt__c);                 
        }
            
        feedbackController.SaveAudit();
        
        List<Site_Characteristic__c> sites2 = [select Id, Name, EPC_Average_Annual_Shading__c, EPC_Azimuth__c,
                                                 EPC_Tilt__c, Inverter_Count__c, Inverter_Manufacturer__c,Observed_Average_Annual_Shading__c,Observed_Azimuth__c,Observed_Tilt__c,Panel_Count__c,Panel_Manufacturer__c,Proposal_Name__c
                                               from Site_Characteristic__c where Install_Audit__c = :installAudits[0].Id];
        //System.AssertEquals(6, sites2.size());  
        
        for(Site_Characteristic__c site2:sites2)
        {
            //System.AssertEquals(1, site2.Observed_Average_Annual_Shading__c);
            //System.AssertEquals(100, site2.Observed_Azimuth__c);
            //System.AssertEquals(0, site2.Observed_Tilt__c);                              
        }
        
        for(AuditFeedbackController.AuditFeedbackModel afm2: feedbackController.auditFeedbackList)
        {
            //if(afm2.ac.Criteria_Id__c == '01-02')
                //System.AssertEquals('Fail', afm2.af.QA_Score__c);
        }
           
        List<Install_Audit__c> installAudits3 = [select Id, Name, Substantial_Fails__c, Total_Points_Accrued__c, Total_Points_Possible__c, 
                                              Corporate_Metric__c, Partner_Metric__c, Priority_Criteria_Missed__c, EPC_Discrepancies__c, Score__c 
                                              From Install_Audit__c];
        
        //System.AssertEquals(1, installAudits3.size());
        //System.AssertEquals(20, installAudits3[0].Total_Points_Possible__c);
        //System.AssertEquals(15, installAudits3[0].Total_Points_Accrued__c);
        //System.AssertEquals(75, installAudits3[0].Score__c);
        //System.AssertEquals(0, installAudits3[0].Priority_Criteria_Missed__c);
        //System.AssertEquals(1, installAudits3[0].EPC_Discrepancies__c);
        //System.AssertEquals('Fail', installAudits3[0].Corporate_Metric__c);
        //System.AssertEquals('Fail', installAudits3[0].Partner_Metric__c); 
        //System.AssertEquals(0, installAudits3[0].Substantial_Fails__c);          
        
        for(SiteCharacteristic s:feedbackController.siteCharacteristics)
        {
            s.SiteCharacteristic.Observed_Tilt__c = 100;
        }
        feedbackController.CalculateAutoCriteria1();
        feedbackController.SaveAudit();
        
        for(AuditFeedbackController.AuditFeedbackModel afm2: feedbackController.auditFeedbackList)
        {
            //if(afm2.ac.Criteria_Id__c == '01-02')
                //System.AssertEquals('Pass', afm2.af.QA_Score__c);
        }        
        
        
        List<Install_Audit__c> installAudits4 = [select Id, Name, Substantial_Fails__c, Total_Points_Accrued__c, Total_Points_Possible__c, 
                                              Corporate_Metric__c, Partner_Metric__c, Priority_Criteria_Missed__c, EPC_Discrepancies__c, Score__c 
                                              From Install_Audit__c];
        
        //System.AssertEquals(1, installAudits4.size());
        //System.AssertEquals(20, installAudits4[0].Total_Points_Possible__c);
        //System.AssertEquals(20, installAudits4[0].Total_Points_Accrued__c);
        //System.AssertEquals(100, installAudits4[0].Score__c);
        //System.AssertEquals(0, installAudits4[0].Priority_Criteria_Missed__c);
        //System.AssertEquals(0, installAudits4[0].EPC_Discrepancies__c);
        //System.AssertEquals('Pass', installAudits4[0].Corporate_Metric__c);
        //System.AssertEquals('Pass', installAudits4[0].Partner_Metric__c); 
        //System.AssertEquals(0, installAudits4[0].Substantial_Fails__c);          
        
   }
    
    
}