@isTest(SeeAllData=true)
public  class Test_OpportunitySalesRep {
static testMethod void OpportunitySalesRep() {  
     Test.starttest();
        
        //Profile p = [SELECT Id FROM Profile limit 1];
        //User u = new user ( FirstName = 'Smith',LastName  = 'James',Email='test@gmail.com',Username= 'sfdctest1111@yopmail.com',Alias = 'Jim',TimeZoneSidKey= 'America/Denver',
        //LocaleSidKey = 'en_US',EmailEncodingKey  = 'UTF-8',LanguageLocaleKey = 'en_US',ProfileId =p.Id);
        //insert u;
        //Proposal__c prop = [Select Name,Sales_Rep_Email__c, Date_Issued__c, Opportunity__c, System_Size_STC_DC__c, Upfront_Payment__c FROM Proposal__c limit 1];      
        
        Opportunity opp = new Opportunity(Name='TestOpportunity',StageName='Prospecting',salesrep__c=userinfo.getuserid());
        insert opp;  
        Proposal__c propObj=new Proposal__c(opportunity__c=opp.id,name='TESTPROPSalesrepupdate',Upfront_Payment__c = 1000,Mode_Name__c ='TEST',Date_Issued__c =  date.today(),Sales_Rep_Email__c ='test4343@yopmail.com',EDP_Phase__c = 'EDP Phase-1',System_Size_STC_DC__c=100);
        insert propObj;      
        set<id> ids = new set<id>();
        ids.add(opp.id);       
        OpportunitySalesRep.OpportunitySalesRep(ids);
        OpportunitySalesRepUpdate.OpportunitySalesRepUpdate(ids);
        test.stopTest();
       
    }
    
}