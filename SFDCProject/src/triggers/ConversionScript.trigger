trigger ConversionScript on Lead (after update)  {
 // no bulk processing; will only run from the UI
 if (Trigger.new.size() == 1)  {

  if (Trigger.old[0].isConverted == false && Trigger.new[0].isConverted == true)  {

   // if a new account was created
   if (Trigger.new[0].ConvertedAccountId != null) {
        
        //get all the quotes belonging to that lead
        Quote__c[] quotes = [Select q.Id from Quote__c q where q.Lead__c= :Trigger.new[0].Id];
        
        for (Quote__c quote : quotes) {
            //set the account id to the given account
            quote.account__c=Trigger.new[0].ConvertedAccountId;
            update quote;   
        }
   }
      
  }
 }  
}