/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
 
@isTest(SeeAllData=true)
private class testCustomerReferralsClass {

    static testMethod void myUnitTest() {
    // Create test data        
    // SunRunTestRunner
      Profile prf = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
      User u = new User(Alias = 'SunRunTR', Email='SunRunTestRunner@testorg.com', 
      EmailEncodingKey='UTF-8', LastName='SunRunTestRunner', LanguageLocaleKey='en_US', 
      LocaleSidKey='en_US', ProfileId = prf.Id, 
      TimeZoneSidKey='America/Los_Angeles', UserName='SunRunTestRunner@testorg.com');
    System.runAs(u) 
    {   
    
    //
    List<Account> listA = new List<Account>();
    Account sourceacct = new Account(name='Test Source',Zip_6__c='12345123456');
    listA.add(sourceacct);
    Account a = New Account();
    a.Name = 'Account Test';    
    listA.add(a);   
    insert listA; 
    //
    Opportunity Opp = new Opportunity();
    Opp.Name = 'TestOppty';
    Opp.StageName = 'Qualified';
    Opp.CloseDate = Date.Today().addDays(18);    
    Opp.AccountId = a.Id;
    insert Opp;  
    //
    /*Contact c5 = new Contact();
    c5.Email = 'test@test.com';
    c5.Phone = '1234567890';
    c5.LastName = 'Tester';
    c5.AccountId = sourceacct.id;
    insert c5;
    OpportunityContactRole ocr5 = new OpportunityContactRole();
    ocr5.ContactId = c5.Id;
    ocr5.Role = 'Other';
    ocr5.OpportunityId = Opp.Id;
    insert ocr5;*/
    //Promotions
    Boolean bHasPrimary = false;
    list<Promotion__c> listPromo = new List<Promotion__c>();
    Promotion__c prim = new Promotion__c();
    for(Promotion__c promo:[select id from Promotion__c where Primary_Promotion__c = true])
    {
        bHasPrimary = true;
        prim = promo;
    }
    if(!bHasPrimary)
    {   
       //
       prim.Name = 'Summer Prim';
       prim.Promotion_Type__c = 'Customer';    
       prim.Start_Date__c = Date.Today().addYears(-5);
       prim.End_Date__c = Date.Today().addYears(5);
       prim.Expires_after_usage__c = 999;
       prim.In_Time_Duration_Length__c = 1;
       prim.In_Time_Duration_Unit__c = 'Weeks';
       prim.Primary_Promotion__c = true;    
       prim.Referral_Payout_on1__c = 'Asset';
       prim.At_Stage1__c = 'NTP';
       prim.Referee_Payment_Option1__c = 'Check / Credit on Monthly Bill';    
       prim.Referrer_Payment_Option1__c = 'Check / Credit on Monthly Bill';
       prim.Referee_Payment_Amount1__c = 100;
       prim.Referrer_Payment_Amount1__c = 100;
       listPromo.add(prim);
    }
    Promotion__c p = new Promotion__c();
    p.Name = 'Summer Blues';
    p.Promotion_Type__c = 'Customer';    
    p.Start_Date__c = Date.Today().addYears(-1);
    p.End_Date__c = Date.Today().addYears(1);
    p.Expires_after_usage__c = 1;
    p.In_Time_Duration_Length__c = 1;
    p.In_Time_Duration_Unit__c = 'Weeks';
    p.Primary_Promotion__c = false;    
    p.Referral_Payout_on1__c = 'Asset';
    p.At_Stage1__c = 'NTP';
    p.Referee_Payment_Option1__c = 'Check / Credit on Monthly Bill';    
    p.Referrer_Payment_Option1__c = 'Check / Credit on Monthly Bill';
    p.Referee_Payment_Amount1__c = 100;
    p.Referrer_Payment_Amount1__c = 100;
    listPromo.add(p);
    //
    Promotion__c paDV = new Promotion__c();
    pADV.Name = 'ADV1';
    pADV.Promotion_Type__c = 'Advocate';       
    pADV.Start_Date__c = Date.Today().addYears(-1);
    pADV.End_Date__c = Date.Today().addYears(1);
    pADV.Expires_after_usage__c = 1;
    pADV.In_Time_Duration_Length__c = 1;
    pADV.In_Time_Duration_Unit__c = 'Weeks';
    pADV.Primary_Promotion__c = false;    
    pADV.Referral_Payout_on1__c = 'Asset';
    pADV.At_Stage1__c = 'NTP';
    pADV.Referee_Payment_Option1__c = 'Check / Credit on Monthly Bill';    
    pADV.Referrer_Payment_Option1__c = 'Check / Credit on Monthly Bill';
    pADV.Referee_Payment_Amount1__c = 100;
    pADV.Referrer_Payment_Amount1__c = 100;
    listPromo.add(pADV);
    //         
    Promotion__c pEMP = new Promotion__c();
    pEMP.Name = 'EMP1';
    pEMP.Promotion_Type__c = 'Employee';       
    pEMP.Start_Date__c = Date.Today().addYears(-1);
    pEMP.End_Date__c = Date.Today().addYears(1);
    pEMP.Expires_after_usage__c = 1;
    pEMP.In_Time_Duration_Length__c = 1;
    pEMP.In_Time_Duration_Unit__c = 'Weeks';
    pEMP.Primary_Promotion__c = false;    
    pEMP.Referral_Payout_on1__c = 'Asset';
    pEMP.At_Stage1__c = 'NTP';
    pEMP.Referee_Payment_Option1__c = 'Check / Credit on Monthly Bill';    
    pEMP.Referrer_Payment_Option1__c = 'Check / Credit on Monthly Bill';
    pEMP.Referee_Payment_Amount1__c = 100;
    pEMP.Referrer_Payment_Amount1__c = 100;
    listPromo.add(pEMP);
    Promotion__c pPTR = new Promotion__c();
    pPTR.Name = 'PTR1';
    pPTR.Promotion_Type__c = 'Partner';        
    pPTR.Start_Date__c = Date.Today().addYears(-1);
    pPTR.End_Date__c = Date.Today().addYears(1);
    pPTR.Expires_after_usage__c = 1;
    pPTR.In_Time_Duration_Length__c = 1;
    pPTR.In_Time_Duration_Unit__c = 'Weeks';
    pPTR.Primary_Promotion__c = false;    
    pPTR.Referral_Payout_on1__c = 'Asset';
    pPTR.At_Stage1__c = 'NTP';
    pPTR.Referee_Payment_Option1__c = 'Check / Credit on Monthly Bill';    
    pPTR.Referrer_Payment_Option1__c = 'Check / Credit on Monthly Bill';
    pPTR.Referee_Payment_Amount1__c = 100;
    pPTR.Referrer_Payment_Amount1__c = 100;
    listPromo.add(pPTR);
    //
    insert listPromo;   
    //Contact
    List<Contact> listCon = new List<Contact>();
    Contact c = new Contact();
    c.AccountId = a.Id;
    c.LastName = 'Smith';
    c.FirstName = 'Smitty';
    c.Email = 'Smith@smitty.com.xyz';
    listCon.add(c);
    //
    Contact c2 = new Contact();
    c2.AccountId = a.Id;
    c2.LastName = 'Smith';
    c2.FirstName = 'Smitty';
    c2.Email = 'Smith@smitty.com.xyz';    
    listCon.add(c2);
    insert listCon;
    //
    List<Referral_Input__c> listRef = new List<Referral_Input__c>();
    Referral_Input__c ri = new Referral_Input__c();
    ri.Target_Contact_Id__c = c.Id;
    ri.Source_Contact_Id__c = c2.Id;
    ri.Promotion__c = p.id;
    ri.Source_Account_Id__c = sourceacct.id;
    listRef.add(ri);
    Referral_Input__c ri2 = new Referral_Input__c();
    ri2.Target_Contact_Id__c = c.Id;
    ri2.Source_Contact_Id__c = c2.Id;
    ri2.Promotion__c = p.id;
    ri2.Source_Account_Id__c = sourceacct.id;
    listRef.add(ri2);
    insert listRef;
    //Initial Lead
    List<Lead> listLead = new List<Lead>();
    Lead L1 = new Lead();
    L1.Company = 'Test Company';
    L1.Email = 'test@test.com';
    L1.Referred_by__c = sourceacct.id;
    L1.Phone = '1234567890';
    L1.LastName = 'Tester';
    L1.FirstName = 'Joe';
    L1.Referred_By_Code__c = 'RR987654';
    L1.LeadSource = 'Referral - Customer Portal';
    L1.Referred_by_Contact__c = c.Id;
    L1.Zip_6__c='12345123456';
    L1.Promotion_Code__c = p.Promotion_Code__c;
    listLead.add(L1);
    //Duplicate Lead
    Lead L2 = new Lead();
    L2.Company = 'Test Company';
    L2.Email = 'test@test.com';
    L2.Referred_by__c = sourceacct.id;
    L2.Phone = '1234567890';
    L2.LastName = 'Tester';
    L2.FirstName = 'Joe';
    L2.Referred_By_Code__c = 'RR987657';
    L2.LeadSource = 'Referral - Customer Portal';
    L2.Referred_by_Contact__c = c.Id;
    L2.Zip_6__c='12345123456';
    listLead.add(L2);
    //New Lead for same source    
    Lead L3 = new Lead();
    L3.Company = 'Test Company 2';
    L3.Email = 'test2@test2.com';
    L3.Referred_by__c = sourceacct.id;
    L3.Phone = '1234567892';
    L3.LastName = 'Tester2';
    L3.FirstName = 'Joe2';
    L3.Referred_By_Code__c = 'RR987652';
    L3.LeadSource = 'Referral - Customer Portal';
    L3.Referred_by_Contact__c = c.Id;    
    listLead.add(L3);
    Test.startTest();
    insert listLead;
    /*
    //
    //Update Leads to fire trigger
    L1.Referred_by_Contact__c = c2.Id;
    //L2.Referred_by_Contact__c = null;
    L3.Lead_Status__c = Label.Lead_Status_Duplicate;
    L3.Why_Unqualified__c = Label.Lead_Why_Unqualified_DuplicateLeadFound;    
    List<Lead> listLeadUpdates = new List<Lead>();
    listLeadUpdates.add(L1);
    listLeadUpdates.add(L2);
    listLeadUpdates.add(L3);
    update listLeadUpdates;
    */
    //
    //Convert Lead
   
    //
    Opportunity O1 = new Opportunity();
    O1.Name = 'TestOppty';
    O1.StageName = 'Qualified';
    O1.CloseDate = Date.Today().addDays(18);
    O1.Referral__c = ri.Id;
    O1.AccountId = a.Id;
    insert O1;
    OpportunityContactRole ocr = new OpportunityContactRole();
    ocr.OpportunityId = O1.Id;
    ocr.ContactId = c.Id;
    ocr.Role = 'Other';
    insert ocr;
    //
    Generation_Assets__c ga = new Generation_Assets__c();
    ga.Opportunity_Name__c = O1.Id;
    ga.Name = '99999';
    ga.Home_Address__c = '123 Main St';
    ga.City__c = 'Sunrunville';
    ga.Zip__c = '12345';
    ga.Customer_Contact__c = c.Id;
    ga.Account_Name__c = a.Id;
    ga.Welcome_Call__c = Date.Today();
    ga.SR_Signoff__c = Date.Today().addDays(-19);
    //insert ga;
    //
    Referral_Input__c ri3 = new Referral_Input__c();
    ri3.Target_Contact_Id__c = c.Id;
    ri3.Source_Contact_Id__c = c2.Id;
    ri3.Promotion__c = p.id;
    ri3.Source_Account_Id__c = sourceacct.id;
    ri3.Opportunity__c = O1.Id;
    insert ri3;
    //    
    //ga.M1_proof_panel_inverter_delivery__c = Date.Today();
    //ga.M2_proof_substantial_completion__c = Date.Today();
    //ga.NTP_Granted__c = Date.Today();
    //ga.PTO__c = Date.Today();
    //update ga;
    //UPDATE Promo
    List<Promotion__c> listP = new List<Promotion__c>();
    try{
      prim.Expires_after_usage__c = 1;      
      pADV.Primary_Promotion__c = true;
      listP.add(prim);
      listP.add(pADV);
      update listP;
    }
    catch(Exception ex)
    {
        //
    }
    try{
        delete p;
    }catch(Exception e){
        //
    }
    Test.stopTest();    
    /*
    Database.Leadconvert lc = new Database.Leadconvert();
    lc.setLeadId(L3.id);    
    LeadStatus convertStatus = [select id,MasterLabel from LeadStatus where isConverted=true limit 1];
    lc.setConvertedStatus(convertStatus.MasterLabel);
    Database.LeadConvertResult lcr = Database.convertLead(lc);
    */
    }        
    }
}