/* 
** Class: PartnerContractsManager
** Author: Raghavendra Masineni
** 
**
*/

public class PartnerContractsManager {

	public List<Partner_Contract__c> expiredContracts;
	public List<Partner_Contract__c> renewedContracts ;
	public List<Partner_Contract__c> contractsExpiresAfter30Days;
	public List<Partner_Contract__c> autoRenewalContractsAfter30Days ;
	public List<String> autorenewalErrors ;
	public List<PRMLibrary.ErrorDescription> contractsUpdateResult;
	private Map<Id, Partner_Contract__c> oldToNewContractMap;
	public Boolean testing = false;

	public PartnerContractsManager(){	
		oldToNewContractMap = new Map<Id, Partner_Contract__c>();

		expiredContracts = new List<Partner_Contract__c>();
		renewedContracts = new List<Partner_Contract__c>();
		contractsExpiresAfter30Days = new List<Partner_Contract__c>();
		autoRenewalContractsAfter30Days = new List<Partner_Contract__c>();
		autorenewalErrors = new List<String>();
		contractsUpdateResult = new List<PRMLibrary.ErrorDescription> ();	
	} 
	
    // Returns a dynamic SOQL statement for the whole object, includes only creatable 
    //fields since we will be inserting a cloned result of this query 
    private string getCreatableFieldsSOQL(String objectName){
        String selects = '';
        String soqlQuery = '';
        
        // Get a map of field name and field token
        Map<String, Schema.SObjectField> fMap = Schema.getGlobalDescribe().get(objectName.toLowerCase()).getDescribe().Fields.getMap();
        list<string> selectFields = new list<string>();
        if (fMap != null){
            for (Schema.SObjectField ft : fMap.values()){ // loop through all field tokens (ft)
                Schema.DescribeFieldResult fd = ft.getDescribe(); // describe each field (fd)
                if (fd.isCreateable()){ // field is creatable
                    selectFields.add(fd.getName());
                }
            }
        }
        if (!selectFields.isEmpty()){
            for (string s:selectFields){
                selects += s + ',';
            }
            if (selects.endsWith(',')){selects = selects.substring(0,selects.lastIndexOf(','));}
        }       
        soqlQuery = 'SELECT Id, ' + selects + ' FROM ' + objectName;
        return soqlQuery;
    }
 
     public String getContractSOQLQuery(String accountFilter){
     	String whereClause = ' Contract_Status__c = \'Active\' ' ; 
        if(testing == false){
        	whereClause += ' AND (Expiration_Date__c < :todayDate  OR Expiration_Date__c =  :dateObj)' ;
        }

		String soqlQuery = getCreatableFieldsSOQL('Partner_Contract__c') ;
				soqlQuery +=  ' WHERE ' + whereClause;  

 		if(accountFilter != null && accountFilter != ''){
			soqlQuery += ' AND ' + accountFilter;
		}

        return  soqlQuery;
    }
    
