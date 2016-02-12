trigger trg_casecomment_after_insert_update on CaseComment (after insert, after update) {
    
    case caseRec = new case();
    User userObj = new User();
    String toAddr = '';
    Boolean isPartnerUser;
    for(CaseComment CaseCommentObj: Trigger.new){
        
        List<case> caseObjList = [Select id,RecordType.Name,CreatedById,CaseNumber,subject  from case where id =: CaseCommentObj.ParentId limit 1];
        if(caseObjList != null && caseObjList.size() > 0){
                caseRec = caseObjList[0];
        }
        
        isPartnerUser = false;
        userObj = PRMContactUtil.getLoginUser();       
        if(userObj != null && userObj.ContactId != null){
            isPartnerUser = true;
        }
        
        if(caseRec.RecordType.Name == Label.Partner_Help_Record_Type && CaseCommentObj.IsPublished == true && isPartnerUser == false){
         
            if(trigger.isInsert || trigger.isupdate){
                List<User> userObjList = [select id, name, email from User where id =: caseRec.CreatedById limit 1];
                if(userObjList != null && userObjList.size() > 0){
                    userObj = userObjList[0];
                }
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                List<String> toAddresses = new List<String>();
                toAddr = userObj.email;
                toAddresses.add(toAddr);
                
                String subject = 'New case comment notification for ' + caseRec.CaseNumber ;
                String htmlBody = '<html>';
                
                htmlBody += EmailService.getHTMLHeader();
                htmlBody += '<p></p>';
                htmlBody += 'Hi ' + userObj.name +',' + '<br/>';
                htmlBody += '<br/>';
                htmlBody += UserInfo.getName() + ' has added a comment to case ' + caseRec.CaseNumber + ': ' + caseRec.subject;
                htmlBody += '<br/> <br/> Case Comment : ';
                htmlBody += '<br/>'+ CaseCommentObj.CommentBody;
          
                htmlBody += '<br/> <br/>';
                htmlBody += 'Thank you';
                htmlBody += '<br/> From <br/> Partner Help Support Team <br/> <br/>';
                htmlBody += EmailService.getHTMLFooter();
                htmlBody += '</html>';
                mail.setHtmlBody(htmlBody);
                mail.setSubject(subject);
                mail.setToAddresses(toAddresses);
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });    
                
                
            }    
        }
    }
    
}