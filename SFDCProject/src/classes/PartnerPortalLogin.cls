public class PartnerPortalLogin {

    public String email {get; set;}
    public String username {get; set;}
    public String password {get; set {password = value == null ? value : value.trim(); } }
    public Boolean testUser = false;
    public String securityQuestion {get;set;}
    public String securityAnswer {get;set;}
    public User loginUserObj;
    public PageReference portalHomePage;
    public boolean forgotPassword;
    public boolean forgotUsername;

    public String userSercurityQuestion {get;set;}
    public Boolean showSecurityQuestion {get;set;}
    public String userSercurityAnswer {get;set;}    
    public String securityAnswerInput {get;set;}
    public String confirmMessage {get;set;}

    public String loginContent1 {get;set;}
    public String loginContent2 {get;set;}
    public String loginContent3 {get;set;}
    public String loginContent4 {get;set;}
    public String loginContent5 {get;set;}
            
    public String loginContentTitle1 {get;set;}
    public String loginContentTitle2 {get;set;}
    public String loginContentTitle3 {get;set;}
    public String loginContentTitle4 {get;set;}
    public String loginContentTitle5 {get;set;}
                
    public PartnerPortalLogin(){

        System.debug('PartnerPortalLogin');
        forgotPassword = false;
        forgotUsername = false;
        email = '';
        userSercurityAnswer = '';
        
        securityAnswerInput = '';
        initializeMessages();
        System.debug('Before: initializeArticles');
        
        initializeArticles();
        System.debug('After: initializeArticles');
    }

    public PartnerPortalLogin(Boolean testUser){
        email = '';
        if(testUser == true){
            userList = new List<User>();
            User userObj = new user();
            userObj.username = 'testUser@sunrun.com1';
            userList.add(userObj);
        }
        initializeMessages();
    }

    List<User> userList;
    public PageReference login() {
        String siteUrl = '/home/home.jsp';
        //String siteUrl = '/apex/PartnerPortalLanding';
        portalHomePage = Site.login(username, password, siteUrl);
        if(portalHomePage == null){
            System.debug('Null reference ...');
            return portalHomePage;
        }else{
            initializeUserDetails(username);
            System.debug('loginUserObj: ' + loginUserObj);
            if(loginUserObj != null 
                && loginUserObj.Security_Question__c != null 
                && loginUserObj.Security_Question__c != ''
                && loginUserObj.Security_Answer__c != null
                && loginUserObj.Security_Answer__c != ''){
                return portalHomePage;
            }
            PageReference pr = Page.PartnerPortalSecurityQA;
            //pr.setRedirect(true);
            return pr;  
        }
        return null;
    }
    
    public Boolean CheckPortalUser(){
        Boolean userNameExists = false;
        String tempUserName = '';
         String tempEmail = '';
        if(email != null){
            tempEmail = email.trim();
        }
        try{
            System.debug('tempEmail: ' + tempEmail);
            if(tempEmail != null && tempEmail != ''){
                userList = [select id, Security_Question__c, Security_Answer__c, firstname, lastname,
                             CompanyName, email, username, ContactId, isactive from User 
                                where email =:tempEmail 
                                and contactId != null
                                and isactive = true];                       
            }

            if(userList != null && userList.size() > 0){
                userNameExists = true;
                if(username == null || username == ''){
                    username = userList[0].username;
                }

                if(userSercurityQuestion == null || userSercurityQuestion == ''){
                    userSercurityQuestion = userList[0].Security_Question__c;
                }
                if(userSercurityAnswer == null || userSercurityAnswer == ''){
                    userSercurityAnswer = userList[0].Security_Answer__c;
                }
            }
            System.debug('userList: ' + userList);
        }
        catch(Exception e){
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, 'error is: ' + e.getMessage());             
            ApexPages.addMessage(msg);
        }
        System.debug('userNameExists: ' + userNameExists);
        return userNameExists;
    }
    
    public static Boolean CheckIsAEEUser(){
    
      string URL = Apexpages.currentPage().getUrl();
      boolean isAEEUser = false;
      if(URL != null && URL.contains('aeepartner')){
      isAEEUser = true;
      }
      return isAEEUser;
    }
    
    
    public PageReference forgotPassword() {     
        try{        
            if(email == null || email == ''){
                ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Enter a valid email address');             
                ApexPages.addMessage(msg);
                return null;
            }
            
            if(CheckPortalUser())
            {
               boolean success = Site.forgotPassword(username);
               PageReference pr = Page.PartnerPortalConfirm;
               pr.setRedirect(true);
               if (success) {           
                   pr.getParameters().put('messagetype', 'PasswordSuccess');
                   return pr;
               }
            }
            else
            {
                 ApexPages.Message msg2 = new ApexPages.Message(ApexPages.Severity.ERROR, 'You are not a valid SunRun portal user. Please Contact SunRun partner manager.');               
                 ApexPages.addMessage(msg2);
                 return null;               
            }
        }
        catch(Exception e){
            ApexPages.Message msg2 = new ApexPages.Message(ApexPages.Severity.ERROR, 'Problem resetting SunRun partner portal password.  Please Contact SunRun partner manager.');            
            ApexPages.addMessage(msg2);
            return null;
        }
        return null;
    }
    
    Public PageReference returnTologinPage(){
        email = null;
        username = null;
        password = null;
        
        securityQuestion = null;
        securityAnswer = null;
        password = null;
        portalHomePage = null;
        
        showSecurityQuestion = false;
        userSercurityQuestion = null;
        userSercurityAnswer = null;
        securityAnswerInput = null;

        PageReference pr = Page.PartnerPortalLogin;
        pr.setRedirect(true);
        return pr;
    }

    Public PageReference needSigningHelpPage(){
        PageReference pr = Page.PartnerPortalNeedHelp;
        pr.setRedirect(true);
        return pr;
    }
    
    Public PageReference forgotPasswordPage(){
        PageReference pr = Page.PartnerPortalForgotPassword;
        pr.setRedirect(true);
        return pr;
    }

    public void initForgotpassword(){
        forgotPassword = true;
        forgotUsername = false;
    }

    public void initForgotUsername(){
        forgotUsername = true;
        forgotPassword = false;
    }

    public PageReference savesecurityQuestion(){
        System.debug('Before update ..');

        if(securityQuestion == null || securityQuestion == ''){
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Enter a valid Security Question');             
            ApexPages.addMessage(msg);
            return null;
        }       

        if(securityAnswer == null || securityAnswer == ''){
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Enter a valid Security Answer');             
            ApexPages.addMessage(msg);
            return null;
        }
        
        if(loginUserObj != null){
            loginUserObj.Security_Question__c =     securityQuestion;
            loginUserObj.Security_Answer__c =   securityAnswer; 
            update  loginUserObj;
            
            String siteUrl = '/home/home.jsp';
            System.PageReference pageRef = Site.login(username, password, siteUrl);
            if(pageRef != null){
                pageRef.setRedirect(true);
            }
            return pageRef;         
            
        }
        if(portalHomePage == null){
            System.debug('Null ....');
        }else{
            System.debug('Not Null ....');
        }
        return portalHomePage;
    }

    public void initializeUserDetails(String username){
        //Id userId = UserInfo.getUserId();
        System.debug('username: ' + username);
        List<User> userList = new List<User>();
        userList = [Select Id, name, Security_Question__c, Security_Answer__c, 
                            UserType, userName, profileId, 
                            email, contactId from User where userName = :username];
        if(userList != null && userList.size() > 0){
            loginUserObj = userList[0];
        }
        
    }

    public PageReference showSecurityQuestion() {    

        if(email == null || email == ''){
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Enter a valid email address');             
            ApexPages.addMessage(msg);
            return null;
        }
        if(CheckPortalUser() && !CheckIsAEEUser()) {
            if(userSercurityQuestion == null || userSercurityQuestion == ''){                       
                System.debug('userList1: ' + userList);
                PageReference pr = Page.PartnerPortalConfirm;
                if(userList != null && userList.size() > 0 && userList[0] != null){
                    System.debug('userList: ' + userList);
                    if(forgotPassword){
                        boolean success = Site.forgotPassword(userList[0].username);
                        pr.setRedirect(true);
                        if (success) {           
                            pr.getParameters().put('messagetype', 'PasswordSuccess');
                        }else{
                            //ApexPages.currentPage().getParameters().put('messagetype', 'PasswordError');
                            pr.getParameters().put('messagetype', 'PasswordError');                         
                        }                       
                    }else if(forgotUsername){
                        System.debug('userList[0]: ' + userList[0]);
                        PartnerPortalEmailManager.communicateUsername(userList[0]);
                        pr.getParameters().put('messagetype', 'EmailSuccess');
                    }else if(userList[0].Security_Question__c == null || userList[0].Security_Question__c == ''
                            || userList[0].Security_Answer__c == null || userList[0].Security_Answer__c == ''){
                        pr.getParameters().put('messagetype', 'SecurityQuestion');
                    }
                }else{
                    //ApexPages.currentPage().getParameters().put('messagetype', 'EmailError');
                    pr.getParameters().put('messagetype', 'EmailError');
                }
                pr.setRedirect(true);        
                return pr;
            }
        }
        else if(CheckPortalUser() && CheckIsAEEUser()){
             if(userSercurityQuestion == null || userSercurityQuestion == ''){                       
                System.debug('userList1: ' + userList);
                PageReference pr = Page.PartnerPortalConfirm;
                if(userList != null && userList.size() > 0 && userList[0] != null){
                    System.debug('userList: ' + userList);
                    if(forgotPassword){
                        boolean success = Site.forgotPassword(userList[0].username);
                        pr.setRedirect(true);
                        if (success) {           
                            pr.getParameters().put('messagetype', 'PasswordSuccess');
                        }else{
                            //ApexPages.currentPage().getParameters().put('messagetype', 'PasswordError');
                            pr.getParameters().put('messagetype', 'PasswordError');                         
                        }                       
                    }else if(forgotUsername){
                        System.debug('userList[0]: ' + userList[0]);
                        PartnerPortalEmailManager.communicateUsernameAEE(userList[0]);
                        pr.getParameters().put('messagetype', 'EmailSuccess');
                    }else if(userList[0].Security_Question__c == null || userList[0].Security_Question__c == ''
                            || userList[0].Security_Answer__c == null || userList[0].Security_Answer__c == ''){
                        pr.getParameters().put('messagetype', 'SecurityQuestion');
                    }
                }else{
                    //ApexPages.currentPage().getParameters().put('messagetype', 'EmailError');
                    pr.getParameters().put('messagetype', 'EmailError');
                }
                pr.setRedirect(true);        
                return pr;
            }
        }
        else if(!CheckPortalUser() && CheckIsAEEUser()){
             System.debug('Message-2');
             ApexPages.Message msg2 = new ApexPages.Message(ApexPages.Severity.ERROR, 'You are not a valid AEE user. Please Contact AEE partner manager.');               
             ApexPages.addMessage(msg2);
             return null;               
        }
        else {
             System.debug('Message-2');
             ApexPages.Message msg2 = new ApexPages.Message(ApexPages.Severity.ERROR, 'You are not a valid SunRun portal user. Please Contact SunRun partner manager.');               
             ApexPages.addMessage(msg2);
             return null;               
        }
        System.debug('Message-3');
        return null;
    }


    Public PageReference showForgotUserName(){
        username = null;
        userSercurityQuestion = null;
        userSercurityAnswer = null;     

        PageReference pr = Page.PartnerPortalForgotUsername;
        pr.setRedirect(true);
        return pr;
        
    }

    Public PageReference showForgotPassword(){
        username = null;
        userSercurityQuestion = null;
        userSercurityAnswer = null;     

        PageReference pr = Page.PartnerPortalForgotPassword;
        pr.setRedirect(true);
        return pr;
        
    }

    public PageReference emailUserName() {

        if(securityAnswerInput == null || securityAnswerInput == ''){
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Enter the security answer');             
            ApexPages.addMessage(msg);
            return null;
        }       
        try{
            
            if(userSercurityAnswer == securityAnswerInput){
                PageReference pr = Page.PartnerPortalConfirm;
                if(userList[0] != null && !CheckIsAEEUser()){
                    PartnerPortalEmailManager.communicateUsername(userList[0]);
                    pr.getParameters().put('messagetype', 'EmailSuccess');

                }
                else if(userList[0] != null && CheckIsAEEUser()){
                    PartnerPortalEmailManager.communicateUsernameAEE(userList[0]);
                    pr.getParameters().put('messagetype', 'EmailSuccess');
                }
                else{
                    ApexPages.currentPage().getParameters().put('messagetype', 'EmailError');
                    pr.getParameters().put('messagetype', 'EmailError');
                }
                pr.setRedirect(true);        
                return pr;
            }else{
                 ApexPages.Message msg2 = new ApexPages.Message(ApexPages.Severity.ERROR, 'Security Answer doesn\'t match our records. Please retry');               
                 ApexPages.addMessage(msg2);
                 return null;               
            }
            
            
        }catch(Exception e){
            ApexPages.Message msg2 = new ApexPages.Message(ApexPages.Severity.ERROR, 'Unable to email Username.  Please Contact SunRun partner manager.');            
            ApexPages.addMessage(msg2);
            return null;        
        }
        return null;        
        
    }

    public PageReference resetPassword() {

        if(securityAnswerInput == null || securityAnswerInput == ''){
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Enter the security answer');             
            ApexPages.addMessage(msg);
            return null;
        }       
        try{
            
            if(userSercurityAnswer == securityAnswerInput){
                boolean success = Site.forgotPassword(username);
                PageReference pr = Page.PartnerPortalConfirm;
                pr.setRedirect(true);
                if (success) {           
                    pr.getParameters().put('messagetype', 'PasswordSuccess');
                    return pr;
                }
            }else{
                 ApexPages.Message msg2 = new ApexPages.Message(ApexPages.Severity.ERROR, 'Security Answer doesn\'t match our records. Please retry');               
                 ApexPages.addMessage(msg2);
                 return null;               
            }
            
            
        }catch(Exception e){
            ApexPages.Message msg2 = new ApexPages.Message(ApexPages.Severity.ERROR, 'Problem resetting SunRun partner portal password.  Please Contact SunRun partner manager.');            
            ApexPages.addMessage(msg2);
            return null;        
        }
        return null;

    }

    public void initializeMessages(){
        String messageType = System.currentPagereference().getParameters().get('messagetype');
        System.debug('messageType: ' + messageType);
        if(messageType == null || messageType == '')
            return;
        
        confirmMessage = '';
        
        if(messageType == 'EmailError'){
            confirmMessage = 'We are unable to process your request. Please contact your Salesforce Administrator.';
        }else if(messageType == 'PasswordError'){
            confirmMessage = 'We are unable to reset your Password. Please contact your Salesforce Administrator.';
        }else if(messageType == 'EmailSuccess'){
            confirmMessage = 'An email with has been sent to the user. Please check your email account.';
        }else if(messageType == 'PasswordSuccess'){
            confirmMessage = 'An email has been sent to the user with further instructions on how to reset your password. Please check your email account.';
        }if(messageType == 'SecurityQuestion'){
            confirmMessage = 'We are unable to process your request. Please contact your Salesforce Administrator.';
        }
        
    }

    public void initializeArticles(){
        List<Public__kav> solutionArticles = [Select Title, Id, Article_Body__c From Public__kav  
                                            //where Id = 'ka7g00000008OIUAA2'];
                                            WHERE PublishStatus='Online' 
                                            AND Language = 'en_US' and title in (:Label.Login_Content_Title1, :Label.Login_Content_Title2, :Label.Login_Content_Title3, :Label.Login_Content_Title4, :Label.Login_Content_Title5)];
        System.debug('solutionArticles: ' + solutionArticles);
        
        if(solutionArticles != null && solutionArticles.size() > 0){
            for(Public__kav articleObj : solutionArticles){
                if(articleObj.Title == Label.Login_Content_Title1){
                    loginContent1 = articleObj.Article_Body__c;
                    loginContentTitle1 = articleObj.Title;                      
                }else if(articleObj.Title == Label.Login_Content_Title2){
                    loginContent2 = articleObj.Article_Body__c;
                    loginContentTitle2 = articleObj.Title;                      
                }else if(articleObj.Title == Label.Login_Content_Title3){
                    loginContent3 = articleObj.Article_Body__c;
                    loginContentTitle3 = articleObj.Title;                      
                }else if(articleObj.Title == Label.Login_Content_Title4){
                    loginContent4 = articleObj.Article_Body__c;
                    loginContentTitle4 = articleObj.Title;                      
                }else if(articleObj.Title == Label.Login_Content_Title5){
                    loginContent5 = articleObj.Article_Body__c;
                    loginContentTitle5 = articleObj.Title;                      
                }           
            }
        }

    }
    
    public static void test(){

        List<Public__kav> solutionArticles = [Select Title, Id, Article_Body__c From Public__kav  
                                            //where Id = 'ka7g00000008OIUAA2'];
                                            WHERE PublishStatus='Online' 
                                            AND Language = 'en_US' and title in ('Solution1')];
        System.debug('solutionArticles: ' + solutionArticles);

        
        /*
        List<Public__kav> solutionArticles = [Select Title, Id, Article_Body__c From Public__kav  
                                            //where Id = 'ka7g00000008OIUAA2'];
                                            WHERE PublishStatus='Online' 
                                            AND Language = 'en_US' and title in ('Solution1')];
        System.debug('solutionArticles: ' + solutionArticles);
        */      
    }
}