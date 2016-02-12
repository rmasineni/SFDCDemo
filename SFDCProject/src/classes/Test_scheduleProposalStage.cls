@isTest (SeeAllData = true)  
public class Test_scheduleProposalStage {
    static testMethod void TestscheduleProposalStage() {
     	Test.startTest();
			scheduleProposalStageBatchRules scheduleProposalStageObj = new scheduleProposalStageBatchRules();
			String schedule = '0 0 23 * * ?';
			system.schedule('Proposal Stage Update Batch Process', schedule, scheduleProposalStageObj);
			scheduleProposalStageBatchRules.startScheduleProposalStageBatchRules();
		Test.stopTest();
    }
    
}