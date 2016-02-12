trigger OpportunityTrigger on Opportunity (before insert, before update, after Insert, after update) {
    
    Boolean skipValidations = false;
  skipValidations = SkipTriggerValidation.performTriggerValidations();
  if(skipValidations == false){    
      Set<Id> optyNumberIds = new Set<Id>();
      Integer counter = 0;
      Map<id,Opportunity> SalesRepOptyMap=new Map<id,Opportunity>(); 
      for(Opportunity opty : Trigger.new) {
          if (Trigger.isBefore && (Trigger.isInsert || (Trigger.isUpdate && (opty.Deal_Id__c == null ||  opty.Deal_Id__c == '')))) {
              //The length of the deal id is 12 digits. This is required for financials system reconciliation
              opty.Deal_Id__c = new BaseClass().getRandomString(Constants.DealIdLength);
          }
      
      if (Trigger.isBefore && (Trigger.isInsert || (Trigger.isUpdate && (opty.opportunity_Number__c == null || opty.opportunity_Number__c == '')))) {
             counter++;
             if(opty.Id != null ){
          optyNumberIds.add(opty.Id);
             }
      }
      //BSKY-5746
        if(opty.Original_Owner_Rep__c==null&&opty.SalesRep__c!=null&&(Trigger.isinsert||(Trigger.isupdate&&Trigger.oldMap.get(opty.id).SalesRep__c!=opty.SalesRep__c))){
            opty.Original_Owner_Rep__c=opty.SalesRep__c;
            SalesRepOptyMap.put(opty.SalesRep__c,opty);
        }
        if(opty.Rewarm_Date__c==null&&opty.SalesRep__c==System.Label.Database_Team){
            opty.Rewarm_Date__c=System.today();
        }
    }
    
    if(!SalesRepOptyMap.isempty()){
        Map<id,String> SalesRepSalesTeamMap=new Map<id,String>();
        for(Contact contObj:[select Sales_Team__c,Sunrun_User__c from Contact where Sunrun_user__c in:SalesRepOptyMap.keyset()]){
            SalesRepSalesTeamMap.put(contObj.Sunrun_User__c,contObj.Sales_Team__c);
        }
        for(Opportunity opp:SalesRepOptyMap.values()){
            if(SalesRepSalesTeamMap.containsKey(opp.SalesRep__c)){
                opp.Original_Owner_Team__c=SalesRepSalesTeamMap.get(opp.SalesRep__c);
            }
        }   
      }
    //End BSKY-5746
    if(!optyNumberIds.isEmpty()){
      Map<Id, String> optyScNameMap = new Map<Id, String>();
      for(ServiceContract scoBJ : [Select Id, name, Opportunity__c,Marked_For_Deletion__c from ServiceContract where 
                      (Marked_For_Deletion__c = null OR   Marked_For_Deletion__c = 'No') 
                      AND Status__c != 'Inactive' and Opportunity__c in :optyNumberIds]){
        Opportunity optyObj = Trigger.newmap.get(scoBJ.Opportunity__c);
        optyObj.Opportunity_number__c = 'O-' + scoBJ.Name;
        counter --;
      }
    }
    if(counter > 0){
      List<String> optyNumberList = new List<String>();
      optyNumberList = RandomNumberGenerator.getUniqueServiceContractNumbers(counter);
      for(Opportunity opty : Trigger.new) {
        if (optyNumberList != null && !optyNumberList.isEmpty() && counter > 0 && 
          Trigger.isBefore && (Trigger.isInsert || (Trigger.isUpdate && (opty.opportunity_Number__c == null || opty.opportunity_Number__c == '')))) {
               counter--;
          opty.Opportunity_number__c = 'O-' + optyNumberList[counter];
        }
        }    
    }
  }  

    //Handles the aws sqs sync of opportunity status updates.
    Sf.awsSyncService.handleOptysTrigger();
    
    if(Trigger.isupdate){
         Sf.costcoSyncService.handleOpportunitiesTrigger();  
    }

    if(Trigger.isInsert || Trigger.isUpdate){
        Sf.homeDepotSyncService.handleOpportunitiesTrigger();    
    }
}