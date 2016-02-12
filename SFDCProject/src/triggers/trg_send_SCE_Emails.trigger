trigger trg_send_SCE_Emails on Service_Contract_Event__c (After Update, After Insert) {
    
    Boolean skipValidations = false;
    skipValidations = SkipTriggerValidation.performTriggerValidations();
    
    if(skipValidations == false){    
        if(trigger.isAfter){  
            if(trigger.isInsert || trigger.isUpdate){
               try{
                    if(SCE_Email_Status__c.getValues('Install Scheduled').Active__c == 'Yes'){
                       SCETriggerClass.checkScheduledInstallDate(trigger.new,trigger.isinsert,trigger.isupdate,trigger.oldMap);    
                    }
                    if(SCE_Email_Status__c.getValues('Permit Submitted').Active__c == 'Yes'){
                       SCETriggerClass.checkPermitSubmittedDate(trigger.new,trigger.isinsert,trigger.isupdate,trigger.oldMap);    
                    }
                    if(SCE_Email_Status__c.getValues('Permit Approved').Active__c == 'Yes'){
                       SCETriggerClass.checkPermitApprovedDate(trigger.new,trigger.isinsert,trigger.isupdate,trigger.oldMap);    
                    }
                    if(SCE_Email_Status__c.getValues('Install Completed').Active__c == 'Yes'){
                       SCETriggerClass.checkConstructionCompletionDate(trigger.new,trigger.isinsert,trigger.isupdate,trigger.oldMap);    
                    }
                    if(SCE_Email_Status__c.getValues('Inspection Sign-Off').Active__c == 'Yes'){
                       SCETriggerClass.checkInspectionSignOffDate(trigger.new,trigger.isinsert,trigger.isupdate,trigger.oldMap); 
                    }
                    if(SCE_Email_Status__c.getValues('Utility Interconnection').Active__c == 'Yes'){
                       SCETriggerClass.checkUtilityInterconnectionDate(trigger.new,trigger.isinsert,trigger.isupdate,trigger.oldMap); 
                    }
                    if(SCE_Email_Status__c.getValues('PTO').Active__c == 'Yes'){
                       SCETriggerClass.checkPTODate(trigger.new,trigger.isinsert,trigger.isupdate,trigger.oldMap); 
                    }
                    if(SCE_Email_Status__c.getValues('CAP').Active__c == 'Yes'){
                        System.debug('>> Calling CAP method');
                       SCETriggerClass.checkCAPDate(trigger.new,trigger.isinsert,trigger.isupdate,trigger.oldMap);
                    }
               }catch(Exception ex) {
                  System.debug('-----Exception block after insert / update:' +ex); 
               }
            } 
        }    
    }
}