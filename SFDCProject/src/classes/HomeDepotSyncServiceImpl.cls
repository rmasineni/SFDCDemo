/*
**
**
*/

public class HomeDepotSyncServiceImpl extends BaseClass implements HomeDepotSyncService {
    public static final String HomeDepot = 'Home Depot';
    public String authToken;
    
    /**
     * To be called Before/After and Insert/Update triggers. Implements the process to sync
     * the lead to Home Depot.
     */
    public void handleLeadsTrigger() {
        
        //In before insert/update trigger, we will need to check if this lead is applicable for home depot sync.
        //If yes set the external sync system as Home Depot and update the status as appropriate.
        if (isBeforeInsert()) {
            for (Sobject sobj : Trigger.new) {
                Lead lead = (Lead) sobj;
                
                //if (isHomeDepotLead(lead) && isHomeDepotLeadReadyToSync(lead)) {
                if (isHomeDepotLead(lead)) {    
                    lead.External_Sync_System__c = HomeDepot;
                    lead.External_Sync_Status__c = BaseClass.Status_ToBeSynced;
                    lead.External_Sync_InProgress__c = false;
                    lead.External_Sync_Batch_ID_Outbound__c = '';
                    checkRecursive.homeDepotLeadIds.add(lead.id);
                } else {
                    info('Lead is not applicable for Home depot due to its channel [' + lead.Channel__c 
                         + '] and retail lead source [' + lead.Retail_Lead_Source__c + '].');
                }
            }
        }
        
        //If this is lead update, check if intended fields are updated. If yes then mark
        //such lead for syncing.        
        if (isBeforeUpdate()) {
            for (Integer i = 0; i < Trigger.new.size(); i++) {
                Lead oldLead = (Lead) Trigger.old.get(i);
                Lead newLead = (Lead) Trigger.new.get(i);
                
                //if (isHomeDepotLead(newLead) && isHomeDepotLeadReadyToSync(newLead) &&
                if (isHomeDepotLead(newLead) &&
                    !checkRecursive.homeDepotLeadIds.contains(newLead.id)) {
                    if (newLead.External_Sync_InProgress__c && isHomeDepotLeadChanged(oldLead, newLead)) {
                        //newLead.External_Sync_InProgress__c = false;
                        newLead.External_Sync_Status__c = BaseClass.Status_UpdatedDuringSync;
                        checkRecursive.homeDepotLeadIds.add(newLead.id);
                    } else if (isHomeDepotLeadChanged(oldLead, newLead)) {
                        newLead.External_Sync_System__c = HomeDepot;
                        newLead.External_Sync_Status__c = BaseClass.Status_ToBeSynced;
                        newLead.External_Sync_InProgress__c = false;
                        newLead.External_Sync_Batch_ID_Outbound__c = '';
                        checkRecursive.homeDepotLeadIds.add(newLead.id);
                    } 
                } else {
                    info('Lead is not applicable for syncing with Home Depot');
                }
            }
        }

        if ( isAfterUpdate() ) {
            List<API_Request_Log__c> apiReqList = new List<API_Request_Log__c>(); 
            for (Integer i = 0; i < Trigger.new.size(); i++) {
                Lead oldLead = (Lead) Trigger.old.get(i);
                Lead newLead = (Lead) Trigger.new.get(i);
                
                if (isHomeDepotLead(newLead) && !checkRecursive.homeDepotAPIReqLeadIds.contains(newLead.id) &&
                    oldLead.External_Sync_InProgress__c == false && newLead.External_Sync_InProgress__c == true &&
                    newLead.External_Sync_Status__c == BaseClass.Status_ToBeSynced){
                    
                    API_Request_Log__c apiReq = new API_Request_Log__c(); 
                    apiReq.Object_Name__c = 'lead';
                    apiReq.Prospect_Id__c = newLead.Prospect_Id__c; 
                    apiReq.External_Sync_System__c = newLead.External_Sync_System__c; 
                    apiReq.Request_Status__c = 'Ready To Look-up'; 
                    apiReq.Request_Type__c = 'HD Lead Look-up'; 
                    apiReq.Name = apiReq.Request_Type__c+apiReq.Prospect_Id__c; 
                    apiReqList.add(apiReq); 
                     
                    checkRecursive.homeDepotAPIReqLeadIds.add(newLead.id); 
                }
            }    

            insert apiReqList; 

        }
    }

    
    public void handleAPIRequestLogTrigger() {
        if ( isBeforeUpdate() ){
            for (Integer i = 0; i < Trigger.new.size(); i++) {
                API_Request_Log__c oldReq = (API_Request_Log__c) Trigger.old.get(i);
                API_Request_Log__c newReq = (API_Request_Log__c) Trigger.new.get(i); 
    
                if(newReq.External_Sync_System__c == 'Home Depot' && 
                   newReq.Request_Type__c == 'HD Lead Look-up' && 
                   newReq.Request_Status__c == 'Look-up In Progress' && 
                   newReq.Request_Status__c != oldReq.Request_Status__c){
                    // Look-up callout
                    System.debug('Before callout');
                    //lookupLeadOppty(newReq.Id);
                    String jobID = enqueueJobWithCheck(new HomeDepotLeadLookupQueueable(newReq.Id));
                    if(jobID == null){
                       newReq.Request_Status__c = 'Look-up Error'; 
                       newReq.Response_Details__c = 'Look-up request could not be submitted';
                    }
                    System.debug('After callout');
                }
            } 
        }
    }
    
    public void handleAPIRequestErrorLogTrigger(){
    
        for (Integer i = 0; i < Trigger.new.size(); i++) {
            
            API_Request_Log__c newReq = (API_Request_Log__c) Trigger.new.get(i); 
    
                if(newReq.External_Sync_System__c == 'Home Depot' && 
                   newReq.Request_Type__c == 'HD Error Look-up' &&
                   newReq.Request_Status__c == 'Look-up Error'){
                    // Look-up callout
                    System.debug('Before callout');
                    //lookupLeadOppty(newReq.Id);
                    String jobID = enqueueJobWithCheck(new HomeDepotErrorLookupQueueable(newReq.Id));
                    if(jobID == null){
                       system.debug('Job ID is NULL');
                    }
                    System.debug('After callout');
                }
        }
    
    }
    /**
     * To be called Before/After and Insert/Update triggers. Implements the process to sync
     * the Opportunities to Home Depot.
     */
    
    public void handleAccountsTrigger() {
    /*    
        Set<Id> accountIds = new Set<Id>();
        //If this is Account update, check if intended fields are updated. If yes then mark
        //such lead for syncing.        
        if (isAfterUpdate()) {
            for (Integer i = 0; i < Trigger.new.size(); i++) {
                Account oldAccount = (Account) Trigger.old.get(i);
                Account newAccount = (Account) Trigger.new.get(i);
                if (isHomeDepotAccount(newAccount) && isHomeDepotAccountChanged(oldAccount, newAccount)) {
                    accountIds.add(newAccount.Id);
                } else {
                   // info('Account is not applicable for home depot due to its channel [' + newOpportunity.Channel__c 
                    //     + '] and retail Account source [' + newOpportunity.Retail_Lead_Source__c + '].');
                }
            }

            if(!isEmptyCollection(accountIds)){
                List<Opportunity> opportunities = getHomeDepotOpportunitiesForAccounts(accountIds);
                if(!isEmptyCollection(opportunities)){
                    updateHomeDepotOpportunitiesForSync(opportunities);
                }
            }
            
            
        }
    */
    }


    /**
     * To be called Before/After and Insert/Update triggers. Implements the process to sync
     * the Contact to Home Depot.
     */
    public void handleContactsTrigger() {
        Set<Id> contactIds = new Set<Id>();
        //If this is lead update, check if intended fields are updated. If yes then mark
        //such lead for syncing.        
        if (isAfterUpdate()) {
            for (Integer i = 0; i < Trigger.new.size(); i++) {
                Contact oldContact = (Contact) Trigger.old.get(i);
                Contact newContact = (Contact) Trigger.new.get(i);
                
                if (isHomeDepotContact(newContact) && isHomeDepotContactChanged(oldContact, newContact)) {
                    contactIds.add(newContact.Id);
                } else {
                    //info('Contact is not applicable for home depot due to its channel [' + newContact.Channel__c 
                   //      + '] and retail Contact source [' + newContact.Retail_Lead_Source__c + '].');
                }
            }
            
            if(!isEmptyCollection(contactIds)){
                List<Opportunity> opportunities = getHomeDepotOpportunitiesForContacts(contactIds);
                if(!isEmptyCollection(opportunities)){
                    updateHomeDepotOpportunitiesForSync(opportunities);
                }
            }
        }
    }
    
    public void updateHomeDepotOpportunitiesForSync(List<Opportunity> opportunities){
        for(Opportunity optyObj : opportunities){
            if (optyObj.External_Sync_InProgress__c) {
                optyObj.External_Sync_Status__c = BaseClass.Status_UpdatedDuringSync;
            } else {
                optyObj.External_Sync_System__c = HomeDepot;
                optyObj.External_Sync_Status__c = BaseClass.Status_ToBeSynced;
                optyObj.External_Sync_InProgress__c = false;
                optyObj.External_Sync_Batch_ID_Outbound__c = '';
            }           
        }
        update opportunities;
    }


