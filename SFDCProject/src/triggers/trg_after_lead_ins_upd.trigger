/* 
   Peter Alexander Mandy
   29-10-2012:14:01:34.25
   
   Conditions under which we call ZipPlusSix from Cdyne:
   1) If Lead is new and has address info
   2) If Lead is updated and has NULL ZipPlusSix and address info 
      or Non-null ZipPlusSix with Changed Address Info.   
*/
trigger trg_after_lead_ins_upd on Lead (after insert, after update) {
   //
   // This is to prevent an additional call to CDYNE when the CDYNE Results
   // Cause the Lead to be updated with correct address information
   // True, it is an address change, but not one that we need to send
   // to Cdyne, as the change was initiated by Cdyne.
   //
   if(System.isFuture())
   {
      return;
   }    
   Set<String> setGetZipPlusSix = new Set<String>();
   for(Lead l:Trigger.New)
   {
      if(Trigger.isInsert 
         && l.Street != '' 
         && l.City != '' 
         && l.State != '' 
         && l.PostalCode != ''
         && (l.CDYNE_Status__c == null || l.CDYNE_Status__c == '')
         && (l.Zip_6__c == '' || l.Zip_6__c == null))
      {
          setGetZipPlusSix.add(String.ValueOf(l.Id));
      }

      if(Trigger.isUpdate  
         && l.CDYNE_Address__c != l.Street + l.City + l.State + l.PostalCode
         && 
         ((l.Street != '' 
           && l.City != '' 
           && l.State != '' 
           && l.PostalCode != ''
           && (l.Street != Trigger.oldMap.get(l.Id).Street
               || l.City != Trigger.oldMap.get(l.Id).City
               || l.State != Trigger.oldMap.get(l.Id).State
               || l.PostalCode != Trigger.oldMap.get(l.Id).PostalCode)
           && l.Zip_6__c != '')   
         ||
         (l.Street != '' 
          && l.City != '' 
          && l.State != '' 
          && l.PostalCode != ''
          && l.Zip_6__c == '')
         )   
         )
      {          
        system.debug('setGetZipPlusSix*****');
         setGetZipPlusSix.add(String.ValueOf(l.Id));
      }
   }
   //Now call Cdyne if any accounts qualified
   system.debug('setGetZipPlusSix*****'+ setGetZipPlusSix);
   if(!setGetZipPlusSix.isEmpty())
   {
      // Issue Call to CDYNE Service Method that calls CDYNE API Asynchronously.
      CDYNEService.processZipPlusSixForLeads(setGetZipPlusSix);
      system.debug('CDYNE Called*****');
   }

}