public with sharing class Referral_SC_SalesRepEmailUtil{

public static void updateSalesRepEmail(boolean isinsert,boolean isupdate,List<ServiceContract> scList,Map<id,ServiceContract> oldMap){

    List<Referral_Input__c> riList = new List<Referral_Input__c>();
    for(ServiceContract sc:scList){
        if((isInsert&&sc.Referral__c!=null)||(isUpdate&&oldMap.get(sc.id).referral__c!=sc.referral__c)){
            Referral_input__c riObj=new Referral_input__c(id=sc.referral__c,sales_rep_email__c=sc.Sales_Rep_Email__c);
            riList.add(riObj);
        }
    }
    if(!riList.isempty()){
        update riList;
    }

}

}