    /**
     * To be called Before/After and Insert/Update triggers. Implements the process to sync
     * the Opportunities to Home Depot.
     */
    public void handleOpportunitiesTrigger() {
        
        //In before insert/update trigger, we will need to check if this Opportunity is applicable for home depot sync.
        //If yes set the external sync system as Home Depot and update the status as appropriate.
        if (isBeforeInsert()) {
            for (Sobject sobj : Trigger.new) {
                Opportunity optyObj = (Opportunity) sobj;
                if (isHomeDepotOpportunity(optyObj)) {
                    if (optyObj.External_Sync_InProgress__c) {
                        optyObj.External_Sync_Status__c = BaseClass.Status_UpdatedDuringSync;
                        checkRecursive.homeDepotOpptyIds.add(optyObj.id);
                    } else{
                        optyObj.External_Sync_System__c = HomeDepot;
                        optyObj.External_Sync_Status__c = BaseClass.Status_ToBeSynced;
                        optyObj.External_Sync_InProgress__c = false;
                        checkRecursive.homeDepotOpptyIds.add(optyObj.id);
                    }
                } else {
                    info('Opportunity is not applicable for Home depot due to its channel [' + optyObj.Channel_2__c 
                         + '] and retail Opportunity source [' + optyObj.Retail_Lead_Source__c + '].');
                }
            }
        }
        
        //If this is Opportunity update, check if intended fields are updated. If yes then mark
        //such Opportunity for syncing.        
        if (isBeforeUpdate()) {
            for (Integer i = 0; i < Trigger.new.size(); i++) {
                Opportunity oldOpportunity = (Opportunity) Trigger.old.get(i);
                Opportunity newOpportunity = (Opportunity) Trigger.new.get(i);
                if (isHomeDepotOpportunity(newOpportunity) && 
                    !checkRecursive.homeDepotOpptyIds.contains(newOpportunity.id)) {
                    if (newOpportunity.External_Sync_InProgress__c && isHomeDepotOpportunityChanged(oldOpportunity, newOpportunity)) {
                        newOpportunity.External_Sync_Status__c = BaseClass.Status_UpdatedDuringSync;
                        checkRecursive.homeDepotOpptyIds.add(newOpportunity.id);
                    } else if (isHomeDepotOpportunityChanged(oldOpportunity, newOpportunity)) {
                        newOpportunity.External_Sync_System__c = HomeDepot;
                        newOpportunity.External_Sync_Status__c = BaseClass.Status_ToBeSynced;
                        newOpportunity.External_Sync_InProgress__c = false;
                        checkRecursive.homeDepotOpptyIds.add(newOpportunity.id);
                        System.debug('Modifiesd Object ...');
                    } 
                } else {
                    info('Opportunity is not applicable for home depot due to its channel [' + newOpportunity.Channel__c 
                         + '] and retail Opportunity source [' + newOpportunity.Retail_Lead_Source__c + '].');
                }
            }
        }

        if ( isAfterUpdate() ) {
            List<API_Request_Log__c> apiReqList = new List<API_Request_Log__c>(); 
            for (Integer i = 0; i < Trigger.new.size(); i++) {
                Opportunity oldOpportunity = (Opportunity) Trigger.old.get(i);
                Opportunity newOpportunity = (Opportunity) Trigger.new.get(i);
                System.debug('API Request Log Record is created0');
                System.debug('isHomeDepotOpportunity(newOpportunity) :' +isHomeDepotOpportunity(newOpportunity));
                System.debug('External_Sync_InProgress__c_Old : ' +oldOpportunity.External_Sync_InProgress__c);
                System.debug('External_Sync_InProgress__c_New : ' +newOpportunity.External_Sync_InProgress__c);
                System.debug('External_Sync_System__c : ' +newOpportunity.External_Sync_Status__c);

                if (isHomeDepotOpportunity(newOpportunity) && !checkRecursive.homeDepotAPIReqOptyIds.contains(newOpportunity.id) &&
                    oldOpportunity.External_Sync_InProgress__c == false && newOpportunity.External_Sync_InProgress__c == true &&
                    newOpportunity.External_Sync_Status__c == BaseClass.Status_ToBeSynced){
                    System.debug('API Request Log Record is created1');
                    API_Request_Log__c apiReq = new API_Request_Log__c(); 
                    apiReq.Object_Name__c = 'opportunity';
                    apiReq.Prospect_Id__c = newOpportunity.Prospect_Id__c; 
                    apiReq.External_Sync_System__c = newOpportunity.External_Sync_System__c; 
                    apiReq.Request_Status__c = 'Ready To Look-up'; 
                    apiReq.Request_Type__c = 'HD Lead Look-up'; 
                    apiReq.Name = apiReq.Request_Type__c+apiReq.Prospect_Id__c; 
                    apiReqList.add(apiReq); 
                     
                    checkRecursive.homeDepotAPIReqOptyIds.add(newOpportunity.id); 
                }
            }    

            insert apiReqList; 
            System.debug('API Request Log Record is created2');

        }
    }

    /*
    ** TODO:
    */
    /*
    public List<Opportunity> getHomeDepotOpportunitiesForAccounts(Set<Id> accountIds){
        Map<Id, Opportunity> optyMap = new Map<Id, Opportunity>();
        
        for(Opportunity optyObj : [Select Id, Channel_2__c,Prospect_Id__c, External_Id__c, External_Sync_Batch_ID_Outbound__c, External_Sync_InProgress__c,
                                                External_Sync_Status__c, External_Sync_Details__c, Lead_Source_2__c, StageName
                                                from Opportunity where accountId in :accountIds and Channel_2__c = 'Retail' and Lead_Source_2__c like '%Home Depot%']){
            optyMap.put(optyObj.Id, optyObj);
        }
        return optyMap.values();
    }

    */
    /*
    ** TODO:
    */
    public List<Opportunity> getHomeDepotOpportunitiesForContacts(Set<Id> contactIds){
        Map<Id, Opportunity> optyMap = new Map<Id, Opportunity>();
        
        for(OpportunityContactRole roleObj : [Select Id, Opportunity.Id, Opportunity.Channel_2__c, Opportunity.StageName,
                                                Opportunity.Prospect_Id__c, Opportunity.External_Id__c, Opportunity.External_Sync_Batch_ID_Outbound__c, Opportunity.External_Sync_InProgress__c,
                                                Opportunity.External_Sync_Status__c, Opportunity.External_Sync_Details__c, Opportunity.Lead_Source_2__c
                                                from OpportunityContactRole where contactId in :contactIds and isPrimary = true and
                                                Opportunity.Channel_2__c = 'Retail' and Opportunity.Lead_Source_2__c like '%Home Depot%']){
            optyMap.put(roleObj.Opportunity.Id, roleObj.Opportunity);
        }
        return optyMap.values();
    }


    /**
     * Syncs the given leads to Home Depot system. Whether lead is already created or updated in Home Depot depends
     * on the External_Id__c field. If this field has value, then that value is considered as 
     * Home depot Lead id and that is updated.
     */
    public void syncLeads(List<Id> leadIds) {
        
    }
    public void syncLeads(List<Lead> leads) {
        
    }
    
    public void syncLeads(String sunrunBatchId, List<Lead> leads) {
        if (!isHomeDepotLeadSyncEnabled()) {
            info('Home Depot Lead Sync is not enabled in the Settings [HomeDepotLeadSyncEnabled] and hence not syncing.');
            return;
        }
        
        String batchId = '';
        String syncStatus = '';
        String exceptionDetails = '';
        if(!isEmptyCollection(leads)){
            try{
                JsonReader reader = homeDepotHttpPost(getLeadCreateUrl(), getCreateLeadRequestBody(sunrunBatchId, leads));
                syncStatus = BaseClass.Status_SyncSuccess;
                batchId = reader.getString('SFILEADPOBATCHICONX_Output.ReceivedBatchQueueID');
                for (Lead lead : leads) {
                    lead.External_Sync_Batch_ID_Outbound__c = sunrunBatchId;
                    lead.External_Sync_Batch_ID_Inbound__c = batchId;
                    lead.External_Sync_Details__c = null;
                    lead.External_Sync_InProgress__c = true;
                }
            }catch (Exception e) {
                syncStatus = BaseClass.Status_SyncError;
                exceptionDetails = getExceptionDetails(e);          
                for (Lead lead : leads) {
                    lead.External_Sync_Status__c = syncStatus;
                    lead.External_Sync_Details__c = exceptionDetails;
                }           
            }
            update leads;
        }
        
    }
    
    /*
    ** TODO:
    **
    */
    public void syncOpportunities(List<Opportunity> opportunities) {
        
    }
    public void syncOpportunities(String sunrunBatchId, List<Opportunity> opportunities) {
        if (!isHomeDepotLeadSyncEnabled()) {
            info('Home Depot Lead Sync is not enabled in the Settings [HomeDepotLeadSyncEnabled] and hence not syncing.');
            return;
        }
        
        String batchId = '';
        String syncStatus = '';
        String exceptionDetails = '';
        if(!isEmptyCollection(opportunities)){
            try{
                JsonReader reader = homeDepotHttpPost(getLeadCreateUrl(), getCreateLeadRequestBody(sunrunBatchId, opportunities));
                syncStatus = BaseClass.Status_SyncSuccess;
                batchId = reader.getString('SFILEADPOBATCHICONX_Output.ReceivedBatchQueueID');
                for (Opportunity optyObj : opportunities) {
                    optyObj.External_Sync_InProgress__c = true;
                    optyObj.External_Sync_Batch_ID_Outbound__c = sunrunBatchId;
                    optyObj.External_Sync_Batch_ID_Inbound__c = batchId;
                    optyObj.External_Sync_Details__c = null;
                }
            }catch (Exception e) {
                syncStatus = BaseClass.Status_SyncError;
                exceptionDetails = getExceptionDetails(e);          
                for (Opportunity optyObj : opportunities) {
                    optyObj.External_Sync_Status__c = syncStatus;
                    optyObj.External_Sync_Details__c = exceptionDetails;
                }
            }
            update opportunities;
        }   
    
    }

