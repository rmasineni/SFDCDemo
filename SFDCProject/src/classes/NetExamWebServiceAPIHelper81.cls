global class NetExamWebServiceAPIHelper81
{

    public class MissingAccountInformationException extends Exception{}
    public class NetExamWebserviceException extends Exception{}
    public with sharing class TestException extends Exception {}
    
    
    //NetExam API Credentials    
    private static string ne_apiKey = System.Label.NetExam_API_Key;
    private static string ne_apiUser = System.Label.NetExam_API_User; 
    private static string ne_apiPass = System.Label.NetExam_API_Pass; 
    
    public static string contactSalesforceErrorMsg = 'Salesforce is unable to send the Contact details to NetExam. ';
    private static List<String> exceptionsContacts = new List<String>();
   
    @Future(callout=true)
    public static void SendContactListToNetExam(Set<Id> contactIDList)
    {
        try
        {
            
            webservicesNetexamComUserservice81.ArrayOfUserExtended Users = GetNetExamUsers(contactIDList);            
            
            if(Users != null)
            {
                BulkUpsertUsersWithUserGroups(Users);
            }            
            
        }
        catch(Exception e)
        {
            System.debug('SendContactListToNetExam Exception: ' + e);
        }
    }    
   
   
    private static webservicesNetexamComUserservice81.ArrayOfUserExtended GetNetExamUsers(Set<Id> contactIDList)
    {
      
         webservicesNetexamComUserservice81.ArrayOfUserExtended Users = new webservicesNetexamComUserservice81.ArrayOfUserExtended();
         Users.UserExtended =  new webservicesNetexamComUserservice81.UserExtended[]{}; 
         
         webservicesNetexamComUserservice81.UserExtended neUser = null;         
         
         try
         {
              for(String contactId: contactIDList)
              {
                  try
                  {           
                      neUser = CreateNetExamUser(contactId); 
                      
                      System.debug('FOUND CONTACT ID: ' + neUser.ExternalID);                                       
                       
                      if(neUser.ExternalID != '')
                      {
                          Users.UserExtended.Add(neUser);
                      }
                  }
                  catch(Exception innerEx)
                  {
                      //LOG AND MOVE ON TO NEXT CONTACT
                  }
        
               }
          }
          catch(Exception ex)
          {
              System.debug('GetNetExamUsers: ' + ex);
              throw ex;
          }
    
          return Users; 

    }

    private static webservicesNetexamComUserservice81.UserExtended CreateNetExamUser(string contactID)
    {
        string transactionResult = 'Contact Not sent: Invalid Contact ID';

        webservicesNetexamComUserservice81.UserExtended neUser = new webservicesNetexamComUserservice81.UserExtended();
        try
        {
            
            if(String.isNotBlank(contactID))
            {
            
            
            
               Contact objContact = [Select 
                                       ID,
                                       FirstName,
                                       LastName,
                                       Email,
                                       Phone,
                                       MailingStreet,
                                       MailingCity,
                                       MailingCountry,
                                       MailingState,
                                       MailingPostalCode, 
                                       Job_Function__c,
                                       Contact_Number__c,
                                       Active_NetExam_User__c,
                                       active__c, 
                                       RecordType.Name,
                                       Branch_Location__c, 
                                       Selling_States__c, 
                                       Training__c,                                    
                                       Contact.Account.ID,
                                       Contact.Account.BillingStreet,
                                       Contact.Account.BillingCountry,
                                       Contact.Account.BillingCity,
                                       Contact.Account.BillingState,
                                       Contact.Account.BillingPostalCode,
                                       Contact.Account.Name,
                                       Contact.Account.OwnerId                                                                                                              
                                       FROM Contact WHERE ID = :contactID LIMIT 1]; 
                                       
                                       
                if(objContact == null) 
                {
                    transactionResult = contactID + ': Contact Not sent. Invalid Contact ID';
                    exceptionsContacts.add(transactionResult);
                    return neUser;
                }
                    
                    
                if((String.isBlank(objContact.ID)) ||
                   (String.isBlank(objContact.Account.ID)) ||
                   (String.isBlank(objContact.FirstName)) ||
                   (String.isBlank(objContact.LastName)) ||
                   (String.isBlank(objContact.Email))
                ){
                    transactionResult = contactID + ': Contact Not Sent.Invalid Contact field values. Check Account, First Name, Last Name and Email';
                    exceptionsContacts.add(transactionResult);
                    return neUser;
                 }
                
               
            
                string sfdcContactID = objContact.ID;
                string firstName = objContact.FirstName;
                string lastName = objContact.LastName;
                string email = objContact.Email;                
                string accountID = objContact.Account.ID;
                string accountCountry = objContact.Account.BillingCountry;
                string accountName = objContact.Account.Name;    
                             
                string language = 'English';
                string userType = 'Partner';
                string userRole = 'Student'; 
                string managerSFDCContactID = '';
                string UsersCountry = 'USA';
                string UsersStatus = '';        
                string userName = '';  
                string businessPhone = '';  
                string UsersUserType = userType; 
                string userActive = '1';
                string errorMsg = '';          
                
                
                //Optional variables: Default to empty strings if not used
                string jobTitle = '';
                string ContactsTimeZone = '';
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
                String hireDate = '';
                string formattedStartDate = '';
                string userGroupMgrUserId = '';
                string userGroupMgrContactId = '';
                string userGroupMgrExternalId = '';
                string secondaryUserGroup = 'Invalid';
                string groupName = '';
                Boolean bUserTypeDefined = false;
                string jobFunction = '';
                string contactNumber = '';
                string recordType = '';
                string bLocation = '';
                string sState = '';
                
                
                //Get the Training flag. If Training flag is OFF this Contact will not be sent to NetExam
                Boolean bTraining = objContact.Training__c;
                if(!bTraining )
                {
                    transactionResult = contactID + ': Contact Not Sent. Please make sure the Training is enabled';
                    exceptionsContacts.add(transactionResult);
                    return neUser;    
                }      
               
                
                //Get the Contact Status: Active or Inactive
                Boolean isActive = objContact.active__c;
                if(!isActive)
                    userActive = '0';
                    
                                    
                if(String.isNotBlank(userName))
                {
                  userName = email;
                }
            
                    
                //Check to make sure the required fields for the account object have the required information
                errorMsg = ValidateAccountData(accountName, accountID, accountCountry);        
                if(errorMsg != 'Success'){
                    transactionResult = contactID + ': Missing Account Information. Contact was not sent. ' + errorMsg;
                    exceptionsContacts.add(transactionResult);
                    return neUser;
                }
                        
                //Check to make sure the required fields for the account object have the required information
                errorMsg = ValidateContactData(sfdcContactID, firstName, lastName, email, language, userType, userRole, managerSFDCContactID);
                if(errorMsg != 'Success'){
                        
                    transactionResult = contactID + ': Missing Contact Data. Contact was not sent. ' + errorMsg;
                    exceptionsContacts.add(transactionResult);
                    return neUser;
                }                           
           
                //Get Business Phone
                try { businessPhone = ((String.isNotBlank(objContact.Phone)) ? objContact.Phone : '');} catch(Exception e){ businessPhone = '';}
                
                 //Get Street Address
                try { address1 = ((String.isNotBlank(objContact.MailingStreet)) ? objContact.MailingStreet : (String.isNotBlank(objContact.Account.BillingStreet)? objContact.Account.BillingStreet: ''));} catch(Exception e){ address1 = '';}
                        
                //Get City
                try { city = ((String.isNotBlank(objContact.MailingCity)) ? objContact.MailingCity : (String.isNotBlank(objContact.Account.BillingCity) ? objContact.Account.BillingCity : ''));} catch(Exception e){ city = '';}
                
                //Get the Country //check on null for account
                try { UsersCountry = ((String.isNotBlank(objContact.MailingCountry)) ? objContact.MailingCountry:(String.isNotBlank(objContact.Account.BillingCountry) ? objContact.Account.BillingCountry : 'USA')); } catch(Exception e){ UsersCountry = 'USA'; }
                
                //Get State 
                try { state = ((String.isNotBlank(objContact.MailingState)) ? objContact.MailingState : (String.isNotBlank(objContact.Account.BillingState) ? objContact.Account.BillingState : '')); } catch(Exception e){ state = ''; }
                
                //Get Postal Code
                try { postalCode = ((String.isNotBlank(objContact.MailingPostalCode)) ? objContact.MailingPostalCode : (String.isNotBlank(objContact.Account.BillingPostalCode) ? objContact.Account.BillingPostalCode : '')); } catch(Exception e){ postalCode = ''; }
                
                //Get the User Id for the user who is the Account owner
                try { userGroupMgrUserId = ((String.isNotBlank(objContact.Account.OwnerId)) ? objContact.Account.OwnerId : ''); } catch(Exception e){ userGroupMgrUserId = ''; }
                
                //Get the Job Function
                try { jobFunction = ((String.isNotBlank(objContact.Job_Function__c)) ? objContact.Job_Function__c : ''); } catch(Exception e){ jobFunction = ''; }
                
                //Get the Contact Number
                try { contactNumber = ((String.isNotBlank(objContact.Contact_Number__c)) ? objContact.Contact_Number__c : ''); } catch(Exception e){ contactNumber = ''; }
               
                //Get the Record Type
                try { recordType = ((String.isNotBlank(objContact.RecordType.Name)) ? objContact.RecordType.Name : '');} catch(Exception e){ recordType = '';}
                
                //Get the Branch Location
                try { bLocation = ((String.isNotBlank(objContact.Branch_Location__c)) ? objContact.Branch_Location__c : '');} catch(Exception e){ bLocation = '';}

                //Get the Selling State
                try { sState= ((String.isNotBlank(objContact.Selling_States__c)) ? objContact.Selling_States__c : '');} catch(Exception e){ sState = '';}

                
                //transactionResult = jobFunction;
                //exceptionsContacts.add(transactionResult);
                //return neUser;
                                           
                
                if( recordType == 'Residential')
                {
                    transactionResult = 'Contact not sent. Account Record Type of Residential not valid for transmission';
                    exceptionsContacts.add(transactionResult);
                    return neUser;
                }
                                
                      
               //Try to get the Contact Id if there is a Contact record associated with the User
               //NetExam prefares to use Contact Id as the External Id
               if(String.isNotBlank(userGroupMgrUserId))
               {
                   if(userGroupMgrUserId.length() > 0){ 
                      List<User> objUsrMgr = [Select ContactId FROM User WHERE Id = : userGroupMgrUserId LIMIT 1];        
                      try { userGroupMgrContactId = ((String.isEmpty(objUsrMgr[0].ContactId)) ? '': objUsrMgr[0].ContactId); } catch(Exception e){userGroupMgrContactId = '';}      
                   }
               } 
           
               //If Contact Id was found, use it otherwise just send the User Id.
               if(String.isNotBlank(userGroupMgrContactId))
               {
                   if(userGroupMgrContactId.length() > 0)
                       userGroupMgrExternalId = userGroupMgrContactId;
                   else
                       userGroupMgrExternalId = userGroupMgrUserId; 
               }     
              
            
                // Ensure that we have a valid country by setting a default
               if(String.isBlank(accountCountry))
               {
                  accountCountry = 'USA';
               }       
               
               if(String.isBlank(UsersCountry)) 
               {
                  UsersCountry = 'USA';
               }       

               // Ensure that we have a valid language by setting a default
               if(String.isBlank(language))
               {
                  language = 'English';
               } 
                        
            
               Boolean emailOptIn = true;
               Boolean preserveUserGroup = false; 
               Boolean preserveCustomFields = false; 
                
               //Try and pull the User Id from the User record if it exists
               List<User> objUser = [Select Id FROM User WHERE ContactId = :sfdcContactID LIMIT 1]; 
               if(objUser != null)
               {       
                  try{
                        sfdcUserId = objUser[0].Id;
                     }
                     catch(Exception e){
                       //Do Nothing with this exception
                       System.debug('Error Finding User: ' + e);             
                     }
               } 
               
               
               //PULL JOB FUNCTIONS DIRECT
               //Job Function is a Custom Field in NetExam. Use following business rule to determine the Job Function
               string netExamjobFunction = jobFunction;
                              
                     
               webservicesNetexamComUserservice81.ArrayOfCustomField CustomFields = new webservicesNetexamComUserservice81.ArrayOfCustomField();
               CustomFields.CustomField=  new webservicesNetexamComUserservice81.CustomField[]{};
               
               //JOB FUNCTION CUSTOM FIELD
               webservicesNetexamComUserservice81.CustomField JobFunctionCustomField = new webservicesNetexamComUserservice81.CustomField();
               JobFunctionCustomField.Name = 'Job Functions';
               JobFunctionCustomField.Value = netExamjobFunction;
                
               CustomFields.CustomField.Add(JobFunctionCustomField);                
               
               //SUNRUN ID CUSTOM FIELD 
               webservicesNetexamComUserservice81.CustomField SunRunID = new webservicesNetexamComUserservice81.CustomField();
               SunRunID.Name = 'SunrunID';
               SunRunID.Value = contactNumber;
                
               CustomFields.CustomField.Add(SunRunID); 
               
               
               //HOME CITY CUSTOM FIELD
               webservicesNetexamComUserservice81.CustomField HomeCity = new webservicesNetexamComUserservice81.CustomField();
               HomeCity.Name = 'Home City';
               HomeCity.Value = city;
                
               CustomFields.CustomField.Add(HomeCity); 
               
               //HOME STATE CUSTOM FIELD
               webservicesNetexamComUserservice81.CustomField HomeState = new webservicesNetexamComUserservice81.CustomField();
               HomeState.Name = 'Home State';
               HomeState.Value = state;
                
               CustomFields.CustomField.Add(HomeState); 
               
               //BRANCH LOCATION CUSTOM FIELD
               webservicesNetexamComUserservice81.CustomField BranchLocation = new webservicesNetexamComUserservice81.CustomField();
               BranchLocation.Name = 'Branch Location';
               BranchLocation.Value = bLocation;
                
               CustomFields.CustomField.Add(BranchLocation); 
               
               
                              
               //SELLING STATE CUSTOM FIELD
                                            
               List<string> lstStates = sState.split(';');               
                
               //transactionResult = string.valueof(lstStates.size());
               //exceptionsContacts.add(transactionResult);
               //return neUser;
               
               
               if(lstStates.size() > 0)
               {
                   webservicesNetexamComUserservice81.CustomField SellingState = null;
                   for(String strState : lstStates){
                       SellingState = new webservicesNetexamComUserservice81.CustomField();
                       SellingState.Name = 'Selling State';
                       SellingState.Value = strState;
                        
                       CustomFields.CustomField.Add(SellingState);
                   }
               }
               
               // Create the array of user groups to send to NetExam. Only the PrimaryGroup is required.
               webservicesNetexamComUserservice81.ArrayOfUserUserGroup Groups = new webservicesNetexamComUserservice81.ArrayOfUserUserGroup();
               Groups.UserUserGroup =  new webservicesNetexamComUserservice81.UserUserGroup[]{};              
                
                
               // ADD ACCOUNT AS PRIMARY USER GROUP
               webservicesNetexamComUserservice81.UserUserGroup PrimaryGroup = new webservicesNetexamComUserservice81.UserUserGroup();
               PrimaryGroup.Name = accountName;
               PrimaryGroup.ExternalID = accountID;
               PrimaryGroup.IsPrimaryUserGroup = 1;
               PrimaryGroup.Country = accountCountry;
               PrimaryGroup.AccountManagerExternalID = userGroupMgrExternalId;   
                
               Groups.UserUserGroup.add(PrimaryGroup);                
               
                   
       
                //Account Name will also be used to determine User Type in the following business rule
                //If AccountName contains "Sunrun" e.g "Sunrun Direct" or "REC" e.g "REC Solar" then user type needs to be set to Employee otherwise Partner
                if((accountName.contains('Sunrun')) ||(accountName.contains('REC'))){
                    userType = 'Employee';
                }
                else{
                    userType = 'Partner';
                }        
                          
               

                //NetExam User
                neUser.FirstName = firstName;
                neUser.LastName = lastName;
                neUser.UserName = userName;
                neUser.Email = email;
                neUser.BusinessPhone = businessPhone;
                neUser.PersonalEmail = personalEmail;
                neUser.Address1 = address1; 
                neUser.Address2 = address2; 
                neUser.City = city;
                neUser.State = state;
                neUser.TimeZone = ContactsTimeZone; 
                neUser.PostalCode = postalCode; 
                neUser.Country = UsersCountry; 
                neUser.Language = language;
                neUser.UserGroups = Groups; 
                neUser.JobCategory = jobCategory; 
                neUser.JobTitle = jobTitle; 
                neUser.UserTypeName = userType; 
                neUser.ExternalID = sfdcContactID; 
                neUser.ExternalUserID = sfdcUserId;
                neUser.Status = userActive; 
                neUser.ManagerExternalID = managerSFDCContactID; 
                neUser.PreserveUserGroup = preserveUserGroup; 
                neUser.PreserveCustomFields = preserveCustomFields;
                neUser.customFields = CustomFields;     
                neUser.UserRole = userRole;
                neUser.AlternateEmail = '';
                neUser.version = 0;         
                //emailOptIn
                //hireDate
            }
        }
        catch(Exception ex)
        {
           System.debug('CreateNetExamUser: ' + ex);              
           throw ex;
        } 
                       
        return neUser;

    }
    
    Webservice static string SendContactToNetExam(string contactID)
    {
        string transactionResult = 'Contact Sent Successfully';
        
        webservicesNetexamComUserservice81.UserExtended neUser = CreateNetExamUser(contactId);
        
        if(String.isBlank(neUser.ExternalID))
        {
            if(exceptionsContacts.size() > 0)
            {
                transactionResult = exceptionsContacts.get(0);
                exceptionsContacts.clear();
            }
        
        }
        else
        {
                          
             // Send the Contact to NetExam
             Boolean bStatus = ((neUser.Status=='1')?true:false);                                                                                                                                                                                                                                                                                                                                                         
             string errorMsg = UpsertUserWithUserGroupsExtended(ne_apiKey, 
                                                               ne_apiUser, 
                                                               ne_apiPass,
                                                               neUser.FirstName, 
                                                               neUser.LastName, 
                                                               neUser.UserName,
                                                               neUser.UserRole, 
                                                               neUser.Email, 
                                                               neUser.BusinessPhone, 
                                                               neUser.PersonalEmail, 
                                                               neUser.Address1, 
                                                               neUser.Address2, 
                                                               neUser.City, 
                                                               neUser.State, 
                                                               neUser.TimeZone, 
                                                               neUser.PostalCode, 
                                                               neUser.Country, 
                                                               neUser.Language,
                                                               neUser.UserGroups, 
                                                               neUser.JobCategory, 
                                                               neUser.JobTitle, 
                                                               neUser.UserTypeName, 
                                                               neUser.ExternalID, 
                                                               neUser.ExternalUserID,
                                                               bStatus, 
                                                               neUser.ManagerExternalID, 
                                                               neUser.PreserveUserGroup, 
                                                               neUser.PreserveCustomFields,
                                                               neUser.customFields, 
                                                               false,
                                                               '');
               
                if(errorMsg != 'Success')
                {
                    transactionResult = 'Error Sending Data to NE web service. Contact was not sent. ' + errorMsg;
                }
                else
                {
                   Contact theContact = [select Active_NetExam_User__c from contact WHERE Id =: neUser.ExternalID limit 1];
                    if(!theContact.Active_NetExam_User__c)
                    {
                        theContact.Active_NetExam_User__c = True;                                    
                        update theContact;
                    } 
                }
                    
            }           
                        
            return transactionResult;
    
    }

    private static void BulkUpsertUsersWithUserGroups(webservicesNetexamComUserservice81.ArrayOfUserExtended Users)
    {
       string ne_result = '';
       Integer transactionId; 

       try{
           webservicesNetexamComUserservice81.UserServiceSoap ne_Webservice = new webservicesNetexamComUserservice81.UserServiceSoap();
           webservicesNetexamComUserservice81.ApiResult apiResult = ne_Webservice.BulkUpsertUsersWithUserGroups(ne_apiKey, ne_apiUser, ne_apiPass, Users);
           System.debug('Result: ' + apiResult.Code + ':' + apiResult.Description);
           transactionId = integer.valueof(apiResult.Code);
           ne_result = 'Success';
           
           try{
               webservicesNetexamComUserservice81.ArrayOfBulkUploadTransaction arrResults = ne_Webservice.GetBulkUpsertTransactionLog(ne_apiKey, ne_apiUser, ne_apiPass, transactionId);
               webservicesNetexamComUserservice81.BulkUploadTransaction[] arrTransactionResults = arrResults.BulkUploadTransaction;
               
               System.debug('XXXX: TRANSACTION RESULT ARRAY SIZE: ' + arrTransactionResults.size());
                             
               webservicesNetexamComUserservice81.BulkUploadTransaction tResult;
               integer iErrorCode  = 0;
               if(arrTransactionResults.size() > 0)
               {
                   for(integer i=0;i<arrTransactionResults.size();i++)
                   {
                       tResult = arrTransactionResults[i]; 
                       iErrorCode = integer.valueOf(tResult.ErrorCode);
                       System.debug('CONTACTS EMAIL: ' + tResult.Email + ' ERROR CODE: ' + tResult.ErrorCode);
                       if(iErrorCode == 1)
                       {
                             System.debug('SUCCESSFUL: UPDATE CONTACT - CONTACTS EMAIL: ' + tResult.Email + ' ERROR CODE: ' + tResult.ErrorCode );  
                             
                             webservicesNetexamComUserservice81.UserExtended[] sentUsers = Users.UserExtended;
                             
                             System.debug('SENT USERS ARRAY LENGTH : ' + sentUsers.size());
                             
                             for(integer iSearch = 0;iSearch < sentUsers.size();iSearch++)
                             {
                                 if(sentUsers[iSearch].Email == tResult.Email)
                                 {
                                    System.debug('CONTACT TO UPDATE : ' + sentUsers[iSearch].ExternalID);
                                    
                                    Contact theContact = [select Active_NetExam_User__c from contact WHERE Id =: sentUsers[iSearch].ExternalID limit 1];
                                    if(!theContact.Active_NetExam_User__c)
                                    {
                                        theContact.Active_NetExam_User__c = True;                                    
                                        update theContact;
                                    }
                                     
                                 } 
                             }
                             
                             //+ ' EXTERNAL ID ' + Users.UserExtended[i].ExternalID
                             
                             //System.debug('SUCCESSFUL: CONTACT ID ' + Users.UserExtended[i].ExternalID);
                       }
                       //tResult.ErrorCode
                   }   //tResult.Email
               }
               
           }
           catch(System.Exception te){
           
           }
           

       }
       catch(System.CalloutException e){
            System.debug('Error: ' + e);            
            ne_result = e.getMessage().replace('Web service callout failed: WebService returned a SOAP Fault: ','').replace('faultcode=soap:Client faultactor=','');          
       }
    }
    
      
    //This method will create a user in NetExam OR if the user already exists(checked by sfdcContactID) the user's information will be updated.
    private static string UpsertUserWithUserGroupsExtended(string apiKey, string apiUser, string apiPass, string firstName,string lastName, string userName, string userRole, string email, string businessPhone, string personalEmail, string address1, string address2, string city, string state, string ContactsTimeZone, string postalCode, string accountCountry, string language, webservicesNetexamComUserservice81.ArrayOfUserUserGroup Groups,string jobCategory, string jobTitle, string userType, string sfdcContactID, string sfdcUserId, Boolean status, string managerSFDCContactID, Boolean preserveUserGroup, Boolean preserveCustomFields, webservicesNetexamComUserservice81.ArrayOfCustomField CustomFields, Boolean emailOptIn,string startDate)
    {
        string ne_result = '';
       //INVOKE WEBSERVICE CALL TO ADD/UPDATE USER        
       
       try{
           webservicesNetexamComUserservice81.UserServiceSoap ne_Webservice = new webservicesNetexamComUserservice81.UserServiceSoap();
           webservicesNetexamComUserservice81.ApiResult Result = ne_Webservice.UpsertUserWithUserGroupsExtended(apiKey, apiUser, apiPass, firstName,lastName, userName, userRole, email, businessPhone, personalEmail, address1, address2, city, state, ContactsTimeZone, postalCode, accountCountry, language, Groups, jobCategory, jobTitle, userType, sfdcContactID, sfdcUserId, status, managerSFDCContactID, preserveUserGroup, preserveCustomFields, CustomFields, emailOptIn,startDate);
           System.debug('Result: ' + Result.Code + ':' + Result.Description);
           ne_result = 'Success';
        }
        catch(System.CalloutException e){
            System.debug('Error: ' + e);            
            ne_result = e.getMessage().replace('Web service callout failed: WebService returned a SOAP Fault: ','').replace('faultcode=soap:Client faultactor=','');          
        }
        
        return ne_result;  
        
    }  
   
      
    //This method simply checks to make sure that there is enough information to create the user group. 
    // If these values are missing, the webservice would return an error.
    // NOTE: Not all params are required, so not all params are checked.
    private static string ValidateAccountData(string accountName, string accountID, string accountCountry)
    {
        string errorMsg = '';
       
        if(String.isNotBlank(accountID))
        {
            if(accountID.length() == 0){
                errorMsg = errorMsg + '<br>Account ID';
            }
        }
        else{
            errorMsg = errorMsg + '<br>Account ID';
        }        
        
        if(String.isNotBlank(accountName))
        {     
            if(accountName.length() == 0){
                errorMsg  = errorMsg + '<br>Account Name';
            }
        }
        else{
            errorMsg  = errorMsg + '<br>Account Name';
        }
        
        if(errorMsg.length() > 0){
            errorMsg = 'Missing required information: ' + errorMsg;
        }
        else{
            errorMsg = 'Success';
        }

        return errorMsg;
    }
    
    //This method simply checks to make sure that there is enough information to create the user group. 
    // If these values are missing, the webservice would return an error.
    // NOTE: Not all params are required, so not all params are checked.
    private static string ValidateContactData(string sfdcContactID, string firstName, string lastName, string email, string language, string userType, string userRole, string managerSFDCContactID)
    {
        string errorMsg = '';       
        
        //check null for all variables 
        if(String.isNotBlank(firstName))
        {
            if(firstName.length() == 0){
                errorMsg  = errorMsg + '<br>First Name';
            }
        }
        else{
            errorMsg  = errorMsg + '<br>First Name';
        }
        
        if(String.isNotBlank(lastName))
        {
            if(lastName.length() == 0){
                errorMsg = errorMsg + '<br>Last Name';
            }
        }
        else{
            errorMsg = errorMsg + '<br>Last Name';
        }
        
        if(String.isNotBlank(lastName))
        {
            if(email.length() == 0){
                errorMsg = errorMsg + '<br>Email';
            }
        }
        else{
            errorMsg = errorMsg + '<br>Email';
        }
        
        if(errorMsg.length() > 0){
            errorMsg = 'Missing required information: ' + errorMsg;
        }
        else{
            errorMsg = 'Success';
        }

        return errorMsg;
    
    }
   

}