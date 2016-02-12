@isTest(SeeAllData=true)
public with sharing class UnitTest_ReferralOfferUtil {

    static testmethod void ReferralOfferUtil(){
    Account acc= new Account(name='SunRun');
    insert acc;
    Contact c=new contact(firstname='tesfrs',lastname='Test',accountId=acc.id,Email='UnitTest_ReferralOfferUtil.Customer1@yopmail.com');
    insert c;
    Opportunity oppty=new Opportunity(name='Test',accountid=acc.id,stagename='Open');
    insert oppty;
    Promotion__c promotion = new Promotion__c(Name='Test2',Promotion_Type__c='Customer',Start_Date__c=system.today()-5,end_date__c=system.today()+4);
    insert promotion ;
    offer__c offer=new offer__c(promotion__c=promotion.id,Customer_Contact__c=c.id);
    insert offer;
    Referral_Input__c referral=new Referral_Input__c(promotion__c=promotion.id,Target_Contact_Id__c=c.id,Source_Contact_Id__c=c.id);
    insert referral;
    Proposal__c proposal=new Proposal__c(Upfront_Payment__c=111,System_Size_STC_DC__c=11,Sales_Rep_Email__c='tests12@yopmail.com',
    Date_Issued__c=system.now(),Name='1231312',opportunity__c=oppty.id,Mode_Name__c='TEST');
    insert proposal;
    String random='999'+math.random();
     ServiceContract sc=new ServiceContract(name=random.substring(0,10),offer__c=offer.id,referral__c=referral.id,contactid=c.id,accountid=acc.id,Agreement_Number__c=random.substring(0,10),opportunity__c=oppty.id,proposal__c=proposal.id);  
    //ServiceContract sc1=new ServiceContract(name=random2.substring(0,10),contactid=c.id,accountid=acc.id,te_fund_name__c='CS Fund V',Agreement_Number__c=random2.substring(0,10));
    List<ServiceContract> scList=new List<ServiceContract>();
    scList.add(sc);
    //scList.add(sc1);
    insert scList;
    Service_Contract_Event__c sce=new Service_Contract_Event__c(Rebate_Conf_Rec_d__c=system.today(),Final_Rebate_Amount__c=11,Initial_Deposit_Amount_Received__c=100,   Initial_Deposit_Processed__c=system.today(),Initial_Deposit_Amount__c=100,service_contract__c=scList[0].id,PTO__c=system.today()-1,M1_proof_panel_inverter_delivery__c=system.today(),
                                                                Complete_Deal_Received__c=system.today(),SR_Signoff__c=system.today(),Facility_Design_Approved__c=system.today(),M2_proof_substantial_completion__c=system.today(),NTP_Granted__c=system.today());     
  //Service_Contract_Event__c sce1=new Service_Contract_Event__c(Rebate_Conf_Rec_d__c=system.today(),Final_Rebate_Amount__c=11,Initial_Deposit_Amount_Received__c=100,  Initial_Deposit_Processed__c=system.today(),Initial_Deposit_Amount__c=100,service_contract__c=scList[1].id,PTO__c=system.today()-1,M1_proof_panel_inverter_delivery__c=system.today(),
    //                              M2_proof_substantial_completion__c=system.today(),NTP_Granted__c=system.today());     
    List<Service_Contract_Event__c> sceList=new List<Service_Contract_Event__c>();
    sceList.add(sce);
    //sceList.add(sce1);
    insert sceList;  
    referral.service_contract__c=scList[0].id;
    update referral;
    offer.Service_Contract__c=scList[0].id;
    update offer;
    scList[0].te_fund_name__c='CS Fund VII';
    update scList;  
    }
    
    }