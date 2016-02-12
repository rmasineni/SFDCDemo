@istest(seeAllData=true)
public with sharing class Test_ShareHistoricOppty {
    public static testMethod void Test_ShareHistoricOppty(){
        
    user u=[select id,Share_Historical_Opportunities__c,Account_Id__c from user where Account_Id__c!=null and Share_Historical_Opportunities__c=false and isactive=true limit 1]; 
    
     Opportunity opp = new Opportunity(Name ='Test1',StageName='Created',Accountid=u.Account_Id__c,Closedate=system.today());
    Opportunity opp1 = new Opportunity(Name ='Test2',StageName='Created',Accountid=u.Account_Id__c,Closedate=system.today()-10);
        List<Opportunity> opptList=new List<Opportunity>();
    opptList.add(opp);
    opptList.add(opp1);
    insert opptList;
        Proposal__c p = new Proposal__c(Name='TestProp',Mode_Name__c='TestProp',Opportunity__c=opp.Id,Sales_Partner__c=u.Account_Id__c,Sales_Rep_Email__c='test123@yopmail.com',Date_Issued__c=system.today(),System_Size_STC_DC__c=20.01,Upfront_Payment__c=10);
        Proposal__c p2 = new Proposal__c(Name='TestProp1',Mode_Name__c='TestProp1',Opportunity__c=opp1.Id,Install_Partner__c=u.Account_Id__c,Sales_Rep_Email__c='test123@yopmail.com',Date_Issued__c=system.today()-1,System_Size_STC_DC__c=10.99,Upfront_Payment__c=20);
        List<Proposal__c> PropList = new List<Proposal__c>();
        PropList.add(p);
        PropList.add(p2);
       insert PropList;
      u.Share_Historical_Opportunities__c=true;
      update u; 

}
}