    public void lookupLead(Id apiReqId, String batchNumber, String prospectId){
        if (!isHomeDepotLeadSyncEnabled()) {
            info('Home Depot Lead Sync is not enabled in the Settings [HomeDepotLeadSyncEnabled] and hence not syncing.');
        }
        
        Map<String, HomeDepotLeadLookupDto.LeadDTO> leadDTOMap;
        Boolean leadFound; 
        Boolean opptyFound;
        Datetime reqStartTime = Datetime.now();
        
        try{
            System.debug('lookupLeads---> 2');
            JsonReader reader = homeDepotHttpPost(getLeadLookupUrl(), getLookupLeadRequestBody(batchNumber, prospectId));
            HomeDepotLeadLookupDto lookupDTO = new HomeDepotLeadLookupDto(reader);
            System.debug('lookupLeads---> 3');
            if(lookupDTO != null){
                leadDTOMap = lookupDTO.leadDTOMap;
            }
 
           if(leadDTOMap != null && !leadDTOMap.isEmpty()){
                leadFound = false; 
                opptyFound = false;
                List<Lead> leadList = queryLeadsByProspectId(leadDTOMap.keySet());
                
                if (!leadList.isEmpty() && leadList.get(0) != null){
                    leadFound = true;
                    Lead leadObj = leadList.get(0);    
                    leadObj.External_ID__c = leadDTOMap.get(leadObj.Prospect_Id__c).externalId;
                    if(!String.isEmpty(leadObj.External_ID__c)){
                        leadObj.External_Sync_Status__c = (leadObj.External_Sync_Status__c == Status_UpdatedDuringSync) ? Status_ToBeSynced : Status_SyncSuccess;
                        leadObj.External_Sync_Details__c = null;
                        leadObj.External_Sync_Batch_ID_Outbound__c = '';
                        leadObj.External_Row_ID__c = leadDTOMap.get(leadObj.Prospect_Id__c).externalRowId;
                                
                    }else{
                        leadObj.External_Sync_Status__c = Status_ToBeSynced;
                        leadObj.External_Sync_Details__c = 'HomeDepot didn\'t return External Id ';
                    }
                    leadObj.External_Sync_InProgress__c = false;
                    leadObj.External_Created_DateTime__c = leadDTOMap.get(leadObj.Prospect_Id__c).createdDate;
                    update leadObj;
                }
    
        //If any leads are converted to Opportunities then update the external Id on the Opportunities. 
                
                if (leadFound == false){    
                
                    List<Opportunity> optyList = queryOpportunitiesByProspectId(leadDTOMap.keySet());
                    
                    if(!optyList.isEmpty() && optyList.get(0) != null){    
                        opptyFound = true; 
                        Opportunity optyObj = optyList.get(0); 
                        optyObj.External_ID__c = leadDTOMap.get(optyObj.Prospect_Id__c).externalId;
                          
                        if(!String.isEmpty(optyObj.External_ID__c)){
                            optyObj.External_Sync_Status__c = (optyObj.External_Sync_Status__c == Status_UpdatedDuringSync) ? Status_ToBeSynced : Status_SyncSuccess;
                            optyObj.External_Sync_Details__c = null;
                            optyObj.External_Sync_Batch_ID_Outbound__c = '';
                            optyObj.External_Row_ID__c = leadDTOMap.get(optyObj.Prospect_Id__c).externalRowId;
                               
                        }else{
                            optyObj.External_Sync_Status__c = Status_ToBeSynced;
                            optyObj.External_Sync_Details__c = 'HomeDepot didn\'t return External Id ';
    
                        }
                        optyObj.External_Sync_InProgress__c = false;
                        optyObj.External_Created_DateTime__c = leadDTOMap.get(optyObj.Prospect_Id__c).createdDate;
                        update optyObj; 
                    }
                }         

                if(leadFound || opptyFound){
                   List<API_Request_Log__c> apiReqList = queryAPIRequestLogById(new Set<Id>{apiReqId});
                   if(!apiReqList.isEmpty()){
                       API_Request_Log__c apiReq =  apiReqList.get(0);
                       apiReq.Request_Status__c = 'Look-up Success';  
                       apiReq.Request_Start_Time__c = reqStartTime;
                       apiReq.Request_End_Time__c = Datetime.now();
                       apiReq.Response_Details__c = String.valueOf(reader);
                      // apiReq.Response_Details__c = leadDTOMap.get(prospectId).externalId + '-->' + leadDTOMap.get(prospectId).firstname + '-->' + leadDTOMap.get(prospectId).lastname;
                       update apiReq; 
                   } 
                }
            }

        }catch (Exception e) {
            
            List<API_Request_Log__c> apiReqList = queryAPIRequestLogById(new Set<Id>{apiReqId});
            if(!apiReqList.isEmpty()){
                API_Request_Log__c apiReq =  apiReqList.get(0);
                apiReq.Request_Status__c = 'Look-up Error';  
                apiReq.Response_Details__c = getExceptionDetails(e);
                update apiReq; 
            }
        }
    }
    /**
     * TODO:    
     *
     */
    /*
    public Map<String, HomeDepotLeadLookupDto.LeadDTO> lookupLeads(String batchNumber, String prospectId) {
        return null;
        
        if (!isHomeDepotLeadSyncEnabled()) {
            info('Home Depot Lead Sync is not enabled in the Settings [HomeDepotLeadSyncEnabled] and hence not syncing.');
            return null;
        }
    
        String syncStatus = '';
        String exceptionDetails = '';    
        Map<String, HomeDepotLeadLookupDto.LeadDTO> leadDTOMap;
        try{
            System.debug('lookupLeads---> 2');
            JsonReader reader = homeDepotHttpPost(getLeadLookupUrl(), getLookupLeadRequestBody(batchNumber, prospectId));
            HomeDepotLeadLookupDto lookupDTO = new HomeDepotLeadLookupDto(reader);
            System.debug('lookupLeads---> 3');
            if(lookupDTO != null){
                leadDTOMap = lookupDTO.leadDTOMap;
            }
        }catch (Exception e) {
            syncStatus = BaseClass.Status_SyncError;
            exceptionDetails = getExceptionDetails(e);
        }

        if(leadDTOMap != null && !leadDTOMap.isEmpty()){
            system.debug('leadDTOMap ---> '+leadDTOMap);
            return leadDTOMap;
        }else{
            return null;
        }
    
    }

    public Map<String, HomeDepotLeadLookupDto.LeadDTO> lookupLeads(String batchNumber, String createdDateStart, String createdDateEnd) { 
        return null;
    }*/

    
    public void updateLeads(Map<String, Map<String, HomeDepotLeadLookupDto.LeadDTO>> batchIdLeadLookupDTO){
    /*    
            List<Lead> updtLeadsList = new List<Lead>();
            List<Opportunity> updtOpptysList = new List<Opportunity>();

            for (Map<String, HomeDepotLeadLookupDto.LeadDTO> leadDTOMap: batchIdLeadLookupDTO.values()){
                if(leadDTOMap != NULL && !leadDTOMap.isEmpty()){
                    List<Lead> leads = queryLeadsByProspectId(leadDTOMap.keySet());
                    Set<String> tempProspectIds = new Set<String>();
                    for(Lead leadObj : leads){
                        tempProspectIds.add(leadObj.Prospect_Id__c);
                        leadObj.External_ID__c = leadDTOMap.get(leadObj.Prospect_Id__c).externalId;
                        if(!String.isEmpty(leadObj.External_ID__c)){
                            leadObj.External_Sync_Status__c = (leadObj.External_Sync_Status__c == Status_UpdatedDuringSync) ? Status_ToBeSynced : Status_SyncSuccess;
                            leadObj.External_Sync_Details__c = null;
                            
                        }else{
                            leadObj.External_Sync_Status__c = Status_ToBeSynced;
                            leadObj.External_Sync_Details__c = 'HomeDepot didn\'t return External Id ';
                        }
                        leadObj.External_Sync_InProgress__c = false;
                        leadObj.External_Sync_Batch_ID_Outbound__c = '';
                        updtLeadsList.add(leadObj);
                    }
    
                    //If any leads are converted to Opportunities then update the external Id on the Opportunities. 
                    Set<String> dtoProspectIds = leadDTOMap.keySet();
                    dtoProspectIds.removeall(tempProspectIds);  
                    if(!isEmptyCollection(dtoProspectIds)){
                        List<Opportunity> optyList = queryOpportunitiesByProspectId(dtoProspectIds);
                        for(Opportunity optyObj : optyList){
                            optyObj.External_ID__c = leadDTOMap.get(optyObj.Prospect_Id__c).externalId;
                            
                            if(!String.isEmpty(optyObj.External_ID__c)){
                                optyObj.External_Sync_Status__c = (optyObj.External_Sync_Status__c == Status_UpdatedDuringSync) ? Status_ToBeSynced : Status_SyncSuccess;
                                optyObj.External_Sync_Details__c = null;
                                
                            }else{
                                optyObj.External_Sync_Status__c = Status_ToBeSynced;
                                optyObj.External_Sync_Details__c = 'HomeDepot didn\'t return External Id ';
                            }
                            optyObj.External_Sync_InProgress__c = false;
                            optyObj.External_Sync_Batch_ID_Outbound__c = '';
                            updtOpptysList.add(optyObj);
                        }

                    }           
                }
            }

            if(!isEmptyCollection(updtLeadsList)){
                update updtLeadsList;
            }

            if(!isEmptyCollection(updtOpptysList)){
                update updtOpptysList;
            }
    */        
    }
   
