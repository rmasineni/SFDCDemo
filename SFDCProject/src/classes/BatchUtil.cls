public class BatchUtil {
	public static void processBatchErrors(DataBase.BatchableContext BC){
		AsyncApexJob a = [Select Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email,
							 ParentJobId, MethodName, JobType,  CompletedDate, ApexClassId 
		 from AsyncApexJob where Id =:BC.getJobId()];    
		if(a.NumberOfErrors > 0){
	        String status = (String.isEmpty(a.Status)) ? '' : a.Status;
	        status = status.toLowerCase();
	        ApexClass aC = [SELECT Id, Name FROM ApexClass WHERE Id =: a.ApexClassID];
			String className = ac.Name;
	        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
	        String[] toAddresses = new String[] {Label.BatchUserId};
	        mail.setToAddresses(toAddresses);
	        mail.setSubject('Apex Batch Job : ' + BC.getJobId() +  ' ' + status + ' with errors');
	        String textBody = 'The apex batch job ' + BC.getJobId() + ' processed '+ a.TotalJobItems + ' record(s) with '+ a.NumberOfErrors + ' failure(s). \r\n ';
	        textBody += '\r\n\t Completed Date: ' + a.CompletedDate + ' \r\n ';
	        textBody += '\t Apex Class: ' + className + ' \r\n ';
	        textBody += '\t Total Job Items: ' + a.TotalJobItems + ' \r\n ';
	        textBody += '\t Job Items Processed: ' + a.JobItemsProcessed + ' \r\n ';
			mail.setPlainTextBody(textBody);
	        try{
	        	Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
	        }
	        catch(exception e){
	        	system.debug(e);
	        }	
		}			
	}
}