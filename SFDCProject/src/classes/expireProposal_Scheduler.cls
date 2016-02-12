global class expireProposal_Scheduler implements Schedulable{

    public expireProposal_Scheduler(){
                
    }
    
    global void execute(SchedulableContext SCtx) {  
        expireProposalsBatch batchObj = new expireProposalsBatch();
        id batchinstanceid = database.executeBatch(batchObj, 500);  
    }
}