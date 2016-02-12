public with sharing class OverrideProposalEditButton {

static final private String Proposal = Schema.SObjectType.Proposal__c.getKeyPrefix(); 
public string retURL {get;set;}
	ApexPages.StandardController controller;
	Id recordTypeId;
	String entStr;
public OverrideProposalEditButton(ApexPages.StandardController c)
    {
		controller = c;
		retURL = System.currentPagereference().getParameters().get('retURL');
		recordTypeId = System.currentPagereference().getParameters().get('RecordType');
		entStr = System.currentPagereference().getParameters().get('ent');
    }
public PageReference redirectEditPage(){
	
		Id userId = UserInfo.getUserId();
		User loginUser = PRMContactUtil.getUser(userId);
		String url = '';
		if(retURL == null){
			retURL = '';
		}
     	if(loginUser.contactId == null){
	    	url = '/'+ Proposal +'/e?retURL=' + retURL  + '&nooverride=1';
	    	if(recordTypeId != null){
	    		url +=  '&RecordType='  + recordTypeId;
	    	}
				
			if(entStr != null && entStr != ''){
	    		url +=  '&ent='  + entStr;
	    	}
    	}else{
			url = '/partner/apex/EditPartnerProposals?retURL=' + retURL;
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