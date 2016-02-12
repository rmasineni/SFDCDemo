public with sharing class OverridePartnerCaseTab {

	static final private String casePrefix = Schema.SObjectType.Case.getKeyPrefix(); 
	public string retURL {get;set;}
	ApexPages.StandardsetController controller;
	Id recordTypeId;
	String entStr;
	public OverridePartnerCaseTab(ApexPages.StandardsetController stdCon)
    {
		controller = stdCon;
		retURL = System.currentPagereference().getParameters().get('retURL');
		recordTypeId = System.currentPagereference().getParameters().get('RecordType');
		entStr = System.currentPagereference().getParameters().get('ent');
    }
    
    public PageReference redirectCaseTab(){
    	
		Id userId = UserInfo.getUserId();
		User loginUser = PRMContactUtil.getUser(userId);
		String url = '';
		if(retURL == null){
			retURL = '';
		}

     	if(loginUser.contactId == null){
	    	url = '/'+ casePrefix +'/o?retURL=' + retURL  + '&nooverride=1';
	    	system.debug('URL***********:' + url);
	    	if(recordTypeId != null){
	    		url +=  '&RecordType='  + recordTypeId;
	    		system.debug('URL with Record Type***********:' + url);
	    	}
				
			if(entStr != null && entStr != ''){
	    		url +=  '&ent='  + entStr;
	    	}
    	}else{
			url = '/partner/apex/CaseSearch?retURL=' + retURL;
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