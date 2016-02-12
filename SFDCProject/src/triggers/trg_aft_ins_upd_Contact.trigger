trigger trg_aft_ins_upd_Contact on Contact (after update, after insert, before update) {
    
    Set<Id> conIdSet = new Set<Id>();
    map<Id,Id> opptyConMap = new map<Id,Id>();
    map<Id,String> conMemberIdMap = new map<Id,String>();
    map<Id,String> conMemberTypeMap = new map<Id,String>();
    List<Opportunity> opptyList = new List<Opportunity> ();
    Set<Id> cIdSet = new Set<Id>();
    Map<Id,Id> opconmap = new Map<Id,Id>();
    set<String> ssrset = new set<String>();
    map<Id,String> opputilitymap = new Map<Id,String>();
    list<Contact> conlist = new list<Contact>();
    
    Set<Id> conPrefLanSet = new Set<Id>();
    Map<Id,String> conPrefLanMap = new Map<Id,String>();
    Set<Id> tempSet = new Set<Id>();
    
    Boolean skipValidations = false;
    skipValidations = SkipTriggerValidation.performTriggerValidations();
    
    if(skipValidations == false){
        if(trigger.isAfter){  
            if(trigger.isInsert || trigger.isUpdate){
               for (Contact con : trigger.new) {
                    If (!checkRecursive.costcoContactIds.contains(con.id) &&
                       ((Trigger.isInsert && con.Member_ID__c != null) || 
                        (Trigger.isUpdate && (trigger.oldMap.containsKey(con.id) && trigger.oldMap.get(con.id).Member_ID__c != con.Member_ID__c)))){
                            
                        conIdSet.add(con.id);
                        tempset.add(con.id);
                        conMemberIdMap.put(con.id, con.Member_ID__c);
                        checkRecursive.costcoContactIds.add(con.id);
                    } //End-If
                    If((Trigger.isInsert && con.Preferred_Language__c != null) || (Trigger.isUpdate && (trigger.oldMap.get(con.id).Preferred_Language__c != con.Preferred_Language__c))){
                        conPrefLanSet.add(con.id);
                        tempset.add(con.id);
                        conPrefLanMap.put(con.id,con.Preferred_Language__c);
                        system.debug('tempset'+tempset);
                        system.debug('conPrefLanMap'+conPrefLanMap); 
                    }
                }// End-For     
                if(!tempset.isEmpty()){        
                 for(OpportunityContactRole ocr:[select ContactId, OpportunityId from OpportunityContactRole where isPrimary = true and ContactId in : tempset]){
                    opptyConMap.put(ocr.OpportunityId, ocr.ContactId);
                    system.debug('opptyConMap'+opptyConMap); 
                 }        
                }
                if(!opptyConMap.isEmpty()){
                 for(Opportunity oppty: [select id, Costco_Member_ID__c,Preferred_Language__c from Opportunity where Id in :opptyConMap.keySet()]){
                  if(conIdSet.contains(opptyConMap.get(oppty.Id))){
                    oppty.Costco_Member_ID__c = conMemberIdMap.get(opptyConMap.get(oppty.id)); 
                    opptyList.add(oppty);
                  }    
                  if(conPrefLanSet.contains(opptyConMap.get(oppty.id))){
                    oppty.Preferred_Language__c = conPrefLanMap.get(opptyConMap.get(oppty.id));  
                    opptyList.add(oppty);
                  }
                    system.debug('opptyList'+opptyList); 
                 }
                }
                try{
                   if(!opptyList.isEmpty())
                    update opptyList;         
                }catch(Exception e){
                    System.debug('Opportunity Member Id failed :' +e);         
                }
            }
            
        }
        if(trigger.isBefore && trigger.isUpdate){
           for(Contact c: trigger.new){
             if(trigger.isUpdate && (trigger.oldMap.get(c.id).Preferred_Language__c != c.Preferred_Language__c)){
                cIdSet.add(c.Id);
                conlist.add(c);
                system.debug('conlist'+conlist);
             }
           }
           if(!cIdSet.isEmpty()){
            for(OpportunityContactRole ocr: [select Id, OpportunityId, ContactId from OpportunityContactRole where isPrimary = true and contactId in: cIdSet]){
              opconmap.put(ocr.contactId,ocr.opportunityId);
              system.debug('opconmap'+opconmap);
            }
           }
           for(Spanish_Service_Resource__c ssr : Spanish_Service_Resource__c.getall().values()){
             ssrset.add(ssr.Utility__c);
             system.debug('ssrset'+ssrset);           
           }
           if(!opconmap.isEmpty()){
             for(Opportunity opp : [select Id, Utility_Company__c from Opportunity where Id in: opconmap.values()]){
               opputilitymap.put(opp.Id,opp.Utility_Company__c);
               system.debug('opputilitymap'+opputilitymap);
             }
           }
           if(!opputilitymap.isEmpty()){
            for(Contact cont : conlist){
             if(!ssrset.contains(opputilitymap.get(opconmap.get(cont.Id))) && cont.Preferred_Language__c == 'Spanish')
              cont.addError('The Preferred language(Spanish) is not supported in this market');
             
            }
           }
        }

       Set<Id> contactIdSet = new Set<Id>();
       List<OpportunityContactRole> ocrList = new List<OpportunityContactRole>();
       Map<Id,Id> conOppIdMap = new Map<Id,Id>();
       Map<Id,Contact> contactMap = new Map<Id,Contact>();
       List<Opportunity> OpportunityList = new List<Opportunity>();
       List<Opportunity> updateOptyList = new List<Opportunity>();
       List<Appointment__c> apptList = new List<Appointment__c>();
       Map<Id,Id> appOppMap = new Map<Id,Id>();
       List<Appointment__c> toBeUpdateApptList = new List<Appointment__c>();
       Map<Id,Contact> contactMap2 = new Map<Id,Contact>();
       if(Trigger.isAfter && Trigger.isUpdate){
         for(Contact c : Trigger.new){
           if(c.FirstName != Trigger.oldMap.get(c.Id).FirstName || c.LastName != Trigger.oldMap.get(c.Id).LastName ){    
              contactIdSet.add(c.Id);
              contactMap.put(c.Id,c);
           }
           if(c.Phone != Trigger.oldMap.get(c.Id).Phone || c.Text_Opt_Out__c != Trigger.oldMap.get(c.Id).Text_Opt_Out__c ){
              contactIdSet.add(c.Id);
              contactMap2.put(c.Id,c);
           }
         }
       
       if(!contactIdSet.isEmpty()){
         ocrList = [select Id, OpportunityId, ContactId, isPrimary from OpportunityContactRole where contactId in : contactIdSet and isPrimary = true];
         system.debug('ocr list'+ocrlist);
       }
       if(!ocrList.isEmpty()){
         for(OpportunityContactRole ocr : ocrList){
            conOppIdMap.put(ocr.OpportunityId,ocr.ContactId);
         }
       }
       if(!conOppIdMap.isEmpty()){
         OpportunityList = [select Id, Homeowner_First_Name__c, Homeowner_Last_Name__c from Opportunity where Id in : conOppIdMap.keySet()];
         system.debug('OpportunityList'+OpportunityList);
         apptList = [select id, Mobile_for_SMS__c,Text_Opt_Out__c,Opportunity__c from Appointment__c where Opportunity__c in: conOppIdMap.keySet()];
       }
       if(!contactMap.isEmpty()){  
         for(Opportunity o : OpportunityList){
           if(conOppIdMap.containsKey(o.Id) && contactMap.containsKey(conOppIdMap.get(o.Id))){
           o.Homeowner_First_Name__c = contactMap.get(conOppIdMap.get(o.Id)).FirstName;
           o.Homeowner_Last_Name__c = contactMap.get(conOppIdMap.get(o.Id)).LastName;
           o.Homeowner_Full_Name__c = contactMap.get(conOppIdMap.get(o.Id)).FirstName + ' ' + contactMap.get(conOppIdMap.get(o.Id)).LastName;
           updateOptyList.add(o);
           }
         }
       }
        if(!apptList.isEmpty()){
            for(Appointment__c app : apptList){
                appOppMap.put(app.Id,app.Opportunity__c);
            }    
        }
        system.debug('==>appOppMap'+appOppMap);   
        if(!appOppMap.isEmpty() && !contactMap2.isEmpty() && !conOppIdMap.isEmpty()){
            for(Appointment__c appt : apptList){
             if(conOppIdMap.containsKey(appOppMap.get(appt.Id)) && contactMap2.containsKey(conOppIdMap.get(appOppMap.get(appt.Id)))){
              if(appt.Mobile_for_SMS__c != contactMap2.get(conOppIdMap.get(appOppMap.get(appt.Id))).Phone){ 
                appt.Mobile_for_SMS__c = contactMap2.get(conOppIdMap.get(appOppMap.get(appt.Id))).Phone;
              }
              if(appt.Text_Opt_Out__c != contactMap2.get(conOppIdMap.get(appOppMap.get(appt.Id))).Text_Opt_Out__c){
                appt.Text_Opt_Out__c = contactMap2.get(conOppIdMap.get(appOppMap.get(appt.Id))).Text_Opt_Out__c;
              }
               toBeUpdateApptList.add(appt);
             }  
                
            }    
        }
        system.debug('==>toBeUpdateApptList'+toBeUpdateApptList);
        system.debug('updateOptyList'+updateOptyList);
        if(!updateOptyList.isEmpty()){
            update updateOptyList;
        }
        if(!toBeUpdateApptList.isEmpty()){
            update toBeUpdateApptList;   
        }   
      }
    
 //update servicecontract agreement info for the contact  on contractDB
        If(trigger.isAfter){
            set<Id> conObjIds= new set<Id>();
            Set<String> agreementIds =  new  Set<String>();
            for(contact conObj: Trigger.new){
                If(Trigger.IsUpdate){
                    if(conObj.ERP_Contact_of_Record__c==true){
                        conObjIds.add(conObj.id);
                        
                    }
                }  
            }  
            If(!conObjIds.isEmpty()){
                List<ServiceContract> ServiceContractObjList=[SELECT Agreement_Number__c  FROM ServiceContract  where ContactId in:conObjIds];
                for(ServiceContract sc:ServiceContractObjList){
                    if(sc.Agreement_Number__c!=null && sc.Agreement_Number__c!=''){
                        agreementIds.add(sc.Agreement_Number__c);
                    }
                }
                
            }
            if(!agreementIds.isEmpty())
                ContractDBUtil.updateContractDBInfo(agreementIds);
            
            
        }  
    }
}