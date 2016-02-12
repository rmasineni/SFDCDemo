public class Referral_SCE_SalesRepEmailUtil{

public static void updateSalesRepEmail(boolean isinsert,boolean isupdate, List<Service_Contract_Event__c> sceList,Map<id,Service_Contract_Event__c> oldMap){

    List<Referral_Input__c> riList = new List<Referral_Input__c>();

     for(Service_Contract_Event__c sce: sceList)
    {
        if((isinsert&&sce.referral_id__c!=null&&sce.sales_rep_email__c!=null)||(isupdate&&sce.referral_id__c!=null&&oldmap.get(sce.id).sales_rep_email__c!=sce.sales_rep_email__c))   
        {
          Referral_input__c riObj=new Referral_input__c(id=sce.referral_id__c,sales_rep_email__c=sce.Sales_Rep_Email__c);
          riList.add(riObj);
        }    
    }           
    
    system.debug('****'+riList);
    if(!riList.isempty()){
    update rilist;
    }

    
}

}