public class SCETriggerClass{

/***********************************************************************************
 Email is sent out Customer and Sales Rep informing about the Scheduled Installation, 
 when Scheduled Installation Date is updated on Service Contract Event.  
************************************************************************************/
    public static void checkScheduledInstallDate(List<Service_Contract_Event__c> list_sce,Boolean isInsert,
                                               Boolean isupdate,map<id,Service_Contract_Event__c> old_Map){
    
                                                 
        map<Id,String> sceProjectTypeMap = new map<Id,String>();
        map<Id,List<Id>> sceToRecipientMap = new map<Id,List<Id>>();
        map<Id,List<String>> sceCCRecipientMap = new map<Id,List<String>>();
        map<Id,String> sceIdPPEmailIdMap = new map<Id,String>();
        map<Id,map<String,String>> sceWhereClauseFieldValueMap = new map<Id,map<String,String>>();
        map<Id,String> sceSalesPartnerGenericEmailMap = new map<Id,String>();
        List<Service_Contract_Event__c> sceList = new List<Service_Contract_Event__c>();
        Set<Id> sceIdSet = new Set<Id>();
        Integer daysInPastLimit = 0; 
        map<Id,List<String>> sceBCCRecipientMap = new map<Id,List<String>>();
        map<Id,List<String>> sceToAddrRecipientMap = new map<Id,List<String>>();                                                                                      

        daysInPastLimit = Integer.valueOf(SCE_Email_Status__c.getValues('Install Scheduled').No_Of_Days_In_Past_Limit__c);
        System.debug('No. of Days in Past: ' +daysInPastLimit);        
        //System.debug('list_sce :' +list_sce);
        for (Service_Contract_Event__c sce : list_sce) {
            If ((sce.Scheduled_Install_Date__c != null && sce.Scheduled_Install_Date__c >= (date.today() - daysInPastLimit) && 
                !checkRecursive.scheduledInstallIds.contains(sce.id)) &&
                (Trigger.isInsert || 
                (Trigger.isUpdate  && old_Map.get(sce.id).Scheduled_Install_Date__c != sce.Scheduled_Install_Date__c))){
                
                checkRecursive.scheduledInstallIds.add(sce.id);               
                sceIdSet.add(sce.id);
            }
        }   
        
        if(!sceIdSet.isEmpty()){ 
            sceList = [Select Id, Project_Manager__c, Project_Manager_Email__c, Service_Contract__r.ContactId, 
                              Service_Contract__r.Opportunity__r.Opportunity_Source_Type__c, Service_Contract__r.Utility_Company__c, 
                              Service_Contract__r.Opportunity__r.Salesrep__c, Service_Contract__r.Opportunity__r.Salesrep__r.Email,
                              Service_Contract__r.Opportunity__r.Sales_Representative__c, Service_Contract__r.Opportunity__r.Sales_Representative__r.Email,
                              Service_Contract__r.Opportunity__r.Preferred_Language__c,
                              Opportunity__c
                        From Service_Contract_Event__c
                        Where id in :sceIdSet]; 

            if(!sceList.isEmpty()){ 
                sceProjectTypeMap = getProjectType(sceList);
                sceToRecipientMap = getToRecipientList(sceList);
                sceSalesPartnerGenericEmailMap = getSalesPartnerGenericEmail(sceList); 
                sceCCRecipientMap = getCCRecipientList(sceList, sceSalesPartnerGenericEmailMap);
                sceIdPPEmailIdMap = getReplyToEmailId(sceList);
                sceWhereClauseFieldValueMap = getSceWhereClauseFieldValue(sceList);
            
                for(Service_Contract_Event__c sce : sceList){
                 if(sce.Service_Contract__r.Opportunity__r.Preferred_Language__c == 'Spanish'){
                   CustomEmailManager.communicateScheduledEvent(sceWhereClauseFieldValueMap.get(sce.Id),
                                                              'Install Schedule Direct Spanish', sceToRecipientMap.get(sce.Id), sceCCRecipientMap.get(sce.Id),
                                                              'Sunrun Project Planner', sceIdPPEmailIdMap.get(sce.Id), null);
                 }
                 else
                  {  if (sceProjectTypeMap.get(sce.Id) == 'Direct' && sceIdPPEmailIdMap.containsKey(sce.Id)){
                        System.debug('recipientList :' +sceToRecipientMap.get(sce.Id));
                        System.debug('CCList : ' +sceCCRecipientMap.get(sce.Id));
                        CustomEmailManager.communicateScheduledEvent(sceWhereClauseFieldValueMap.get(sce.Id), 
                                                                     'Install Schedule Direct', sceToRecipientMap.get(sce.Id),sceCCRecipientMap.get(sce.Id),
                                                                     'Sunrun Project Planner' , sceIdPPEmailIdMap.get(sce.Id),null);             
                    } else {
                        System.debug('recipientList :' +sceToRecipientMap.get(sce.Id));
                        CustomEmailManager.communicateScheduledEvent(sceWhereClauseFieldValueMap.get(sce.Id), 
                                                                     'Install Schedule EPC', sceToRecipientMap.get(sce.Id), sceCCRecipientMap.get(sce.Id),
                                                                      null, null,'pc@sunrun.com');             
                    }
                  }  
                }//End-For 
            } //End-If
        } //End-If
    }

/***********************************************************************************
 Email is sent out Customer and Sales Rep informing about the Permit Submission, 
 when -
 1. CAP Date Approved is populated on Service Contract Event AND
 2. Permit Expected Date is populated on Service Contract Event AND
 3. Permit Submitted Date is populated on Service Contract Event AND
 4. Permit Approval is NULL on Service Contract Event
************************************************************************************/
  public static void checkPermitSubmittedDate(List<Service_Contract_Event__c> list_sce,Boolean isInsert,
                                               Boolean isupdate,map<id,Service_Contract_Event__c> old_Map){

        map<Id,String> sceProjectTypeMap = new map<Id,String>();
        map<Id,List<Id>> sceToRecipientMap = new map<Id,List<Id>>();
        map<Id,List<String>> sceCCRecipientMap = new map<Id,List<String>>();
        map<Id,String> sceIdPPEmailIdMap = new map<Id,String>();
        map<Id,map<String,String>> sceWhereClauseFieldValueMap = new map<Id,map<String,String>>();
        map<Id,String> sceSalesPartnerGenericEmailMap = new map<Id,String>();
        List<Service_Contract_Event__c> sceList = new List<Service_Contract_Event__c>();
        Set<Id> sceIdSet = new Set<Id>();
        
        System.debug('list_sce :' +list_sce);
        for (Service_Contract_Event__c sce : list_sce) {
            If ((sce.CAP_date_approved__c != null && sce.Permit_Expected_Date__c != null && 
                 sce.Permit_Submitted_Date__c != null && sce.Permit_Approval_Date__c == null && 
                !checkRecursive.permitSubmittedIds.contains(sce.id)) &&
                (Trigger.isInsert || 
                (Trigger.isUpdate && 
                (sce.CAP_date_approved__c != null && old_Map.get(sce.id).CAP_date_approved__c == null) ||
                (sce.Permit_Expected_Date__c != null && old_Map.get(sce.id).Permit_Expected_Date__c == null) ||
                (sce.Permit_Submitted_Date__c != null && old_Map.get(sce.id).Permit_Submitted_Date__c == null)))){
                
                checkRecursive.permitSubmittedIds.add(sce.id);               
                sceIdSet.add(sce.id);
            }
        }   

        if(!sceIdSet.isEmpty()){ 
            sceList = [Select Id, Project_Manager__c, Project_Manager_Email__c, Service_Contract__r.ContactId, 
                              Service_Contract__r.Opportunity__r.Opportunity_Source_Type__c, Service_Contract__r.Utility_Company__c, 
                              Service_Contract__r.Opportunity__r.Salesrep__c, Service_Contract__r.Opportunity__r.Salesrep__r.Email,
                              Service_Contract__r.Opportunity__r.Sales_Representative__c, Service_Contract__r.Opportunity__r.Preferred_Language__c, Service_Contract__r.Opportunity__r.Sales_Representative__r.Email,
                              Opportunity__c 
                        From Service_Contract_Event__c
                        Where id in :sceIdSet]; 

     
            if(!sceList.isEmpty()){ 
                sceProjectTypeMap = getProjectType(sceList);
                System.debug('sceProjectTypeMap : ' +sceProjectTypeMap);
                sceToRecipientMap = getToRecipientList(sceList);
                System.debug('sceToRecipientMap : ' +sceToRecipientMap);
                sceSalesPartnerGenericEmailMap = getSalesPartnerGenericEmail(sceList); 
                sceCCRecipientMap = getCCRecipientList(sceList, sceSalesPartnerGenericEmailMap);
                sceIdPPEmailIdMap = getReplyToEmailId(sceList);
                sceWhereClauseFieldValueMap = getSceWhereClauseFieldValue(sceList);
            
                for(Service_Contract_Event__c sce : sceList){ 
                    if (sce.Service_Contract__r.Opportunity__r.Preferred_Language__c == 'Spanish'){
                        System.debug('recipientList :' +sceToRecipientMap.get(sce.Id));
                        System.debug('CCList : ' +sceCCRecipientMap.get(sce.Id));
                        CustomEmailManager.communicateScheduledEvent(sceWhereClauseFieldValueMap.get(sce.Id), 
                                                                     'Permit Submitted Direct Spanish', sceToRecipientMap.get(sce.Id),sceCCRecipientMap.get(sce.Id),
                                                                     'Sunrun Project Planner' , sceIdPPEmailIdMap.get(sce.Id),null);             
                    }
                    else if (sceProjectTypeMap.get(sce.Id) == 'Direct' && sceIdPPEmailIdMap.containsKey(sce.Id)){
                        System.debug('recipientList :' +sceToRecipientMap.get(sce.Id));
                        System.debug('CCList : ' +sceCCRecipientMap.get(sce.Id));
                        CustomEmailManager.communicateScheduledEvent(sceWhereClauseFieldValueMap.get(sce.Id), 
                                                                     'Permit Submitted Direct', sceToRecipientMap.get(sce.Id),sceCCRecipientMap.get(sce.Id),
                                                                     'Sunrun Project Planner' , sceIdPPEmailIdMap.get(sce.Id),null);             
                    } else {
                        System.debug('recipientList :' +sceToRecipientMap.get(sce.Id));
                        CustomEmailManager.communicateScheduledEvent(sceWhereClauseFieldValueMap.get(sce.Id), 
                                                                     'Permit Submitted EPC', sceToRecipientMap.get(sce.Id), sceCCRecipientMap.get(sce.Id),
                                                                      null, null,'pc@sunrun.com');             
                    }
                }//End-For 
            } //End-If
        } //End-If
    }


/***********************************************************************************
 Email is sent out Customer and Sales Rep informing about the Permit Approval, 
 when -
 1. CAP Date Approved is populated on Service Contract Event AND 
 2. Permit Approval Date is populated on Service Contract Event   
************************************************************************************/
    public static void checkPermitApprovedDate(List<Service_Contract_Event__c> list_sce,Boolean isInsert,
                                               Boolean isupdate,map<id,Service_Contract_Event__c> old_Map){

        map<Id,String> sceProjectTypeMap = new map<Id,String>();
        map<Id,List<Id>> sceToRecipientMap = new map<Id,List<Id>>();
        map<Id,List<String>> sceCCRecipientMap = new map<Id,List<String>>();
        map<Id,String> sceIdPPEmailIdMap = new map<Id,String>();
        map<Id,map<String,String>> sceWhereClauseFieldValueMap = new map<Id,map<String,String>>();
        map<Id,String> sceSalesPartnerGenericEmailMap = new map<Id,String>();
        List<Service_Contract_Event__c> sceList = new List<Service_Contract_Event__c>();
        Set<Id> sceIdSet = new Set<Id>();
        
        System.debug('list_sce :' +list_sce);
        for (Service_Contract_Event__c sce : list_sce) {
            If ((sce.CAP_date_approved__c != null && sce.Permit_Approval_Date__c != null && 
                !checkRecursive.permitApprovedIds.contains(sce.id)) &&
                (Trigger.isInsert || 
                (Trigger.isUpdate && 
                (sce.CAP_date_approved__c != null && old_Map.get(sce.id).CAP_date_approved__c == null) ||
                (sce.Permit_Approval_Date__c != null && old_Map.get(sce.id).Permit_Approval_Date__c == null)))){
                
                checkRecursive.permitApprovedIds.add(sce.id);               
                sceIdSet.add(sce.id);
            }
        }   

        if(!sceIdSet.isEmpty()){ 
            sceList = [Select Id, Project_Manager__c, Project_Manager_Email__c, Service_Contract__r.ContactId, 
                              Service_Contract__r.Opportunity__r.Opportunity_Source_Type__c, Service_Contract__r.Utility_Company__c, 
                              Service_Contract__r.Opportunity__r.Salesrep__c, Service_Contract__r.Opportunity__r.Salesrep__r.Email,
                              Service_Contract__r.Opportunity__r.Sales_Representative__c, Service_Contract__r.Opportunity__r.Preferred_Language__c, Service_Contract__r.Opportunity__r.Sales_Representative__r.Email,
                              Opportunity__c 
                        From Service_Contract_Event__c
                        Where id in :sceIdSet]; 


            if(!sceList.isEmpty()){ 
                sceProjectTypeMap = getProjectType(sceList);
                System.debug('sceProjectTypeMap : ' +sceProjectTypeMap);
                sceToRecipientMap = getToRecipientList(sceList);
                System.debug('sceToRecipientMap : ' +sceToRecipientMap);
                sceSalesPartnerGenericEmailMap = getSalesPartnerGenericEmail(sceList); 
                sceCCRecipientMap = getCCRecipientList(sceList, sceSalesPartnerGenericEmailMap);
                sceIdPPEmailIdMap = getReplyToEmailId(sceList);
                sceWhereClauseFieldValueMap = getSceWhereClauseFieldValue(sceList);
            
                for(Service_Contract_Event__c sce : sceList){ 
                    if (sce.Service_Contract__r.Opportunity__r.Preferred_Language__c == 'Spanish'){
                        System.debug('recipientList :' +sceToRecipientMap.get(sce.Id));
                        System.debug('CCList : ' +sceCCRecipientMap.get(sce.Id));
                        CustomEmailManager.communicateScheduledEvent(sceWhereClauseFieldValueMap.get(sce.Id), 
                                                                     'Permit Approved Direct Spanish', sceToRecipientMap.get(sce.Id),sceCCRecipientMap.get(sce.Id),
                                                                     'Sunrun Project Planner' , sceIdPPEmailIdMap.get(sce.Id),null);             
                    }
                    else if (sceProjectTypeMap.get(sce.Id) == 'Direct' && sceIdPPEmailIdMap.containsKey(sce.Id)){
                        System.debug('recipientList :' +sceToRecipientMap.get(sce.Id));
                        System.debug('CCList : ' +sceCCRecipientMap.get(sce.Id));
                        CustomEmailManager.communicateScheduledEvent(sceWhereClauseFieldValueMap.get(sce.Id), 
                                                                     'Permit Approved Direct', sceToRecipientMap.get(sce.Id),sceCCRecipientMap.get(sce.Id),
                                                                     'Sunrun Project Planner' , sceIdPPEmailIdMap.get(sce.Id),null);             
                    } else {
                        System.debug('recipientList :' +sceToRecipientMap.get(sce.Id));
                        CustomEmailManager.communicateScheduledEvent(sceWhereClauseFieldValueMap.get(sce.Id), 
                                                                     'Permit Approved EPC', sceToRecipientMap.get(sce.Id), sceCCRecipientMap.get(sce.Id),
                                                                      null, null,'pc@sunrun.com');             
                    }
                }//End-For 
            } //End-If
        } //End-If    
    }

/***********************************************************************************
 Email is sent out Customer and Sales Rep informing about the Construction Completion, 
 when -
 1. Completion of Construction Date is populated on Service Contract Event 
************************************************************************************/
    public static void checkConstructionCompletionDate(List<Service_Contract_Event__c> list_sce,Boolean isInsert,
                                               Boolean isupdate,map<id,Service_Contract_Event__c> old_Map){

        map<Id,String> sceProjectTypeMap = new map<Id,String>();
        map<Id,List<Id>> sceToRecipientMap = new map<Id,List<Id>>();
        map<Id,List<String>> sceCCRecipientMap = new map<Id,List<String>>();
        map<Id,String> sceIdPPEmailIdMap = new map<Id,String>();
        map<Id,map<String,String>> sceWhereClauseFieldValueMap = new map<Id,map<String,String>>();
        map<Id,String> sceSalesPartnerGenericEmailMap = new map<Id,String>();
        List<Service_Contract_Event__c> sceList = new List<Service_Contract_Event__c>();
        Set<Id> sceIdSet = new Set<Id>();
        Integer daysInPastLimit = 0; 
        
        daysInPastLimit = Integer.valueOf(SCE_Email_Status__c.getValues('Install Completed').No_Of_Days_In_Past_Limit__c);
        
        for (Service_Contract_Event__c sce : list_sce) {
            If ((sce.Completion_of_Construction__c != null && sce.Completion_of_Construction__c >= (date.today() - daysInPastLimit) &&
                !checkRecursive.constructionCompletedIds.contains(sce.id)) &&
                (Trigger.isInsert || 
                (Trigger.isUpdate && 
                (sce.Completion_of_Construction__c != null && old_Map.get(sce.id).Completion_of_Construction__c == null)))){
                
                checkRecursive.constructionCompletedIds.add(sce.id);               
                sceIdSet.add(sce.id);
            }
        }   
        
        if(!sceIdSet.isEmpty()){
            sceList = [Select Id, Project_Manager__c, Project_Manager_Email__c, Service_Contract__r.ContactId, 
                              Service_Contract__r.Opportunity__r.Opportunity_Source_Type__c, Service_Contract__r.Utility_Company__c, 
                              Service_Contract__r.Opportunity__r.Salesrep__c, Service_Contract__r.Opportunity__r.Salesrep__r.Email,
                              Service_Contract__r.Opportunity__r.Sales_Representative__c, Service_Contract__r.Opportunity__r.Sales_Representative__r.Email,Service_Contract__r.Opportunity__r.Preferred_Language__c,
                              Opportunity__c 
                        From Service_Contract_Event__c
                        Where id in :sceIdSet]; 


            if(!sceList.isEmpty()){ 
                sceProjectTypeMap = getProjectType(sceList);
                System.debug('sceProjectTypeMap : ' +sceProjectTypeMap);
                sceToRecipientMap = getToRecipientList(sceList);
                System.debug('sceToRecipientMap : ' +sceToRecipientMap);
                sceSalesPartnerGenericEmailMap = getSalesPartnerGenericEmail(sceList); 
                sceCCRecipientMap = getCCRecipientList(sceList, sceSalesPartnerGenericEmailMap);
                sceIdPPEmailIdMap = getReplyToEmailId(sceList);
                sceWhereClauseFieldValueMap = getSceWhereClauseFieldValue(sceList);
                
                for(Service_Contract_Event__c sce : sceList){ 
                    if(sce.Service_Contract__r.Opportunity__r.Preferred_Language__c == 'Spanish')
                    {
                        CustomEmailManager.communicateScheduledEvent(sceWhereClauseFieldValueMap.get(sce.Id), 
                           'Install Complete Direct Spanish', sceToRecipientMap.get(sce.Id),sceCCRecipientMap.get(sce.Id),
                           'Sunrun Project Planner' , sceIdPPEmailIdMap.get(sce.Id),null);   
                    }
             
                    else if (sceProjectTypeMap.get(sce.Id) == 'Direct' && sceIdPPEmailIdMap.containsKey(sce.Id)){
                        System.debug('recipientList :' +sceToRecipientMap.get(sce.Id));
                        System.debug('CCList : ' +sceCCRecipientMap.get(sce.Id));
                        CustomEmailManager.communicateScheduledEvent(sceWhereClauseFieldValueMap.get(sce.Id), 
                                                                     'Install Complete Direct', sceToRecipientMap.get(sce.Id),sceCCRecipientMap.get(sce.Id),
                                                                     'Sunrun Project Planner' , sceIdPPEmailIdMap.get(sce.Id),null);             
                    } else {
                        System.debug('recipientList :' +sceToRecipientMap.get(sce.Id));
                        CustomEmailManager.communicateScheduledEvent(sceWhereClauseFieldValueMap.get(sce.Id), 
                                                                     'Install Complete EPC', sceToRecipientMap.get(sce.Id), sceCCRecipientMap.get(sce.Id),
                                                                      null, null,'pc@sunrun.com');             
                    }
                }//End-For 
            } //End-If
        } //End-If    
    }    


/***********************************************************************************
 Email is sent out Customer and Sales Rep informing about the Inspection Sign-Off, 
 when -
 1. Final Inspection Sign-Off Date is populated on Service Contract Event 
************************************************************************************/
    public static void checkInspectionSignOffDate(List<Service_Contract_Event__c> list_sce,Boolean isInsert,
                                               Boolean isupdate,map<id,Service_Contract_Event__c> old_Map){

        map<Id,String> sceProjectTypeMap = new map<Id,String>();
        map<Id,List<Id>> sceToRecipientMap = new map<Id,List<Id>>();
        map<Id,List<String>> sceCCRecipientMap = new map<Id,List<String>>();
        map<Id,String> sceIdPPEmailIdMap = new map<Id,String>();
        map<Id,map<String,String>> sceWhereClauseFieldValueMap = new map<Id,map<String,String>>();
        map<Id,String> sceSalesPartnerGenericEmailMap = new map<Id,String>();
        List<Service_Contract_Event__c> sceList = new List<Service_Contract_Event__c>();
        Set<Id> sceIdSet = new Set<Id>();
        Integer daysInPastLimit = 0; 
        
        daysInPastLimit = Integer.valueOf(SCE_Email_Status__c.getValues('Inspection Sign-Off').No_Of_Days_In_Past_Limit__c);        
        
        System.debug('list_sce :' +list_sce);
        for (Service_Contract_Event__c sce : list_sce) {
            If ((sce.Final_Inspection_Signoff__c != null && sce.Final_Inspection_Signoff__c >= (date.today() - daysInPastLimit) && 
                !checkRecursive.inspectionSignOffIds.contains(sce.id)) &&
                (Trigger.isInsert || 
                (Trigger.isUpdate && 
                (sce.Final_Inspection_Signoff__c != null && old_Map.get(sce.id).Final_Inspection_Signoff__c == null)))){
                
                checkRecursive.inspectionSignOffIds.add(sce.id);               
                sceIdSet.add(sce.id);
            }
        }   
        
        if(!sceIdSet.isEmpty()){
            sceList = [Select Id, Project_Manager__c, Project_Manager_Email__c, Service_Contract__r.ContactId, 
                              Service_Contract__r.Opportunity__r.Opportunity_Source_Type__c, Service_Contract__r.Utility_Company__c, 
                              Service_Contract__r.Opportunity__r.Salesrep__c, Service_Contract__r.Opportunity__r.Salesrep__r.Email,
                              Service_Contract__r.Opportunity__r.Sales_Representative__c, Service_Contract__r.Opportunity__r.Preferred_Language__c, Service_Contract__r.Opportunity__r.Sales_Representative__r.Email,
                              Opportunity__c 
                        From Service_Contract_Event__c
                        Where id in :sceIdSet]; 


            if(!sceList.isEmpty()){ 
                sceProjectTypeMap = getProjectType(sceList);
                System.debug('sceProjectTypeMap : ' +sceProjectTypeMap);
                sceToRecipientMap = getToRecipientList(sceList);
                System.debug('sceToRecipientMap : ' +sceToRecipientMap);
                sceSalesPartnerGenericEmailMap = getSalesPartnerGenericEmail(sceList); 
                sceCCRecipientMap = getCCRecipientList(sceList, sceSalesPartnerGenericEmailMap);
                sceIdPPEmailIdMap = getReplyToEmailId(sceList);
                sceWhereClauseFieldValueMap = getSceWhereClauseFieldValue(sceList);
            
                for(Service_Contract_Event__c sce : sceList){ 
                      if (sce.Service_Contract__r.Opportunity__r.Preferred_Language__c == 'Spanish'){
                        System.debug('recipientList :' +sceToRecipientMap.get(sce.Id));
                        System.debug('CCList : ' +sceCCRecipientMap.get(sce.Id));
                        CustomEmailManager.communicateScheduledEvent(sceWhereClauseFieldValueMap.get(sce.Id), 
                                                                     'Inspection Sign-Off Direct Spanish', sceToRecipientMap.get(sce.Id),sceCCRecipientMap.get(sce.Id),
                                                                     'Sunrun Project Planner' , sceIdPPEmailIdMap.get(sce.Id),null);             
                    } 
            else if (sceProjectTypeMap.get(sce.Id) == 'Direct' && sceIdPPEmailIdMap.containsKey(sce.Id)){
                        System.debug('recipientList :' +sceToRecipientMap.get(sce.Id));
                        System.debug('CCList : ' +sceCCRecipientMap.get(sce.Id));
                        CustomEmailManager.communicateScheduledEvent(sceWhereClauseFieldValueMap.get(sce.Id), 
                                                                     'Inspection Sign-Off Direct', sceToRecipientMap.get(sce.Id),sceCCRecipientMap.get(sce.Id),
                                                                     'Sunrun Project Planner' , sceIdPPEmailIdMap.get(sce.Id),null);             
                    } else {
                        System.debug('recipientList :' +sceToRecipientMap.get(sce.Id));
                        CustomEmailManager.communicateScheduledEvent(sceWhereClauseFieldValueMap.get(sce.Id), 
                                                                     'Inspection Sign-Off EPC', sceToRecipientMap.get(sce.Id), sceCCRecipientMap.get(sce.Id),
                                                                      null, null,'pc@sunrun.com');             
                    }
                }//End-For 
            } //End-If
        } //End-If    
    }       

/************************************************************************************************
 Email is sent out Customer and Sales Rep informing about the Utility Interconnection Completion, 
 when -
 1. Submit Final Interconnection Date is populated on Service Contract Event 
*************************************************************************************************/
    public static void checkUtilityInterconnectionDate(List<Service_Contract_Event__c> list_sce,Boolean isInsert,
                                               Boolean isupdate,map<id,Service_Contract_Event__c> old_Map){

        map<Id,String> sceProjectTypeMap = new map<Id,String>();
        map<Id,List<Id>> sceToRecipientMap = new map<Id,List<Id>>();
        map<Id,List<String>> sceCCRecipientMap = new map<Id,List<String>>();
        map<Id,String> sceIdPPEmailIdMap = new map<Id,String>();
        map<Id,map<String,String>> sceWhereClauseFieldValueMap = new map<Id,map<String,String>>();
        map<Id,String> sceSalesPartnerGenericEmailMap = new map<Id,String>();
        List<Service_Contract_Event__c> sceList = new List<Service_Contract_Event__c>();
        Set<Id> sceIdSet = new Set<Id>();
        Integer daysInPastLimit = 0; 
        
        daysInPastLimit = Integer.valueOf(SCE_Email_Status__c.getValues('Utility Interconnection').No_Of_Days_In_Past_Limit__c);        
        
        System.debug('list_sce :' +list_sce);
        for (Service_Contract_Event__c sce : list_sce) {
            If ((sce.Submit_Final_Interconnection__c != null && sce.Submit_Final_Interconnection__c >= (date.today() - daysInPastLimit) && 
                !checkRecursive.utilityInterconnectionIds.contains(sce.id)) &&
                (Trigger.isInsert || 
                (Trigger.isUpdate && 
                (sce.Submit_Final_Interconnection__c != null && old_Map.get(sce.id).Submit_Final_Interconnection__c == null)))){
                
                checkRecursive.utilityInterconnectionIds.add(sce.id);               
                sceIdSet.add(sce.id);
            }
        }   
        
        if(!sceIdSet.isEmpty()){
            sceList = [Select Id, Project_Manager__c, Project_Manager_Email__c, Service_Contract__r.ContactId, 
                              Service_Contract__r.Opportunity__r.Opportunity_Source_Type__c, Service_Contract__r.Utility_Company__c, 
                              Service_Contract__r.Opportunity__r.Salesrep__c, Service_Contract__r.Opportunity__r.Salesrep__r.Email,
                              Service_Contract__r.Opportunity__r.Sales_Representative__c, Service_Contract__r.Opportunity__r.Preferred_Language__c, Service_Contract__r.Opportunity__r.Sales_Representative__r.Email,
                              Opportunity__c
                        From Service_Contract_Event__c
                        Where id in :sceIdSet]; 


            if(!sceList.isEmpty()){ 
                sceProjectTypeMap = getProjectType(sceList);
                System.debug('sceProjectTypeMap : ' +sceProjectTypeMap);
                sceToRecipientMap = getToRecipientList(sceList);
                System.debug('sceToRecipientMap : ' +sceToRecipientMap);
                sceSalesPartnerGenericEmailMap = getSalesPartnerGenericEmail(sceList); 
                sceCCRecipientMap = getCCRecipientList(sceList, sceSalesPartnerGenericEmailMap);
                sceIdPPEmailIdMap = getReplyToEmailId(sceList);
                sceWhereClauseFieldValueMap = getSceWhereClauseFieldValue(sceList);
            
                for(Service_Contract_Event__c sce : sceList){ 
                     if (sce.Service_Contract__r.Opportunity__r.Preferred_Language__c == 'Spanish'){
                        System.debug('recipientList :' +sceToRecipientMap.get(sce.Id));
                        System.debug('CCList : ' +sceCCRecipientMap.get(sce.Id));
                        CustomEmailManager.communicateScheduledEvent(sceWhereClauseFieldValueMap.get(sce.Id), 
                                                                     'Utility Interconnection Direct Spanish', sceToRecipientMap.get(sce.Id),sceCCRecipientMap.get(sce.Id),
                                                                     'Sunrun Project Planner' , sceIdPPEmailIdMap.get(sce.Id),null);             
                    }                    

                    else if (sceProjectTypeMap.get(sce.Id) == 'Direct' && sceIdPPEmailIdMap.containsKey(sce.Id)){
                        System.debug('recipientList :' +sceToRecipientMap.get(sce.Id));
                        System.debug('CCList : ' +sceCCRecipientMap.get(sce.Id));
                        CustomEmailManager.communicateScheduledEvent(sceWhereClauseFieldValueMap.get(sce.Id), 
                                                                     'Utility Interconnection Direct', sceToRecipientMap.get(sce.Id),sceCCRecipientMap.get(sce.Id),
                                                                     'Sunrun Project Planner' , sceIdPPEmailIdMap.get(sce.Id),null);             
                    } else {
                        System.debug('recipientList :' +sceToRecipientMap.get(sce.Id));
                        CustomEmailManager.communicateScheduledEvent(sceWhereClauseFieldValueMap.get(sce.Id), 
                                                                     'Utility Interconnection EPC', sceToRecipientMap.get(sce.Id), sceCCRecipientMap.get(sce.Id),
                                                                      null, null,'pc@sunrun.com');             
                    }
                }//End-For 
            } //End-If
        } //End-If    
    }           

/************************************************************************************************
 Email is sent out Customer and Sales Rep informing about PTO, 
 when -
 1. PTO Date is populated on Service Contract Event 
*************************************************************************************************/
    public static void checkPTODate(List<Service_Contract_Event__c> list_sce,Boolean isInsert,
                                               Boolean isupdate,map<id,Service_Contract_Event__c> old_Map){

        map<Id,String> sceProjectTypeMap = new map<Id,String>();
        map<Id,List<Id>> sceToRecipientMap = new map<Id,List<Id>>();
        map<Id,List<String>> sceCCRecipientMap = new map<Id,List<String>>();
        map<Id,String> sceIdPPEmailIdMap = new map<Id,String>();
        map<Id,map<String,String>> sceWhereClauseFieldValueMap = new map<Id,map<String,String>>();
        map<Id,String> sceSalesPartnerGenericEmailMap = new map<Id,String>();
        List<Service_Contract_Event__c> sceList = new List<Service_Contract_Event__c>();
         map <Id,String> scecost = new map<Id,String>();
        Set<Id> sceIdSet = new Set<Id>();                                          
        Integer daysInPastLimit = 0; 
        
        daysInPastLimit = Integer.valueOf(SCE_Email_Status__c.getValues('PTO').No_Of_Days_In_Past_Limit__c);                
        
        System.debug('list_sce :' +list_sce);
        for (Service_Contract_Event__c sce : list_sce) {
            If ((sce.PTO__c != null && sce.PTO__c >= (date.today() - daysInPastLimit) &&
                !checkRecursive.ptoIds.contains(sce.id)) &&
                (Trigger.isInsert || 
                (Trigger.isUpdate && 
                (sce.PTO__c != null && old_Map.get(sce.id).PTO__c == null)))){
                
                checkRecursive.ptoIds.add(sce.id);               
                sceIdSet.add(sce.id);
            }
        }   
        
        if(!sceIdSet.isEmpty()){
            sceList = [Select Id, Project_Manager__c, Project_Manager_Email__c, Service_Contract__r.ContactId, 
                              Service_Contract__r.Opportunity__r.Opportunity_Source_Type__c, Service_Contract__r.Utility_Company__c, 
                              Service_Contract__r.Opportunity__r.Salesrep__c, Service_Contract__r.Opportunity__r.Salesrep__r.Email,
                              Service_Contract__r.Opportunity__r.Sales_Representative__c, Service_Contract__r.Opportunity__r.Preferred_Language__c, Service_Contract__r.Opportunity__r.Sales_Representative__r.Email,
                              Service_Contract__r.Cost_Stack__c, Opportunity__c 
                        From Service_Contract_Event__c
                        Where id in :sceIdSet]; 


            if(!sceList.isEmpty()){
                for(Service_Contract_Event__c SCE: sceList)
                {
                   scecost.put(SCE.Id, SCE.Service_Contract__r.Cost_Stack__c);
                 }
                sceProjectTypeMap = getProjectType(sceList);
                System.debug('sceProjectTypeMap : ' +sceProjectTypeMap);
                sceToRecipientMap = getToRecipientList(sceList);
                System.debug('sceToRecipientMap : ' +sceToRecipientMap);
                sceSalesPartnerGenericEmailMap = getSalesPartnerGenericEmail(sceList); 
                sceCCRecipientMap = getCCRecipientList(sceList, sceSalesPartnerGenericEmailMap);
                sceIdPPEmailIdMap = getReplyToEmailId(sceList);
                sceWhereClauseFieldValueMap = getSceWhereClauseFieldValue(sceList);
            
                for(Service_Contract_Event__c sce : sceList){ 
           if (sce.Service_Contract__r.Opportunity__r.Preferred_Language__c == 'Spanish'){
                        System.debug('recipientList :' +sceToRecipientMap.get(sce.Id));
                        System.debug('CCList : ' +sceCCRecipientMap.get(sce.Id));
                        CustomEmailManager.communicateScheduledEvent(sceWhereClauseFieldValueMap.get(sce.Id), 
                                                                     'PTO Direct Spanish', sceToRecipientMap.get(sce.Id),sceCCRecipientMap.get(sce.Id),
                                                                     'Sunrun Project Planner' , sceIdPPEmailIdMap.get(sce.Id),null);             
                  }         
           else if (sceProjectTypeMap.get(sce.Id) == 'Direct' && sceIdPPEmailIdMap.containsKey(sce.Id)){
                        System.debug('recipientList :' +sceToRecipientMap.get(sce.Id));
                        System.debug('CCList : ' +sceCCRecipientMap.get(sce.Id));
                        CustomEmailManager.communicateScheduledEvent(sceWhereClauseFieldValueMap.get(sce.Id), 
                                                                     'PTO Direct', sceToRecipientMap.get(sce.Id),sceCCRecipientMap.get(sce.Id),
                                                                     'Sunrun Project Planner' , sceIdPPEmailIdMap.get(sce.Id),null);             
                    } else if(scecost.get(sce.Id) != 'INTEGRATED') {
                        System.debug('recipientList :' +sceToRecipientMap.get(sce.Id));
                        CustomEmailManager.communicateScheduledEvent(sceWhereClauseFieldValueMap.get(sce.Id), 
                                                                     'PTO EPC', sceToRecipientMap.get(sce.Id), sceCCRecipientMap.get(sce.Id),
                                                                      null, null,'pc@sunrun.com');             
                    }
                }//End-For
            } //End-If
        } //End-If    
    }
/************************************************************************************************
 Email is sent out Customer and Sales Rep informing about CAP, 
 when -
 1. CAP Date is populated on Service Contract Event 
*************************************************************************************************/
    public static void checkCAPDate(List<Service_Contract_Event__c> list_sce, Boolean isInsert,
                                      Boolean isupdate,map<id,Service_Contract_Event__c> old_Map){
    
        map<Id,String> sceProjectTypeMap = new map<Id,String>();
        map<Id,List<Id>> sceToRecipientMap = new map<Id,List<Id>>();
        map<Id,List<String>> sceCCRecipientMap = new map<Id,List<String>>();
        map<Id,String> sceIdPPEmailIdMap = new map<Id,String>();
        map<Id,map<String,String>> sceWhereClauseFieldValueMap = new map<Id,map<String,String>>();
        map<Id,String> sceSalesPartnerGenericEmailMap = new map<Id,String>();
        set<Id> sceIdset = new Set<Id>();
        List<Service_Contract_Event__c> scelist = new List<Service_Contract_Event__c>();
        Integer daysInPastLimit = 0;
        
        daysInPastLimit = Integer.valueOf(SCE_Email_Status__c.getValues('CAP').No_Of_Days_In_Past_Limit__c);
        
        for(Service_Contract_Event__c sce : list_sce){
            if(sce.CAP_date_approved__c != null && sce.CAP_date_approved__c >= (date.today()-daysInPastLimit) &&
               !checkRecursive.capids.contains(sce.id) &&
               (Trigger.isInsert || 
               (Trigger.isUpdate && sce.CAP_date_approved__c !=null && old_map.get(sce.id).CAP_date_approved__c == null))){
               
               checkRecursive.capids.add(sce.id);
               sceIdset.add(sce.id);       
               }
        }
        if(!sceIdset.isEmpty()){
            scelist = [Select Id, Project_Manager__c, Project_Manager_Email__c, Service_Contract__r.ContactId,
                      Service_Contract__r.Opportunity__r.Opportunity_Source_Type__c, Service_Contract__r.Utility_Company__c,
                      Service_Contract__r.Opportunity__r.Salesrep__c, Service_Contract__r.Opportunity__r.Salesrep__r.Email,
                      Service_Contract__r.Opportunity__r.Sales_Representative__c, Service_Contract__r.Opportunity__r.Sales_Representative__r.Email,
                      Service_Contract__r.Opportunity__r.Preferred_Language__c,
                      Opportunity__c
                      From Service_Contract_Event__c
                      Where Id in : sceIdset];
        
          if(!scelist.isEmpty()){
              sceProjectTypeMap = getProjectType(scelist);
              sceToRecipientMap = getToRecipientList(scelist);
              sceSalesPartnerGenericEmailMap = getSalesPartnerGenericEmail(scelist);
              sceCCRecipientMap = getCCRecipientList(scelist,sceSalesPartnerGenericEmailMap);
              sceIdPPEmailIdMap = getReplyToEmailId(scelist);
              sceWhereClauseFieldValueMap = getSceWhereClauseFieldValue(scelist);
              
              for(Service_Contract_Event__c sce : scelist){
               if(sce.Service_Contract__r.Opportunity__r.Preferred_Language__c == 'Spanish'){
                CustomEmailManager.communicateScheduledEvent(sceWhereClauseFieldValueMap.get(sce.Id),
                                                              'CAP Direct Spanish', sceToRecipientMap.get(sce.Id), sceCCRecipientMap.get(sce.Id),
                                                              'Sunrun Project Planner', sceIdPPEmailIdMap.get(sce.Id), null); 
               }
               else{    
                if(sceProjectTypeMap.get(sce.Id) == 'Direct' && sceIdPPEmailIdMap.containsKey(sce.Id)){
                 CustomEmailManager.communicateScheduledEvent(sceWhereClauseFieldValueMap.get(sce.Id),
                                                              'CAP Direct', sceToRecipientMap.get(sce.Id), sceCCRecipientMap.get(sce.Id),
                                                              'Sunrun Project Planner', sceIdPPEmailIdMap.get(sce.Id), null);
                }
                else{
                 CustomEmailManager.communicateScheduledEvent(sceWhereClauseFieldValueMap.get(sce.Id),
                                                              'CAP EPC', sceToRecipientMap.get(sce.Id), sceCCRecipientMap.get(sce.Id),
                                                              null, null, 'pc@sunrun.com');
                }
               } 
              }
          
          }
        }
    }
                   
/************************************************************************
  This mentod determines the Project Type of each Service Contract.
  Project Type - 
    1. Direct: If both Sales Partner and Install Partner are Sunrun
    2. EPC: If both Sales Partner and Install Partner are not Sunrun  
*************************************************************************/
    private static map <Id,String> getProjectType(List<Service_Contract_Event__c> sceList){
        map <Id,String> sceProjectTypeMap = new map<Id,String>();
        map <Id,Id> sceIdOpptyIdMap = new map<Id,Id>();
        boolean ipSunrun; 

        for(Service_Contract_Event__c sce: sceList){
            sceIdOpptyIdMap.put(sce.Opportunity__c, sce.Id); 
        }
        ipSunrun = false;
        
       for(Partner_Role__c pr: [Select Role__c, Partner_Name__c, Opportunity__c 
                                   from Partner_Role__c 
                                  where Opportunity__c in :sceIdOpptyIdMap.keySet()
                                and Role__c in ('Install')]){
        
      
            ipSunrun = false;
            if (pr.Partner_Name__c == System.label.sunrun_inc_Id){
                ipSunrun = true;    
            }

            if (ipSunrun == true){
                sceProjectTypeMap.put(sceIdOpptyIdMap.get(pr.Opportunity__c), 'Direct');
            } else {
                sceProjectTypeMap.put(sceIdOpptyIdMap.get(pr.Opportunity__c), 'EPC');
            }

        }//End-For
        
        return sceProjectTypeMap;
    }

/************************************************************************
   This method gets the list of (To) recipients for each Service Contract
*************************************************************************/
    private static map<Id,List<Id>> getToRecipientList(List<Service_Contract_Event__c> sceList){
        Set<Id> sceIdSet = new Set<Id>(); 
        List<Id> recipientList = new List<Id>(); 
        List<Id> tempRecipientList = new List<Id>();
        map<Id,List<Id>> sceToRecipientMap = new map<Id,List<Id>>();
        
        for(Service_Contract_Event__c sce: sceList){
            if (sce.Service_Contract__r.ContactId != null){
               recipientList.add(sce.Service_Contract__r.ContactId);
            }   
              
            tempRecipientList = recipientList.clone();  
            sceToRecipientMap.put(sce.id,tempRecipientList);
            recipientList.clear();
        }    
        
        return sceToRecipientMap;
    }

/************************************************************************
  This mentod gets the Corporate Generic Email Address for Sales Partner
*************************************************************************/
    private static map <Id,String> getSalesPartnerGenericEmail(List<Service_Contract_Event__c> sceList){
        map <Id,String> sceSalesPartnerMap = new map<Id,Id>();
        map <Id,String> sceSalesPartnerGenericEmailMap = new map<Id,String>();
        map <Id,String> salesPartnerCorporateGenericEmailMap = new map<Id,String>();
        map <Id,Id> sceIdOpptyIdMap = new map<Id,Id>();
        boolean ipSunrun; 

        for(Service_Contract_Event__c sce: sceList){
            sceIdOpptyIdMap.put(sce.Opportunity__c, sce.Id); 
        }
        
        for(Partner_Role__c pr: [Select Role__c, Partner_Name__c, Opportunity__c 
                                   from Partner_Role__c 
                                  where Opportunity__c in :sceIdOpptyIdMap.keySet()
                                    and Role__c in ('Sales')]){

            sceSalesPartnerMap.put(sceIdOpptyIdMap.get(pr.Opportunity__c), pr.Partner_Name__c);
            
        }//End-For
        System.debug('Sales Partners :' +sceSalesPartnerMap.values());
        for(Account acct:[Select id, Corporate_Email_Address__c
                            from Account
                           Where id in :sceSalesPartnerMap.values()]){
            salesPartnerCorporateGenericEmailMap.put(acct.id, acct.Corporate_Email_Address__c);
            System.debug('Adding Corporate Generic Email Address');
        }

        System.debug('salesPartnerCorporateGenericEmailMap : ' +salesPartnerCorporateGenericEmailMap); 
        for(Id sceId: sceSalesPartnerMap.keySet()){
            sceSalesPartnerGenericEmailMap.put(sceId, salesPartnerCorporateGenericEmailMap.get(sceSalesPartnerMap.get(sceId)));  
        }
        
        System.debug('sceSalesPartnerGenericEmailMap :' +sceSalesPartnerGenericEmailMap);
        return sceSalesPartnerGenericEmailMap;
    }
    
/************************************************************************
   This method gets the list of (cc) recipients for each Service Contract
*************************************************************************/
    private static map<Id,List<Id>> getCCRecipientList(List<Service_Contract_Event__c> sceList, map<Id,String> sceSalesPartnerGenericEmailMap){
        List<Id> recipientList = new List<String>(); 
        List<Id> tempRecipientList = new List<String>();
        map<Id,List<String>> sceCCRecipientMap = new map<Id,List<String>>();
        
        for(Service_Contract_Event__c sce: sceList){
            System.debug('Oppty Source :' +sce.Service_Contract__r.Opportunity__r.Opportunity_Source_Type__c);
            if(sce.Service_Contract__r.Opportunity__r.Opportunity_Source_Type__c == 'BB'){
                recipientList.add(sce.Service_Contract__r.Opportunity__r.Salesrep__r.Email);
                System.debug('Adding Sales Rep Email to CCList :' +sce.Service_Contract__r.Opportunity__r.Salesrep__r.Email);
            }else if (sce.Service_Contract__r.Opportunity__r.Sales_Representative__c !=null){ 
                recipientList.add(sce.Service_Contract__r.Opportunity__r.Sales_Representative__r.Email);       
            }
            
            if (sceSalesPartnerGenericEmailMap.get(sce.id) != null){
                recipientList.add(sceSalesPartnerGenericEmailMap.get(sce.id));
                System.debug('Get Sales Partner Generic Email');
            }
            
            recipientList.add(Corporate_Generic_Email__c.getValues(System.label.sunrun_inc_Id).Email__c);

            tempRecipientList = recipientList.clone();   
            sceCCRecipientMap.put(sce.id,tempRecipientList);
            recipientList.clear();
        }
        System.debug('sceCCRecipientMap :' +sceCCRecipientMap);
        return sceCCRecipientMap;
    }

/************************************************************************
   This method gets the ReplyTo Email Id for each Service Contract. 
*************************************************************************/
    private static map<Id, String> getReplyToEmailId(List<Service_Contract_Event__c> sceList){
        map <Id,String> sceReplyToEmailIdMap = new map<Id,String>();
        for(Service_Contract_Event__c sce: sceList){
            if (sce.Project_Manager_Email__c != null && sce.Project_Manager_Email__c != ' '){ 
              sceReplyToEmailIdMap.put(sce.Id,sce.Project_Manager_Email__c);
            }
        }    

        return sceReplyToEmailIdMap;
    }

/************************************************************************
   This method creates the map of inputs required - 
   Service Contract Event ID 
   Utility Company 
*************************************************************************/

