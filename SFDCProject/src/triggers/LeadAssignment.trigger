trigger LeadAssignment on Lead (before insert,after update) 
{  
  if(Trigger.isInsert&&Trigger.isBefore){
    if(userinfo.getUserType()=='PowerPartner'){
      for(Lead l : trigger.new){
      l.lock_assignment__c=true;
    }    
    }   
  } 
     
  else if(system.isFuture() == false && system.isBatch() == false&&Trigger.isupdate&&userinfo.getUserType()!='PowerPartner'){    
      Set<id> ids=new Set<id>();
    for(lead l:trigger.new){      
      if(string.valueOf(l.Channel__c)!='Retail'&&l.lock_assignment__c==false&&!l.isconverted&&!checkRecursive.leadsetIds.contains(l.id)){          
      ids.add(l.id);
      checkRecursive.leadsetIds.add(l.id);
      }      
    }
    if(!ids.isempty()){  
    System.debug('----> insert lead ids'+ids);    
    Lead_Assignment.Lead_Assignment(ids);    
    }
      
  }  

}