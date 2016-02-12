public class LeadRedirectToEdit {
	
	public string leadId ;
    private Boolean systemAdmin = false;
    private lead leadObj;     

	public Boolean isPartnerUser {get;set;} 
	public leadRedirectToEdit(){
		initialize();
	}

    public leadRedirectToEdit(ApexPages.StandardController controller) {
		leadObj = (lead) controller.getRecord();
        if (leadId == null) {
            leadId = leadObj.Id;
        }
        initialize();
    }
    
    private void initialize(){
		User userObj = PRMContactUtil.getLoginUser();
		isPartnerUser = false;
		if(userObj != null && userObj.contactId != null){
			isPartnerUser = true;
		}	    	
    }

    private String editURL {
        get {
            return '/' + leadId + '/e?nooverride=1' +  '&retURL=%2F' + leadId ;
        }
        set;
    }  

    private String customEditURL {
        get {
            return '/partner/apex/PartnerLeadCreate?leadId=' + leadId + '&retURL=%2F' + leadId + '&gmaps=1' ;
        }
        set;
    } 

    public PageReference getleadEditPage() {
        PageReference ref = null;
        System.debug('isPartnerUser: ' + isPartnerUser);
        System.debug('customEditURL: ' + customEditURL);
        if(isPartnerUser == true ){
            ref = new PageReference(customEditURL);
            ref.setRedirect(true);      
        }else{
            ref = new PageReference(editURL);
            ref.setRedirect(true);          
        }
        return ref;
    }
}