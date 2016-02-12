@isTest
private class Test_trg_Contact_aft_ins_update {

    static testMethod void Test_trg_Contact() {
        Test.starttest(); 
        List<Contact> conList = New List<Contact>();
        List<Contact> updtConList = New List<Contact>();
        Contact con = New Contact();
        con.FirstName = 'Jack';
        con.LastName = 'Smith';
        con.Application_Status__c = 'Received';
        con.Sells_Sunrun__c = 'Yes';
        con.Sells_in_CA__c = 'Yes';
        con.active__c = True;
        conList.add(con);
        
        Contact con2 = New Contact();
        con2.FirstName = 'August';
        con2.LastName = 'Smith';
        con2.Application_Status__c = 'Received';
        con2.active__c = False;
        conList.add(con2);
        
        
        Contact con3 = New Contact();
        con3.FirstName = 'July';
        con3.LastName = 'Smith';
        con3.Application_Status__c = 'Received';
        con3.Stop_Payment__c = True;
        conList.add(con3);
        
        Contact con4 = New Contact();
        con4.FirstName = 'June';
        con4.LastName = 'Smith';
        con4.Stop_Payment__c = True;
        con4.Member_ID__c = '371111111111';
        conList.add(con4);
        insert conList;

        con4.Member_ID__c = '371111111112';
        updtConList.add(con4);
        Update updtConList;
        
        Account acc= new Account(name='SunRun');
        insert acc;
        
       
        Promotion__c promotion = new Promotion__c(Name='Test2',Promotion_Type__c='Customer',Start_Date__c=system.today()-5,end_date__c=system.today()+4);
        insert promotion ;
        
        List <Referral_Input__c> referralList = New List<Referral_Input__c>();
        Referral_Input__c referral = New Referral_Input__c();
        referral.promotion__c=promotion.id;
        referral.Target_Contact_Id__c=con3.id;
        referral.Source_Contact_Id__c=con3.id;
        referral.Milestone_1_Status__c = 'Qualified for Payment';
        referral.Referrer_Status_1__c = Null;
        referralList.add(referral);
                    
        insert referralList;
        con3.Application_Status__c = Null;
        con3.Stop_Payment__c = False;
        Update conList;
        System.debug('Created a Referral ' + referral.id);
        Test.stoptest();    
      
        
        
    }
}