@istest
public class Unit_NetExamWebServiceAPIHelper7 {

	static testmethod void testContact(){
		Account accountObj1 = TestPRMLibrary.insertAccount('NetExamPartnerAccount1', PRMLibrary.PARTNER);
		accountObj1.IsPartner = true;
		//accountObj1.ParentId = contactObj1.AccountId;
		accountObj1.Stage__c = 'Confirmed';
		accountObj1.BillingState = 'CA';
		accountObj1.BillingCountry = 'USA';
		accountObj1.BillingPostalCode = '94116';
		update accountObj1;	

		//Create Contact
		Contact contactObj1 = TestPRMLibrary.insertContact('PRMTestAccountExpired1',
															PRMLibrary.PARTNER, 
															'PRMTestExpiredLastName1',
															'prmcontactExpired1@gmail.com');

		
        contactObj1.AccountId = accountObj1.Id;
        contactObj1.FirstName = 'NetExamPortalUserF331';
        contactObj1.lastname = 'NetExamPortalUserL331';
        //contactObj1.email = 'NetExamPortalUserL331@gmail.com';
        contactObj1.title = 'Title-1';
        contactObj1.Job_Function__c = 'Analyst';
        contactObj1.role__C = 'Executive';
		
		contactObj1.AccountId = accountObj1.Id;
		contactObj1.firstname = 'TestContact11';
		contactObj1.Sells_Sunrun__c = 'Yes';
		contactObj1.Sells_in_CA__c = 'Yes';
		contactObj1.Application_Submitted__c = date.today().addDays(2);
		contactObj1.Sells_Sunrun__c = 'Yes';
		contactObj1.e_sign_documents_access__c = 'Requested';
		contactObj1.Can_Run_Change_Orders__c = 'Requested';
		contactObj1.Proposal_Tool_Access__c = 'Requested';
		contactObj1.Design_Tool_Access__c = 'Requested';
		contactObj1.Application_Status__c = 'Submitted';
		contactObj1.active__C = true;
		update 	contactObj1;

		contactObj1.active__C = false;
		update 	contactObj1;		
		
	}

	static testmethod void testAccount(){
		Account accountObj1 = TestPRMLibrary.insertAccount('NetExamPartnerAccount1', PRMLibrary.PARTNER);

		//Create Contact
		Contact contactObj1;
		List<Contact> contactlist = new List<Contact>();

		System.debug('accountObj1: ' + accountObj1);
		for(Integer counter =0; counter < 7; counter++){
			contactObj1 = new Contact();
			Id contactRecordTypeId = TestPRMLibrary.getRecordTypeId(PRMLibrary.PARTNER, 'Contact');
			contactObj1.AccountId = accountObj1.Id;
			contactObj1.RecordTypeId = contactRecordTypeId;
			contactObj1.email = 'prmcontactExpired'+ counter + '@gmail.com';
	        contactObj1.AccountId = accountObj1.Id;
	        contactObj1.FirstName = 'NetExamPortalUserF33' + counter;
	        contactObj1.lastname = 'NetExamPortalUserL332'+ counter;
	        contactObj1.title = 'Title-1';
	        contactObj1.Job_Function__c = 'Analyst';
	        contactObj1.role__C = 'Executive';
			contactObj1.Sells_Sunrun__c = 'Yes';
			contactObj1.Sells_in_CA__c = 'Yes';
			contactObj1.Application_Submitted__c = date.today().addDays(2);
			contactObj1.Sells_Sunrun__c = 'Yes';
			contactObj1.e_sign_documents_access__c = 'Requested';
			contactObj1.Can_Run_Change_Orders__c = 'Requested';
			contactObj1.Proposal_Tool_Access__c = 'Requested';
			contactObj1.Design_Tool_Access__c = 'Requested';
			contactObj1.Application_Status__c = 'Submitted';
			
			contactlist.add(contactObj1); 
		}
		//contactObj1.active__C = false;
		insert 	contactlist;


		contactObj1.active__C = false;
		update 	contactObj1;

		accountObj1.IsPartner = true;
		//accountObj1.ParentId = contactObj1.AccountId;
		accountObj1.Stage__c = 'Confirmed';
		accountObj1.BillingState = 'CA';
		accountObj1.BillingCountry = 'USA';
		accountObj1.BillingPostalCode = '94116';
		update accountObj1;

		
		boolean result = false;
		Contact contactObj = contactlist[1];
		contactObj.firstname = contactlist[0].firstname;
		contactObj.lastName = contactlist[0].lastName;
		contactObj.email = contactlist[0].email;
		
		contactObj.sells_sunrun__c = 'No';
		LMSInfoManager.hasCertificationProfileModified(contactlist[0], contactObj);	
		contactObj.Job_Function__c = 'Analyst1';
		LMSInfoManager.hasCertificationProfileModified(contactlist[0], contactObj);					
		contactObj.email = 'testemail@gmail.com';
		LMSInfoManager.hasCertificationProfileModified(contactlist[0], contactObj);
		contactObj.lastName = 'test1';
		LMSInfoManager.hasCertificationProfileModified(contactlist[0], contactObj);	
	}

	
}