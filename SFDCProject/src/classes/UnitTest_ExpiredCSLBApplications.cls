@isTest	
public class UnitTest_ExpiredCSLBApplications {

	private static testMethod void TestExpiredCSLBApplicationsBatch(){
		//Insert contacts with different expirtation dates
		Contact contactObj1 = TestPRMLibrary.insertContact('PRMTestAccountExpired1',
															PRMLibrary.PARTNER, 
															'PRMTestExpiredLastName1',
															'prmcontactExpired1@gmail.com');

		contactObj1.Sells_Sunrun__c = 'Yes';
		contactObj1.Sells_in_CA__c = 'Yes';
		contactObj1.Application_Submitted__c = date.today().addDays(-92);
		contactObj1.Sells_Sunrun__c = 'Yes';
		contactObj1.e_sign_documents_access__c = 'Requested';
		contactObj1.Can_Run_Change_Orders__c = 'Requested';
		contactObj1.Proposal_Tool_Access__c = 'Requested';
		contactObj1.Design_Tool_Access__c = 'Requested';
		update 	contactObj1;

		Contact_ExpiredCSLBApplicationsBatch batchJob = new Contact_ExpiredCSLBApplicationsBatch();
		id batchinstanceid = database.executeBatch(batchJob);   
	}

	static testmethod void TestExpiredCSLBApplicationsScheduler(){// for code coverage only
        Contact_ExpiredCSLBApplicationsScheduler  schedule = new Contact_ExpiredCSLBApplicationsScheduler();
        schedule.execute(null); 
    }

	private static testMethod void TestCSLBApplicationsBatch1(){
		List<Contact> contactObjectsList = new List<Contact>();
		//Insert contacts with different expirtation dates
		Contact contactObj1 = TestPRMLibrary.insertContact('PRMTestAccountCSLBApp1',
															PRMLibrary.PARTNER, 
															'PRMTestCSLBAppLastName1',
															'prmcontactCSLB1@gmail.com');

		contactObj1.Sells_Sunrun__c = 'Yes';
		contactObj1.Sells_in_CA__c = 'Yes';
		contactObj1.Application_Submitted__c = date.today();
		contactObj1.Sells_Sunrun__c = 'Yes';
		contactObj1.e_sign_documents_access__c = 'Requested';
		contactObj1.Can_Run_Change_Orders__c = 'Requested';
		contactObj1.Proposal_Tool_Access__c = 'Requested';
		contactObj1.Design_Tool_Access__c = 'Requested';
		contactObj1.Application_Status__c = 'Submitted';
		contactObjectsList.add(contactObj1);

		Contact contactObj2 = TestPRMLibrary.insertContact('PRMTestAccountCSLBApp2',
															PRMLibrary.PARTNER, 
															'PRMTestCSLBAppLastName2',
															'prmcontactCSLB2@gmail.com');

		contactObj2.Sells_Sunrun__c = 'Yes';
		contactObj2.Sells_in_CA__c = 'Yes';
		contactObj2.Application_Submitted__c = date.today().adddays(-60);
		contactObj2.Sells_Sunrun__c = 'Yes';
		contactObj2.e_sign_documents_access__c = 'Requested';
		contactObj2.Can_Run_Change_Orders__c = 'Requested';
		contactObj2.Proposal_Tool_Access__c = 'Requested';
		contactObj2.Design_Tool_Access__c = 'Requested';
		contactObj2.Application_Status__c = 'Submitted';
		contactObjectsList.add(contactObj2);		

		Contact contactObj3 = TestPRMLibrary.insertContact('PRMTestAccountCSLBApp3',
															PRMLibrary.PARTNER, 
															'PRMTestCSLBAppLastName3',
															'prmcontactCSLB3@gmail.com');

		contactObj3.Sells_Sunrun__c = 'Yes';
		contactObj3.Sells_in_CA__c = 'Yes';
		contactObj3.Application_Submitted__c = date.today().adddays(-60);
		contactObj3.Sells_Sunrun__c = 'Yes';
		contactObj3.e_sign_documents_access__c = 'Requested';
		contactObj3.Can_Run_Change_Orders__c = 'Requested';
		contactObj3.Proposal_Tool_Access__c = 'Requested';
		contactObj3.Design_Tool_Access__c = 'Requested';
		contactObj3.Application_Status__c = 'Submitted';
		contactObjectsList.add(contactObj3);

		update 	contactObjectsList;

		Contact_CSLBApplicationsBatch batchJob = new Contact_CSLBApplicationsBatch();
		id batchinstanceid = database.executeBatch(batchJob);   
	}

