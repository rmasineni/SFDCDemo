@isTest(SeeAllData=true)
public with sharing class UnitTest_Lead_Assignment {

    static testmethod void method1(){
    List<Lead> leadList=new List<Lead>();   
    List<Lead> leadList2=new List<Lead>();  
    Set<id> partnerids=new Set<id>();
    recordtype r=[Select id, name from RecordType where name='Partner' and sobjecttype='Account' limit 1 ];
    Account recAcc= new Account(name='SunRun', lead_eligible__c=true, recordtypeid=r.id,office_location__c='Headquarters',active__c=true,stage__c='Confirmed');
    Account recAcc2= new Account(name='SunRun1', lead_eligible__c=true, recordtypeid=r.id,office_location__c='Headquarters',active__c=true,stage__c='Confirmed');
    Account recAcc3= new Account(name='SunRun2', lead_eligible__c=true, recordtypeid=r.id,office_location__c='Headquarters',active__c=true,stage__c='Confirmed');     
    List<Account> accList=new List<Account>();
    accList.add(recAcc);
    accList.add(recAcc2);
    accList.add(recAcc3);
    insert accList;
    partnerids.add(accList[0].id);
    List<Assignment_Order__c> aoList = new List<Assignment_order__c>();
    Assignment_Order__c ao1=new Assignment_Order__c(order__c='1',Assignment_Criteria__c='Offer Promotion');
    Assignment_Order__c ao2=new Assignment_Order__c(order__c='2',Assignment_Criteria__c='Market Assignment');
    Assignment_Order__c ao3=new Assignment_Order__c(order__c='3',Assignment_Criteria__c='Referral Promotion');
    aoList.add(ao1);
    aoList.add(ao2);
    aoList.add(ao3);
    //Contact c=new contact(firstname='tetstsfs',lastname='Test',Email='UnitTest_Lead_Assignment.Customer1@yopmail.com',account=accList[0]);
    Contact c=new contact(firstname='tetstsfs',lastname='Test',Email='UnitTest_Lead_Assignment.Customer1@yopmail.com',accountId=recAcc.id);
    insert c;
    String random=math.random()+'123';
    /*
    Generation_Assets__c g=new Generation_Assets__c(name='Test',Home_Address__c='123',Zip__c='00000',city__c='San Francisco',pto__c=system.today(),Customer_Contact__c=c.id,Meter_Serial_Num__c=random.substring(0,12)+'123',
                                                    Meter_Test_Date__c=system.today(),sales_organization__c='SunRun');
    insert g;   
    */
    ServiceContract sc=new ServiceContract(name=random.substring(0,10),accountid=recAcc.id,Contactid=c.id,Agreement_Number__c=random.substring(0,10));  
    insert sc;  
    Service_Contract_Event__c sce=new Service_Contract_Event__c(service_contract__c=sc.id,PTO__c=system.today()-1);     
    insert sce;                                                 
    Promotion__c p = new Promotion__c(Name='Test',Promotion_Type__c='Offer',Start_Date__c=system.today()-5,end_date__c=system.today()+5);
    Promotion__c p1 = new Promotion__c(Name='Test2',Promotion_Type__c='Offer',Start_Date__c=system.today()-5,end_date__c=system.today()+4);
    Promotion__c p2 = new Promotion__c(Name='Test2',Promotion_Type__c='Customer',Start_Date__c=system.today()-5,end_date__c=system.today()+4);
    List<Promotion__c> promoList=new List<Promotion__c>();
    promoList.add(p);
    promoList.add(p1);
    promoList.add(p2);
    insert promoList;
    Referral_Input__c ref=new Referral_Input__c(promotion__c=promoList[2].id,Target_Contact_Id__c=c.id,service_contract__c=sc.id);
    insert ref;
    Partner_Promotions__c pp = new Partner_Promotions__c(Partner_Account__c=accList[0].id,Promotion__c=promoList[0].id,Role__c='Sales',Start_date__c=system.today()-5,end_date__c=system.today()+5);
    Partner_Promotions__c pp1 = new Partner_Promotions__c(Partner_Account__c=accList[1].id,Promotion__c=promoList[1].id,Role__c='Sales',Start_date__c=system.today()-5,end_date__c=system.today()+4);
    List<Partner_Promotions__c> ppList=new List<Partner_Promotions__c>();
    ppList.add(pp);
    ppList.add(pp1);
    insert ppList;
    offer__c o1=new offer__c(promotion__c=promoList[0].id);
    offer__c o2=new offer__c(promotion__c=promoList[1].id);
    List<offer__c> offList=new List<offer__c>();
    offList.add(o1);
    offList.add(o2);
    insert offList;
    Market__c market=new Market__c(state__c='CA',Utility_company__c='Pacific Gas & Electric (PG&E)',Number_of_Leads__c=10);
    insert market;
    Market_Assignment__c ma = new Market_Assignment__c(market__c=market.id,partner__c=recAcc2.id,Start_date__c=system.today()-1,end_date__c=system.today()+1,role__c='Sales,Install',Zipcodes__c='00000',Install_Partner_age_distribution__c=0.10,Sales_Partner_age_distribution__c=0.10);
    Market_Assignment__c ma1 = new Market_Assignment__c(market__c=market.id,partner__c=recAcc.id,Start_date__c=system.today()-1,end_date__c=system.today()+1,role__c='Sales,Install',Select_All_Zipcodes__c=true,Install_Partner_age_distribution__c=0.10,Sales_Partner_age_distribution__c=0.10);
    Market_Assignment__c ma2 = new Market_Assignment__c(market__c=market.id,partner__c=recAcc3.id,Start_date__c=system.today()-1,end_date__c=system.today()+1,role__c='Install',Select_All_Zipcodes__c=true,Install_Partner_age_distribution__c=0.10,Sales_Partner_age_distribution__c=0.10);
    Market_Assignment__c ma3 = new Market_Assignment__c(market__c=market.id,partner__c=recAcc.id,Start_date__c=system.today()-1,end_date__c=system.today()+1,role__c='Sales',Zipcodes__c='00000',Install_Partner_age_distribution__c=0.10,Sales_Partner_age_distribution__c=0.10);
    Market_Assignment__c ma4 = new Market_Assignment__c(market__c=market.id,partner__c=recAcc.id,Start_date__c=system.today()-1,end_date__c=system.today()+1,role__c='Install',Zipcodes__c='00000',Install_Partner_age_distribution__c=0.10,Sales_Partner_age_distribution__c=0.10);
    List<Market_Assignment__c> maList=new List<Market_Assignment__c>();
    maList.add(ma);
    maList.add(ma1);
    maList.add(ma2);
    maList.add(ma3);
    maList.add(ma4);        
    insert maList;
    Map<string,List<lead>> zipcodemap=new Map<string,List<lead>>();
    Lead l=new Lead(lastname='Test',channel__c='Test',referred_by_contact__c=c.id,company='Home',referral_input__c=ref.id);
    Lead l1=new Lead(lastname='Test',channel__c='Test',PostalCode='00000',company='Home');
    Lead l2=new Lead(lastname='Test',State__c='CA',State='CA',PostalCode='00000',channel__c='Test',company='Home',utility_company__c='Pacific Gas & Electric (PG&E)');
    Lead l3=new Lead(lastname='Test',channel__c='Test',offer__c=offList[0].id,company='Home');
    Lead l4=new Lead(lastname='Test',channel__c='Test',PostalCode='00000',state='CA',company='Home',utility_company__c='Pacific Gas & Electric (PG&E)');
    Lead l5=new Lead(lastname='Test',channel__c='Test',State='IN',company='Home');
    Lead l6=new Lead(lastname='Test',channel__c='Test',company='Home');
    Lead l7=new Lead(lastname='Test',channel__c='Test',Referral_web_form__c=true,company='Home');
    Lead l8=new lead(lastname='Test',channel__c='Test',company='Home');
    leadList.add(l);
    leadList.add(l1);   
    leadList.add(l2);
    leadList.add(l3);   
    leadList.add(l4);
    leadList.add(l5);
    leadList.add(l6);
    leadList.add(l7);
    leadList.add(l8);
    insert leadList;
    zipcodemap.put('00000',leadList);
    Set<String> stateSet=new set<String>();
    stateSet.add('CA');
    /*
    Lead_Assignment.referralPromoAssignmentKey=1;
    Lead_Assignment.offerPromoAssignmentKey=1;
    Lead_Assignment.marketAssignmentKey=1;
    Lead_Assignment.sunrunDirectKey=1;
    */
    Lead_Assignment.partnerAssignList=new List<Partner_Assignment_Staging__c>();
    //Lead_Assignment.doReferralPromotion(leadList, null, stateSet, aoList);
    //Lead_Assignment.doOfferPromotion(leadList, null, stateSet, aoList);
    //Lead_Assignment.doMarketAssignmentQ2(leadList, zipcodemap,stateSet, aoList);
    Partner_Assignment_Staging__c pa=new Partner_Assignment_Staging__c();
    Set<String> utilityset=new set<string>();
    utilityset.add('Pacific Gas & Electric (PG&E)');    
    /*
    Lead_Assignment.referralPromoAssignmentKey=0;
    Lead_Assignment.offerPromoAssignmentKey=0;
    Lead_Assignment.marketAssignmentKey=0;      
    */
    Set<id> leadids=new set<id>();
    leadids.add(leadList[0].id);
    leadids.add(leadList[1].id);
    leadids.add(leadList[2].id);
    leadids.add(leadList[3].id);
    leadids.add(leadList[4].id);
    leadids.add(leadList[5].id);
    leadids.add(leadList[6].id);
    leadids.add(leadList[7].id);
    leadids.add(leadList[8].id);
    //Lead_Assignment.referralPromoAssignmentKey=1;
    //Lead_Assignment.offerPromoAssignmentKey=1;
    //Lead_Assignment.marketAssignmentKey=1;
    //Lead_Assignment.sunrunDirectKey=1;
    /*  
    Lead_Assignment.Lead_Assignment(leadids);
    Lead_Assignment.Lead_Assignment_Immediate(leadids);
    */
    Lead_Assignment.Lead_Assignment(leadids);
    Test.startTest();
    Lead_Assignment.Lead_Assignment_Immediate(leadids);
    Map<String,Market_Assignment__c> maMap=Lead_assignment.doFindSalesInstallMarketsForReferralOffer(leadList, zipCodeMap, stateset, partnerIds, utilitySet);
    maMap=FindMarketsManual.doFindSalesMarket(zipcodemap.keyset(), stateset, partnerIds, utilitySet);
    maMap=FindMarketsManual.doFindInstallMarket(zipcodemap.keyset(), stateset, partnerIds, utilitySet);
   // SearchSalesInstallForPartners.SearchSalesInstallForPartners(leadids);
    /*Lead_assignment.doFindInstallPartner(leadList, zipCodeMap, stateset, aoList,pa, utilitySet);
    Lead_Assignment.doReferralPromotion(leadList, zipCodeMap, stateSet, aoList,utilitySet);
    Lead_Assignment.doOfferPromotion(leadList, zipCodeMap, stateSet, aoList,utilitySet);
    Lead_Assignment.doMarketAssignmentQ2(leadList, zipcodemap,stateSet, aoList,utilitySet);
    aoList.clear();
    */
    Test.stopTest();
    }
}