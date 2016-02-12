/*************************************************************************
**************************************************************************
Trigger Name:trg_before_ins_update_closeDate
Created Date: 1/7/2014
Author: Prashanth Veloori
Description: Assign default close date as 12/31/2099 before insert as close
             date is a required field and it is not exposed to business users

***************************************************************************
***************************************************************************/
trigger trg_before_ins_update_closeDate on Opportunity (before insert) {
    date d1 = date.parse('12/09/2099');
    for(opportunity o:trigger.new)
    if(o.closedate ==null || o.lead_id__c!=null)
    o.closedate=d1;

}