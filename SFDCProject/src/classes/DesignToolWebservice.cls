/************************************************************************************************************
Name    : DesignToolWebservice
Author  : Raghu
Date    : May, 2013
Description: 
************************************************************************************************************/
global class DesignToolWebservice {

    //webService static DesignToolWebserviceResponse getDesignToolURL(String leadId){
	webService static DesignToolWebserviceResponse getDesignToolURL(String objectId, String prospectId, String sObjType){
		DesignToolWebserviceResponse responseObj = new DesignToolWebserviceResponse();
		responseObj.status = 'Success';
		
		//Actual URL
		responseObj = DesignTool.getDesignToolURL(objectId, prospectId, sObjType);
		System.debug('responseObj: ' +responseObj);
		return 	responseObj;
	}
    webService static DesignToolWebserviceResponse getDesignToolURLWithFunction(String objectId, String prospectId, String sObjType,String function){
		DesignToolWebserviceResponse responseObj = new DesignToolWebserviceResponse();
		responseObj.status = 'Success';
		
		//Actual URL
		DesignTool.function=function;
		responseObj = DesignTool.getDesignToolURL(objectId, prospectId, sObjType);
		System.debug('responseObj: ' +responseObj);
		return 	responseObj;
	}
	webService static DesignToolWebserviceResponse getModifyProposalURL(String objectId){
		DesignToolWebserviceResponse responseObj = new DesignToolWebserviceResponse();
		responseObj = DesignTool.getModifyProposalURL(objectId);
		System.debug('responseObj: ' +responseObj);
		return 	responseObj;
	}
	webService static DesignToolWebserviceResponse getModifyProposalURLWithFunction(String objectId,string function){
		DesignTool.function=function;
		DesignToolWebserviceResponse responseObj = new DesignToolWebserviceResponse();
		responseObj = DesignTool.getModifyProposalURL(objectId);
		System.debug('responseObj: ' +responseObj);
		return 	responseObj;
	}
	
	@RemoteAction
	global static DesignToolWebserviceResponse getModifyProposalURLForOpty(String objectId){
		DesignToolWebserviceResponse responseObj = new DesignToolWebserviceResponse();
		responseObj = DesignTool.getModifyProposalURLForOpty(objectId);
		System.debug('responseObj: ' +responseObj);
		return 	responseObj;
	}

	
	global class DesignToolWebserviceResponse{
		webservice String status{get;set;}
		webservice String errorMessage{get;set;}
		webservice String url{get;set;}
	}
}