trigger LeadTrigger on Lead (before insert, after insert, before update, after update) {
    //Below service calls checks if status of leads changed and if so, sends a sqs message to the partner queue.
    Sf.awsSyncService.handleLeadsTrigger();    
}