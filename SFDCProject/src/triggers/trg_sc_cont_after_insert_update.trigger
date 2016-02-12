trigger trg_sc_cont_after_insert_update on Service_Contract_Contact_Rel__c (after insert,after update)
 { 
    
    Boolean skipValidations = false;
    skipValidations = SkipTriggerValidation.performTriggerValidations();
    if(skipValidations == false){
        Set<Id> modifiedRelatedObjectIds = new Set<Id>();
        if(Trigger.isinsert || Trigger.isupdate)
        {
            Map<Id,Id> contactToRelatedcontact = new Map<Id,Id>();
            Map<Id,Id> relatedcontactToserviceContract = new Map<Id,Id>();
            
            for(Service_Contract_Contact_Rel__c sccr : Trigger.new)
            {
                Service_Contract_Contact_Rel__c oldServiceContractContact;
                If(Trigger.isUpdate){
                    oldServiceContractContact = trigger.oldMap.get(sccr.Id);
                }
                
                if((sccr.Contact__c!= null && sccr.Type__c != null && (sccr.Type__c.contains('Billing'))) 
                	&& (Trigger.isinsert || (Trigger.isUpdate && (oldServiceContractContact.Contact__c!= sccr.Contact__c) || oldServiceContractContact.Type__c!= sccr.Type__c) ) )
                {
                    contactToRelatedContact.put(sccr.Id,sccr.Contact__c);
                    relatedcontactToserviceContract.put(sccr.ServiceContract__c,sccr.Id);
                }
            }
            
            Map<Id, Contact> contactMap = new  Map<Id, Contact>();
            Map<String, Contact> existingERPContacts = new  Map<String, Contact>();
            
            Map<Id, String> contactIdToEmail = new Map<Id, String>();
            if(contactToRelatedContact != null && !contactToRelatedContact.isEmpty()){
                String contactSOQL = ServiceContractUtil.getContactSOQL();
                List<Id> contactIds = contactToRelatedContact.values();
                Boolean erpContact = true;
                String contactSOQL1 =  contactSOQL + ' WHERE Id in :contactIds' ;
                for(Contact contactObj : Database.query(contactSOQL1)){
                    contactMap.put(contactObj.Id, contactObj);
                    if(contactObj.email != null){
                        contactIdToEmail.put(contactObj.Id, contactObj.email);
                    }
                }
                
                if(contactIdToEmail != null && !contactIdToEmail.isEmpty()){
                    List<String> emailIds = contactIdToEmail.values();
                    String contactSOQL2 =  contactSOQL + ' WHERE email in :emailIds and ERP_Contact_of_Record__c =:erpContact ' ;
                    for(Contact contactObj : Database.query(contactSOQL2)){
                        existingERPContacts.put(contactObj.email, contactObj);
                    }
                }
                System.debug('existingERPContacts: ' + existingERPContacts);
                
            }
                            
            List<servicecontract> servicecontractList = new List<servicecontract>();
            if(!relatedcontactToserviceContract.isEmpty()) 
            {
                Set<Id> contractIds = relatedcontactToserviceContract.keySet();
                String contactRelSOQL = ServiceContractUtil.getContactSOQLForOptyContactRole();
                String scContactSOQL = ' SELECT Id,ContactId, erp_customer_name__c, ' + contactRelSOQL + ' from Servicecontract Where id IN :contractIds ' ;
                servicecontractList =  Database.query(scContactSOQL);
            }
            Map<Id, Contact> scIdToContactMap = new Map<Id, Contact>();
            for(servicecontract sc : servicecontractList){
                
                Id contactId = contactToRelatedContact.get(relatedcontactToserviceContract.get(sc.id));
                Contact sourceERPContact = contactMap.get(contactId);
                String email = contactIdToEmail.get(contactId);
                
                Contact existingSCERPContact = new Contact();
                if(sc.contact != null && sc.contact.Id != null){
                    existingSCERPContact = sc.contact;
                    System.debug('Line -1');
                }else if(email != null && email != '' && existingERPContacts.containsKey(email)){
                    existingSCERPContact = existingERPContacts.get(email);
                    System.debug('Line -2');
                }                
                ServiceContractUtil.cloneERPContact(sourceERPContact, existingSCERPContact);
                scIdToContactMap.put(sc.Id, existingSCERPContact);
                sc.erp_customer_name__c = ServiceContractUtil.getContactName(existingSCERPContact);
            }
            
            if(scIdToContactMap != null && !scIdToContactMap.isEmpty()){
                upsert scIdToContactMap.values();
            }

            for(servicecontract sc : servicecontractList){
                Contact erpContact = scIdToContactMap.get(sc.Id);
                if(erpContact != null && erpContact.Id != null && sc.contactId == null){
                    sc.contactId = erpContact.Id;
                    sc.erp_customer_name__c = ServiceContractUtil.getContactName(erpContact);
                }
            }
            
            if(!servicecontractList.isEmpty())
            {
                update servicecontractList;
            }
            
            if(modifiedRelatedObjectIds != null && !modifiedRelatedObjectIds.isEmpty()){
                ServiceContractUtil.updateServiceContractsForContacts(modifiedRelatedObjectIds, datetime.now());
            }
        }
    }
 }