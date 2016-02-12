@isTest(seealldata=true)
public class SendEmailNtpPtoCCTest {
    
    private static BaseClass utils = new BaseClass();
    
    testmethod public static void sendemailscentppto(){
        
        //For role 'Billing Contact
        		
        Sf.settingsService.setString(Constants.RequestPaymentBaseUrl, 'RequestPaymentBaseUrl');
        
        Account acc = BaseClassTest.createTestAccount();
        
        Contact con = New Contact(FirstName='John',LastName='Doe',Email='johndoe@test.com',AccountId=acc.Id,Title='Sales Rep',Job_Function__c='Inside Sales',Division__c='Inside Sales');
        insert con;
        
        Opportunity opty = New Opportunity(AccountId=acc.Id,Name= 'acc.Name+opp',StageName='2. Appointment Process',Opportunity_Status__c='Open',CloseDate=system.today()+90);
        insert opty;
       
        OpportunityContactRole ocr = new OpportunityContactRole(Role='Billing Contact',ContactId=con.Id,OpportunityId=opty.Id);
        insert ocr;
        
        servicecontract sc1 = new servicecontract(Name='111111111111111',Opportunity__c=opty.Id,Billing_Method__c='Pay by Check',ContactId=con.Id,Agreement_Type__c='Custom');
        insert sc1;

        sc1 = [Select Id, Name,ContactId,Customer_Email__c from ServiceContract where Id=:sc1.Id];
        
        Service_Contract_Event__c  sce = New Service_Contract_Event__c(
        Complete_Deal_Received__c=system.today(),Final_Rebate_Amount__c=250,    
        Rebate_Conf_Rec_d__c=system.today(),service_contract__c=sc1.id);
        insert sce;
        
        sce.NTP_Granted__c = system.today();
        sce.PTO__c = system.today();
        sce.SR_Signoff__c= system.today();
        sce.Facility_Design_Approved__c= system.today();
        sce.Complete_Deal_Received__c = system.today();
        sce.Final_Rebate_Amount__c = 250;
        sce.Initial_Deposit_Processed__c = system.today();
        sce.Initial_Deposit_Amount_Received__c = 250;
        sce.Initial_Deposit_Amount__c = 250;
        update sce;
        
        opty = [Select id,Payment_Request_Url__c,Payment_Request_Token_Status__c,Payment_Request_Contact_Role_Id__c from Opportunity where Id=:opty.Id];
        system.assertEquals('Valid', opty.Payment_Request_Token_Status__c);
        system.assertEquals(true,SendEmailClass.checkptosend);
    }
    
    testmethod static void sendemailscentppto1(){
        
        //For role that is not Billing Contact NTP
        
        Sf.settingsService.setString(Constants.RequestPaymentBaseUrl, 'RequestPaymentBaseUrl');
        
        Account acc = BaseClassTest.createTestAccount();
        
        Contact con = New Contact(FirstName='John',LastName='Doe',Email='johndoe@test.com',AccountId=acc.Id,Title='Sales Rep',Job_Function__c='Inside Sales',Division__c='Inside Sales');
        insert con;
        
        Opportunity opty = New Opportunity(AccountId=acc.Id,Name= 'acc.Name+opp',StageName='2. Appointment Process',Opportunity_Status__c='Open',CloseDate=system.today()+90);
        insert opty;
       
        OpportunityContactRole ocr = new OpportunityContactRole(Role='Billing',ContactId=con.Id,OpportunityId=opty.Id);
        insert ocr;
        
        servicecontract sc2 = new servicecontract(Name='2222222222222222',Opportunity__c=opty.Id,Billing_Method__c='Pay by Check',ContactId=con.Id,Agreement_Type__c='Custom');
        insert sc2;
        sc2 = [Select Id, Name,ContactId,Customer_Email__c from ServiceContract where Id=:sc2.Id];
        
        Service_Contract_Event__c  sce = New Service_Contract_Event__c(
        Complete_Deal_Received__c=system.today(),Final_Rebate_Amount__c=250,    
        Rebate_Conf_Rec_d__c=system.today(),service_contract__c=sc2.id);
        insert sce;
        
        sce.NTP_Granted__c = system.today();
        sce.SR_Signoff__c= system.today();
        sce.Facility_Design_Approved__c= system.today();
        sce.Complete_Deal_Received__c = system.today();
        sce.Final_Rebate_Amount__c = 250;
        sce.Initial_Deposit_Processed__c = system.today();
        sce.Initial_Deposit_Amount_Received__c = 250;
        sce.Initial_Deposit_Amount__c = 250;
        update sce;
        
        opty = [Select id,Payment_Request_Url__c,Payment_Request_Token_Status__c,Payment_Request_Contact_Role_Id__c from Opportunity where Id=:opty.Id];
        system.assertEquals('Valid', opty.Payment_Request_Token_Status__c);
    }
    
