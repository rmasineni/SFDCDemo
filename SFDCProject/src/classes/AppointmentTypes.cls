public class AppointmentTypes {
	public String baseURL {get;set;}
	public String apptType {get;set;}
	public String redirectUrl {get;set;}
	public String schedulerUrl{get;set;}
	public String currentPageURL{get;set;}
	public Id objectId {get;set;}
	public boolean showScheduling{get;set;}
	public String fsDispatchPrefix{get;set;}
	Boolean isFSDispath {get;set;}
	public AppointmentTypes(ApexPages.StandardController controller) {
        try{
            currentPageURL = System.URL.getCurrentRequestUrl().getPath();
			fsDispatchPrefix = Schema.SObjectType.FS_Dispatch__c.getKeyPrefix(); 
            baseURL = EDPUtil.getBaseURL(); 
            objectId = controller.getId();    
            schedulerUrl =  '/apex/CallcenterOptyScheduler?scontrolCaching=1&id=' + objectId + '&category=';
            showScheduling = false;  
            isFSDispath = false; 	
			String objectType = getObjectType();
			if(isFSDispath == true){
				FS_Dispatch__c tempFSD = [Select Id, FS_Service_Contract__c from FS_Dispatch__c where Id =:objectId];
				if(tempFSD.FS_Service_Contract__c != null){
					showScheduling = true;
				}
			}

		}catch(Exception exceptionObj){
            ApexPages.addMessages(exceptionObj);               
        }   
	}
	
	public String getObjectType(){
		String result = '';
		String tempId = '' + objectId;
		if(tempId.startsWith(fsDispatchPrefix)){
			result = 'FS_Dispatch__c';
			isFSDispath = true;
		}
		return result;
	}
	public List<SelectOption> getApptTypes(){
		List<SelectOption> options = new List<SelectOption>();
		if(isFSDispath == true){
			options.add(new SelectOption('Service', 'Service'));
			schedulerUrl =  '/apex/CallcenterFSDispatchScheduler?scontrolCaching=1&id=' + objectId + '&category=';   	  
		}else{
			options.add(new SelectOption('--None--','--None--'));
			options.add(new SelectOption('Sales','Sales'));
			options.add(new SelectOption('Site Audit', 'Site Audit'));			
		}
		return options;
	}
	
	public pagereference showScheduler(){
        Pagereference page;
		redirectUrl = '';
        Boolean PartnerPP=baseURL.containsIgnoreCase('partner');
		if(!String.isEmpty(apptType) && apptType != '--None--'){
			redirectUrl = schedulerUrl + apptType;
		}
		System.debug('redirectUrl: ' + redirectUrl);
		
		if(!String.isEmpty(redirectUrl)){
	        page=new Pagereference(redirectUrl);
	        page.setRedirect(true);
			return page;
        }       
        return null;
	}
}