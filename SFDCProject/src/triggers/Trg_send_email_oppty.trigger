trigger Trg_send_email_oppty on Opportunity (after insert, after update) {

    List<opportunity> opplist = new List<Opportunity>();
    List<opportunity> oplist = new List<Opportunity>();
    Integer daysInPastLimitSASchedule = 0; 
    Integer daysInPastLimitSAComplete = 0; 
    
    If(!Test.isRunningTest()){
    daysInPastLimitSASchedule = Integer.valueOf(Opportunity_Email_Status__c.getValues('Site Audit Schedule').No_Of_Days_In_Past_Limit__c);
    daysInPastLimitSAComplete = Integer.valueOf(Opportunity_Email_Status__c.getValues('Site Audit Complete').No_Of_Days_In_Past_Limit__c); 
    }
    else if(Test.isRunningTest()){
    daysInPastLimitSASchedule = 5;
    daysInPastLimitSAComplete = 5;
    }
    for(opportunity opp:trigger.new){
        if(trigger.isUpdate && opp.Opportunity_Division_Custom__c != label.AEE_label && opp.Site_Audit_Scheduled__c!= null && opp.Site_Audit_Scheduled__c != trigger.oldMap.get(opp.id).Site_Audit_Scheduled__c &&
           opp.Site_Audit_Scheduled__c  >= (date.today() - daysInPastLimitSASchedule)){
         opplist.add(opp);   
        }
        
        if(trigger.isUpdate && opp.Opportunity_Division_Custom__c != label.AEE_label && opp.Site_Audit_Completed__c != null && opp.Site_Audit_Completed__c != trigger.oldmap.get(opp.id).Site_Audit_Completed__c &&
           opp.Site_Audit_Completed__c  >= (date.today() - daysInPastLimitSAComplete)){
         oplist.add(opp);   
        }
    }
    if(!opplist.isEmpty()){
      if(Opportunity_Email_Status__c.getValues('Site Audit Schedule').Active__c == 'Yes'){
        OpportunityEmailClass.checkSiteAuditSchedule(opplist);
      }    
    }
    if(!oplist.isEmpty()){
      if(Opportunity_Email_Status__c.getValues('Site Audit Complete').Active__c == 'Yes'){
        OpportunityEmailClass.checkSiteAuditComplete(oplist);  
      }
    }
    
}