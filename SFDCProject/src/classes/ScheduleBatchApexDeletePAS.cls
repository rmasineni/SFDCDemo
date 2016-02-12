global class ScheduleBatchApexDeletePAS implements Schedulable{  
    global void execute(SchedulableContext SC) {
            String query='select id from Partner_Assignment_Staging__c where lead__r.isconverted=true';
            if(Test.isRunningTest())
            query='select id from Partner_Assignment_Staging__c where lead__r.isconverted=true limit 10';            
            BatchApexDeletePAS  batch=new BatchApexDeletePAS(query);
            database.executeBatch(batch);
    }
    
}