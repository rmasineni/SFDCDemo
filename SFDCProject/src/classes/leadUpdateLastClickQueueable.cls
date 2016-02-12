public class leadUpdateLastClickQueueable extends BaseClass implements Queueable{

    public Set<Id> recIdSet {get;set;}
    public Set<Id> asyncReqIdSet {get;set;}
    
    public leadUpdateLastClickQueueable() {
        this(null, null);
    }
    
    public leadUpdateLastClickQueueable(Set<Id> recIdSet, Set<Id> asyncReqIdSet) {
        this.recIdSet = recIdSet;
        this.asyncReqIdSet = asyncReqIdSet; 
    }
      
    public void execute(QueueableContext ctx) {
        DateTime reqStartTime = Datetime.now(); 
         
        List<Async_Process_Queue__c> asyncReqList = [select Id, Request_Status__c, Response_Details__c, Request_Start_Time__c, Request_End_Time__c  
                                                       from Async_Process_Queue__c
                                                      where Id in :asyncReqIdSet];
        if(!recIdSet.isEmpty()){
            try{
                LeadDeDupServiceImpl.updateLastClickForDups(recIdSet, 'Lead');  
                LeadDeDupServiceImpl.updateAsyncProcessQueueRec(asyncReqList, reqStartTime, 'Success', 'Last Click for duplicate leads updated successesfully');

                String jobID = enqueueJobWithCheck(new opptyUpdateLastClickQueueable(recIdSet, asyncReqIdSet));
                if(jobID == null){
                    System.debug('Update Last Click request can not be submitted');
                    LeadDeDupServiceImpl.updateAsyncProcessQueueRec(asyncReqList, reqStartTime, 'Error', 'Failed to invoke opptyUpdateLastClickQueueable');
                }

            }catch(Exception e){
                String responseDetails = 'Last Click for duplicate leads update failed with Exception' + e;
                LeadDeDupServiceImpl.updateAsyncProcessQueueRec(asyncReqList, reqStartTime, 'Error', responseDetails);

                String jobID = enqueueJobWithCheck(new opptyUpdateLastClickQueueable(recIdSet, asyncReqIdSet));
                if(jobID == null){
                   System.debug('Update Last Click request can not be submitted');
                    LeadDeDupServiceImpl.updateAsyncProcessQueueRec(asyncReqList, reqStartTime, 'Error', 'Failed to invoke opptyUpdateLastClickQueueable');
                }

            }//end Catch

        }//End-if
        
    }//End Execute    

}