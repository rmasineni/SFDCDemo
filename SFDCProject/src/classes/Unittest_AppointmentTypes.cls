@isTest(SeeAllData=true)
public class Unittest_AppointmentTypes {

	public static testMethod void testGETApptTypesForFSD(){
		
		Account a = new Account(name ='TEST ACCOUNT',Type = 'partner');
		insert a;
		Contact con = new Contact(FirstName = 'TestAcct',LastName = 'TestAcctOppty',Email = 'emailfake@fakeemail.net',AccountId = a.Id);
		insert con;
		Case cs;
		cs = new case (Status ='Open',Reason='Customer');  

		List<Case> caselist=new List<Case>();
		caselist.add(cs);

		insert caselist;  
	
		ServiceContract sc = new ServiceContract(AccountId=a.Id,Name='service test');
		insert sc;
		
		FS_Dispatch__c fsd = new FS_Dispatch__c(FS_Parent_Case__c=cs.Id,FS_Dispatch_State__c='new',FS_Approve_Findings__c = true,FS_Service_Contract__c=sc.Id);
		insert fsd;
		
        ApexPages.StandardController controller = new ApexPages.StandardController(fsd);
        AppointmentTypes apptTypesObj = new AppointmentTypes(controller);
        apptTypesObj.getApptTypes();
        apptTypesObj.showScheduler();
    }
	
    public static testMethod void testGETApptTypesForOpportunity(){
		
        Account accountObj = TestPRMLibrary.insertAccount('Test Acc123', 'Residential');
        Contact primaryContact = TestPRMLibrary.insertContact(accountObj.Id, 'Residential', 'firstName'+ '-1', 'lastName'+'-1', 'first.' + 'customerEmail@yopmail.com');
        Contact secondaryContact = TestPRMLibrary.insertContact(accountObj.Id, 'Residential', 'firstName'+ '-2', 'lastName'+'-2', 'second.' + 'customerEmail@yopmail.com');
        Opportunity oppotyObj=new Opportunity();
		oppotyObj.channel_2__c='Retail';
		oppotyObj.Lead_Source_2__c='Costco';
		oppotyObj.accountid=accountObj.id;
		oppotyObj.external_id__c='123456';
		oppotyObj.name='TESt';
		oppotyObj.stageName='Open';
		insert oppotyObj;
		
        ApexPages.StandardController controller = new ApexPages.StandardController(oppotyObj);
        AppointmentTypes apptTypesObj = new AppointmentTypes(controller);
        apptTypesObj.getApptTypes();
        apptTypesObj.showScheduler();
    }
    

}