    private static map<Id, map<String,String>> getSceWhereClauseFieldValue(List<Service_Contract_Event__c> sceList){
        map<Id,map<String,String>> sceWhereClauseFieldValueMap = new map<Id,map<String,String>>();
        map<String,String> whereClauseFieldValueMap = new map<String,String>();
        map<String,String> tempWhereClauseFieldValueMap = new map<String,String>();
        Set<String> utilityCompanySet=new Set<String>();
        List<Service_Contract_Event__c> List_sce = new List<Service_Contract_Event__c>();
        set<Id> sceIds = new Set<Id>();
        /*
        for(Utility_Companies__c utc:Utility_Companies__c.getAll().values()){
            utilityCompanySet.add(utc.Name);
        }*/

        for(Utility_Timelines__c utc:[Select Name from Utility_Timelines__c]){
            utilityCompanySet.add(utc.Name);
        }
        for(Service_Contract_Event__c sce : sceList){
            sceIds.add(sce.Id);
        }
        List_sce = [select Id, Service_Contract__r.Opportunity__r.preferred_language__c, Service_Contract__r.Utility_Company__c from Service_Contract_Event__c where id in : sceIds];

        for(Service_Contract_Event__c sce: List_sce){
            whereClauseFieldValueMap.put('id', sce.id);
            
            if(sce.Service_Contract__r.Opportunity__r.preferred_language__c == 'Spanish'){
                whereClauseFieldValueMap.put('Utility', 'General Timeline Spanish');
            }
            else if(utilityCompanySet.contains(sce.Service_Contract__r.Utility_Company__c)){
                whereClauseFieldValueMap.put('Utility', sce.Service_Contract__r.Utility_Company__c);
            }
            else{
                whereClauseFieldValueMap.put('Utility', 'General Timeline');
            } 

            tempWhereClauseFieldValueMap =  whereClauseFieldValueMap.clone(); 
            System.debug('tempWhereClauseFieldValueMap :' +tempWhereClauseFieldValueMap);
            sceWhereClauseFieldValueMap.put(sce.id,tempWhereClauseFieldValueMap);
            whereClauseFieldValueMap.clear();
        }    
         
        System.debug('sceWhereClauseFieldValueMap :' +sceWhereClauseFieldValueMap);
        return sceWhereClauseFieldValueMap;
    }

