/**
Peter Alexander Mandy
10232012 104119
 */
@isTest
private class testGenAssetTriggers {

    static testMethod void myUnitTest() {
//
    Promotion__c prim = new Promotion__c();
    list<Promotion__c> listPromo = new List<Promotion__c>();
    Boolean bHasPrimary = false;
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
    if(!listPromo.isEmpty())
    {
       insert listPromo;
    }   
//
    List<Account> listA = new List<Account>();
    Account sourceacct = new Account(name='Test Test GA Trigger 1',Zip_6__c='12345123456');    
    listA.add(sourceacct);
    Account targetacct = New Account();
    targetacct.Name = 'Account Test GA Trigger 2';    
    listA.add(targetacct);   
    insert listA;   
//
    List<Contact> listC = new List<Contact>();
    Contact sourceContact = new Contact();
    sourceContact.FirstName = 'TestGA';
    sourceContact.LastName = 'TestAcctGA';
    sourceContact.Email = 'emailfake@fakeemail.net';
    sourceContact.AccountId = sourceacct.Id;
    listC.add(sourceContact);
    Contact targetContact = new Contact();
    targetContact.FirstName = 'TestGA2';
    targetContact.LastName = 'TestAcctGA2';
    targetContact.Email = 'emailfake@fakeemail2.net';
    targetContact.AccountId = targetacct.Id;
    listC.add(targetContact);        
    insert listC;
    //
        Opportunity Opp = new Opportunity();
        Opp.Name = 'TestOpptyTriggers';
        Opp.StageName = 'Qualified';
        Opp.CloseDate = Date.Today().addDays(18);    
        Opp.AccountId = targetacct.Id;
        Opp.Sales_Representative__c = targetContact.Id;
        //insert Opp;     
    //
    List<Referral_Input__c> listRef = new List<Referral_Input__c>();
    Referral_Input__c ri = new Referral_Input__c();
    ri.Target_Contact_Id__c = sourceContact.Id;
    ri.Source_Contact_Id__c = targetContact.Id;
    ri.Promotion__c = prim.id;
    ri.Source_Account_Id__c = targetacct.id;    
    listRef.add(ri);
    Referral_Input__c ri2 = new Referral_Input__c();
    ri2.Target_Contact_Id__c = targetContact.Id;
    ri2.Source_Contact_Id__c = sourceContact.Id;
    ri2.Promotion__c = prim.id;
    ri2.Source_Account_Id__c = sourceacct.id;
    listRef.add(ri2);
    insert listRef;
    //
    Generation_Assets__c ga = new Generation_Assets__c();
    ga.Account_Name__c = sourceacct.Id;
    ga.Customer_Contact__c = sourceContact.Id;
    ga.Home_Address__c = 'Test Class';
    ga.City__c = 'Los Gatos';
    ga.Zip__c = '95032';
    ga.Asset_Status__c = 'Plans Approved, Awaiting NTP';
    ga.Facility_Design_Approved__c = date.today();
    ga.NTP_Granted__c = date.today();
    ga.M1_proof_panel_inverter_delivery__c = date.today();
    ga.M2_proof_substantial_completion__c = date.today();
    ga.PTO__c = date.today();
    ga.TE_Fund_name__c = 'ThisEisFunIX';
    
    ga.Referral_Input__c = ri.Id;

        ga.SR_Signoff__c = date.today();
        ga.Facility_Design_Approved__c = date.today();
        ga.Complete_Deal_Received__c = date.today();
 		ga.Initial_Deposit_Processed__c = date.today();
 		ga.Initial_Deposit_Amount_Received__c = 10000;
		ga.Initial_Deposit_Amount__c = 10000;
		ga.Rebate_Conf_Rec_d__c  = date.today();
		ga.Final_Rebate_Amount__c = 100.00;
		ga.Meter_Serial_Num__c = 'Test1234ABC12345';
		ga.Meter_Test_Date__c = date.today();
		ga.Rebate_Conf_Num__c = '234533';
    //
    insert ga;
    //
    Referral_Input__c ri3 = new Referral_Input__c();
    ri3.Target_Contact_Id__c = targetContact.Id;
    ri3.Source_Contact_Id__c = sourceContact.Id;
    ri3.Promotion__c = prim.id;
    ri3.Source_Account_Id__c = sourceacct.id;
    ri3.Generation_Asset__c = ga.Id;
    ri3.Opportunity__c = Opp.Id;
    insert ri3;    
    //
    ri3.Milestone_1_Status__c = Label.ReferralReadyForPayment;
    update ri3;    
    //
    }
}