trigger SendEmailCustomerCreditPass on Customer_Credit__c (before update){
    /*
    Set<String> DealCreditSet = New Set<String>();
    List<Opportunity> OppDealIdList = New List<Opportunity>();
    //Profile ProfileName = [Select Name from profile where Id =: Userinfo.getProfileId()];
    String financeCreditProfileId = Label.Finance_Credit_Id;
    String loginProfileId = UserInfo.getProfileId();
    List<Customer_Credit__c> CreditUpdateList = New List<Customer_Credit__c>();
    Map<String,Id> DealIdvsOppIdMap = New Map<String,Id>();
    for(Customer_Credit__c ccObj: Trigger.New){
        Customer_Credit__c oldCCObj;
        oldCCObj = Trigger.oldMap.get(ccObj.Id);
        System.debug('oldCCObj: ' + oldCCObj);
		System.debug('ccObj: ' + ccObj);
        if(ccObj.Deal_Id__c != null && 
           ((((ccObj.Sunrun_Credit_Status__c == 'PASS' && oldCCObj.Sunrun_Credit_Status__c != 'PASS') ||(ccObj.Sunrun_Credit_Status__c == 'CPASS' && oldCCObj.Sunrun_Credit_Status__c != 'CPASS') || (ccObj.Sunrun_Credit_Status__c == 'MANUAL' && oldCCObj.Sunrun_Credit_Status__c != 'MANUAL') || (ccObj.Sunrun_Credit_Status__c == 'FAIL' && oldCCObj.Sunrun_Credit_Status__c != 'FAIL')) && 
             (ccObj.Status__c == 'N/A' || ccObj.Status__c == 'CPASS' || ccObj.Status__c == 'PASS' || ccObj.Status__c == 'FAIL' || ccObj.Status__c == 'MANUAL')) ||
            
            (((ccObj.Status__c == 'N/A' || ccObj.Status__c == 'CPASS' || ccObj.Status__c == 'PASS' || ccObj.Status__c == 'FAIL' || ccObj.Status__c =='MANUAL') &&
              (oldCCObj.Status__c != 'N/A' || oldCCObj.Status__c != 'CPASS' || oldCCObj.Status__c != 'PASS' || oldCCObj.Status__c != 'FAIL'  || oldCCObj.Status__c!= 'MANUAL')) &&
             ((ccObj.Sunrun_Credit_Status__c == 'PASS' && oldCCObj.Sunrun_Credit_Status__c != 'PASS') ||(ccObj.Sunrun_Credit_Status__c == 'CPASS' && oldCCObj.Sunrun_Credit_Status__c != 'CPASS') || (ccobj.Sunrun_Credit_Status__c ==' MANUAL' && oldCCObj.Sunrun_Credit_Status__c != 'MANUAL') ||(ccObj.Sunrun_Credit_Status__c == 'FAIL' && oldCCObj.Sunrun_Credit_Status__c !='FAIL')))) &&
           (!loginProfileId.contains(financeCreditProfileId))&&
           (ccObj.Credit_Email_Sent__c != True))
        {
            CreditUpdateList.add(ccObj);
            DealCreditSet.add(ccObj.Deal_Id__c);
            System.debug('Inside ...');
        }
        System.debug('DealCreditSet: ' + DealCreditSet);
    }
    if(!DealCreditSet.isEmpty()){
        OppDealIdList = [Select Id,Deal_Id__c,Sales_Representative__r.Email from Opportunity where Deal_Id__c IN :DealCreditSet];
        
        if(!OppDealIdList.isEmpty()){
            for(Opportunity opp : OppDealIdList ){
                DealIdvsOppIdMap.put(opp.Deal_Id__c,opp.Id);  
            }
            
            SendEmailClass SMail = New SendEmailClass();
            SMail.SendEmailCredit(CreditUpdateList,DealIdvsOppIdMap,Trigger.oldMap);
        }
    }
    */
}