	public void processContracts(List<Partner_Contract__c> partnerContractList){
		System.debug('partnerContractList: ' + partnerContractList);
		Date dateObj30days = date.today().adddays(30);
		Date todayObj = date.today();
		List<Partner_Contract__c> expiredContracts = new List<Partner_Contract__c>();
		for(Partner_Contract__c contractObj :partnerContractList ){
			if(contractObj.Expiration_Date__c == dateObj30days){
				if(contractObj.Terms_of_Renewal__c == 'Automatic' && 
            		contractObj.Auto_Renewal_Term_months__c > 0 ){
					autoRenewalContractsAfter30Days.add(contractObj);           		
            	}else{
					contractsExpiresAfter30Days.add(contractObj);  
            	}			
			}else if(contractObj.Expiration_Date__c <= todayObj){
				expiredContracts.add(contractObj);			
			}else if(testing){
				expiredContracts.add(contractObj);	
			}
		}
		
		if(expiredContracts.size() > 0){
			processExpiredAutoRenewalContracts(expiredContracts);
		}
	}

  
    public  void processExpiredAutoRenewalContracts(List<Partner_Contract__c> partnerContractList){
        List<Partner_Contract__c> clonedContracts = new List<Partner_Contract__c>();
        for(Partner_Contract__c contractObj :partnerContractList ){
 
            if(contractObj.Terms_of_Renewal__c == 'Automatic' && 
            	contractObj.Auto_Renewal_Term_months__c > 0 ){
				Partner_Contract__c cloneObj = contractObj.clone();
				cloneObj.contract_number__c = '';
            	Integer renewalMonths = contractObj.Auto_Renewal_Term_months__c.intValue();
				cloneObj.Effective_Date__c = contractObj.Expiration_Date__c.adddays(1);
            	cloneObj.Expiration_Date__c = contractObj.Expiration_Date__c.addMonths(renewalMonths);
            	contractObj.Contract_Status__c = 'Active';
				clonedContracts.add(cloneObj);
				oldToNewContractMap.put(contractObj.Id, cloneObj);
			}
            contractObj.Contract_Status__c = 'Inactive';
        }

		Set<Id> updatedContractIds = new Set<Id>();
        if(partnerContractList.size() > 0 ){
			Database.Saveresult[] contractsUpdateResult = Database.update(partnerContractList, false);
			for(Database.SaveResult sr:contractsUpdateResult){
			   if(sr.isSuccess()){
					updatedContractIds.add(sr.Id);			   
			   }else{
					if(sr.getErrors()[0] != null){
						String errormessage = (sr.getErrors()[0] == null) ? '' : sr.getErrors()[0].getMessage();
						addContractUpdatError(sr.Id, errormessage);
					}
			   }
			}		      	
        }
		
		Set<Id> newContractIds = new Set<Id>();
		if(oldToNewContractMap.size() > 0 ){
			Database.Saveresult[] contractsInsertResult = Database.insert(oldToNewContractMap.values(), false);
			for(Database.SaveResult sr:contractsInsertResult){
			   if(sr.isSuccess()){
			   		newContractIds.add(sr.Id);
			   }else{
					if(sr.getErrors()[0] != null){
						autorenewalErrors.add(sr.getErrors()[0].getMessage());
					}
			   }
			}
			
		}  	
		getModifiedContracts(newContractIds, updatedContractIds);     
    }

	private void getModifiedContracts(Set<Id> newContractIds, Set<Id> updatedContractIds){
		Set<Id> contractIds = new Set<Id>();
		contractIds.addall(newContractIds);
		contractIds.addall(updatedContractIds);
		for(Partner_Contract__c contractObj: [Select Id, Sign_Date__c, expiration_date__c, 
												Effective_Date__c, Terms_of_Renewal__c, Contract_Status__c,
												Contract_Number__c, Auto_Renewal_Term_months__c 
												from  Partner_Contract__c WHERE Id in :contractIds]){
			if(newContractIds.contains(contractObj.Id)){
				renewedContracts.add(contractObj);								
			}else if(updatedContractIds.contains(contractObj.Id)){
				expiredContracts.add(contractObj);				
			}			
		}
	}

	public void addContractUpdatError(String contractNumber, String errorMessage){
		contractsUpdateResult.add(new PRMLibrary.ErrorDescription(contractNumber, errorMessage));
	}

	
	public void sendSuccessEmail(List<String> toAddresses, String batchJobId, AsyncApexJob apexJob){
	
		Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
		mail.setSenderDisplayName('SunRun Salesforce Admin');
		mail.setToAddresses(toAddresses);
		mail.setSubject('Contract Summary');
		String htmlMsgBody = '';
		
		if(apexJob != null && apexJob.NumberOfErrors > 0){
			htmlMsgBody = 	EmailService.getHTMLErrorBody(
							batchJobId, apexJob.ExtendedStatus);
		}else{
			htmlMsgBody =	EmailService.getHTMLBody(
									batchJobId,
									renewedContracts,
									expiredContracts,
									autoRenewalContractsAfter30Days,
									contractsExpiresAfter30Days,
									contractsUpdateResult,
									autorenewalErrors);
		}
		
		mail.setHTMLBody(htmlMsgBody);			
		Messaging.SingleEmailMessage[] theEmails = new List<Messaging.SingleEmailMessage>();
		theEmails.add(mail);
		Messaging.Email[] allMails = new List<Messaging.Email>();
		for( Integer j = 0; j < theEMails.size(); j++ ){
			allMails.add(theEMails.get(j));
		}	
		Messaging.SendEmailResult[] results = Messaging.sendEmail( allMails );

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
}