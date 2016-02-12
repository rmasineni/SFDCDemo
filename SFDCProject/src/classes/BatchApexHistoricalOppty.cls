global class BatchApexHistoricalOppty implements Database.Batchable<sObject>,Database.AllowsCallouts {
    public string query;
    public Map<id,id> UserAccountMap=new Map<id,id>();
    public set<id> ids;
    
  global BatchApexHistoricalOppty(string q){
      query = q;
    }        
       
    global Database.QueryLocator start(Database.BatchableContext BC) {        
        return Database.getQueryLocator(query);        
    }
    global void execute(Database.BatchableContext BC, List<sObject> scope) {   
         List<OpportunityShare> opptyShares = new List<OpportunityShare>();
         List<ContactShare> conShares = new List<ContactShare>();
         Map<id,id> userOptyIds = new Map<id,id>();             
        for(sObject p: scope){ 
          Proposal__c pp = (Proposal__c )p;
            if(UserAccountMap.containsKey(pp.Sales_Partner__c)){
            OpportunityShare os=new OpportunityShare(OpportunityId=pp.opportunity__c,OpportunityAccessLevel='Edit',UserOrGroupid=UserAccountMap.get(pp.Sales_Partner__c) );
            opptyShares.add(os);
            userOptyids.put(pp.opportunity__c,UserAccountMap.get(pp.Sales_Partner__c));
            }
            else if(UserAccountMap.containsKey(pp.Install_Partner__c)){
            OpportunityShare os=new OpportunityShare(OpportunityId=pp.opportunity__c,OpportunityAccessLevel='Edit',UserOrGroupid=UserAccountMap.get(pp.Install_Partner__c) );
            opptyShares.add(os);
             userOptyIds.put(pp.opportunity__c,UserAccountMap.get(pp.Install_Partner__c)); 
            }               
        }
          if(!userOptyIds.isEmpty()){
          
          for(OpportunityContactRole OCR:[select Id, ContactId, OpportunityId from OpportunityContactRole where OpportunityId in: userOptyids.keyset()]){
            ContactShare cs = new ContactShare(ContactId=OCR.ContactId,ContactAccessLevel='Edit',UserOrGroupid=UserOptyids.get(OCR.OpportunityId));
            conShares.add(cs); 
          }
        }                 
          if(!conShares.isEmpty()){
            try{    
            Database.SaveResult[] results = Database.insert(conShares,false);
            if(results != null){
                for(Database.saveresult result:results){
                    if(!result.isSuccess()){
                        Database.Error[] errs = result.getErrors();
                        for(Database.Error err : errs)
                            system.debug(err.getStatusCode() + ' - ' + err.getMessage());
                    }
                }
            }
            
            }
          catch (Exception e) {
            System.debug(e.getTypeName() + ' - ' + e.getCause() + ':' + e.getMessage());
          }
          }
          if(!opptyShares.isEmpty()){
           try {
         
            Database.SaveResult[] results = Database.insert(opptyShares,false);
            if (results != null){
                for (Database.SaveResult result : results) {
                    if (!result.isSuccess()) {
                        Database.Error[] errs = result.getErrors();
                        for(Database.Error err : errs)
                            System.debug(err.getStatusCode() + ' - ' + err.getMessage());
         
                    }
                }
            }
         
            } 
          catch (Exception e) {
            System.debug(e.getTypeName() + ' - ' + e.getCause() + ': ' + e.getMessage());
          } 
          }
    }
     global void finish(Database.BatchableContext BC) {   
        AsyncApexJob a = [Select Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email from AsyncApexJob where Id =:BC.getJobId()];    
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[] {a.CreatedBy.Email};
        mail.setToAddresses(toAddresses);
        mail.setSubject('Batch Apex Job' + a.Status);
        mail.setPlainTextBody('The batch Apex job processed '+ a.TotalJobItems + 'batches with '+ a.NumberOfErrors + ' failures.');
        try{
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }
        catch(exception e){
        system.debug(e);
        }
    }
}