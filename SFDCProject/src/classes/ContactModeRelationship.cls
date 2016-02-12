public class ContactModeRelationship {

	Map<Id, String> partnerModesList;
	Map<String, Id> partnerModesStringToId;
    public Map<Id, string> leftvalues{
    	get;set;
    }
    public Map<Id, string> rightvalues{
    	get;set;
    }
	Set<Id> contactmodes;

	public Id ultimateParentAccountId{
		get;set;
	}

	public Id accountId{
		get;set;
	}
 
	public Id contactId{
		get;set;
	}  
    
    Public List<Id> leftselected{get;set;}
    Public List<Id> rightselected{get;set;}

	public Map<Id, Partner_Modes__c> partnerModes{
		get;set;
	}
    
    public void initialize(){
    	partnerModes = new Map<Id, Partner_Modes__c>();
    	partnerModesList = new Map<Id, String>();
    	partnerModesStringToId = new Map<String, Id>();
    	leftvalues = new Map<Id, string>();
    	rightvalues = new Map<Id, string>();
		
		leftselected = new List<Id>();
		rightselected = new List<Id>();
		contactmodes = new Set<Id>();
		initializePartnerModes();
		initializeContactModes();
    }
	
	public ContactModeRelationship(){
		initialize();
	}

	public void initializeMultiSelectLists(){
		initialize();
		System.debug('partnerModesList: ' + partnerModesList);
		for(Id idVal : partnerModesList.keySet()){
			String value = partnerModesList.get(idVal);
			if(contactmodes != null && contactmodes.contains(idVal)){
				rightvalues.put(idVal, value);
			}else{
				leftvalues.put(idVal, value);
			}
		}
		System.debug('rightvalues: ' + rightvalues);	
	}	
	
	public void initializeContactModes(){	
		if(contactId == null){
			return;
		}
		
		for(Contact_Mode_Rel__c contactModeRelObj : [Select Id, contact__c, Partner_Modes__c,
														Isactive__c
														from Contact_Mode_Rel__c 
														where contact__c = :contactId
														and Isactive__c = true
														order by mode_name__c asc]){	
			contactmodes.add(contactModeRelObj.Partner_Modes__c);
		}

	}
	public void initializePartnerModes(){
		if(accountId == null || ultimateParentAccountId == null)
			return;
			
		for(Partner_Modes__c partnerModesObj : [Select Id,mode_Id__c, mode_name__c from Partner_Modes__c 
												where account__c = :ultimateParentAccountId 
												and master__c = false 
												and mode_name__c != null
												and mode_Id__c != null
												and deleted__c = false
												order by mode_name__c asc]){
			partnerModes.put(partnerModesObj.Id, partnerModesObj);
			partnerModesList.put(partnerModesObj.Id, partnerModesObj.Mode_Name__c);
			partnerModesStringToId.put(partnerModesObj.Mode_Name__c, partnerModesObj.Id);
		}
	}
	
	public static List<String> updateContactModeRelationships(Map<Id, Set<Id>> contactModeRelationmap){
		
		System.debug('Step-1');
		List<String> errors = new List<String>();
		Map<Id, Map<Id, Contact_Mode_Rel__c>> existingContactModeRels = new Map<Id, Map<Id, Contact_Mode_Rel__c>>();
		Map<Id, Contact_Mode_Rel__c> tempModes;
		List<Contact_Mode_Rel__c> updateContactRelModes = new List<Contact_Mode_Rel__c>();
		List<Contact_Mode_Rel__c> upsertContactRelModes = new List<Contact_Mode_Rel__c>();
		
		for(Contact_Mode_Rel__c contactModeRelObj : [Select Id, contact__c, Partner_Modes__c,
														Isactive__c, mode_name__c
														from Contact_Mode_Rel__c 
														where contact__c in :contactModeRelationmap.keySet()
														order by mode_name__c asc]){
			tempModes = existingContactModeRels.containsKey(contactModeRelObj.contact__c) ? 
						existingContactModeRels.get(contactModeRelObj.contact__c) :  
						new Map<Id, Contact_Mode_Rel__c>();
			contactModeRelObj.Isactive__c = false;
			tempModes.put(contactModeRelObj.Partner_Modes__c, contactModeRelObj);
			existingContactModeRels.put(contactModeRelObj.contact__c, tempModes);	 
		}
		System.debug('existingContactModeRels: ' + existingContactModeRels);
		System.debug('Step-2: ' + contactModeRelationmap);
		
		Set<Id> requiredmodes; 
		for(Id contactId : contactModeRelationmap.keySet()){
			
			requiredmodes = contactModeRelationmap.get(contactId);
			tempModes = existingContactModeRels.get(contactId);
			System.debug('Step-21: ' + requiredmodes);
			for(Id modeId: requiredmodes){
				Contact_Mode_Rel__c contactRelMode = null;
				if(tempModes != null){
					contactRelMode = tempModes.get(modeId);
					if(contactRelMode != null){
						contactRelMode.Isactive__c = true;
					}
				}	
				if(contactRelMode == null){
					contactRelMode = new Contact_Mode_Rel__c();
					contactRelMode.Contact__c = contactId;
					contactRelMode.Partner_Modes__c = modeId;
					contactRelMode.Isactive__c = true;
					upsertContactRelModes.add(contactRelMode);
				}

			}
			if(tempModes != null && tempModes.size() > 0){
				upsertContactRelModes.addall(tempModes.values());	
			}	
		}
		System.debug('Step-4' + upsertContactRelModes);
		Set<Id> contactmodeIds = new Set<Id>();
		if(upsertContactRelModes != null && upsertContactRelModes.size() > 0){
			Database.UpsertResult[] upserResults = Database.upsert(upsertContactRelModes, false);	
			Integer counter = 0;
			for (Database.UpsertResult result: upserResults) {
				Contact_Mode_Rel__c tempContractModeObj = upsertContactRelModes[counter];
				if(result.isSuccess()){
					contactmodeIds.add(tempContractModeObj.Id);
				}else if(!result.isSuccess()){
					String errorMessage = 'Unable to assign the Partner Mode: ' + 
											tempContractModeObj.Partner_Modes__c;
					errors.add(errorMessage);
				}	
				counter++;	
			}
		}
		
		return errors;
	}

    public PageReference selectclick(){
        rightselected.clear();
        System.debug('leftselected: ' + leftselected);
        for(Id selectedId : leftselected){
            String value = leftvalues.remove(selectedId);
			rightvalues.put(selectedId, value);
        }
        System.debug('rightvalues: ' + rightvalues);
        return null;
    }
    
    public PageReference unselectclick(){
        leftselected.clear();
        System.debug('rightselected: ' + rightselected);
        for(Id selectedId : rightselected){
			String value =  rightvalues.remove(selectedId);
			leftvalues.put(selectedId, value);
        } 
        System.debug('leftvalues: ' + leftvalues);
        return null;
    }

    public List<SelectOption> getunSelectedValues(){
        List<SelectOption> options = new List<SelectOption>();
		List<String> sortedList = leftvalues.values();
		sortedList.sort();
        for(String valueStr : sortedList){
            Id idVal  = partnerModesStringToId.get(valueStr);
            System.debug('Selected valueStr: ' + valueStr);
			options.add(new SelectOption(idVal,valueStr));
        }
        //options.sort();
        return options;
    }

	public List<SelectOption> getSelectedValues(){
	    List<SelectOption> options = new List<SelectOption>();
	    List<String> sortedList = rightvalues.values();
        sortedList.sort();
        for(String valueStr : sortedList){
            Id idVal = partnerModesStringToId.get(valueStr);
            System.debug('Selected valueStr: ' + valueStr);
            System.debug('Selected idVal: ' + idVal);
            if(idVal != null){
            	options.add(new SelectOption(idVal,valueStr));
            }
        }
        //options.sort();
	    return options;
	}

}