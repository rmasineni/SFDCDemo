trigger trg_case_milestone_after_upd on Case (after update, after delete) 
{
	Boolean skipValidations = false;
	skipValidations = SkipTriggerValidation.performTriggerValidations();
	if(skipValidations == false){
		Set <Id> caseIds = new Set <Id>();
		Set <Id> assetIds = new Set <Id>();
		Set <Id> scIds = new Set <Id>();
		Set <Id> m1AssetIds = new Set <Id>();
		Set <Id> m2AssetIds = new Set <Id>();
		Set <Id> m3AssetIds = new Set <Id>();
	
		Set <Id> scM1AssetIds = new Set <Id>();
		Set <Id> scM2AssetIds = new Set <Id>();
		Set <Id> scM3AssetIds = new Set <Id>();
	
		List<Generation_Assets__c> assetsToUpdate = new List<Generation_Assets__c>();
		List<ServiceContract> serviceContractsToUpdate = new List<ServiceContract>();
		List<Case> casesToUpdate = new List<Case>();
		if (System.Trigger.isUpdate)
		{
		    for(Integer i = 0;i<Trigger.new.size();i++)
		    {      
		        if (Trigger.new[i].Status != Trigger.old[i].Status)
		        {
		        	caseIds.add(Trigger.new[i].Id);
		        }
		        if (Trigger.new[i].Generation_Asset__c != null)
		        {
					assetIds.add(Trigger.new[i].Generation_Asset__c);
		        }            
		        if (Trigger.new[i].Service_Contract__c != null)
		        {
					scIds.add(Trigger.new[i].Service_Contract__c);
		        } 
	
		    }    
		}
		else if (System.Trigger.isDelete)
		{
			for(Integer i = 0;i<Trigger.old.size();i++)
	        {
	            if (Trigger.old[i].Generation_Asset__c != null && Trigger.old[i].Milestone_Proof_Type__c == 'M1 Proof')
	            {
					m1AssetIds.add(Trigger.old[i].Generation_Asset__c);
	            }
	            else if (Trigger.old[i].Generation_Asset__c != null && Trigger.old[i].Milestone_Proof_Type__c == 'M2 Proof')
	            {
					m2AssetIds.add(Trigger.old[i].Generation_Asset__c);
	            }
	            else if (Trigger.old[i].Generation_Asset__c != null && Trigger.old[i].Milestone_Proof_Type__c == 'M3 Proof')
	            {
					m3AssetIds.add(Trigger.old[i].Generation_Asset__c);
	            }else if (Trigger.old[i].Service_Contract__c != null && Trigger.old[i].Milestone_Proof_Type__c == 'M1 Proof')
	            {
					scM1AssetIds.add(Trigger.old[i].Service_Contract__c);
	            }
	            else if (Trigger.old[i].Service_Contract__c != null && Trigger.old[i].Milestone_Proof_Type__c == 'M2 Proof')
	            {
					scM2AssetIds.add(Trigger.old[i].Service_Contract__c);
	            }
	            else if (Trigger.old[i].Service_Contract__c != null && Trigger.old[i].Milestone_Proof_Type__c == 'M3 Proof')
	            {
					scM3AssetIds.add(Trigger.old[i].Service_Contract__c);
	            }
	        }    
		}
	
		if (System.Trigger.isUpdate)
		{
			if (caseIds != null && caseIds.size() > 0)
			{
				if(scIds != null && !scIds.isEmpty()){
					ServiceContractUtil.updateMilestoneProofInformation(scIds, caseIds);
				}
				if(assetIds != null && !assetIds.isEmpty()){
					Map<Id, Generation_Assets__c> assetMap = new Map<Id, Generation_Assets__c>([SELECT Id, M1_Proof_Upload_Date__c, M2_Proof_Upload_Date__c, 
																								M3_Proof_Upload_Date__c, M1_Status__c, M2_Status__c, 
																								M3_Status__c, M1_proof_panel_inverter_delivery__c, M2_proof_substantial_completion__c, 
																								M1_Denied_Comments__c,M2_Denied_Comments__c, M3_Denied_Comments__c
																								FROM Generation_Assets__c WHERE Id IN :assetIds]);
					
					for(Case caseRec:[Select Id,Status, Milestone_Proof_Type__c, Milestone_Proof_Approval_Date__c, Denied_Comment__c, Generation_Asset__c from Case where Id in:caseIds And Generation_Asset__c != null And RecordTypeId In (Select Id from RecordType Where SobjectType = 'Case' And DeveloperName = 'Milestone_Proof')])
			    	{
						Generation_Assets__c assetRec = assetMap.get((ID)caseRec.Generation_Asset__c);
						if (caseRec.Status == 'Request Approval' && caseRec.Milestone_Proof_Type__c == 'M1 Proof')
						{
							assetRec.M1_Status__c = 'Pending';
							assetRec.M1_proof_panel_inverter_delivery__c = null;
						}    		
						else if (caseRec.Status == 'Request Approval' && caseRec.Milestone_Proof_Type__c == 'M2 Proof')
						{
							assetRec.M2_Status__c = 'Pending';
							assetRec.M2_proof_substantial_completion__c = null;
						}    		
						else if (caseRec.Status == 'Request Approval' && caseRec.Milestone_Proof_Type__c == 'M3 Proof')
						{
							assetRec.M3_Status__c = 'Pending';
						}    		
						else if (caseRec.Status == 'M1 Proof Approved' && caseRec.Milestone_Proof_Type__c == 'M1 Proof')
						{
							assetRec.M1_Status__c = 'Approved';
			//				assetRec.M1_proof_panel_inverter_delivery__c = date.today();
							assetRec.M1_proof_panel_inverter_delivery__c = assetRec.M1_Proof_Upload_Date__c;
							caseRec.Milestone_Proof_Approval_Date__c = date.today();
			
							casesToUpdate.add(caseRec);
							
						}    		
						else if (caseRec.Status == 'M2 Proof Approved (non meter test)' && caseRec.Milestone_Proof_Type__c == 'M2 Proof')
						{
							assetRec.M2_Status__c = 'Approved';
			//				assetRec.M2_proof_substantial_completion__c = date.today();
							assetRec.M2_proof_substantial_completion__c = assetRec.M2_Proof_Upload_Date__c;
							caseRec.Milestone_Proof_Approval_Date__c = date.today();
							casesToUpdate.add(caseRec);
						}    		
						else if (caseRec.Status == 'M3 PTO Approved' && caseRec.Milestone_Proof_Type__c == 'M3 Proof')
						{
							assetRec.M3_Status__c = 'Approved';
							
							caseRec.Milestone_Proof_Approval_Date__c = date.today();
							casesToUpdate.add(caseRec);
						}    		
						else if (caseRec.Status == 'M1 Proof Denied' && caseRec.Milestone_Proof_Type__c == 'M1 Proof')
						{
							assetRec.M1_Status__c = 'Denied';
							assetRec.M1_Proof_Upload_Date__c = null;
							assetRec.M1_proof_panel_inverter_delivery__c = null;
							assetRec.M1_Denied_Comments__c = caseRec.Denied_Comment__c;
			
							caseRec.Milestone_Proof_Approval_Date__c = null;
							casesToUpdate.add(caseRec);
						}    		
						else if ((caseRec.Status == 'M2 Proof Denied (non meter test)' || caseRec.Status == 'M2 Meter Test Denied')&& caseRec.Milestone_Proof_Type__c == 'M2 Proof')
						{
							assetRec.M2_Status__c = 'Denied';
							assetRec.M2_Proof_Upload_Date__c = null;
							assetRec.M2_proof_substantial_completion__c = null;
							assetRec.M2_Denied_Comments__c = caseRec.Denied_Comment__c;
			
							caseRec.Milestone_Proof_Approval_Date__c = null;
							casesToUpdate.add(caseRec);
						}    		
						else if (caseRec.Status == 'M3 PTO Denied' && caseRec.Milestone_Proof_Type__c == 'M3 Proof')
						{
							assetRec.M3_Status__c = 'Denied';
							assetRec.M3_Proof_Upload_Date__c = null;
							assetRec.M3_Denied_Comments__c = caseRec.Denied_Comment__c;
			
							caseRec.Milestone_Proof_Approval_Date__c = null;
							casesToUpdate.add(caseRec);
						}    
						assetsToUpdate.add(assetRec);		
			    	}                
							
					if (assetsToUpdate.size() > 0)
					{
						update assetsToUpdate;
					}
					if (casesToUpdate.size() > 0)
					{
						update casesToUpdate;
					}
				}
			}
		}
		else if (System.Trigger.isDelete)
		{
			ServiceContractUtil.updateMilestoneProofInformation(scM1AssetIds, scM2AssetIds, scM3AssetIds );
			if (m1AssetIds != null && m1AssetIds.size() > 0)
			{
				for(Generation_Assets__c assetRec :[Select Id,M1_Proof_Upload_Date__c, M1_Status__c, M1_Denied_Comments__c, M1_proof_panel_inverter_delivery__c  from Generation_Assets__c where Id in :m1AssetIds])
		    	{
					assetRec.M1_Proof_Upload_Date__c = null;	   
					assetRec.M1_Status__c = null;
					assetRec.M1_Denied_Comments__c = null;
					assetRec.M1_proof_panel_inverter_delivery__c = null;
					
					assetsToUpdate.add(assetRec);
		    	}
			}
			else if (m2AssetIds != null && m2AssetIds.size() > 0)
			{
				for(Generation_Assets__c assetRec :[Select Id,M2_Proof_Upload_Date__c, M2_Status__c, M2_Denied_Comments__c, M2_proof_substantial_completion__c  from Generation_Assets__c where Id in :m2AssetIds])
		    	{
					assetRec.M2_Proof_Upload_Date__c = null;	   
					assetRec.M2_Status__c = null;
					assetRec.M2_Denied_Comments__c = null;
					assetRec.M2_proof_substantial_completion__c = null;
					
					assetsToUpdate.add(assetRec);
		    	}
			}
			else if (m3AssetIds != null && m3AssetIds.size() > 0)
			{
				for(Generation_Assets__c assetRec :[Select Id,M3_Proof_Upload_Date__c, M3_Status__c, M3_Denied_Comments__c from Generation_Assets__c where Id in :m3AssetIds])
		    	{
					assetRec.M3_Proof_Upload_Date__c = null;	   
					assetRec.M3_Status__c = null;
					assetRec.M3_Denied_Comments__c = null;
					
					assetsToUpdate.add(assetRec);
		    	}
			}
			if (assetsToUpdate.size() > 0)
			{
				update assetsToUpdate;
			}
			
		}
	}

}