    /**
     * TODO:    
     *
     */
    public void lookupOpportunities(String batchNumber, String createdDate) {
    /*    
        if (!isHomeDepotLeadSyncEnabled()) {
            info('Home Depot Lead Sync is not enabled in the Settings [HomeDepotLeadSyncEnabled] and hence not syncing.');
            return;
        }
        
        String syncStatus = '';
        String exceptionDetails = '';       
        try{
            JsonReader reader = homeDepotHttpPost(getLeadLookupUrl(), getLookupLeadRequestBody(batchNumber, createdDate));
            HomeDepotLeadLookupDto lookupDTO = new HomeDepotLeadLookupDto(reader);
            if(lookupDTO != null){
                Map<String, HomeDepotLeadLookupDto.LeadDTO> leadDTOMap = lookupDTO.leadDTOMap;
                if(!leadDTOMap.isEmpty()){
                    List<Opportunity> opportunities = queryOpportunitiesByProspectId(leadDTOMap.keySet());
                    Set<String> tempProspectIds = new Set<String>();
                    for(Opportunity OptyObj : opportunities){
                        tempProspectIds.add(OptyObj.Prospect_Id__c);
                        OptyObj.External_ID__c = leadDTOMap.get(OptyObj.Prospect_Id__c).externalId;
                        OptyObj.External_Sync_Details__c = null;
                        OptyObj.External_Sync_InProgress__c = false;
                        OptyObj.External_Sync_Batch_ID_Outbound__c = '';
                        OptyObj.External_Sync_Status__c = (OptyObj.External_Sync_Status__c == Status_UpdatedDuringSync) ? Status_ToBeSynced : Status_SyncSuccess;
                    }
                    if(!isEmptyCollection(opportunities)){
                        update opportunities;
                    }       
                }
            }
        }catch (Exception e) {
            syncStatus = BaseClass.Status_SyncError;
            exceptionDetails = getExceptionDetails(e);
        }
        */
    }

    /**
     * TODO:    
     *
     */
    //public void errorLogLookup(String batchNumber, String createdDate) {
    public void errorLogLookup(String createdDate) {
        if (!isHomeDepotLeadSyncEnabled()) {
            info('Home Depot Lead Sync is not enabled in the Settings [HomeDepotLeadSyncEnabled] and hence not syncing.');
            return;
        }
        String syncStatus = '';
        String exceptionDetails = '';
        try{
            
            //JsonReader reader = homeDepotHttpPost(getErrorLogUrl(), getErrorLogRequestBody(batchNumber, createdDate));
            JsonReader reader = homeDepotHttpPost(getErrorLogUrl(), getErrorLogRequestBody(createdDate));
            system.debug('My Reader'+reader);
            HomeDepotErrorLookupDto ErrorlookupDTO = new HomeDepotErrorLookupDto(reader);
            if(ErrorlookupDTO != null){
                Map<String, String> ErrorDTOMap = ErrorlookupDTO.ErrorLookUpDTOMap;
                system.debug('-->ErrorDTOMAP'+ErrorDTOMap);
                if(!ErrorDTOMap.isEmpty()){
                    List<Lead> leads = queryLeadsByProspectId(ErrorDTOMap.keySet());
                    Set<String> tempProspectIds = new Set<String>();
                    for(Lead leadObj : leads){
                        tempProspectIds.add(leadObj.Prospect_Id__c);
                      if(leadObj.External_Sync_Status__c == BaseClass.Status_ToBeSynced && leadObj.External_Sync_InProgress__c == true){  
                        leadObj.External_Sync_Status__c = BaseClass.Status_SyncError;
                        if(ErrorDTOMap.containsKey(leadObj.Prospect_Id__c))
                        leadObj.External_Sync_Details__c = ErrorDTOMap.get(leadObj.Prospect_Id__c);                            
                        
                        leadObj.External_Sync_InProgress__c = false;
                        system.debug('Sync in progress'+leadObj.External_Sync_InProgress__c);
                      }
                    }
                    if(!isEmptyCollection(leads)){
                        update leads;
                    }
                    Set<String> dtoProspectIds = ErrorDTOMap.keySet();
                    dtoProspectIds.removeall(tempProspectIds);
                    if(!dtoProspectIds.isempty()){
                        List<Opportunity> optyList = queryOpportunitiesByProspectId(dtoProspectIds);
                        for(Opportunity optyObj : optyList){
                            if(optyObj.External_Sync_Status__c == BaseClass.Status_ToBeSynced && optyObj.External_Sync_InProgress__c == true){
                                optyObj.External_Sync_Status__c = BaseClass.Status_SyncError;
                                if(ErrorDTOMap.containsKey(optyObj.Prospect_Id__c))
                                optyObj.External_Sync_Details__c = ErrorDTOMap.get(optyObj.Prospect_Id__c);
                                
                                optyObj.External_Sync_InProgress__c = false;
                            }
                        }
                        if(!isEmptyCollection(optyList)){
                            update optyList;
                        }
                    }           
                }
            }
           
        }catch (Exception e) {
            System.debug('Exception .... ' + e);
            syncStatus = BaseClass.Status_SyncError;
            exceptionDetails = getExceptionDetails(e);
        }
    
    }

    public void addLeadFieldsToJSONWriter(String sunrunBatchId, Account accountObj, Contact contactObj, Opportunity optyObj, JsonWriter writer){
        /*
        if (String.isEmpty(optyObj.External_ID__c)) {
            writer.write('Id', optyObj.Prospect_Id__c);
        }else{
            writer.write('Id', optyObj.External_ID__c);      
        }*/
        
        if (String.isEmpty(optyObj.External_Row_ID__c)) {
            writer.write('Id', optyObj.Prospect_Id__c);
        }else{
            writer.write('Id', optyObj.External_Row_ID__c);      
        }  
           
        writer.write('ContactFirstName', contactObj.FirstName);
        writer.write('ContactLastName', contactObj.LastName);
        
        String tempPhone = (!String.isEmpty(contactObj.Phone)) ? contactObj.Phone : '';
        tempPhone = tempPhone.remove(' ').remove('-').remove('(').remove(')') ; 
        
        writer.write('MMSVPreferredContactPhoneNumber', tempPhone);
        //writer.write('MainEmailAddress', contactObj.Email);
        if(contactObj.Email == null){
            writer.write('MainEmailAddress','NA@NA.com');
        }else{    
            writer.write('MainEmailAddress', contactObj.Email);
        }
        
        writer.write('MMSVSiteAddress', accountObj.BillingStreet);
        writer.write('MMSVSiteCity', accountObj.BillingCity);
        writer.write('MMSVSiteCountry', accountObj.BillingCountry);
        writer.write('MMSVSiteCounty', accountObj.County__c);
        writer.write('MMSVSitePostalCode', accountObj.BillingPostalCode);
        writer.write('MMSVSiteState', accountObj.BillingState);
        
        writer.write('SFIMVendor', label.HomeDepot_SFIMVendor);
        
        writer.write('SFIProgramGroupNameUnconstrained', label.HomeDepot_SFIProgramGroupNameUnconstrained);
        writer.write('MMSVCSNeedAck', label.HomeDepot_MMSVCSNeedAck);
        writer.write('MMSVCSSubmitLeadFlag', label.HomeDepot_MMSVCSSubmitLeadFlag);
        writer.write('MMSVCSSVSTypeCode', label.HomeDepot_MMSVCSSVSTypeCode);
        System.debug('Retail Store Location : ' + optyObj.Lead_Organization_Location_2__r.AccountNumber);
        writer.write('MMSVStoreNumber', optyObj.Lead_Organization_Location_2__r.AccountNumber);
        writer.write('SFIReferralStore', optyObj.Lead_Organization_Location_2__r.AccountNumber);
        writer.write('MMSVCSServiceProviderOrderNumber ', optyObj.Prospect_Id__c);
        writer.write('SFIContractDate', (optyObj.CreatedDate).format('MM/dd/yyyy HH:mm:ss'));
        writer.write('MMSVCSLeadBatchNumber', sunrunBatchId);
        writer.write('SFIWorkflowOnlyStatus', getOpportunityStatus(optyObj.stagename)); 
        System.debug('Reason ----> ' +optyObj.reason__c);
        if (getOpportunityStatus(optyObj.stagename).equalsIgnoreCase('Cancelled')){
           writer.write('SFIStatusReason', getOpportunityStatusReason(optyObj.stagename, optyObj.Opportunity_Status__c, optyObj.reason__c)); 
        }   

    }


