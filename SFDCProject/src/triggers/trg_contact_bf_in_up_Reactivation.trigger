trigger trg_contact_bf_in_up_Reactivation on Contact (before update) {  

  Boolean skipValidations = False;
  skipValidations = SkipTriggerValidation.performTriggerValidations();
  if(skipValidations == false){
  
    for(Contact c:trigger.new){
    if((c.Professional_Certification__c=='Yes'&&Trigger.oldMap.get(c.id).Professional_Certification__c!='Yes')||(c.Accreditation_Status__c=='Accredited'&&Trigger.oldMap.get(c.id).Accreditation_Status__c!='Accredited')){
        if(c.Previous_Design_Tool__c!=null&&c.Design_Tool_Access__c==null)
        c.Design_Tool_Access__c=c.Previous_Design_Tool__c;
        if(c.Previous_Proposal_Tool__c!=null&&c.Proposal_Tool_Access__c==null)
        c.Proposal_Tool_Access__c=c.Previous_Proposal_Tool__c;
        c.Previous_Design_Tool__c=null;
        c.Previous_Proposal_Tool__c=null;
        c.Tools_Deactivation_Date__c=null;
    }        
    }
  }     
}