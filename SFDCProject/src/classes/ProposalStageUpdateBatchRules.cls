public with sharing class ProposalStageUpdateBatchRules {

    public static void processProposalStageUpdate(){
		
		Set<String> proposalStages = new Set<String>();
		proposalStages.add('Pending');
		proposalStages.add('On hold');
		proposalStages.add('Created');
		String nameLike = 'P%';
		String proposalSOQLStr = ' SELECT id, Name, stage__c,  Stage_Last_Modified__c, CreatedDate FROM Proposal__c ';
		proposalSOQLStr += ' Where stage__c in :proposalStages ' ;
		proposalSOQLStr += ' AND Revised_Proposal__c = false ' ;
		proposalSOQLStr += ' AND Name Like :nameLike ' ;
		
		If(Test.isRunningTest()){
			proposalSOQLStr += ' and Stage_Last_Modified__c < :expdate ' ;
			proposalSOQLStr += ' limit 10 ' ;
		}
      
        Date expdate = date.today().addDays(-60);
        system.debug('Today'+ date.today());
        system.debug('Date to set EXPIRED Stage:' + expdate);
        
        List<Proposal__c> updateproposalRecList = new List<Proposal__c>();
        for(Proposal__c selProposalRec  : Database.query(proposalSOQLStr)){
            system.debug('Inside For Loop');
            DateTime createdDT = selProposalRec.createddate;
            Date propCreatedDate = Date.newInstance(createdDT.year(),createdDT.Month(),createdDT.day());
            
            if(selProposalRec.Stage__c == 'On Hold' && selProposalRec.Stage_Last_Modified__c < expdate){
                system.debug('On Hold Stage_Last_Modified__c' + selProposalRec.Stage_Last_Modified__c);
                selProposalRec.Stage__c = 'Expired';
                updateproposalRecList.add(selProposalRec);
                //update selProposalRec;
            }else if(selProposalRec.Stage__c == 'Pending' && selProposalRec.Stage_Last_Modified__c < expdate){
                system.debug('Pending Stage_Last_Modified__c' + selProposalRec.Stage_Last_Modified__c);
                selProposalRec.Stage__c = 'Expired';
                updateproposalRecList.add(selProposalRec);
                //update selProposalRec;
            }else if(selProposalRec.Stage__c == 'Created' && propCreatedDate < expdate){
                system.debug('Created Date' + propCreatedDate);
                selProposalRec.Stage__c = 'Expired';
                updateproposalRecList.add(selProposalRec);
                //update selProposalRec;
            }                                           
        }
        
        if(updateproposalRecList != Null && updateproposalRecList.size() > 0){
            update updateproposalRecList;
        }
    }
}