    public void addLeadFieldsToJSONWriter(String sunrunBatchId, Lead lead, JsonWriter writer){
        /*
        if (String.isEmpty(lead.External_ID__c)) {
            writer.write('Id', lead.Prospect_Id__c);
        }else{
            writer.write('Id', lead.External_ID__c);      
        }*/
         
        if (String.isEmpty(lead.External_Row_ID__c)) {
            writer.write('Id', lead.Prospect_Id__c);
        }else{
            writer.write('Id', lead.External_Row_ID__c);      
        }
         
        writer.write('ContactFirstName', lead.FirstName);
        writer.write('ContactLastName', lead.LastName);

        String tempPhone = (!String.isEmpty(lead.Phone)) ? lead.Phone : '';
        tempPhone = tempPhone.remove(' ').remove('-').remove('(').remove(')') ; 
        
        writer.write('MMSVPreferredContactPhoneNumber', tempPhone);
        
        if(lead.Email == null){
            writer.write('MainEmailAddress','NA@NA.com');
        }else{    
            writer.write('MainEmailAddress', lead.Email);
        } 
        //writer.write('MainEmailAddress', lead.Email);
        writer.write('MMSVSiteAddress', lead.Street);
        writer.write('MMSVSiteCity', lead.City);
        writer.write('MMSVSiteCountry', lead.Country);
        writer.write('MMSVSiteCounty', lead.County__c);
        writer.write('MMSVSitePostalCode', lead.PostalCode);
        writer.write('MMSVSiteState', lead.State);
        writer.write('SFIMVendor', label.HomeDepot_SFIMVendor);
        writer.write('SFIProgramGroupNameUnconstrained', label.HomeDepot_SFIProgramGroupNameUnconstrained);
        writer.write('MMSVCSNeedAck', label.HomeDepot_MMSVCSNeedAck);
        writer.write('MMSVCSSubmitLeadFlag', label.HomeDepot_MMSVCSSubmitLeadFlag);
        writer.write('MMSVCSSVSTypeCode', label.HomeDepot_MMSVCSSVSTypeCode);
        System.debug('Retail Store Location : ' + lead.Lead_Organization_Location_2__r.AccountNumber);
        writer.write('MMSVStoreNumber', lead.Lead_Organization_Location_2__r.AccountNumber);
        writer.write('SFIReferralStore', lead.Lead_Organization_Location_2__r.AccountNumber);
        writer.write('MMSVCSServiceProviderOrderNumber ', lead.Prospect_Id__c);
        writer.write('SFIContractDate', (lead.CreatedDate).format('MM/dd/yyyy HH:mm:ss'));
        writer.write('MMSVCSLeadBatchNumber', sunrunBatchId);       
        writer.write('SFIWorkflowOnlyStatus', getLeadStatus(lead.Status)); 
        if (getLeadStatus(lead.Status).equalsIgnoreCase('Cancelled')){
           writer.write('SFIStatusReason', getLeadStatusReason(lead.Status,lead.Lead_Status__c)); 
        }   
    }

    public String getCreateLeadRequestBody(String sunrunBatchId, List<Lead> leads) {
        JsonWriter writer = new JsonWriter();
        writer.ignoreNulls = true;
        writer.with('SFILEADPOBATCHICONX_Input.ListOfMmSvCsServiceProviderLeadInbound');
        for(Integer ii =0; ii < leads.size(); ii++){
            Lead leadObj = leads.get(ii);
            writer.with('MmSvCsServiceProviderLeadHeaderInbound[' + ii + ']');
            addLeadFieldsToJSONWriter(sunrunBatchId, leadObj, writer);
            writer.endWith();                      
        }
        System.debug('Writer : ' +writer); 
        return writer.toPrettyJson();
    }
    
    public String getCreateLeadRequestBody(String sunrunBatchId, List<Opportunity> opportunities) {
        List<Id> opportunityIds = new List<Id>();
        for(Opportunity optyObj : opportunities){
            opportunityIds.add(optyObj.Id);
        }
        Map<Id, Map<Id, OpportunityContactRole>> opportunityContactMap = getOpportunityRoleMap(opportunityIds);
        JsonWriter writer = new JsonWriter();
        writer.ignoreNulls = true;
        writer.with('SFILEADPOBATCHICONX_Input.ListOfMmSvCsServiceProviderLeadInbound');
        for(Integer ii =0; ii < opportunities.size(); ii++){
            Opportunity opty = opportunities.get(ii);
            Contact contactObj;
            Account accountObj = opty.account;
            Map<Id, OpportunityContactRole> roleMap = opportunityContactMap.get(opty.Id);
            
            if(roleMap != null && !roleMap.isEmpty()){
                for(OpportunityContactRole optyContactRoleObj : roleMap.values()){
                    System.debug('optyContactRoleObj: ' + optyContactRoleObj);

                    if(optyContactRoleObj.isPrimary == true){
                        contactObj = optyContactRoleObj.contact;
                        break;
                    }
                }
            } 
            writer.with('MmSvCsServiceProviderLeadHeaderInbound[' + ii + ']');
            //if (isHomeDepotOpptyReadyToSync(opty, accountObj, contactObj)){
                addLeadFieldsToJSONWriter(sunrunBatchId, accountObj, contactObj, opty, writer);
                writer.endWith();       
            //}
        }
        System.debug('Writer : ' +writer); 
        return writer.toPrettyJson();
    }
    
    public String getLookupLeadRequestBody(String batchId, String prospectId) {
        System.debug('Creating Look-Up Lead Body');
        JsonWriter writer = new JsonWriter();
        writer.ignoreNulls = true;
        String createdEndDate = '\'08/18/2015 15:00:00\'';
        
        writer.with('SFILEADLOOKUPWS_Input');
        writer.write('PageSize', '100');
        writer.with('ListOfSfileadbows.Sfileadheaderws[0]');
        String temp = '([SFI MVendor #] = \'50003780\' ';
        temp  += ' )';  
        system.debug(temp);  
        writer.write('Searchspec', temp);
        writer.write('MMSVCSLeadBatchNumber', batchId);
        writer.write('MMSVCSServiceProviderOrderNumber', prospectId);
        System.debug('Writer : ' +writer.toPrettyJson()); 
        return writer.toPrettyJson();       
    }

    //public String getErrorLogRequestBody(String batchId, String createdDate) {
    public String getErrorLogRequestBody(String createdDate) {
        system.debug('Created Date :'+createdDate);
        System.debug('Creating Error Log Body');
        JsonWriter writer = new JsonWriter();
        writer.ignoreNulls = true;
        
        writer.with('SFISPERRORLOGWS_Input');
        writer.write('PageSize', '100');
        writer.with('ListOfMmSvCsErrorLog.MmSvCsErrorLog[0]');
        //dateTime createdEndDate = createdDate.addHours(1);
        //dateTime createdEndDate = dateTime.parse(createdDate);
        //createdEndDate.addHours(1);
        List<string> stringparts = createdDate.split(' ');
        system.debug('stringparts'+stringparts);
        List<string> dateparts = stringparts[0].split('/');
        system.debug('dateparts'+dateparts);
        List<string> timeparts = stringparts[1].split(':');
        system.debug('timeparts'+timeparts);
        dateTime currentDateTime = dateTime.newInstance(Integer.valueOf(dateparts[2]), 
                                                    Integer.valueOf(dateparts[0]), 
                                                    Integer.valueOf(dateparts[1]), 
                                                    Integer.valueOf(timeparts[0]), 
                                                    Integer.valueOf(timeparts[1]), 
                                                    Integer.valueOf(timeparts[2]));
        system.debug('currentDateTime'+currentDateTime);
        dateTime nextHrTime = currentDateTime.addHours(1);
        system.debug('nextHrTime'+nextHrTime);
        
        string createdStartTime = currentDateTime.format('MM/dd/yyyy HH:mm:ss');
        system.debug('createdStartTime'+createdStartTime);
        string createdEndTime = nextHrTime.format('MM/dd/yyyy HH:mm:ss');
        system.debug('createdEndTime'+createdEndTime);
        
        //String temp = '([Error Name] = \'50003780\' ';
        String temp = '([Error Name]=\'50003780\' ';
        if(!String.isEmpty(createdStartTime)){
            //temp += ' AND [Created] >= ' + '\''+createdStartTime+'\' ';
            //temp += ' AND <= ' + '\''+createdEndTime+'\' ';
            temp += 'AND [Created]>='+ '\''+createdStartTime+'\'';
            //temp += ' AND <= ' + '\''+createdEndTime+'\' '; 
        }
        //temp  += ' )';
        temp  += ')';

        system.debug(temp);  
        writer.write('searchspec', temp);
        System.debug('Writer : ' +writer.toPrettyJson()); 
        return writer.toPrettyJson();       
    }

    public List<Opportunity> queryOpportunitiesByProspectId(Set<String> prospectIds) {
        if(isEmptyCollection(prospectIds)){
            return new List<Opportunity>();
        }else{
            return [
                select
                    Id,
                    StageName,
                    Prospect_Id__c,
                    External_Id__c, 
                    External_Sync_Batch_ID_Outbound__c,
                    External_Sync_Status__c,
                    External_Sync_Details__c,
                    External_Sync_InProgress__c,
                    Lead_Source_2__c
                from Opportunity
                where Prospect_Id__c in :prospectIds
            ];
        }
    }

    public List<Lead> queryLeadsByProspectId(Set<String> prospectIds) {
        if(isEmptyCollection(prospectIds)){
            return new List<Lead>();
        }else{
            return [
                select
                    FirstName,
                    LastName,
                    Title,
                    Street,
                    City,
                    State,
                    PostalCode,
                    Phone,
                    Alternate_Phone__c,
                    Email,
                    Notes__c,
                    Contact_Costco_Member_ID__c,
                    External_Id__c, 
                    Lead_Organization_Location_2__r.AccountNumber,
                    Prospect_Id__c,
                    External_Sync_Batch_ID_Outbound__c,
                    External_Sync_Status__c,
                    External_Sync_Details__c,
                    External_Sync_InProgress__c 
                from Lead
                where Prospect_Id__c in :prospectIds and isConverted = false
            ];
        }
    }

    public List<Lead> queryLeads(List<Id> leadIds) {
        
        return [
            select
                FirstName,
                LastName,
                Title,
                Street,
                City,
                State,
                PostalCode,
                Phone,
                Alternate_Phone__c,
                Email,
                Notes__c,
                Contact_Costco_Member_ID__c,
                External_Id__c, 
                Lead_Organization_Location_2__r.AccountNumber,
                Prospect_Id__c,
                External_Sync_Batch_ID_Outbound__c,
                External_Sync_Status__c,
                External_Sync_Details__c
            from Lead
            where id in :leadIds
        ];
    }
    
    public List<API_Request_Log__c> queryAPIRequestLogById(Set<Id> apiReqIds) {
        if(isEmptyCollection(apiReqIds)){
            return new List<API_Request_Log__c>();
        }else{
            return [select Id, 
                           Request_Status__c,
                           Request_Start_Time__c, 
                           Request_End_Time__c, 
                           Response_Details__c 
                      from API_Request_Log__c where Id in :apiReqIds]; 
        }
    }

