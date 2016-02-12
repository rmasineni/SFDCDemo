trigger trg_task_aft_inst_UpdateLeadContent on Task (after insert, after update) {
    List<Lead> ldList=new List<Lead>();
    List<Opportunity> oppList=new List<Opportunity>();
    Map<id,String> leadContent=new Map<id,String>();
    Map<id,String> opptyContent=new Map<id,String>();
 
    for(task t:trigger.new){
        System.debug('Five9__Five9DNIS__c :' +t.Five9__Five9DNIS__c);
        System.debug('WhoId : ' +t.WhoId);
        if(t.Five9__Five9DNIS__c!=null && t.WhoId!=null && t.CallType == 'Inbound'){
            System.debug('Entering1');
            if(!leadContent.containsKey(t.whoId)){
              if(t.whoId.getSObjectType().getDescribe().getName() == 'Lead'){
                  System.debug('Entering2A');  
                  leadContent.put(t.whoId,t.Five9__Five9DNIS__c);
              }
            }
        }

        if(t.Five9__Five9DNIS__c!=null && t.WhatId!=null && t.CallType == 'Inbound'){
          if(!opptyContent.containsKey(t.WhatId)){
              if(t.WhatId.getSObjectType().getDescribe().getName() == 'Opportunity'){
                  System.debug('Entering2B');  
                  opptyContent.put(t.WhatId,t.Five9__Five9DNIS__c);
              }
          }  
        }
    }

    if(!leadContent.isempty()){
        System.debug('leadContent.keySet() :' +leadContent.keySet());
        for(lead l:[select Id, Custom_Lead_Source__c, Content__c from lead where Id in :leadContent.keySet()]){
            System.debug('Entering3');
            System.debug('Custom_Lead_Source__c :' +l.Custom_Lead_Source__c);
            System.debug('Content__c :' +l.Content__c);
            if(l.Custom_Lead_Source__c != null && l.Custom_Lead_Source__c.containsIgnoreCase(System.label.Mickey_Account) && 
              (l.Content__c == ' ' || l.Content__c == null)){
               System.debug('Entering4'); 
               l.Content__c = leadContent.get(l.Id);    
               System.debug('Content : ' +l.Content__c); 
               ldList.add(l); 
            }
        }
    }

    if(!opptyContent.isempty()){
        System.debug('opptyContent.keySet() :' +opptyContent.keySet());
        for(opportunity opp:[select Id, Lead_Source_2__c, Content__c from Opportunity where Id in :opptyContent.keySet()]){
            System.debug('Entering4');
            System.debug('Lead_Source_2__c :' +opp.Lead_Source_2__c);
            System.debug('Content__c :' +opp.Content__c);
            if(opp.Lead_Source_2__c != null && opp.Lead_Source_2__c.containsIgnoreCase(System.label.Mickey_Account) && 
               opp.Content__c == null){
               System.debug('Entering5'); 
               opp.Content__c = opptyContent.get(opp.Id);    
               System.debug('Content : ' +opp.Content__c); 
               oppList.add(opp); 
            }
        }
    }

    if(!ldList.isempty()){
        update ldList;
    }

    if(!oppList.isempty()){
        update oppList;
    }
}