public class PRMEmailManager {

 	public static void communicateNewUserDetails(User userobj, User accountManager, String companyName, 
 												Boolean newUser, 
 												Boolean activateUser) {
    	
    	if(accountManager == null || userobj == null)
    		return;
    		
    	Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
    	String organizationName =  companyName;	
		List<String> toAddresses = new List<String>();
		toAddresses.add(accountManager.email);
		
		String subject = organizationName ;
		if(newUser != null && newUser == true){
			subject += ': Created new partner portal user' ;
		}
		//else if(activateUser != null && activateUser == true){
		//	subject += ': Activated partner portal user' ;
		//}else if(activateUser != null && activateUser == false){
		//	subject += ': Deactivated partner portal user' ;
		//}

		String htmlBody = '<html>';
		htmlBody += EmailService.getHTMLHeader();
		htmlBody += '<p></p>';
		htmlBody += getPlainTextBodyForNewPRMUser(organizationName, 
													accountManager.Name, 
													userobj, newUser, activateUser);
		htmlBody += EmailService.getHTMLFooter();
		htmlBody += '</html>';
		sendEmail(toAddresses, subject, htmlBody);	
    }

	public static void communicateErrorDetails(Account partnerAccount, Contact contactObj, 
 												User accountManager, String errorMessage) {
    	
    	if(accountManager == null || contactObj == null)
    		return;
    		
    	Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
		List<String> toAddresses = new List<String>();
		toAddresses.add(accountManager.email);
		
		String subject = partnerAccount.name ;
		subject += ': Unable to create new partner portal user';

		String htmlBody = '<html>';
		htmlBody += EmailService.getHTMLHeader();
		htmlBody += '<p></p>';
		htmlBody += getPlainTextBodyForError(partnerAccount, contactObj, accountManager, errorMessage);
		htmlBody += EmailService.getHTMLFooter();
		htmlBody += '</html>';
		sendEmail(toAddresses, subject, htmlBody);	
    }

 	private static String getPlainTextBodyForError(Account accountObj, Contact contactObj,
 														User userObj,
 														String errorMessage){

		String ret = '';
		ret += '<p>Dear ' + userObj.name  + ',</p><br/>';
		ret += '<br/>';
		ret += '<p></p>';
	
		ret += 'Salesforce is unable to create new Partner Portal user.<br/>';
		ret += '<br/>';
		ret += '<font size="4" ><u> Partner Details </u> </font> <br/>';
		ret += ' <b>Partner Account Id: </b>' + accountObj.Id +  ' <br/>';
		ret += ' <b>Partner Account Name: </b>' + accountObj.name +  ' <br/>';
		ret += '<br/>';
		ret += '<p></p>';	

		ret += '<font size="4" ><u> Contact Details  </u></font> <br/>';
		ret += ' <b>Contact Id: </b>' + contactObj.Id +  ' <br/>';
		ret += ' <b>Contact Name: </b>' + contactObj.name +  ' <br/>';
		ret += ' <b>Contact Email: </b>' + contactObj.email +  ' <br/>';
		ret += ' <b>Error Message: </b>' + errorMessage +  ' <br/>';

		ret += '<br/>';
		ret += '<p></p>';	
		ret += '<br/>';
		ret += '<br/>';
		ret += '<p></p>';
		ret += 'Thank you,<br/>';
		ret += 'SunRun Customer Support';
		ret += '<p></p>';
		ret += '<p></p>';
		return ret;
	}

	
 	private static String getPlainTextBodyForNewPRMUser(String organizationName, 
 														String accountManagerName,
 														User userObj, 
 														Boolean newUser, 
 														Boolean activateUser){

		String ret = '';
		ret += '<p>Dear ' + accountManagerName  + ',</p><br/>';
		String name = '';
		name += (userObj.Firstname != null) ? userObj.Firstname : '';
		name += ' ';
		name += (userObj.Lastname != null) ? userObj.Lastname : '';
		
		if(newUser != null && newUser == true){
			ret += 'New partner portal user has been created for the following partner.<br/>';
		}
		//else if (activateUser != null && activateUser == true){
		//	ret += 'Following Partner portal user has been activated for the following partner.<br/>';			
		//}else if(activateUser != null && activateUser == false){
		//	ret += 'Following Partner portal user has been deactivated for the following partner.<br/>';	
		//}
		
		ret += 'Partner Account: ' + organizationName + '<br/>';
		ret += '<br/>';
		ret += '<p></p>';		
		ret += 'Partner User details: <br/>';
		ret += 'Name: '+  name + '<br/>';
		ret += 'Username: '+  userObj.username + '<br/>';
		ret += '<br/>';
		ret += '<br/>';
		ret += '<p></p>';
		ret += 'Thank you,<br/>';
		ret += 'SunRun Customer Support';
		ret += '<p></p>';
		ret += '<p></p>';
		return ret;
	}

