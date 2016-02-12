global class BatchToDeleteContact implements Schedulable {

    global void execute(SchedulableContext sc) {
    
       Batch_DeleteContact dc = new Batch_DeleteContact();
        Database.executeBatch(dc, 10);
    }
}