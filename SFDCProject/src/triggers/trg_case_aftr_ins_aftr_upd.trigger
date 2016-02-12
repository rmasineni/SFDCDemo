trigger trg_case_aftr_ins_aftr_upd on Case(after insert, after update) {

	Boolean skipValidations = false;
	skipValidations = SkipTriggerValidation.performTriggerValidations();
	if(skipValidations == false){
	    //List < Case > updateCases = new List < Case > ();
	    List < Case > updateCases2 = new List < Case > ();
	    List < Case > insertCases = new List < Case > (); 
	    String[] caseIds = new String[Trigger.new.size()];
	    Map<Id, Date> mapGAIdtoPTODate = new Map<Id, Date>();
	    Map<Id, Date> mapSCIdtoPTODate = new Map<Id, Date>();
	    
	    String newStatus;
	    String oldStatus;
	    String ownerId; //= new String[Trigger.new.size()];
	    String oldOwnerId;
	    String caseId;
	    Integer j = 0;
	    DateTime now = DateTime.now();
	    Boolean isCaseTriggerFlag;
	
		String[] caseIdsForContact = new String[Trigger.new.size()];
		String[] caseIdsForCopies = new String[Trigger.new.size()];
		Integer intCount = 0;
		Integer intJCount = 0;
	    Map<String, Id> scMap = new  Map<String, Id>();
	    Map<String, String> taskNameMap = new  Map<String, String>();
		Map<String, 	Submit_M3_Proof_Tasks__c> m3ProofTasks = Submit_M3_Proof_Tasks__c.getAll();
			
	    for (Integer i = 0; i < Trigger.new.size(); i++) {
	    	
	    	if(Trigger.isInsert){
	    		if (Trigger.new[i].Service_Contract__c != null && Trigger.new[i].Milestone_Proof_Type__c == 'M1 Proof')
	            {
					scMap.put(Trigger.new[i].Service_Contract__c+Label.WFM_Submit_M1_Proof, Trigger.new[i].Service_Contract__c);
					taskNameMap.put(Trigger.new[i].Service_Contract__c+Label.WFM_Submit_M1_Proof, Label.WFM_Submit_M1_Proof);
				}
	            else if (Trigger.new[i].Service_Contract__c != null && Trigger.new[i].Milestone_Proof_Type__c == 'M2 Proof')
	            {
					scMap.put(Trigger.new[i].Service_Contract__c+Label.WFM_Submit_M2_Proof, Trigger.new[i].Service_Contract__c);
					taskNameMap.put(Trigger.new[i].Service_Contract__c+Label.WFM_Submit_M2_Proof, Label.WFM_Submit_M2_Proof);
	            }else if (Trigger.new[i].Service_Contract__c != null && Trigger.new[i].Milestone_Proof_Type__c == 'M3 Proof')
	            {
					if(!m3ProofTasks.isEmpty()){
						for(String taskName : m3ProofTasks.keySet()){
							scMap.put(Trigger.new[i].Service_Contract__c + taskName, Trigger.new[i].Service_Contract__c);
							taskNameMap.put(Trigger.new[i].Service_Contract__c + taskName,taskName);							
						}
					}
					//scMap.put(Trigger.new[i].Service_Contract__c+Label.WFM_Submit_M3_Proof, Trigger.new[i].Service_Contract__c);
					//taskNameMap.put(Trigger.new[i].Service_Contract__c+Label.WFM_Submit_M3_Proof, Label.WFM_Submit_M3_Proof);
	            }
	    	}
	    	
	    	if(Trigger.isUpdate   	
	    	   && (Trigger.oldMap.get(Trigger.new[i].Id).IsClosed == null || !Trigger.oldMap.get(Trigger.new[i].Id).IsClosed)
	    	   && Trigger.new[i].IsClosed
	    	   && Trigger.new[i].Milestone_Proof_Type__c == 'M3 Proof'
	    	   && Trigger.new[i].Case_M3_PTO__c <> null) 
	    	{
	    		if(Trigger.new[i].Generation_Asset__c != null){
	    			mapGAIdtoPTODate.put(Trigger.new[i].Generation_Asset__c, Trigger.new[i].Case_M3_PTO__c);
	    		}
				if(Trigger.new[i].Service_Contract__c != null){
	    			mapSCIdtoPTODate.put(Trigger.new[i].Service_Contract__c, Trigger.new[i].Case_M3_PTO__c);
	    		}
	    	}
	    	
	        ownerId = Trigger.new[i].OwnerId;
	
	        caseId = Trigger.new[i].Id;
	
	        newStatus = Trigger.new[i].Status;

	        if (System.Trigger.isUpdate) {
	                
	        } else {
	            
		    	if (Trigger.new[i].ContactId == null)
		    	{
		    		caseIdsForContact[intCount] = Trigger.new[i].Id;
		    	}
		    	if(Trigger.new[i].First_Response_Date_Time__c != null || Trigger.new[i].Last_Response_Date_Time__c != null)
		    	{
		    	caseIdsForCopies[intJCount] = Trigger.new[i].Id;
		    	intJCount++;
		    	}
		    	else
		    	{
		    	caseIds[j] = (Trigger.new[i].Id);
		    	 j++;
		    	}
	        }

	    }
	
	    if (caseIdsForCopies != null && caseIdsForCopies.size() > 0 && caseIdsForCopies[0] != null)
	    {
		  for (Case insertCase: [SELECT Id,First_Response_Date_Time__c,Last_Response_Date_Time__c,First_Response_Updated__c FROM Case WHERE Id IN: caseIdsForCopies])
	      {     	
	     	insertCase.First_Response_Date_Time__c = null;
	     	insertCase.Last_Response_Date_Time__c = null;
	     	insertCase.First_Response_Updated__c = false;   	
	        insertCases.add(insertCase);
	      }
	    }
		if (caseIdsForContact != null && caseIdsForContact.size() > 0 && caseIdsForContact[0] != null)
		{
		    for (Case updatedCase: [SELECT Id, ContactId, RecordType.Name, Generation_Asset__r.Customer_Contact__c FROM Case WHERE Id IN: caseIdsForContact])
		    {     	
		     	if (updatedCase.Generation_Asset__r.Customer_Contact__c != null)
		     	{
		     		if(updatedCase.RecordType.Name != 'Milestone Proof' || Trigger.isUpdate)
		     		{
			     	   updatedCase.ContactId = updatedCase.Generation_Asset__r.Customer_Contact__c;     	
			           updateCases2.add(updatedCase);
		     		}
		     	}
		    }
		}
		
	   
	    if (updateCases2.size() > 0) {
	        update updateCases2;
	    }
	    if (insertCases.size() > 0) {
	        update insertCases;
	    }
	    
	    if(!mapGAIdtoPTODate.isEmpty())
	    {
	    	list<Generation_Assets__c> listGA = new List<Generation_Assets__c>();
	    	for(Generation_Assets__c ga:[select id, PTO__c from Generation_Assets__c 
	    	                              where id in :mapGAIdtoPTODate.keySet()])
	    	{
	    		if(mapGAIdtoPTODate.get(ga.Id) != null)
	    		{
	    		   ga.PTO__c = mapGAIdtoPTODate.get(ga.Id);
	    		   listGA.add(ga);
	    		}
	    	}
	        if(!listGA.isEmpty())
	        {
	    	   update listGA;
	        }    	
	    }
		
		if(!mapSCIdtoPTODate.isEmpty())
	    {
	    	list<Service_Contract_Event__c> listSC = new List<Service_Contract_Event__c>();
	    	for(Service_Contract_Event__c scEvent:[select id, PTO__c, Service_Contract__c from Service_Contract_Event__c 
	    	                              where Service_Contract__c in :mapSCIdtoPTODate.keySet()])
	    	{
	    		if(mapSCIdtoPTODate.get(scEvent.Service_Contract__c) != null)
	    		{
	    		   scEvent.PTO__c = mapSCIdtoPTODate.get(scEvent.Service_Contract__c);
	    		   listSC.add(scEvent);
	    		}
	    	}
	        if(!listSC.isEmpty())
	        {
	    	   update listSC;
	        }    	
	    }
	    
	    if(scMap != null && !scMap.isEmpty()){
			wfUtil.completeSCTasks(scMap,taskNameMap);
	    }

	}        
    public Integer getOwnerType(String ownrId) {
        Group[] gp = [Select Id From Group where Id = : ownrId];
        if (gp.size() > 0) return 1;

        return 0;
    }
}