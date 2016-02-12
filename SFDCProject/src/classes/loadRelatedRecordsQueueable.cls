public class loadRelatedRecordsQueueable implements Queueable{

    public Set<Id> leadIdSet {get;set;}
    public Set<Id> asyncReqIdSet {get;set;}
    
    public loadRelatedRecordsQueueable() {
    	this(null, null);
    }
    
    public loadRelatedRecordsQueueable(Set<Id> leadIdSet, Set<Id> asyncReqIdSet) {
        this.leadIdSet = leadIdSet;
        this.asyncReqIdSet = asyncReqIdSet;
    }
      
    public void execute(QueueableContext ctx) {
           DateTime reqStartTime = Datetime.now(); 
           List<Async_Process_Queue__c> asyncReqList = [select Id, Request_Status__c, Response_Details__c, Request_Start_Time__c, Request_End_Time__c  
                                                          from Async_Process_Queue__c
                                                         where Id in :asyncReqIdSet];
            try{
                LeadDeDupServiceImpl.loadRelatedRecords(leadIdSet);     
                LeadDeDupServiceImpl.updateAsyncProcessQueueRec(asyncReqList, reqStartTime, 'Success', 'Related Records loaded successesfully');  
            }catch(Exception e){
                String responseDetails = 'Failed to load Related Records with Exception' + e;
                LeadDeDupServiceImpl.updateAsyncProcessQueueRec(asyncReqList, reqStartTime, 'Error', responseDetails);  
            }
    }

}