    testmethod static void sendemailscentppto2(){
        
        //For role that is not Billing Contact PTO
        
        Sf.settingsService.setString(Constants.RequestPaymentBaseUrl, 'RequestPaymentBaseUrl');
        
        Account acc = BaseClassTest.createTestAccount();
        
        Contact con = New Contact(FirstName='John',LastName='Doe',Email='johndoe@test.com',AccountId=acc.Id,Title='Sales Rep',Job_Function__c='Inside Sales',Division__c='Inside Sales');
        insert con;
        
        Opportunity opty = New Opportunity(AccountId=acc.Id,Name= 'acc.Name+opp',StageName='2. Appointment Process',Opportunity_Status__c='Open',CloseDate=system.today()+90);
        insert opty;
       
        OpportunityContactRole ocr = new OpportunityContactRole(Role='Billing',ContactId=con.Id,OpportunityId=opty.Id);
        insert ocr;
        
        servicecontract sc3 = new servicecontract(Name='33333333333333',Opportunity__c=opty.Id,Billing_Method__c='Pay by Check',ContactId=con.Id,Agreement_Type__c='Custom');
        insert sc3;
        sc3 = [Select Id, Name,ContactId,Customer_Email__c from ServiceContract where Id=:sc3.Id];
        
        Service_Contract_Event__c  sce = New Service_Contract_Event__c(
        Complete_Deal_Received__c=system.today(),Final_Rebate_Amount__c=250,    
        Rebate_Conf_Rec_d__c=system.today(),service_contract__c=sc3.id);
        insert sce;
        
        sce.PTO__c = system.today();
        sce.SR_Signoff__c= system.today();
        sce.Facility_Design_Approved__c= system.today();
        sce.Complete_Deal_Received__c = system.today();
        sce.Final_Rebate_Amount__c = 250;
        sce.Initial_Deposit_Processed__c = system.today();
        sce.Initial_Deposit_Amount_Received__c = 250;
        sce.Initial_Deposit_Amount__c = 250;
        update sce;
        
        opty = [Select id,Payment_Request_Url__c,Payment_Request_Token_Status__c,Payment_Request_Contact_Role_Id__c from Opportunity where Id=:opty.Id];
        system.assertEquals('Valid', opty.Payment_Request_Token_Status__c);
    }
    
     testmethod static void sendemailcc(){
        
        Sf.settingsService.setString(Constants.RequestPaymentBaseUrl, 'RequestPaymentBaseUrl');
        
        Account acc	= BaseClassTest.createTestAccount();
        
        Contact con = New Contact(FirstName='John',LastName='Doe',Email='johndoe@test.com',AccountId=acc.Id,Title='Sales Rep',Job_Function__c='Inside Sales',Division__c='Inside Sales');
        insert con;
        
        Opportunity opty = New Opportunity(AccountId=acc.Id,Name= 'acc.Name+opp',StageName='2. Appointment Process',Opportunity_Status__c='Open',CloseDate=system.today()+90,Deal_Id__c='588316188443');
        insert opty;
        
        OpportunityContactRole ocr = new OpportunityContactRole(Role='Billing Contact',ContactId=con.Id,OpportunityId=opty.Id);
        insert ocr;
        
        Customer_Credit__c cc = new Customer_Credit__c(First_Name__c = 'John', Last_Name__c = 'Doe', Customer_Email__c = 'johndoe@test.com', Sunrun_Credit_Status__c = null, Status__c = 'N/A', Credit_Email_Sent__c = false, Deal_Id__c = opty.Deal_Id__c, Contact__c = con.Id);
        insert cc;

        Profile p = [SELECT Id FROM Profile WHERE Name='Customer Portal Manager Custom'];
   		User u = new User(alias = 'standt', Title = 'Test', email='test@test.com', emailencodingkey='UTF-8', FirstName = 'Testing', lastname='Testing', languagelocalekey='en_US', localesidkey='en_US', IsPortalSelfRegistered = true, profileid = p.Id, ContactId = con.id, timezonesidkey='America/Los_Angeles', CommunityNickname = 'Tom', isActive = true, username='testsendemailcust@test.com');
		insert u;
        
        cc = [Select Sunrun_Credit_Status__c,Status__c,Credit_Email_Sent__c,Deal_Id__c from Customer_Credit__c where Id=:cc.Id];
        cc.Sunrun_Credit_Status__c = 'PASS';
        update cc;

		cc = [Select Credit_Email_Sent__c from Customer_Credit__c where Id=:cc.Id];           
        system.assertEquals(true, cc.Credit_Email_Sent__c);
        
        String tempid;
        
        system.runas(u){
		Customer_Credit__c cc1 = new Customer_Credit__c(First_Name__c = 'John', Last_Name__c = 'Doe', Customer_Email__c = 'johndoe@test.com', Sunrun_Credit_Status__c = null, Status__c = 'N/A', Credit_Email_Sent__c = false, Deal_Id__c = opty.Deal_Id__c, Contact__c = con.Id);
        insert cc1;
        tempid = cc1.Id;
        }
        
        Customer_Credit__c cc1 = [Select Sunrun_Credit_Status__c,Status__c,Credit_Email_Sent__c,Deal_Id__c from Customer_Credit__c where Id=:tempid];
        cc1.Sunrun_Credit_Status__c = 'PASS';
        update cc1;
            
		cc1 = [Select Credit_Email_Sent__c from Customer_Credit__c where Id=:cc1.Id];           
        system.assertEquals(true, cc1.Credit_Email_Sent__c);
        }
}