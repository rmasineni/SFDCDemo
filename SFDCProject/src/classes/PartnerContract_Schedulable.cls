/* 
** Class: PartnerContract_Schedulable
** Author: Raghavendra Masineni
** 
**
*/

global class PartnerContract_Schedulable implements Schedulable {
    
    public String accountFilter;
    public PartnerContract_Schedulable(){
    	accountFilter = '';
    }
    
    public PartnerContract_Schedulable(String accountFilter){
    	this.accountFilter = accountFilter;
    }
    
    
    global void execute(SchedulableContext SC) {
        System.debug('scheduleTM: execute');   
        PartnerContract_Batch contractBatch = new PartnerContract_Batch(accountFilter, false);
        id batchinstanceid = database.executeBatch(contractBatch );   
    }
}