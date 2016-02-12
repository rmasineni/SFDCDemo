trigger PartnerContract_SetPartnerContractFields on Partner_Contract__c (before insert, before update) {
    Integer size = 0;
    Integer counter = 0;    
    for(Partner_Contract__c contractObj: Trigger.new){
        
        if(Trigger.isUpdate){
            Partner_Contract__c oldContractObj = Trigger.oldMap.get(contractObj.Id);
            if(oldContractObj.Contract_Status__c == 'Inactive' 
                && contractObj.Contract_Status__c == oldContractObj.Contract_Status__c){
                contractObj.adderror('Inactive contracts are not allowed for modifications');
            }
        }

        if(contractObj.Terms_of_Renewal__c != null && 
            contractObj.Terms_of_Renewal__c == 'Automatic' && 
            (contractObj.Auto_Renewal_Term_months__c == null || 
            contractObj.Auto_Renewal_Term_months__c <= 0)){
            contractObj.adderror('In case of auto renewal, enter a positive integer for \'Auto Renewal Term\'');
        }  
        
        if(contractObj.Expiration_Date__c < contractObj.effective_date__c){
            contractObj.adderror('Expiration Date should be greater than Effective Date');
        }       
        
        if(contractObj.of_project_guaranteed_by__c < 0 || 
            contractObj.Auto_Renewal_Term_months__c < 0 || 
            contractObj.Days_Guaranteed_to_Subst_Completion__c < 0 ||
            contractObj.Existing_Territory_Notice__c < 0 || 
            contractObj.Length_of_Term_months__c < 0 ||
                contractObj.M1_percentage__c < 0 || 
                contractObj.M2_Percentage__c < 0 || 
                contractObj.M3_Percentage__c < 0 || 
                contractObj.New_Territory_Notice__c < 0 ||
                contractObj.Renewal_Notice_Period_days__c < 0  ){
            contractObj.adderror('Negative values are not allowed for the contract fields');
        }

        if(contractObj.Contract_Status__c != null && 
            contractObj.Contract_Status__c == 'Active' && 
            contractObj.Expiration_Date__c < date.today()){
			contractObj.adderror('Expiration date cannot be a day in past');    
        }         

        if(contractObj.contract_Number__c == null || contractObj.contract_Number__c == ''){
            size++;
        }
        
        if(contractObj.Expiration_Date__c == null){
            contractObj.Expiration_Date__c = date.parse('12/31/2099');
        }
    }
    List<String> randomNumners = null;
    if(size > 0){
        randomNumners = PRMLibrary.getUniquecontractNumbers(size);
    }
    
    for(Partner_Contract__c contractObj: Trigger.new){
        if((counter < size) && 
            (contractObj.contract_Number__c == null || contractObj.contract_Number__c == '')){
            contractObj.contract_Number__c = randomNumners[counter];
            counter++;
        }
    }
}