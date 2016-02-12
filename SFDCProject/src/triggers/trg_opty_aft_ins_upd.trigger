trigger trg_opty_aft_ins_upd on Opportunity (after insert, after update) {

	Boolean skipValidations = false;
	skipValidations = SkipTriggerValidation.performTriggerValidations();
	if(skipValidations == false){     
    Set<Id> closedLostOpportunityIds = new Set<Id>();
    Set<Id> proposalIdsForVoid = new Set<Id>();
	Map<Id, Opportunity> modifiedProjectNumbers = new Map<Id, Opportunity>();
    Map<Id, Map<Id, Proposal__C>> opportunityProposalmap;
    Map<Id, Proposal__c> voidedProposals = new Map<Id, Proposal__c>();
    for(Opportunity optyObj:Trigger.New)
    {

        Opportunity oldOpportunity;
        if(Trigger.isUpdate){
            opportunityProposalmap = ProposalUtil.getActiveProposalsForOpportunities(null);
            oldOpportunity = Trigger.oldMap.get(optyObj.Id);
            //Code change from closed/lost to Unqualified
            if(('Unqualified' == optyObj.StageName)
             && (oldOpportunity != null && oldOpportunity.StageName != optyObj.StageName))
            {
                closedLostOpportunityIds.add(optyObj.Id);
            }

            if(oldOpportunity != null && oldOpportunity.Project_Number__c != optyObj.Project_Number__c)
            {
				modifiedProjectNumbers.put(optyObj.Id, optyObj);
            }

            if(OpportunityUtil.eligibleForVoid.contains(optyObj.Id) 
                && !OpportunityUtil.voidedOpportunityIds.contains(optyObj.Id)){
                OpportunityUtil.voidedOpportunityIds.add(optyObj.Id);
                if(opportunityProposalmap != null){
                    Map<Id, Proposal__C> proposalMap = opportunityProposalmap.get(optyObj.Id);
                    if(proposalMap != null && !proposalMap.isEmpty()){
                        voidedProposals.putAll(proposalMap);
                    }
                }

            }
            
        }
        
    }
	
	if(modifiedProjectNumbers != null && !modifiedProjectNumbers.isEmpty()){
		wfUtil.updateJobCode(modifiedProjectNumbers);
	}
    if(voidedProposals != null && !voidedProposals.isEmpty()){
        Map<Id, String> reasonMap = new Map<Id, String>();
        for(Proposal__c tempProposalObj : voidedProposals.values()){
            if(OpportunityUtil.reasonMap.containskey(tempProposalObj.Opportunity__c)){
                reasonMap.put(tempProposalObj.Id, OpportunityUtil.reasonMap.get(tempProposalObj.Opportunity__c));
            }else{
                reasonMap.put(tempProposalObj.Id, ProposalUtil.OPPORTUNITY_CHANGE);
            }
        }
        ProposalUtil.voidProposals(voidedProposals, reasonMap, true);
    }

    if(closedLostOpportunityIds.size() > 0){
        EDPUtil.cancelProposals(closedLostOpportunityIds);
    }
    
    Notes__c noteobj = new Notes__c();
    for(Opportunity optyObj:Trigger.New)
    {
         if(Trigger.isInsert){

                if(optyObj.Notes__c != null && optyObj.Notes__c != ''){
                    noteobj.Notes__c = optyObj.Notes__c;
                    noteobj.Opportunity__c = optyObj.Id;
                    noteobj.Notes_Added_By__c = getwhichOrg();
                    insert noteobj;
                }
                if(optyObj.Partner_Notes__c != null && optyObj.Partner_Notes__c != ''){

                    system.debug('Oppty' + optyObj.Id);
                    noteobj.Notes__c = optyObj.Partner_Notes__c;
                    noteobj.Opportunity__c = optyObj.Id;
                    noteobj.Notes_Added_By__c = getwhichOrg();
                    insert noteobj;
                }

            }
            if(Trigger.isUpdate && optyObj.Notes__c != Trigger.oldMap.get(optyObj.id).Notes__c){
                noteobj.Notes__c = optyObj.Notes__c;
                noteobj.Opportunity__c = optyObj.Id;
                noteobj.Notes_Added_By__c = getwhichOrg();
                insert noteobj;
            }
            if(Trigger.isUpdate && optyObj.Partner_Notes__c != Trigger.oldMap.get(optyObj.id).Partner_Notes__c){
                noteobj.Notes__c = optyObj.Partner_Notes__c;
                noteobj.Opportunity__c = optyObj.Id;
                noteobj.Notes_Added_By__c = getwhichOrg();
                insert noteobj;
            }
      }
	}
	
       private string getwhichOrg(){
        
        
        Contact contobj = PRMContactUtil.getLoginUserContact();
        Boolean ispartnerUser = false;
        
        if(contobj != null){
            ispartnerUser = true;
        }
        
        String whichOrgValue;
    
        if(ispartnerUser == true){
            
            system.debug('Organization Name' + contobj.Account.Name);
            whichOrgValue = contobj.Account.Name;
            return whichOrgValue;
        }
        
        whichOrgValue = 'SunRun';
        return whichOrgValue;
        
    }
    
}