	public static void sendEmail(List<String> toAddresses, String subject, String htmlBody){
		sendEmail(toAddresses, subject, htmlBody, null);
	}
	
    public static void sendEmail(List<String> toAddresses, String subject, String htmlBody, String fromEmailId){
		Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
		mail.setHtmlBody(htmlBody);
		mail.setSubject(subject);
		mail.setToAddresses(toAddresses);
		if(fromEmailId != null && fromEmailId != ''){
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


	public static void communicateLMSInfoErrorDetails(List<Contact> contactList,Set<String> exceptionsMessages, String emailId) {
    	
    	if(emailId == null || emailId == '' || contactList == null || contactList.size() == 0)
    		return;
    		
    	Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
		List<String> toAddresses = new List<String>();
		toAddresses.add(emailId);
		
		String subject = 'Unable to send the Partner Contact Details to NetExam';

		String htmlBody = '<html>';
		htmlBody += EmailService.getHTMLHeader();
		htmlBody += '<p></p>';
		htmlBody += getPlainTextBodyForContactInfo(contactList, exceptionsMessages);
		htmlBody += EmailService.getHTMLFooter();
		htmlBody += '</html>';
		sendEmail(toAddresses, subject, htmlBody);	
    }

 	public static String getPlainTextBodyForContactInfo(List<Contact> contactList, Set<String> exceptionsMessages){

		String ret = '';
		ret += '<p>Hello,</p><br/>';
		ret += '<br/>';
		ret += '<p></p>';
	
		ret += 'Salesforce is unable to send the following partner contact details to NetExam.<br/>';
		ret += '<br/>';
		ret += '<font size="4" ><u> Contact Details  </u></font> <br/>';
		
		for(Contact contactObj : [Select Id, firstname, lastname, email, job_function__c, Account.Name, Contact_Number__c,
									Ultimate_Parent_Account__c, active__c 
									from Contact where Id in :contactList] ){
			ret += ' <b>Contact Id: </b>' + contactObj.Id +  ' <br/>';
			ret += ' <b>Contact Number: </b>' + contactObj.Contact_Number__c +  ' <br/>';
			if(contactObj.firstname != null)
				ret += ' <b>FirstName: </b>' + contactObj.firstname +  ' <br/>';

			if(contactObj.lastname != null)				
				ret += ' <b>Lastname: </b>' + contactObj.lastname +  ' <br/>';
			
			if(contactObj.email != null)	
				ret += ' <b>Email: </b>' + contactObj.email +  ' <br/>';
			
			if(contactObj.job_function__c != null)
				ret += ' <b>Job Function: </b>' + contactObj.job_function__c +  ' <br/>';
				
			ret += ' <b>Account Name: </b>' + contactObj.Account.Name +  ' <br/>';
			ret += ' <b>Account Id: </b>' + contactObj.Ultimate_Parent_Account__c +  ' <br/>';
			ret += ' <b>Contact Active: </b>' + contactObj.active__c +  ' <br/>';
			ret += ' <b>Language: </b>' + 'English'+  ' <br/>';
			ret += ' <b>User Role: </b>' + 'Student'+  ' <br/>';
			ret += ' <b>Country: </b>' + 'USA'+  ' <br/>';
			ret += ' <b>Manager iD: </b>' + ' <br/>';
			ret += '<br/>';			
		}
		ret += ' <b>Error Message(s): </b>';
		for(String errorMessage : exceptionsMessages){
			ret +=  errorMessage +  ' <br/>';
		}

		ret += '<br/>';
		ret += '<p></p>';	
		ret += '<br/>';
		ret += '<br/>';
		ret += '<p></p>';
		ret += 'Thank you,<br/>';
		ret += 'SunRun Salesforce Admin';
		ret += '<p></p>';
		ret += '<p></p>';
		return ret;
	}
	
	
	public static String getTaskHTMLBody(String subject, Proposal__c proposalObj, Task taskObj, User partnerSalesRep) {

		List<String> toAddresses = new List<String>();
		String htmlBody = '<html>';
		htmlBody += EmailService.getHTMLHeader();
		htmlBody += '<p></p>';
		
		String ret = '';
		ret += '<p>Dear ' + partnerSalesRep.name  + ',</p><br/>';
		ret += '<br/>';
		ret += '<p></p>';
	
		ret += UserInfo.getName() + ' has assigned you the following new task: <br/>';
		ret += '<br/>';
		ret += '<font ><u> Task Details </u> </font> <br/>';
		ret += '<br/>';
		ret += '<p></p>';
		//ret += ' <b>Subject: </b>' + subject +  ' <br/>';
		ret += ' <b>Customer Name: </b>' + proposalObj.Homeowner_Name__c +  ' <br/>';
		ret += ' <b>Proposal Name: </b>' + proposalObj.Name +  ' <br/>';
		ret += ' <b>Status: </b>' + taskObj.status +  ' <br/>';
		ret += ' <b>Priority: </b>' + taskObj.priority +  ' <br/>';
		ret += ' <b>Description: </b>' + taskObj.Description +  ' <br/>';

		ret += '<br/>';
		ret += '<p></p>';
		
		String baseUrl = (partnerSalesRep.contactId != null) ? Label.PartnerPortalSiteUrl : System.URL.getSalesforceBaseURL().toExternalForm() + '';
		String taskUrl = baseUrl + '/' + taskObj.Id;
		
		ret += ' <b>For more details, click the following link: </b> <br/>';
		ret += '<a href="' + taskUrl + '">' + taskUrl  + '</a> <br/>';
		ret += '<br/>';
		ret += '<br/>';
		ret += '<p></p>';
		
		ret += 'Thank you,<br/>';
		ret += 'SunRun Operations Team';
		ret += '<p></p>';
		ret += '<p></p>';
		
		htmlBody += ret;
		//htmlBody += EmailService.getHTMLFooter2();
		htmlBody += '</html>';
		return 	htmlBody;
    }

	public static String getChangeOrderHTMLBody(Proposal__c proposalObj) {

		List<String> toAddresses = new List<String>();
		String htmlBody = '<html>';

		htmlBody += EmailService.getHTMLHeader();
		htmlBody += '<p></p>';		
		String ret = '';
		
		
		ret += '<p>Dear ' + proposalObj.Assigne__r.name  + ',</p><br/>';
		ret += '<br/>';
		ret += '<p></p>';
	
		ret += proposalObj.Homeowner_Name__c + ' has esigned the Change Order ' + proposalObj.Name + '. This change order may be ready for submission. <br/>';
		ret += '<br/>';
		
		//ret += '<font size="4" ><u> Proposal Details </u> </font> <br/>';
		//ret += '<br/>';
		//ret += '<p></p>';

		ret += '<br/>';
		ret += '<p></p>';
		
		String proposalURL = Label.PartnerPortalSiteUrl + '/' + proposalObj.Id;
		
		ret += ' <b>For more details, click the following link: </b> <br/>';
		ret += '<a href="' + proposalURL + '">' + proposalURL  + '</a> <br/>';
		ret += '<br/>';
		ret += '<br/>';
		ret += '<p></p>';
		
		ret += 'Thank you,<br/>';
		ret += 'SunRun Operations Team';
		ret += '<p></p>';
		ret += '<p></p>';
		
		htmlBody += ret;
		htmlBody += '</html>';
		return 	htmlBody;
	}

}