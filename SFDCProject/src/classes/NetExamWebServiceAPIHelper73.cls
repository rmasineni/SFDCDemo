global class NetExamWebServiceAPIHelper73
{

    public class MissingAccountInformationException extends Exception{}
    public class NetExamWebserviceException extends Exception{}
    public static string contactSalesforceErrorMsg = 'Salesforce is unable to send the Contact details to NetExam. ';

    
    //NetExam SANDBOX API Credentials    
    //private static string ne_apiKey = '32FbYhXCRKhSZktC5jRWy7Tl6ufktzFz';
    //private static string ne_apiUser = 'intDevapiUser';
    //private static string ne_apiPass = '817#xX6$'; 
     

    //NetExam PRODUCTION API Credentials    
    private static string ne_apiKey = '869dlsui-1042-9z87-di8s-dkls89dcK88ld97';
    private static string ne_apiUser = 'apiuserSRProd';
    private static string ne_apiPass = '2kB4eE8jiTK23API'; 
    
    /*
    @Future(callout=true)
    public static void SendContactFromTrigger(Set<Id> contactIds, Set<Id> activateContactIds, Set<Id> deactivateContactIds){
        System.debug('contactIds: ' + contactIds);
        System.debug('activateContactIds: ' + activateContactIds);
        System.debug('deactivateContactIds: ' + deactivateContactIds);
        
        NetExamWebServiceAPIHelper73.processContactForLMS(contactIds, activateContactIds, deactivateContactIds);
    }

    public static String processContactForLMS(Set<Id> contactIds, Set<Id> activateContactIds, Set<Id> deactivateContactIds)
    {       
        Set<Id> successContactIds = new Set<Id>();
        String country = 'USA';
        String language = 'English';
        String userRole = 'Student';
        String managerSFDCContactID = ''; 
        Map<Id, Contact> exceptionContacts = new Map<Id, Contact>();
        String tempErrorMessage = '';
        List<Contact> contactList = [Select Id, name, firstname, lastname, email, account.name, Ultimate_Parent_Account__c,
                                        Sells_Sunrun__c, Contact_Number__c, job_function__c, Active_NetExam_User__c,
                                        active__c from Contact where Id in :contactIds];
        Set<String> exceptionsMessages = new Set<String>();
        List<Contact> updatedContactList = new List<Contact>();
        for(Contact contactObj: contactList){
            try{
                if(contactObj.firstName == null || contactObj.firstName == '' || 
                    contactObj.lastName == null || contactObj.lastName == '' ||
                    contactObj.job_function__c == null || contactObj.job_function__c == '' ||
                    contactObj.email == null || contactObj.email == ''){
                    exceptionContacts.put(contactObj.Id, contactObj);
                    exceptionsMessages.add('Contact field values are null or empty. Please verify First Name, Last Name, Email and Job Function values for this Contact');
                    continue;               
                }

                String returnValue = '';
                Boolean netExamStatus = false;
                
                if((contactObj.Sells_Sunrun__c == 'Yes' && contactObj.active__C == true) 
                    || (contactObj.Active_NetExam_User__c == true && contactObj.active__C == true)){
                    netExamStatus = true;
                }

                for(Integer i=0; i < 3; i++){
                    returnValue = SendContactToNetExam(
                                                contactObj.Id, 
                                                contactObj.firstName, 
                                                contactObj.lastName, 
                                                contactObj.email, 
                                                language, 
                                                contactObj.job_function__c, 
                                                userRole, 
                                                netExamStatus,
                                                managerSFDCContactID, 
                                                contactObj.Account.Name, 
                                                contactObj.Ultimate_Parent_Account__c, 
                                                country,
                                                contactObj.Contact_Number__c);  
                    if( returnValue == 'Success') {
                        successContactIds.add(contactObj.Id);
                        if(netExamStatus != contactObj.Active_NetExam_User__c){
                            contactObj.Active_NetExam_User__c =  netExamStatus;
                            updatedContactList.add(contactObj);
                        }
                        
                        break;
                    }
                }
                if( returnValue != 'Success')            
                {
                    exceptionContacts.put(contactObj.Id, contactObj);
                    exceptionsMessages.add(returnValue);
                    tempErrorMessage +=  returnValue + ' ';
                }
                /*
                else{
                    returnValue = '';
                    if(activateContactIds.contains(contactObj.Id)){
                        //returnValue = activateContacts(contactObj.Id);
                        returnValue = 'Success';
                    } 
                    if( returnValue != '' && returnValue != 'Success')            
                    {
                        exceptionContacts.put(contactObj.Id, contactObj);
                        exceptionsMessages.add(returnValue);
                    }
                }
                *
                
                if(updatedContactList.size() > 0 ){
                    update updatedContactList;
                }
            
            }catch(Exception expObj){
                exceptionContacts.put(contactObj.Id, contactObj);
                exceptionsMessages.add(expObj.getMessage());
                if(updatedContactList.size() > 0 ){
                    update updatedContactList;
                }
            }
        }
            
        List<Contact> deactiveContactList = [Select Id, name, firstname, lastname, email, account.name, Ultimate_Parent_Account__c,
                                            Sells_Sunrun__c, Active_NetExam_User__c,
                                            Contact_Number__c, job_function__c, active__c from Contact where Id in :deactivateContactIds];

        for(Contact contactObj : deactiveContactList){
            try{
                if(contactObj.firstName == null || contactObj.firstName == '' || 
                    contactObj.lastName == null || contactObj.lastName == '' ||
                    contactObj.job_function__c == null || contactObj.job_function__c == '' ||
                    contactObj.email == null || contactObj.email == ''){
                    exceptionContacts.put(contactObj.Id, contactObj);
                    exceptionsMessages.add('Contact field values are null or empty. Please verify First Name, Last Name, Email and Job Function values for this Contact');
                    continue;               
                }

                //String returnValue =  deactivateContact(contactObj.Id);
                String returnValue = 'Success';
                if( returnValue != '' && returnValue != 'Success')            
                {
                    exceptionContacts.put(contactObj.Id, contactObj);
                    exceptionsMessages.add(returnValue);
                }
            }catch(Exception expObj){
                exceptionContacts.put(contactObj.Id, contactObj);
                exceptionsMessages.add(expObj.getMessage());
                tempErrorMessage +=  expObj.getMessage() + ' ';
            }
        }

        if(exceptionContacts.size() > 0){
            PRMEmailManager.communicateLMSInfoErrorDetails(exceptionContacts.values(), exceptionsMessages, Label.Partner_Concierge_Helpdesk_Email);
            return tempErrorMessage;
        }
        return 'Success';
    } */ 
     

    Webservice static string SendContactToNetExam(string sfdcContactID, string firstName, string lastName, string email, string language, string userType, string userRole, string managerSFDCContactID, string accountName, string accountID, string accountCountry)
    {
                   
        string errorMsg = '';  
        String jobFunction = '';
        String secondaryUserGroup = '';
        String contactNumber = '';   
        string ContactsTimeZone = '';
        
                
        if(accountID.length() == 0){
            return 'Error, no account information was associated with this contact: ' + errorMsg ;
        }
        

        //Check to make sure the required fields for the account object have the required information
        errorMsg = ValidateAccountData(accountName, accountID, accountCountry);        
        if(errorMsg != 'Success'){
            return 'Contact was not sent. ' + errorMsg;
        }
        
        //Check to make sure the required fields for the account object have the required information
        errorMsg = ValidateContactData(sfdcContactID, firstName, lastName, email, language, userType, userRole, managerSFDCContactID);
        if(errorMsg != 'Success'){
            return 'Contact was not sent. ' + errorMsg;
        }
        
        
        //NEED TO PULL VALUES FROM APPROPRIATE FIELDS IN SFDC        
        List<Contact> objContact = [Select Job_Function__c,Contact_Number__c FROM Contact WHERE Id = :sfdcContactID LIMIT 1];        
       
        //Get the Job Function
        try {
                
                jobFunction = objContact[0].Job_Function__c;
                if(String.isEmpty(jobFunction))
                    jobFunction = '';
    
             }
             catch(Exception e){
                 jobFunction = '';
             }
             
        //Get the Contact Number
        try {
                
                contactNumber = objContact[0].Contact_Number__c;
                if(String.isEmpty(contactNumber))
                    contactNumber = '';
    
             }
             catch(Exception e){
                 contactNumber = '';
             }
       
       
       // Create the array of user groups to send to NetExam. Only the PrimaryGroup is required.
        webservicesNetexamComUserservice73.ArrayOfUserUserGroup Groups = new webservicesNetexamComUserservice73.ArrayOfUserUserGroup();
        Groups.UserUserGroup =  new webservicesNetexamComUserservice73.UserUserGroup[]{};
    
        
        // Add account as primary user group
        webservicesNetexamComUserservice73.UserUserGroup PrimaryGroup = new webservicesNetexamComUserservice73.UserUserGroup();
        PrimaryGroup.Name = accountName;
        PrimaryGroup.ExternalID = accountID;
        PrimaryGroup.IsPrimaryUserGroup = 1;
        PrimaryGroup.Country = accountCountry;
        PrimaryGroup.AccountManagerExternalID = '';   
        
        Groups.UserUserGroup.add(PrimaryGroup); 

        //Depending on the jobFunction, Contact will need to be put into a Secondary User Group
        //By Default, set secondaryUserGroup variable to Unassigned. 
        secondaryUserGroup = 'Unassigned';
    
        
        //Inside Sales Rep
        if((jobFunction == 'Inside Sales Rep')){       
            secondaryUserGroup = 'Inside Sales Rep';
        }
    
        //Lead Generator
        if((jobFunction == 'Lead Generator (FM)') 
           ||(jobFunction == 'Lead Generator (Canvassing)')
           ||(jobFunction == 'Retail Solar Advisor')
           ||(jobFunction == 'Lead Generator (Qualifier)')){      
            secondaryUserGroup = 'Lead Generator';
        }
    
    
        //Operations Admin
        if((jobFunction == 'Manager-Operations') 
           ||(jobFunction == 'Operations Admin')){      
            secondaryUserGroup = 'Operations Admin';
        }
    
        //Outside Sales Rep
        if((jobFunction == 'Outside Sales Representative') 
           ||(jobFunction == 'Retail Sales Rep')           
           ||(jobFunction == 'Manager-Sales')
           ||(jobFunction == 'Executive')
           ||(jobFunction == 'Executive (C-Level)')){     
            secondaryUserGroup = 'Outside Sales Rep';
        }
    
        //Trainer
        if((jobFunction == 'Sunrun-Trainer') 
           ||(jobFunction == 'Trainer')){       
            secondaryUserGroup = 'Trainer';
        } 
        
         //Other
        if(jobFunction == 'Other'){       
            secondaryUserGroup = 'Other';
        }
       
        
        
    
        // Add Secondary User Group
        webservicesNetexamComUserservice73.UserUserGroup SecondaryGroup = new webservicesNetexamComUserservice73.UserUserGroup();
        SecondaryGroup.Name = secondaryUserGroup;
        SecondaryGroup.ExternalID = secondaryUserGroup;
        SecondaryGroup.IsPrimaryUserGroup = 0;
        SecondaryGroup.Country = '';
        SecondaryGroup.AccountManagerExternalID = '';   
        
        Groups.UserUserGroup.add(SecondaryGroup);
              
       
        //Account Name will also be used to determine User Type in the following business rule
        //If AccountName contains "Sunrun" e.g "Sunrun Direct" or "REC" e.g "REC Solar" then user type needs to be set to Employee otherwise Partner
        if((accountName.contains('Sunrun')) ||(accountName.contains('REC'))){
            userType = 'Employee';
        }
        else{
            userType = 'Partner';
        }
            
        
             
        
        // Ensure that we have a valid country by setting a default
        integer accountCountryLength;
        accountCountryLength = accountCountry.length();
        if(accountCountryLength == 0){
            accountCountry = 'USA';
        }

        // Ensure that we have a valid language by setting a default
        integer languageLength;
        languageLength = language.length(); 
        if(languageLength == 0){
            language = 'English';
        } 
        
        Boolean emailOptIn = true;
        String sfdcUserId = '';
        
        //Try and pull the User Id from the User record if it exists
        List<User> objUser = [Select Id FROM User WHERE ContactId = :sfdcContactID LIMIT 1];        
        try {
                sfdcUserId = objUser[0].Id;
        }
        catch(Exception e){
            //Do Nothing with this exception
            System.debug('Error Finding User: ' + e);             
        }      

        webservicesNetexamComUserservice73.ArrayOfCustomField CustomFields = new webservicesNetexamComUserservice73.ArrayOfCustomField();
        CustomFields.CustomField=  new webservicesNetexamComUserservice73.CustomField[]{};
        
        webservicesNetexamComUserservice73.CustomField SunRunID = new webservicesNetexamComUserservice73.CustomField();
        SunRunID.Name = 'SunrunID';
        SunRunID.Value = contactNumber;
        
        CustomFields.CustomField.Add(SunRunID); 
        
          
                
        // Send the Contact to NetExam
        errorMsg = UpsertUserWithUserGroups(ne_apiKey, ne_apiUser, ne_apiPass, sfdcContactID, firstName, lastName, email, language, userType, userRole, managerSFDCContactID, accountID, accountName, Groups, CustomFields,accountCountry,emailOptIn,sfdcUserId,ContactsTimeZone);
        if(errorMsg != 'Success'){
            return 'Contact was not sent. ' + errorMsg;
        }
        
        return 'Success';    
    
    }

    Webservice static string SendContactToNetExamExtended(string sfdcContactID, string firstName, string lastName, string email, string language, string userType, string userRole, string managerSFDCContactID, string accountName, string accountID, string accountCountry)
    {
                   
        string errorMsg = ''; 
        string ContactsTimeZone = '';
        string UsersCountry = 'USA';
        string UsersStatus = '';
        string jobTitle = '';
        string userName = '';  
        string businessPhone = '';  
        string UsersUserType = userType; 
        Boolean userActive = true;
        string AccountType = '';
       
        
        //Default these variables to Empty as they are not used in this integration
        string personalEmail = '';
        string address1 = '';
        string address2 = '';
        string city = '';
        string postalCode = '';
        string state = '';
        string jobCategory = '';
        DateTime UsersStartDate = NULL;
        string UsersUserRole = '';
        string SalesforceUserID = '';
        String sfdcUserId = '';
        String jobFunction = '';
        string formattedStartDate = '';        
        String secondaryUserGroup = '';
        String hireDate = '';
        String contactNumber = '';
        String recordType = '';
         
        userRole = 'Student';              
        userActive = True;         
       
        
        
        if(accountID.length() == 0){
            return 'Error, no account information was associated with this contact: ' + errorMsg ;
        }
        
        
        //Check to make sure the required fields for the account object have the required information
        errorMsg = ValidateAccountData(accountName, accountID, accountCountry);        
        if(errorMsg != 'Success'){
            return 'Missing Account Information. Contact was not sent. ' + errorMsg;
        }
        
        //Check to make sure the required fields for the account object have the required information
        errorMsg = ValidateContactData(sfdcContactID, firstName, lastName, email, language, userType, userRole, managerSFDCContactID);
        if(errorMsg != 'Success'){
            return 'Missing Contact Data. Contact was not sent. ' + errorMsg;
        }
        
        if(userName.length() == 0)
            userName = email;        

                    
        //NEED TO PULL VALUES FROM APPROPRIATE FIELDS IN SFDC        
        List<Contact> objContact = [Select Job_Function__c,Contact_Number__c,Active_NetExam_User__c,active__c, RecordType.Name FROM Contact WHERE Id = :sfdcContactID LIMIT 1];        
       
        //Get the Job Function
        try {
                
                jobFunction = objContact[0].Job_Function__c;
                if(String.isEmpty(jobFunction))
                    jobFunction = '';
    
             }
             catch(Exception e){
                 jobFunction = '';
             }
             
        //Get the Contact Number
        try {
                
                contactNumber = objContact[0].Contact_Number__c;
                if(String.isEmpty(contactNumber))
                    contactNumber = '';
    
             }
             catch(Exception e){
                 contactNumber = '';
             }
             
         //Get Active Employee
        try {                
                userActive = objContact[0].active__c;                    
             }
             catch(Exception e){
                 userActive = false;
             }
             
             
         //Get the Record Type
        try { recordType = ((String.isEmpty(objContact[0].RecordType.Name)) ? '' : objContact[0].RecordType.Name);} catch(Exception e){ recordType = '';}
        
              
        if( recordType == 'Residential')
           return 'Contact not sent. Account Record Type of Residential not valid for transmission';
  
         // Create the array of user groups to send to NetExam. Only the PrimaryGroup is required.
        webservicesNetexamComUserservice73.ArrayOfUserUserGroup Groups = new webservicesNetexamComUserservice73.ArrayOfUserUserGroup();
        Groups.UserUserGroup =  new webservicesNetexamComUserservice73.UserUserGroup[]{};
    
        
        // Add account as primary user group
        webservicesNetexamComUserservice73.UserUserGroup PrimaryGroup = new webservicesNetexamComUserservice73.UserUserGroup();
        PrimaryGroup.Name = accountName;
        PrimaryGroup.ExternalID = accountID;
        PrimaryGroup.IsPrimaryUserGroup = 1;
        PrimaryGroup.Country = accountCountry;
        PrimaryGroup.AccountManagerExternalID = '';   
        
        Groups.UserUserGroup.add(PrimaryGroup); 

        //Depending on the jobFunction, Contact will need to be put into a Secondary User Group
        //By Default, set secondaryUserGroup variable to Unassigned. 
        secondaryUserGroup = 'Unassigned';
    
    
        //Inside Sales Rep
        if((jobFunction == 'Inside Sales Rep')){       
            secondaryUserGroup = 'Inside Sales Rep';
        }
    
        //Lead Generator
        if((jobFunction == 'Lead Generator (FM)') 
           ||(jobFunction == 'Lead Generator (Canvassing)')
           ||(jobFunction == 'Retail Solar Advisor')
           ||(jobFunction == 'Lead Generator (Qualifier)')){      
            secondaryUserGroup = 'Lead Generator';
        }
    
    
        //Operations Admin
        if((jobFunction == 'Manager-Operations') 
           ||(jobFunction == 'Operations Admin')){      
            secondaryUserGroup = 'Operations Admin';
        }
    
        //Outside Sales Rep
        if((jobFunction == 'Outside Sales Representative') 
           ||(jobFunction == 'Retail Sales Rep')           
           ||(jobFunction == 'Manager-Sales')
           ||(jobFunction == 'Executive')
           ||(jobFunction == 'Executive (C-Level)')){     
            secondaryUserGroup = 'Outside Sales Rep';
        }
    
        //Trainer
        if((jobFunction == 'Sunrun-Trainer') 
           ||(jobFunction == 'Trainer')){       
            secondaryUserGroup = 'Trainer';
        }  
        
        //Other
        if(jobFunction == 'Other'){       
            secondaryUserGroup = 'Other';
        }
    
    
        /*
        //RETIRED JOB FUNCTION MAPPINGS 06/05/2015
        //Customer Care Rep
        if(jobFunction == 'Sunrun-Customer Care Rep'){      
            secondaryUserGroup = 'Customer Care Rep';
        }
    
        //Inside Sales Rep
        if((jobFunction == 'Inside Sales Representative (telesales)')
           ||(jobFunction == 'Inside Sales')
           ||(jobFunction == 'Sunrun-Inside Sales Rep (telesales)')){       
            secondaryUserGroup = 'Inside Sales Rep';
        }
    
        //Installer
        if((jobFunction == 'Sunrun-Installer') 
           ||(jobFunction == 'Sunrun-Manager-Construction')
           ||(jobFunction == 'Sunrun-Site Auditor')
           ||(jobFunction == 'Installer')
           ||(jobFunction == 'Manager - Construction')
           ||(jobFunction == 'Site Auditor')){      
            secondaryUserGroup = 'Installer';
        }
    
    
        //Lead Generator
        if((jobFunction == 'Sunrun-Canvasser') 
           ||(jobFunction == 'Sunrun-Solar Scout')
           ||(jobFunction == 'Sunrun-Field Marketing Associate')
           ||(jobFunction == 'Canvasser')
           ||(jobFunction == 'Inside Sales Representative (prequalify)')
           ||(jobFunction == 'Sunrun-Advisor') 
           ||(jobFunction == 'Retail Rep')
           ||(jobFunction == 'Retail Representative')
           ||(jobFunction == 'Inside Sales Support')   
           ||(jobFunction == 'Sunrun-Lead Generator/Qualifier')  
           ||(jobFunction == 'Lead Generator/Qualifier')      
           ||(jobFunction == 'Sunrun-Inside Sales Rep (prequalify)')){      
            secondaryUserGroup = 'Lead Generator';
        }
    
    
        //Operations Admin
        if((jobFunction == 'Sunrun-Manager-Operations') 
           ||(jobFunction == 'Sunrun-Operations Associate')
           ||(jobFunction == 'Manager - Operations')
           ||(jobFunction == 'Operations')           
           ||(jobFunction == 'Operations Admin')){      
            secondaryUserGroup = 'Operations Admin';
        }
    
        //Outside Sales Rep
        if((jobFunction == 'Sunrun-Account Manager')         
           ||(jobFunction == 'Sunrun-Outside Sales Rep')
           ||(jobFunction == 'Outside Sales Rep') 
           ||(jobFunction == 'Sales')       
           ||(jobFunction == 'Outside Sales Representative')){     
            secondaryUserGroup = 'Outside Sales Rep';
        }
        
         //Designer
        if(jobFunction == 'Proposal Generator') {       
            secondaryUserGroup = 'Designer';
        }
    
        //Trainer
        if((jobFunction == 'Sunrun-Trainer') 
           ||(jobFunction == 'Trainer')){       
            secondaryUserGroup = 'Trainer';
        }
        
        //Sales Manager
        if((jobFunction == 'Manager - Sales') 
            ||(jobFunction == 'Sunrun-Manager-Sales')){       
            secondaryUserGroup = 'Sales Manager';
        }  
         
        
        //Other
        if(jobFunction == 'Other'){       
            secondaryUserGroup = 'Other';
        }
        */
        
        //return secondaryUserGroup;
         
        // Add Secondary User Group
        webservicesNetexamComUserservice73.UserUserGroup SecondaryGroup = new webservicesNetexamComUserservice73.UserUserGroup();
        SecondaryGroup.Name = secondaryUserGroup;
        SecondaryGroup.ExternalID = secondaryUserGroup;
        SecondaryGroup.IsPrimaryUserGroup = 0;
        SecondaryGroup.Country = '';
        SecondaryGroup.AccountManagerExternalID = '';   
        
        Groups.UserUserGroup.add(SecondaryGroup);
    
        //If Contact is placed in the Unassigned User Group, make sure they are also inactive in NetExam
        if(secondaryUserGroup == 'Unassigned'){
            userActive = false;
        }
    
       
        //Account Name will also be used to determine User Type in the following business rule
        //If AccountName contains "Sunrun" e.g "Sunrun Direct" or "REC" e.g "REC Solar" then user type needs to be set to Employee otherwise Partner
        if((accountName.contains('Sunrun')) ||(accountName.contains('REC'))){
            userType = 'Employee';
        }
        else{
            userType = 'Partner';
        }        
               
             
        
        // Ensure that we have a valid country by setting a default
        integer accountCountryLength;
        accountCountryLength = accountCountry.length();
        if(accountCountryLength == 0){
            accountCountry = 'USA';
        }
        
        integer usersCountryLength;
        usersCountryLength = UsersCountry.length();
        if(usersCountryLength == 0){
            UsersCountry = 'USA';
        }        

        // Ensure that we have a valid language by setting a default
        integer languageLength;
        languageLength = language.length(); 
        if(languageLength == 0){
            language = 'English';
        } 
        
        Boolean emailOptIn = true;
        Boolean preserveUserGroup = true;
        
        
        //Try and pull the User Id from the User record if it exists
        List<User> objUser = [Select Id FROM User WHERE ContactId = :sfdcContactID LIMIT 1];        
        try {
                sfdcUserId = objUser[0].Id;
        }
        catch(Exception e){
            //Do Nothing with this exception
        //    System.debug('Error Finding User: ' + e);             
        }      

        webservicesNetexamComUserservice73.ArrayOfCustomField CustomFields = new webservicesNetexamComUserservice73.ArrayOfCustomField();
        CustomFields.CustomField=  new webservicesNetexamComUserservice73.CustomField[]{}; 
        
        webservicesNetexamComUserservice73.CustomField SunRunID = new webservicesNetexamComUserservice73.CustomField();
        SunRunID.Name = 'SunrunID';
        SunRunID.Value = contactNumber;
        
        CustomFields.CustomField.Add(SunRunID);         
               
                
        // Send the Contact to NetExam                                                                                                                                                                                                                                                                                                                                                          
        errorMsg = UpsertUserWithUserGroupsExtended(ne_apiKey, ne_apiUser, ne_apiPass,firstName, lastName, userName,userRole, email, businessPhone, personalEmail, address1, address2, city, state, ContactsTimeZone, postalCode, UsersCountry, language,Groups, jobCategory, jobTitle, userType, sfdcContactID, sfdcUserId,userActive, managerSFDCContactID, preserveUserGroup, CustomFields, emailOptIn,hireDate);
       
        if(errorMsg != 'Success'){
            return 'Error Sending Data to NE web service. Contact was not sent. ' + errorMsg;
        }
        
        return 'Success';     
         
        
    
    }

    @Future(callout=true)
    public static void SendContactFromTrigger(string sfdcContactID, string firstName, string lastName, string email,string accountID)
    {       
        String accountName = '';
        String country = 'USA';
        String language = 'English';
        String userType = 'Employee';
        String userRole = 'Student';
        String managerSFDCContactID = ''; 

                
        //Depending on your account setup, you may need to alter where the country is pulled from. If no country is available for the account, you can pull it from another relationship or default it.
        //Common country fields: Account.BillingCountry, Account.ShippingCountry. If you change the email here, also change the variable name below at the country assignment
        List<Account> objAccount = [Select BillingCountry, Name FROM Account WHERE Id = :accountID LIMIT 1];        
        if(accountID != 'test')
        {
            try {
                accountName = objAccount[0].Name;
            }
            catch(Exception e){
                //We should just log the exception.  
                //throw new MissingAccountInformationException('Account Could Not Be Found'); 
            }
        }
            
        //if we survived, we must be able to get account information, lets try the optional country field.
        try{
          country = objAccount[0].BillingCountry; //If you changed the query above, be sure to change the name of the variable here
        }
        catch(Exception e){
          // No real problem here, we must not have permissions to the billing fields, default to USA
        }      
          
        if(country == null) {country = 'USA';}         
    
        
        String returnValue = SendContactToNetExamExtended(
            sfdcContactID, 
            firstName, 
            lastName, 
            email, 
            language, 
            userType, 
            userRole, 
            managerSFDCContactID, 
            accountName, 
            accountID, 
            country
        );
            
        //if( returnValue != 'Success' && accountID != 'test')            
        //{
        //    throw new MissingAccountInformationException(returnValue); 
        //}
        
        return;
    }    
    
    //This method will create a user in NetExam OR if the user already exists(checked by sfdcContactID) the user's information will be updated.
    public static string UpsertUserWithUserGroups(string apiKey, string apiUser, string apiPass, string sfdcContactID, string firstName, string lastName, string email, string language, string userType, string userRole, string managerSFDCContactID, string accountID, string accountName,  webservicesNetexamComUserservice73.ArrayOfUserUserGroup Groups, webservicesNetexamComUserservice73.ArrayOfCustomField CustomFields,string country,Boolean EmailOptIn,string SFDCUserID,string ContactsTimeZone)
    {
        string ne_result = '';
       //INVOKE WEBSERVICE CALL TO ADD/UPDATE USER 
       try{
           webservicesNetexamComUserservice73.UserServiceSoap ne_Webservice = new webservicesNetexamComUserservice73.UserServiceSoap();
           webservicesNetexamComUserservice73.ApiResult Result = ne_Webservice.UpsertUserWithUserGroups(apiKey,apiUser,apiPass,sfdcContactID,firstName,lastName, email, language, userType, userRole, managerSFDCContactID, Groups, true, CustomFields, true,country,EmailOptIn,SFDCUserID,ContactsTimeZone);
           System.debug('Result: ' + Result.Code + ':' + Result.Description);
           ne_result = 'Success';
        }
        catch(System.CalloutException e){
            System.debug('Error: ' + e);            
            ne_result = e.getMessage().replace('Web service callout failed: WebService returned a SOAP Fault: ','').replace('faultcode=soap:Client faultactor=','');          
        }
        return ne_result;  
        
    }


    //This method will create a user in NetExam OR if the user already exists(checked by sfdcContactID) the user's information will be updated.
    public static string UpsertUserWithUserGroupsExtended(string apiKey, string apiUser, string apiPass, string firstName,string lastName, string userName, string userRole, string email, string businessPhone, string personalEmail, string address1, string address2, string city, string state, string ContactsTimeZone, string postalCode, string accountCountry, string language, webservicesNetexamComUserservice73.ArrayOfUserUserGroup Groups,string jobCategory, string jobTitle, string userType, string sfdcContactID, string sfdcUserId, Boolean status, string managerSFDCContactID, Boolean preserveUserGroup, webservicesNetexamComUserservice73.ArrayOfCustomField CustomFields, Boolean emailOptIn,string startDate)
    {
        string ne_result = '';
       //INVOKE WEBSERVICE CALL TO ADD/UPDATE USER        
       
       try{
           webservicesNetexamComUserservice73.UserServiceSoap ne_Webservice = new webservicesNetexamComUserservice73.UserServiceSoap();
           webservicesNetexamComUserservice73.ApiResult Result = ne_Webservice.UpsertUserWithUserGroupsExtended(apiKey, apiUser, apiPass, firstName,lastName, userName, userRole, email, businessPhone, personalEmail, address1, address2, city, state, ContactsTimeZone, postalCode, accountCountry, language, Groups, jobCategory, jobTitle, userType, sfdcContactID, sfdcUserId, status, managerSFDCContactID, preserveUserGroup, CustomFields, emailOptIn,startDate);
           System.debug('Result: ' + Result.Code + ':' + Result.Description);
           ne_result = 'Success';
        }
        catch(System.CalloutException e){
            System.debug('Error: ' + e);            
            ne_result = e.getMessage().replace('Web service callout failed: WebService returned a SOAP Fault: ','').replace('faultcode=soap:Client faultactor=','');          
        }
        
        return ne_result;  
        
    }


    
    //This method will create a user group in Netexam OR if the group already exists(checked by AccountID) the group information will be updated.
    public static string AddEditUserGroup(string apiKey, string apiUser, string apiPass, string AccountName, string AccountID, string AccountCountry)
    {
        string ne_result = '';      
        try{
            webservicesNetexamComUserservice73.UserServiceSoap ne_Webservice = new webservicesNetexamComUserservice73.UserServiceSoap();
            string Result = ne_Webservice.AddEditUserGroup(apiKey , apiUser , apiPass , AccountName, AccountID, AccountCountry); 
            System.debug('Result: ' + Result);
            ne_result = 'Success';
        }
        catch(System.CalloutException e){
            System.debug('Error: ' + e);
            ne_result = e.getMessage();          
        }
        return ne_result;
    
    }

     //This method will Bulk upsert users in NetExam OR if the user already exists(checked by sfdcContactID) the user's information will be updated.
    //@Future(callout=true)
    public static void BulkUpsertUsers(string apiKey, string apiUser, string apiPass, webservicesNetexamComUserservice73.ArrayOfUser Users)
    {
        string ne_TransactionID = '0';

       //INVOKE WEBSERVICE CALL TO BulkUpsert Users 
       try{
           webservicesNetexamComUserservice73.UserServiceSoap ne_Webservice = new webservicesNetexamComUserservice73.UserServiceSoap();
           //webservicesNetexamComUserservice73.ApiResult Result = ne_Webservice.BulkUpsertUsers(apiKey,apiUser,apiPass,Users);
          
           //Get the Transaction ID. You can use the Transaction ID In the GetBulkUpsertTransactionLog method to get the results of your BulkUpsertUsers call 
           //ne_TransactionID = string.valueof(Result.Code);
        }
        catch(Exception e){
            System.debug('Error: ' + e);            
        }
        return; //ne_TransactionID;        
    }
    
    //This method simply checks to make sure that there is enough information to create the user group. 
    // If these values are missing, the webservice would return an error.
    // NOTE: Not all params are required, so not all params are checked.
    public static string ValidateAccountData(string accountName, string accountID, string accountCountry)
    {
        string errorMsg = '';
        integer accountIDLength;
        integer accountNameLength;

        try{
            accountIDLength = accountID.length();
            //Validate required fields
            if(accountIDLength == 0){
                errorMsg = errorMsg + '<br>Account ID';
            }
        
            accountNameLength = accountName.length();         
            if(accountNameLength == 0){
                errorMsg  = errorMsg + '<br>Account Name';
            }
        
            if(errorMsg.length() > 0){
                errorMsg = 'Missing required information: ' + errorMsg;
            }
            else{
                errorMsg = 'Success';
            }
        }
        catch(Exception e){
            errorMsg = 'Missing required information: ';
        }

        return errorMsg;
    }
    
    //This method simply checks to make sure that there is enough information to create the user group. 
    // If these values are missing, the webservice would return an error.
    // NOTE: Not all params are required, so not all params are checked.
    public static string ValidateContactData(string sfdcContactID, string firstName, string lastName, string email, string language, string userType, string userRole, string managerSFDCContactID)
    {
        string errorMsg = '';
        integer firstNameLength;
        integer lastNameLength;
        integer emailLength;
        integer userTypeLength;
        integer userRoleLength;
        
       try{
            firstNameLength = firstName.length();
            if(firstNameLength == 0){
                errorMsg  = errorMsg + '<br>First Name';
            }
            
            lastNameLength = lastName.length();
            if(lastNameLength == 0){
                errorMsg = errorMsg + '<br>Last Name';
            }
            
            emailLength = email.length();
            if(emailLength == 0){
                errorMsg = errorMsg + '<br>Email';
            }   
    
            userTypeLength = userType.length(); 
            if(userTypeLength == 0){
                errorMsg = errorMsg + '<br>User Type';
            }
     
            userRoleLength = userRole.length(); 
            if(userRoleLength == 0){
                errorMsg = errorMsg + '<br>User Role';
            }
            
            if(errorMsg.length() > 0){
                errorMsg = 'Missing required information: ' + errorMsg;
            }
            else{
                errorMsg = 'Success';
            }
         }
         catch(Exception e){
            errorMsg = 'Missing required information: ';
        }

        return errorMsg;
    
    }

}