global class scheduleProposalStageBatchRules implements Schedulable 
{
    global void execute(SchedulableContext ctx)
    {
        ProposalStageUpdateBatchRules.processProposalStageUpdate();
    }
    
     public static void startScheduleProposalStageBatchRules()
    {
        //Seconds Minutes Hours Day_of_month Month Day_of_week optional_year
        System.schedule('Proposal Stage Update Batch Process - 0', '0 0 0-23 * * ?', new scheduleProposalStageBatchRules());

    }
}