trigger Lead_Consolidated_Trigger_prod on Lead (before insert, after insert, before update, after update, before delete , after delete, after undelete) {
    if(trigger.isBefore){
        if(trigger.isInsert){
            Lead_Distribution_SouthNorth.assignLeads(trigger.new);  
            LeadTriggerClass2.trg_lead_zip_to_utility(trigger.new);       
            LeadTriggerClass2.trg_lead_before_insert(trigger.oldMap, trigger.NewMap, trigger.new, trigger.isUpdate, trigger.isInsert);
            LeadTriggerClass2.trg_before_insert_fillLeadGeneratedByBefIns(trigger.new);
            LeadTriggerClass2.trg_webtoleadBeforeInsert(trigger.new);
            Lead_Distribution_SouthNorth.updateRelatedValues(Trigger.new);            
            LeadTriggerClass2.LeadAssignmentBeforeInsert(trigger.new);
            
        }else if(trigger.isUpdate){ 
            for(Lead l : trigger.new){
                if(l.LastUpdateDifference__c == null &&!checkRecursive.sunrunSouthIds.contains(l.id)){
                    l.LastUpdateDifference__c = 1;
                    checkRecursive.sunrunSouthIds.add(l.id);
                }else if(!checkRecursive.sunrunSouthIds.contains(l.id)){
                    l.LastUpdateDifference__c = 2;
                    checkRecursive.sunrunSouthIds.add(l.id);
                }
            }
            LeadTriggerClass2.trg_lead_before_insert(trigger.oldMap, trigger.NewMap, trigger.new, trigger.isUpdate, trigger.isInsert);
            LeadTriggerClass2.trg_lead_bef_upd_leadStatus(trigger.new);
            Lead_Distribution_SouthNorth.updateRelatedValues(trigger.new);      
            LeadTriggerClass2.trg_lead_zip_to_utility(trigger.new); 
            LeadTriggerClass2.trg_before_insert_fillLeadGeneratedByAftUp(trigger.new);
        }else if(trigger.isDelete){
    
        }
    }else{
        if(trigger.isInsert){
            LeadTriggerClass2.trg_after_lead_ins_upd(trigger.oldmap, trigger.new,trigger.isinsert, trigger.isUpdate);
            LeadTriggerClass2.trg_lead_after_insert(null, trigger.new, trigger.isInsert, trigger.isUpdate);
            LeadTriggerClass2.LeadEmail(trigger.new);
            LeadTriggerClass2.trg_webtoleadAfterInsert(trigger.new);
            LeadTriggerClass2.InsertSouthRecords(trigger.new);
        }else if(trigger.isUpdate){
            LeadTriggerClass2.trg_after_lead_ins_upd(trigger.oldmap, trigger.new,trigger.isinsert, trigger.isUpdate);
            LeadTriggerClass2.trg_lead_after_insert(trigger.oldMap, trigger.new, trigger.isInsert, trigger.isUpdate);
            LeadTriggerClass2.ConversionScript(trigger.old, trigger.new);
            LeadTriggerClass2.LeadEmail(trigger.new);
            LeadTriggerClass2.LeadAssignmentAfterUpdate(trigger.new);
            
        }else if(trigger.isDelete){
            LeadTriggerClass2.trg_lead_after_delete(trigger.old);
        }else if(trigger.isUndelete){
    
        }
    }
}