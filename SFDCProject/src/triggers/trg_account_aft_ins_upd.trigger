/* 
   Peter Alexander Mandy
   29-10-2012:12:26:45.11
   
   Conditions under which we call ZipPlusSix from Cdyne:
   1) If Account is new and has address info
   2) If Account is updated and has NULL ZipPlusSix and address info 
      or Non-null ZipPlusSix with Changed Address Info.   
*/
trigger trg_account_aft_ins_upd on Account (after insert, after update) {
   //
   // This is to prevent an additional call to CDYNE when the CDYNE Results
   // Cause the Account to be updated with correct address information
   // True, it is an address change, but not one that we need to send
   // to Cdyne, as the change was initiated by Cdyne.
   //
   if(System.isFuture())
   {
      return;
   }
   Set<String> setGetZipPlusSix = new Set<String>();
   for(Account a:Trigger.New)
   {
      if(Trigger.isInsert 
         && a.BillingStreet != '' && a.BillingStreet != null
         && a.BillingCity != '' && a.BillingCity != null
         && a.BillingState != '' && a.BillingState != null
         && a.BillingPostalCode != '' && a.BillingPostalCode != null 
         && (a.CDYNE_Status__c == null || a.CDYNE_Status__c == '')
         && (a.Zip_6__c == '' || a.Zip_6__c == null)
         && (a.Account_Type__c == 'Residential'||a.Account_Type__c == 'Residential Customer'))
      {
          setGetZipPlusSix.add(String.ValueOf(a.Id));
      }

     
      //Should Remove this Comment after all the accounts has been Updated
      if(Trigger.isUpdate &&!a.Override_CDYNE__c
         && (a.Account_Type__c == 'Residential'||a.Account_Type__c == 'Residential Customer')
         && a.CDYNE_Address__c != a.BillingStreet + a.BillingCity + a.BillingState + a.BillingPostalCode
         && 
         ((a.BillingStreet != '' 
           && a.BillingCity != '' 
           && a.BillingState != '' 
           && a.BillingPostalCode != ''           
           && (a.BillingStreet != Trigger.oldMap.get(a.Id).BillingStreet
               || a.BillingCity != Trigger.oldMap.get(a.Id).BillingCity
               || a.BillingState != Trigger.oldMap.get(a.Id).BillingState
               || a.BillingPostalCode != Trigger.oldMap.get(a.Id).BillingPostalCode)
           && a.Zip_6__c != '')   
         ||
         (a.BillingStreet != '' 
          && a.BillingCity != '' 
          && a.BillingState != '' 
          && a.BillingPostalCode != ''
          && a.Zip_6__c == '')
         )   
         )
      {          
         setGetZipPlusSix.add(String.ValueOf(a.Id));
      }
     

   }
   //Now call Cdyne if any accounts qualified
   if(!setGetZipPlusSix.isEmpty())
   {
      // Issue Call to CDYNE Service Method that calls CDYNE API Asynchronously.
      CDYNEService.processZipPlusSixForAccounts(setGetZipPlusSix);
   }

}