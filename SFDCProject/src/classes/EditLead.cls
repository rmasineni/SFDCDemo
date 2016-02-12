public with sharing class EditLead {
    public string title{get;set;}
    private string fieldSetName {get;set;}
    public string sectionName{get;set;}
    public String retURL = '';  
    public Lead leadObj {get;set;}
    
    Public EditLead(ApexPages.StandardController controller){
        try{
            leadObj = (Lead) controller.getRecord();
            initialize();           
        }catch(Exception exceptionObj){
            String errorMessage = exceptionObj.getMessage();
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,errorMessage));
        }
    }
    
    public void initialize(){
        title = 'New Lead';
        retURL = ApexPages.currentPage().getParameters().get('retURL');
        String recordTypeId = '';
        if(leadObj != null && leadObj.RecordTypeId != null){
            recordTypeId = leadObj.RecordTypeId;            
        }else{
            recordTypeId = ApexPages.currentPage().getParameters().get('RecordType');
            if(recordTypeId != null){
                leadObj.RecordTypeId = recordTypeId;
            }
        }
        if(recordTypeId == null || recordTypeId == ''){
            //recordTypeId = getDefaultRecordTypeId();
        }

        Map<Id,Schema.RecordTypeInfo> rtMapByName = Schema.SObjectType.Lead.getRecordTypeInfosByID();
        //Schema.RecordTypeInfo recordTypeObj =  rtMapByName.get(recordTypeId);
        
        if(leadObj != null && leadObj.Id != null){
            initializeLeadObj(leadObj.Id);
            title=leadObj.name;
        }
        System.debug('leadObj: ' + leadObj);
    }
    
    private void initializeLeadObj(Id leadId){
        String query = 'SELECT Id, FirstName, lock_assignment__c,lastName,name,Lead_Assignment_Control_Field__c, company, Street , City, State, postalCode, country, Alternate_Phone__c, Phone, Email, Address_Standardization_Status__c, Latitude__c, Longitude__c FROM Lead where Id =:leadId ';       
        Lead tempLeadObj = Database.query(query);
        leadObj = tempLeadObj;
    }

    public Id getDefaultRecordTypeId(){
        Id defaultRecordTypeId;
        Schema.DescribeSObjectResult dsr = Lead.SObjectType.getDescribe();
        Schema.RecordTypeInfo defaultRecordType;
        for(Schema.RecordTypeInfo rti : dsr.getRecordTypeInfos()) {
            if(rti.isDefaultRecordTypeMapping()) {
                defaultRecordType = rti;
                defaultRecordTypeId = defaultRecordType.getRecordTypeId();
            }
        }
        return defaultRecordTypeId;
    }
    
    //public PageReference save() {
    //  leadObj.Company = leadObj.LastName + ',' + leadObj.FirstName;
    //  if(leadObj.Id == null){
    //      leadObj.Lock_Assignment__c = true;
    //  }
    //  upsert leadObj;
    //  PageReference ref = null;
    //  String editURL = '/' + leadObj.Id;
    //  // + '&nooverride=1';
    //  ref = new PageReference(editURL);
    //  ref.setRedirect(true);
   //     return ref;
    //}
        
    public void leadValidations(){
        if(leadObj.FirstName == null || leadObj.FirstName == ''){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'Enter First Name'));
        }

        if(leadObj.lastName == null || leadObj.lastName == ''){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'Enter Last Name'));
        }

                if((leadObj.email == null || leadObj.email == '') && ((leadObj.Phone == null || leadObj.Phone == ''))){
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'Enter Email OR Phone'));
                }

                //if(leadObj.Phone == null || leadObj.Phone == ''){
                //      ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'Enter Phone'));
                //}     
    }
        
    public PageReference continueLeadEdit() {
        PageReference ref = null;
        try{
            leadObj.Company = leadObj.LastName + ',' + leadObj.FirstName;
            if(leadObj.Id == null){
                leadObj.Lead_Assignment_Control_Field__c = true;
            }
            leadValidations();
            
            if(ApexPages.getMessages() != null && !ApexPages.getMessages().isEmpty()){
                return ref;
            }
                        
            upsert leadObj;
            
            String editURL = '/' + leadObj.Id + '/e?retURL=' +  '/' + leadObj.Id+ '&nooverride=1';
            ref = new PageReference(editURL);
            ref.setRedirect(true);
        
        }catch(Exception exceptionObj){                
            String errorMessage = exceptionObj.getMessage();                         
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,errorMessage));
        	}
        	/*        	
            String errorMessage = exceptionObj.getMessage();
            Set<string> errorMessages=new Set<String>();
            Boolean errorReached=false;
            for(Skip_Error_Messages__c skipError:Skip_Error_Messages__c.getAll().values()){
            	errorMessages.add(skipError.Error_Message__c);
            	 system.debug('---Print error match'+errorMessage.contains(skipError.Error_Message__c));
            	 if(errorMessage.contains(skipError.Error_Message__c)){
            	 	errorReached=true;
            	 }
            }  
            if(!errorReached){          
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,errorMessage));
            }
            else{
            String editURL = '/' + leadObj.Id + '/e?retURL=' +  '/' + leadObj.Id+ '&nooverride=1';
            ref = new PageReference(editURL);
            ref.setRedirect(true);	
            }
            */
        return ref;        
    }
    
    public PageReference saveLead() {
        PageReference ref = null;
        try{
            leadObj.Company = leadObj.LastName + ',' + leadObj.FirstName;
            if(leadObj.Id == null){
                leadObj.Lead_Assignment_Control_Field__c = true;
            }
            leadValidations();
            
            if(ApexPages.getMessages() != null && !ApexPages.getMessages().isEmpty()){
                return ref;
            }            
            upsert leadObj;           
            
            String editURL = '/' + leadObj.Id  + '?retURL=' +  retURL + '&nooverride=1';
            ref = new PageReference(editURL);
            ref.setRedirect(true);
        
        }catch(Exception exceptionObj){         
            String errorMessage = exceptionObj.getDMLMessage(0);                        
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,errorMessage));
        }
        return ref;     
    }

}