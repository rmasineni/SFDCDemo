public with sharing class OverrideNewCustomerContact {
static final private String contactPrefix = Schema.SObjectType.Contact.getKeyPrefix(); 
public string retURL {get;set;}
	ApexPages.StandardController controller;
	Id recordTypeId;
	String entStr;
public OverrideNewCustomerContact(ApexPages.StandardController c)
    {
		controller = c;
		retURL = System.currentPagereference().getParameters().get('retURL');
		recordTypeId = System.currentPagereference().getParameters().get('RecordType');
		entStr = System.currentPagereference().getParameters().get('ent');
    }
public PageReference redirectNewCustomerContact(){
	
		Id userId = UserInfo.getUserId();
		User loginUser = PRMContactUtil.getUser(userId);
		String url = '';
		if(retURL == null){
			retURL = '';
		}
     	if(loginUser.contactId == null){
	    	url = '/'+ contactPrefix +'/e?retURL=' + retURL  + '&nooverride=1';
	    	if(recordTypeId != null){
	    		url +=  '&RecordType='  + recordTypeId;
	    	}
				
			if(entStr != null && entStr != ''){
	    		url +=  '&ent='  + entStr;
	    	}
    	}else{
			url = '/partner/apex/NewCustomerContactOverridden?retURL=' + retURL;
	    	if(recordTypeId != null){
	    		url +=  '&RecordType='  + recordTypeId;
	    	}
				
			if(entStr != null && entStr != ''){
	    		url +=  '&ent='  + entStr;
	    	}			
    	}
		System.debug('url: ' + url);
		PageReference pageRef = new PageReference(url);
		return pageRef;
	
}
}