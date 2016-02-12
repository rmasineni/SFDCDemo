trigger trg_email_aftr_ins on EmailMessage (after insert) {
 List<Case> cases = new List<Case>();    
    
    String[] caseIds = new String[Trigger.new.size()];
    Boolean[] emailTypes = new Boolean[Trigger.new.size()];
    Set <Id> parentCaseIds = new Set <Id>();
    Set <Id> lastUpdateOnCaseIds = new Set <Id>();
    
    for(Integer i = 0;i<Trigger.new.size();i++)
    {      
        if (System.Trigger.isInsert)
        {
            caseIds[i] = Trigger.new[i].ParentId;           
            emailTypes[i] = Trigger.new[i].Incoming; 
          
            if (Trigger.new[i].Incoming == false ){
            	parentCaseIds.add(Trigger.new[i].ParentId);
            }            
        }    
                
    }    
    
    if (parentCaseIds.size() > 0)
    {
	try
	{
    for(Case caseRec:[Select Id,First_Response_Date_Time__c,First_Response_Updated__c,Last_Response_Date_Time__c from Case where Id in:parentCaseIds])
    {                
        
        //Integer index = indexOf(caseIds,caseRec.Id);
        
        if(caseRec.First_Response_Updated__c == true)
        {
        caseRec.Last_Response_Date_Time__c = DateTime.now();
        }
        else if(caseRec.First_Response_Updated__c == false)
        {
        caseRec.First_Response_Date_Time__c = DateTime.now();
        caseRec.First_Response_Updated__c = true;
        caseRec.Last_Response_Date_Time__c = DateTime.now();
        }
        cases.add(caseRec);      
    }
    
    update cases;    
    }
    catch(exception ex)
    {
        System.debug('Exception occured '+ ex.getMessage());    
    }
}
}