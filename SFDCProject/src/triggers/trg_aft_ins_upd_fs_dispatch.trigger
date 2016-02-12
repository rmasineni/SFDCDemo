trigger trg_aft_ins_upd_fs_dispatch on FS_Dispatch__c (after insert,after update) {

	Set<Id> installerIds = new Set<Id>();
	Map<Id, Set<Id>> scInstallerMap = new Map<Id, Set<Id>>();

	Boolean skipValidations = false;
	skipValidations = SkipTriggerValidation.performTriggerValidations();
	if(skipValidations == false){
	    Set<String> fsDispIds = new Set<String>();
	    for (Integer i = 0; i < Trigger.new.size(); i++)  
	    {
	        if (System.Trigger.IsInsert || trigger.new[i].FS_Dispatch_To__c != trigger.old[i].FS_Dispatch_To__c)
	        {
	            fsDispIds.add(trigger.new[i].Id);
	         }   
	    }
	    if (fsDispIds.size() > 0)
	    {
	        List<FS_Dispatch__c> updFsDispList = new List<FS_Dispatch__c>();
	        for (FS_Dispatch__c fsDispRec : [Select Id, FS_Service_Contract__c, FS_Dispatch_Partner__c, FS_Dispatch_To__r.AccountId, FS_Dispatch_To__r.Ultimate_Parent_Account__c from FS_Dispatch__c where Id in :fsDispIds] )
	        {
				Id accountId = (fsDispRec.FS_Dispatch_To__r.Ultimate_Parent_Account__c != null) ? fsDispRec.FS_Dispatch_To__r.Ultimate_Parent_Account__c : fsDispRec.FS_Dispatch_To__r.AccountId;
				if(fsDispRec.FS_Service_Contract__c != null && accountId != null
					&& (fsDispRec.FS_Dispatch_Partner__c != fsDispRec.FS_Dispatch_To__r.AccountId)){
					
					Set<Id> tempInstallerIds = scInstallerMap.containsKey(fsDispRec.FS_Service_Contract__c) ?  scInstallerMap.get(fsDispRec.FS_Service_Contract__c) : new Set<Id>();
					tempInstallerIds.add(accountId);
					scInstallerMap.put(fsDispRec.FS_Service_Contract__c, tempInstallerIds);
					installerIds.add(accountId);
				}   
	             
	             fsDispRec.FS_Dispatch_Partner__c = fsDispRec.FS_Dispatch_To__r.AccountId;
	             updFsDispList.add(fsDispRec);  
			}   
	        update updFsDispList;

			System.debug('installerIds: ' + installerIds);
			ServiceContractUtil.createServiceContractSharing(scInstallerMap, installerIds);	        
	        
	    }
	}    
}