@isTest (SeeAllData=true)
public class MeterRegistrationControllerTest{
	
	
	public static testMethod void testServiceContractMeterRegistration(){
		String cancelledStatus1 = 'Deal Cancelled';
		String cancelledStatus2 = 'Deal Cancelled due to credit';
		String acctName = '';
		String custRefNum = '';
		String custMailAddress = '';
		Service_Contract_Event__c scEventObj;
		
        Test_Partner_User__c testPartnerUserObj = UnitTest_ServiceContractUtil.getBlackBirdSalesRep();
        User u = [Select Id from User where ContactID != NULL and IsActive = true and Id =:testPartnerUserObj.User_Id__c  limit 1];
        System.runAs(u) {   
			Test.startTest();
			Account a = new Account(name='Test Acct1');
	        insert a;
	        
	        Opportunity oppty = new Opportunity();
	        oppty.AccountId = a.Id;
	        oppty.Name = 'NewCC Test';
	        oppty.StageName = 'Qualified';
	        oppty.CloseDate = Date.Today().addDays(18);
	        insert oppty;
	        //
			Proposal__c proposal = UnitTest_ServiceContractUtil.createProposal(oppty.Id);
			insert proposal;
			
			ApexPages.StandardController controller = new ApexPages.StandardController(proposal);
	        CreateServiceContractController serviceContractController = new CreateServiceContractController(controller);
	        PageReference page = serviceContractController.create();
	        //get object id from page reference
	        String objectId = page.getURL().right(page.getURL().length() - 1);
	        
	        ServiceContract serviceContract = [select Id, Name, Yr_1_Avoided_Power_Cost__c, Proposal__c from ServiceContract where Id = :objectId];
	        Service_Contract_Event__c scEventObjTemp = [select Id, Name, service_contract__c, NTP_Granted__c,Initial_Deposit_Amount__c,
	        										Initial_Deposit_Amount_Received__c, Initial_Deposit_Processed__c, SR_Signoff__c,
	        										Customer_Signoff__c, Complete_Deal_Received__c, Facility_Design_Approval_Requested__c,
	        										Facility_Design_Approved__c, Rebate_Conf_Rec_d__c, Final_Rebate_Amount__c
	        										from Service_Contract_Event__c where service_contract__c = :serviceContract.Id];
	        scEventObjTemp.NTP_Granted__c = Date.Today();
			scEventObjTemp.Initial_Deposit_Amount__c = 123.00;
			scEventObjTemp.Initial_Deposit_Amount_Received__c = 123.00;
	        scEventObjTemp.Initial_Deposit_Processed__c = Date.Today();
	        scEventObjTemp.SR_Signoff__c = DateTime.now();
	        scEventObjTemp.Customer_Signoff__c = DateTime.now();
        	scEventObjTemp.Complete_Deal_Received__c = Date.today();
        	scEventObjTemp.Facility_Design_Approval_Requested__c = Date.today();
        	scEventObjTemp.Facility_Design_Approved__c = Date.today();
        	scEventObjTemp.Rebate_Conf_Rec_d__c = Date.Today();
			scEventObjTemp.Final_Rebate_Amount__c = 123;
			update scEventObjTemp;
			//Insert SC
			//Insert SC Event
			//Insert Asset
			
		
        	List<Service_Contract_Event__c> scEventList = [Select Id, Service_Contract__c, Service_Contract__r.Customer_Name__c, 
        													Service_Contract__r.Cust_Ref_Num__c, Service_Contract__r.Customer_Mailing_Address__c 
        													from Service_Contract_Event__c where NTP_Granted__c != null and Asset_Status__c NOT IN (:cancelledStatus1, :cancelledStatus2) limit 1];
			
			if(scEventList != null && !scEventList.isEmpty()){
        		scEventObj = scEventList[0];
        		acctName = scEventObj.Service_Contract__r.Customer_Name__c;
        		custRefNum = scEventObj.Service_Contract__r.Cust_Ref_Num__c;
        		custMailAddress = scEventObj.Service_Contract__r.Customer_Mailing_Address__c;
			}
			
        Test.stopTest();
        	ServiceContractMeterRegistration meterRegistrationObj = new ServiceContractMeterRegistration();
	        meterRegistrationObj.acctName = acctName;
	        meterRegistrationObj.custRefNum = custRefNum;
	        meterRegistrationObj.custMailAddress = custMailAddress;
	        
	        meterRegistrationObj.doSearch();
			meterRegistrationObj.getServiceContracts();
	        meterRegistrationObj.uploadMeterRegistrationDetails();

			String filebody = 'This is a test file body';
			meterRegistrationObj.fileBody = Blob.valueof(filebody);
			meterRegistrationObj.fullPathFileName = 'testPath';
			meterRegistrationObj.uploadMeterRegistrationDetails();
	        
	        meterRegistrationObj.meterregistration();
	        
	        meterRegistrationObj.selCC = (scEventObjTemp != null) ? scEventObjTemp.Id + '' : '';
	         meterRegistrationObj.meterregistration();
			
			meterRegistrationObj.SaveMeterRegis();
			
			meterRegistrationObj.serialNumber = '2233445534';
			meterRegistrationObj.selectedSCEvent.PTO__c = Date.Today();
			meterRegistrationObj.confirmSave = false;
			meterRegistrationObj.SaveMeterRegis();

			meterRegistrationObj.confirmSave = true;
			meterRegistrationObj.SaveMeterRegis();

			meterRegistrationObj.serialNumber = '22334455';
			meterRegistrationObj.SaveMeterRegis();

			meterRegistrationObj.confirmSave = false;
			meterRegistrationObj.serialNumber = '22';
			meterRegistrationObj.SaveMeterRegis();

			meterRegistrationObj.confirmSave = true;
			meterRegistrationObj.SaveMeterRegis();
			
			
			meterRegistrationObj.serialNumber = '22334455';
			meterRegistrationObj.confirmSave = false;
			meterRegistrationObj.SaveMeterRegis();

			meterRegistrationObj.confirmSave = true;
			meterRegistrationObj.SaveMeterRegis();
			
			meterRegistrationObj.selectedSCEvent.PTO__c = null;
			meterRegistrationObj.confirmSave = false;
			meterRegistrationObj.serialNumber = '1234';
			meterRegistrationObj.SaveMeterRegis();
			
			meterRegistrationObj.confirmSave = true;
			meterRegistrationObj.SaveMeterRegis();

			meterRegistrationObj.serialNumber = '23456767';
			meterRegistrationObj.SaveMeterRegis();

			meterRegistrationObj.confirmSave = true;
			meterRegistrationObj.serialNumber = '23456767';
			meterRegistrationObj.SaveMeterRegis();
			
			meterRegistrationObj.processDuplicateSerialNumber();
			meterRegistrationObj.getMeterType();
            
			meterRegistrationObj.batchUpload();
			meterRegistrationObj.back();
			
			ServiceContractMeterRegistration.ServiceContractEventWrapper wrapperObj = new ServiceContractMeterRegistration.ServiceContractEventWrapper();
			Boolean isSelected = wrapperObj.selected;
			Service_Contract_Event__c scEventObjTemp2 = wrapperObj.scEventObj;
			List<Asset__c> assetList = wrapperObj.assetList;
			
			meterRegistrationObj.first();
			meterRegistrationObj.last();
			meterRegistrationObj.previous();
			meterRegistrationObj.next();
		}
		
  	}
        

}