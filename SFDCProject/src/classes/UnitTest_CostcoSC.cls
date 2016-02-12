@istest(seealldata=true)
public with sharing class UnitTest_CostcoSC {
	 static testmethod void testMethod1(){
		String partnerAccountId = PartnerDetail__c.getValues('ApexTestAccount').PartnerAccountId__C;
		String salesRepEmail = PartnerDetail__c.getValues('ApexTestAccount').PartnerContactEmail__C;
		Proposal__C proposalObj = new Proposal__C();
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
        proposalObj.Name = 'P124124123-I';
        proposalObj.Opportunity__c = oppotyObj.Id;
        proposalObj.Upfront_Payment__c = 1000;
        proposalObj.Proposal_ID__c = 23532;
        proposalObj.System_Size_STC_DC__c = 23;
        proposalObj.Mode_Name__c = 'Mode-1';
        proposalObj.Date_Issued__c =  date.today();
        proposalObj.Sales_Rep_Email__c = salesRepEmail; 
        proposalObj.Sales_Partner__c = partnerAccountId;
        proposalObj.Install_Partner__c = partnerAccountId;
        proposalObj.EDP_Phase__c = 'EDP Phase-1';
        proposalObj.stage__c = EDPUtil.SR_OPS_APPROVED;
        insert proposalObj;
        ServiceContract sc = new ServiceContract();
        sc.accountId = accountObj.Id;
        sc.Proposal__c = proposalObj.id;
        sc.Opportunity__c = oppotyObj.Id;
        sc.ContactId=primaryContact.id;
        insert sc;
        Service_contract_event__c sce=new Service_contract_event__c();
        sce.service_contract__c=sc.id;
        //sce.Customer_s_Email__c='TEST@yopmail.com';
        //sce.Sales_Rep_Email__c='TEST@yopmail.com';
        insert sce;
          
           Test.startTest();
       		 sce.Commencement_of_Construction__c=system.today();
        	 sce.Completion_of_Construction__c=system.today();
       		 update sce;
       		 List<Service_Contract_Event__c> sceToBeUpdated = new List<Service_Contract_Event__c>();
       		 sceToBeUpdated.add(sce);
       		 BaseClass bas=new BaseClass();
       		 bas.enqueueJobWithCheck(new CostcoLeadUpdateInstallInfoJob(bas.getUniqueIdList(sceToBeUpdated)));
           Test.stopTest();
          
        /*
        ApexPages.StandardController controller = new ApexPages.StandardController(proposalObj);
       CreateServiceContractController serviceContractController = new CreateServiceContractController(controller);
       PageReference page = serviceContractController.create();
       //get object id from page reference
       String objectId = page.getURL().right(page.getURL().length() - 1);
       
       Set<Id> contractIds = new Set<Id>();
       contractIds.add(objectId);
       Map<Id, ServiceContract> contractMap = ServiceContractUtil.getServiceContractMap(contractIds);
       ServiceContract scObj = contractMap.get(objectId);  
       if(scObj.Service_Contract_Events__r != null && !scObj.Service_Contract_Events__r.isEmpty()){
           Service_contract_event__c scEventObj = scObj.Service_Contract_Events__r[0];
           Test.startTest();
       		 scEventObj.Commencement_of_Construction__c=system.today();
        	 scEventObj.Completion_of_Construction__c=system.today();
       		 update scEventObj;
           Test.stopTest();
       }  
        //Service_contract_event__c sce=new 
        //Service_contract_event__c sce=[select id,Commencement_of_Construction__c,Completion_of_Construction__c,service_contract__r.opportunity__r.external_id__c,lead_source__c from Service_contract_event__c where Service_Contract__c=:sc.id];
        //sce.Commencement_of_Construction__c=system.today();
        //sce.Completion_of_Construction__c=system.today();
        */
		
	}
}