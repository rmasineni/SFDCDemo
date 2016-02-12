trigger LeadEmail on Lead (after insert, after update) {
    
    
    for(Lead newLead : Trigger.new){
        
        Messaging.SingleEmailMessage msg = new Messaging.SingleEmailMessage();
        msg.setToAddresses(new String[]{newLead.Email});
        
    }
}