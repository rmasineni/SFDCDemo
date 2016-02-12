trigger trg_after_ins_sce_srsignoff on Service_Contract_Event__c (after insert) {
List<Opportunity> opptylist = new List<Opportunity>(); 
     for(Service_Contract_Event__c sce:trigger.new){
        if(sce.SR_Signoff__c!=null && sce.Opportunity__c!=null){
        Opportunity opp=new Opportunity();
        opp.id=sce.Opportunity__c;
        DateTime dT=sce.SR_Signoff__c;
        Date d1 = date.newinstance(dT.year(), dT.month(), dT.day());
        opp.CloseDate=d1;
        opp.StageName='7. Closed Won';
        opptylist.add(opp);
        }
     }        
     if(!opptylist.isempty())
     update opptylist;

     }