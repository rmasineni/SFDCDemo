public class AmbassadorSyncServiceImpl extends BaseClass implements AmbassadorSyncService {

    public static final String ReferralStatus = 'Referral_Status__c';
    public static final String PaymentStatus1 = 'Referrer_Status_1__c';
    public static final String PaymentStatus2 = 'Referrer_Status_2__c';
    public static final String PaymentStatus3 = 'Referrer_Status_3__c';
    
    public static final String Field_SyncStatus = 'Ambassador_Sync_Status__c';
    public static final String Field_SyncField = 'Ambassador_Sync_Field__c';
    
    /**
     * This method handles the before insert, update trigger events and checks for updates
     * of applicable fields. If applicable fields are updated, then it will try to update
     * ambassador with new values.
     */
    public void handleReferralsTrigger() {
        //When inserted, we will post the status to ambassador system.
        if (isBeforeInsert()) {
            setValue(Trigger.new, 'Ambassador_Sync_Status__c', Status_ToBeSynced);
            setValue(Trigger.new, 'Ambassador_Sync_Field__c', ReferralStatus);
        }
        
        //In the before update, we will capture the status of the referral and in after trigger,
        //we will handle the sync in future event.
        if (isBeforeUpdate()) {
            for (Integer i = 0; i < Trigger.new.size(); i ++) {
                Referral_Input__c oldReferral = (Referral_Input__c) Trigger.old.get(i);
                Referral_Input__c newReferral = (Referral_Input__c) Trigger.new.get(i);
                
                System.debug('##Old Referral###'+ oldReferral);
                System.debug('##New Referral###'+ newReferral);
                
                String fieldToBeSynced;
                
                if (isChanged(oldReferral, newReferral, PaymentStatus1)) {
                    fieldToBeSynced = PaymentStatus1;
                    System.debug('##fieldToBeSyncedl###'+ fieldToBeSynced);
                    
                } else if (isChanged(oldReferral, newReferral, PaymentStatus2)) {
                    fieldToBeSynced = PaymentStatus2;
                    System.debug('##fieldToBeSynced2###'+ fieldToBeSynced);

                } else if (isChanged(oldReferral, newReferral, PaymentStatus3)) {
                    fieldToBeSynced = PaymentStatus3;
                   System.debug('##fieldToBeSynced3###'+ fieldToBeSynced); 

                } else if (isChanged(oldReferral, newReferral, ReferralStatus)) {
                    fieldToBeSynced = ReferralStatus;
                    System.debug('##fieldToBeSynced4###'+ fieldToBeSynced);
                }
                
                if (fieldToBeSynced != null&&!checkrecursive.ambassadorReferrals.contains(newReferral.id)) {
                    newReferral.Ambassador_Sync_Field__c = fieldToBeSynced;
                    newReferral.Ambassador_Sync_Status__c = Status_ToBeSynced;
                    checkrecursive.ambassadornewReferrals.add(newReferral.id);
                  System.debug('##fieldToBeSynced4###'+ newReferral.Ambassador_Sync_Field__c);  
                }
            }
        }
        
        if  (isAfterInsertOrUpdate()) {
            if (isAmbassadorRealtimeSyncEnabled()) {
                List<Sobject> recordsToBeSynced = getMatchingRecords(Trigger.new, 
                    Field_SyncStatus, Status_ToBeSynced);
                List<Referral_input__c> referralstoBeSynched=new List<referral_input__c>();    
                System.debug('##List Of Trigger.new####:' + Trigger.new);
                System.debug('##Field_SyncStatus####:' + Field_SyncStatus);
                System.debug('##Status_ToBeSynced####:' + Status_ToBeSynced);
                System.debug('##List Of Referral Records####:' + recordsToBeSynced);
                for(sobject sObj:recordsToBeSynced){
                    Referral_input__c ref=(Referral_input__c)sObj;
                   System.debug('This is After insert:'+ isAfterInsert());
                   System.debug('This is After update:'+ isAfterUpdate());  
                   System.debug('##AmbassadorReferrals####:' + checkrecursive.ambassadorReferrals.contains(ref.id));
                   System.debug('##AmbassadornewReferrals####:' + checkrecursive.ambassadornewReferrals.contains(ref.id)); 
                   System.debug('##isAfterInsert####:' + (isAfterInsert() && !checkrecursive.ambassadorReferrals.contains(ref.id)));
                   System.debug('##isAfterUpdate####:' + (isAfterUpdate() && !checkrecursive.ambassadorReferrals.contains(ref.id) && checkrecursive.ambassadornewReferrals.contains(ref.id)));
                   // if(!checkrecursive.ambassadorReferrals.contains(ref.id)&&checkrecursive.ambassadornewReferrals.contains(ref.id)){
                      if( (isAfterInsert() && !checkrecursive.ambassadorReferrals.contains(ref.id)) ||
                          (isAfterUpdate() && !checkrecursive.ambassadorReferrals.contains(ref.id) && checkrecursive.ambassadornewReferrals.contains(ref.id)) 
                        ) {
                  // if(!checkrecursive.ambassadorReferrals.contains(ref.id)) {    
                          System.debug('This is After insert:'+ isAfterInsert());
                          System.debug('This is After update:'+ isAfterUpdate()); 
                          referralstoBeSynched.add(ref);
                          checkrecursive.ambassadorReferrals.add(ref.id);
                          System.debug('##List Of referralstoBeSynched####:' + referralstoBeSynched);  
                         }
                }
                if (!referralstoBeSynched.isEmpty()) 
                {
                  //  if(controlContactTriggerRecursion.ControlReferralsTrigger)
                //  { 
                      enqueueJobWithCheck(new AmbassadorSyncJob(getUniqueIdList(referralstoBeSynched)));
                      controlContactTriggerRecursion.ControlReferralsTrigger = false;
                //    }    
                }
            }
        }
    }
    

   /**
     * This method handles the before insert, update trigger events and checks for referrals submitted via non Ambassador. 
     * Post the referrals submitted to Ambassador and get the 
     *  Id in response and update associated lead/oppty. 
     */    
     public void handleNonAmbassadorReferrals() {
        //When inserted, we will post the status to ambassador system.
        if (isBeforeInsert()) {
              setValue(Trigger.new, 'Ambassador_Sync_Status__c', Status_ToBeSynced);
         //   setValue(Trigger.new, 'Ambassador_Sync_Field__c', ReferralStatus);
        }
        
        //In the before update, we will capture the status of the referral and in after trigger,
        //we will handle the sync in future event.
        if (isBeforeUpdate()) {
            for (Integer i = 0; i < Trigger.new.size(); i ++) {
                Referral_Input__c oldReferral = (Referral_Input__c) Trigger.old.get(i);
                Referral_Input__c newReferral = (Referral_Input__c) Trigger.new.get(i);
               
              if ( (isChanged(oldReferral, newReferral, 'Lead__c') || isChanged(oldReferral, newReferral, 'Opportunity__c')) 
                  &&!checkrecursive.NonAmbassadorReferrals.contains(newReferral.id) ) {
                     newReferral.Ambassador_Sync_Status__c = Status_ToBeSynced;
					 checkrecursive.NonAmbassadornewReferrals.add(newReferral.id);
                }
            }
        }
         
         List<Sobject> recordsToBeSynced1 = Trigger.new; 
         System.debug('This is recordsToBeSynced1'+ recordsToBeSynced1);
        
        if  (isAfterInsertOrUpdate()) {
            if (isAmbassadorRealtimeSyncEnabled()) {
                
           /*     List<Sobject> recordsToBeSynced = Trigger.new;
                  
                enqueueJobWithCheck(new AmbassadorCommissionSyncJob(getUniqueIdList(recordsToBeSynced)));  
                System.debug('This is recordsToBeSynced'+ recordsToBeSynced); */
                
               List<Sobject> recordsToBeSynced = getMatchingRecords(Trigger.new, 
                    Field_SyncStatus, Status_ToBeSynced);
			   List<Referral_input__c> referralstoBeSynched=new List<referral_input__c>(); 	
                System.debug('##List Of Records####:' + recordsToBeSynced);
			   for(sobject sObj:recordsToBeSynced){
                    Referral_input__c ref=(Referral_input__c)sObj;
                   System.debug('##List Of Records####:' + recordsToBeSynced);
                   System.debug('##NonAmbassadorReferrals####:' + checkrecursive.NonAmbassadorReferrals.contains(ref.id));
                   System.debug('##NonAmbassadornewReferrals####:' + checkrecursive.NonAmbassadornewReferrals.contains(ref.id));
                // if(!checkrecursive.NonAmbassadorReferrals.contains(ref.id)&&checkrecursive.NonAmbassadornewReferrals.contains(ref.id)){
                   if( (isAfterInsert() && !checkrecursive.NonAmbassadorReferrals.contains(ref.id)) || 
                       (isAfterUpdate() && !checkrecursive.NonAmbassadorReferrals.contains(ref.id) && checkrecursive.NonAmbassadornewReferrals.contains(ref.id))
                     ) {
               //  if(!checkrecursive.NonAmbassadorReferrals.contains(ref.id)) {    
                             referralstoBeSynched.add(ref);
                             checkrecursive.NonAmbassadorReferrals.add(ref.id);
                             System.debug('##List Of referralstoBeSynched####:' + referralstoBeSynched);   
                       }
                }
                
                if (!referralstoBeSynched.isEmpty()) 
                {
                     if(controlContactTriggerRecursion.ControlNonAmbassadorReferralsTrigger)
                    { 
                       enqueueJobWithCheck(new AmbassadorCommissionSyncJob(getUniqueIdList(referralstoBeSynched)));
                       controlContactTriggerRecursion.ControlNonAmbassadorReferralsTrigger = false;  
                    }    
                } 
            }
        }
    }


    /**
     * This method handles ERP Contacts associated to Service Contracts and publish the contact to Ambassador
     * and get Ambassador Id in Response. 
     */
    public void handleERPContacts() {
        //When inserted, we will check if the contact is associated to Service Contract. 
        if (isBeforeInsert()) {
          //    setValue(Trigger.new, 'Ambassador_Sync_Status__c', Status_ToBeSynced);
          //  setValue(Trigger.new, 'Ambassador_Sync_Field__c', ReferralStatus);
        }

        //In before insert trigger, we will need to check if this Contact is applicable for Ambassador sync.
        
        if (isBeforeInsert()) {
            
            for (Sobject sobj : Trigger.new) {
                Contact contactObj = (Contact) sobj;
                if (contactObj.ERP_Contact_of_Record__c == true && !checkrecursive.ambassadorContacts.contains(contactObj.lastname)) {
                    contactObj.Ambassador_Sync_Status__c = Status_ToBeSynced;
                    checkrecursive.ambassadornewContacts.add(contactObj.lastname);
                }
            }
        }

        
        //In before Update trigger, we will need to check if this Contact is applicable for Ambassador sync.
        
        if (isBeforeUpdate()) {
            for (Integer i = 0; i < Trigger.new.size(); i ++) {
                Contact oldContact = (Contact) Trigger.old.get(i);
                Contact newContact = (Contact) Trigger.new.get(i);
                if (isChanged(oldContact, newContact, 'ERP_Contact_of_Record__c') && newContact.ERP_Contact_of_Record__c == true&& !checkrecursive.ambassadorContacts.contains(newContact.lastname)) {
                    newContact.Ambassador_Sync_Status__c = Status_ToBeSynced;
                    checkrecursive.ambassadornewContacts.add(newContact.lastname);
                }
            }
        }
          List<Sobject> recordsToBeSynced1 = Trigger.new; 
         System.debug('This is recordsToBeSynced1'+ recordsToBeSynced1);
          
        if  (isAfterInsertOrUpdate()) {
            
            if (isAmbassadorRealtimeSyncEnabled()) {
                
             //   List<Sobject> recordsToBeSynced = Trigger.new;
                List<Sobject> recordsToBeSynced = getMatchingRecords(Trigger.new, Field_SyncStatus, Status_ToBeSynced);
                List<Contact> contacttobesynced=new List<Contact>();
                for(sobject sObj:recordsToBeSynced){
                    Contact cont=(Contact)sObj;
                    if(!checkrecursive.ambassadorContacts.contains(cont.lastname)&&checkrecursive.ambassadornewContacts.contains(cont.lastname)){
                     contacttobesynced.add(cont);
                     checkrecursive.ambassadorContacts.add(cont.lastname);
                    }
                }
                if (!contacttobesynced.isEmpty()) 
                {
                   if(controlContactTriggerRecursion.ControlERPContactsTrigger)
                    { 
                     enqueueJobWithCheck(new AmbassadorERPSyncJob(getUniqueIdList(contacttobesynced)));    
                     System.debug('This is recordsToBeSynced'+ contacttobesynced);
                     controlContactTriggerRecursion.ControlERPContactsTrigger = false;   
                    }   
                }
            }
        }
    }
    public void handleInactiveRefereeContacts() {
        //When inserted, we will check if the contact is associated to Service Contract. 
        if (isBeforeInsert()) {
          //    setValue(Trigger.new, 'Ambassador_Sync_Status__c', Status_ToBeSynced);
          //  setValue(Trigger.new, 'Ambassador_Sync_Field__c', ReferralStatus);
        }

        //In before insert trigger, we will need to check if this Contact is applicable for Ambassador sync.
        
        if (isBeforeInsert()) {
            
            for (Sobject sobj : Trigger.new) {
                Contact contactObj = (Contact) sobj;
                if (contactObj.ERP_Contact_of_Record__c == true &&!checkrecursive.ActivateAmbassadorContacts.contains(contactObj.lastname)) {
                    contactObj.Ambassador_Sync_Status__c = Status_ToBeSynced;
                    checkrecursive.ActivateAmbassadornewContacts.add(contactObj.lastname);
                }
            }
        }

        
        //In before Update trigger, we will need to check if this Contact is applicable for Ambassador sync.
        
        if (isBeforeUpdate()) {
            for (Integer i = 0; i < Trigger.new.size(); i ++) {
                Contact oldContact = (Contact) Trigger.old.get(i);
                Contact newContact = (Contact) Trigger.new.get(i);
                if (isChanged(oldContact, newContact, 'ERP_Contact_of_Record__c') && newContact.ERP_Contact_of_Record__c == true &&  !checkrecursive.ActivateAmbassadorContacts.contains(newContact.lastname)) {
                    newContact.Ambassador_Sync_Status__c = Status_ToBeSynced;
                     checkrecursive.ActivateAmbassadornewContacts.add(newContact.lastname);
                }
            }
        }
          List<Sobject> recordsToBeSynced1 = Trigger.new; 
         System.debug('This is recordsToBeSynced1'+ recordsToBeSynced1);
          
        if  (isAfterInsertOrUpdate()) {
            
            if (isAmbassadorRealtimeSyncEnabled()) {
                
             //   List<Sobject> recordsToBeSynced = Trigger.new;
                List<Sobject> recordsToBeSynced = getMatchingRecords(Trigger.new, Field_SyncStatus, Status_ToBeSynced);
                List<Contact> contacttobesynced=new List<Contact>();
                for(sobject sObj:recordsToBeSynced){
                    Contact cont=(Contact)sObj;
                    if(!checkrecursive.ActivateAmbassadorContacts.contains(cont.lastname)&&checkrecursive.ActivateAmbassadornewContacts.contains(cont.lastname)){
                     contacttobesynced.add(cont);
                     checkrecursive.ActivateAmbassadorContacts.add(cont.lastname);
                    }
                }
                if (!contacttobesynced.isEmpty()) 
                {
                   if(controlContactTriggerRecursion.ControlActivateContact)
                    { 
                     enqueueJobWithCheck(new ActivateRefereeSyncjob(getUniqueIdList(contacttobesynced)));    
                     System.debug('This is recordsToBeSynced'+ contacttobesynced);
                     controlContactTriggerRecursion.ControlActivateContact = false;   
                    }   
                }
            }
        }
    }    
    
    public Boolean isAmbassadorRealtimeSyncEnabled() {
        return isAmbassadorSyncEnabled() && Sf.settingsService.getBoolean('AmbassadorRealtimeSyncEnabled', true);
    }

    public Boolean isAmbassadorSyncEnabled() {
        return Sf.settingsService.getBoolean('AmbassadorSyncEnabled', false);
    }
    
    public void syncReferrals(List<Id> referralIds) {
        if (!isAmbassadorSyncEnabled()) {
            info('Ambassador Sync is not enabled (in Settings__c) and hence terminating the Sync Process.');
            return;
        }
        
        String ambassadorSyncUrl;

        List<Referral_Input__c> referrals = queryReferrals(referralIds);
        for (Referral_Input__c referral : referrals) {
            System.debug('### This is list of Referrals###:'+ referral);
            try {
                if (referral.Lead__r.Commission_ID__c == null && referral.Opportunity__r.Commission_Id__c == null) {
              //   if (referral.Lead__r.Commission_ID__c == null ) {
                    referral.Ambassador_Sync_Status__c = 'Commission Id Empty';
                    continue;
                }
                
                if (ambassadorSyncUrl == null) {
                    ambassadorSyncUrl = getAmbassadorSyncUrl();  
                    System.debug('### This is list of ambassadorSyncUrl###:'+ ambassadorSyncUrl);
                }
                
                String paymentStatus;
                
                if (referral.Ambassador_Sync_Field__c == PaymentStatus1
                   || referral.Ambassador_Sync_Field__c == PaymentStatus2
                   || referral.Ambassador_Sync_Field__c == PaymentStatus3) 
                {
                    paymentStatus = (String) referral.get(referral.Ambassador_Sync_Field__c);
                    system.debug('### This is Payment Status###:'+ paymentStatus);
                }
                
                JsonWriter writer = new JsonWriter();
                 if (referral.Lead__r.Commission_ID__c != null)
                { 
                 System.debug('This is Commission_ID__c:'+ referral.Lead__r.Commission_ID__c);   
                 writer.write('commission_uid', referral.Lead__r.Commission_ID__c);
                }   
                if(referral.Opportunity__r.Commission_Id__c!=null)
                {
                 System.debug('This is Commission_ID__c:'+ referral.Opportunity__r.Commission_Id__c);   
                 writer.write('commission_uid', referral.Opportunity__r.Commission_ID__c);
                }    
              //  writer.write('transaction_uid', referral.name);
                writer.write('event_data1', referral.Referral_Status__c);
                System.debug('This is writer:'+ writer);
                System.debug('This is ref status:'+ referral.Referral_Status__c);
                if (paymentStatus != null) {
                    writer.write('event_data2', paymentStatus);
                    System.debug('This is writer:'+ writer);
                }
                
                httpPost(ambassadorSyncUrl, writer.toPrettyJson(), new Map<String, String>{'Content-Type'=>'application/json'}, null);
                
                referral.Ambassador_Sync_Status__c = Status_SyncSuccess;
                referral.Ambassador_Sync_Details__c = null;
                
            } catch (Exception e) {
                referral.Ambassador_Sync_Status__c = Status_SyncError;
                referral.Ambassador_Sync_Details__c = getExceptionDetails(e);
            }
        }
       // if(controlContactTriggerRecursion.ControlAmbReferralsTrigger)
      //  {    
        //    controlContactTriggerRecursion.ControlAmbReferralsTrigger = false;
            update referrals;
      //  }    
    }

    public void syncERPContacts(List<Id> contactIds) 
    {
       if(controlContactTriggerRecursion.ControlERPContactsTrigger)
      { 
        if (!isAmbassadorSyncEnabled()) {
            info('Ambassador Sync is not enabled (in Settings__c) and hence terminating the Sync Process.');
            return;
        }
        
        String ambassadorERPContactSyncUrl;
      //  String ambassadorActivateSyncUrl;  
        system.debug('This is ERP contact Sync URL : '+ ambassadorERPContactSyncUrl);

        List<Contact> contacts = queryContacts(contactIds);
        List<ServiceContract> SCcontacts = querySCContacts(contactIds);
        Map<Id,Id> MapOfSCandContId = new Map<Id, Id>();
       If(!SCcontacts.isEmpty())
       {    
          For(ServiceContract SCExist :SCcontacts)
        {
            MapOfSCandContId.put(SCExist.ContactId,SCExist.Id);
        }
       }     
        
        for (Contact contact : contacts) {
             system.debug('This is list of Contacts:'+ contacts);
            If(MapOfSCandContId.containsKey(contact.id))
           {     
            try {

                if (ambassadorERPContactSyncUrl == null) {
                    ambassadorERPContactSyncUrl = getAmbassadorERPContactSyncUrl();     
                    System.debug('This is getAmbassadorERPContactSyncUrl:'+ getAmbassadorERPContactSyncUrl());
                }

                
                Map<String, String> parms = new Map<String, String>{
                    'email' => contact.email,
                    'first_name' => contact.firstname,
                    'last_name' => contact.lastname,
                    'auto_create' => '1',  
                    'add_to_group_id' => '12',    
                    'set_groups' =>'12',
                    'email_new_ambassador'=>'0'    
                };
                
                Map<String,String> HeaderMap = new Map<String,String>();
                HeaderMap.put('Connection', 'close');    
                
                    
          /*    HttpRequest req = new HttpRequest();
                req.setMethod('GET');
                req.setHeader('Connection', 'close');
                AmbassadorSyncServiceImpl TempObj = new AmbassadorSyncServiceImpl();
                String EndURL = TempObj.getAmbassadorERPContactSyncUrl();
                System.debug('This ERP URL:'+ TempObj.getAmbassadorERPContactSyncUrl());
                EndURL  = EndURL +'?email='+contact.email+'&first_name='+contact.FirstName+'&last_name='+contact.LastName+'&auto_create=1';
                System.debug('This ERP URL:'+ EndURL);
             // String EndURL2 =' https://getambassador.com/api/v2/sunrun-TEST/20702ee1f2009d7ff43df5e89d3887a7/json/ambassador/get?email='+Con.email+'&first_name='+Con.FirstName+'&last_name='+Con.LastName+'&auto_create=1';
                req.setEndpoint(EndURL);
                Http http = new Http();
                System.debug('This is req:'+req);
                HttpResponse res = http.send(req);


               JSONParser parser = JSON.createParser(res.getBody());
               system.debug('JSON PARESER___________________'+parser );
               system.debug('Respone'+res.getBody()); */
           //  httpGet(ambassadorERPContactSyncUrl,HeaderMap,parms,null); 
               BaseClass TempObj = new BaseClass();
               JSONParser parser = JSON.createParser(TempObj.httpGet(ambassadorERPContactSyncUrl,HeaderMap,parms,null)); 
                
               while (parser.nextToken() != null)
               {
                  if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'platform_id'))
                  {
                   parser.nextToken();
                   system.debug('#$%$@$$##$PlatformID######'+parser.getText());
                   contact.Ambassador__Ambassador_ID__c = parser.getText();
                  }
                  if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'campaign_uid'))
                  {
                   parser.nextToken();
                   system.debug('#$%$@$$##$campaign_uid######'+parser.getText());
                     contact.campaign_uid__c = parser.getText();
                  }
                   if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'amount'))
                  {
                   parser.nextToken();
                   system.debug('#$%$@$$##$amount######'+parser.getText());
                   contact.Commission_Amount__c = parser.getText();
                   system.debug('#$%$@$$##$amount######'+contact.Commission_Amount__c);   
                  }
               } 
                    

               //   httpGet(ambassadorERPContactSyncUrl, createHttpParmsString(parms));
              //    Contact.campaign_uid__c='test';
                  contact.Ambassador_Sync_Status__c = Status_SyncSuccess;
                  contact.Ambassador_Sync_Details__c = null;
                
            } catch (Exception e) {
                  contact.Ambassador_Sync_Status__c = Status_SyncError;
                  contact.Ambassador_Sync_Details__c = getExceptionDetails(e);
            }
            
           }     
        }
        update contacts;
        controlContactTriggerRecursion.ControlERPContactsTrigger = false;
        System.debug('###This is contact to upd#######:'+ contacts);
      }
    }
       public void ActivateRefereeContacts(List<Id> contactIds) 
    {
       System.debug('This is cont List: '+ contactIds); 
       if(controlContactTriggerRecursion.ControlActivateContact)
      { 
        if (!isAmbassadorSyncEnabled()) {
            info('Ambassador Sync is not enabled (in Settings__c) and hence terminating the Sync Process.');
            return;
        }
        String ambassadorActivateSyncUrl;  
        system.debug('This is ambassadorActivateSyncUrl : '+ ambassadorActivateSyncUrl);

        List<Contact> contacts = queryContacts(contactIds);
        List<ServiceContract> SCcontacts = querySCContacts(contactIds);
        Map<Id,Id> MapOfSCandContId = new Map<Id, Id>();
        If(!SCcontacts.isEmpty())
        {    
            For(ServiceContract SCExist :SCcontacts)
          {
            MapOfSCandContId.put(SCExist.ContactId,SCExist.Id);
            System.debug('###Map Keys###:'+MapOfSCandContId.keySet());
            System.debug('###Map Values###:'+ MapOfSCandContId.values());
          }
        }    
        
        for (Contact contact : contacts) {
             system.debug('This is list of Contacts:'+ contacts);
             system.debug('###Map contains##:'+ MapOfSCandContId.containsKey(contact.id));
            If(MapOfSCandContId.containsKey(contact.id))
           {    
            try {

                if (ambassadorActivateSyncUrl == null) {
                    ambassadorActivateSyncUrl = getAmbassadorActivateSyncUrl();     
                    System.debug('This is getAmbassadorERPContactSyncUrl:'+ getAmbassadorActivateSyncUrl());
                }

                
                Map<String, String> parms = new Map<String, String>{
                    'email' => contact.email,
                    'is_deactivated' =>'0'    
                };
                
                Map<String,String> HeaderMap = new Map<String,String>();
                HeaderMap.put('Connection', 'close');    
                
                 JsonWriter writer = new JsonWriter();
                 if (contact.email != null)
                { 
                 System.debug('###This is Cont Email###:'+ contact.email);   
                 writer.write('email', contact.email);
                 writer.write('is_deactivated','0');   
                }
                httpPost(ambassadorActivateSyncUrl, writer.toPrettyJson(), new Map<String, String>{'Content-Type'=>'application/json'}, null); 
               //   httpGet(ambassadorERPContactSyncUrl, createHttpParmsString(parms));
              //    Contact.campaign_uid__c='test';
                  contact.Ambassador_Sync_Status__c = Status_SyncSuccess;
                  contact.Ambassador_Sync_Details__c = null;
                
            } catch (Exception e) {
                  contact.Ambassador_Sync_Status__c = Status_SyncError;
                  contact.Ambassador_Sync_Details__c = getExceptionDetails(e);
            }
           }     
        }
        update contacts;
        controlContactTriggerRecursion.ControlActivateContact = false;
        System.debug('###This is contact to upd#######:'+ contacts);
      }
    } 
     public void syncNonAmbassadorReferrals(List<Id> referralIds) {
         
     if(controlContactTriggerRecursion.ControlNonAmbassadorReferralsTrigger)
     {   
         if (!isAmbassadorSyncEnabled()) {
            info('Ambassador Sync is not enabled (in Settings__c) and hence terminating the Sync Process.');
            return;
        }
        
        String NonAmbassadorReferralSyncUrl;
        system.debug('This is ERP contact Sync URL : '+ NonAmbassadorReferralSyncUrl);

        List<Referral_Input__c> referrals = queryReferrals(referralIds);
        List<Id> ListOfContIds = New List<Id>(); 
        List<Id> ListOfLeads = New List<Id>(); 
        List<Id> ListOfOppts = New List<Id>(); 
        List<Lead> ListOfLeadsToUpd = new List<Lead>(); 
        List<Opportunity> ListOfOpptysToUpd = new List<Opportunity>(); 
        for (Referral_Input__c referral : referrals)
           {
                  System.debug('### This is list of Referrals###:'+ referral);
               If(referral.Source_Contact_Id__c!=null)
              {
                  ListOfContIds.add(referral.Source_Contact_Id__c);
                  ListOfLeads.add(referral.Lead__c);
                  ListOfOppts.add(referral.Opportunity__c);
              }
           }
        List<Contact> Contacts = queryReferrerContacts(ListOfContIds); 
        List<Lead> Leads = queryLeads(ListOfLeads);  
        List<Opportunity> Oppts = queryOppts(ListOfOppts); 
        Map<Id,String> MapOfContIdAmbassadorId = new Map<Id,String>(); 
        Map<Id,String> MapOfContIdCampaignId = new Map<Id,String>();
        Map<Id,String> MapOfContIdEmail = new Map<Id,String>(); 
        Map<Id,Lead> MapOfIdToLead = new Map<Id,Lead>(); 
        Map<Id,Opportunity> MapOfIdToOpportunity = new Map<Id,Opportunity>(); 
         
        for(Contact con: Contacts)
          {
            MapOfContIdAmbassadorId.put(con.id,con.Ambassador__Ambassador_ID__c);
            MapOfContIdCampaignId.put(con.id, con.campaign_uid__c);
            MapOfContIdEmail.put(con.id,con.Email);  
          }
        
        for(Lead l: Leads)
          {
            MapOfIdToLead.put(l.id,l);
          }  
         for(Opportunity opps: Oppts)
          {
            MapOfIdToOpportunity.put(opps.id,opps);
          }  
         
        for (Referral_Input__c referral : referrals) {
            system.debug('This is list of referral:'+ referral);
         //   system.debug('##This is referral Lead##:'+ MapOfIdToLead.containsKey(referral.Lead__c));
        //    system.debug('##This is referral Lead Commission Id##:'+ MapOfIdToLead.get(referral.Lead__c).Commission_ID__c);
            If((MapOfIdToLead.containsKey(referral.Lead__c) && MapOfIdToLead.get(referral.Lead__c).Commission_ID__c== null) || (MapOfIdToOpportunity.containsKey(referral.Opportunity__c) && MapOfIdToOpportunity.get(referral.Opportunity__c).Commission_ID__c== null)) 
            {    
            try {

                if (NonAmbassadorReferralSyncUrl == null) {
                    NonAmbassadorReferralSyncUrl = getNonAmbassadorReferralSyncUrl();     
                    System.debug('This is getAmbassadorERPContactSyncUrl:'+ getNonAmbassadorReferralSyncUrl());
                }

               String Amount = String.valueOf(referral.Referrer_Payment_1_Amount__c);
             
              /*  Map<String, String> parms = new Map<String, String>{
                    'uid' => referral.Source_Contact_Id__r.Ambassador__Ambassador_ID__c,
                    'email' => referral.Source_Contact_Id__r.email,
                    'campaign_uid' => referral.Source_Contact_Id__r.campaign_uid__c,
                    'amount' => Amount    
                }; */
             //   system.debug('This is target cont id:'+referral.Target_Contact_Id__c );
             //   system.debug('This is Lead id:'+referral.Lead__c );
                
                Map<String, String> parms = new Map<String, String>();
                parms.put('uid',referral.Source_Contact_Id__r.Ambassador__Ambassador_ID__c);
                parms.put('email', referral.Source_Contact_Id__r.email);
                parms.put('campaign_uid',referral.Source_Contact_Id__r.campaign_uid__c);
                parms.put('amount', Amount);
                parms.put('event_data1', referral.Referral_Status__c);
             // parms.put('transaction_uid', referral.name);
                
               system.debug('This is target cont id:'+referral.Target_Contact_Id__c );
            // system.debug('This is transaction_uid:'+referral.name ); 
                system.debug('This is Lead id:'+referral.Lead__c );
                if((referral.Target_Contact_Id__c== null) && (referral.Lead__c!=null))
               {
                   parms.put('first_name', referral.Lead__r.FirstName);
                   parms.put('last_name', referral.Lead__r.LastName);
                   parms.put('customer_email', referral.Lead__r.email);
               } 
               if((referral.Target_Contact_Id__c!= null))
               {
                   parms.put('first_name', referral.Target_Contact_Id__r.FirstName);
                   parms.put('last_name', referral.Target_Contact_Id__r.LastName);
                   parms.put('customer_email', referral.Target_Contact_Id__r.email);
               } 
                    
                   Map<String,String> HeaderMap = new Map<String,String>();
                    HeaderMap.put('Connection', 'close');
                
                    BaseClass TempObj = new BaseClass();
                    JSONParser parser = JSON.createParser(TempObj.httpGet(NonAmbassadorReferralSyncUrl,HeaderMap,parms,null)); 
                
                while (parser.nextToken() != null)
               {
                  if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'commission_uid'))
                  {
                   parser.nextToken();
                   system.debug('#$%$@$$##$commission_uid######'+parser.getText());
                 //  contact.Ambassador__Ambassador_ID__c = patrser.getTex();
                   if(MapOfIdToLead.containsKey(referral.Lead__c))
                   {
                   Lead extLead = new Lead(); 
                   extLead = MapOfIdToLead.get(referral.Lead__c);   
                   extlead.Commission_ID__c = parser.getText();
                   System.debug('###This is lead Commission##:'+extlead.Commission_ID__c);   
                   ListOfLeadsToUpd.add(extlead);   
                   }
                   if(MapOfIdToOpportunity.containsKey(referral.Opportunity__c))
                   {
                   Opportunity extOppty = new Opportunity(); 
                   extOppty = MapOfIdToOpportunity.get(referral.Opportunity__c);   
                   extOppty.Commission_ID__c = parser.getText();
                   System.debug('###This is Oppty Commission##:'+extOppty.Commission_ID__c);   
                   ListOfOpptysToUpd.add(extOppty);   
                   }
                      
                  }
                 
               }
                    

             //   httpGet(NonAmbassadorReferralSyncUrl, createHttpParmsString(parms));
                referral.Ambassador_Sync_Status__c = Status_SyncSuccess;
                referral.Ambassador_Sync_Details__c = null;
                
            } catch (Exception e) {
                referral.Ambassador_Sync_Status__c = Status_SyncError;
                referral.Ambassador_Sync_Details__c = getExceptionDetails(e);
            }
          }
        }    
        if(!ListOfLeadsToUpd.isEmpty())
        {
          update ListOfLeadsToUpd; 
          controlContactTriggerRecursion.ControlNonAmbassadorReferralsTrigger = false;  
          System.debug('this is lis of lead to upd:'+ ListOfLeadsToUpd);  
        }  
        if(!ListOfOpptysToUpd.isEmpty())
        {
          update ListOfOpptysToUpd; 
          controlContactTriggerRecursion.ControlNonAmbassadorReferralsTrigger = false;  
        } 
    //   update referrals;
    //    System.debug('###This is contact to upd#######:'+ referrals); 
      } 
    }

    public String getAmbassadorERPContactSyncUrl() {
        
        //Settings with default value.
            String ambassadorSyncUrl = Sf.settingsService.getString('AmbassadorSyncReferralUpdateUrl', 
                'https://getambassador.com/api/v2/{UserName}/{ApiKey}/json/{Action}');

        ambassadorSyncUrl = replaceMergeTokens(ambassadorSyncUrl, new Map<String, String>{
            'UserName' => Sf.settingsService.getString('AmbassadorSyncUserName'),
            'ApiKey' => Sf.settingsService.getString('AmbassadorSyncApiKey'),
            'Action' => 'ambassador/get'
        });
        
        return ambassadorSyncUrl;
    }
    
    public String getNonAmbassadorReferralSyncUrl() {
        
        //Settings with default value.
            String ambassadorSyncUrl = Sf.settingsService.getString('AmbassadorSyncReferralUpdateUrl', 
                'https://getambassador.com/api/v2/{UserName}/{ApiKey}/json/{Action}');

        ambassadorSyncUrl = replaceMergeTokens(ambassadorSyncUrl, new Map<String, String>{
            'UserName' => Sf.settingsService.getString('AmbassadorSyncUserName'),
            'ApiKey' => Sf.settingsService.getString('AmbassadorSyncApiKey'),
            'Action' => 'commission/add'
        });
        
        return ambassadorSyncUrl;
    }
    
    public String getAmbassadorSyncUrl() {
        
        //Settings with default value.
        String ambassadorSyncUrl = Sf.settingsService.getString('AmbassadorSyncReferralUpdateUrl', 
            'https://getambassador.com/api/v2/{UserName}/{ApiKey}/json/{Action}');

        ambassadorSyncUrl = replaceMergeTokens(ambassadorSyncUrl, new Map<String, String>{
            'UserName' => Sf.settingsService.getString('AmbassadorSyncUserName'),
            'ApiKey' => Sf.settingsService.getString('AmbassadorSyncApiKey'),
            'Action' => 'commission/update'
        });
        
        return ambassadorSyncUrl;
    }
    
    public String getAmbassadorActivateSyncUrl() {
        
        //Settings with default value.
        String ambassadorActivateSyncUrl = Sf.settingsService.getString('AmbassadorSyncReferralUpdateUrl', 
            'https://getambassador.com/api/v2/{UserName}/{ApiKey}/json/{Action}');

        ambassadorActivateSyncUrl = replaceMergeTokens(ambassadorActivateSyncUrl, new Map<String, String>{
            'UserName' => Sf.settingsService.getString('AmbassadorSyncUserName'),
            'ApiKey' => Sf.settingsService.getString('AmbassadorSyncApiKey'),
            'Action' => 'ambassador/update'
        });
        
        return ambassadorActivateSyncUrl;
    }

    public List<Contact> queryContacts(List<Id> contactIds) {
        return [
            Select
                Id,
                firstname,
                lastname,
                email,
                Ambassador__Ambassador_ID__c,
                campaign_uid__c,
                Ambassador_Sync_Status__c,
                Ambassador_Sync_Details__c,
                Commission_Amount__c
            from Contact 
            where Id in :contactIds
        ];
    }
    
    public List<Referral_Input__c> queryReferrals(List<Id> referralIds) {
        return [
            Select
                Id,
                Name,
                Referral_Status__c,
                Referrer_Status_1__c,
                Referrer_Status_2__c,
                Referrer_Status_3__c, 
                Ambassador_Sync_Details__c,
                Ambassador_Sync_Field__c,
                Ambassador_Sync_Status__c,
                Lead__r.Commission_ID__c,
                Opportunity__r.Commission_ID__c,
                Source_Contact_Id__r.campaign_uid__c,
                Source_Contact_Id__r.Ambassador__Ambassador_ID__c,
                Source_Contact_Id__r.Commission_Amount__c,
                Source_Contact_Id__r.email,
                Target_Contact_Id__r.FirstName,
                Target_Contact_Id__r.LastName,
                Target_Contact_Id__r.Email,
                Lead__r.FirstName,
                Lead__r.LastName,
                Lead__r.Email,
                Referrer_Payment_1_Amount__c
            from Referral_Input__c 
            where Id in :referralIds
        ];
    }
      public List<Contact> queryReferrerContacts(List<Id> ListOfContIds) {
        return [
            Select
                Id,
                campaign_uid__c,
                Ambassador__Ambassador_ID__c,
                Commission_Amount__c,
                email
            from Contact 
            where Id in :ListOfContIds
        ];
    }
     public List<Lead> queryLeads(List<Id> ListOfLeads) {
        return [
            Select
                Id,
                Commission_ID__c
            from Lead 
            where Id in :ListOfLeads
        ];
    }
    public List<ServiceContract> querySCContacts(List<Id> ListOfContIds) {
        return [
            Select Id,
            ContactId 
            from ServiceContract where ContactId in : ListOfContIds
 
        ];
    }
    public List<Opportunity> queryOppts(List<Id> ListOfOppts) {
        return [
            Select
                Id,
                Commission_ID__c
            from Opportunity 
            where Id in :ListOfOppts
        ];
    }
}