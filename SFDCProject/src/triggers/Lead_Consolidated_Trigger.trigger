trigger Lead_Consolidated_Trigger on Lead (before insert, after insert, before update, after update, before delete , after delete, after undelete) {
    Boolean skipValidations = false;
    skipValidations = SkipTriggerValidation.performTriggerValidations();
    
    if(skipValidations == false){    
    if(trigger.isBefore){
        
        if(trigger.isInsert){
            try{
            LeadTriggerClass.LeadPromoCodePopulateBeforeInsert(trigger.new); 
            LeadTriggerClass.trg_before_insert_fillLeadGeneratedByBefIns(trigger.new);   
            LeadTriggerClass.trg_lead_zip_to_utility(trigger.new,trigger.oldmap);    
            //if(System.isBatch()){
            LeadTriggerClass.PopulateChannelLeadSourceForPPLeads(trigger.new);
            BreaLeadAssignment.FindSalesInstallPartnerAdders(trigger.new);
            PartnerLeadAssignment.doMarketAssignment(trigger.new,trigger.isinsert,trigger.isupdate,trigger.oldMap);
            //}              
            //Lead_Distribution_SouthNorth.assignLeads(trigger.new); 
            LeadTriggerClass.trg_bef_ins_FindSalesrep(trigger.new);
            LeadTriggerClass.trg_lead_bef_ins_upd_salesRepEmailPhone(trigger.new,trigger.oldMap);  
            LeadTriggerClass.trg_lead_before_insert(trigger.oldMap, trigger.NewMap, trigger.new, trigger.isUpdate, trigger.isInsert);            
            sfLead.leadDeDupService.handleLeadsTrigger();
            LeadTriggerClass.trg_webtoleadBeforeInsert(trigger.new);
            //Lead_Distribution_SouthNorth.updateRelatedValues(Trigger.new);            
            //LeadTriggerClass.trg_lead_bef_ins_SP_IP_Partner(trigger.new);
            LeadTriggerClass.LeadAssignmentBeforeInsert(trigger.new);
            //LeadTriggerClass.ReferralCodeLookup_trigger(trigger.new);
            LeadTriggerClass.LeadBeforeInsert(trigger.new);
            LeadTriggerClass.LeadExtSourceBeforeInsert(trigger.new); 
            
            //Added for BSKY-7120 Incontact Hard Coded Values 
            LeadTriggerClass.UpdateCallCenterCheckbox(trigger.new);
             //Added for 7120 - Priya
            LeadTriggerClass.UpdateCallCenterCheckbox(trigger.oldmap,trigger.new, trigger.isInsert, trigger.isUpdate);
            
            LeadTriggerClass.doFieldMarketingBranch(trigger.new,trigger.oldMap,trigger.isInsert,trigger.isUpdate);
            //adding logic to update lead info based InContact data
            // LeadTriggerClass.updateInContactInfoOnLead(trigger.oldMap, trigger.new, trigger.isInsert, trigger.isUpdate);
                
            }catch(Exception ex){
                System.debug('-----Exception block before insert:' +ex+'line no'+ ex.getLineNumber()); 
                String UserName = UserInfo.getName();
                String ProfileId = UserInfo.getProfileId();
                String MarketoProfile = [ Select Id from Profile Where Name=:System.Label.MarketoProfileName].Id;
                if(UserName == System.Label.UserName || ProfileId == MarketoProfile){
                    Lead_Distribution_SouthNorth.exceptionHandler(trigger.new[0], ex.getMessage());
                }
            }
        }else if(trigger.isUpdate){
            LeadTriggerClass.ProcessMickeyLeads(trigger.new,trigger.oldmap);     
            LeadTriggerClass.ProcessRetailLeads(trigger.new,trigger.oldmap);     
            LeadTriggerClass.LeadPromoCodePopulateBeforeUpdate(trigger.new,trigger.oldMap);  
            //Lead_Distribution_SouthNorth.assignLeads(trigger.new);                   
            LeadTriggerClass.trg_lead_bef_ins_upd_salesRepEmailPhone(trigger.new,trigger.oldMap);     
            LeadTriggerClass.trg_lead_before_insert(trigger.oldMap, trigger.NewMap, trigger.new, trigger.isUpdate, trigger.isInsert);
            LeadTriggerClass.trg_lead_bef_upd_leadStatus(trigger.new);
            //Lead_Distribution_SouthNorth.updateRelatedValues(trigger.new);      
            LeadTriggerClass.trg_lead_zip_to_utility(trigger.new,trigger.oldmap);
            sfLead.leadDeDupService.handleLeadsTrigger();
            //LeadTriggerClass.PopulateChannelLeadSourceForPPLeads(trigger.new);
            PartnerLeadAssignment.doMarketAssignment(trigger.new,trigger.isinsert,trigger.isupdate,trigger.oldMap); 
            LeadTriggerClass.trg_before_insert_fillLeadGeneratedByAftUp(trigger.new);
            LeadTriggerClass.trg_lead_bf_up_findMarketsManual(trigger.new,trigger.oldMap);
            LeadTriggerClass.ProcessCostcoLead(trigger.new);

            //Added for BSKY-7120 Incontact Hard Coded Values
            LeadTriggerClass.UpdateCallCenterCheckbox(trigger.new);

            LeadTriggerClass.doFieldMarketingBranch(trigger.new,trigger.oldMap,trigger.isInsert,trigger.isUpdate);
         //   LeadTriggerClass.NotifyReferee(trigger.new,trigger.oldmap);
            
             //adding logic to update lead info based InContact data
            if(!System.isfuture()&&!system.isBatch())
           LeadTriggerClass.updateInContactInfoOnLead(trigger.oldMap, trigger.new, trigger.isInsert, trigger.isUpdate);
           
            //Added for 7120 - Priya
            LeadTriggerClass.UpdateCallCenterCheckbox(trigger.oldmap,trigger.new, trigger.isInsert, trigger.isUpdate);
           
            for(Lead l : trigger.new){
                if(l.LastUpdateDifference__c == null &&!checkRecursive.sunrunSouthIds.contains(l.id)&&l.sunrun_south__c){
                    l.LastUpdateDifference__c = 1;
                    checkRecursive.sunrunSouthIds.add(l.id);
                }else if(!checkRecursive.sunrunSouthIds.contains(l.id)&&l.sunrun_south__c){
                    l.LastUpdateDifference__c = 2;
                    checkRecursive.sunrunSouthIds.add(l.id);
                }
            }
            //LeadTriggerClass.ReferralCodeLookup_trigger(trigger.new);
        }else if(trigger.isDelete){
    
        }
    }else{
        if(trigger.isInsert){
            
            try{
            
            if(!System.isfuture()&&!system.isBatch())
            LeadTriggerClass.NotifyReferee(null, trigger.new, trigger.isInsert, trigger.isUpdate);    
            LeadCampaignAssignment.LeadCampaigns(trigger.new);                 
            LeadTriggerClass.trg_after_lead_ins_upd(trigger.oldmap, trigger.new, trigger.isUpdate);                              
            //LeadTriggerClass.InsertSouthRecords(trigger.new);
            LeadTriggerClass.trg_lead_after_insert(null, trigger.new, trigger.isInsert, trigger.isUpdate);
            LeadTriggerClass.LeadEmail(trigger.new);
            LeadTriggerClass.trg_webtoleadAfterInsert(trigger.new);
            //LeadTriggerClass.InsertSouthRecords(trigger.new);
            BreaLeadAssignment.BreaLeadshare(trigger.new); 
            LeadTriggerClass.trg_lead_aft_ins_SP_IP_Partner(trigger.new); 
           // LeadTriggerClass.ProcessCostcoLeadAfterInsert(trigger.new);    
            PartnerLeadShare.PartnerLeadShare(trigger.new,trigger.oldmap,trigger.isinsert,trigger.isupdate); 
            LeadTriggerClass.doReferralStagesUpdate(trigger.new,trigger.oldmap);
            if(!System.isfuture()&&!system.isBatch())
            LeadTriggerClass.updateInContactInfoOnLead(trigger.oldMap, trigger.new, trigger.isInsert, trigger.isUpdate);
                
           // LeadTriggerClass.NotifyReferee(null, trigger.new, trigger.isInsert, trigger.isUpdate);
            //LeadTriggerClass.convertQualifiedLeads(trigger.new);
            sfLead.leadDeDupService.handleLeadsTrigger();
           
             }
             catch(Exception ex){
                System.debug('-----Exception block after insert:' +ex); 
                String UserName = UserInfo.getName();
                String ProfileId = UserInfo.getProfileId();
                String MarketoProfile = [ Select Id from Profile Where Name=:System.Label.MarketoProfileName].Id;
                if(UserName == System.Label.UserName || ProfileId == MarketoProfile){
                    Lead_Distribution_SouthNorth.exceptionHandler(trigger.new[0], ex.getMessage());
                }
            }
        }else if(trigger.isUpdate){ 
            
            LeadTriggerClass.trg_after_lead_ins_upd(trigger.oldmap, trigger.new, trigger.isUpdate);          
            LeadTriggerClass.trg_lead_after_insert(trigger.oldMap, trigger.new, trigger.isInsert, trigger.isUpdate);
            LeadTriggerClass.ConversionScript(trigger.old, trigger.new);
            LeadTriggerClass.ConversionAndUpdateOppty(trigger.new);
            //LeadTriggerClass.trg_before_insert_fillLeadGeneratedByBefIns(trigger.new);
            LeadTriggerClass.LeadEmail(trigger.new);
            //LeadTriggerClass.trg_lead_zip_to_utility(trigger.new);
            //if(!system.isFuture()){
            //LeadTriggerClass.InsertSouthRecords(trigger.new);
            //}            
            LeadTriggerClass.LeadAssignmentAfterUpdate(trigger.new,trigger.oldMap);
        SalesRepMarketAssignment.doSalesRepMarketAssignment(trigger.new,trigger.oldmap);
            list<lead> LstOfLeadNotinConvertionProcess = new list<Lead>();
            for(Lead TempLeadObj : trigger.new)
            {
                if(!(TempLeadObj.isconverted))
                {
                    LstOfLeadNotinConvertionProcess.add(TempLeadObj);
                }
            }
            if(!(LstOfLeadNotinConvertionProcess.isempty()))
            LeadTriggerClass.LeadAfterUpdate(LstOfLeadNotinConvertionProcess); 
            LeadTriggerClass.trg_lead_aft_ins_SP_IP_Partner(trigger.new);
          //  LeadTriggerClass.NotifyReferee(trigger.oldMap, trigger.new, trigger.isInsert, trigger.isUpdate);
          //  LeadTriggerClass.ProcessCostcoLeadAfterUpdate(trigger.new);
            
            PartnerLeadShare.PartnerLeadShare(trigger.new,trigger.oldmap,trigger.isinsert,trigger.isupdate);
            LeadTriggerClass.doReferralStagesUpdate(trigger.new,trigger.oldmap);
            sfLead.leadDeDupService.handleLeadsTrigger();
            //LeadTriggerClass.convertQualifiedLeads(trigger.new);
            
        }else if(trigger.isDelete){
            LeadTriggerClass.trg_lead_after_delete(trigger.old);
        }else if(trigger.isUndelete){
    
        }
    }
    
    }
    
    //Below service calls integrates the Leads with AddressService to standardize the address.
    Sf.addressService.handleLeadsTrigger();
    Sf.costcoSyncService.handleLeadsTrigger();
    Sf.homeDepotSyncService.handleLeadsTrigger();
    //Below service calls checks if status of leads changed and if so, sends a sqs message to the partner queue.
   // Sf.awsSyncService.handleLeadsTrigger();    
}