/**
Peter Alexander Mandy
10232012 121228
 */
@isTest
private class testProposalTriggers {

    static testMethod void myUnitTest() {
       Account accountRec = new Account();
        accountRec.Name = 'Test Account Oppties';
        insert accountRec;
        //
        Contact contactRec = new Contact();
        contactRec.FirstName = 'TestAcct';
        contactRec.LastName = 'TestAcctOppty';
        contactRec.Email = 'emailfake@fakeemail.net';
        contactRec.AccountId = accountRec.Id;
        insert contactRec;
        //
        ID ProfileID = [ Select id from Profile where UserType = 'Standard' LIMIT 1].id;
        //
        List<User> listUsers = new List<User>();
        User u1 = new User( email='test-user11@fakeemail.com', profileid = ProfileID, 
                UserName='test-user1@fakeemail.com', alias='tusr11', CommunityNickName='tusr11', 
		        TimeZoneSidKey='America/New_York', LocaleSidKey='en_US', EmailEncodingKey='ISO-8859-1', 
		        LanguageLocaleKey='en_US', FirstName = 'Test', LastName = 'User',Title = 'Key User' );
        listUsers.add(u1);
        User u2 = new User( email='test-user22@fakeemail.com', profileid = ProfileID, 
                UserName='test-user22@fakeemail.com', alias='tusr22', CommunityNickName='tusr22', 
		        TimeZoneSidKey='America/New_York', LocaleSidKey='en_US', EmailEncodingKey='ISO-8859-1', 
		        LanguageLocaleKey='en_US', FirstName = 'Test2', LastName = 'User2',Title = 'Key User2' );
        listUsers.add(u2);
        insert listUsers;
        //
        Opportunity Opp = new Opportunity();
        /*Opp.Name = 'TestOpptyTriggers';
        Opp.StageName = 'In Progress';
        Opp.CloseDate = Date.Today().addDays(18);    
        Opp.AccountId = accountRec.Id;
        Opp.Sales_Representative__c = contactRec.Id;    
        Opp.Credit_Status__c = 'Approved'; 
        insert Opp;
        //temp fix for odd error on above insert on 11072012 while deploying LD changes
        Opp = [select id from Opportunity LIMIT 1];  
        
        //
        List<Proposal__c> listProp = new List<Proposal__c>();
        Proposal__c prop = new Proposal__c();
        prop.Opportunity__c = Opp.Id;
        prop.Assigne__c = u1.Id;        
        prop.Stage__c = 'Created';  
        prop.Sales_Rep_Email__c = 'therepsemail@repemailfake.com';
        prop.Date_Issued__c = Date.Today().addDays(18); 
        prop.Mode_Name__c = '1234';
        prop.System_Size_STC_DC__c  = 5.8;
        prop.Upfront_Payment__c = 20.0;
        listProp.add(prop);
        //
        Proposal__c prop2 = new Proposal__c();
        prop2.Opportunity__c = Opp.Id;
        prop2.Assigne__c = u1.Id;        
        prop2.Stage__c = 'Created';
        prop2.Sales_Rep_Email__c = 'therepsemail@repemailfake.com'; 
        prop2.Date_Issued__c = Date.Today().addDays(18); 
        prop2.Mode_Name__c = '1234';
        prop2.System_Size_STC_DC__c  = 5.8;
        prop2.Upfront_Payment__c = 20.0;
        listProp.add(prop2);
        //
        insert listProp;
        //
        Proposal__c prop3 = new Proposal__c();
        prop3.Opportunity__c = Opp.Id;
        prop3.Assigne__c = u1.Id;        
        prop3.Stage__c = 'Created';
        prop3.Sales_Rep_Email__c = 'therepsemail@repemailfake.com'; 
        prop3.Date_Issued__c = Date.Today().addDays(18); 
        prop3.Mode_Name__c = '1234';
        prop3.System_Size_STC_DC__c  = 5.8;
        prop3.Upfront_Payment__c = 20.0;
        prop3.Change_Order__c = true;
        prop3.Change_Order_ID__c = prop2.Id;        
        insert prop3;
        //
        prop.Estimated_Rebate_Amount__c = 999;
        prop.Partner_Guaranteed_Rebate__c = true;         
        prop.Assigne__c = u2.Id;
        prop.Stage__c = EDPUtil.SR_OPS_APPROVED;
        update prop;
        //
        try{
          prop.Stage__c = EDPUtil.SR_OPS_REVIEWED;
          prop.Estimated_Rebate_Amount__c = null;
          prop.Partner_Guaranteed_Rebate__c = false;
          update prop;
        }
        catch(Exception e)
        {
        	System.Debug('Trap the error that is intentionally thrown to the page.');
        }
        //
        prop.Stage__c = EDPUtil.SR_OPS_REVIEWED;
        update prop;
        prop.Stage__c = EDPUtil.CREDIT_APPROVED;
        prop.EPC_Price__c = 105000;
        update prop;
        //To hit lines 222-225 update again with no change to stage but equal to Approved:
        update prop;
        try{
        prop.Stage__c = EDPUtil.SUBMITTED;
        prop.Change_Order__c = true;
        prop.Change_Order_Type__c = EDPUtil.FINAL_INPUTS_HYBRID_ID;
        prop.Change_Order_ID__c = prop2.Id;        
        prop.Original_Proposal_ID__c = prop2.Id;
        prop.Electronically_Signed_Document__c = false;
        update prop;
        }
        catch(Exception e)
        {
        	System.Debug('Trap the error that is intentionally thrown to the page.');
        }
        //
        try{
        prop.Electronically_Signed_Document__c = true;
        update prop;   
        }
        catch(Exception e)
        {
        	System.Debug('Trap the error that is intentionally thrown to the page.');
        }   
        //
        try{
        prop.Product_ID__c = 'F';
        prop.Change_Order__c = true;
        prop.Change_Order_Type__c = EDPUtil.FINAL_INPUTS_HYBRID_ID;
        prop.Change_Order_ID__c = prop2.Id; 
        prop.Stage__c = EDPUtil.PENDING;
        prop.Pending_Proposal_Reason__c = 'Missing pages';
        update prop;
        }
        catch(Exception e)
        {
        	System.Debug('Trap the error that is intentionally thrown to the page.');
        }
        //
        try{
        	prop.Change_Order_ID__c = null;
        	update prop;
        }
        catch(Exception e)
        {
           System.Debug('Trap the error that is intentionally thrown to the page.');
        }    
        try{
          prop.Assigne__c = null;
          update prop;	
        }
        catch(Exception e)
        {
        	System.Debug('Trap the error that is intentionally thrown to the page.');
        }    */
    }
}