trigger trg_after_insert_opptyshare on User (after insert, after update) {  
    /*
     Set<id> partnerProfile=new Set<id>();
     for(Profile p:[select id from profile where name ='PartnerOperations' or name='PartnerAdmin']){
        partnerProfile.add(p.id);
     }*/
     Map<id,id> UserAccountMap=new Map<id,id>();
     List<OpportunityShare> opptyShares = new List<OpportunityShare>();      
      for(User u: Trigger.new){
        if(trigger.oldmap!=null&&trigger.oldmap.get(u.id).Share_Historical_Opportunities__c!=trigger.newmap.get(u.id).Share_Historical_Opportunities__c &&u.Share_Historical_Opportunities__c== true && u.IsActive == true) {
          UserAccountMap.put(u.Account_Id__c,u.id);     
        } 
     }     
    system.debug('----'+UserAccountMap);
    if(!UserAccountMap.isempty()){
        String query='select id,opportunity__c,Sales_Partner__c,Install_Partner__c from Proposal__c where ( Install_Partner__c in:ids or Sales_Partner__c in:ids ) and createddate = LAST_90_DAYS order by createddate desc';
        if(Test.isrunningtest()){
        query='select id,opportunity__c,Sales_Partner__c,Install_Partner__c from Proposal__c where Install_Partner__c in:ids or Sales_Partner__c in:ids limit 10';
        }
        BatchApexHistoricalOppty batch=new BatchApexHistoricalOppty(query); 
        batch.ids=UserAccountMap.keyset();
        batch.UserAccountMap=UserAccountMap;
        Database.executeBatch(batch,200);
    }
    
}