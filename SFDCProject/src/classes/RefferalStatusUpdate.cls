public with sharing class RefferalStatusUpdate {
  public static void updateNTPReached(List<Service_Contract_Event__c> sceList,Map<id,Service_Contract_Event__c> old_Map){
    Set<id> scIds=new Set<id>();
    Set<id> serContIds=new Set<id>();
    Set<id> M1serContIds=new Set<id>();
    Map<id,string> MapOfSCIDAndNTPGranted = new  Map<Id, String>();
    Map<id,string> MapOfSCIDAndCOC = new Map<Id, String>(); 
    Map<id,string> MapOfSCIDAndM2PSC = new Map<Id, String>();  
    for(Service_Contract_Event__c sceObj:sceList){      
      if(sceObj.Referral_Id__c!=null&&sceObj.NTP_Granted__c!=null&&old_Map.get(sceObj.id).NTP_Granted__c!=sceObj.NTP_Granted__c){
        scIds.add(sceObj.Service_Contract__c);
     //   MapOfSCIDAndNTPGranted.put(sceObj.Service_Contract__c,sceObj.NTP_Granted__c);  
      }
      else if(sceObj.Referral_Id__c!=null&&sceObj.Completion_of_Construction__c!=null&&old_Map.get(sceObj.id).Completion_of_Construction__c!=sceObj.Completion_of_Construction__c){
        serContIds.add(sceObj.Service_Contract__c);
    //    MapOfSCIDAndCOC.put(sceObj.Service_Contract__c,sceObj.Completion_of_Construction__c);  
      }
     /* else if(sceObj.Referral_Id__c!=null&&sceObj.M1_proof_panel_inverter_delivery__c!=null&&old_Map.get(sceObj.id).M1_proof_panel_inverter_delivery__c!=sceObj.M1_proof_panel_inverter_delivery__c){
          M1serContIds.add(sceObj.Service_Contract__c);
      } */
      else if(sceObj.Referral_Id__c!=null&&sceObj.M2_proof_substantial_completion__c!=null&&old_Map.get(sceObj.id).M2_proof_substantial_completion__c!=sceObj.M2_proof_substantial_completion__c){
        M1serContIds.add(sceObj.Service_Contract__c);
    //    MapOfSCIDAndM2PSC.put(sceObj.Service_Contract__c,sceObj.M2_proof_substantial_completion__c);  
      }   
    }
    if(!scIds.isempty()){
      RefferalStagesChanges.updateReferralStatus(scIds,'Ready for Installation','Service_Contract__c');
    }
    if(!serContIds.isempty()){
      Set<id> scMatch=new Set<id>();
      for(ServiceContract scObj:[select id,Sales_Organization_Id__c from ServiceContract where id in:serContIds]){
        if(scObj.Sales_Organization_Id__c==System.Label.Sunrun_Inc_id){
          scMatch.add(scObj.id);
        }
      }
      if(!scMatch.isempty()){
        RefferalStagesChanges.updateReferralStatus(scMatch,'Solar Install Complete','Service_Contract__c');        
      }
    }
    if(!M1serContIds.isempty()){
      Set<id> scMatch=new Set<id>();
      for(ServiceContract scObj:[select id,Sales_Organization_Id__c from ServiceContract where id in:M1serContIds]){
        if(scObj.Sales_Organization_Id__c!=System.Label.Sunrun_Inc_id){
          scMatch.add(scObj.id);
        }
      }
      if(!scMatch.isempty()){
        RefferalStagesChanges.updateReferralStatus(scMatch,'Solar Install Complete','Service_Contract__c');        
      }
    }
  }
  public static void updateSolarInstall(List<ServiceContract> scList,Map<id,ServiceContract> old_Map,Boolean isinsert,Boolean isupdate){
    Set<id> scIds=new Set<id>();
    Set<id> scInsertIds=new Set<id>();
    Set<id> scCancelToOtherIds=new Set<id>();  
    Set<id> sceid = new Set<Id>();  
   if(!scList.isEmpty())
   {    
      for(ServiceContract scObj:scList)
    {
      if(isinsert&&scObj.Referral__c!=null)
      {
        scInsertIds.add(scObj.id);
      }
        
       if(isupdate&&scObj.Referral__c!=null&&scObj.status__c!=null&& old_Map.get(scObj.id).status__c!=null && (!scObj.status__c.contains('Cancelled'))&&old_Map.get(scObj.id).status__c.contains('Cancelled'))
      {	
        scCancelToOtherIds.add(scObj.id);
        sceid.add(scObj.Service_Contract_Event__c);   
      } 
      else if(isupdate&&scObj.Referral__c!=null&&scObj.status__c!=null&&scObj.status__c.contains('Cancelled')&&old_Map.get(scObj.id).status__c!=scObj.status__c)
      {
        scIds.add(scObj.id);
      }
    }
   }    
    if(!scIds.isempty()){
      RefferalStagesChanges.updateReferralStatus(scIds,'Solar Install Cancelled','Service_Contract__c');
    } 
    
    if(!sceid.isempty()){
      Set<id> scecheck =new Set<id>();
      Set<id> scecheck1 =new Set<id>();
      Set<id> scecheck2 =new Set<id>(); 
      Set<id> scecheck3 =new Set<id>();  
      for(Service_Contract_Event__c sceObj:[select id,NTP_Granted__c,Service_Contract__c,Completion_of_Construction__c,M2_proof_substantial_completion__c from Service_Contract_Event__c where id in:sceid])
      {
        if(sceObj.NTP_Granted__c==null && sceObj.Completion_of_Construction__c==null && sceObj.M2_proof_substantial_completion__c==null)
        {
          scecheck.add(sceObj.Service_Contract__c);
        }
        if(sceObj.NTP_Granted__c!=null && sceObj.Completion_of_Construction__c==null && sceObj.M2_proof_substantial_completion__c==null)
        {
          scecheck1.add(sceObj.Service_Contract__c);
        }
        if(sceObj.NTP_Granted__c!=null && sceObj.Completion_of_Construction__c!=null && sceObj.M2_proof_substantial_completion__c==null)
        {
          scecheck2.add(sceObj.Service_Contract__c);
        }  
        if(sceObj.NTP_Granted__c!=null && sceObj.Completion_of_Construction__c==null && sceObj.M2_proof_substantial_completion__c!=null)
        {
          scecheck3.add(sceObj.Service_Contract__c);
        }   
      }
      if(!scecheck.isempty())
      {
        RefferalStagesChanges.updateReferralStatus(scecheck,'Solar Consultation In-Progress','Service_Contract__c');        
      }
      if(!scecheck1.isempty())
      {
        RefferalStagesChanges.updateReferralStatus(scecheck1,'Ready for Installation','Service_Contract__c');        
      }
      if(!scecheck2.isempty())
      {
        Set<id> scMatch=new Set<id>();  
        for(ServiceContract scObj:[select id,Sales_Organization_Id__c from ServiceContract where id in:scecheck2])
       {
        if(scObj.Sales_Organization_Id__c==System.Label.Sunrun_Inc_id)
         {
          scMatch.add(scObj.id);
         }
       }
        if(!scMatch.isempty())
        {
          RefferalStagesChanges.updateReferralStatus(scMatch,'Solar Install Complete','Service_Contract__c');  
        }   
      }
      if(!scecheck3.isempty())
      {
        Set<id> scMatch=new Set<id>();  
        for(ServiceContract scObj:[select id,Sales_Organization_Id__c from ServiceContract where id in:scecheck3])
       {
        if(scObj.Sales_Organization_Id__c!=System.Label.Sunrun_Inc_id)
         {
          scMatch.add(scObj.id);
         }
       }
        if(!scMatch.isempty())
        {
          RefferalStagesChanges.updateReferralStatus(scMatch,'Solar Install Complete','Service_Contract__c');  
        }          
      }  
    }  
      
   /* if(!scInsertIds.isempty()){
      RefferalStagesChanges.updateReferralStatus(scInsertIds,'Solar Install In-Progress','Service_Contract__c');
    } */
  }
}