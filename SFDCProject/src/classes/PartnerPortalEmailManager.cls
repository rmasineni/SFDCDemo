public class PartnerPortalEmailManager {

    
    public static void communicateUsername(User userobj) {
        
        System.debug('userobj:'  + userobj);
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

        EmailTemplate et = [SELECT id FROM EmailTemplate WHERE name = 'PRMForgotUserNameV1_0'];
        
        mail.setSenderDisplayName('Sunrun Partner Concierge Team');
        List<String> toAddresses = new List<String>(); 
        toAddresses.add(userobj.email);
        // Assign the addresses for the To and CC lists to the mail object. 
        mail.setToAddresses(toAddresses);
        mail.setTargetObjectId(userobj.id); // Specify who the email should be sent to.
        mail.setTemplateId(et.id);
        mail.setSaveAsActivity(false);
        
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});                 
    }
    
    public static void communicateUsernameAEE(User userobj) {
        
        System.debug('userobj:'  + userobj);
        OrgWideEmailAddress[] owa = [select id, Address, DisplayName from OrgWideEmailAddress where DisplayName = 'AEE Team' limit 1];
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        
        EmailTemplate et = [SELECT id FROM EmailTemplate WHERE name = 'AEE_Community_Forgot_Username_Email'];
        
        //string oweaId = owa[0].Id;
        
        List<String> toAddresses = new List<String>(); 
        toAddresses.add(userobj.email);
        // Assign the addresses for the To and CC lists to the mail object. 
        mail.setToAddresses(toAddresses);
        if(owa[0].id != null){
        mail.setorgwideemailaddressid(owa[0].id);
        }
        mail.setTargetObjectId(userobj.id); // Specify who the email should be sent to.
        mail.setTemplateId(et.id);
        mail.setSaveAsActivity(false);
        
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});                 
    }

    @IsTest(SeeAllData=true) 
    public static void testemail(){
        Account accountObj1 = TestPRMLibrary.insertAccount('PRMPartnerAccount1', PRMLibrary.PARTNER);
        accountObj1.IsPartner = true;
        update accountObj1;

        Contact contactObj1 = TestPRMLibrary.insertContact('PRMTestAccount1',PRMLibrary.PARTNER, 
                                            'PRMTestLastName1','sunrunprmcontact11@gmail.com');     
        contactObj1.accountId = accountObj1.Id;
        contactObj1.FirstName = 'PRMTest1';
        update contactObj1;
        
        List<Profile> profiles = [Select Id , name from Profile where name like '%gold%'];
        
        User newUserObj = new User();
        newUserObj.ProfileId = profiles[0].Id;
        newUserObj.FirstName = contactObj1.firstname;
        newUserObj.LastName = contactObj1.lastname;
        newUserObj.Email = contactObj1.email;
        newUserObj.title = 'title1';
        newUserObj.Username = contactObj1.email;
        newUserObj.contactId = contactObj1.id;
        newUserObj.TimeZoneSidKey = 'America/Los_Angeles';
        newUserObj.EmailEncodingKey = 'ISO-8859-1';
        newUserObj.LocaleSidkey = 'en_US';
        newUserObj.LanguageLocaleKey = 'en_US';
        newUserObj.alias = 'abxz';
        newUserObj.CommunityNickname = 'prmtest1';
        newUserObj.Security_Answer__c = 'SunRun';
        newUserObj.Security_Question__c = 'CompanyName';
        insert  newUserObj;

        /*newUserObj.FirstName = contactObj1.FirstName + '1';
        newUserObj.LastName = contactObj1.lastname  + '1';
        newUserObj.Email = 'prmmodified@gmail.com';
        update newUserObj;*/
        
        PartnerPortalEmailManager.communicateUsername(newUserObj);
    }
    
    

    /*
    public static void communicateUsername(User userobj) {
            
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String organizationName =  userobj.CompanyName; 
        List<String> toAddresses = new List<String>();
        toAddresses.add(userobj.email);
        
        String subject = 'SunRun partner portal Username';

        String htmlBody = '<html>';
        htmlBody += EmailService.getHTMLHeader();
        htmlBody += '<p></p>';
        htmlBody += getPlainTextBodyForUserName(userobj);
        htmlBody += EmailService.getHTMLFooter();
        htmlBody += '</html>';
        sendEmail(toAddresses, subject, htmlBody);  
    }

    private static String getPlainTextBodyForUserName(User userObj){
        String name = '';
        name += (userObj.Firstname != null) ? userObj.Firstname : '';
        name += ' ';
        name += (userObj.Lastname != null) ? userObj.Lastname : '';
        String ret = '';
        ret += '<p>Dear ' + name   + ',</p><br/>';

        ret += '<p></p>';
        ret += '<p></p>';
        ret += 'Your SunRun partner portal user name is below.';
        ret += 'Note that your user name is in the form of email address.<br/>';
        ret += '<br/>';         
        ret += '<p></p>';       
        ret += 'Username: '+  userObj.username + '<br/>';
        ret += '<br/>';
        ret += '<br/>';
        ret += '<p></p>';
        ret += 'Thank you<br/>';
        ret += '<p></p>';
        ret += '<p></p>';
        ret += '<p></p>';
        return ret;
    }

    public static void sendEmail(List<String> toAddresses, String subject, String htmlBody){

        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setHtmlBody(htmlBody);
        mail.setSubject(subject);
        mail.setToAddresses(toAddresses);
        
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
    */
}