    /* BSKY-6575 logic start */
    
    public static void CancellationStatus(Map<Id,ServiceContract> ServiceContractMap){
        map<Id,List<String>> sceToRecipientMap = new map<Id,List<String>>();
        map<Id,List<String>> sceBCCRecipientMap = new map<Id,List<String>>();
        map<Id,List<String>> sceToAddrRecipientMap = new map<Id,List<String>>();
        List<Service_Contract_Event__c> scelist = new List<Service_Contract_Event__c>();
        map<Id,map<String,String>> sceWhereClauseFieldValueMap = new map<Id,map<String,String>>();
        map<Id,String> sceIdPPEmailIdMap = new map<Id,String>();
        
        if(!ServiceContractMap.isEmpty()){
            sceList = [Select Id,Project_Manager__c, Project_Manager_Email__c, Sales_Rep_Email__c, Customer_s_Email__c, 
                       Service_Contract__r.Install_Partner__c,Service_Contract__r.ContactId,customer_signoff__c,Service_Contract__r.Customer_Name__c,Service_Contract__r.Customer_Mailing_Address__c,Service_Contract__r.City__c,Service_Contract__r.State__c,Service_Contract__r.Zip_Formula__c 
                       from service_contract_event__c where Service_Contract__c in : ServiceContractMap.keyset()];
        }
        
        if(!scelist.isEmpty()){
            System.debug('scelist Size ' + sceList.size() + sceList  );
            sceToRecipientMap = getToRecipientList(scelist);
            
            sceToAddrRecipientMap = getToAddrRecipientList(scelist);
            
            //  sceToAddrRecipientMap = getToAddrRecipientList(scelist);
            sceWhereClauseFieldValueMap = getSceWhereClauseFieldValue(scelist);
            
        }
        for(Service_Contract_Event__c sce: sceList)
        {
            // CustomEmailManager.CancelEvent(sceToRecipientMap.get(sce.Id),sceBCCRecipientMap.get(sce.Id),sceToAddrRecipientMap.get(sce.Id));
            
            CustomEmailManager.CommunicateCancelEvent(sceWhereClauseFieldValueMap.get(sce.Id),'Customer Agreement Cancellation',
                                                    sceToRecipientMap.get(sce.Id),sceToAddrRecipientMap.get(sce.Id),'Cancellations', 'cancellations@sunrun.com', null );
            
        }
    }
    
