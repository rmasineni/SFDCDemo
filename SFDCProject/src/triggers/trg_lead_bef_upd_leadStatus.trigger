trigger trg_lead_bef_upd_leadStatus on Lead (before update) {
    for(lead l:trigger.new){
        if(l.IsConverted){
            l.Lead_Status__c='Converted';
        }
    }

}