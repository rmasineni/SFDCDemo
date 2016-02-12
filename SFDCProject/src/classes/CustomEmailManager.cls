public class CustomEmailManager {
  
  @future
  public static void communicateScheduledEvent(Map<String, String> whereClauseFieldValueMap, String templateName,  
                                                List<Id> toRecipientIdList, List<String> ccRecipientList, String fromDisplayName, String replyToEmailId, String fromEmailId) {
         System.debug('This is WhereClause :' + whereClauseFieldValueMap);
         System.debug('This is Template :' + templateName);
         System.debug('This is Recipient List :' + toRecipientIdList);
         System.debug('communicateScheduledEvent ---> 1');
         //Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

        String subject  = getPlainText('Email Subject', whereClauseFieldValueMap, templateName); 
        System.debug('communicateScheduledEvent ---> 2');
        System.debug('this is subject :' + subject);  
        String htmlBody = getPlainText('Email Body', whereClauseFieldValueMap, templateName);                                        
        System.debug('this is Body :' + htmlBody);                                          
        System.debug('communicateScheduledEvent ---> 3');
        System.debug('toRecipientList :' +toRecipientIdList); 
        
        for (Id recipientId: toRecipientIdList){
            System.debug('recipientId :' +recipientId);   
            System.debug('ccRecipientList :' +ccRecipientList);
            System.debug('subject :' +subject);
            System.debug('htmlBody :' +htmlBody);
            System.debug('fromEmailId :' +fromEmailId);
            System.debug('fromDisplayName :' +fromDisplayName);
            System.debug('replyToEmailId :' +replyToEmailId);     
            sendEmail(recipientId, ccRecipientList, subject, htmlBody, fromEmailId, fromDisplayName, replyToEmailId);             
        }
  }
  
   public static void communicateScheduledEvent_Costco(Map<String, String> whereClauseFieldValueMap, String templateName,  
                                                            List<Id> toRecipientIdList, List<String> ccRecipientList, String fromDisplayName, String replyToEmailId, String fromEmailId, List<Service_Contract_Event__c> sceList) {
                     System.debug('This is WhereClause :' + whereClauseFieldValueMap); 
                     //System.debug('This is Template :' + templateName);    
                     System.debug('This is Recipient List :' + toRecipientIdList);                                           
                     System.debug('communicateScheduledEvent ---> 1');
                     Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                     String subject  = 'test visualforce page';
                    //  String subject  = getPlainText('Email Subject', whereClauseFieldValueMap, templateName); 
                     System.debug('communicateScheduledEvent ---> 2');
                     System.debug('this is subject :' + subject);                                          
                     String htmlBody = getPlainText('Email Body', whereClauseFieldValueMap, templateName);
                     System.debug('this is Body :' + htmlBody);                                          
                     System.debug('communicateScheduledEvent ---> 3');
                     System.debug('toRecipientList :' +toRecipientIdList);    
                    for (Id recipientId: toRecipientIdList){
                        System.debug('recipientId :' +recipientId); 
                        System.debug('ccRecipientList :' +ccRecipientList);
                        System.debug('subject :' +subject);
                        System.debug('htmlBody :' +htmlBody);
                        System.debug('fromEmailId :' +fromEmailId);
                        System.debug('fromDisplayName :' +fromDisplayName);
                        System.debug('replyToEmailId :' +replyToEmailId);
                        sendEmailCostco(recipientId, ccRecipientList, subject, htmlBody, fromEmailId, fromDisplayName, replyToEmailId, sceList);             
                    }
              }

  public static String getPlainText(String recordType, Map<String, String> whereClauseFieldValueMap, String emailTemplateName){

        String ret = '';
        String tempQuery = ' ';
        boolean firstRec = true;
        String tempObj = ' ';
        String tempObjectName = ' '; 
        String tempWhereClause = ' ';
        Map<string,string> emailDBFieldMap = new Map<string,string>();
        Map<string,string> emailDefaultValMap = new Map<string,string>();
        Map<string,string> emailFieldOutputTypeMap = new Map<string,string>();
        Map<string,string> tempEmailDBFieldMap = new Map<string,string>();
        Map<string,string> tempEmailDefaultValMap = new Map<string,string>();
        Map<string,string> tempEmailFieldOutputTypeMap = new Map<string,string>();
        Map<String,Map<string,string>> objEmailDBFieldMap = new Map<String,Map<string,string>>();
        Map<String,Map<string,string>> objEmailDefaultValMap = new Map<String,Map<string,string>>();
        Map<String,Map<string,string>> objEmailFieldOutputTypeMap = new Map<String,Map<string,string>>();
        Map<string,object> dbFieldValueMap = new Map<string,object>();
        Map<string,string> dbFieldParentObjMap = new Map<string,string>();
        Map<string,string> tempDbFieldParentObjMap = new Map<string,string>();
        Map<String,Map<string,string>> objDbFieldParentObjMap = new Map<String,Map<string,string>>();
        Map<string,string> objWhereClauseMap = new Map<string,string>(); 
        List<String> objList = new List<String>(); 
        List<SObject> sobjList = new List<SObject>();
       
        for(Custom_Email_Template__c cet : [select Custom_Email_Template_Data__c 
                                            from Custom_Email_Template__c 
                                           where Name = :emailTemplateName 
                                             and Record_Type__c = :recordType
                                           order by Seq_No__c]){
          ret += cet.Custom_Email_Template_Data__c;

        }
        
        for(Custom_Email_Object_Mapping__c ceo : [select Object_Name__c,
                                                         Where_Field_Name__c, 
                                                         Where_Field_Data_Type__c,
                                                         Where_Field_Value__c  
                                                    from Custom_Email_Object_Mapping__c 
                                                   where Name = :emailTemplateName 
                                                     and Record_Type__c = :recordType
                                                order by Object_Name__c, Seq_No__c]){
          if(firstRec){
            tempObjectName = ceo.Object_Name__c; 
            firstRec = false; 
            objList.add(ceo.Object_Name__c);
          }

          If(ceo.Object_Name__c != tempObjectName){
             objWhereClauseMap.put(tempObjectName, tempWhereClause);   
             objList.add(ceo.Object_Name__c);    
             tempObjectName = ceo.Object_Name__c;
             tempWhereClause = ' '; 
          }
          if (ceo.Where_Field_Data_Type__c == 'id' || ceo.Where_Field_Data_Type__c == 'text'){
              tempWhereClause = ceo.Where_Field_Name__c + ' = \'' + whereClauseFieldValueMap.get(ceo.Where_Field_Value__c) + '\'';
          }else{
              tempWhereClause = ceo.Where_Field_Name__c + ' = : whereClauseFieldValueMap.get(ceo.Where_Field_Value__c)';
          }   
                   
        }
        objWhereClauseMap.put(tempObjectName, tempWhereClause);   
        System.debug('objWhereClauseMap : ' +objWhereClauseMap); 
        
        for(String objName: objList){
           firstRec = true; 
           tempQuery = 'Select ';
           for(Custom_Email_Field_Mapping__c csFieldMapping: [Select Object_Name__c, 
                                                                Parent_Object_Name__c,
                                                                Database_Field_Name__c,
                                                                Email_Field_Name__c, 
                                                                Default_Value__c,
                                                                Output_Data_Type__c,
                                                                Object_For_Duplicate_Field__c 
                                                           from Custom_Email_Field_Mapping__c 
                                                           where Name = :emailTemplateName
                                                             and Record_Type__c = :recordType
                                                             and Object_Name__c = :objName]){
            
              if (firstRec) {
                  if (csFieldMapping.Parent_Object_Name__c != null){
                      tempQuery += csFieldMapping.Parent_Object_Name__c + '.' +csFieldMapping.Database_Field_Name__c;  
                      if(csFieldMapping.Object_For_Duplicate_Field__c != null){
                         dbFieldParentObjMap.put(csFieldMapping.Database_Field_Name__c + ':' + csFieldMapping.Object_For_Duplicate_Field__c, 
                                                 csFieldMapping.Parent_Object_Name__c);  
                      }else{
                         dbFieldParentObjMap.put(csFieldMapping.Database_Field_Name__c, csFieldMapping.Parent_Object_Name__c);
                      }
                  }else{
                      tempQuery += csFieldMapping.Database_Field_Name__c;
                  }
                  tempObj = csFieldMapping.Object_Name__c;
                  firstRec = false;
              } else {
                  if (csFieldMapping.Parent_Object_Name__c != null){
                      tempQuery += ', ' + csFieldMapping.Parent_Object_Name__c + '.' + csFieldMapping.Database_Field_Name__c;
                      if(csFieldMapping.Object_For_Duplicate_Field__c != null){
                         dbFieldParentObjMap.put(csFieldMapping.Database_Field_Name__c +':'+ csFieldMapping.Object_For_Duplicate_Field__c, 
                                                 csFieldMapping.Parent_Object_Name__c);
                      }else{
                         dbFieldParentObjMap.put(csFieldMapping.Database_Field_Name__c, csFieldMapping.Parent_Object_Name__c);
                      }
                  }else{
                      tempQuery += ', ' + csFieldMapping.Database_Field_Name__c;
                  }    
              }

              if(csFieldMapping.Object_For_Duplicate_Field__c != null){
                 emailDBFieldMap.put(csFieldMapping.Email_Field_Name__c, 
                                     csFieldMapping.Database_Field_Name__c +':'+csFieldMapping.Object_For_Duplicate_Field__c);     
              }else{
                 emailDBFieldMap.put(csFieldMapping.Email_Field_Name__c, csFieldMapping.Database_Field_Name__c);    
              }
              emailDefaultValMap.put(csFieldMapping.Email_Field_Name__c, csFieldMapping.Default_Value__c);       
              emailFieldOutputTypeMap.put(csFieldMapping.Email_Field_Name__c, csFieldMapping.Output_Data_Type__c);
          }
          System.debug('This is temp query :'+ tempQuery);
          System.debug('emailDBFieldMap1 : ' +emailDBFieldMap);
          System.debug('emailDefaultValMap1 : '+emailDefaultValMap); 
          System.debug('dbFieldParentObjMap1 : ' +dbFieldParentObjMap);
          
          tempEmailDBFieldMap = emailDBFieldMap.clone();
          objEmailDBFieldMap.put(objName, tempEmailDBFieldMap); 
          emailDBFieldMap.clear(); 

          tempEmailDefaultValMap = emailDefaultValMap.clone(); 
          objEmailDefaultValMap.put(objName, tempEmailDefaultValMap);
          emailDefaultValMap.clear(); 

          tempDbFieldParentObjMap = dbFieldParentObjMap.clone();
          objDbFieldParentObjMap.put(objName, tempDbFieldParentObjMap); 
          dbFieldParentObjMap.clear();

          tempEmailFieldOutputTypeMap = emailFieldOutputTypeMap.clone();
          objEmailFieldOutputTypeMap.put(objName, tempEmailFieldOutputTypeMap); 
          emailFieldOutputTypeMap.clear();

          tempQuery += ' from ' + tempObj + ' where ' + objWhereClauseMap.get(objName);
          System.debug('tempQuery : ' +tempQuery);

          System.debug('Before adding to sobjList');
         	if((Database.query(tempQuery)).size() > 0){
             sobjList.add(Database.query(tempQuery));
          }           
          System.debug('After adding to sobjList');
        }  

        for(SObject tempBaseObj : sobjList){
            List<String> dbFieldName = new List<String>();
            String currentObjName = (tempBaseObj.Id).getSObjectType().getDescribe().getName();
            for(String tempEmailDBField: objEmailDBFieldMap.get(currentObjName).values()){
                System.debug('tempEmailDBField : ' + tempEmailDBField);
                dbFieldName.clear();
                if(tempEmailDBField.contains(':')){
                   dbFieldName = tempEmailDBField.split(':',2);   
                }else{
                   dbFieldName.add(tempEmailDBField);
                }
                System.debug('dbFieldName : ' +dbFieldName);
                if(objDbFieldParentObjMap.get(currentObjName).get(tempEmailDBField) != null){  
                    sObject tempParentObj = tempBaseObj; 
                    sObject tempParentObjNew; 
                    List<String> parentObjList = objDbFieldParentObjMap.get(currentObjName).get(tempEmailDBField).split('\\.', 0); 
                    System.debug('parentObjList :' +parentObjList);
                    for (String tempParentObjName : parentObjList){
                       System.debug('tempParentObjName :' +tempParentObjName);
                       tempParentObjNew = tempParentObj.getSObject(tempParentObjName);
                       tempParentObj    = tempParentObjNew; 
                       System.debug('tempParentObjNew :' +tempParentObjNew);
                    }
                    dbFieldValueMap.put(tempEmailDBField, tempParentObj.get(dBFieldName.get(0)));
                } else {
                    dbFieldValueMap.put(tempEmailDBField, tempBaseObj.get(dBFieldName.get(0))); 
                }   
                System.debug('====1===');
            } 
        

            for(string tempEmailField: objEmailDBFieldMap.get(currentObjName).keyset()){
               String tempFieldValString = ' ';
               Date tempFieldValDate; 
               Datetime tempFieldValDT;
               System.debug('====2===');
               String tempEmailDBField = objEmailDBFieldMap.get(currentObjName).get(tempEmailField);
               Object tempFieldVal = dbFieldValueMap.get(tempEmailDBField);
               if (objEmailFieldOutputTypeMap.get(currentObjName).get(tempEmailField) == 'Long Date'){
                   tempFieldValDate = Date.valueOf(tempFieldVal);
                   tempFieldValDT = Datetime.newInstance(tempFieldValDate, Time.newInstance(12, 0, 0, 0));
                   tempFieldValString = tempFieldValDT.format('EEEEEEEEE, MMMMMMMMM d, yyyy');
                   if(emailTemplateName.contains('Spanish')){
                  Map<String,String> WeekdaysSpanish = new Map<String,String>{'Monday' => 'lunes','Tuesday' => 'martes','Wednesday' => 'miércoles', 'Thursday' => 'jueves', 
                  'Friday' => 'viernes', 'Saturday' => 'sábado', 'Sunday' => 'domingo','January' => 'enero', 'February' => 'febrero', 'March' => 'marzo', 'April' => 'abril', 'May' => 'mayo', 'June' => 'junio',
      'July' => 'julio', 'August' => 'augosto', 'September' => 'septiembre', 'October' => 'octubre', 'November' => 'noviembre', 'December' => 'diciembre'};
                   for(String s: WeekdaysSpanish.keyset())
                      {
                          tempFieldValString = tempFieldValString.replace(s,WeekdaysSpanish.get(s));
                       }
                   }    
               }else if(objEmailFieldOutputTypeMap.get(currentObjName).get(tempEmailField) == 'Long Date Time'){
                   tempFieldValDT = DateTime.valueOf(tempFieldVal);
                   tempFieldValString = tempFieldValDT.format('EEEEEEEEE, MMMMMMMMM d, yyyy h:mm a');
                   if(emailTemplateName.contains('Spanish')){
                  Map<String,String> WeekdaysSpanish = new Map<String,String>{'Monday' => 'lunes','Tuesday' => 'martes','Wednesday' => 'miércoles', 'Thursday' => 'jueves', 
                  'Friday' => 'viernes', 'Saturday' => 'sábado', 'Sunday' => 'domingo','January' => 'enero', 'February' => 'febrero', 'March' => 'marzo', 'April' => 'abril', 'May' => 'mayo', 'June' => 'junio',
      'July' => 'julio', 'August' => 'augosto', 'September' => 'septiembre', 'October' => 'octubre', 'November' => 'noviembre', 'December' => 'diciembre'};
                   for(String s: WeekdaysSpanish.keyset())
                      {
                          tempFieldValString = tempFieldValString.replace(s,WeekdaysSpanish.get(s));
                       }
                   }    
               }else if(objEmailFieldOutputTypeMap.get(currentObjName).get(tempEmailField) == 'String Long Date Time'){
                   String tempFieldVal1 = String.valueOf(tempFieldVal); 
                   tempFieldValDT = DateTime.parse(tempFieldVal1);
                   tempFieldValString = tempFieldValDT.format('EEEEEEEEE, MMMMMMMMM d, yyyy h:mm a');
                   if(emailTemplateName.contains('Spanish')){
                      Map<String,String> WeekdaysSpanish = new Map<String,String>{'Monday' => 'lunes','Tuesday' => 'martes','Wednesday' => 'miércoles', 'Thursday' => 'jueves', 
                      'Friday' => 'viernes', 'Saturday' => 'sábado', 'Sunday' => 'domingo','January' => 'enero', 'February' => 'febrero', 'March' => 'marzo', 'April' => 'abril', 'May' => 'mayo', 'June' => 'junio',
                      'July' => 'julio', 'August' => 'augosto', 'September' => 'septiembre', 'October' => 'octubre', 'November' => 'noviembre', 'December' => 'diciembre'};
                      for(String s: WeekdaysSpanish.keyset())
                      {
                          tempFieldValString = tempFieldValString.replace(s,WeekdaysSpanish.get(s));
                       }
                   }    
               }else{ 
                   tempFieldValString = String.valueOf(tempFieldVal);
               }
               if (tempfieldVal != null) {
                  ret = ret.replace(tempEmailField,tempFieldValString);
               } else if (objEmailDefaultValMap.get(currentObjName).get(tempEmailField) != null){
                  ret = ret.replace(tempEmailField,objEmailDefaultValMap.get(currentObjName).get(tempEmailField));  
               } else if (objEmailDefaultValMap.get(currentObjName).get(tempEmailField) == null){
                  ret = ret.replace(tempEmailField, ' ');  
               }    
            }

        }
        System.debug('ret : ' +ret);
        return ret;

  }
    
  public static void sendEmail(Id targetObjectId, List<String> ccRecipientList, String subject, String htmlBody, String fromEmailId, String fromDisplayName, String replyToEmailId){   
            System.debug('recipientId :' +targetObjectId);                   
            System.debug('ccRecipientList :' +ccRecipientList);
            System.debug('subject :' +subject);
            System.debug('htmlBody :' +htmlBody);
            System.debug('fromEmailId :' +fromEmailId);
            System.debug('fromDisplayName :' +fromDisplayName);
            System.debug('replyToEmailId :' +replyToEmailId);
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setHtmlBody(htmlBody);
        mail.setSubject(subject);
        mail.setTargetObjectId(targetObjectId);
        mail.setBccAddresses(ccRecipientList);
      //  mail.setCcAddresses(ccRecipientList);
        
        if(targetObjectId.getSObjectType().getDescribe().getName() == 'Contact'|| targetObjectId.getSObjectType().getDescribe().getName() == 'Lead' || targetObjectId.getSObjectType().getDescribe().getName() == 'User'){
            mail.setSaveAsActivity(true);
            System.debug('Setting HTML Email Tracking on');
        }else{
            mail.setSaveAsActivity(false);
            System.debug('Setting HTML Email Tracking off');
        }
        
        if (replyToEmailId != null && fromDisplayName != null){
            mail.setSenderDisplayName(fromDisplayName);
            mail.setReplyTo(replyToEmailId);
        } 
        else if(fromEmailId != null && fromEmailId != ''){
            System.debug('fromEmailId : ' +fromEmailId);
            OrgWideEmailAddress[] owea = [select Id, DisplayName from OrgWideEmailAddress where Address =:fromEmailId];
            if(owea != null && owea.size() > 0 ){
               mail.setOrgWideEmailAddressId(owea.get(0).Id);
            }     
        }

       Messaging.SendEmailResult[] results =  Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        Messaging.SendEmailError[] errors = new List<Messaging.SendEmailError>();
          for( Messaging.SendEmailResult currentResult : results ) {
            errors = currentResult.getErrors();
            String emailErrorReport = '';
            if( null != errors ) {
              for( Messaging.SendEmailError currentError : errors ) {
                  emailErrorReport += emailErrorReport + '(' + currentError.getStatusCode() + ') '
                                   + currentError.getMessage() + '\r\n' ;
              }
              System.debug('MESSAGE>>>>>> Email Error Report '+ emailErrorReport);
            }else{
              System.debug('No error');
            }
        }   
  }
  
   public static void sendEmailCostco(Id targetObjectId, List<String> ccRecipientList, String subject, String htmlBody, String fromEmailId, String fromDisplayName, String replyToEmailId, List<Service_Contract_Event__c> sceList){   
                
                    for(Service_Contract_Event__c event : sceList)
                    {     
                   System.debug('recipientId :' +targetObjectId); 
                        System.debug('ccRecipientList :' +ccRecipientList);
                        System.debug('subject :' +subject);
                        System.debug('htmlBody :' +htmlBody);
                        System.debug('fromEmailId :' +fromEmailId);
                        System.debug('fromDisplayName :' +fromDisplayName);
                        System.debug('replyToEmailId :' +replyToEmailId);
                        String TemplateName;
                  if(event.Service_Contract__r.Opportunity__r.Purchased_Thru__c == 'Costco')
                      TemplateName = 'Install Complete Direct Email';
                 //  EmailTemplate et=[Select id from EmailTemplate where name='Install Complete Direct Email'];
                   else 
                      TemplateName = 'Install Complete Direct Email Non Costco';
                     EmailTemplate et=[Select id from EmailTemplate where name=: TemplateName];
                        
                  Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                  mail.setTargetObjectId(targetObjectId);
                  mail.setBccAddresses(ccRecipientList);
                  mail.setCcAddresses(ccRecipientList);
                  mail.setTemplateId(et.Id);
                  //  Id CurrentRecord = ApexPages.currentPage().getParameters().get('id');''
                //    Id CurrentRecord = 'a6560000000Y4S5';
                   mail.setWhatId(event.Id);
                
               
                    if (fromDisplayName != null){ //replyToEmailId != null && 
                        mail.setSenderDisplayName(fromDisplayName);
                        mail.setReplyTo(replyToEmailId);
                    } 
                    else if(fromEmailId != null && fromEmailId != ''){
                        System.debug('fromEmailId : ' +fromEmailId);
                              OrgWideEmailAddress[] owea = [select Id, DisplayName from OrgWideEmailAddress where Address =:fromEmailId];
                              if(owea != null && owea.size() > 0 ){
                                   mail.setOrgWideEmailAddressId(owea.get(0).Id);
                              }         
                    }
                      //    List<Messaging.SendEmailResult> results = Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
                        Messaging.SendEmailResult[] results =  Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
                        Messaging.SendEmailError[] errors = new List<Messaging.SendEmailError>();
                        if(!results.isEmpty())
                        {
                        for( Messaging.SendEmailResult currentResult : results ) {
                              errors = currentResult.getErrors();
                              String emailErrorReport = '';
                              if( null != errors ) {
                                  for( Messaging.SendEmailError currentError : errors ) {
                                        emailErrorReport += emailErrorReport + '(' + currentError.getStatusCode() + ') '
                                                                 + currentError.getMessage() + '\r\n' ;
                                  }
                                  System.debug('MESSAGE>>>>>> Email Error Report '+ emailErrorReport);
                              }else{
                                  System.debug('No error');
                              }
                        } 
                    } 
                  }
                }
    /* BSKY-6575 logic start */
    public static void CommunicateCancelEvent(Map<String, String> whereClauseFieldValueMap, String templateName,List<Id> toRecipientIdList, List<String> ToAddrRecipientList,String fromDisplayName, String fromEmailId, String replyToEmailId)
    {
        
        System.debug('This is cancel WhereClause :' + whereClauseFieldValueMap);
        System.debug('This is cancel Template :' + templateName);
        System.debug('This is cancel Recipient List :' + toRecipientIdList);
        String subject  = getPlainText('Email Subject', whereClauseFieldValueMap, templateName); 
        System.debug('this is cancel subject :' + subject);  
        String htmlBody = getPlainText('Email Body', whereClauseFieldValueMap, templateName);                                        
        System.debug('this is cancel Body :' + htmlBody);                                          
        System.debug('this is cancel toRecipientList :' +toRecipientIdList); 
      //  System.debug('this is cancel BCcRecipientList :' +BCcRecipientList); 
        System.debug('this is cancel ToAddrRecipientList :' +ToAddrRecipientList); 
        
        for (Id recipientId: toRecipientIdList)
        {
            System.debug('Cancel recipientId :' +recipientId);   
            //  System.debug('Cancel BCcRecipientList :' +BCcRecipientList);
            System.debug('Cancel subject :' +subject);
            System.debug('Cancel htmlBody :' +htmlBody); 
            sendEmail(recipientId, ToAddrRecipientList, subject, htmlBody, fromEmailId, null, null);
            // sendCancelEmail(recipientId, BCcRecipientList,sceToAddrRecipientList,subject, htmlBody, fromDisplayName, fromEmailId,  null);             
        }
        
    }
    
   /* public static void sendCancelEmail(Id targetObjectId, List<String> BccRecipientList,List<String> ToAddrRecipientList, String subject, String htmlBody, String fromDisplayName, String fromEmailId, String replyToEmailId ){   
        System.debug('Cancel recipientId :' +targetObjectId);                   
        System.debug('Cancel BCcRecipientList :' +BCcRecipientList);
        System.debug('Cancel ToAddrRecipientList:' +ToAddrRecipientList);
        System.debug('Cancel subject :' +subject);
        System.debug('Cancel htmlBody :' +htmlBody);
        String TemplateName = 'Cancellation - Customer Initiated';
        EmailTemplate et=[Select id from EmailTemplate where name=: TemplateName];
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setHtmlBody(htmlBody);
        mail.setSubject(subject);
        mail.setTargetObjectId(targetObjectId);
        mail.setBccAddresses(BccRecipientList);
        mail.setToAddresses(ToAddrRecipientList);
        
        if(targetObjectId.getSObjectType().getDescribe().getName() == 'Contact'|| targetObjectId.getSObjectType().getDescribe().getName() == 'Lead' || targetObjectId.getSObjectType().getDescribe().getName() == 'User'){
            mail.setSaveAsActivity(true);
            System.debug('Setting HTML Email Tracking on');
        }else{
            mail.setSaveAsActivity(false);
            System.debug('Setting HTML Email Tracking off');
        }
        
    
       if(fromEmailId != null && fromEmailId != ''){
            System.debug('fromEmailId : ' +fromEmailId);
            OrgWideEmailAddress[] owea = [select Id, DisplayName from OrgWideEmailAddress where Address =:fromEmailId];
            if(owea != null && owea.size() > 0 ){
                mail.setOrgWideEmailAddressId(owea.get(0).Id);
            }     
        }
        //   mail.setTemplateId(et.Id);
        Messaging.SendEmailResult[] results =  Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        Messaging.SendEmailError[] errors = new List<Messaging.SendEmailError>();
        for( Messaging.SendEmailResult currentResult : results ) {
            errors = currentResult.getErrors();
            String emailErrorReport = '';
            if( null != errors ) {
                for( Messaging.SendEmailError currentError : errors ) {
                    emailErrorReport += emailErrorReport + '(' + currentError.getStatusCode() + ') '
                        + currentError.getMessage() + '\r\n' ;
                }
                System.debug('MESSAGE>>>>>> Email Error Report '+ emailErrorReport);
            }else{
                System.debug('No error');
            }
        }   
    }
                
  /*BSKY-6575 Logic End */
}