public with sharing class OverridePartnerLeadTab {
	static final private String leadPrefix = Schema.SObjectType.Lead.getKeyPrefix(); 
	public string retURL {get;set;}
	ApexPages.StandardsetController controller;
	Id recordTypeId;
	String entStr;
	public OverridePartnerLeadTab(ApexPages.StandardsetController c)
    {
		controller = c;
		retURL = System.currentPagereference().getParameters().get('retURL');
		recordTypeId = System.currentPagereference().getParameters().get('RecordType');
		entStr = System.currentPagereference().getParameters().get('ent');
    }
    
    public PageReference redirectLeadTab(){
    	
		Id userId = UserInfo.getUserId();
		Contact contactObj = PRMContactUtil.getLoginUserAccountAndContact();
		User loginUser = PRMContactUtil.getUser(userId);
		String url = '';
		if(retURL == null){
			retURL = '';
		}
		
		if(test.isrunningtest())
        	retURL = '/apex/OverridePartnerLeadTab';
        	
		system.debug('LEADPREFIX***********:' + leadPrefix);
     	if(loginUser.contactId == null){
	    	url = '/'+ leadPrefix +'/o?retURL=' + retURL  + '&nooverride=1';
	    	system.debug('URL***********:' + url);
	    	if(recordTypeId != null){
	    		url +=  '&RecordType='  + recordTypeId;
	    		system.debug('URL with Record Type***********:' + url);
	    	}
				
			if(entStr != null && entStr != ''){
	    		url +=  '&ent='  + entStr;
	    	}
    	}else{
    		Boolean isPartnerPortalURL = EDPUtil.isPartnerPortalURL();
    		url = (isPartnerPortalURL) ? '/partner/apex/LeadSearch?retURL=' : '/apex/LeadSearch?retURL=' ;
			url += retURL;
			//url = '/partner/apex/LeadSearch?retURL=' + retURL;
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