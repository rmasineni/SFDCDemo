@istest(seeAllData=true)
public with sharing class Test_trg_after_insert_bboppty {
     static testMethod void Test_trg_after_insert_bboppty(){
        Test.starttest();
         Opportunity opp = new Opportunity(Name ='Test1',StageName='Created',Opportunity_Source_Type__c='BB');
         Opportunity opp1 = new Opportunity(Name ='Test2',StageName='Created',Opportunity_Source_Type__c='PT');
        List<Opportunity> opptList=new List<Opportunity>();
        opptList.add(opp);
        opptList.add(opp1);
        insert opptList;        
        Proposal__c p = new Proposal__c(name='TestProposal',Proposal_Source__c='BB',Opportunity__c=opptList[0].Id,System_Size_STC_DC__c=20.01,Upfront_Payment__c=10,Mode_Name__c='TestProp1',Sales_Rep_Email__c='test123@yopmail.com',Date_Issued__c=system.today());
        Proposal__c p1 = new Proposal__c(name='TestProposal3',Proposal_Source__c='PT',Opportunity__c=opptList[1].Id,System_Size_STC_DC__c=10.01,Upfront_Payment__c=20,Mode_Name__c='TestProp21',Sales_Rep_Email__c='test124@yopmail.com',Date_Issued__c=system.today(),Array_1_Production_Yr_1__c=66,Array_2_Production_Yr_1__c=66,Array_3_Production_Yr_1__c=66,Array_4_Production_Yr_1__c=66,Array_5_Production_Yr_1__c=66,Array_6_Production_Yr_1__c=66);
        List<Proposal__c> PropList = new List<Proposal__c>();
        PropList.add(p);        
        PropList.add(p1);        
      insert PropList;
  
    Array_Information__c arr1 = new Array_Information__c(Array_Number__c=1,AC_DC_derate_factor__c=21,April_Shade__c=50,August_Shade__c=50,Azimuth__c=23,CEC_AC_Rating__c=22,December_Shade__c=33,February_Shade__c=33,Inverter_Type__c='Type1',January_Shade__c=33,July_Shade__c=44,June_Shade__c=77,March_Shade__c=44,May_Shade__c=66,November_Shade__c=55,Number_of_Inverters__c=33,Number_of_Panels__c=22,October_Shade__c=22,Panel_Type__c='Test',Production__c=55,Proposal__c=PropList[0].id,September_Shade__c=33);
    Array_Information__c arr2 = new Array_Information__c(Array_Number__c=2,AC_DC_derate_factor__c=21,April_Shade__c=50,August_Shade__c=50,Azimuth__c=23,CEC_AC_Rating__c=22,December_Shade__c=33,February_Shade__c=33,Inverter_Type__c='Type2',January_Shade__c=33,July_Shade__c=44,June_Shade__c=77,March_Shade__c=44,May_Shade__c=66,November_Shade__c=55,Number_of_Inverters__c=33,Number_of_Panels__c=22,October_Shade__c=22,Panel_Type__c='Test1',Production__c=55,Proposal__c=PropList[1].id,September_Shade__c=33);   
    List<Array_Information__c> arrList = new List<Array_Information__c>();
    arrList.add(arr1);
    arrList.add(arr2);  
     insert arrList;    
    test.stopTest();
     }
}