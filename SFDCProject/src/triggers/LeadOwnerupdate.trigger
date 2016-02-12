trigger LeadOwnerupdate on Referral_Input__c (after insert, after update) 
{
    Boolean skipValidations = false;
   skipValidations = SkipTriggerValidation.performTriggerValidations();
   if(skipValidations == false)
   {
      If(Trigger.isInsert)
     {
     // ReferralTriggerHandler.leadOwnerUpdate(trigger.new);  
        ReferralTriggerHandler.leadOwnerUpdate(null, trigger.new, trigger.isInsert, trigger.isUpdate);   
     } 
    else{
        ReferralTriggerHandler.leadOwnerUpdate(trigger.oldMap, trigger.new, trigger.isInsert, trigger.isUpdate);
     }
   }  
    
    
}