	private static testMethod void TestCSLBApplicationsBatch2(){
		List<Contact> contactObjectsList = new List<Contact>();

		Contact contactObj4 = TestPRMLibrary.insertContact('PRMTestAccountCSLBApp4',
															PRMLibrary.PARTNER, 
															'PRMTestCSLBAppLastName4',
															'prmcontactCSLB4@gmail.com');

		contactObj4.Sells_Sunrun__c = 'Yes';
		contactObj4.Sells_in_CA__c = 'Yes';
		contactObj4.Application_Submitted__c = date.today().adddays(-75);
		contactObj4.Sells_Sunrun__c = 'Yes';
		contactObj4.e_sign_documents_access__c = 'Requested';
		contactObj4.Can_Run_Change_Orders__c = 'Requested';
		contactObj4.Proposal_Tool_Access__c = 'Requested';
		contactObj4.Design_Tool_Access__c = 'Requested';
		contactObj4.Application_Status__c = 'Submitted';
		contactObjectsList.add(contactObj4);

		Contact contactObj5 = TestPRMLibrary.insertContact('PRMTestAccountCSLBApp5',
															PRMLibrary.PARTNER, 
															'PRMTestCSLBAppLastName5',
															'prmcontactCSLB5@gmail.com');

		contactObj5.Sells_Sunrun__c = 'Yes';
		contactObj5.Sells_in_CA__c = 'Yes';
		contactObj5.Application_Submitted__c = date.today().adddays(-83);
		contactObj5.Sells_Sunrun__c = 'Yes';
		contactObj5.e_sign_documents_access__c = 'Requested';
		contactObj5.Can_Run_Change_Orders__c = 'Requested';
		contactObj5.Proposal_Tool_Access__c = 'Requested';
		contactObj5.Design_Tool_Access__c = 'Requested';
		contactObj5.Application_Status__c = 'Submitted';
		contactObjectsList.add(contactObj5);

		Contact contactObj6 = TestPRMLibrary.insertContact('PRMTestAccountCSLBApp6',
															PRMLibrary.PARTNER, 
															'PRMTestCSLBAppLastName6',
															'prmcontactCSLB6@gmail.com');

		contactObj6.Sells_Sunrun__c = 'Yes';
		contactObj6.Sells_in_CA__c = 'Yes';
		contactObj6.Application_Submitted__c = date.today().adddays(-89);
		contactObj6.Sells_Sunrun__c = 'Yes';
		contactObj6.e_sign_documents_access__c = 'Requested';
		contactObj6.Can_Run_Change_Orders__c = 'Requested';
		contactObj6.Proposal_Tool_Access__c = 'Requested';
		contactObj6.Design_Tool_Access__c = 'Requested';
		contactObj6.Application_Status__c = 'Submitted';
		contactObjectsList.add(contactObj6);
		update 	contactObjectsList;

		Contact_CSLBApplicationsBatch batchJob = new Contact_CSLBApplicationsBatch();
		id batchinstanceid = database.executeBatch(batchJob);   
	}



	static testmethod void TestCSLBApplicationsScheduler(){// for code coverage only
        Contact_CSLBApplicationsScheduler  schedule = new Contact_CSLBApplicationsScheduler();
        schedule.execute(null); 
    }

}