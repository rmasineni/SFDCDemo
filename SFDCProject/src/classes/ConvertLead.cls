global without sharing class ConvertLead {
webService static String doConvert(Id leadId){
        Lead leadObj = [select id, name, street, city, HasOptedOutOfEmail,PostalCode,DoNotCall, state__C, zip_6__c, CDYNE_Status__c, phone, Alternate_Phone__c, Preferred_Language__c from lead where id =: leadId];
        Database.LeadConvert lc = new database.LeadConvert();
        lc.setLeadId(leadId);
        lc.setDoNotCreateOpportunity(false);
        if(leadobj.street != null){
        lc.opportunityName = leadobj.street + '-' + leadobj.PostalCode;
        }

        LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted=true LIMIT 1];
        lc.setConvertedStatus(convertStatus.MasterLabel);
        Database.LeadConvertResult lcr = Database.convertLead(lc);
        
        String OpptyId = lcr.getOpportunityId();
        System.debug('OpptyId: ' + OpptyId);
       /* List<OpportunityContactRole> contactRoleList = [Select Id, role, isPrimary, ContactId from OpportunityContactRole where OpportunityId =:OpptyId];
        System.debug('contactRoleList: ' + contactRoleList);
        if(contactRoleList.size() > 0){
            OpportunityContactRole contactRoleObj = contactRoleList[0];
            contactRoleObj.role = 'Homeowner';
            contactRoleObj.isPrimary = true;
            update contactRoleObj;
        } */

        Id userId = UserInfo.getUserId();
        User loginUser = PRMContactUtil.getUser(userId);
       Contact loginContact = PRMContactUtil.getLoginUserContact();
        Opportunity OpptyObj = [select id, name,Email_Opt_Out__c,CreatedBy.contactid,Do_not_call__c,salesrep__c,ownerid,createdbyid, street__c, city__c, zip_code__c, state__C, zip_6__c,county__c, CDYNE_Status__c, phone__c, Alternate_Phone__c from Opportunity where id =: OpptyId];
        
        OpptyObj.street__c =  leadobj.street;
        OpptyObj.city__c = leadobj.city;
        OpptyObj.zip_code__c = leadobj.PostalCode;
        OpptyObj.state__C = leadobj.state__C;
        OpptyObj.zip_6__c = leadObj.zip_6__c;
        OpptyObj.CDYNE_Status__c = leadObj.CDYNE_Status__c; 
        OpptyObj.Do_not_call__c=leadObj.DoNotCall;
         OpptyObj.Email_Opt_Out__c=leadObj.HasOptedOutOfEmail;
         OpptyObj.Preferred_Language__c=leadObj.Preferred_Language__c;  
        //if(OpptyObj.CreatedBy.contactid!=null){
        //OpptyObj.ownerid=OpptyObj.createdbyid;
        //}    
        //OpptyObj.phone__c = leadObj.phone;
       // OpptyObj.Alternate_Phone__c = leadobj.Alternate_Phone__c ;
        //if(loginContact!=null)
        //OpptyObj.Sales_Representative__c = loginContact.id;
        
        update OpptyObj;
        
        return OpptyId;
    }
}