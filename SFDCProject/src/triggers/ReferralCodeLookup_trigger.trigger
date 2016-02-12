trigger ReferralCodeLookup_trigger on Lead (before insert, before update) {
/*
    Peter Alexander Mandy - July 09, 2012
    This code has been deprecated per Susie.
    The preference is to comment it out, vice deactivate.
    Lead.Referred_By_Code__c is now being passed in as the actual Account.Id
    This code will therefore never fire since no one would enter a lead with the account id as the referred by code.
    Additionally, we are no longer populating the referred by code when emailing customers.
    
  Set<String> setRefByCode = new Set<String>();
  Map<String, Account> mapRefCodeToAccount = new Map<String, Account>();
  for(Lead newLead : Trigger.new)
  {
        if(newLead.Referred_By_Code__c != null && (Trigger.isInsert
           || (Trigger.isUpdate                
               && ((Trigger.oldMap.get(newLead.Id).Referred_By_Code__c == null || Trigger.oldMap.get(newLead.Id).Referred_By_Code__c == '')
                   || (Trigger.oldMap.get(newLead.Id).Referred_By_Code__c != null
                       && newLead.Referred_By_Code__c != Trigger.oldMap.get(newLead.Id).Referred_By_Code__c))
           )))
           {
               setRefByCode.add(newLead.Referred_By_Code__c);
           }
  }
  
  if(!setRefByCode.isEmpty())
  {
     for(Account accountWithReferralCode:[select id, name, Customer_referral_code__c from Account where Customer_referral_code__c in :setRefByCode])
     {
        mapRefCodeToAccount.put(accountWithReferralCode.Customer_referral_code__c, accountWithReferralCode);
     }
  }
   
  if(!mapRefCodeToAccount.isEmpty())
  { 
     for(Lead newLead : Trigger.new)
     {      
        if(mapRefCodeToAccount.get(newLead.Referred_By_Code__c) != null)
        {
           //newLead.Referred_by__r=mapRefCodeToAccount.get(newLead.Referred_By_Code__c);
           newLead.Referred_by__c=mapRefCodeToAccount.get(newLead.Referred_By_Code__c).Id;
        }    
     }
  }  
*/ 
}