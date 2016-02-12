Public class OpportunityEmailClass{

public static void checkSiteAuditSchedule(List<Opportunity> oplist){
 Map<Id,List<Id>> recepientMap = new Map<Id,List<Id>>();
 Map<Id,String> oppSalesPartnerGenericEmailMap = new Map<Id,String>();
 Map<Id,List<string>> ccRecepientMap = new Map<Id,List<string>>();
 Map<Id,Map<String,string>> oppWhereClauseFieldValueMap = new Map<Id,Map<string,string>>();
 List<Opportunity> optylist = new List<Opportunity>();
 Set<Id> optyidset = new set<Id>();
 
    for(opportunity o: oplist){
      if(!checkRecursive.siteAuditSchedule.contains(o.id) ){
        checkRecursive.siteAuditSchedule.add(o.id);
        optyidset.add(o.id);
        system.debug('optyidset'+optyidset);
      }
    }
    if(!optyidset.isEmpty()){
      optylist = [select Id, Utility_Company__c,Sales_Representative__c,Sales_Representative__r.Email,Salesrep__c,Salesrep__r.Email,Opportunity_Source_Type__c,Preferred_Language__c,Purchased_Thru__c from Opportunity where Id in: optyidset];
    }
    if(!optylist.isEmpty()){
    recepientMap = recepientList(optylist);
    system.debug('recepientMap '+recepientMap);
    oppSalesPartnerGenericEmailMap = salesPartnerGenericEmail(optylist);
    system.debug('oppSalesPartnerGenericEmailMap '+oppSalesPartnerGenericEmailMap);
    ccRecepientMap = ccRecepientList(optylist,oppSalesPartnerGenericEmailMap);
    system.debug('ccRecepientMap '+ccRecepientMap);
    oppWhereClauseFieldValueMap = oppWhereClauseFieldValue(optylist);
    system.debug('oppWhereClauseFieldValueMap '+oppWhereClauseFieldValueMap);    
    
      for(Opportunity o: optylist){
        if(recepientMap.get(o.Id)!=null && oppWhereClauseFieldValueMap.get(o.id) != null && ccRecepientMap.get(o.Id)!=null){
            if(o.Preferred_Language__c == 'Spanish'){
               CustomEmailManager.communicateScheduledEvent(oppWhereClauseFieldValueMap.get(o.id),'Site Audit Schedule EPC Spanish',recepientMap.get(o.Id),ccRecepientMap.get(o.Id),null,null,'pc@sunrun.com');       
            } 
            else if(o.Purchased_Thru__c == 'Costco')
            {
                CustomEmailManager.communicateScheduledEvent(oppWhereClauseFieldValueMap.get(o.id),'Site Audit Schedule Costco',recepientMap.get(o.Id),ccRecepientMap.get(o.Id),null,null,'pc@sunrun.com');       
            }
        else
               CustomEmailManager.communicateScheduledEvent(oppWhereClauseFieldValueMap.get(o.id),'Site Audit Schedule EPC',recepientMap.get(o.Id),ccRecepientMap.get(o.Id),null,null,'pc@sunrun.com');
          }
      }    
    }    
}
    
public static Map<Id,List<Id>> recepientList(List<opportunity> opplist){

 set<Id> oppIds = new Set<Id>();
 set<Id> oppIds2 = new Set<Id>();
 List<Id> conIds = new List<Id>();
 List<OpportunityContactRole> OCRlist = new List<OpportunityContactRole>();
 Map<Id,List<Id>> contactsMap = new Map<Id,List<Id>>();
 Map<Id,List<Id>> tempcontactsMap = new Map<Id,List<Id>>();
 List<Id> contactIdList = new List<Id>();
 List<Id> tempcontactIdList = new List<Id>();
 Map<Id,List<Id>> oppconmap = new Map<Id,List<Id>>();   
 
 for(Opportunity o: opplist){
   //if(!checkRecursive.recipientlistids.contains(o.id)){
   //checkRecursive.recipientlistids.add(o.id);
    oppIds.add(o.Id);
   //}
 }
 
 if(!oppIds.isEmpty()){
   OCRlist = [Select ContactId, Contact.Email, OpportunityId from OpportunityContactRole where OpportunityId in: oppIds and IsPrimary = true and Contact.Email!=null];
 }
 
 if(!OCRlist.isEmpty()){
 system.debug('OCRlist'+OCRlist);
    for(OpportunityContactRole OCR: OCRlist){
      
      if(OCR.Contact.Email!=null)
      contactIdList.add(OCR.ContactId);
      tempcontactIdList = contactIdList.clone();  
      oppconmap.put(OCR.OpportunityId,tempcontactIdList);
      contactIdList.clear();  
      system.debug('OCR Contact Email'+OCR.Contact.Email);
      system.debug('Temp contactId List'+tempcontactIdList ); 
    }
  }
    if(!oppIds.isEmpty() && !oppconmap.isEmpty()){
      for(Id oid: oppIds){
        //tempcontactIdList = contactIdList.clone();
          contactsMap.put(oid,oppconmap.get(oid));
          //contactIdList.clear();
      }
    }
    system.debug('contactsMap'+contactsMap);
    
 return contactsMap;
}

public static Map<Id,string> salesPartnerGenericEmail(List<Opportunity> opplist){

 Set<Id> oppset = new Set<Id>();
 Map<Id,Id> prmap = new map<Id,Id>();
 Map<Id,string> accmap = new map<Id,string>();
 Map<Id,string> salesPartnerGenericEmailMap = new Map<Id,string>();
 for(Opportunity o: opplist){
  oppset.add(o.Id);
 }

 for(Partner_Role__c pr : [select Id,Partner_Name__c,Role__c,Opportunity__c from Partner_Role__c where Role__c in ('Sales') and Opportunity__c in: oppset]){
  prmap.put(pr.Opportunity__c,pr.Partner_Name__c);
 system.debug('prmap'+prmap);
 }
 if(!prmap.isEmpty()){
  for(Account acc: [select Id, Corporate_Email_Address__c from Account where Id in: prmap.values()])
   accmap.put(acc.Id,acc.Corporate_Email_Address__c);
 system.debug('accmap'+accmap);
 }
    for(Id oppId : prmap.keyset()){
       salesPartnerGenericEmailMap.put(oppId,accmap.get(prmap.get(oppId))); 
    system.debug('salesPartnerGenericEmailMap'+salesPartnerGenericEmailMap);
    }
 return salesPartnerGenericEmailMap;
}

    public static Map<Id,List<string>> ccRecepientList(List<Opportunity> oplist, Map<Id,String> salesPartnerGenericEmail){
     List<string> ccRecepientlist = new List<string>();
     List<string> temprecepientlist = new List<string>();
     Map<Id,List<String>> ccRecepientMap = new Map<Id,List<String>>();   
        for(Opportunity o:oplist ){
            
            if(o.Opportunity_Source_Type__c=='BB'){
                //ccRecepientlist.add(o.Salesrep__r.Email);
              if(o.Salesrep__r.Email != null){
                ccRecepientlist.add(o.Salesrep__r.Email);
                //ccRecepientlist.add(o.Salesrep__c);
              }
            system.debug('ccRecepientlist'+ccRecepientlist);
            }
            
            else if(o.Sales_Representative__c!=null){
                //ccRecepientlist.add(o.Sales_Representative__r.Email);
                ccRecepientlist.add(o.Sales_Representative__r.Email);
                //ccRecepientlist.add(o.Sales_Representative__r.Email);
            system.debug('ccRecepientlist2'+ccRecepientlist);
            }
            
            if(salesPartnerGenericEmail.get(o.id) != null){
                ccRecepientlist.add(salesPartnerGenericEmail.get(o.id));
            }
            ccRecepientlist.add(Corporate_Generic_Email__c.getValues(System.label.sunrun_inc_Id).Email__c);
            system.debug('ccRecepientlist'+ccRecepientlist);
            
            temprecepientlist = ccRecepientlist.clone();
            ccRecepientMap.put(o.id,temprecepientlist);
            ccRecepientlist.clear();
            system.debug('ccRecepientMap'+ccRecepientMap);
        }
        return ccRecepientMap;
    }
    public static Map<Id, Map<string,string>> oppWhereClauseFieldValue(List<Opportunity> oplist){
        set<string> UtilityCompanySet = new Set<string>();
        Map<string, string> WhereClauseFieldValueMap = new Map<string, string>();
        Map<string,string> tempWhereClauseFieldValueMap = new Map<string,string>();
        Map<Id, Map<String,string>> oppWhereClauseFieldValueMap = new Map<Id, Map<String,String>>();
        for(Utility_Timelines__c u: [select Name from Utility_Timelines__c]){
           UtilityCompanySet.add(u.Name);    
        }
        for(Opportunity o: oplist){
            WhereClauseFieldValueMap.put('id',o.Id);
        if(O.preferred_language__c == 'Spanish'){
                whereClauseFieldValueMap.put('Utility', 'General Timeline Spanish');
        }
        else if(UtilityCompanySet.contains(o.Utility_Company__c)){
                WhereClauseFieldValueMap.put('Utility',o.Utility_Company__c);
        }
        else{
                WhereClauseFieldValueMap.put('Utility', 'General Timeline');
        }
        tempWhereClauseFieldValueMap = WhereClauseFieldValueMap.clone();
        oppWhereClauseFieldValueMap.put(o.Id,tempWhereClauseFieldValueMap);
        WhereClauseFieldValueMap.clear();
        }
        return oppWhereClauseFieldValueMap;
        }
   
    public static void checkSiteAuditComplete(List<Opportunity> oplist){
        
     Map<Id,List<Id>> recepientMap = new Map<Id,List<Id>>();
     Map<Id,String> oppSalesPartnerGenericEmailMap = new Map<Id,String>();
     Map<Id,List<string>> ccRecepientMap = new Map<Id,List<Id>>();   
     Map<Id,Map<String,string>> oppWhereClauseFieldValueMap = new Map<Id,Map<string,string>>();
     Map<Id,string> projectPlannerMap = new Map<Id,string>();
     Set<Id> optyidset2 = new set<Id>();
     List<Opportunity> optylist = new List<Opportunity>();
     
     for(Opportunity o: oplist){
       if(!checkRecursive.siteAuditComplete.contains(o.id)){
          checkRecursive.siteAuditComplete.add(o.id);
          optyidset2.add(o.id);
       }
     }
     if(!optyidset2.isEmpty()){
       optylist = [select Id, Utility_Company__c,Sales_Representative__c,Sales_Representative__r.Email,Salesrep__c,Salesrep__r.Email,Opportunity_Source_Type__c,Install_Partner__c,Project_Manager_Email__c,Preferred_Language__c from Opportunity where Id in: optyidset2];
     }   
     if(!optylist.isEmpty()){
     recepientMap = recepientList(optylist);
     system.debug('recepientMap'+recepientMap);
     oppSalesPartnerGenericEmailMap = salesPartnerGenericEmail(optylist);
     system.debug('oppSalesPartnerGenericEmailMap'+oppSalesPartnerGenericEmailMap);
     ccRecepientMap = ccRecepientList(optylist,oppSalesPartnerGenericEmailMap);
     system.debug('ccRecepientMap'+ccRecepientMap);
     oppWhereClauseFieldValueMap = oppWhereClauseFieldValue(optylist);
     system.debug('oppWhereClauseFieldValueMap'+oppWhereClauseFieldValueMap);   
     projectPlannerMap = projectPlannerMailId(optylist);
     system.debug('projectPlannerMap'+projectPlannerMap);
        for(Opportunity o:optylist){
          if(o.Install_Partner__c == System.label.sunrun_inc_Id && o.Project_Manager_Email__c != null && o.Preferred_Language__c == 'Spanish'){
             CustomEmailManager.communicateScheduledEvent(oppWhereClauseFieldValueMap.get(o.id),'Site Audit Complete Spanish',recepientMap.get(o.Id),ccRecepientMap.get(o.Id),projectPlannerMap.get(o.Id),projectPlannerMap.get(o.Id),null); 
          }
          else if(o.Project_Manager_Email__c == null && o.Preferred_Language__c == 'Spanish'){
             CustomEmailManager.communicateScheduledEvent(oppWhereClauseFieldValueMap.get(o.id),'Site Audit Complete Spanish 2',recepientMap.get(o.Id),ccRecepientMap.get(o.Id),projectPlannerMap.get(o.Id),projectPlannerMap.get(o.Id),null);
          }
          else
          { 
            if(o.Install_Partner__c == System.label.sunrun_inc_Id && o.Project_Manager_Email__c != null){
              if(oppWhereClauseFieldValueMap.get(o.id)!=null && recepientMap.get(o.Id)!=null && ccRecepientMap.get(o.Id)!=null && projectPlannerMap.get(o.Id)!=null)
                 CustomEmailManager.communicateScheduledEvent(oppWhereClauseFieldValueMap.get(o.id),'Site Audit Complete',recepientMap.get(o.Id),ccRecepientMap.get(o.Id),projectPlannerMap.get(o.Id),projectPlannerMap.get(o.Id),null);  
            }
            //else if(o.Install_Partner__c != System.label.sunrun_inc_Id){
            else if(oppWhereClauseFieldValueMap.get(o.id)!=null && recepientMap.get(o.Id)!=null && ccRecepientMap.get(o.Id)!=null){
                 CustomEmailManager.communicateScheduledEvent(oppWhereClauseFieldValueMap.get(o.id),'Site Audit Complete EPC',recepientMap.get(o.Id),ccRecepientMap.get(o.Id),null,null,'pc@sunrun.com');  
            }
          }
        }  
    }
    
    }

    public static map<Id,string> projectPlannerMailId(List<Opportunity> olist){
        map<Id,string> projectPlannerMap = new Map<Id,string>();
        set<Id> userIds = new Set<Id>();
        for(Opportunity o:olist){
            if(o.Install_Partner__c == System.label.sunrun_inc_Id && o.Project_Manager_Email__c != null)
            projectPlannerMap.put(o.id,o.Project_Manager_Email__c);
            system.debug('projectPlannerMap'+projectPlannerMap);
        }
      return projectPlannerMap;  
    }

        
}