trigger PaymentTransactionShare on Payment_Transaction__c (after insert) {
    Set<id> PayTranscIds=new Set<id>();
    for(Payment_Transaction__c payTransc:trigger.new){
        if(payTransc.Opportunity_Source_Type__c=='PT'&&payTransc.Sales_Partner__c!=null){
            PayTranscIds.add(payTransc.id);
        }   
    }
    if(!PayTranscIds.isempty()){
        List<Payment_Transaction__Share> PTShareList=new List<Payment_Transaction__Share>();
        for(Id payTransId:PayTranscIds){
            Payment_Transaction__Share PS=new Payment_Transaction__Share();
            PS.AccessLevel='Edit';
            PS.ParentId=payTransId;
            PS.UserOrGroupId=UserInfo.getUserId();
            PTShareList.add(PS);
        }
        if(!PTShareList.isEmpty()){
            Database.SaveResult[] result = database.insert(PTShareList,false);
        }
        PaymentTransactionShare.PaymentTransactionShare(PayTranscIds);
    }   
}