    public JsonReader homeDepotHttpPost(String url, String body) {
        String userId = Sf.settingsService.getString('HomeDepotUserId');
        String password = Sf.settingsService.getString('HomeDepotPassword');
        Map<String, String> headers = new Map<String, String>{
            'appToken' => getAuthToken(),
            'x-clientid' => base64Encode(userId +':'+ password),
            'Content-Type' => 'application/json'
        };
        HttpDetails details = httpPostDetails(url, body, headers, 60000);        
        JsonReader jsonReader = new JsonReader(details.response.getBody());
        system.debug('-->jsonreader'+jsonreader);
        if(jsonReader.getString('Fault.faultCode') != null) {
            throw new UnsuccessfulHttpResponseException(details.request, details.response, details.requestHeaders);
        }
        
        return jsonReader;
    }
    
    public String getAuthToken() {
        if (authToken != null) {
            return authToken;
        }
        authToken = getOAuth2AccessToken(getOAuth2AuthzUrl(), Sf.settingsService.getString('HomeDepotOAuth2ClientId'),
            Sf.settingsService.getString('HomeDepotOAuth2ClientSecret'));
        
        return authToken;
    }
    
    public Boolean isHomeDepotLeadSyncEnabled() {
        return Sf.settingsService.getBoolean('HomeDepotLeadSyncEnabled', false);
    }

    public Boolean isHomeDepotLead(Lead lead) {
        return lead.Channel__c == 'Retail' && lead.custom_lead_source__c != null && lead.custom_lead_source__c.indexOf(HomeDepot) >= 0;
    }
    /*
    public Boolean isHomeDepotLeadChanged(Lead oldLead, Lead newLead) {
        return isChanged(oldLead, newLead, new String[]{'FirstName', 'LastName', 
            'Email', 'Phone', 'Street', 'City', 'State', 'PostalCode', 'Country', 
            'County__c', 'Status', 'Lead_Status__c', 'Lead_Organization_Location_2__c'});
    }*/

    public Boolean isHomeDepotLeadChanged(Lead oldLead, Lead newLead) {
        return isChanged(oldLead, newLead, new String[]{'Email', 'Status', 'Lead_Status__c'});
    }

    public Boolean isHomeDepotAccount(Account accountobj) {
        return true;
        //return accountobj.Channel__c == 'Retail' && accountobj.custom_lead_source__c != null && accountobj.custom_lead_source__c.indexOf(HomeDepot) >= 0;
    }

    public Boolean isHomeDepotContact(Contact contactObj) {
        return true;
        //return contactObj.Channel__c == 'Retail' && contactObj.custom_lead_source__c != null && contactObj.custom_lead_source__c.indexOf(HomeDepot) >= 0;
    }

    public Boolean isHomeDepotOpportunity(Opportunity opportunityObj) {
        return opportunityObj.Channel_2__c == 'Retail' && opportunityObj.Lead_Source_2__c != null && opportunityObj.Lead_Source_2__c.indexOf(HomeDepot) >= 0;
    }
    /*
    public Boolean isHomeDepotAccountChanged(Account oldAccount, Account newAccount) {
        return isChanged(oldAccount, newAccount, new String[]{'BillingStreet', 'BillingCity', 
            'BillingState', 'BillingCountry', 'BillingPostalcode', 'County__c'});
    }

    public Boolean isHomeDepotContactChanged(Contact oldContact, Contact newContact) {
        return isChanged(oldContact, newContact, new String[]{'FirstName', 'LastName', 'Email', 'Phone'});
    }*/

    public Boolean isHomeDepotContactChanged(Contact oldContact, Contact newContact) {
        return isChanged(oldContact, newContact, new String[]{'Email'});
    }

    public Boolean isHomeDepotLeadReadyToSync(Lead lead) {
        If(String.isEmpty(lead.FirstName) ||
           String.isEmpty(lead.LastName)  ||
           String.isEmpty(lead.Phone)     ||
  //       String.isEmpty(lead.Email)       ||
           String.isEmpty(lead.Street)    ||
           String.isEmpty(lead.City)      ||
           String.isEmpty(lead.Country)   ||
           String.isEmpty(lead.County__c) ||
           String.isEmpty(lead.Postalcode)||
           String.isEmpty(lead.State)     ||
           String.isEmpty(lead.Prospect_Id__c) ||
           lead.Lead_Organization_Location_2__c == null){
              return false; 
        }

        return true;
    }

    public Boolean isHomeDepotOpptyReadyToSync(Opportunity opptyObj, Account acctObj, Contact contactObj) {
        If(String.isEmpty(contactObj.FirstName)     ||
           String.isEmpty(contactObj.LastName)      ||
           String.isEmpty(contactObj.Phone)         ||
  //       String.isEmpty(contactObj.Email)         ||
           String.isEmpty(acctObj.BillingStreet)    ||
           String.isEmpty(acctObj.BillingCity)      ||
           String.isEmpty(acctObj.BillingCountry)   ||
           String.isEmpty(acctObj.BillingPostalcode)||
           String.isEmpty(acctObj.BillingState)     ||
           String.isEmpty(acctObj.County__c)        ||
           String.isEmpty(opptyObj.Prospect_Id__c)  ||
           opptyObj.Lead_Organization_Location_2__c == null){
              return false; 
        }

        return true;
    }
    /*
    public Boolean isHomeDepotOpportunityChanged(Opportunity oldOpportunity, Opportunity newOpportunity) {
        System.debug('oldOpportunity.stagename : ' + oldOpportunity.stagename);
        System.debug('newOpportunity.stagename : ' + newOpportunity.stagename);
        Boolean result = isChanged(oldOpportunity, newOpportunity, new String[]{'stagename', 'Lead_Organization_Location_2__c'});
        System.debug('Result ... ' + result);
        
        return result;
    }*/

    public Boolean isHomeDepotOpportunityChanged(Opportunity oldOpportunity, Opportunity newOpportunity) {
        
        Boolean result = isChanged(oldOpportunity, newOpportunity, new String[]{'stagename', 'Opportunity_Status__c', 'Reason__c'});
        System.debug('Result ... ' + result);
        
        return result;
    }

    public String getLeadCreateUrl() {
        return Sf.settingsService.getString('HomeDepotCreateLeadUrl',
            isSandbox()?'https://qa1.api.hs.homedepot.com/iconx/v1/leads/pobatch':
            'https://api.hs.homedepot.com/iconx/v1/leads/pobatch');
    }

    public String getLeadLookupUrl() {
        return Sf.settingsService.getString('HomeDepotLeadLookupUrl',
            isSandbox()?'https://qa1.api.hs.homedepot.com/iconx/v1/leads/lookup':
            'https://api.hs.homedepot.com/iconx/v1/leads/lookup');
    }
 

    public String getErrorLogUrl() {
        return Sf.settingsService.getString('HomeDepotLeadLookupUrl',
            isSandbox()?'https://qa1.api.hs.homedepot.com/iconx/v1/errorlog':
            'https://api.hs.homedepot.com/iconx/v1/errorlog');
    }
 
    public String getOAuth2AuthzUrl() {
        return Sf.settingsService.getString('HomeDepotOAuth2AuthzUrl',
            isSandbox()?'https://qa1.api.hs.homedepot.com/iconx/v1/auth/accesstoken':
            'https://api.hs.homedepot.com/iconx/v1/auth/accesstoken');
    } 

    public Map<Id, Map<Id, OpportunityContactRole>> getOpportunityRoleMap(List<Id> opportunityIds){
        System.debug('opportunityIds: ' + opportunityIds);
        Map<Id, Map<Id, OpportunityContactRole>> opportunityContactMap = new Map<Id, Map<Id, OpportunityContactRole>>();
        for(OpportunityContactRole roleObj: [Select Id, contactId, OpportunityId, role, isprimary,
                                                Contact.Name, contact.firstname, contact.lastname, contact.email, contact.phone, contact.preferred_language__c  from OpportunityContactRole 
                                                where OpportunityId in :opportunityIds]){ 
//                                                and contact.email != null and contact.email  != '' ]){
            if(roleObj.contactId != null){
                Map<Id, OpportunityContactRole> roleMap = opportunityContactMap.containsKey(roleObj.OpportunityId) ? 
                                                            opportunityContactMap.get(roleObj.OpportunityId) : new Map<Id, OpportunityContactRole>();
                roleMap.put(roleObj.contactId, roleObj);    
                opportunityContactMap.put(roleObj.OpportunityId, roleMap);  
            }
        }
        return opportunityContactMap;
    }  

    public String getLeadStatus(String leadStage){
        String leadStatus = 'Acknowledged';
        if(leadStage == 'Closed Lost' || leadStage == 'Out of Market'){
            leadStatus = 'Cancelled';
        }
        return leadStatus;
    }
    
    public String getLeadStatusReason(String leadStage, String leadStatus){
        String statusReason = ' ';
        if(leadStage == 'Closed Lost' && leadStatus == 'Not Interested'){
            statusReason = 'Customer Not Interested';
        }else if(leadStage == 'Closed Lost' && leadStatus == 'Working with Partner'){
            statusReason = 'Already Purchased';
        }else if(leadStage == 'Closed Lost' && leadStatus == 'Bad Contact Info'){
            statusReason = 'Bad Contact Information';
        }else if(leadStage == 'Closed Lost'){
            statusReason = 'Not Interested';  
        }else if(leadStage == 'Out of Market'){
            statusReason = 'Out of Service/License Area';
        }
        return statusReason;
    }

