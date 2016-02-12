trigger trg_task_aftr_ins_upd on Task (after insert, after update) {
List<Case> cases = new List<Case>();    
    
    String[] caseIds = new String[Trigger.new.size()];
    String[] taskTypes = new String[Trigger.new.size()];
    Set <Id> parentCaseIds = new Set <Id>();
    Set <Id> lastUpdateOnCaseIds = new Set <Id>();
    Set <Id> genAssetIds = new Set <Id>();
    
    for(Integer i = 0;i<Trigger.new.size();i++)
    {      
        if (System.Trigger.isInsert)
        {
            caseIds[i] = Trigger.new[i].WhatId;           
            taskTypes[i] = Trigger.new[i].Activity_Channel__c; 
          
            if (Trigger.new[i].Activity_Channel__c == 'Call Outbound' || Trigger.new[i].Activity_Channel__c == 'Email Outbound' || Trigger.new[i].Activity_Channel__c == 'Left Voicemail')
            {
            	parentCaseIds.add(Trigger.new[i].WhatId);
            }            

			//Added the following changes for Story# BSKY-628
	        if(Trigger.new[i].WhatId != null && 
	        	Trigger.new[i].subject != null && 
	        	Trigger.new[i].subject == Label.Welcome_Subject){
				genAssetIds.add(Trigger.new[i].WhatId);
	        } 

        }  
   
    }
    
    //Added the following changes for Story# BSKY-628    
    List<Generation_Assets__c> updatedGenAssets = new List<Generation_Assets__c>();
    if(genAssetIds != null && genAssetIds.size() > 0){
    	for(Generation_Assets__c ga: [Select Id, Welcome_Docs_Sent__c from Generation_Assets__c 
    									where Id in :genAssetIds]){
    		ga.Welcome_Docs_Sent__c = date.today();
    		updatedGenAssets.add(ga);
    	}
    	
    	if(updatedGenAssets != null && updatedGenAssets.size() > 0 ){
    		update updatedGenAssets;
    	}
    }
    
    if (parentCaseIds.size() > 0)
    {
	try
	{
    for(Case caseRec:[Select Id,First_Response_Date_Time__c,First_Response_Updated__c,Last_Response_Date_Time__c from Case where Id in:parentCaseIds])
    {                
        
        //Integer index = indexOf(caseIds,caseRec.Id);
        
        if(caseRec.First_Response_Updated__c == true)
        {
        caseRec.Last_Response_Date_Time__c = DateTime.now();
        }
        else if(caseRec.First_Response_Updated__c == false)
        {
        caseRec.First_Response_Date_Time__c = DateTime.now();
        caseRec.First_Response_Updated__c = true;
        caseRec.Last_Response_Date_Time__c = DateTime.now();
        }
        cases.add(caseRec);      
    }
    
    update cases;    
    }
    catch(exception ex)
    {
        System.debug('Exception occured '+ ex.getMessage());    
    }
}
}