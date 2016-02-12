trigger trg_credit_before_ins_before_upd on Customer_Credit__c (before insert, before update) {
    
    Set<id> ccIds = new set<Id>();
    Set<id> contactids = new set<id>();
    map<id,id> conOppMap = new Map<id,id>();
    map<id,string> opportunitymap = new map<id,string>();
    Boolean skipValidations = false;
    skipValidations = SkipTriggerValidation.performTriggerValidations();
    if(skipValidations == false){
        
        List<Customer_Credit__c> customerCreditList = new List<Customer_Credit__c>();
        for(Customer_Credit__c ccObj:Trigger.New){
            Customer_Credit__c oldCCObj;
            if(Trigger.isUpdate){
                oldCCObj = Trigger.oldMap.get(ccObj.Id);
            }
            if(Trigger.isInsert || (Trigger.isUpdate 
                && ((ccObj.Fico__c != oldCCObj.Fico__c) || 
                    (ccObj.fico1__c != oldCCObj.fico1__c) ||  
                    (ccObj.fico2__c != oldCCObj.fico2__c) ||  
                    (ccObj.fico3__c != oldCCObj.fico3__c) ||  
                    (ccObj.Estimated_Home_Value__c != oldCCObj.Estimated_Home_Value__c) ||
                    (ccObj.Reason__c != oldCCObj.Reason__c) ||
                    (ccObj.state__c != oldCCObj.state__c) ||  
                    (ccObj.Banky_Outcome__c != oldCCObj.Banky_Outcome__c) || 
                    (ccObj.Mortgage_Outcome__c != oldCCObj.Mortgage_Outcome__c) ||
                    (ccObj.status__c != oldCCObj.status__c) // ???
                ))){
                customerCreditList.add(ccObj);
            }
            
            if(Trigger.isInsert || (Trigger.isUpdate && (ccObj.Failed_Score__c != oldCCObj.Failed_Score__c))){
                CustomerCreditUtil.copyFicoScore(ccObj);
            }
            
            system.debug('CustomerCreditUtilCustomerCreditUtil>>'+ customerCreditList);
        }
        if(!customerCreditList.isEmpty()){
            CustomerCreditUtil.calculateCreditScore(customerCreditList);
            CustomerCreditUtil.updateCreditStatus(customerCreditList);
            if(Trigger.isUpdate){
                CustomerCreditUtil.processCreditEmail(Trigger.newmap, Trigger.oldMap);
            }
        }
        for(Customer_Credit__c cc: trigger.new){
          ccIds.add(cc.Id);
          contactids.add(cc.Contact__c);
        }
        
        if(!contactIds.isempty()){
        for(opportunitycontactrole ocr : [select id, opportunityid, contactId from opportunitycontactrole where contactid in: contactids])
         conOppMap.put(ocr.contactId,ocr.opportunityid);
        }
        
        if(!conOppMap.isEmpty()){
         for(opportunity opp : [select id, SalesOrganizationName__c from opportunity where id in: conOppMap.values()]){
          opportunityMap.put(opp.Id,opp.SalesOrganizationName__c);
         }
        }
        
        if(!opportunitymap.isempty()){
         for(Customer_Credit__c cc: trigger.new){
          if(trigger.isInsert || (trigger.isUpdate && trigger.oldMap.get(cc.id).Sales_Organization_Name__c == null || trigger.oldMap.get(cc.id).Sales_Organization_Name__c == '') ){
            cc.Sales_Organization_Name__c = opportunitymap.get(conOppmap.get(cc.contact__c));
            system.debug('==>cc'+cc.Sales_Organization_Name__c);
          }
         }
        }
    }
}