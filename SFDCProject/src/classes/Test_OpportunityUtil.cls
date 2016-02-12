@isTest(SeeAllData=true)
public with sharing class Test_OpportunityUtil {
    public static testmethod void Test_OpportunityUtil (){
        Test.StartTest();
       Account acc = new Account(name='Test1',billingpostalcode='00000',billingstate='CA'); 
       insert acc;  
       Opportunity opp = new Opportunity(name='Test11',Accountid=acc.id,Average_Monthly_Electric_Bill__c=66,stagename='Created',CloseDate=system.today());
       insert opp;
        OpportunityUtil opputil = new OpportunityUtil();
        Map<Id, String> st=OpportunityUtil.isUtilityInformationChanged(opp,opp);
        List<opportunity> opList=new List<opportunity>();
        opList.add(opp);
        Map<id,opportunity> opMap=new Map<id,opportunity>();
        opmap.put(opp.id,opp);
        //OpportunityUtil.calculateMonUsage(opList, opMap, false, true);
        OpportunityUtil.copyOptyUtilityInformation(opp,opp);                
        Id jitterBitId=System.Label.JitterBitUser;
        if(jitterBitId!=null){
            User jitterbitUser=new User(id=jitterBitId);
            System.runas(jitterbitUser){
               OpportunityUtil.doJitterBitRollBackFields(opList,opMap); 
            }
        }
        Test.StopTest();
    }

}