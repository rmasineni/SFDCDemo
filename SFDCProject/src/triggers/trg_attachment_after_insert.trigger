trigger trg_attachment_after_insert on Attachment (after insert) {
//
   Set<Id> setParentIds = new Set<Id>();
   
   Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe(); 
    Map<String,String> keyPrefixMap = new Map<String,String>{};
    Set<String> keyPrefixSet = gd.keySet();
    for(String sObj : keyPrefixSet){
       Schema.DescribeSObjectResult r =  gd.get(sObj).getDescribe();
       String tempName = r.getName();
       String tempPrefix = r.getKeyPrefix();
       System.debug('Processing Object['+tempName + '] with Prefix ['+ tempPrefix+']');
       keyPrefixMap.put(tempPrefix,tempName);
    }
   Map<Id, String> mapFSDIdToFileName = new Map<Id, String>(); 
   for(Attachment att:Trigger.New)
   { 
       //
       if(att.ParentId != null){            
            String tPrefix = att.ParentId;
            tPrefix = tPrefix.subString(0,3);
            //
            System.debug('Attachment Id[' + att.id + '] is associated to Object of Type: ' + keyPrefixMap.get(tPrefix));
            if(keyPrefixMap.get(tPrefix) == 'FS_Dispatch__c')
            {
               setParentIds.add(att.ParentId);
               mapFSDIdToFileName.put(att.ParentId, att.Name);
            }
        }      
   }
   
   if(!setParentIds.isEmpty())
   {
       Id emailfromid = null;
       String sunrunCustomerCareEmail = Label.Sunrun_Customer_Care_Email;
       for(OrgWideEmailAddress owea:[select Id from OrgWideEmailAddress where Address =:sunrunCustomerCareEmail])
       {
         emailfromid = owea.Id;
       } 
       //
       for(FS_Dispatch__c fsd:[select id, Name, CreatedBy.Email from FS_Dispatch__c where id in :setParentIds])
       {
               Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();               
               mail.setOrgWideEmailAddressId(emailfromid); 
               List<String> listToAddr = new List<String>();
               listToAddr.add(fsd.CreatedBy.Email);
               mail.setToAddresses(listToAddr);
               if(mapFSDIdToFileName.get(fsd.id) != null)
               {
                   String instanceurl = System.URL.getSalesforceBaseUrl().toExternalForm();
                   mail.setHtmlBody('Filename: ' + mapFSDIdToFileName.get(fsd.Id) + ' was attached to FS Dispatch: <a href=\'' + instanceurl + '/' + fsd.Id + '\'>' + fsd.Name + '</a>');                                      
               }
               else
               {
                   mail.setHtmlBody('Filename not found');
               }
               mail.setSubject('Subject- New Attachment- ' + fsd.Name);//Subject- New Attachment- 'FS dispatch number'
               mail.setWhatId(fsd.Id);       
               Messaging.sendEmail(new Messaging.SingleEmailMessage[]{mail});  
       }
    
    
   }
   
//   
}