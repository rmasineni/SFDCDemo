global class Batch_DeleteContact implements Database.Batchable<sObject>,Database.stateful {
  
  //Variable to count Success and Error Records
    public Integer successCounter = 0;
    public Integer failureCounter = 0; 
         
    //Start Method 
    global Database.QueryLocator start(Database.BatchableContext BC) { 
    
        //Query to Fetch Records
        if(Test.isRunningtest()) 
            return Database.getQueryLocator([SELECT ID FROM Contact where Mark_for_Delete__c= True limit 1]);
        else
            return Database.getQueryLocator([SELECT ID FROM Contact where Mark_for_Delete__c= True]);
   
    }
    
    //Execute Method
    global void  execute(Database.BatchableContext BC, List<Contact> scope) {
      
    //Delete the Records those are in Contexts
        Database.DeleteResult[] delresults = Database.delete((scope),false);
        
        //Loop through records giong to be deleted
        for(Database.DeleteResult dr : delResults){
        
            //If record is not successfully deleted
            if(!dr.isSuccess()){
            
                //List to hold Error
                Database.Error[] errs = dr.getErrors();
                
                //Loop through list of Error
                for(Database.Error err : errs) {
                    
                    //Debug to get Error Status
                    System.debug('$#$#$#$' + err.getStatusCode() + ' - ' + err.getMessage());
                    
                    //Debug to get Error Message
                    System.debug('ErrorMessage##########'+ err.getMessage());
                }
                
                //Increase counter for Failure
                 failureCounter++;
            }
            
            else {
            
                successCounter++;
            }
        }      
    }
    
    global void finish(Database.BatchableContext BC){
		BatchUtil.processBatchErrors(bc);
    }
}