trigger trg_webtolead on Lead (before insert,after insert) {    
    if(trigger.isBefore){
    for(lead l: trigger.new){
    if((l.Sales_Rep_Email__c!=null || l.Sales_Rep_Email__c!='') && l.Channel__c == 'Retail'){
        if(l.firstname!=null){
            l.company=l.firstname+' '+l.lastname;           
        }
        else{
            l.company=l.lastname;
        }
    }
  }
}
if(trigger.isAfter){
    
     Set<id> leadids=new Set<id>();
     Created_By__c devAccount =  Created_By__c.getValues('Created By Name');
     //user devAccount=[select id from user where name='Sunrun CRM' limit 1];
     for(lead l:trigger.new){
      if((l.Sales_Rep_Email__c!=null || l.Sales_Rep_Email__c!='') && l.Channel__c == 'Retail'&&l.CreatedById==devAccount.User_ID__c){
            leadids.add(l.id);
        }
     }
     if(!leadids.isempty())
     Web2LeadOwnerUpdate.Web2LeadOwnerUpdate(leadids);
 
}
}