   public String getOpportunityStatus(String opptyStage){
        String opptyStatus = 'Acknowledged';
        if(opptyStage == '9. Closed Lost'){
            opptyStatus = 'Cancelled';
        }else if(opptyStage == '2. Appointment Process' || opptyStage == '3. Proposal Presented to Customer' ||
                 opptyStage == '4. Verbal Commit' || opptyStage == '5. Customer Signed Agreement' ||
                 opptyStage == '6. Submitted To Operations' || opptyStage == '7. Closed Won'){
            opptyStatus = 'Confirmed';
        }
        return opptyStatus;
    }
     
    public String getOpportunityStatusReason(String optyStage, String optyStatus, String reason){
        //String statusReason = 'Product / Service Offering ? Modified to Wrong Product/Service Offering';
        String statusReason = 'Wrong Product/Service Offering';
        
        if(optyStage == '9. Closed Lost' && optyStatus == 'Not Interested' && reason == 'Upfront Cost Too High'){
            statusReason = 'Price';
        }else if(optyStage == '9. Closed Lost' && optyStatus == 'Not Interested' && reason == 'Contract Terms'){
        //    statusReason = 'Product / Service Offering ? Modified to Wrong Product/Service Offering';
              statusReason = 'Wrong Product/Service Offering';
        }else if(optyStage == '9. Closed Lost' && optyStatus == 'Not Interested' && reason == 'Unable To Reach'){
            statusReason = 'Cannot connect with customer';
        }else if(optyStage == '9. Closed Lost' && optyStatus == 'Unqualified' && reason == 'Credit'){
            statusReason = 'Credit Reject';
        }else if(optyStage == '9. Closed Lost' && optyStatus == 'Unqualified' && reason == 'Out of Service Territory'){
            statusReason = 'Out of Service/License Area';
        }else if(optyStage == '9. Closed Lost' && optyStatus == 'Competitor'){
            statusReason = 'Already Purchased';
        }
        return statusReason;
    }

@Future(callout=true)
    public static void lookupLeadOppty(Id apiRequestLogId) {
        String batchId;  
        API_Request_Log__c apiReq = [select Id, Object_Name__c, Prospect_Id__c from API_Request_Log__c where id = :apiRequestLogId];       
        
        If(apiReq.Object_Name__c.equalsIgnoreCase('lead')){
            Lead l = [Select External_Sync_Batch_ID_Outbound__c from Lead where Prospect_Id__c = :apiReq.Prospect_Id__c];  
            batchId = l.External_Sync_Batch_ID_Outbound__c;
        }else if (apiReq.Object_Name__c.equalsIgnoreCase('opportunity')){
            Opportunity o = [Select External_Sync_Batch_ID_Outbound__c from Opportunity where Prospect_Id__c = :apiReq.Prospect_Id__c];    
            batchId = o.External_Sync_Batch_ID_Outbound__c;
        }
        
        if(batchId != null){
           Sf.HomeDepotSyncService.lookupLead(apiReq.Id, batchId, apiReq.Prospect_Id__c);             
        }else{
            apiReq.Request_Status__c = 'Look-up Error'; 
            apiReq.Response_Details__c = 'External Sync Batch ID Outbound is not found';
            update apiReq;
        }

    }
    
    public void handleSCEventsTrigger() {
        
        if (isBeforeUpdate()) {
            for (Integer i = 0; i < Trigger.new.size(); i++) {
                Service_Contract_Event__c oldSCE = (Service_Contract_Event__c) Trigger.old.get(i);
                Service_Contract_Event__c newSCE = (Service_Contract_Event__c) Trigger.new.get(i);
                if (isHomeDepotServiceContractEvent(newSCE) && 
                    !checkRecursive.homeDepotSCEIds.contains(newSCE.id)) {
                    if (newSCE.External_Sync_InProgress__c && isHomeDepotServiceContractEventChanged(oldSCE, newSCE)) {
                        checkRecursive.homeDepotSCEIds.add(newSCE.id);
                    } else if (isHomeDepotServiceContractEventChanged(oldSCE, newSCE)) {
                        newSCE.External_Sync_System__c = HomeDepot;
                        newSCE.External_Sync_Status__c = BaseClass.Status_ToBeSynced;
                        newSCE.External_Sync_InProgress__c = false;
                        checkRecursive.homeDepotSCEIds.add(newSCE.id);
                        System.debug('Modified Object ...');
                    } 
                } else {
                    info('Service Contract Event is not applicable for home depot due to its External Source [' + newSCE.External_Sync_System__c 
                         + '] ');
                }
            }
        } 

        if ( isAfterUpdate() ) {
            List<API_Request_Log__c> apiReqList = new List<API_Request_Log__c>(); 
            for (Integer i = 0; i < Trigger.new.size(); i++) {
                Service_Contract_Event__c oldSCE = (Service_Contract_Event__c) Trigger.old.get(i);
                Service_Contract_Event__c newSCE = (Service_Contract_Event__c) Trigger.new.get(i);
                  
                if (oldSCE.External_Sync_InProgress__c == false && newSCE.External_Sync_InProgress__c == true &&
                    newSCE.External_Sync_Status__c == BaseClass.Status_ToBeSynced){
                    System.debug('API Request Log Record is created for SCE');
                    API_Request_Log__c apiReq = new API_Request_Log__c(); 
                    apiReq.Object_Name__c = 'Service Contract Event';
                    apiReq.Prospect_Id__c = newSCE.ProspectId__c; 
                    apiReq.External_Sync_System__c = newSCE.External_Sync_System__c; 
                    apiReq.Request_Status__c = 'Ready To Look-up'; 
                    apiReq.Request_Type__c = 'HD SCE Look-up'; 
                    apiReq.Name = apiReq.Request_Type__c+apiReq.Prospect_Id__c; 
                    apiReqList.add(apiReq); 
                     
                    checkRecursive.homeDepotAPIReqSCEIds.add(newSCE.id); 
                }
            }    

            insert apiReqList; 
            System.debug('API Request Log Record is created for SCE 2');

        }
    }  
    
    public void syncServiceContractEvents(String sunrunBatchId, List<Service_Contract_Event__c> scEvents){
      
      String batchId = '';
      String syncStatus = '';
      String exceptionDetails = '';
      if(!isEmptyCollection(scEvents)){
        try{
          JsonReader reader = homeDepotHttpPost(getLeadCreateUrl(), getCreateSCEventsRequestBody(sunrunBatchId, scEvents));
          syncStatus = BaseClass.Status_SyncSuccess;
          batchId = reader.getString('SFILEADPOBATCHICONX_Output.ReceivedBatchQueueID');
          for (Service_Contract_Event__c scEvent : scEvents) {
               scEvent.External_Sync_Batch_ID_Outbound__c = sunrunBatchId;
               scEvent.External_Sync_Batch_ID_Inbound__c = batchId;
               scEvent.External_Sync_Details__c = null;
               scEvent.External_Sync_InProgress__c = true;
          }
        }catch (Exception e) {
                syncStatus = BaseClass.Status_SyncError;
                exceptionDetails = getExceptionDetails(e);          
                for (Service_Contract_Event__c scEvent : scEvents) {
                    scEvent.External_Sync_Status__c = syncStatus;
                    scEvent.External_Sync_Details__c = exceptionDetails;
                }           
         }
         update scEvents;
      }  
    
    
    }
    
     public String getCreateSCEventsRequestBody(String sunrunBatchId, List<Service_Contract_Event__c> scEvents){
        
        Set<Id> scIds = new Set<Id>();
        List<ServiceContract> ServiceContracts = new List<ServiceContract>();
        Set<Id> scConIds = new Set<Id>();
        Set<Id> scAccIds = new Set<Id>();
        Set<Id> scOptyIds = new Set<Id>();
        Map<Id,Contact> getSCConMap = new Map<Id,Contact>();
        Map<Id,Account> getSCAccMap = new Map<Id,Account>();
        Map<Id,Opportunity> getSCOptyMap = new Map<Id,Opportunity>();  
        
       
        //writer.with('MmSvCsServiceProviderLeadHeaderInbound');    
        for(Service_Contract_Event__c sce : scEvents){
          scIds.add(sce.Service_Contract__c);
        }
        if(!scIds.isEmpty()){
           for(ServiceContract sc : [select Id, Opportunity__c, ContactId, AccountId, Proposal__c, Description,ContractNumber,service_contract_event__c,Service_Contract_Event__r.External_id__c,Home_depot_Unit_Cost__c,Home_Depot_Payment_Amount__c from ServiceContract where Id in : scIds]){
            ServiceContracts.add(sc);
            scConIds.add(sc.ContactId);
            scAccIds.add(sc.AccountId);
            scOptyIds.add(sc.Opportunity__c);
           }
        }
        
        If(!scConIds.isEmpty()){
           for(Contact con : [select Id, FirstName, LastName, Phone, Email from Contact where Id in: scConIds]){
             getSCConMap.put(con.Id,con);
           }
        }
        If(!scAccIds.isEmpty()){
           for(Account acc : [select Id, BillingStreet, BillingCity, BillingCountry,County__c,BillingPostalCode,BillingState from Account where Id in : scAccIds ]){
             getSCAccMap.put(acc.Id,acc);
           }
        }
        If(!scOptyIds.isEmpty()){
           for(Opportunity opp : [select Id, Prospect_Id__c,External_ID__c,External_Row_ID__c,Lead_Organization_Location_2__r.AccountNumber,StageName, CreatedDate from Opportunity where Id in : scOptyIds]){
             getSCOptyMap.put(opp.Id,opp);
           }
        }
        JsonWriter writerX = new JsonWriter();
        writerX.ignoreNulls = true;
        JsonWriter writer = new JsonWriter();
        writer.ignoreNulls = true;
        
         JsonWriter writer3 = new JsonWriter();
         writer3.ignoreNulls = true;
         writer3.with('ListOfMmSvCsServiceProviderLeadInbound');
             
          for(Integer j =0; j < ServiceContracts.size(); j++){
          
          ServiceContract scObj = ServiceContracts.get(j);
          Contact scContact = getSCConMap.get(scObj.ContactId);
          Account scAccount = getSCAccMap.get(scObj.AccountId);
          Opportunity optyObj = getSCOptyMap.get(scObj.Opportunity__c);
          
             JsonWriter writer31 = new JsonWriter();
             writer31.ignoreNulls = true;
             addLeadFieldsToJSONWriter(sunrunBatchId,scAccount,scContact,scObj,optyObj,writer31);
             
             JsonWriter writer32 = new JsonWriter();
             writer32.ignoreNulls = true;
             
             if(scObj.Service_Contract_Event__r.External_id__c != null){
          writer32.write('Id',scObj.Service_Contract_Event__r.External_id__c);
          }
          else{
          writer32.write('Id',scObj.ContractNumber);
          }
          writer32.write('MMSVQuantityRequested','1'); 
          writer32.write('MMSVSKU',label.Home_Depot_MMSVSKU);
          string unitprice = string.valueof(scObj.Home_Depot_Payment_Amount__c);
          writer32.write('UnitPrice',unitprice);
          //writer.write('UnitPrice',scObj.Home_Depot_Payment_Amount__c);
          writer32.write('MMSVCSItemField1',optyObj.Prospect_Id__c);
          writer32.endwith();
             
             writer31.write('ListOfMmSvCsServiceProviderEstimatesInbound.MmSvCsServiceProviderEstimatesInbound[0]', writer32.jsonObj);
             writer31.endwith();
             
            writer3.write('MmSvCsServiceProviderLeadHeaderInbound['+j+']', writer31.jsonObj);
            
          }
          writer3.endwith();
          
          writerX.write('SFILEADPOBATCHICONX_Input',writer3.jsonObj);
          writerX.endWith();    
          system.debug('test writer3'+ writerX.toPrettyJson());
         
     return writerX.toPrettyJson();
     }
     
