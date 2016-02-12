trigger trg_before_ins_upd_oppty on Opportunity (after insert, after update) {
    Boolean skipValidations = False;
    skipValidations = SkipTriggerValidation.performTriggerValidations();
    if(skipValidations == false){
        Set<String> optyCancelledStages = new Set<String>();
        optyCancelledStages.add('8. Future Prospect');
        optyCancelledStages.add('9. Closed Lost');  
    Map<Id, String> optyIdProjectStatusMap = new Map<Id, String>();
    Set<Id> setContactIds = new Set<Id>();
    Map<Id,Id> mapContactUserIds = new Map<Id, Id>();
    Set<id> scOpptySet=new Set<id>();
    if(trigger.isupdate){
        Map<Id, ServiceContract> optySCMap = ServiceContractUtil.getServiceContractForOpty(trigger.newMap.keyset());
        scOpptySet.addall(optySCMap.keySet());
        System.debug('scOpptySet: ' + scOpptySet);
    //for(ServiceContract sc:[select id,opportunity__c from ServiceContract where Opportunity__c in:trigger.newMap.keyset()]){
    //    scOpptySet.add(sc.opportunity__c);
    //}
   }
   for(Opportunity o:Trigger.new)
   {
    Opportunity oldOpportunity = null;
        if(trigger.isUpdate){
        oldOpportunity = trigger.oldMap.get(o.Id);
        }  
       
       if(trigger.isUpdate && oldOpportunity.stageName != o.StageName  && optyCancelledStages.contains(o.StageName))
       {
           
           if( !scOpptySet.contains(o.id)  )
               optyIdProjectStatusMap.put(o.Id, wfUtil.CANCELLED);
       } 
          
         if (trigger.isUpdate&&scOpptySet.contains(o.id) && (Userinfo.getProfileId() != system.label.System_Admin_Profile_Id) )
         {         
           if(oldOpportunity.SunRun_NTP_Costco_PO_Issued__c  != o.SunRun_NTP_Costco_PO_Issued__c)
          o.SunRun_NTP_Costco_PO_Issued__c.addError('Field can not be edited as Service Contract Event has been created');
          
        //   if(oldOpportunity.Project_Manager__c != o.Project_Manager__c)
        //   o.Project_Manager__c.addError('Should update project planner field on Service Contract Event once a Service Contact exists');
          
           if(oldOpportunity.Oracle_Opportunity_Close_Date__c  != o.Oracle_Opportunity_Close_Date__c)
          o.Oracle_Opportunity_Close_Date__c.addError('Field can not be edited as Service Contract Event has been created');
          
           if(oldOpportunity.Oracle_Revenue_Amount__c  != o.Oracle_Revenue_Amount__c)
          o.Oracle_Revenue_Amount__c.addError('Field can not be edited as Service Contract Event has been created');
          
          // if(oldOpportunity.Permit_Jurisdiction_municipality__c  != o.Permit_Jurisdiction_municipality__c)
         // o.Permit_Jurisdiction_municipality__c.addError('Field can not be edited as Service Contract Event has been created');
         
          if(oldOpportunity.Return_to_Sales_Date__c  != o.Return_to_Sales_Date__c)
          o.Return_to_Sales_Date__c.addError('Field can not be edited as Service Contract Event has been created');
          
        //   if(oldOpportunity.Plans_Reviewed_Date__c  != o.Plans_Reviewed_Date__c)
        //  o.Plans_Reviewed_Date__c.addError('Field can not be edited as Service Contract Event has been created');
          
          // if(oldOpportunity.Plans_Completed_Date__c  != o.Plans_Completed_Date__c)
         // o.Plans_Completed_Date__c.addError('Field can not be edited as Service Contract Event has been created');
          
           if(oldOpportunity.Layout_Approval_Finish__c  != o.Layout_Approval_Finish__c)
          o.Layout_Approval_Finish__c.addError('Field can not be edited as Service Contract Event has been created');
          
           if(oldOpportunity.Layout_Approval_Start__c  != o.Layout_Approval_Start__c)
          o.Layout_Approval_Start__c.addError('Field can not be edited as Service Contract Event has been created');
          
          if(oldOpportunity.Project_Creation_Date__c  != o.Project_Creation_Date__c)
          o.Project_Creation_Date__c.addError('Field can not be edited as Service Contract Event has been created');
          
           if(oldOpportunity.Submit_Final_Interconnection__c  != o.Submit_Final_Interconnection__c)
          o.Submit_Final_Interconnection__c.addError('Field can not be edited as Service Contract Event has been created');
          
            if(oldOpportunity.Actual_Construction_Start__c  != o.Actual_Construction_Start__c)
          o.Actual_Construction_Start__c.addError('Field can not be edited as Service Contract Event has been created');
          
            if(oldOpportunity.Actual_Construction_Finish__c  != o.Actual_Construction_Finish__c)
          o.Actual_Construction_Finish__c.addError('Field can not be edited as Service Contract Event has been created');
          
            if(oldOpportunity.Permitting_Process_Start_Date__c  != o.Permitting_Process_Start_Date__c)
          o.Permitting_Process_Start_Date__c.addError('Field can not be edited as Service Contract Event has been created');
          
            if(oldOpportunity.Permitting_Process_Finish_Date__c  != o.Permitting_Process_Finish_Date__c)
          o.Permitting_Process_Finish_Date__c.addError('Field can not be edited as Service Contract Event has been created');
          
             if(oldOpportunity.Elect_PV_Finish_Date__c  != o.Elect_PV_Finish_Date__c)
          o.Elect_PV_Finish_Date__c.addError('Field can not be edited as Service Contract Event has been created');
          
           if(oldOpportunity.Job_Type__c  != o.Job_Type__c)
          o.Job_Type__c.addError('Field can not be edited as Service Contract Event has been created');
                              
          //  if(oldOpportunity.Site_Audit_Completed__c  != o.Site_Audit_Completed__c)
          //o.Site_Audit_Completed__c.addError('Field can not be edited as Service Contract Event has been created');
          
         /* if(oldOpportunity.Date_when_Site_Audit_was_Scheduled__c  != o.Date_when_Site_Audit_was_Scheduled__c)
          o.Date_when_Site_Audit_was_Scheduled__c.addError('Field can not be edited as Service Contract Event has been created');*/
                   
          if(oldOpportunity.Site_Audit_Results_Rcvd__c!= o.Site_Audit_Results_Rcvd__c)
          o.Site_Audit_Results_Rcvd__c.addError('Field can not be edited as Service Contract Event has been created');
          
         /* if(oldOpportunity.Site_Audit_Scheduled__c!= o.Site_Audit_Scheduled__c)
          o.Site_Audit_Scheduled__c.addError('Field can not be edited as Service Contract Event has been created');
          
         if(oldOpportunity.First_Call_Completed_Date__c!= o.First_Call_Completed_Date__c)
          o.First_Call_Completed_Date__c.addError('Field can not be edited as Service Contract Event has been created');
          
          if(oldOpportunity.Scheduled_Construction_Start_Date__c!= o.Scheduled_Construction_Start_Date__c)             
          o.Scheduled_Construction_Start_Date__c.addError('Field can not be edited as Service Contract Event has been created');*/
          
         }
         if (trigger.isUpdate&&scOpptySet.contains(o.id) && (Userinfo.getProfileId() != system.label.Sales_Profile_Id))
         { 
                            
           if(oldOpportunity.Critter_Guard__c!= o.Critter_Guard__c)             
          o.Critter_Guard__c.addError('Field can not be edited as Service Contract Event has been created');
          
        //   if(oldOpportunity.Reroof_under_Array__c!= o.Reroof_under_Array__c)             
        //  o.Reroof_under_Array__c.addError('Field can not be edited as Service Contract Event has been created');
                    
        //   if(oldOpportunity.Service_Panel_Upgrade__c!= o.Service_Panel_Upgrade__c)             
        //  o.Service_Panel_Upgrade__c.addError('Field can not be edited as Service Contract Event has been created');
          
           if(oldOpportunity.Vaulted_Ceilings__c!= o.Vaulted_Ceilings__c)             
          o.Vaulted_Ceilings__c.addError('Field can not be edited as Service Contract Event has been created');
          
          if(oldOpportunity.Main_Panel_Size_Amps__c!= o.Main_Panel_Size_Amps__c)             
          o.Main_Panel_Size_Amps__c.addError('Field can not be edited as Service Contract Event has been created');                    
         }
        
         Set<Id> opptyid = new Set<Id>();
         List<Opportunity> opptylist = new List<Opportunity>();
         List<Service_Contract_Event__c> scelist = new List <Service_Contract_Event__c>();
         Map<Id, Service_Contract_Event__c> scemap = New Map<Id, Service_Contract_Event__c>(); 
         if(trigger.isupdate){              
        for(Opportunity opp : trigger.new){
          if((trigger.oldmap.get(opp.id).Critter_Guard__c !=opp.Critter_Guard__c) || (trigger.oldmap.get(opp.id).Reroof_under_Array__c !=opp.Reroof_under_Array__c) || (trigger.oldmap.get(opp.id).Service_Panel_Upgrade__c !=opp.Service_Panel_Upgrade__c) || (trigger.oldmap.get(opp.id).First_Call_Completed_Date__c !=opp.First_Call_Completed_Date__c) || (trigger.oldmap.get(opp.id).HOA_Name__c !=opp.HOA_Name__c)
          || (trigger.oldmap.get(opp.id).Vaulted_Ceilings__c !=opp.Vaulted_Ceilings__c) || (trigger.oldmap.get(opp.id).Main_Panel_Size_Amps__c !=opp.Main_Panel_Size_Amps__c) || (trigger.oldmap.get(opp.id).Scheduled_Construction_Start_Date__c != opp.Scheduled_Construction_Start_Date__c) || (trigger.oldmap.get(opp.id).Project_Manager__c != opp.Project_Manager__c) || (trigger.oldmap.get(opp.id).HOA_Notes__c !=opp.HOA_Notes__c)
          || (trigger.oldmap.get(opp.id).Job_Type__c !=opp.Job_Type__c) || (trigger.oldmap.get(opp.id).SunRun_NTP_Costco_PO_Issued__c !=opp.SunRun_NTP_Costco_PO_Issued__c) || (trigger.oldmap.get(opp.id).Oracle_Revenue_Amount__c !=opp.Oracle_Revenue_Amount__c) || (trigger.oldmap.get(opp.id).External_Drafter__c !=opp.External_Drafter__c) || (trigger.oldmap.get(opp.id).PE_Stamp_Ordered__c !=opp.PE_Stamp_Ordered__c) 
          || (trigger.oldmap.get(opp.id).Permit_Jurisdiction_municipality__c !=opp.Permit_Jurisdiction_municipality__c) || (trigger.oldmap.get(opp.id).Layout_Approval_Start__c !=opp.Layout_Approval_Start__c) || (trigger.oldmap.get(opp.id).Elect_PV_Finish_Date__c !=opp.Elect_PV_Finish_Date__c) || (trigger.oldmap.get(opp.id).PE_Stamp_Received__c !=opp.PE_Stamp_Received__c) 
          || (trigger.oldmap.get(opp.id).Permitting_Process_Start_Date__c !=opp.Permitting_Process_Start_Date__c)  || (trigger.oldmap.get(opp.id).Permitting_Process_Finish_Date__c !=opp.Permitting_Process_Finish_Date__c) || (trigger.oldmap.get(opp.id).Actual_Construction_Finish__c !=opp.Actual_Construction_Finish__c) || (trigger.oldmap.get(opp.id).HOA_Approved__c !=opp.HOA_Approved__c)
          || (trigger.oldmap.get(opp.id).Actual_Construction_Start__c !=opp.Actual_Construction_Start__c)|| (trigger.oldmap.get(opp.id).Plans_Completed_Date__c !=opp.Plans_Completed_Date__c)|| (trigger.oldmap.get(opp.id).Submit_Final_Interconnection__c !=opp.Submit_Final_Interconnection__c) || (trigger.oldmap.get(opp.id).Draft_Quality_Rating__c !=opp.Draft_Quality_Rating__c)
          || (trigger.oldmap.get(opp.id).Site_Audit_Completed__c !=opp.Site_Audit_Completed__c) || (trigger.oldmap.get(opp.id).Layout_Approval_Finish__c !=opp.Layout_Approval_Finish__c) || (trigger.oldmap.get(opp.id).Oracle_Opportunity_Close_Date__c !=opp.Oracle_Opportunity_Close_Date__c) || (trigger.oldmap.get(opp.id).HOA_Application_Submitted_Date__c !=opp.HOA_Application_Submitted_Date__c)
          || (trigger.oldmap.get(opp.id).Plans_Reviewed_Date__c !=opp.Plans_Reviewed_Date__c) || (trigger.oldmap.get(opp.id).Site_Audit_Notes__c !=opp.Site_Audit_Notes__c )||(trigger.oldmap.get(opp.Id).On_Hold_End_Date__c!= opp.On_Hold_End_Date__c )||(trigger.oldmap.get(opp.Id).On_Hold_Start_Date__c!= opp.On_Hold_Start_Date__c ) ||(trigger.oldmap.get(opp.Id).ETA_of_HOA_Approval_Date__c!= opp.ETA_of_HOA_Approval_Date__c)
          || (trigger.oldmap.get(opp.id).Electrical_PE_Stamp__c !=opp.Electrical_PE_Stamp__c) || (trigger.oldmap.get(opp.id).HOA__c !=opp.HOA__c) || (trigger.oldmap.get(opp.id).Welcome_Call__c !=opp.Welcome_Call__c) || (trigger.oldmap.get(opp.id).Welcome_Call_Status__c !=opp.Welcome_Call_Status__c) || (trigger.oldmap.get(opp.id).Site_Audit_Scheduled__c !=opp.Site_Audit_Scheduled__c) 
          || (trigger.oldmap.get(opp.id).Structural_PE_Stamp__c !=opp.Structural_PE_Stamp__c) || (trigger.oldmap.get(opp.id).PE_Stamp_Required__c !=opp.PE_Stamp_Required__c) || (trigger.oldmap.get(opp.id).PE_Stamp_Type__c !=opp.PE_Stamp_Type__c) ||  (trigger.oldmap.get(opp.id).Project_Number__c  !=opp.Project_Number__c ) || (trigger.oldmap.get(opp.id).Date_when_Site_Audit_was_Scheduled__c  !=opp.Date_when_Site_Audit_was_Scheduled__c ))
          {
            opptyid.add(opp.id);
          }
        }
        }
         if(!opptyid.isempty()){
             for(Service_Contract_Event__c sce :[ Select opportunity__c,Job_Type__c,Scheduled_Construction_Start_Date__c, Critter_guard__c,SunRun_NTP_Costco_PO_Issued__c,Oracle_Opportunity_Close_Date__c,
                                                 On_Hold_Start_Date__c,On_Hold_End_Date__c,Electrical_PE_Stamp__c,HOA__c,Welcome_Call__c,Welcome_Call_Status__c,Structural_PE_Stamp__c,PE_Stamp_Required__c,
                                                 Reroof_under_array__c,Service_Panel_Upgrade__c,Vaulted_Ceilings__c,Main_Panel_Size_Amps__c,Site_Audit_Complete__c,Layout_Approval_Start__c,
                                                 CAP_date_approved__c,Final_Inspection_Signoff__c,Permit_Submitted_Date__c,Permit_Approval_Date__c,Commencement_of_Construction__c,Completion_of_Construction__c,
                                                 Oracle_Revenue_Amount__c,Permit_Jurisdiction_municipality__c,Plans_Completed_Date__c,Layout_Rcvd__c,
                                                 Submit_Final_Interconnection__c,PP_Notes__c from Service_Contract_Event__c where service_contract__r.opportunity__c in: opptyid]){             
                                                     scemap.put(sce.opportunity__c,sce);
                                                 }
         }

         if(trigger.isupdate){ 
         for(Opportunity opp: trigger.new){  
             
            if(scemap.containskey(opp.id))  {  
                system.debug('This is ---:' +scemap.containskey(opp.id));
                Service_Contract_Event__c sce = scemap.get(opp.id); 
                System.debug('This is SCE' + sce);
                if(trigger.oldmap.get(opp.id).Critter_guard__c!=opp.Critter_guard__c)                   
                sce.Critter_guard__c = opp.Critter_guard__c;
                
                
                if(trigger.oldmap.get(opp.Id).On_Hold_Start_Date__c!= opp.On_Hold_Start_Date__c)
                    sce.On_Hold_Start_Date__c = opp.On_Hold_Start_Date__c ;
                
                if(trigger.oldmap.get(opp.Id).On_Hold_End_Date__c!= opp.On_Hold_End_Date__c)
                    sce.On_Hold_End_Date__c = opp.On_Hold_End_Date__c ;
                
                
            //    if(trigger.oldmap.get(opp.id).Reroof_under_array__c!=opp.Reroof_under_array__c)    
            //    sce.Reroof_under_array__c = opp.Reroof_under_array__c;
                
                if(trigger.oldmap.get(opp.id).Vaulted_Ceilings__c!=opp.Vaulted_Ceilings__c) 
                sce.Vaulted_Ceilings__c = opp.Vaulted_Ceilings__c;
                
                if(trigger.oldmap.get(opp.id).Main_Panel_Size_Amps__c!=opp.Main_Panel_Size_Amps__c)
                sce.Main_Panel_Size_Amps__c = opp.Main_Panel_Size_Amps__c;
                
                if(trigger.oldmap.get(opp.id).Scheduled_Construction_Start_Date__c!=opp.Scheduled_Construction_Start_Date__c)                                
                sce.Scheduled_Construction_Start_Date__c = opp.Scheduled_Construction_Start_Date__c;
                
                System.debug('This is Oppty value '+ opp.Scheduled_Construction_Start_Date__c);
                System.debug('This is SCE value '+ sce.Scheduled_Construction_Start_Date__c);
                
                if(trigger.oldmap.get(opp.id).Job_Type__c!=opp.Job_Type__c)  
                sce.Job_Type__c = opp.Job_Type__c;
                
                if(trigger.oldmap.get(opp.id).SunRun_NTP_Costco_PO_Issued__c!=opp.SunRun_NTP_Costco_PO_Issued__c)                
                sce.SunRun_NTP_Costco_PO_Issued__c = opp.SunRun_NTP_Costco_PO_Issued__c;
                
                if(trigger.oldmap.get(opp.id).Oracle_Opportunity_Close_Date__c!=opp.Oracle_Opportunity_Close_Date__c)                                 
                sce.Oracle_Opportunity_Close_Date__c = opp.Oracle_Opportunity_Close_Date__c;
                
                if(trigger.oldmap.get(opp.id).Oracle_Revenue_Amount__c!=opp.Oracle_Revenue_Amount__c)                
                sce.Oracle_Revenue_Amount__c = opp.Oracle_Revenue_Amount__c;
                
                if(trigger.oldmap.get(opp.id).Permit_Jurisdiction_municipality__c!=opp.Permit_Jurisdiction_municipality__c)                                 
                sce.Permit_Jurisdiction_municipality__c = opp.Permit_Jurisdiction_municipality__c;
                
                if(trigger.oldmap.get(opp.id).Layout_Approval_Start__c!=opp.Layout_Approval_Start__c)  
                sce.Layout_Approval_Start__c = opp.Layout_Approval_Start__c;
               
                if(trigger.oldmap.get(opp.id).Layout_Approval_Finish__c!=opp.Layout_Approval_Finish__c)
                sce.CAP_date_approved__c = opp.Layout_Approval_Finish__c;
                
                if(trigger.oldmap.get(opp.id).Elect_PV_Finish_Date__c!=opp.Elect_PV_Finish_Date__c)
                sce.Final_Inspection_Signoff__c = opp.Elect_PV_Finish_Date__c;                
                
                if(trigger.oldmap.get(opp.id).Permitting_Process_Start_Date__c!=opp.Permitting_Process_Start_Date__c)               
                sce.Permit_Submitted_Date__c = opp.Permitting_Process_Start_Date__c;
                
                if(trigger.oldmap.get(opp.id).Permitting_Process_Finish_Date__c!=opp.Permitting_Process_Finish_Date__c)
                sce.Permit_Approval_Date__c = opp.Permitting_Process_Finish_Date__c;
                
                if(trigger.oldmap.get(opp.id).Actual_Construction_Finish__c!=opp.Actual_Construction_Finish__c)
                sce.Completion_of_Construction__c = opp.Actual_Construction_Finish__c;
                
                if(trigger.oldmap.get(opp.id).Actual_Construction_Start__c!=opp.Actual_Construction_Start__c)
                sce.Commencement_of_Construction__c = opp.Actual_Construction_Start__c;
                
                 if(trigger.oldmap.get(opp.id).Plans_Completed_Date__c!=opp.Plans_Completed_Date__c)
                sce.Plans_Completed_Date__c = opp.Plans_Completed_Date__c;
                
                if(trigger.oldmap.get(opp.id).Submit_Final_Interconnection__c!=opp.Submit_Final_Interconnection__c)
                sce.Submit_Final_Interconnection__c = opp.Submit_Final_Interconnection__c;
                
                if(trigger.oldmap.get(opp.id).Site_Audit_Notes__c != opp.Site_Audit_Notes__c)
                sce.PP_Notes__c = opp.Site_Audit_Notes__c;
                
                // Modified by MA
               
                if(trigger.oldmap.get(opp.id).Electrical_PE_Stamp__c != opp.Electrical_PE_Stamp__c)
                sce.Electrical_PE_Stamp__c = opp.Electrical_PE_Stamp__c;
                
                if(trigger.oldmap.get(opp.id).HOA__c != opp.HOA__c)
                sce.HOA__c = opp.HOA__c;
                
                if(trigger.oldmap.get(opp.id).Welcome_Call__c != opp.Welcome_Call__c)
                sce.Welcome_Call__c = opp.Welcome_Call__c;
                
                if(trigger.oldmap.get(opp.id).Welcome_Call_Status__c != opp.Welcome_Call_Status__c)
                sce.Welcome_Call_Status__c = opp.Welcome_Call_Status__c;
                
               if(trigger.oldmap.get(opp.id).Structural_PE_Stamp__c != opp.Structural_PE_Stamp__c)
               sce.Structural_PE_Stamp__c = opp.Structural_PE_Stamp__c;
             
                if(trigger.oldmap.get(opp.id).PE_Stamp_Required__c != opp.PE_Stamp_Required__c)
                sce.PE_Stamp_Required__c = opp.PE_Stamp_Required__c;
                
                if(trigger.oldmap.get(opp.id).Reroof_under_Array__c != opp.Reroof_under_Array__c)
                sce.Reroof_under_Array__c = opp.Reroof_under_Array__c;
                
                if(trigger.oldmap.get(opp.id).Site_Audit_Scheduled__c != opp.Site_Audit_Scheduled__c)
                sce.Site_Audit_Scheduled__c = opp.Site_Audit_Scheduled__c;
                
                if(trigger.oldmap.get(opp.id).Date_when_Site_Audit_was_Scheduled__c != opp.Date_when_Site_Audit_was_Scheduled__c)
                sce.Date_when_Site_Audit_was_Scheduled__c = opp.Date_when_Site_Audit_was_Scheduled__c;
                
                if(trigger.oldmap.get(opp.id).Site_Audit_Completed__c != opp.Site_Audit_Completed__c)
                sce.Site_Audit_Complete__c = opp.Site_Audit_Completed__c;
                
                if(trigger.oldmap.get(opp.id).Plans_Reviewed_Date__c != opp.Plans_Reviewed_Date__c)
                sce.Plans_Reviewed_Date__c = opp.Plans_Reviewed_Date__c;
                
                if(trigger.oldmap.get(opp.id).Plans_Reviewed_Date__c != opp.Plans_Reviewed_Date__c)
                sce.Layout_Rcvd__c = opp.Plans_Reviewed_Date__c;
                
                 if(trigger.oldmap.get(opp.id).Service_Panel_Upgrade__c != opp.Service_Panel_Upgrade__c)
                sce.Service_Panel_Upgrade__c = opp.Service_Panel_Upgrade__c;
                
                if(trigger.oldmap.get(opp.id).Draft_Quality_Rating__c != opp.Draft_Quality_Rating__c)
                sce.Draft_Quality_Rating__c = Decimal.valueof(opp.Draft_Quality_Rating__c);
                
                if(trigger.oldmap.get(opp.id).External_Drafter__c != opp.External_Drafter__c)
                sce.External_Drafter__c = opp.External_Drafter__c;
                
                 if(trigger.oldmap.get(opp.id).Project_Manager__c != opp.Project_Manager__c)
                sce.Project_Manager__c = opp.Project_Manager__c;
                
                 if(trigger.oldmap.get(opp.id).First_Call_Completed_Date__c != opp.First_Call_Completed_Date__c)
                sce.First_Call_Completed_Date__c = opp.First_Call_Completed_Date__c;
//below two fields copied from Opty to SCE as part of BSKY-5892 08/07/2015 - Arun
                if(trigger.oldmap.get(opp.id).HOA_Name__c != opp.HOA_Name__c)
                sce.HOA_Name__c = opp.HOA_Name__c;
                
                if(trigger.oldmap.get(opp.id).HOA_Notes__c != opp.HOA_Notes__c)
                sce.HOA_Status__c = opp.HOA_Notes__c;
                
//below two fields copied from Opty to SCE as part of BSKY-6036 08/13/2015 - Arun
                if(trigger.oldmap.get(opp.id).PE_Stamp_Ordered__c != opp.PE_Stamp_Ordered__c)
                sce.PE_Stamp_Ordered__c = opp.PE_Stamp_Ordered__c;
                
                if(trigger.oldmap.get(opp.id).PE_Stamp_Received__c != opp.PE_Stamp_Received__c)
                sce.PE_Stamp_Received__c = opp.PE_Stamp_Received__c; 
                
//below three fields copied from Opty to SCE as part of BSKY-6355 09/02/2015 - Arun
                if(trigger.oldmap.get(opp.id).HOA_Application_Submitted_Date__c != opp.HOA_Application_Submitted_Date__c)
                sce.HOA_Application_Submitted_Date__c = opp.HOA_Application_Submitted_Date__c;
                
                if(trigger.oldmap.get(opp.id).ETA_of_HOA_Approval_Date__c != opp.ETA_of_HOA_Approval_Date__c)
                sce.ETA_of_HOA_Approval_Date__c = opp.ETA_of_HOA_Approval_Date__c;
                
                if(trigger.oldmap.get(opp.id).HOA_Approved__c != opp.HOA_Approved__c)
                sce.HOA_Approved__c = opp.HOA_Approved__c;               
                // if(trigger.oldmap.get(opp.id).Project_Number__c != opp.Project_Number__c)
                // sce.Project_Number__c = opp.Project_Number__c;
   
             //   if(trigger.oldmap.get(opp.id).PE_Stamp_Type__c != opp.PE_Stamp_Type__c)
             //   sce.PE_Stamp_Type__c = opp.PE_Stamp_Type__c;
                
                scelist.add(sce);
                system.debug('This is scelist ' +scelist);
                } 
            }           
         }
          if(!scelist.isempty()){
        update scelist;
              }          
      
        if((o.Sales_Representative__c != null) 
          &&(trigger.isInsert || o.Sales_Representative__c != oldOpportunity.Sales_Representative__c))
     {
        setContactIds.add(o.Sales_Representative__c);
        mapContactUserIds.put(o.Sales_Representative__c, Label.DefaultSalespersonForOppty);
        if(oldOpportunity != null && o.Sales_Representative__c != null){
          setContactIds.add(o.Sales_Representative__c);
        }
     }   
   }
   
   if(setContactIds != null && !setContactIds.isEmpty()){
     for(User u:[select id, ContactId from user where ContactId in :setContactIds and isactive = true])
     {
       mapContactUserIds.put(u.ContactId, u.Id);
     }
   }
   List<Opportunityshare>  opportunityShare = new List<Opportunityshare>();
   for(Opportunity o:Trigger.new)
   {
        Id ownerId = mapContactUserIds.get(o.Sales_Representative__c);
        if(ownerId == null){
      continue;
        }

    Opportunity oldOpportunity = null;
    if(trigger.isUpdate){
      oldOpportunity = trigger.oldMap.get(o.Id);
    }  
        
       //Update only if it is a change or on insert
       if(o.Id != null && o.Sales_Representative__c != null 
          && (Trigger.isInsert
              || (Trigger.isUpdate && o.OwnerId != mapContactUserIds.get(o.Sales_Representative__c)&&oldOpportunity.Sales_Representative__c!=o.Sales_Representative__c)
             )
         )
       {
           if(UserInfo.getUserId() != mapContactUserIds.get(o.Sales_Representative__c)){
                OpportunityShare oppShare= new OpportunityShare();
                oppShare.OpportunityAccessLevel = 'Edit';
                oppShare.OpportunityId = o.Id;
                oppShare.UserOrGroupId =  mapContactUserIds.get(o.Sales_Representative__c);
                opportunityShare.add(oppShare); 
           }           
       }
        
   }

   if(opportunityShare.size() > 0){
        //database.upsert(opportunityShare,false);
        try {
         
            Database.SaveResult[] results = Database.insert(opportunityShare,false);
            if (results != null){
                for (Database.SaveResult result : results) {
                    if (!result.isSuccess()) {
                        Database.Error[] errs = result.getErrors();
                        for(Database.Error err : errs)
                            System.debug(err.getStatusCode() + ' - ' + err.getMessage());
         
                    }
                }
            }
         
            } 
          catch (Exception e) {
            System.debug(e.getTypeName() + ' - ' + e.getCause() + ': ' + e.getMessage());
          } 
    }
   if(optyIdProjectStatusMap != null && !optyIdProjectStatusMap.isEmpty()){
        wfUtil.updateWFProjectStatus(optyIdProjectStatusMap);
     } 
  }
 
 }