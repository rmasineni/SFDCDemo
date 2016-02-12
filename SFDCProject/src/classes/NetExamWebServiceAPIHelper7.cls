global class NetExamWebServiceAPIHelper7
{
    public class MissingAccountInformationException extends Exception{}
    public class NetExamWebserviceException extends Exception{}
	public static string ne_apiKey = Label.NetExam_API_Key;
	public static string ne_apiUser = Label.NetExam_API_User;
	public static string ne_apiPass = Label.NetExam_API_Pass;
	public static string contactSalesforceErrorMsg = 'Salesforce is unable to send the Contact details to NetExam. ';

    @Future(callout=true)
    public static void SendContactFromTrigger(Set<Id> contactIds, Set<Id> activateContactIds, Set<Id> deactivateContactIds){
		System.debug('contactIds: ' + contactIds);
		System.debug('activateContactIds: ' + activateContactIds);
		System.debug('deactivateContactIds: ' + deactivateContactIds);
		
		NetExamWebServiceAPIHelper7.processContactForLMS(contactIds, activateContactIds, deactivateContactIds);
	}
	public static void SendContactFromBatch(Set<Id> contactIds, Set<Id> activateContactIds, Set<Id> deactivateContactIds){
		System.debug('contactIds: ' + contactIds);
		System.debug('activateContactIds: ' + activateContactIds);
		System.debug('deactivateContactIds: ' + deactivateContactIds);
		
		NetExamWebServiceAPIHelper7.processContactForLMS(contactIds, activateContactIds, deactivateContactIds);
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
		        */
		        
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
    }    
	


    Webservice static string SendContactToNetExam(string sfdcContactID, string firstName, string lastName, string email, 
    												string language, string userType, string userRole, boolean status, string managerSFDCContactID, 
    												string accountName, string accountID, string accountCountry, string contactNumber)
    {
        // Change these to match your new NetExam account
       // final string ne_apiKey = 'dk42kdKA-0dkE-Ke76-kN62-837mdKhduc763J0';
       // final string ne_apiUser = 'srsbxapiuser';
       // final string ne_apiPass = '01JgxX6k';
        string errorMsg = '';      

		try{
        
	        if(accountID.length() == 0){
	            return 'Error, no account information was associated with this contact: ' + errorMsg ;
	        }
	        
	
	        //Check to make sure the required fields for the account object have the required information
	        errorMsg = ValidateAccountData(accountName, accountID, accountCountry);        
	        if(errorMsg != 'Success'){
	            return contactSalesforceErrorMsg + errorMsg;
	        }
	        
	        //Check to make sure the required fields for the account object have the required information
	        errorMsg = ValidateContactData(sfdcContactID, firstName, lastName, email, language, userType, userRole, managerSFDCContactID);
	        if(errorMsg != 'Success'){
	            return contactSalesforceErrorMsg + errorMsg;
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
	
	        webservicesNetexamComUserservice7.CustomField SunRunID = new webservicesNetexamComUserservice7.CustomField();
			//SunRunID.Name = 'SunRunContactNumber';
			SunRunID.Name = 'SunrunID';
			SunRunID.Value = contactNumber;
	 
	        webservicesNetexamComUserservice7.ArrayOfCustomField CustomFields = new webservicesNetexamComUserservice7.ArrayOfCustomField();
	        CustomFields.CustomField= new webservicesNetexamComUserservice7.CustomField[]{SunRunID};
	        
	        // Add account as primary user group
	        webservicesNetexamComUserservice7.UserUserGroup PrimaryGroup = new webservicesNetexamComUserservice7.UserUserGroup();
	        PrimaryGroup.Name = accountName;
	        PrimaryGroup.ExternalID = accountID;
	        PrimaryGroup.IsPrimaryUserGroup = 1;
	        PrimaryGroup.Country = 'USA';
	        
	        // Create the array of user groups to send to NetExam. Only the PrimaryGroup is required.
	        webservicesNetexamComUserservice7.ArrayOfUserUserGroup Groups = new webservicesNetexamComUserservice7.ArrayOfUserUserGroup();         
	        Groups.UserUserGroup =  new webservicesNetexamComUserservice7.UserUserGroup[]{PrimaryGroup};     
	       
	                
	        // Send the Contact to NetExam
	        errorMsg = UpsertUserWithUserGroups(ne_apiKey, ne_apiUser, ne_apiPass, sfdcContactID, firstName, lastName, email, 
	        									language, userType, userRole, status,
	        									managerSFDCContactID, accountID, accountName, Groups, CustomFields,accountCountry);
	        if(errorMsg != 'Success'){
	            return contactSalesforceErrorMsg + errorMsg;
	        }
	        
	        return 'Success';    
		}
		catch(Exception expObj){
			return expObj.getMessage();
		}
    }

    
    //This method will create a user in NetExam OR if the user already exists(checked by sfdcContactID) the user's information will be updated.
    private static string UpsertUserWithUserGroups(string apiKey, string apiUser, string apiPass, string sfdcContactID, 
    												string firstName, string lastName, string email, string language, 
    												string userType, string userRole, boolean status,
    												string managerSFDCContactID,  string accountID, string accountName, 
    												webservicesNetexamComUserservice7.ArrayOfUserUserGroup Groups, 
    												webservicesNetexamComUserservice7.ArrayOfCustomField CustomFields,string country)
    {
        string ne_result = '';
       //INVOKE WEBSERVICE CALL TO ADD/UPDATE USER 
       try{
           webservicesNetexamComUserservice7.UserServiceSoap ne_Webservice = new webservicesNetexamComUserservice7.UserServiceSoap();
           webservicesNetexamComUserservice7.ApiResult Result = ne_Webservice.UpsertUserWithUserGroups(apiKey,apiUser,apiPass,sfdcContactID,firstName,lastName, email, language, userType, userRole, managerSFDCContactID, Groups, true, CustomFields, status,country); 
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
    private static string AddEditUserGroup(string apiKey, string apiUser, string apiPass, string AccountName, string AccountID, string AccountCountry)
    {
        string ne_result = '';      
        try{
            webservicesNetexamComUserservice7.UserServiceSoap ne_Webservice = new webservicesNetexamComUserservice7.UserServiceSoap();
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
    
    //This method simply checks to make sure that there is enough information to create the user group. 
    // If these values are missing, the webservice would return an error.
    // NOTE: Not all params are required, so not all params are checked.
    private static string ValidateAccountData(string accountName, string accountID, string accountCountry)
    {
        string errorMsg = '';
        integer accountIDLength;
        integer accountNameLength;

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

        return errorMsg;
    }
    
    //This method simply checks to make sure that there is enough information to create the user group. 
    // If these values are missing, the webservice would return an error.
    // NOTE: Not all params are required, so not all params are checked.
    private static string ValidateContactData(string sfdcContactID, string firstName, string lastName, string email, string language, string userType, string userRole, string managerSFDCContactID)
    {
        string errorMsg = '';
        integer firstNameLength;
        integer lastNameLength;
        integer emailLength;
        integer userTypeLength;
        integer userRoleLength;
        
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

        return errorMsg;
    
    }   
	
	static testMethod void SendContactToNetExam_TestMethod()
    {
    
        Account testAccount = new Account(Name='Test Account NE');
        insert testAccount;
 
        List<Account> objAccount = [Select ID FROM Account WHERE Name = 'Test Account NE' LIMIT 1];        
        
        String testAccountID = (String)objAccount[0].ID;
        system.assert(testAccountID.length() > 0);      
        
        //Missing Info
        string result = ValidateAccountData('', '', '');
        system.assert(result != 'Success');
        
        result = ValidateContactData('', '', '', '', '', '', '', '');
        system.assert(result != 'Success');
        
        //Missing Account Info
        result = SendContactToNetExam('test', 'test', 'test', 'test', 'test', 'test', 'test', false , 'test',  '', '', '', '1234567890');
        system.assert(result != 'Success');
        
        //Missing Contact Info
        result = SendContactToNetExam('', '', '', '', '', 'test', 'test', false , 'test', 'test', testAccountID, 'test', '1234567890');
        //system.assert(result == 'Success');
        
        //Valid Info
        result = ValidateAccountData('1234', '1234', '1234');
        system.assert(result == 'Success');
        
        result = ValidateContactData('test', 'test', 'test', 'test', 'test', 'test', 'test', 'test');
        system.assert(result == 'Success');
        
        result = SendContactToNetExam('test', 'test', 'test', 'test', '', 'test', 'test', false , 'test', 'test', testAccountID, 'test','1234567890');
        //system.assert(result == 'Success');  
        
        delete testAccount;
    }     

    static testMethod void SendContactFromTrigger_TestMethod()
    {
        Account testAccount = new Account(Name='Test Account NE');
        insert testAccount;
        List<Account> objAccount = [Select ID FROM Account WHERE Name = 'Test Account NE' LIMIT 1];        
        String testAccountID = (String)objAccount[0].ID;
        system.assert(testAccountID.length() > 0);
    
        try
        {
            //Missing Contact Info
            //SendContactFromTrigger('', '', '', '', 'test', '');
        }
        catch(MissingAccountInformationException e)
        {
            system.assert(e.getMessage() == 'Account Could Not Be Found');
        }        
		delete testAccount;
    }

    static testMethod void AddEditUserGroup_TestMethod()
    {
        // This always fails because it includes Callouts
        string result = AddEditUserGroup('1234', '1234', '1234', '1234', '1234', '1234');
        //system.assert(result == 'Success');
    }
    
    static testMethod void UpsertUserWithUserGroups_TestMethod()
    {    
        // This always fails because it includes Callouts
        webservicesNetexamComUserservice7.ArrayOfUserUserGroup Groups = new webservicesNetexamComUserservice7.ArrayOfUserUserGroup();
        webservicesNetexamComUserservice7.ArrayOfCustomField CustomFields = new webservicesNetexamComUserservice7.ArrayOfCustomField();        
        string result = UpsertUserWithUserGroups('1234', '1234', '1234', 'test', 'test', 'test', 'test', 'test', 'test', 'test', false, 'test', 'test', 'test', Groups ,CustomFields,'USA' );
        //system.assert(result == 'Success');
                                                          
    } 

	/*
	public static String activateContacts(Id contactId){
		string ne_result = '';
		webservicesNetexamComUserservice7.UserServiceSoap ne_Webservice = new webservicesNetexamComUserservice7.UserServiceSoap();
		for(Integer i=0; i < 3; i++){
			try{
	 			webservicesNetexamComUserservice7.ApiResult Result = ne_Webservice.ActivateUserByExternalID(ne_apiKey,ne_apiUser,ne_apiPass,contactId);
				System.debug('Result: ' + Result.Code + ':' + Result.Description);
				ne_result = 'Success';   	
				break;			
 			}catch(System.CalloutException e){
				System.debug('Error: ' + e);
				ne_result = e.getMessage().replace('Web service callout failed: WebService returned a SOAP Fault: ','').replace('faultcode=soap:Client faultactor=','');          
	    	}
		}
	    return ne_result;				
	}
	
	public static String deActivateContact(Id contactId){
		String ne_result = '';
		webservicesNetexamComUserservice7.UserServiceSoap ne_Webservice = new webservicesNetexamComUserservice7.UserServiceSoap();
		for(Integer i=0; i < 3; i++){
			try{
				webservicesNetexamComUserservice7.ApiResult Result = ne_Webservice.DeactivateUserByExternalID(ne_apiKey,ne_apiUser,ne_apiPass,contactId);				
				System.debug('Result: ' + Result.Code + ':' + Result.Description);
				ne_result = 'Success';   	
				break;			
 			}catch(System.CalloutException e){
				System.debug('Error: ' + e);
				ne_result = e.getMessage().replace('Web service callout failed: WebService returned a SOAP Fault: ','').replace('faultcode=soap:Client faultactor=','');          
	    	}
		}
	    return ne_result;				
	}
	*/

	/*
    public static void processBulkContactsForLMS(Set<Id> contactIds)
    {       

        String country = 'USA';
        String language = 'English';
        String userRole = 'Student';
        String managerSFDCContactID = ''; 
		Map<Id, Contact> exceptionContacts = new Map<Id, Contact>();
		String tempErrorMessage = '';
		List<Contact> contactList = [Select Id, name, firstname, lastname, email, account.name, Ultimate_Parent_Account__c,
										job_function__c, active__c from Contact where Id in :contactIds];
		Set<String> exceptionsMessages = new Set<String>();
		
		webservicesNetexamComUserservice7.ArrayOfUser Users = new webservicesNetexamComUserservice7.ArrayOfUser();
		Users.User_x =  new webservicesNetexamComUserservice7.User_x[contactList.size()]; 
		
		Integer i = 0;
		for(Contact contactObj: contactList){

			webservicesNetexamComUserservice7.UserUserGroup acct = new webservicesNetexamComUserservice7.UserUserGroup();
			acct.ExternalId = contactObj.Ultimate_Parent_Account__c;
			acct.Name = contactObj.account.name;
			acct.Country = 'USA';       
		       
			webservicesNetexamComUserservice7.User_x user = new webservicesNetexamComUserservice7.User_x();    
			user.FirstName = contactObj.firstName;
			user.LastName = contactObj.lastName;
			user.UserName = contactObj.lastName;
			user.Email = contactObj.email;
			user.AlternateEmail = '';
			user.City = 'Dallas';
		    user.Country = 'USA';
		   	user.State = 'TX';
		    user.PostalCode = '75226';
			user.Language = 'English';
			user.BusinessPhone = '';
			user.PersonalPhone = '';
			user.PersonalEmail = '';
			user.JobCategory = contactObj.job_function__c;
			user.JobTitle = '';
			user.TimeZone = '9';
			user.ExternalID = contactObj.Id;
			user.UserRole = 'Student';
			user.UserTypeName = 'Channel - US';
			user.ManagerExternalID = '';
			user.Status = '1';
			user.userGroup = acct;
			Users.User_x[i] = user; 
    		i++;
		}
	                 
		try{
		    BulkUpsertUsers(ne_apiKey, ne_apiUser, ne_apiPass, Users);    
		}
		catch(Exception ex)
		{                       
			
		} 

    }    
	*/
    
     //This method will Bulk upsert users in NetExam OR if the user already exists(checked by sfdcContactID) the user's information will be updated.
	//@Future(callout=true)
	/*
	public static string BulkUpsertUsers(string apiKey, string apiUser, string apiPass, webservicesNetexamComUserservice7.ArrayOfUser Users)
    {
		string ne_TransactionID = '0';
		//INVOKE WEBSERVICE CALL TO BulkUpsert Users 
		try{
           	webservicesNetexamComUserservice7.UserServiceSoap ne_Webservice = new webservicesNetexamComUserservice7.UserServiceSoap();
			webservicesNetexamComUserservice7.ApiResult Result = ne_Webservice.BulkUpsertUsers(apiKey,apiUser,apiPass,Users);
          
           //Get the Transaction ID. You can use the Transaction ID In the GetBulkUpsertTransactionLog method to get the results of your BulkUpsertUsers call 
			ne_TransactionID = string.valueof(Result.Code);
			System.debug('ne_TransactionID: ' + ne_TransactionID);
        }
        catch(Exception e){
            System.debug('Error: ' + e);            
        }
        return ne_TransactionID;        
    }
	*/
	
	/*
	static testMethod void BulkUpsertUsers_Test() {    
       string result = 'FAIL';
       try
       {        
            webservicesNetexamComUserservice7.ArrayOfUser Users = new webservicesNetexamComUserservice7.ArrayOfUser();
            Users.User_x =  new webservicesNetexamComUserservice7.User_x[1];  
                                  
                 
            webservicesNetexamComUserservice7.UserUserGroup acct = new webservicesNetexamComUserservice7.UserUserGroup();
            acct.ExternalId = '3837263728918376AAG';
            acct.Name = 'TestUsers_USA';
            acct.Country = 'USA';       
               
            webservicesNetexamComUserservice7.User_x user = new webservicesNetexamComUserservice7.User_x();    
            user.FirstName = 'Carlito';
            user.LastName = 'Hlazo';
            user.UserName = 'carlito@email.com';
            user.Email = 'carlito@email.com';
            user.AlternateEmail = '';
            user.City = 'Dallas';
            user.Country = 'USA';
            user.State = 'TX';
            user.PostalCode = '75226';
            user.Language = 'English';
            user.BusinessPhone = '';
            user.PersonalPhone = '';
            user.PersonalEmail = '';
            user.JobCategory = '';
            user.JobTitle = '';
            user.TimeZone = '9';
            user.ExternalID = '786398483728379AAA';
            user.UserRole = 'Student';
            user.UserTypeName = 'Channel - US';
            user.ManagerExternalID = '';
            user.Status = '1';
            user.userGroup = acct;
            Users.User_x[0] = user; 
        	//final string ne_apiKey = 'dk42kdKA-0dkE-Ke76-kN62-837mdKhduc763J0';
            //final string ne_apiUser = 'srsbxapiuser';
            //final string ne_apiPass = '01JgxX6k';
            BulkUpsertUsers(ne_apiKey, ne_apiUser, ne_apiPass, Users);
             result = 'SUCCESS';            
            system.assert(result == 'SUCCESS');        
        
        }
        catch(Exception ex)
        {                       
            system.assert(result == 'SUCCESS'); 
        }        
    }  
	*/

}