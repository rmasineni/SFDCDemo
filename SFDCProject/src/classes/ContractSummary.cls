public with sharing class ContractSummary {
	public String contractName {get;set;}
	
	public Proposal__c proposalObj {get;set;}
	public Account accountObj {get;set;}
	public Contact contactObj {get;set;}
	public Opportunity optyObj {get;set;}
	public Servicecontract contractObj {get;set;}
	public List<Asset__c> assets {get;set;}
	public Service_Contract_Event__c serviceContractEventObj {get;set;}
	public Account installPartner {get;set;}
	public Asset__c assetObj {get;set;}
	public String address {get;set;}
	public List<Service_Contract_Partner_Rel__c> partnerRels {get;set;}
				
	public ContractSummary(){
		contractName = '';
		initialize();
	}

	public void refresh(){
		initialize();
	}
	
	public void initialize(){
		partnerRels = new List<Service_Contract_Partner_Rel__c>();
		installPartner = new Account();
		proposalObj = new Proposal__C();
		optyObj = new Opportunity();
		initializeServiceContractEvent();
		initializeAssets();
		String contractId = ApexPages.currentPage().getParameters().get('contractId');
		
		if(contractId == null || contractId == ''){
			List<Service_Contract_Event__c> serviceContactEventList;
			List<Asset__c> assetList;
			String contractEventId = ApexPages.currentPage().getParameters().get('contractEventId');
			String assetId = ApexPages.currentPage().getParameters().get('assetId');
			if(contractEventId != null && contractEventId != ''){
				serviceContactEventList = [Select Id, Service_Contract__c from Service_Contract_Event__c where Id =:contractEventId];
				if(!serviceContactEventList.isEmpty()){
					contractId = serviceContactEventList[0].Service_Contract__c;
				}
			}
			if(assetId != null && assetId != ''){
				assetList = [Select Id, ServiceContract__c from Asset__c where Id =:assetId];
				if(!assetList.isEmpty()){
					contractId = assetList[0].ServiceContract__c;
				}				
			}
		}
		
		if(contractId == null || contractId == ''){
			
		}
		
		String query = 'SELECT ';
        query += getContractFieldsString() ;
        
        query += getProposalFieldsString() ;
        query += getOpportunityFieldsString() ;
        query += getAccountFieldsString() ;
        query += getContactFieldsString() ;
		query += getContractEventFieldsString() ;
        query += getAssetFieldsString() ;
        query += getPartnerRelFieldsString() ;
		query += ' from Servicecontract where Id =:contractId ' ;
		List<Servicecontract> serviceContractList = Database.query(query);
		if(!serviceContractList.isEmpty()){
			contractObj = serviceContractList[0];
			contractName = contractObj.Name;
			for(Service_Contract_Event__c tempContactEventObj : contractObj.Service_Contract_Events__r){
				serviceContractEventObj = tempContactEventObj;
				break;
			}

			for(Service_Contract_Partner_Rel__c partnerRelObj : contractObj.Service_Contract_Partner_Rels__r){
				if(partnerRelObj.Type__c != null && partnerRelObj.Type__c == 'Install'){
					if(partnerRelObj.Account__r != null){
						installPartner = partnerRelObj.Account__r;
					}
				}
			}

			for(Asset__c tempAssetObj : contractObj.Assets__r){
				setAsset(tempAssetObj);
			}
			
			for(Asset__c tempAssetObj : contractObj.Assets__r){
				setAsset(tempAssetObj);
			}

			contractName = contractObj.Name;
			proposalObj = (contractObj.proposal__r != null) ? contractObj.proposal__r : new Proposal__c();
			optyObj = (contractObj.Opportunity__r != null) ? contractObj.Opportunity__r : new Opportunity();
			accountObj = (contractObj.Account != null) ? contractObj.Account : new Account();
			contactObj = (contractObj.Contact != null) ? contractObj.Contact : new Contact();
			if(accountObj.Id != null){
				address = accountObj.BillingStreet + ', ';
				address += accountObj.BillingCity + ', ' + accountObj.BillingState + '  ' + accountObj.BillingPostalCode + '\r\n';
				address += accountObj.BillingCountry;
				System.debug('address: ' + address); 
			}
		}
		
	}
	
	public String getContractEventFieldsString(){
		String contractEventFields = ' , (Select ';
		Map<String, Schema.SobjectField> fieldsMap = SObjectType.Service_Contract_Event__c.fields.getMap();
		if (fieldsMap != null){
	    	for (Schema.SObjectField ft : fieldsMap.values()){               
	     	    Schema.DescribeFieldResult fd = ft.getDescribe(); 
				contractEventFields += fd.getName() + ',';
			}
			if (contractEventFields.endsWith(',')){
				contractEventFields = contractEventFields.substring(0,contractEventFields.lastIndexOf(','));
			}
	    }
	    contractEventFields += ' From Service_Contract_Events__r ) ';
		System.debug('contractEventFields: ' + contractEventFields);
		return contractEventFields;
	}

	public String getPartnerRelFieldsString(){
		String serviceContractPartnerRelFields = ' , (Select Id, Type__c, Account__r.Name From Service_Contract_Partner_Rels__r ) ';
		System.debug('serviceContractPartnerRelFields: ' + serviceContractPartnerRelFields);
		return serviceContractPartnerRelFields;		
	}


	public String getAssetFieldsString(){
		String assetFields = ' , (Select ';
		Map<String, Schema.SobjectField> fieldsMap = SObjectType.Asset__c.fields.getMap();
		if (fieldsMap != null){
	    	for (Schema.SObjectField ft : fieldsMap.values()){               
	     	    Schema.DescribeFieldResult fd = ft.getDescribe(); 
				assetFields += fd.getName() + ',';
			}
			if (assetFields.endsWith(',')){
				assetFields = assetFields.substring(0,assetFields.lastIndexOf(','));
			}
	    }
	    assetFields += ' , CreatedBy.Name From Assets__r ) ';
		System.debug('assetFields: ' + assetFields);
		return assetFields;
	}

	public String getProposalFieldsString(){
		String proposalFields = '';
		proposalFields = ', Proposal__r.Id, Proposal__r.Name, Proposal__r.Original_Proposal_ID__c, Proposal__r.Original_Proposal_ID__r.Name, Proposal__r.Customer_Signoff_Date__c, Proposal__r.Sales_Rep__c ' ;
		return proposalFields;
	}

	public String getOpportunityFieldsString(){
		String opportunityFields = '';
		opportunityFields = ', Opportunity__r.Id, Opportunity__r.Name  ';
		return opportunityFields;
	}	

	public String getAccountFieldsString(){
		String accountFields = '';
		accountFields = ', Account.Id, Account.Name, Account.ShippingStreet, Account.ShippingState, Account.ShippingPostalCode, Account.ShippingCountry, Account.ShippingCity, Account.BillingStreet, Account.BillingState, Account.BillingPostalCode, Account.BillingCountry, Account.BillingCity  ';
		accountFields += ', Account.Lot_Number__c, Account.Community__c ';
		return accountFields;
	}
	
	public String getContractFieldsString(){
		String contractFields = ' ';

		Map<String, Schema.SobjectField> fieldsMap = SObjectType.Servicecontract.fields.getMap();
		if (fieldsMap != null){
	    	for (Schema.SObjectField ft : fieldsMap.values()){   
	    		Schema.DescribeFieldResult fd = ft.getDescribe(); 
	    		if(fd.getName() == 'BillingAddress' || fd.getName() == 'ShippingAddress')
	    			continue;
				contractFields += fd.getName() + ',';
			}
			if (contractFields.endsWith(',')){
				contractFields = contractFields.substring(0,contractFields.lastIndexOf(','));
			}
	    }
		System.debug('contractFields: ' + contractFields);
				
		/*
		for(Schema.FieldSetMember f : SObjectType.Servicecontract.FieldSets.Contract_Summary_Fields.getFields()) {
			contractFields +=   ', ' + f.getFieldPath() ;
		}

		for(Schema.FieldSetMember f : SObjectType.Servicecontract.FieldSets.Partner_Payment_Details.getFields()) {
			contractFields +=   ', ' + f.getFieldPath() ;
		}

		for(Schema.FieldSetMember f : SObjectType.Servicecontract.FieldSets.Rebate_Info_Fields.getFields()) {
			contractFields +=   ', ' + f.getFieldPath() ;
		}

		for(Schema.FieldSetMember f : SObjectType.Servicecontract.FieldSets.Sales_Org_EPC_Details.getFields()) {
			contractFields +=   ', ' + f.getFieldPath() ;
		}	
		for(Schema.FieldSetMember f : SObjectType.Servicecontract.FieldSets.Grants.getFields()) {
			contractFields +=   ', ' + f.getFieldPath() ;
		}
		*/
		return contractFields;
	}
	
	public String getContactFieldsString(){
		String contactFields = '';
		contactFields = ' , Contact.Id, Contact.Name, Contact.Phone, Contact.HomePhone, Contact.email, Contact.MailingStreet,Contact.MailingState, Contact.MailingPostalCode, Contact.MailingCountry, Contact.MailingCity ';
		return contactFields;
	}
	
	public void initializeAssets(){
		assetObj = new Asset__c();
	}

	public void initializeServiceContractEvent(){
		serviceContractEventObj = new Service_Contract_Event__c();
	}
	
	public void setAsset(Asset__c assetObjVal){
		if(assetObjVal == null || assetObjVal.status__c == null 
			|| assetObjVal.status__c == 'Inactive'){
			return;
		}
		
		if(assetObjVal.Type__c == 'Asset'){
			this.assetObj = assetObjVal;
		}
	}
	
}