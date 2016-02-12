public class BreaLeadShare {
  //@Future
  Public static void BreaLeadShare(Set<id> LeadSet){
    Set<id> accountIds=new Set<id>();
    Map<id,id> UserLeadMap=new Map<id,id>();    
    Map<id,List<User>> UserAccMap=new Map<id,List<User>>();    
     List<LeadShare> LSShareList=new List<LeadShare>();
     List<lead> lst_lead=[Select id,Sales_Partner__c,Install_Partner__c,SalesRep__c from lead where id in:LeadSet];     
    for(lead l:lst_lead){
      if(l.Sales_Partner__c!=null){
        accountIds.add(l.Sales_Partner__c);
      }
      if(l.Install_Partner__c!=null){
        accountIds.add(l.Install_Partner__c);
      }
      if(l.SalesRep__c!=null){
        UserLeadMap.put(l.id,l.SalesRep__c);
      }
    }
    if(!UserLeadMap.isempty()){
      for(Id id:UserLeadMap.KeySet()){
            LeadShare LS=new LeadShare();
                  LS.LeadAccessLevel='Edit';
                  LS.LeadId=id;
                  LS.UserOrGroupId=UserLeadMap.get(id);
                  LSShareList.add(LS);
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
      for(Lead l:lst_Lead){
        if(l.Sales_Partner__c==l.Install_Partner__c&&UserAccMap.containsKey(l.Sales_Partner__c)){
          for(User userObj:UserAccMap.get(l.Sales_Partner__c)){
                  LeadShare LS=new LeadShare();
                  LS.LeadAccessLevel='Edit';
                  LS.LeadId=l.id;
                  LS.UserOrGroupId=userObj.Id;
                  LSShareList.add(LS);
              }
        }
        else if(UserAccMap.containsKey(l.Sales_Partner__c)){
          for(User userObj:UserAccMap.get(l.Sales_Partner__c)){
                  LeadShare LS=new LeadShare();
                  LS.LeadAccessLevel ='Edit';
                  LS.LeadId=l.id;
                  LS.UserOrGroupId=userObj.Id;
                  LSShareList.add(LS);
              }
              if(UserAccMap.containsKey(l.Install_Partner__c)){
                for(User userObj:UserAccMap.get(l.Install_Partner__c)){
                  LeadShare LS=new LeadShare();
                  LS.LeadAccessLevel='Edit';
                  LS.LeadId=l.id;
                  LS.UserOrGroupId=userObj.Id;
                  LSShareList.add(LS);
              }
              }
        }
      }
      if(!LSShareList.isEmpty()){
            Database.SaveResult[] result = database.insert(LSShareList,false);
        }  
    }
  }
}