     public void addLeadFieldsToJSONWriter(String sunrunBatchId, Account accountObj, Contact contactObj, ServiceContract scObj, Opportunity optyObj, JsonWriter writer){
      
         
       if (String.isEmpty(optyObj.External_Row_ID__c)) {
            writer.write('Id', optyObj.Prospect_Id__c);
       }else{
            writer.write('Id', optyObj.External_Row_ID__c);      
       }  
       writer.write('ContactFirstName', contactObj.FirstName);
       writer.write('ContactLastName', contactObj.LastName);
       writer.write('Description',scObj.Description);
       writer.write('MMSVCSServiceProviderOrderNumber ', optyObj.Prospect_Id__c);
       
       String tempPhone = (!String.isEmpty(contactObj.Phone)) ? contactObj.Phone : '';
       tempPhone = tempPhone.remove(' ').remove('-').remove('(').remove(')') ; 
       writer.write('MMSVPreferredContactPhoneNumber', tempPhone); 
       
       writer.write('MMSVSiteAddress', accountObj.BillingStreet);
        writer.write('MMSVSiteCity', accountObj.BillingCity);
        writer.write('MMSVSiteCountry', accountObj.BillingCountry);
        writer.write('MMSVSiteCounty', accountObj.County__c);
        writer.write('MMSVSitePostalCode', accountObj.BillingPostalCode);
        writer.write('MMSVSiteState', accountObj.BillingState);
        writer.write('MMSVStoreNumber', optyObj.Lead_Organization_Location_2__r.AccountNumber);
        writer.write('SFIMVendor', label.HomeDepot_SFIMVendor);
        writer.write('SFIProgramGroupNameUnconstrained', label.HomeDepot_SFIProgramGroupNameUnconstrained);
        writer.write('SFIReferralStore', optyObj.Lead_Organization_Location_2__r.AccountNumber);
        writer.write('SFIWorkflowOnlyStatus', getOpportunityStatus(optyObj.stagename));
        writer.write('MMSVCSNeedAck', label.HomeDepot_MMSVCSNeedAck);
        writer.write('MMSVCSSubmitLeadFlag', label.HomeDepot_MMSVCSSubmitLeadFlag);
        writer.write('MMSVCSSVSTypeCode', label.HomeDepot_MMSVCSSVSTypeCode);
        writer.write('SFIContractDate', (optyObj.CreatedDate).format('MM/dd/yyyy HH:mm:ss'));
        writer.write('MMSVCSLeadBatchNumber', sunrunBatchId);
        if(contactObj.Email == null){
            writer.write('MainEmailAddress','NA@NA.com');
        }else{    
            writer.write('MainEmailAddress', contactObj.Email);
        }
        
     }
     
     public void handleAPIRequestLogSCETrigger() {
        if ( isBeforeUpdate() ){
            for (Integer i = 0; i < Trigger.new.size(); i++) {
                API_Request_Log__c oldReq = (API_Request_Log__c) Trigger.old.get(i);
                API_Request_Log__c newReq = (API_Request_Log__c) Trigger.new.get(i); 
    
                if(newReq.External_Sync_System__c == 'Home Depot' && 
                   newReq.Request_Type__c == 'HD SCE Look-up' && 
                   newReq.Request_Status__c == 'Look-up In Progress' && 
                   newReq.Request_Status__c != oldReq.Request_Status__c){
                    System.debug('Before callout');
                    String jobID = enqueueJobWithCheck(new HomeDepotSCELookupQueueable(newReq.Id));
                    if(jobID == null){
                       newReq.Request_Status__c = 'Look-up Error'; 
                       newReq.Response_Details__c = 'Look-up request could not be submitted';
                    }
                    System.debug('After callout');
                }
            } 
        }
    }
    public Boolean isHomeDepotServiceContractEvent(Service_Contract_Event__c scEventObj) {
        return scEventObj.lead_source__c!=null && scEventObj.lead_source__c.contains(HomeDepot);
    }
    public Boolean isHomeDepotServiceContractEventChanged(Service_Contract_Event__c oldSCE, Service_Contract_Event__c newSCE){
        Boolean result = isChanged(oldSCE,newSCE,new String[]{'M2_proof_substantial_completion__c'});
        system.debug('Result : '+result);
        return result;
    }
    public void lookupSCE(Id apiReqId, String batchNumber, String prospectId){
        
        Map<String, HomeDepotSCELookupDto.sceDTO> SCEDTOMap;
        Boolean SCEFound; 
        Datetime reqStartTime = Datetime.now();
        
        try{
            System.debug('lookupSCE---> 2');
            JsonReader reader = homeDepotHttpPost(getLeadLookupUrl(), getLookupLeadRequestBody(batchNumber, prospectId));
            HomeDepotSCELookupDto lookupDTO = new HomeDepotSCELookupDto(reader);
            System.debug('lookupSCE---> 3');
            if(lookupDTO != null){
                SCEDTOMap = lookupDTO.sceDTOMap;
            }
 
           if(SCEDTOMap != null && !SCEDTOMap.isEmpty()){
                SCEFound = false; 
                List<Service_Contract_Event__c> SCEList = querySCEsByProspectId(SCEDTOMap.keySet());
                
                if (!SCEList.isEmpty() && SCEList.get(0) != null){
                    SCEFound = true;
                    Service_Contract_Event__c SCEObj = SCEList.get(0);    
                    SCEObj.External_ID__c = SCEDTOMap.get(SCEObj.ProspectId__c).externalId;
                    if(!String.isEmpty(SCEObj.External_ID__c)){
                        SCEObj.External_Sync_Status__c = (SCEObj.External_Sync_Status__c == Status_UpdatedDuringSync) ? Status_ToBeSynced : Status_SyncSuccess;
                        SCEObj.External_Sync_Details__c = null;
                        SCEObj.External_Sync_Batch_ID_Outbound__c = '';
                                
                    }else{
                        SCEObj.External_Sync_Status__c = Status_ToBeSynced;
                        SCEObj.External_Sync_Details__c = 'HomeDepot didn\'t return External Id ';
                    }
                    SCEObj.External_Sync_InProgress__c = false;
                    update SCEObj;
                }
    
        
                if(SCEFound){
                   List<API_Request_Log__c> apiReqList = queryAPIRequestLogById(new Set<Id>{apiReqId});
                   if(!apiReqList.isEmpty()){
                       API_Request_Log__c apiReq =  apiReqList.get(0);
                       apiReq.Request_Status__c = 'Look-up Success';  
                       apiReq.Request_Start_Time__c = reqStartTime;
                       apiReq.Request_End_Time__c = Datetime.now();
                       apiReq.Response_Details__c = String.valueOf(reader);
                       update apiReq; 
                   } 
                }
            }

        }catch (Exception e) {
            
            List<API_Request_Log__c> apiReqList = queryAPIRequestLogById(new Set<Id>{apiReqId});
            if(!apiReqList.isEmpty()){
                API_Request_Log__c apiReq =  apiReqList.get(0);
                apiReq.Request_Status__c = 'Look-up Error';  
                apiReq.Response_Details__c = getExceptionDetails(e);
                update apiReq; 
            }
        }
    }
    public List<Service_Contract_Event__c> querySCEsByProspectId(Set<String> prospectIds) {
        if(isEmptyCollection(prospectIds)){
            return new List<Service_Contract_Event__c>();
        }else{
            return [
                select
                    Id,
                    External_id__c,
                    M2_proof_substantial_completion__c,
                    ProspectId__c,
                    External_Sync_Batch_ID_Outbound__c,
                    External_Sync_Status__c,
                    External_Sync_Details__c,
                    External_Sync_InProgress__c
                from Service_Contract_Event__c
                where ProspectId__c in :prospectIds
            ];
        }
    }    
}