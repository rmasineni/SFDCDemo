trigger trg_bef_ins_Quickdesign on Opportunity (before insert, before update) {

   //BSKY-7262 - Update Site Design Priority at opportunity creation - Logic start
   system.debug('*****7262***1:'+Trigger.New);
   system.debug('*****7262***Trigger.isInsert:'+Trigger.isInsert);
   system.debug('*****7262***Trigger.isUpdate:'+Trigger.isUpdate);
   
       if(Trigger.isInsert)
       {
           system.debug('*****7262***2');              
           for(Opportunity optyObj:Trigger.New)
           {
           
            system.debug('*****7262***optyObj.Sales_Partner__r.name: '+optyObj.Sales_Partner__r.name+'optyObj.Sales_Partner__r.Quick_Design_Access__c: '+optyObj.Sales_Partner__r.Quick_Design_Access__c);
             //if((optyObj.Sales_Partner__r.name != null && optyObj.Sales_Partner__r.name.equalsIgnoreCase('SUNRUN')) && (optyObj.Sales_Partner__r.Quick_Design_Access__c != null && optyObj.Sales_Partner__r.Quick_Design_Access__c.equalsIgnoreCase('Auto')))
             if(optyObj.Sales_Partner__c == label.Sunrun_Inc_Id 
                && (optyObj.Sales_Partner__r.Quick_Design_Access__c != null && optyObj.Sales_Partner__r.Quick_Design_Access__c.equalsIgnoreCase('Auto')))
             {
              
                 optyObj.Site_Design_Priority__c = 'Normal';
               
             }
             if((optyObj.Sales_Partner__r.name != null && optyObj.Sales_Partner__r.name.equalsIgnoreCase('Horizon Solar Power')) && ((optyObj.Sales_Partner__r.Quick_Design_Access__c != null && optyObj.Sales_Partner__r.Quick_Design_Access__c.equalsIgnoreCase('Manual'))||optyObj.Sales_Partner__r.Quick_Design_Access__c != null))
             {
                
                 optyObj.Site_Design_Priority__c = null;
               
             }
           }
       }
     
    //BSKY-7262 - Update Site Design Priority at opportunity creation - Logic End
    //BSKY-7264 - Create new field on Opportunity: Design Only - Logic Start
     if(Trigger.isInsert || Trigger.isUpdate)
     {
         system.debug('*****7262***3');
         for(Opportunity optyObj:Trigger.New)
         {
             if((optyObj.Sales_Partner__c == label.Sunrun_Inc_Id && optyObj.Purchased_Thru__c==null)
                || optyObj.SalesRep__c==null
                ||(optyObj.Square_footage__c==null && optyObj.Annual_kWh_usage__c==null)
                ||((optyObj.Purchased_Thru__c!=null && optyObj.Purchased_Thru__c.equalsIgnoreCase('Costco')) && (optyObj.Costco_Member_ID__c == null ||optyObj.Lead_Organization_Location_2__c == null) && optyObj.Sales_Partner__c == label.Sunrun_Inc_Id))
             {
                 optyObj.Design_Only__c = TRUE;
             }
             if(optyObj.Purchased_Thru__c!=null 
                && optyObj.SalesRep__c!=null 
                && (optyObj.Square_footage__c!=null || optyObj.Annual_kWh_usage__c!=null))
             {
                 optyObj.Design_Only__c = FALSE;
             }
             
             
         }
         
     }
    
     //BSKY-7264 - Create new field on Opportunity: Design Only - Logic End

}