trigger Trg_Bread_Share on Opportunity (after insert) {
       Set<id> opptyIds=new Set<id>();
       Set<id> noteOppIds=new Set<id>();
       Set<String> leadSourceSet=new Set<String>();
        for(Partner_Ma__c pma:Partner_Ma__c.getAll().values()){
            leadSourceSet.add(pma.Lead_Source__c);
        }
       for(Opportunity o:trigger.new){
         if((o.channel_2__c=='Partner'&&o.Lead_Source_2__c=='Partner: Legacy')||(o.Lead_Source_2__c!=null&&leadSourceSet.contains(o.Lead_Source_2__c))){
           opptyIds.add(o.id);            
           //if(o.salesRep__c!=null)
           //OpptySalesRepMap.put(o.id,o.salesRep__c);          
         }
         if(o.lead_id__c!=null){
            noteOppIds.add(o.id);
         }
       }      
       if(!opptyIds.isempty()){
         //BreaOpptyShare.BreaOpptyShare_Immediate(Opptyids);
         BreaOpptyShare.BreaOpptyShare(Opptyids);
       }
       if(!noteOppIds.isempty()){
        CopyNoteFromLeadConvertion.CopyNoteFromLeadConvertion(noteOppIds);
       }              
    }