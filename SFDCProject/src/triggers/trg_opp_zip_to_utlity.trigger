trigger trg_opp_zip_to_utlity on Opportunity (after insert, after update) {
   
    set<string> zipCodeSet=new Set<String>();
    Set<id> accountIdSet=new Set<id>();
    Map<String,ZipUtility__c> ZipUtilityMap=new Map<String,ziputility__c>();
   
    List<Opportunity> listOpp=new List<Opportunity>();
    for(Opportunity opp:trigger.new){
    if(opp.stagename!='7. Closed Won'&&opp.Utility_Company__c==null){
        accountIdSet.add(opp.accountid);
    }      
    }
    Map<id,Account> accMap=new Map<id,Account>();
    if(!accountIdSet.isempty()){
		accMap = AccountUtil.getAccountsForBillingPostalcode(accountIdSet);
    }
    for(Account a:accMap.values()){
        if(a.billingpostalcode!=null&&a.billingpostalcode!=''&&a.BillingPostalCode.length()>=5){
        zipCodeSet.add(a.billingpostalcode.substring(0,5));   
        }
       
    }
    if(!zipCodeSet.isempty()){
    for(ZipUtility__c z:[select state__c,Utility_Company__c,Sales_Branch__c,Territory__c,Zip_Code__c from ZipUtility__c where Zip_Code__c in:zipCodeSet]){
        ZipUtilityMap.put(z.zip_code__c,z);
    }  
    }
    for(Opportunity opp:trigger.new){ 
            if(accMap.containsKey(opp.accountid)){
                if(accMap.get(opp.accountid).billingpostalcode!=null&&accMap.get(opp.accountid).billingpostalcode.length()>=5){
                    if(ZipUtilityMap.containskey(accMap.get(opp.accountid).billingpostalcode.substring(0,5))&&opp.stagename!='7. Closed Won'){
                    if(opp.Utility_Company__c!=ZipUtilityMap.get(accMap.get(opp.accountid).billingpostalcode.substring(0,5)).utility_company__c){  
                    if(opp.zip_utility__c != ZipUtilityMap.get(accMap.get(opp.accountid).billingpostalcode.substring(0,5)).Id){ 
                    if(opp.sales_branch__C != ZipUtilityMap.get(accMap.get(opp.accountid).billingpostalcode.substring(0,5)).sales_branch__C){   
                        Opportunity op=new Opportunity(id=opp.id,sales_branch__C =ZipUtilityMap.get(accMap.get(opp.accountid).billingpostalcode.substring(0,5)).sales_branch__c,utility_company__c=ZipUtilityMap.get(accMap.get(opp.accountid).billingpostalcode.substring(0,5)).utility_company__c,zip_utility__c=ZipUtilityMap.get(accMap.get(opp.accountid).BillingPostalcode.substring(0,5)).Id);
                        if(ZipUtilityMap.get(accMap.get(opp.accountid).billingpostalcode.substring(0,5)).Id!=null){
                        op.zip_utility__c = ZipUtilityMap.get(accMap.get(opp.accountid).BillingPostalcode.substring(0,5)).Id;
                        if(ZipUtilityMap.get(accMap.get(opp.accountid).billingpostalcode.substring(0,5)).Territory__c!=null)
                        op.Territory__c=ZipUtilityMap.get(accMap.get(opp.accountid).billingpostalcode.substring(0,5)).territory__c;                                        
                        if(ZipUtilityMap.get(accMap.get(opp.accountid).billingpostalcode.substring(0,5)).state__c!=null){ 
                        op.state__c= ZipUtilityMap.get(accMap.get(opp.accountid).billingpostalcode.substring(0,5)).state__c;  
                        if(ZipUtilityMap.get(accMap.get(opp.accountid).billingpostalcode.substring(0,5)).sales_branch__c !=null){ 
                        op.sales_branch__c = ZipUtilityMap.get(accMap.get(opp.accountid).billingpostalcode.substring(0,5)).sales_branch__c ;
                        if(Trigger.isInsert&&opp.lead_id__c!=null){
                        op.name=opp.account_name__c;    
                        }
                        }  
                        } 
                        } 
                        listOpp.add(op);                       
                        }
                    }
                }
            } 
            else if(Trigger.isInsert&&opp.lead_id__c!=null){
            Opportunity op=new Opportunity(id=opp.id);
            op.name=opp.account_name__c;
            listOpp.add(op); 
           }              
                         
    }
    if(!listOpp.isempty()){
        update listOpp;
    }
   }
}
}