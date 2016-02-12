public without sharing class CostcoSyncServiceImpl extends BaseClass implements CostcoSyncService {

	public static final String Costco = 'Costco';
    public String authToken;

    /**
     * To be called Before/After and Insert/Update triggers. Implements the process to sync
     * the lead to Costco.
     */
    public void handleLeadsTrigger() {
        
        //In before insert/update trigger, we will need to check if this lead is applicable for costco sync.
        //If yes set the external sync system as costco and update the status as appropriate.
        if (isBeforeInsert()) {
            for (Sobject sobj : Trigger.new) {
                Lead lead = (Lead) sobj;
                if (lead.External_Id__c == null && isCostcoLead(lead)
                && !checkrecursive.costcoids.contains(lead.lastname)
                && lead.External_Sync_InProgress__c !=true && lead.reason__c!='Duplicate Lead Found' && lead.reason__c!='Duplicate Opportunity Found'
                ) {
                    lead.External_Sync_System__c = Costco;
                    lead.External_Sync_Status__c = BaseClass.Status_ToBeSynced;
                    lead.External_Sync_InProgress__c = true;
                    checkrecursive.newcostcoids.add(lead.lastname);
                } else {
                    info('Lead is not applicable for costco due to its channel [' + lead.Channel__c 
                         + '] and retail lead source [' + lead.Retail_Lead_Source__c 
                         + '] or it was created in Costco system and being sycned to SFDC so not syncing to costco.');
                }
            }
        }
        
        //If this is lead update, check if intended fields are updated. If yes then mark
        //such lead for syncing.
        if (isBeforeUpdate()) {
            Map<String,String> CancelCodesMap=new Map<String,String>();
            for(Costco_Cancellation_Codes__c cancelCodes:Costco_Cancellation_Codes__c.getAll().values()){
                CancelCodesMap.put(cancelCodes.key__c,cancelCodes.value__c);
            }
            for (Integer i = 0; i < Trigger.new.size(); i++) {
                
                Lead oldLead = (Lead) Trigger.old.get(i);
                Lead newLead = (Lead) Trigger.new.get(i);
                system.debug('newLead.External_Sync_System__c '+newLead.External_Sync_System__c );
                system.debug('newLead.External_Sync_Status__c '+newLead.External_Sync_Status__c );
                system.debug('newLead.External_Sync_InProgress__c '+newLead.External_Sync_InProgress__c );
                system.debug('checkrecursive.costcoids'+checkrecursive.costcoids);
                if (isCostcoLead(newLead)||oldlead.Purchased_Thru__c=='Costco'&&newLead.Purchased_Thru__c!='Costco') {
                    if (newLead.External_Sync_InProgress__c == false && oldlead.External_Sync_InProgress__c == true) {
                        //newLead.External_Sync_InProgress__c = false;
                    } else if ((newLead.External_Id__c == null && isCostcoLeadChanged(oldLead, newLead)) 
                        && !checkrecursive.costcoids.contains(newlead.lastname)
                        && newLead.External_Sync_InProgress__c !=true && newlead.reason__c!='Duplicate Lead Found' && newlead.reason__c!='Duplicate Opportunity Found'){
                        newLead.External_Sync_System__c = Costco;
                        newLead.External_Sync_Status__c = BaseClass.Status_ToBeSynced;
                        newLead.External_Sync_InProgress__c = true;
                        checkrecursive.newcostcoids.add(newLead.lastname);
                    }
                    else if((newLead.External_Id__c != null && isCostcoCancelLeadChanged(oldLead, newLead))
                        && !checkrecursive.costcoids.contains(newlead.lastname)
                        && newLead.External_Sync_InProgress__c !=true)
                    {
                        if(newLead.status!=null&&newLead.Lead_Status__c!=null&newLead.Reason__c!=null&&CancelCodesMap.containsKey(newLead.status+'+'+newLead.Lead_Status__c+'+'+newLead.Reason__c)
                        ||(newLead.status!=null&&newLead.Lead_Status__c!=null&&CancelCodesMap.containsKey(newLead.status+'+'+newLead.Lead_Status__c))
                        ||(newLead.status!=null&&CancelCodesMap.containsKey(newLead.status))
                        ||(oldlead.Purchased_Thru__c=='Costco'&&newLead.Purchased_Thru__c!='Costco')
                        ){
                        newLead.External_Sync_System__c = Costco;
                        newLead.External_Sync_Status__c = BaseClass.Status_ToBeSynced;
                        newLead.External_Sync_InProgress__c = true;
                        checkrecursive.newcostcoids.add(newLead.lastname);
                        }
                    }
                } else {
                    info('Lead is not applicable for costco due to its channel [' + newLead.Channel__c 
                         + '] and retail lead source [' + newLead.Retail_Lead_Source__c + '].');
                }
            }
        }
        
        if (isAfterInsert()||isAfterUpdate()) {
            if (isCostcoLeadSyncEnabled()) {
                List<Lead> leadsToBeSynced = new List<Lead>();
                for (Sobject sobj : Trigger.new) {
                    Lead lead = (Lead) sobj;
                    if (lead.External_Sync_System__c == Costco && lead.external_id__c==null&&lead.External_Sync_Status__c == BaseClass.Status_ToBeSynced 
                        && !checkrecursive.costcoids.contains(lead.lastname)
                        && checkrecursive.newcostcoids.contains(lead.lastname)&&isCostcoLead(lead)) {
                        leadsToBeSynced.add(lead);
                        checkRecursive.costcoids.add(lead.lastname); 
                    }
                    else if (lead.External_Sync_System__c == Costco && lead.external_id__c!=null&&lead.External_Sync_Status__c == BaseClass.Status_ToBeSynced 
                        && !checkrecursive.costcoids.contains(lead.lastname)
                        && checkrecursive.newcostcoids.contains(lead.lastname)&&(isCostcoLead(lead)||lead.Purchased_Thru__c!='Costco')) {
                        leadsToBeSynced.add(lead);
                        checkRecursive.costcoids.add(lead.lastname); 
                    }
                }
                
                if (!leadsToBeSynced.isEmpty()) {
                    enqueueJobWithCheck(new CostcoLeadSyncJob(getUniqueIdList(leadsToBeSynced)));
                    //Add all the above leads to a static set. 
                                       
                }
                System.debug('--Print Costco ids: ' + checkRecursive.costcoids);
            } else {
                info('Costco Lead Sync is not enabled in the settings and hence not syncing to Costco.');
            }
        }
    }
    
    public Boolean isCostcoLead(Lead lead) {
        return lead.Channel__c == 'Retail' && lead.Custom_lead_source__c!=null && lead.Custom_lead_source__c.contains(Costco) && lead.firstname!=null && lead.street!=null && lead.city!=null && lead.state!=null &&
                lead.postalcode!=null && lead.phone!=null && lead.Costco_Store_Id__c!=null && lead.street!='' && lead.city!='' &&lead.postalcode!='' &&lead.state!='';      
    }
    public Boolean isCostcoAppointment(Appointment__c app) {
        return app.Channel__c == 'Retail' && app.lead_source__c!=null && app.lead_source__c.contains(Costco);      
    }
    public Boolean isCostcoServiceContractEvent(Service_Contract_Event__c sce) {
        return sce.lead_source__c!=null && sce.lead_source__c.contains(Costco);      
    }
    public Boolean isCostcoLeadChanged(Lead oldLead, Lead newLead) {
        return isChanged(oldLead, newLead, new String[]{'FirstName', 'LastName', 'Title', 
            'Email', 'Phone', 'Alternate_Phone__c', 'Street', 'City', 'State', 'PostalCode','Lead_Organization_Location_2__c'});
    }
    public Boolean isCostcoCancelLeadChanged(Lead oldLead, Lead newLead) {
        return isChanged(oldLead, newLead, new String[]{'status','Lead_Status__c','Reason__c','Purchased_Thru__c'});
    }
    public Boolean isCostcoOpptyChanged(Opportunity oldOppty, Opportunity newOppty) {
        return isChanged(oldOppty, newOppty, new String[]{'StageName', 'Opportunity_Status__c', 'Reason__c','Purchased_Thru__c'});
    }
    public Boolean isCostcoOpportunity(Opportunity opp) {
        return opp.Channel_2__c == 'Retail' && opp.lead_source_2__c!=null && opp.lead_source_2__c.contains(Costco);      
    }
    public Boolean isCostcoProposal(Proposal__c proObj) {
        return proObj.lead_source__c!=null && proObj.lead_source__c.contains(Costco);      
    }
    /**
     * Syncs the given leads to Costco system. Whether lead is created or updated in Costco depends
     * on the External_Id__c field. If this field has value, then that value is considered as 
     * Costco Lead id and that is updated.
     */
    public void syncLeads(List<Id> leadIds) {
        if (!isCostcoLeadSyncEnabled()) {
            info('Costco Lead Sync is not enabled in the Settings [CostcoLeadSyncEnabled] and hence not syncing.');
            return;
        }
        Map<String,String> CancelCodesMap=new Map<String,String>();
        for(Costco_Cancellation_Codes__c cancelCodes:Costco_Cancellation_Codes__c.getAll().values()){
            CancelCodesMap.put(cancelCodes.key__c,cancelCodes.value__c);
        } 
        String serviceId;
        String storeId;
        String adcodeId;
        
        List<Lead> leads = queryLeads(leadIds);
        String CancelCode;
        for (Lead lead : leads) {           
            lead.External_Sync_InProgress__c = false;
            try {
                if (lead.External_Id__c == null) {
                    lead.Costco_Api_Counter__c++;
                    //We will cache the ids for performance reasons. So we need to
                    //retrieve them first time if they are not initialized.
                    storeid=lead.Costco_Store_Id__c;
                    if (serviceId == null) {
                        serviceId = getServiceId();
                        //storeId = getStoreId();                        
                        adcodeId = getAdcodeId();
                    }
                    
                    XmlReader reader = costcoHttpPost('add_lead', createNewLeadRequestParms(lead, serviceId, storeId, adcodeId));
                    lead.External_Id__c = reader.getString('lead-id');
                } else if (lead.External_Id__c != null){
                    //costcoHttpPost('update_customer', createUpdateCustomerRequestParms(lead));
                    if(lead.Purchased_Thru__c!='Costco'){
                        CancelCode=CancelCodesMap.get('PurchaseThru');
                    }    
                    else if(lead.status!=null&&lead.Lead_Status__c!=null&&lead.Reason__c!=null){
                        CancelCode=CancelCodesMap.get(lead.status+'+'+lead.Lead_Status__c+'+'+lead.Reason__c);
                    }
                    else if(lead.status!=null&&lead.Lead_Status__c!=null){
                        CancelCode=CancelCodesMap.get(lead.status+'+'+lead.Lead_Status__c);
                    }
                    else if(lead.status!=null){
                        CancelCode=CancelCodesMap.get(lead.status);
                    }                          
                    system.debug('string cancelcode'+CancelCode);             
                    XmlReader reader = costcoHttpPost('cancel', cancelLeadRequestParms(lead,CancelCode));  
                }
                
                lead.External_Sync_Details__c = null;
                lead.External_Sync_Status__c = BaseClass.Status_SyncSuccess;                
                
            } catch (Exception e) {
                lead.External_Sync_Status__c = BaseClass.Status_SyncError;
                lead.External_Sync_Details__c = getExceptionDetails(e);
            }
        }
        
        update leads;
    }
    public void syncOpptys(List<Id> opptyIds) {
        if (!isCostcoLeadSyncEnabled()) {
            info('Costco Lead Sync is not enabled in the Settings [CostcoLeadSyncEnabled] and hence not syncing.');
            return;
        }
        Map<String,String> CancelCodesMap=new Map<String,String>();
        for(Costco_Cancellation_Codes__c cancelCodes:Costco_Cancellation_Codes__c.getAll().values()){
            CancelCodesMap.put(cancelCodes.key__c,cancelCodes.value__c);
        }        
        List<Opportunity> opptys = queryOpptys(opptyIds);
        String CancelCode;
        for (Opportunity opp : opptys) {           
            opp.External_Sync_InProgress__c = false;
            try {
                if (opp.External_Id__c != null) {
                    //opp.Costco_Api_Counter__c++;
                    //We will cache the ids for performance reasons. So we need to
                    //retrieve them first time if they are not initialized.    
                    if(opp.Purchased_Thru__c!='Costco'){
                        CancelCode=CancelCodesMap.get('PurchaseThru');
                    }                
                    else if(opp.stageName!=null&&opp.Opportunity_Status__c!=null&&opp.Reason__c!=null){
                        if(opp.Reason__c.indexof(';')!=-1){
                        CancelCode=CancelCodesMap.get(opp.stageName+'+'+opp.Opportunity_Status__c+'+'+opp.Reason__c.substring(0,opp.Reason__c.indexof(';')));   
                        }
                        else{
                        CancelCode=CancelCodesMap.get(opp.stageName+'+'+opp.Opportunity_Status__c+'+'+opp.Reason__c);
                        }
                    }
                    else if(opp.stageName!=null&&opp.Opportunity_Status__c!=null){
                        CancelCode=CancelCodesMap.get(opp.stageName+'+'+opp.Opportunity_Status__c);
                    }
                    else if(opp.stageName!=null){
                        CancelCode=CancelCodesMap.get(opp.stageName);
                    }       
                    system.debug('string cancelcode'+CancelCode);  
                    if(CancelCode!=null)           
                    XmlReader reader = costcoHttpPost('cancel', cancelLeadRequestParms(opp,CancelCode));                    
                }                 
                opp.External_Sync_Details__c = null;
                opp.External_Sync_Status__c = BaseClass.Status_SyncSuccess;                
                
            } catch (Exception e) {
                opp.External_Sync_Status__c = BaseClass.Status_SyncError;
                opp.External_Sync_Details__c = getExceptionDetails(e);
            }
        }
        
        update opptys;
    }
    /**
     * To be called Before/After and Insert/Update triggers. Implements the business logic
     * to update costco lead's appointment date.
     */       
    public void handleAppointmentsTrigger() {
    
        //In before insert/update trigger, we will need to check if this appointment is eligible to update costco lead estimate date.
        //The first appointment on the costco opportunity is eligible to update costco lead estimate date.
        if (isBeforeInsert()) {
            //Set<Id> firstAppointmentOptyIds = getFirstAppointmentOpportunities();
            for (Sobject sobj : Trigger.new) {
                Appointment__c appointmentObj = (Appointment__c) sobj;
                //if (firstAppointmentOptyIds.contains(appointmentObj.opportunity__c)) {
                if (isCostcoAppointment(appointmentObj)&&!appointmentObj.Do_Not_Sync__c) {  
                    appointmentObj.External_Sync_System__c = Costco;
                    appointmentObj.External_Sync_Status__c = BaseClass.Status_ToBeSynced;
                } else {
                    info('This Appointment is not applicable to update costco lead estimate date');
                }
            }
        }

        if (isAfterInsert()) {
            if (isCostcoLeadSyncEnabled()) {
                List<Appointment__c> appointsToBeUpdated = new List<Appointment__c>();
                for (Sobject sobj : Trigger.new) {
                    Appointment__c appointmentObj = (Appointment__c) sobj;
                    if (appointmentObj.External_Sync_System__c == Costco && appointmentObj.External_Sync_Status__c == BaseClass.Status_ToBeSynced&&!appointmentObj.Do_Not_Sync__c) {
                        appointsToBeUpdated.add(appointmentObj);
                    }
                }
                
                if (!appointsToBeUpdated.isEmpty()) {
                    enqueueJobWithCheck(new CostcoLeadUpdateEstimateDateJob(getUniqueIdList(appointsToBeUpdated)));
                }
            } else {
                info('Costco Lead Sync is not enabled in the settings and hence not updating the lead estimate date.');
            }
        }
        
    }
    /*
    public Set<Id> getFirstAppointmentOpportunities(){
        Set<Id> firstAppointmentOptyIds = new Set<Id>();
        if (isBeforeInsert()) {
            Set<Id> optyIds = new Set<Id>();
            for (Sobject sobj : Trigger.new) {
                Appointment__c appointmentObj = (Appointment__c) sobj;
                if(appointmentObj.opportunity__c != null){
                    optyIds.add(appointmentObj.opportunity__c);
                }           
            }
            if(optyIds != null && !optyIds.isEmpty()){
                for(Opportunity optyObj : [Select Id, name, (Select Id, Name from Appointments__R) from Opportunity where Id in :optyIds]){
                    if(optyObj.Appointments__R == null || optyObj.Appointments__R.isEmpty()){
                        firstAppointmentOptyIds.add(optyObj.Id);
                    }
                }
            }
        }
        return firstAppointmentOptyIds;
    }
    */
    
    /**
     * TODO
     * 
     * 
     */    
    public void updateLeadsEstimateDate(List<Id> appointmentIds) {
        if (!isCostcoLeadSyncEnabled()) {
            info('Costco Lead Sync is not enabled in the Settings [CostcoLeadSyncEnabled] and hence not updating the lead estimate date.');
            return;
        }
              
        List<Appointment__c> appointments = queryAppointments(appointmentIds);
        List<id> OpptyIds=new List<id>();
        Integer ESTTimeDiff;
        BaseScheduling bas=new BaseScheduling();   
        TimeZone usertz = UserInfo.getTimeZone();     
        for (Appointment__c appointment : appointments) {
            OpptyIds.add(appointment.opportunity__c);
        }
        Map<id,Opportunity> apOptyMap=appOpptyMap(OpptyIds);
        
        for (Appointment__c appointment : appointments) {            
            try {
                if (!String.isEmpty(appointment.Opportunity_External_Id__c)) {
                    appointment.External_Sync_InProgress__c = true;
                    Integer TimeDiff;
                    if(apOptyMap.containsKey(appointment.opportunity__c)){
                    String custtz = bas.getCustomerTimeZone(apOptyMap.get(appointment.opportunity__c)); 
                    TimeDiff= bas.getOffset(appointment.Appointment_Date_Time__c,custtz)-bas.getOffset(appointment.Appointment_Date_Time__c,usertz.tostring());
                    //timeZoneVar=bas.getCustomerTimeZone(apOptyMap.get(appointment.opportunity__c));
                    ESTTimeDiff=bas.getOffset(appointment.Appointment_Date_Time__c,'America/New_York')-bas.getOffset(appointment.Appointment_Date_Time__c,usertz.tostring());
                    }
                    XmlReader reader = costcoHttpPost('estimate', updateLeadEstimateDateRequestParms(appointment,TimeDiff,ESTTimeDiff));
                    appointment.External_Sync_Details__c = null;
                    appointment.External_Sync_Status__c = BaseClass.Status_SyncSuccess;
                    appointment.External_Sync_InProgress__c = false;
                }
            } catch (Exception e) {
                appointment.External_Sync_Status__c = BaseClass.Status_SyncError;
                appointment.External_Sync_Details__c = getExceptionDetails(e);
                appointment.External_Sync_InProgress__c = false;
            }
        }
        if(!appointments.isEmpty()){
            update appointments;
        }
    }   


    /**
     * To be called Before/After and Insert/Update triggers. Implements the business logic
     * to update costco lead's quote details.
     */
    /* 
    public void handleProposalsTrigger() {
    }
    */
    
    public void handleProposalsTrigger() {   
        //In before insert/update trigger, we will need to check if this Proposal is eligible to update costco lead quote amount.
        //The first proposal on the costco opportunity is eligible to update costco lead quote amount.
        //List<Appointment__c> appointmentList=new List<Appointment__c>();
        if (isBeforeInsert()) {
            //Map<Id,Opportunity> firstProposalOptyIds = getFirstProposalOpportunities();
            for (Sobject sobj : Trigger.new) {
                Proposal__c proposalObj = (Proposal__c) sobj;
                if (isCostcoProposal(proposalObj)&&proposalObj.Number_of_Proposals__c==0) {
                    proposalObj.External_Sync_System__c = Costco;
                    proposalObj.External_Sync_Status__c = BaseClass.Status_ToBeSynced;
                    /*if(proposalObj.Number_of_appointments__c==0){
                        Appointment__c appointment=new Appointment__c();
                        appointment.Event_Assigned_To__c=System.Label.Costco_Dummy_Contact;
                        appointment.opportunity__c=proposalObj.opportunity__c;
                        appointment.Appointment_Date_Time__c=firstProposalOptyIds.get(proposalObj.opportunity__c).Lead_Created_Date_Time__c.addhours(-1);
                        appointment.Appointment_End_Date_Time__c=firstProposalOptyIds.get(proposalObj.opportunity__c).Lead_Created_Date_Time__c;    
                        appointment.Do_Not_Sync__c=true;                                                                    
                        appointmentList.add(appointment);
                    }*/
                } else {
                    info('This Appointment is not applicable to update costco lead quote amount');
                }
            }
            //if(!appointmentList.isempty()){
           //   insert appointmentList;
            //}
        }

        if (isAfterInsert()) {
            if (isCostcoLeadSyncEnabled()) {
                List<Proposal__c> proposalsToBeUpdated = new List<Proposal__c>();
                for (Sobject sobj : Trigger.new) {
                    Proposal__c proposalObj = (Proposal__c) sobj;
                    if (proposalObj.External_Sync_System__c == Costco && proposalObj.External_Sync_Status__c == BaseClass.Status_ToBeSynced) {
                        proposalsToBeUpdated.add(proposalObj);
                    }
                }
                
                if (!proposalsToBeUpdated.isEmpty()) {
                    enqueueJobWithCheck(new CostcoLeadUpdateQuoteAmountJob(getUniqueIdList(proposalsToBeUpdated)));
                }
            } else {
                info('Costco Lead Sync is not enabled in the settings and hence not updating the lead quote amount.');
            }
        }        
    }
     public void handleOpportunitiesTrigger() {   
        //In before insert/update trigger, we will need to check if this Oppty is eligible to update costco lead cancel.        
        if (isBeforeUpdate()) {
            Map<String,String> CancelCodesMap=new Map<String,String>();
            for(Costco_Cancellation_Codes__c cancelCodes:Costco_Cancellation_Codes__c.getAll().values()){
                CancelCodesMap.put(cancelCodes.key__c,cancelCodes.value__c);
            }
            for (Integer i = 0; i < Trigger.new.size(); i++) {                
                Opportunity oldOppty = (Opportunity) Trigger.old.get(i);
                Opportunity newOppty = (Opportunity) Trigger.new.get(i);
                system.debug('ischanged?'+isCostcoOpptyChanged(oldOppty,newOppty)); 
                system.debug('ischanged2?'+newOppty.External_Sync_InProgress__c);  
                system.debug('ischanged3?'+(newOppty.stageName!=null&&newOppty.Opportunity_Status__c!=null&newOppty.Reason__c!=null&&newOppty.Reason__c.indexof(';')!=-1&&CancelCodesMap.containsKey(newOppty.stageName+'+'+newOppty.Opportunity_Status__c+'+'+newOppty.Reason__c.substring(0,newOppty.Reason__c.indexof(';'))))); 
                if (isCostcoOpportunity(newOppty)||oldOppty.Purchased_Thru__c=='Costco'&&newOppty.Purchased_Thru__c!='Costco') {
                    if (newOppty.External_Sync_InProgress__c == false && oldOppty.External_Sync_InProgress__c == true) {
                        //newLead.External_Sync_InProgress__c = false;
                    } else if (newOppty.External_Id__c != null &&isCostcoOpptyChanged(oldOppty,newOppty)
                        && !checkrecursive.costcoids.contains(newOppty.id)
                        && newOppty.External_Sync_InProgress__c !=true){
                        if(newOppty.stageName!=null&&newOppty.Opportunity_Status__c!=null&newOppty.Reason__c!=null&&CancelCodesMap.containsKey(newOppty.stageName+'+'+newOppty.Opportunity_Status__c+'+'+newOppty.Reason__c)
                        ||(newOppty.stageName!=null&&newOppty.Opportunity_Status__c!=null&&CancelCodesMap.containsKey(newOppty.stageName+'+'+newOppty.Opportunity_Status__c))
                        ||(newOppty.stageName!=null&&CancelCodesMap.containsKey(newOppty.stageName))
                        ||oldOppty.Purchased_Thru__c=='Costco'&&newOppty.Purchased_Thru__c!='Costco'
                        ||(newOppty.stageName!=null&&newOppty.Opportunity_Status__c!=null&newOppty.Reason__c!=null&&newOppty.Reason__c.indexof(';')!=-1&&CancelCodesMap.containsKey(newOppty.stageName+'+'+newOppty.Opportunity_Status__c+'+'+newOppty.Reason__c.substring(0,newOppty.Reason__c.indexof(';'))))){   
                        System.debug('eligible lead');
                        newOppty.External_Sync_System__c = Costco;
                        newOppty.External_Sync_Status__c = BaseClass.Status_ToBeSynced;
                        newOppty.External_Sync_InProgress__c = true;
                        checkrecursive.newcostcoids.add(newOppty.id);
                        }
                    }
                } else {
                    info('Lead is not applicable for costco due to its channel [' + newOppty.Channel_2__c 
                         + '] and retail lead source [' + newOppty.Lead_Source_2__c + '].');
                }
            }
        }
        if (isAfterUpdate()) {
            if (isCostcoLeadSyncEnabled()) {
                List<Opportunity> opptysToBeSynced = new List<Opportunity>();
                for (Sobject sobj : Trigger.new) {
                    Opportunity opp = (Opportunity) sobj;
                    if (opp.External_Sync_System__c == Costco && opp.External_Sync_Status__c == BaseClass.Status_ToBeSynced 
                        && !checkrecursive.costcoids.contains(opp.id)
                        && checkrecursive.newcostcoids.contains(opp.id)) {
                        opptysToBeSynced.add(opp);
                        checkRecursive.costcoids.add(opp.id); 
                    }
                }
                
                if (!opptysToBeSynced.isEmpty()) {
                    enqueueJobWithCheck(new CostcoOpptySyncJob(getUniqueIdList(opptysToBeSynced)));
                    //Add all the above leads to a static set. 
                                       
                }
                System.debug('--Print Costco ids: ' + checkRecursive.costcoids);
            } else {
                info('Costco Lead Sync is not enabled in the settings and hence not syncing to Costco.');
            }
        }   
    }
    
     public void handleServiceContractsTrigger() {   
        //In before update trigger, we will need to check if this service contract is eligible to update costco lead installation info.                
         if (isBeforeUpdate()) {           
            for (Integer i = 0; i < Trigger.new.size(); i++) {                
                Service_Contract_Event__c oldSce = (Service_Contract_Event__c) Trigger.old.get(i);
                Service_Contract_Event__c newSce = (Service_Contract_Event__c) Trigger.new.get(i);
                  if (isCostcoServiceContractEvent(newSce)) {
                    if (newSce.External_Sync_InProgress__c == false && oldSce.External_Sync_InProgress__c == true) {
                        //newLead.External_Sync_InProgress__c = false;
                    } else if (newSce.Opportunity_External_Id__c != null&& newSce.Commencement_of_Construction__c!=null && newSce.Completion_of_Construction__c!=null && newSce.Completion_of_Construction__c!=oldSce.Completion_of_Construction__c
                        && !checkrecursive.costcoids.contains(newSce.id)
                        && newSce.External_Sync_InProgress__c !=true){
                        newSce.External_Sync_System__c = Costco;
                        newSce.External_Sync_Status__c = BaseClass.Status_ToBeSynced;
                        newSce.External_Sync_InProgress__c = true;
                        checkrecursive.newcostcoids.add(newSce.id);
                        
                    }
                } else {
                    info('Lead is not applicable for costco due to its retail lead source [' + newSce.Lead_Source__c + '].');
                }
            }
        }
        if (isAfterUpdate()) {
            if (isCostcoLeadSyncEnabled()) {
                List<Service_Contract_Event__c> sceToBeUpdated = new List<Service_Contract_Event__c>();
                for (Sobject sobj : Trigger.new) {
                    Service_Contract_Event__c sceObj = (Service_Contract_Event__c)sobj;
                    if (sceObj.External_Sync_System__c == Costco && sceObj.External_Sync_Status__c == BaseClass.Status_ToBeSynced && !checkrecursive.costcoids.contains(sceObj.id)
                        && checkrecursive.newcostcoids.contains(sceObj.id)) {
                        sceToBeUpdated.add(sceObj);
                        checkRecursive.costcoids.add(sceObj.id);
                    }
                }
                
                if (!sceToBeUpdated.isEmpty()) {
                    enqueueJobWithCheck(new CostcoLeadUpdateInstallInfoJob(getUniqueIdList(sceToBeUpdated)));
                }
            } else {
                info('Costco Lead Sync is not enabled in the settings and hence not updating the lead installation info.');
            }
        }        
    }
    /**
     * TODO
     * 
     * 
     */
     /*
     public void updateLeadsQuoteAmount(List<Id> proposalIds) {
        
     }
     
    */
    public void updateLeadsQuoteAmount(List<Id> proposalIds) {
        if (!isCostcoLeadSyncEnabled()) {
            info('Costco Lead Sync is not enabled in the Settings [CostcoLeadSyncEnabled] and hence not updating the lead quote amount.');
            return;
        }

        List<Proposal__c> proposals = queryProposals(proposalIds);
        List<Appointment__c> apointmentList=new List<Appointment__c>();
        DateTime myDateTime = DateTime.newInstance(system.today().adddays(1).year(), system.today().adddays(1).month(), system.today().adddays(1).day(), 07, 0, 0);
        BaseScheduling bas=new BaseScheduling(); 
        Integer ESTTimeDiff;        
        for (Proposal__c proposal : proposals) {
            
            try {
                if (!String.isEmpty(proposal.Opportunity_External_Id__c)) {
                    proposal.External_Sync_InProgress__c = true;
                    if(!proposal.Has_Appointments__c){
                    XmlReader reader1 = costcoHttpPost('estimate', updateLeadEstimateDateDummyRequestParms(proposal,myDateTime.format('yyyy-MM-dd'),'07:00'));
                        Appointment__c appointment=new Appointment__c();
                        appointment.Event_Assigned_To__c=System.Label.Costco_Dummy_Contact;
                        appointment.opportunity__c=proposal.opportunity__c;
                        appointment.Appointment_Date_Time__c=myDateTime;
                        appointment.Appointment_End_Date_Time__c=myDateTime;    
                        appointment.Do_Not_Sync__c=true;                                                                    
                        apointmentList.add(appointment);
                    }
                    ESTTimeDiff=bas.getOffset(proposal.Lead_Created_Date_Time__c,'America/New_York')-bas.getOffset(proposal.Lead_Created_Date_Time__c,userinfo.gettimezone().tostring());
                    XmlReader reader = costcoHttpPost('quote', updateLeadQuoteAmountRequestParms(proposal,ESTTimeDiff));
                    proposal.External_Sync_Details__c = null;
                    proposal.External_Sync_Status__c = BaseClass.Status_SyncSuccess;
                }
            } catch (Exception e) {
                proposal.External_Sync_Status__c = BaseClass.Status_SyncError;
                proposal.External_Sync_Details__c = getExceptionDetails(e);
            }
        }
        if(!proposals.isEmpty()){
            update proposals;
        }
        if(!apointmentList.isempty()){
            insert apointmentList;
        }
    }
    
    public void updateInstallationInfo(List<id> serviceContractEventIds){
        List<Service_Contract_Event__c> sces = querySces(serviceContractEventIds);
        Map<String,Contract_Pricing__c> cpMap=queryContractPricing(serviceContractEventIds);
        for(Service_Contract_Event__c sceObj:sces){
            try{
            if(sceObj.Service_contract__r.opportunity__r.external_id__c!=null){
                sceObj.External_Sync_InProgress__c=true;               
                String startMonth=String.valueOf(sceObj.Commencement_of_Construction__c.month());
                String startDay=String.valueOf(sceObj.Commencement_of_Construction__c.day());
                String endMonth=String.valueOf(sceObj.Completion_of_Construction__c.month());
                String endDay=String.valueOf(sceObj.Completion_of_Construction__c.day());
                if(startMonth.length()==1){
                    startMonth='0'+startMonth;
                }
                if(startDay.length()==1){
                    startDay='0'+startDay;
                }
                if(endMonth.length()==1){
                    endMonth='0'+endMonth;
                }
                if(endDay.length()==1){
                    endDay='0'+endDay;
                }
                string startdate=String.valueOf(sceObj.Commencement_of_Construction__c.year())+'-'+startMonth+'-'+startDay;
                string enddate=String.valueOf(sceObj.Completion_of_Construction__c.year())+'-'+endMonth+'-'+endDay;
                xmlReader reader1=costcoHttpPost('sold',updateLeadInstallationInfoRequestParms(sceObj,startdate,enddate,cpMap));
                sceObj.External_Sync_Details__c = null;
                sceObj.Costco_Payment_Pre_Tax__c=updateLeadInstallationInfoRequestParms(sceObj,startdate,enddate,cpMap).get('sale_sub_total');
                sceObj.External_Sync_Status__c = BaseClass.Status_SyncSuccess;
                sceObj.External_Sync_InProgress__c=false;
            }
            }
            catch(Exception e){
                sceObj.External_Sync_Status__c = BaseClass.Status_SyncError;
                sceObj.External_Sync_Details__c = getExceptionDetails(e);
                sceObj.External_Sync_InProgress__c=false;
            }
        }
        if(!sces.isempty()){
            update sces;
        }
    }
    /*
    public Map<Id,Opportunity> getFirstProposalOpportunities(){
        Map<Id,Opportunity> firstProposalOptyIds = new Map<Id,Opportunity>();
        if (isBeforeInsert()) {
            Set<Id> optyIds = new Set<Id>();
            for (Sobject sobj : Trigger.new) {
                Proposal__c proposalObj = (Proposal__c) sobj;
                if(proposalObj.opportunity__c != null){
                    optyIds.add(proposalObj.opportunity__c);
                }           
            }
            if(optyIds != null && !optyIds.isEmpty()){
                for(Opportunity optyObj : [Select Id, name,Lead_Created_Date_Time__c,Number_of_appointments__c, (Select Id, Name from Proposals__r) from Opportunity where Id in :optyIds]){
                    if(optyObj.Proposals__r == null || optyObj.Proposals__r.isEmpty()){
                        firstProposalOptyIds.put(optyObj.Id,optyObj);
                    }
                }
            }
        }
        return firstProposalOptyIds;
    }
    */
    
    public String getServiceId() {
        //Sample costco response        
        /*
        <?xml version="1.0" encoding="UTF-8"?>
        <centah-response>
            <services>
                <service>
                    <id>178</id>
                    <title>Water Treatment</title>
                </service>
            </services>
        </centah-response>
        */
        XmlReader reader = costcoHttpGet('get_service_list', null);
        String serviceName = Sf.settingsService.getString('CostcoSyncServiceName');

        for (Integer i = 0; i < reader.getChildrenSize('services'); i++) {
            if (reader.getString('services.service[' + i + '].title') == serviceName) {
                return reader.getString('services.service[' + i + '].id');
            }
        }
        
        throw new BusinessException('Could not find a Service id for given Service name [' + serviceName + ']');
    }
    /*
    public String getStoreId() {
        //Sample stores list response       
        
        //<?xml version="1.0" encoding="UTF-8"?>
        //<centah-response>
        //    <stores>
        //        <store id="2215">439 Aurora</store>
        //        <store id="2216">440 Westminster Co</store>
        //    </stores>
        //</centah-response>
                
        XmlReader reader = costcoHttpGet('get_my_stores', null);
        String storeName = Sf.settingsService.getString('CostcoSyncStoreName');

        for (Integer i = 0; i < reader.getChildrenSize('stores'); i++) {
            if (reader.getString('stores.store[' + i + ']') == storeName) {
                return reader.getAttribute('stores.store[' + i + '].id');
            }
        }
        
        throw new BusinessException('Could not find a Store id for given store name [' + storeName + ']');
    }
*/
    public String getAdcodeId() {
        //Sample costco response        
        /*
        <?xml version="1.0" encoding="UTF-8"?>
        <centah-response>
            <adcodes>
                <adcode id="5495">Promo/MVM</adcode>
                <adcode id="5496">Brochure at Warehouse</adcode>
            </adcodes>
        </centah-response>
        */        
        XmlReader reader = costcoHttpGet('get_adcodes_list', null);
        String adcodeName = Sf.settingsService.getString('CostcoSyncAdcodeName');

        for (Integer i = 0; i < reader.getChildrenSize('adcodes'); i++) {
            if (reader.getString('adcodes.adcode[' + i + ']') == adcodeName) {
                return reader.getAttribute('adcodes.adcode[' + i + '].id');
            }
        }
        
        throw new BusinessException('Could not find a Adcode id for given Adcode name [' + adcodeName + ']');
    }

    public Map<String, String> createNewLeadRequestParms(Lead lead, String serviceId, String storeId, String adcodeId) {
        Map<String, String> parms = createUpdateCustomerRequestParms(lead);
        parms.put('service_id', serviceId);
        parms.put('store_id', storeId);
        parms.put('adcode_id', adcodeId);
        parms.put('Notes', lead.Notes__c);
        parms.put('membership_no', lead.Contact_Costco_Member_ID__c);
        
        return parms;
    }
        
    public Map<String, String> createUpdateCustomerRequestParms(Lead lead) {
        Map<String, String> parms = new Map<String, String> {
            'first_name' => lead.FirstName,
            'last_name' => lead.LastName,
            'address_street_number' => lead.Street!=null?lead.Street.substringBefore(' '):null,
            'address' => lead.Street!=null?lead.Street.substringAfter(' '):null,
            'city' => lead.City,
            'prov' => lead.State,
            'province' => lead.State,
            'zip' => lead.PostalCode,
            'postal_code' => lead.PostalCode,
            'primary_phone' => removeUSPhoneFormatting(lead.Phone),
            'secondary_phone' => removeUSPhoneFormatting(lead.Alternate_Phone__c),
            'email' => lead.Email,
            'lead_id' => lead.External_Id__c,
            'home_age' => '1978_or_later',
            'house_age' => '2'
        };

        return parms;
    }
   public Map<String, String> cancelLeadRequestParms(Opportunity Opp,String CancelCode) {
        Map<String, String> parms = new Map<String, String> {          
            'lead_id' => Opp.External_Id__c,            
            'cancel_id'=>CancelCode
        };

        return parms;
    }
    public Map<String, String> cancelLeadRequestParms(Lead leadObj,String CancelCode) {
        Map<String, String> parms = new Map<String, String> {          
            'lead_id' => leadObj.External_Id__c,            
            'cancel_id'=>CancelCode
        };

        return parms;
    }
    public Map<String, String> updateLeadEstimateDateRequestParms(Appointment__c appointment,Integer TimeDiff,Integer ESTTimeDif) {
         String estimateDateStr;
         String estimateTimeStr;         
        if(TimeDiff!=null){
            //Timezone tz = Timezone.getTimeZone(timeZoneVar);
            DateTime dtpre =appointment.Appointment_Date_Time__c.addhours(TimeDiff); 
            DateTime esttime=appointment.Lead_Created_Date_Time__c.addhours(ESTTimeDif);
            //Time actualTime=dtpre.timegmt()+tz.getOffset(dtpre);
             //system.debug(dtpre.format('MM/dd/yyyy hh:mm'));                       
             if(esttime>dtpre){
                estimateDateStr=appointment.Appointment_Date_Time__c.adddays(1).format('yyyy-MM-dd');
                estimateTimeStr='07:00';
             }
             else{
             List<String> dateTimeStrings = dtpre.format('yyyy-MM-dd HH:mm').split(' ');
             estimateDateStr = (dateTimeStrings.size() == 2) ? dateTimeStrings[0] : '' ;
             estimateTimeStr = (dateTimeStrings.size() == 2) ? dateTimeStrings[1] : '' ;
             }
        }
        else{
            List<String> dateTimeStrings = getDateTimeStrings(appointment.Appointment_Date_Time__c);
            estimateDateStr = (dateTimeStrings.size() == 2) ? dateTimeStrings[0] : '' ;
            estimateTimeStr = (dateTimeStrings.size() == 2) ? dateTimeStrings[1] : '' ;
        }
        Map<String, String> parms = new Map<String, String> {
            'estimate_date' => estimateDateStr,
            'estimate_time' => estimateTimeStr,
            'lead_id' => appointment.Opportunity_External_Id__c
        };
        return parms;
    }
    public Map<String, String> updateLeadEstimateDateDummyRequestParms(Proposal__c proposal,string estimateDateStr,String estimateTimeStr) {
         Map<String, String> parms = new Map<String, String> {
            'estimate_date' => estimateDateStr,
            'estimate_time' => estimateTimeStr,
            'lead_id' => proposal.Opportunity_External_Id__c
        };
        return parms;
    }
     public Map<String, String> updateLeadInstallationInfoRequestParms(Service_Contract_Event__c sceObj,String sDate,String eDate,Map<String,Contract_Pricing__c> cpMap) {
        String salesSubTotal;
        if(sceObj.Service_Contract__r.Opportunity__r.Program_Type__c=='Program 1'){
            if(cpMap.containsKey('Installation'+sceObj.Service_Contract__c)&&cpMap.containsKey('Panel'+sceObj.Service_Contract__c)&&cpMap.containsKey('Inverter'+sceObj.Service_Contract__c))
            salesSubTotal=String.valueOf(cpMap.get('Installation'+sceObj.Service_Contract__c).Total_Price__c+cpMap.get('Panel'+sceObj.Service_Contract__c).Total_Price__c+cpMap.get('Inverter'+sceObj.Service_Contract__c).Total_Price__c);
        }
        else if(sceObj.Service_Contract__r.Opportunity__r.Program_Type__c=='Program 2'){
            if(cpMap.containsKey('Panel'+sceObj.Service_Contract__c)&&cpMap.containsKey('Inverter'+sceObj.Service_Contract__c))
            salesSubTotal=String.valueOf(cpMap.get('Panel'+sceObj.Service_Contract__c).Total_Price__c+cpMap.get('Inverter'+sceObj.Service_Contract__c).Total_Price__c);
        }
         Map<String, String> parms = new Map<String, String> {
            'sale_sub_total' => salesSubTotal,
            'sale_federal_tax' => '0',
            'work_date' => sDate,
            'work_end_date' => eDate,
            'lead_id' => sceObj.Service_Contract__r.Opportunity__r.External_id__c
        };
        return parms;
    }
    public Map<String, String> updateLeadQuoteAmountRequestParms(Proposal__c proposal,Integer ESTTime) {
        DateTime estDateTime=proposal.Lead_Created_Date_Time__c.addhours(ESTTime);
        String amount = formatAmount(proposal.Gross_System_Purchase_Price__c).remove(',');
        List<String> dateTimeStrings = getDateTimeStrings(proposal.createddate);
        String quotedateStr = (dateTimeStrings.size() == 2) ? dateTimeStrings[0] : '' ;
        if(estDateTime.date()>proposal.createddate.date()){
            quotedateStr=estDateTime.format('yyyy-MM-dd');
        }
        Map<String, String> parms = new Map<String, String> {
            'quote_amount' => amount,
            'quote_date' => quotedateStr,
            'lead_id' => proposal.Opportunity_External_Id__c
        };
        return parms;
    }
    

    public void retrieveLeads() {
        try {
            
            List<String> costcoLeadIds = getNewLeadIds();

            DbChanges exceptions = new DbChanges();
            List<XmlReader> costcoLeads = new List<XmlReader>();
            for (String costcoLeadId : costcoLeadIds) {
                try {
                    XmlReader response = costcoHttpGet('get_lead', newStringMap('lead_id', costcoLeadId));
                    
                    acknowledgeLead(costcoLeadId);
                    
                    costcoLeads.add(response);
                    
                } catch (Exception e) {
                    exceptions.addInsert(ExceptionLogger.createException('CostcoSync/RetrieveLeads', 
                        'Exception while getting the details for lead ' +  costcoLeadId, e));
                }
            }
            
            //Now that we have retrieved all costco leads, we need to convert all of these
            //into leads using lead api. To use lead api, we will have to create a 
            //rest request json and post to lead handler.
            for (XmlReader costcoLead : costcoLeads) {
                createLeadUsingLeadApi(costcoLead);
            }
            
        } catch (Exception e) {
            info('Exception while getting the new leads. ' + getExceptionDetails(e));
        }
    }
    
    public void acknowledgeLead(String costcoLeadId) {
        costcoHttpGet('acknowledge', newStringMap('lead_id', costcoLeadId));        
    }
    
    public List<String> getNewLeadIds() {
        //This is for testing.
        //if (true) {
        //    return new String[]{'1083032'};
        //}
        
        XmlReader reader = costcoHttpGet('get_new_leads', null);
        
        List<String> costcoLeadIds = new List<String>();
        
        Integer leadsSize = reader.getChildrenSize('leads');
        for (Integer i = 0; i < leadsSize; i++) {
            costcoLeadIds.add(reader.getString('leads.lead[' + i + '].id'));
        }
        
        info('Get New Leads returned ' + costcoLeadIds.size() + ' lead ids. [' + costcoLeadIds + ']');
        
        return costcoLeadIds;
    }
    
    public void createLeadUsingLeadApi(XmlReader xmlReader) {
        info('Creating the lead using lead api for costco lead ' + xmlReader.toXml());
        
        JsonWriter writer = new JsonWriter();

        writer.write('externalLeadId', xmlReader.getString('lead.id'));
        writer.write('externalSystemCreated', true);
        writer.write('channel', 'Retail');
        writer.write('customerFirstName', xmlReader.getString('lead.customer.first-name'));
        writer.write('customerLastName', xmlReader.getString('lead.customer.last-name'));
        writer.write('customerTitle', xmlReader.getString('lead.customer.title'));
        writer.write('customerStreet', join(xmlReader.getString('lead.customer.address.street-number'), xmlReader.getString('lead.customer.address.street'), ' '));
        writer.write('customerCity', xmlReader.getString('lead.customer.address.city'));
        writer.write('customerState', xmlReader.getString('lead.customer.address.province'));
        writer.write('customerPostalCode', xmlReader.getString('lead.customer.address.postal-code'));
        writer.write('customerPrimaryPhone', xmlReader.getString('lead.customer.primary-phone.phone'));
        writer.write('leadOrgLocationId', '0016000000zeJNx');
        
        RestRequest restReq = new RestRequest();        
        restReq.requestBody = Blob.valueOf(writer.toPrettyJson());
            info('Sending API Request method=' + restReq.httpMethod +', uri=' + restReq.requestURI + ', resourcePath=' + restReq.resourcePath
                       + ', body=' + restReq.requestBody.toString());
        
        //RestResponse restResp = LeadApiLeadsEndpoint.httpPost(restReq, new RestResponse());
        
        //info('Received response from lead api ' + restResp.responseBody.toString());
    }
    
    public Boolean isCostcoLeadSyncEnabled() {
        return Sf.settingsService.getBoolean('CostcoLeadSyncEnabled', false);
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
                Costco_Api_Counter__c,
                Costco_Store_Id__c,
                status,
                Lead_Status__c,
                Reason__c,
                Purchased_Thru__c                
            from Lead
            where id in :leadIds
        ];
    }
    public Map<id,Opportunity> appOpptyMap(List<Id> OpptyIds){
        Map<id,Opportunity> apOpptyMap=new map<id,Opportunity>();
        for(Opportunity opp:[select id,Account.TimeZone__c ,Account.HasDaylightSavings__c from opportunity where id in:OpptyIds]){
            if(opp.Account.TimeZone__c!=null)
            apOpptyMap.put(opp.id,opp);
        }
        return apOpptyMap;
    }
    
    public List<Appointment__c> queryAppointments(List<Id> appointmentIds) {
        return [
            select
                Id, 
                Name,
                Opportunity__c,
                Appointment_Date_Time__c,
                Opportunity_External_Id__c, 
                External_Sync_System__c,
                External_Sync_Status__c,
                Lead_Created_Date_Time__c
            from Appointment__c
            where id in :appointmentIds
        ];
    }
    public List<Opportunity> queryOpptys(List<Id> OpptyIds) {
        return [
            select
                Id,                                                 
                External_Id__c, 
                External_Sync_Details__c,
                External_Sync_System__c,
                External_Sync_Status__c,
                stageName,
                Opportunity_Status__c,
                Reason__c,
                Purchased_Thru__c
            from Opportunity
            where id in :OpptyIds
        ];
    }
    public List<Proposal__c> queryProposals(List<Id> proposalIds) {
        return [
            select
                Id, 
                Name,
                Opportunity__c,
                Proposal_amount__c,
                createddate,
                Opportunity_External_Id__c, 
                External_Sync_System__c,
                External_Sync_Status__c,
                Has_Appointments__c,
                Lead_Created_Date_Time__c,
                Number_of_Proposals__c,
                Gross_System_Purchase_Price__c
            from Proposal__c
            where id in :proposalIds
        ];
    }
    public List<Service_Contract_Event__c> querySces(List<Id> sceIds) {
        return [
            select
                Id,                 
                External_Sync_System__c,
                Service_contract__r.opportunity__r.external_id__c,
                Service_contract__r.proposal__r.Gross_System_Purchase_Price__c,
                External_Sync_Status__c,
                createddate,
                Service_contract__r.opportunity__r.Program_Type__c,
                Service_contract__r.Modules_Price__c,
                Service_contract__r.Power_Electronic_Price__c,
                Service_contract__r.Installation_Price__c,
                Commencement_of_Construction__c,
                Completion_of_Construction__c                                                
            from Service_Contract_Event__c
            where id in :sceIds
        ];
    } 
    public Map<String,Contract_Pricing__c> queryContractPricing(List<id> sceIds){
        Map<String,Contract_Pricing__c> cpMap=new Map<String,Contract_Pricing__c>();
        for(Contract_Pricing__c cp:[select id,Total_Price__c,Service_Contract__c,Asset_Type__c from Contract_Pricing__c where Service_Contract__r.Service_Contract_Event__c in:sceIds]){
            cpMap.put(cp.Asset_Type__c+cp.Service_Contract__c,cp);
        }
        return cpMap;
    }   
    public XmlReader costcoHttpGet(String action, Map<String, String> params) {
        return costcoHttpRequest('GET', action, params);
    }
    
    public XmlReader costcoHttpPost(String action, Map<String, String> params) {
        return costcoHttpRequest('POST', action, params);
    }
    
    public XmlReader costcoHttpRequest(String method, String action, Map<String, String> params) {
        
        if (authToken == null) {
            authToken = getAuthToken();
        }
        
        if (params == null) {
            params = new Map<String, String>();
        }
        
        params.put('_[action]', action);
        params.put('_[auth_token]', authToken);
        
        BaseClass.HttpDetails httpDetails;
        
        if (method == 'POST') {
            httpDetails = httpPostDetails(getCostcoSyncUrl(), createHttpParmsString(params), null, null);
        } else {
            httpDetails = httpGetDetails(getCostcoSyncUrl(), null, params, null);
        }
        String response = httpDetails.response.getBody();
        
        XmlReader reader = new XmlReader(response);
        String errorCode = reader.getAttribute('errors.error.code');
        String errorMessage = reader.getString('errors.error');
        
        //There are some error messages which can be ignored like "This lead was already acknowledged"
        if (errorCode == '1000') {
            info('Costco error response ' + response + ' is ignored.');
            return null;
        }
        
        if (isNotEmpty(errorMessage)) {
            throw new UnsuccessfulHttpResponseException(httpDetails.request, httpDetails.response, httpDetails.requestHeaders);
        }
        
        return reader;
    }
    
    public String getAuthToken() {
        return getAuthToken(Sf.settingsService.getString('CostcoSyncUserId'),
            Sf.settingsService.getString('CostcoSyncPassword'));
    }
    
    public String getAuthToken(String userId, String password) {
        Map<String, String> parms = new Map<String, String>{
            '_[action]' => 'auth',
            'login' => userId,
            'passwd' => password
        };
        
        String response = httpGet(getCostcoSyncUrl(), parms);
        XmlReader reader = new XmlReader(response);
        
        String errorMessage = reader.getString('errors.error');
        if (isNotEmpty(errorMessage)) {
            throw new SystemException(response);
        }
        
        return reader.getString('auth-token');
    }
    
    public String getCostcoSyncUrl() {
        return Sf.settingsService.getString('CostcoSyncUrl', isSandbox()?'https://costcousdemo.centah.com/xml.php':
                                           'https://costcous.centah.com/xml.php');
    }
}