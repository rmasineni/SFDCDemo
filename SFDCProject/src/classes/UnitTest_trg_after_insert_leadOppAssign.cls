@isTest(SeeAllData=true)
public with sharing class UnitTest_trg_after_insert_leadOppAssign {
    
    static testmethod void UnitTest_trg_after_insert_leadOppAssign(){
    Account sunrun=new account(id=system.label.sunrun_inc_id);  
    id recordtypeid=[select id,sobjecttype,name from recordtype  where sobjecttype='Account' and name ='Partner'].id;
    Account testAcc= new Account(name='SunRun',active__c=true, lead_eligible__c=true,stage__c='Confirmed',office_location__c='Headquarters',recordtypeid=recordtypeid);
    insert testAcc;
    Lead l = new Lead(LastName='TestXXX',Company='Test123');
    Lead l2 = new Lead(LastName='TestXXX',Company='Test123');
    List<Lead> listLead=new List<Lead>();
    listLead.add(l);
    listLead.add(l2);
    insert listLead;   
    Market__c market=new Market__c(state__c='CA',Utility_company__c='Pacific Gas & Electric (PG&E)',Number_of_Leads__c=10);
    insert market;
    Market_Assignment__c ma = new Market_Assignment__c(market__c=market.id,partner__c=sunrun.id,Start_date__c=system.today()-1,end_date__c=system.today()+1,role__c='Sales,Install',Zipcodes__c='00000',Install_Partner_age_distribution__c=0.10,Sales_Partner_age_distribution__c=0.10);
    List<Market_Assignment__c> maList=new List<Market_Assignment__c>();
    maList.add(ma);   
    insert maList;        
    Partner_Assignment_Staging__c pastage1 = new Partner_Assignment_Staging__c(Account__c=sunrun.id,lead__c=l.id,sales_market_assignment__c=malist[0].id,install_market_assignment__c=malist[0].id);
    Partner_Assignment_Staging__c pastage2=new Partner_Assignment_Staging__c(lead__c=l.id,Referral_With_Contact_NoMatch__c=true);
    Partner_Assignment_Staging__c pastage3=new Partner_Assignment_Staging__c(lead__c=l.id,No_Data__c=true);
    Partner_Assignment_Staging__c pastage4=new Partner_Assignment_Staging__c(lead__c=l2.id,Offer_Assignment__c=true,sales_market_assignment__c=malist[0].id,install_market_assignment__c=malist[0].id);
    Partner_Assignment_Staging__c pastage5=new Partner_Assignment_Staging__c(lead__c=l.id,Referral_from_Web__c=true);
    Partner_Assignment_Staging__c pastage6=new Partner_Assignment_Staging__c(account__c=testAcc.id,lead__c=l.id,Referral_with_contact__c=true,sales_market_assignment__c=malist[0].id,install_market_assignment__c=malist[0].id);
    Partner_Assignment_Staging__c pastage7=new Partner_Assignment_Staging__c(account__c=testAcc.id,lead__c=l2.id,market_assignment__c=true,sales_market_assignment__c=malist[0].id,install_market_assignment__c=malist[0].id);    
    List<Partner_Assignment_Staging__c> paList=new List<Partner_Assignment_Staging__c>();
    paList.add(pastage1);
    paList.add(pastage2);
    paList.add(pastage3);
    paList.add(pastage4);
    paList.add(pastage5);
    paList.add(pastage6);
    paList.add(pastage7);        
    insert paList;    
            
    }
    
}