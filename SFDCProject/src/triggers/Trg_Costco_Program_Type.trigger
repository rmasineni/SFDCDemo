trigger Trg_Costco_Program_Type on Opportunity (before insert, before update) {
Map<Id,String> AcntIDAndNameMap = New Map<Id,String>();
 Set<Id> SetAcntId = New Set<Id>();
 List<Opportunity> ListOppty = New List<Opportunity>();
 Set<Id> SetOpptId = New Set<Id>();    
 Map<Id,String> MapOfOppIdAndSCStatus = New Map<Id,String>();   
 List<Active_SC_Stages__c> ActiveSCStages = Active_SC_Stages__c.getAll().values();   
    Set<String> ActiveSCStatus = new Set<String>();  
    
    for(Opportunity o: trigger.new){
        if(o.Purchased_Thru__c == 'Costco'){
           if(o.Billing_State__c == 'CA' ||o.Billing_State__c == 'MA' || o.Billing_State__c == 'AZ' || o.Billing_State__c == 'NV' || o.Billing_State__c == 'NJ' || o.Billing_State__c == 'OR' || o.Billing_State__c == 'MD'){
            o.Program_Type__c = 'Program 1';
           }
           if(o.Billing_State__c == 'HI' || o.Billing_State__c == 'NY' || o.Billing_State__c == 'CO'|| o.Billing_State__c == 'CT'){
            o.Program_Type__c = 'Program 2';    
           } 
        }
        else if(o.Purchased_Thru__c != 'Costco'){
            o.Program_Type__c = null;
        }
    }
for(Opportunity opp: trigger.new)
         {  
              if(opp.Purchased_Thru__c!=null && opp.Purchased_Thru__c!='' && opp.Purchased_Thru__c.Contains('Costco'))
              {
                  SetAcntId.add(opp.Lead_Organization_Location_2__c);
                  ListOppty.add(opp);
              } 
         }    
   
if(!SetAcntId.isEmpty())
         {  
              for(Account acc: [select id, name from account where id in : SetAcntId])
              {
                 AcntIDAndNameMap.put(acc.id,acc.name);
                 System.debug('this is key :'+ AcntIDAndNameMap.keySet());    
                 System.debug('this is value :'+ AcntIDAndNameMap.values());    
              }    
         } 
 If(!AcntIDAndNameMap.isEmpty())
 {   
    for(Opportunity opp: ListOppty)
        {
           // system.debug('this contains:'+ AcntIDAndNameMap.get(NewLead.Lead_Organization_Location_2__c).contains('Costco'));
          if(AcntIDAndNameMap.containsKey(opp.Lead_Organization_Location_2__c)){ 
            If(!AcntIDAndNameMap.get(opp.Lead_Organization_Location_2__c).contains('Costco'))
            {
                opp.adderror('Please enter a Costco store location only');
            }
          }   
        }  
 }       
    
  If(Trigger.isupdate)  
{
    for(Opportunity oppty: Trigger.new)
    {
        if(oppty.Purchased_Thru__c!=null && Trigger.oldmap.get(oppty.id).Purchased_Thru__c!=null && (( oppty.Purchased_Thru__c=='Costco' && Trigger.oldmap.get(oppty.id).Purchased_Thru__c!='Costco') ||( oppty.Purchased_Thru__c!='Costco' && Trigger.oldmap.get(oppty.id).Purchased_Thru__c=='Costco') ))
        {
            SetOpptId.add(oppty.id);
            System.debug('This is opp Ids:'+SetOpptId);
        }
        //BSKY-7264 - Create new field on Opportunity: Design Only - Logic Start
        if((oppty.Sales_Partner__c == label.Sunrun_Inc_Id && oppty.Purchased_Thru__c==null)
                || oppty.SalesRep__c==null
                ||(oppty.Square_footage__c==null && oppty.Annual_kWh_usage__c==null)
                ||((oppty.Purchased_Thru__c!=null && oppty.Purchased_Thru__c.equalsIgnoreCase('Costco')) && (oppty.Costco_Member_ID__c == null ||oppty.Lead_Organization_Location_2__c == null) && oppty.Sales_Partner__c == label.Sunrun_Inc_Id))
             {
                 oppty.Design_Only__c = TRUE;
             }
        if(oppty.Purchased_Thru__c!=null
           && oppty.SalesRep__c!=null 
           && (oppty.Square_footage__c!=null || oppty.Annual_kWh_usage__c!=null))
             {
                 oppty.Design_Only__c = FALSE;
             }
        //BSKY-7264 - Create new field on Opportunity: Design Only - Logic End
        
    }
}
if(!SetOpptId.isEmpty())
{
    For(ServiceContract ActiveSC: [Select Id,Opportunity__c,Service_Contract_Status__c,Status__c from ServiceContract where Opportunity__c in:SetOpptId ])
    {
        MapOfOppIdAndSCStatus.put(ActiveSC.Opportunity__c,ActiveSC.Status__c);
        System.debug('This is MapOfOppIdAndSCStatus:'+MapOfOppIdAndSCStatus);
    }
} 
    If(Trigger.isupdate)  
 {
    If(!ActiveSCStages.isEmpty())
    {    
        for (Active_SC_Stages__c sc:ActiveSCStages )
       { 
          ActiveSCStatus.add(sc.ActiveSC__c);
       } 
    }    
    If(!ActiveSCStatus.isEmpty())
   {      
      for(Opportunity oppty: Trigger.new)
      {
        if(oppty.Purchased_Thru__c!=null && Trigger.oldmap.get(oppty.id).Purchased_Thru__c!=null && MapOfOppIdAndSCStatus.containsKey(oppty.id) && (ActiveSCStatus.contains(MapOfOppIdAndSCStatus.get(oppty.id))) && 
           (( oppty.Purchased_Thru__c=='Costco' && Trigger.oldmap.get(oppty.id).Purchased_Thru__c!='Costco') ||( oppty.Purchased_Thru__c!='Costco' && Trigger.oldmap.get(oppty.id).Purchased_Thru__c=='Costco') )
          )
        {
            oppty.adderror('An active service contract has been created, Purchased Thru cannot be changed at this time. In order to change Purchased Thru, you must generate a new customer agreement.');
        }
      }
   }    
   //JurisdictionOnOppty.copyJurisdictionToOppty(Trigger.New,Trigger.isUpdate,Trigger.oldMap,Trigger.newMap);
 }
    
}