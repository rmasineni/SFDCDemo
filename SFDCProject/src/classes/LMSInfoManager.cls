public class LMSInfoManager {
    
	public Static Set<Id> contactTriggerActiveIds = new Set<Id>();
	public Static Set<Id> contactTriggerInActiveIds = new Set<Id>();
	public Static Set<Id> accountTriggerActiveIds = new Set<Id>();
	public static Set<Id> processedContactIds = new Set<Id>();
    public static void sendContsToNetExam(){
        
    }

    public static boolean hasCertificationProfileModified(Contact newContactObj, Contact oldContactObj){
        
        System.debug('newContactObj.Ultimate_Parent_Account__c: ' + newContactObj.Ultimate_Parent_Account__c);
        System.debug('oldContactObj.Ultimate_Parent_Account__c: ' + oldContactObj.Ultimate_Parent_Account__c);
        if(newContactObj.Ultimate_Parent_Account__c != oldContactObj.Ultimate_Parent_Account__c){
            return true;
        }else if(newContactObj.FirstName != oldContactObj.FirstName){
            return true;
        }else if(newContactObj.lastName != oldContactObj.lastName){
            return true;
        }else if(newContactObj.email != oldContactObj.email){
            return true;
        }else if(newContactObj.Job_Function__c != oldContactObj.Job_Function__c){
            return true;
        }else if(newContactObj.sells_sunrun__c != oldContactObj.sells_sunrun__c){
            return true;
        }else if(newContactObj.active__c != oldContactObj.active__c){
            return true;
        }
        return false;
    }

    public static void processAllPartnerContacts(Set<Id> accountIds, Set<Id> accountIdsForContactActivation){
        Set<Id> lmsInfoContactIds = new Set<Id>();
        Set<Id> activateContactIds = new Set<Id>();
        Set<Id> deActivateContactIds = new Set<Id>();
        for(Contact contactObj : [Select Id,Ultimate_Parent_Account__c, firstname, Account.name,
                                    lastname, email, job_function__c, active__c, sells_sunrun__c,
                                    Contact_Number__c
                                    from Contact where Ultimate_Parent_Account__c != null
                                    AND active__c = true 
                                    AND Ultimate_Parent_Account__c in :accountIds]){
			lmsInfoContactIds.add(contactObj.Id);
            if(contactObj.sells_sunrun__c == 'Yes' 
            	&& accountIdsForContactActivation.contains(contactObj.Ultimate_Parent_Account__c)){
            	activateContactIds.add(contactObj.Id);
            }   
			
			System.debug('lmsInfoContactIds.size(): ' + lmsInfoContactIds.size());
			
			//To avoid governor limits we are sending 5 contacts at time to NetExam 
			if(lmsInfoContactIds.size() == 5){
 				NetExamWebServiceAPIHelper7.SendContactFromTrigger(lmsInfoContactIds,activateContactIds,deActivateContactIds);	
            	lmsInfoContactIds = new Set<Id>();
            	activateContactIds = new Set<Id>();
            	deActivateContactIds = new Set<Id>();          				
			}
			
        }

		if(lmsInfoContactIds.size() > 0){
 				NetExamWebServiceAPIHelper7.SendContactFromTrigger(lmsInfoContactIds,activateContactIds,deActivateContactIds);	
            	lmsInfoContactIds = new Set<Id>();
            	activateContactIds = new Set<Id>();
            	deActivateContactIds = new Set<Id>();          				
		}		
		
		/*
        if(lmsInfoContactIds.size() > 0){
            NetExamWebServiceAPIHelper7.processContactForLMS(lmsInfoContactIds, 
            													activateContactIds,
            													deActivateContactIds);
        }
        */
    }
}