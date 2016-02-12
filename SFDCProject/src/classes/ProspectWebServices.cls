@RestResource(urlMapping='/ProspectWebServices/*')
global with sharing class ProspectWebServices {
    
    @HttpPut
    global static List<BBOpportunityResponse> doPutProspectDetails(String prospectId) {
      List<BBOpportunityResponse> responseObjList = new List<BBOpportunityResponse>();
      BBOpportunityResponse responseObj = new BBOpportunityResponse();
      RestResponse res = RestContext.response;
      RestRequest req = RestContext.request;

      //String prospectId = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
      system.debug('Received prospectId:' + prospectId);
      
      List<Lead> leadObjList = [Select id, name, Prospect_Id__c, isconverted from Lead where Prospect_Id__c =:prospectId and isconverted = false order by Id limit 1];
      Lead leadObj = null;
      Opportunity opptyObj = null;
     
      system.debug('leadObjList :' + leadObjList);    
      if(leadObjList != null && leadObjList.size() > 0){
        leadObj = leadObjList[0];
        system.debug('Lead Id:' + leadObj.id);
      }else {
        system.debug('Fetching Opportunity');
        List<Opportunity> opptyObjList = [Select id, name, Prospect_Id__c from Opportunity where Prospect_Id__c =:prospectId order by Id limit 1];
            if(opptyObjList != null && opptyObjList.size() > 0){
                opptyObj = opptyObjList[0];
                system.debug('Opportunity Id:' + opptyObj.id);
            }
      }
      
      
      if(leadObj != null){
        Id leadId = leadObj.id;
        String opptyId = covertLead(leadId);
        responseObj.opportunityId = opptyId;
        responseObj.message = 'Prospect ID matched a lead';
        res.statusCode = 201;
        responseObjList.add(responseObj);

      }else if(opptyObj != null){
        responseObj.opportunityId = opptyObj.Id;
        responseObj.message = 'Prospect ID matched an opportunity';
        res.statusCode = 200;
        responseObjList.add(responseObj);

      }else {
        responseObj.errorCode = 'PROSPECT_ID_NOT_FOUND';
        responseObj.message = 'Prospect ID matched nothing';
        res.statusCode = 404;
        responseObjList.add(responseObj);
      }                 
      
      system.debug('RestResponse' + res);

      return responseObjList;
    }
    
    public static String covertLead(Id leadId){
        Lead leadObj = [select id, name, street, city, PostalCode, state__C, zip_6__c, CDYNE_Status__c, phone, Alternate_Phone__c from lead where id =: leadId];
        
        Database.LeadConvert lc = new database.LeadConvert();
        lc.setLeadId(leadId);
        lc.setDoNotCreateOpportunity(false);
        if(leadobj.street != null){
        lc.opportunityName = leadobj.street;
        }

        LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted=true LIMIT 1];
        lc.setConvertedStatus(convertStatus.MasterLabel);
        Database.LeadConvertResult lcr = Database.convertLead(lc);
        
        String OpptyId = lcr.getOpportunityId();
         system.debug('opptyId');
         
         Opportunity OpptyObj = [select id, name, street__c, city__c, zip_code__c, state__C, zip_6__c, CDYNE_Status__c, phone__c, Alternate_Phone__c from Opportunity where id =: OpptyId];
        
        if(leadobj.street != null || leadobj.street != ''){
        	OpptyObj.Name = leadobj.Street + '-' + leadobj.PostalCode;
        }
        OpptyObj.street__c =  leadobj.street;
        OpptyObj.city__c = leadobj.city;
        OpptyObj.zip_code__c = leadobj.PostalCode;
        OpptyObj.state__C = leadobj.state__C;
        OpptyObj.zip_6__c = leadObj.zip_6__c;
        OpptyObj.CDYNE_Status__c = leadObj.CDYNE_Status__c;
        OpptyObj.phone__c = leadObj.phone;
        OpptyObj.Alternate_Phone__c = leadobj.Alternate_Phone__c ;
        
        update OpptyObj;
        
        return lcr.getOpportunityId();
    }
    
    global class BBOpportunityResponse {
        global String opportunityId{get;set;}
        global String errorCode { get; set; }
        global String message{get;set;}
    }    
    
    global class BBProspectInfo {
    global String prospectId{get;set;}
    } 

}