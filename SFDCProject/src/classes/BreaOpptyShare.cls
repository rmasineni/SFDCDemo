public without sharing class BreaOpptyShare {
  @Future
  Public static void BreaOpptyShare(Set<id> OpptySet){
    Set<id> accountIds=new Set<id>();
    Map<id,id> UserOpptyMap=new Map<id,id>();    
    Map<id,List<User>> UserAccMap=new Map<id,List<User>>();    
     List<OpportunityShare> OSShareList=new List<OpportunityShare>();
     List<Opportunity> lst_Oppty=[Select id,Sales_Partner__c,Install_Partner__c,SalesRep__c from Opportunity where id in:OpptySet];     
    for(Opportunity o:lst_Oppty){
      if(o.Sales_Partner__c!=null){
        accountIds.add(o.Sales_Partner__c);
      }
      if(o.Install_Partner__c!=null){
        accountIds.add(o.Install_Partner__c);
      }
      if(o.SalesRep__c!=null){
        UserOpptyMap.put(o.id,o.SalesRep__c);
      }
    }
    if(!UserOpptyMap.isempty()){
      for(Id id:UserOpptyMap.KeySet()){
            OpportunityShare OS=new OpportunityShare();
                  OS.OpportunityAccessLevel='Edit';
                  OS.OpportunityId=id;
                  OS.UserOrGroupId=UserOpptyMap.get(id);
                  OSShareList.add(OS);
      }
    }
    if(!accountIds.isempty()){
      for(User userObj:[select id,Contact.AccountId from user where Contact.AccountId in:accountIds and ProfileId=:System.label.Partner_Ops_Profile_Id]){
         List<User> userLst=UserAccMap.get(userObj.Contact.AccountId);
               if(userLst==null){
              UserAccMap.put(userObj.Contact.AccountId,new List<User>{userObj});
              }
              else{
              userLst.add(userObj);
              }
      }
      for(Opportunity o:lst_Oppty){
        if(o.Sales_Partner__c==o.Install_Partner__c&&UserAccMap.containsKey(o.Sales_Partner__c)){
          for(User userObj:UserAccMap.get(o.Sales_Partner__c)){
                  OpportunityShare OS=new OpportunityShare();
                  OS.OpportunityAccessLevel='Edit';
                  OS.OpportunityId=o.id;
                  OS.UserOrGroupId=userObj.Id;
                  OSShareList.add(OS);
              }
        }
        else {
        if(UserAccMap.containsKey(o.Sales_Partner__c)){
          for(User userObj:UserAccMap.get(o.Sales_Partner__c)){
                  OpportunityShare OS=new OpportunityShare();
                  OS.OpportunityAccessLevel ='Edit';
                  OS.OpportunityId=o.id;
                  OS.UserOrGroupId=userObj.Id;
                  OSShareList.add(OS);
              }
              }
              if(UserAccMap.containsKey(o.Install_Partner__c)){
                for(User userObj:UserAccMap.get(o.Install_Partner__c)){
                  OpportunityShare OS=new OpportunityShare();
                  OS.OpportunityAccessLevel='Edit';
                  OS.OpportunityId=o.id;
                  OS.UserOrGroupId=userObj.Id;
                  OSShareList.add(OS);
              }
              }
        }
      }
      system.debug('--->opptyShare'+OSShareList);
      if(!OSShareList.isEmpty()){
            system.debug('--->opptyShare'+OSShareList);
            Database.SaveResult[] result = database.insert(OSShareList,false);
        }  
    }
  }
  /*
  public static void BreaOpptyShare_Immediate(Set<id> OpptySet){
   List<OpportunityShare> OSShareList=new List<OpportunityShare>();
          for(Id id:OpptySet){
                  OpportunityShare OS=new OpportunityShare();
                  OS.OpportunityAccessLevel='Edit';
                  OS.OpportunityId=id;
                  OS.UserOrGroupId=Userinfo.getUserId();
                  OSShareList.add(OS);
          }
          database.insert(OSShareList,false);
  }
    */
}