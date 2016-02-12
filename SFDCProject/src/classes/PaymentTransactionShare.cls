public class PaymentTransactionShare {
    @future
    Public static void PaymentTransactionShare(Set<id> PayTranscIds){        
    List<Payment_Transaction__Share> PTShareList=new List<Payment_Transaction__Share>();
    Map<id,List<User>> UserAccMap=new Map<id,List<User>>();
    Set<id> accountIds=new Set<id>();
    //PayMent Transaction Occur one at a time(no bulk uploads)
    List<Payment_Transaction__c> PayTrancsList=[select id,Sales_Partner__c,opportunity__r.Sales_Partner__c from Payment_Transaction__c where id in:PayTranscIds];
    for(Payment_Transaction__c paytransc:PayTrancsList){
        accountIds.add(paytransc.Sales_Partner__c);
    }
    system.debug('---acc'+accountIds);
    for(User userObj:[select id,Contact.AccountId from user where Contact.AccountId=:accountIds]){
       List<User> userLst=UserAccMap.get(userObj.Contact.AccountId);
       if(userLst==null){
        UserAccMap.put(userObj.Contact.AccountId,new List<User>{userObj});
        }
        else{
        userLst.add(userObj);
        }
    }
    for(Payment_Transaction__c paytransc:PayTrancsList){
        for(User userObj:UserAccMap.get(paytransc.Sales_Partner__c)){
            Payment_Transaction__Share PS=new Payment_Transaction__Share();
            PS.AccessLevel='Edit';
            PS.ParentId=paytransc.id;
            PS.UserOrGroupId=userObj.Id;
            PTShareList.add(PS);
        }
    }
    system.debug('---PayTran'+PTShareList);
    if(!PTShareList.isEmpty()){
            Database.SaveResult[] result = database.insert(PTShareList,false);
    }   
}
}