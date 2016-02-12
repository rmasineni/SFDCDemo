trigger trg_email_bef_ins on EmailMessage (before insert) {
	List<Case> cases = new List<Case>();
	
	String[] ids = new String[Trigger.new.size()];
	Integer i = 0;
	 Map <String, Integer> caseIdMap = new Map <String, Integer>();
	 //for (EmailMessage em : Trigger.new)
	for (Integer intPos = 0; intPos < Trigger.new.size(); intPos++)
    {
        //EmailMessage newRec = Trigger.new[intPos];
      //  if(Trigger.new[intPos].ParentId == null || Trigger.new[intPos].ParentId == '')
      //  {                
        	ids[i]=(Trigger.new[intPos].ParentId);
        	caseIdMap.put(Trigger.new[intPos].ParentId,i);
        	i++;
      //  }
           
    
    }
    for (Case insertedCase : [SELECT Case.RecordTypeId,Case.Email_Address_of_Account_Manager__c FROM Case c WHERE c.Id IN :ids])
    {
    	 RecordType partnerConcRecType = [Select Id from RecordType where Name = 'Partner Concierge' and SobjectType = 'Case'];
    	//String caseType = ;
    	String accountManagerEmail = insertedCase.Email_Address_of_Account_Manager__c; 
    	Integer index = caseIdMap.get(insertedCase.Id);
    	String textBody;
    	if(insertedCase.RecordTypeId == partnerConcRecType.Id && accountManagerEmail != null && accountManagerEmail != '')
    	{
    		    
   			if(Trigger.new[index].CcAddress != null && Trigger.new[index].CcAddress != '')
   			{
   			Trigger.new[index].CcAddress +=';' + accountManagerEmail;
   			}
   			else
   			{
   			Trigger.new[index].CcAddress = accountManagerEmail;
   			}
   			Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
   			message.setPlainTextBody(Trigger.new[index].TextBody);
  			message.setSubject(Trigger.new[index].Subject);
    		message.setToAddresses(new String[] {accountManagerEmail});  
    		Messaging.sendEmail(new Messaging.Email[] {message});
   			//textBody = Trigger.new[index].TextBody;
   			//textBody +='Test body change';
   			//Trigger.new[index].TextBody = textBody;
   		}
    }
   
}
//Case c = [Select c.Type from Case c where Id = :Trigger.new[intPos].ParentId];