    /**********************************************************************************************************************
		This method gets the list of (TO) recipients for each Service Contract when service contract status is Deal Cancelled
	************************************************************************************************************************/
    private static map<Id,List<Id>> getToAddrRecipientList(List<Service_Contract_Event__c> sceList){
        List<Id> recipientList = new List<String>(); 
        List<Id> tempRecipientList = new List<String>();
        map<Id,List<String>> sceCCRecipientMap = new map<Id,List<String>>();
        
        for(Service_Contract_Event__c sce: sceList){
            
            /* if(sce.Customer_s_Email__c != Null){
				recipientList.add(sce.Customer_s_Email__c);           
			} */
            
            if(sce.Service_Contract__r.Install_Partner__c == 'Sunrun'){
                if(sce.Sales_Rep_Email__c != null)
                    recipientList.add(sce.Sales_Rep_Email__c);
                if(sce.Project_Manager_Email__c != null)
                    recipientList.add(sce.Project_Manager_Email__c);
            } 
            
            tempRecipientList = recipientList.clone();   
            sceCCRecipientMap.put(sce.id,tempRecipientList);
            recipientList.clear();
        }
        System.debug('sceCCRecipientMap :' +sceCCRecipientMap);
        return sceCCRecipientMap;
    }
    
    
    /* BSKY-6575 logic End */

}