trigger trg_before_insert_fillLeadGeneratedBy on Lead (before insert,before update) {
    if(Trigger.isInsert){
    id id=userinfo.getUserId();
    for(lead l:trigger.new){
        //if(!(l.Channel__c=='Retail'&&l.Sales_Rep_Email__c!=null)){                
        l.Lead_Generated_by__c=id;
        //}
        if(l.Sales_Partner__c!=null&&l.Retail_Sales_Partner_Assigned__c==false){
        l.Partner_for_Lead_Passing__c=l.Sales_Partner__c;
        l.Retail_Sales_Partner_Assigned__c=true;
        }
    }
    }
    else if(Trigger.isUpdate){
        for(lead l:trigger.new){
            if(l.Sales_Partner__c!=null&&l.Retail_Sales_Partner_Assigned__c==false){
            l.Partner_for_Lead_Passing__c=l.Sales_Partner__c;
            l.Retail_Sales_Partner_Assigned__c=true;
            }
        }   
    }
}