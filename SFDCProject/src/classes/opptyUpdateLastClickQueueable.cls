public class opptyUpdateLastClickQueueable extends BaseClass implements Queueable{

    public Set<Id> recIdSet {get;set;}
    public Set<Id> asyncReqIdSet {get;set;}
    
    public opptyUpdateLastClickQueueable() {
        this(null, null);
    }
    
    public opptyUpdateLastClickQueueable(Set<Id> recIdSet, Set<Id> asyncReqIdSet) {
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
            	LeadDeDupServiceImpl.updateLastClickForDups(recIdSet, 'Opportunity');   
                LeadDeDupServiceImpl.updateAsyncProcessQueueRec(asyncReqList, reqStartTime, 'Success', 'Last Click for duplicate opptys updated successesfully');
                
                String jobID = enqueueJobWithCheck(new loadRelatedRecordsQueueable(recIdSet, asyncReqIdSet));
            	if(jobID == null){
                	System.debug('Load Related Leads request can not be submitted');
                    LeadDeDupServiceImpl.updateAsyncProcessQueueRec(asyncReqList, reqStartTime, 'Error', 'Failed to invoke loadRelatedRecordsQueueable');
            	}                    

            }catch(Exception e){
                String responseDetails = 'Last Click for duplicate opptys update failed with Exception' + e;
                LeadDeDupServiceImpl.updateAsyncProcessQueueRec(asyncReqList, reqStartTime, 'Error', responseDetails);

                String jobID = enqueueJobWithCheck(new loadRelatedRecordsQueueable(recIdSet, asyncReqIdSet));
            	if(jobID == null){
                	System.debug('Load Related Leads request can not be submitted');
                    LeadDeDupServiceImpl.updateAsyncProcessQueueRec(asyncReqList, reqStartTime, 'Error', 'Failed to invoke loadRelatedRecordsQueueable');
            	}                    

            }//End Catch
            
        }//End-if
        
    }//End Execute    
}