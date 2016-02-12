global class BatchApexSCAttachment implements Database.Batchable<sObject>,Database.AllowsCallouts {
    public string query;
    public set<String> leadSet;
    
  global BatchApexSCAttachment(string q){
      query = q;
    }        
       
    global Database.QueryLocator start(Database.BatchableContext BC) {        
        return Database.getQueryLocator(query);        
    }
    global void execute(Database.BatchableContext BC, List<sObject> scope) {  
        Set<string> GASet=new Set<string>();
        for(sObject s: scope){ 
          ServiceContract sc= (ServiceContract )s;
          GASet.add(sc.Legacy_Asset_ID__c);   
       }
        Map<id,List<attachment>> attMap=new Map<id,List<attachment>>();
        for(attachment a:[select name,parentid,body from attachment where parentid in:GASet]){
        List<attachment> lstAtt=attMap.get(a.parentid);
        if(lstAtt==null)
        attMap.put(a.parentid,new List<attachment>{a});
        else
        lstAtt.add(a);
        }
        Map<id,servicecontract> scMap=new Map<id,servicecontract>();
        list<attachment> lList=new List<attachment>();
        for(servicecontract sc:[select id,Legacy_Asset_ID__c from servicecontract where Legacy_Asset_ID__c  in:GASet]){
        if(attMap.containskey(sc.Legacy_Asset_ID__c )){
            for(attachment a:attMap.get(sc.legacy_asset_id__c)){
            attachment a1=new attachment(body=a.body,parentid=sc.id,name=a.name);
                lList.add(a1);
        }
        }
        }
        if(!lList.isempty()){
        system.debug('----'+lList); 
        insert lList;
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