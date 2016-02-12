trigger trg_referral_input_before_update on Referral_Input__c (before insert, after insert, before update, after update, before delete, after delete) {
    
If(Trigger.isbefore && (!Trigger.isDelete)) {
  Boolean skipValidations = false;
  skipValidations = SkipTriggerValidation.performTriggerValidations();
  if(skipValidations == false){
         Set<Id> setOppIds = new Set<Id>();
         Set<Id> setAlreadyReferred = new Set<Id>();
         Map<Id, Id> mapOppIdConId = new Map<Id, Id>();
         Map<Id, Id> mapOppIdAccountId = new Map<Id, Id>();
         //Map<Id, Id> mapOppIdToGAId = new Map<Id, Id>(); 
         Map<Id, Id> mapOppIdToSCId = new Map<Id, Id>();
         Set<id> ReferrerContacts=new Set<id>();
         Map<id,ServiceContract> ServiceContractContactMap=new Map<id,ServiceContract>();
         List<Referral_Input__c> listReferrals = new List<Referral_Input__c>();   
         Set<Id> setleadIds = new Set<Id>();
         Set<Id> setSCEIds = new Set<Id>();
         Set<Id> setSCIds = new Set<Id>();
         Set<Id> setSalesOrgIds = new Set<Id>();
    //   Map<Id, Lead> mapleadstatus = new Map<Id, Lead>();
         Map<Id, String> MapLeadStatus = new Map<Id, String>();
         Map<Id, String> MapOpptyStatus = new Map<Id, String>();
         Map<Id, Service_Contract_Event__c> MapOfIDandSCE = new Map<Id, Service_Contract_Event__c>();
         Map<Id, ServiceContract> MapOfIDandSC = new Map<Id, ServiceContract>();
         Map<Id, String> MapOfSalesOrgIDandName = new Map<Id, String>();
         for(Referral_Input__c r:Trigger.New)
         {
           
             if(Trigger.isInsert || (Trigger.isUpdate && r.Lead__c != null && Trigger.oldMap.get(r.Id).Lead__c == null))
            {
              setleadIds.add(r.Lead__c);  
            }
             if(Trigger.isInsert || (Trigger.isUpdate && r.Opportunity__c != null && Trigger.oldMap.get(r.Id).Opportunity__c == null))
            {
              if(r.Opportunity__c != null){
                setOppIds.add(r.Opportunity__c);  
              }
            }
            if(Trigger.isInsert || (Trigger.isUpdate &&r.Source_Contact_Id__c !=null&& Trigger.oldMap.get(r.Id).Source_Contact_Id__c != r.Source_Contact_Id__c))
            {              
              if(r.Source_Contact_Id__c != null){
                ReferrerContacts.add(r.Source_Contact_Id__c);          
              }
            } 
            if(Trigger.isInsert || (Trigger.isUpdate && r.Service_Contract_Event__c != null && Trigger.oldMap.get(r.Id).Service_Contract_Event__c == null))
            {
              setSCEIds.add(r.Service_Contract_Event__c);  
              System.debug('This is SCE Ids :'+ setSCEIds);  
            } 
            if(Trigger.isInsert || (Trigger.isUpdate && r.Service_Contract__c != null && Trigger.oldMap.get(r.Id).Service_Contract__c== null))
            {
              setSCIds.add(r.Service_Contract__c);  
              System.debug('This is SC Ids :'+ setSCIds);  
            }  
            if(Trigger.isUpdate 
               && (((Trigger.oldMap.get(r.Id).Milestone_1_Status__c == null || Trigger.oldMap.get(r.Id).Milestone_1_Status__c != Label.ReferralReadyForPayment) && r.Milestone_1_Status__c == Label.ReferralReadyForPayment)
                   || ((Trigger.oldMap.get(r.Id).Milestone_2_Status__c == null || Trigger.oldMap.get(r.Id).Milestone_2_Status__c != Label.ReferralReadyForPayment) && r.Milestone_2_Status__c == Label.ReferralReadyForPayment)
                   || ((Trigger.oldMap.get(r.Id).Milestone_3_Status__c == null || Trigger.oldMap.get(r.Id).Milestone_3_Status__c != Label.ReferralReadyForPayment) && r.Milestone_3_Status__c == Label.ReferralReadyForPayment)))
            {
              //Check Actual Qualifications for each payment status
              // 
              listReferrals.add(r);
            }
           
         }
         if(!ReferrerContacts.isEmpty()){
           ReferralService refSvc = new ReferralService();
           ServiceContractContactMap=refSvc.ServiceContractContactMap(ReferrerContacts);
         }         
         if(!listReferrals.isEmpty())
         {
             ReferralService refSvc = new ReferralService();
             //Map<Id, String> mapIdToString = refSvc.RetroValidation(listReferrals);
             Map<Id, String> mapIdToString = refSvc.RetroValidationNew(listReferrals);
             if(!mapIdToString.isEmpty())
             {
               for(Referral_Input__c r:Trigger.New)
               {
                 if(mapIdToString.get(r.Source_Contact_id__c) != null)
                 {
                   r.AddError(mapIdToString.get(r.Source_Contact_id__c));
                 }
                 /*
                 if(mapIdToString.get(r.Generation_Asset__c) != null)
                 {
                   r.AddError(mapIdToString.get(r.Generation_Asset__c));
                 }
                 */
                 if(mapIdToString.get(r.Service_Contract__c) != null)
                 {
                   r.AddError(mapIdToString.get(r.Service_Contract__c));
                 }
               }             
             }
         } 
         if(!setLeadIds.isEmpty())
         {    
            for(Lead oLead:[Select Id,Status from Lead where Id in : setleadIds])
           {
              MapLeadStatus.put(oLead.Id, oLead.Status);
           }
         }    
          if(!setOppIds.isEmpty())
         {    
            for(Opportunity oOpp:[SELECT Id, StageName,Service_Contract__c FROM Opportunity where Id in : setOppIds])
           {
              MapOpptyStatus.put(oOpp.Id, oOpp.StageName);
              
           }
         }  
          
         if(!setOppIds.isEmpty())
         {
             for(ServiceContract sc: [Select id,Sales_Organization_Id__c,Status__c,Opportunity__c from ServiceContract where Opportunity__c in:setOppIds ])
             {
                 MapOfIDandSC.put(sc.Opportunity__c,sc);
                 setSCIds.add(sc.id);
               System.debug('this is map:'+ MapOfIDandSC);  
                 If(sc.Sales_Organization_Id__c!=null)
                 {
                     setSalesOrgIds.add(sc.Sales_Organization_Id__c);
                     System.debug('this is setSalesOrgIds:'+ setSalesOrgIds);
                 }
             }   
         }
          if(!setSCIds.isEmpty())
         {
             for(Service_Contract_Event__c sce: [Select id,NTP_Granted__c,Completion_of_Construction__c,M2_proof_substantial_completion__c,Service_Contract__c from Service_Contract_Event__c where Service_Contract__c in:setSCIds ])
             {
                 MapOfIDandSCE.put(sce.Service_Contract__c,sce);
                 System.debug('This is map'+ MapOfIDandSCE);
             }   
         }  
         if(!setSalesOrgIds.isEmpty())
         {
             For (Account SalesOrgName: [Select Id,name from Account where Id in:setSalesOrgIds ])
             {
                 MapOfSalesOrgIDandName.put(SalesOrgName.id,SalesOrgName.Name);
             }    
         }    
         if(!setOppIds.isempty()){      
         for(OpportunityContactRole ocr:[Select Role, OpportunityId, ContactId, Contact.AccountId From OpportunityContactRole where OpportunityId in :setOppIds])
         {
           mapOppIdConId.put(ocr.OpportunityId, ocr.ContactId);
           mapOppIdAccountId.put(ocr.OpportunityId, ocr.Contact.AccountId);
         }
         }
         /*
         for(Generation_Assets__c ga:[select id, Referral_Input__c, Opportunity_Name__c, Customer_Contact__c from Generation_Assets__c where Opportunity_Name__c in :setOppIds])
         {
            mapOppIdToGAId.put(ga.Opportunity_Name__c, ga.Id);
            mapOppIdConId.put(ga.Opportunity_Name__c, ga.Customer_Contact__c);
         }*/
         if(!setOppIds.isempty()){
         for(ServiceContract sc:[select id, Referral__c, Opportunity__c, contactid from ServiceContract where Opportunity__c in :setOppIds])
         {
            mapOppIdToSCId.put(sc.Opportunity__c, sc.Id);
            mapOppIdConId.put(sc.Opportunity__c, sc.contactid);
         }
         }
         for(Referral_Input__c r:Trigger.New)
         {
            if(r.Lead__c!=null && !mapleadstatus.isEmpty() && mapleadstatus.containsKey(r.Lead__c) && mapleadstatus.get(r.Lead__c)=='Created')
            {
               r.Referral_Status__c='Solar Qualification In-progress'; 
            }   
              
            if(r.Lead__c!=null && !mapleadstatus.isEmpty() && mapleadstatus.containsKey(r.Lead__c) && mapleadstatus.get(r.Lead__c)=='Closed Lost')
            {
               r.Referral_Status__c='Not Ready for Solar Now'; 
            } 
            if(r.Lead__c!=null && !mapleadstatus.isEmpty() && mapleadstatus.containsKey(r.Lead__c) && mapleadstatus.get(r.Lead__c)=='Converted')
            {
               r.Referral_Status__c='Solar Consultation In-Progress'; 
            }  
            // System.debug('### This is map###:'+ MapOfIDandSCE.containsKey(r.Service_Contract_Event__c));
          //    if(r.Opportunity__c !=null && !MapOpptyStatus.isEmpty() && MapOpptyStatus.containsKey(r.Opportunity__c) && MapOpptyStatus.get(r.Opportunity__c)!='9. Closed Lost' && (!MapOfIDandSC.containsKey(r.Opportunity__c)) && (!MapOfIDandSCE.containsKey(MapOfIDandSC.get(r.Opportunity__c).id)))
            if(r.Opportunity__c !=null && !MapOpptyStatus.isEmpty() && MapOpptyStatus.containsKey(r.Opportunity__c) && MapOpptyStatus.get(r.Opportunity__c)!='9. Closed Lost' && (!MapOfIDandSC.containsKey(r.Opportunity__c)))
            {
               r.Referral_Status__c='Solar Consultation In-Progress'; 
            }  
          //  if(r.Opportunity__c!=null && MapOfIDandSC.containsKey(r.Opportunity__c) && MapOfIDandSCE.get(MapOfIDandSC.get(r.Opportunity__c).id).NTP_Granted__c==null && MapOfIDandSCE.get(MapOfIDandSC.get(r.Opportunity__c).id).Completion_of_Construction__c==null && MapOfIDandSCE.get(MapOfIDandSC.get(r.Opportunity__c).id).M2_proof_substantial_completion__c==null)
           if(r.Opportunity__c!=null && MapOfIDandSC.containsKey(r.Opportunity__c) && MapOfIDandSCE.containsKey(MapOfIDandSC.get(r.Opportunity__c).id) && MapOfIDandSCE.get(MapOfIDandSC.get(r.Opportunity__c).id).NTP_Granted__c==null && MapOfIDandSCE.get(MapOfIDandSC.get(r.Opportunity__c).id).Completion_of_Construction__c==null && MapOfIDandSCE.get(MapOfIDandSC.get(r.Opportunity__c).id).M2_proof_substantial_completion__c==null)
            {
                r.Referral_Status__c='Solar Consultation In-Progress';
            }  
             if(r.Opportunity__c !=null && !MapOpptyStatus.isEmpty() && MapOpptyStatus.containsKey(r.Opportunity__c) && MapOpptyStatus.get(r.Opportunity__c)=='9. Closed Lost')
            {
               r.Referral_Status__c='Not Ready for Solar Now'; 
            } 
          //  if(r.Service_Contract_Event__c !=null && MapOfIDandSCE.get(MapOfIDandSC.get(r.Opportunity__c).id).NTP_Granted__c!=null && MapOfIDandSCE.get(MapOfIDandSC.get(r.Opportunity__c).id).Completion_of_Construction__c==null && MapOfIDandSCE.get(MapOfIDandSC.get(r.Opportunity__c).id).M2_proof_substantial_completion__c==null)
          //   if(r.Opportunity__c !=null && MapOfIDandSCE.get(MapOfIDandSC.get(r.Opportunity__c).id).NTP_Granted__c!=null && MapOfIDandSCE.get(MapOfIDandSC.get(r.Opportunity__c).id).Completion_of_Construction__c==null && MapOfIDandSCE.get(MapOfIDandSC.get(r.Opportunity__c).id).M2_proof_substantial_completion__c==null)
             if(r.Opportunity__c!=null && MapOfIDandSC.containsKey(r.Opportunity__c) && MapOfIDandSCE.containsKey(MapOfIDandSC.get(r.Opportunity__c).id) &&  MapOfIDandSCE.get(MapOfIDandSC.get(r.Opportunity__c).id).NTP_Granted__c!=null && MapOfIDandSCE.get(MapOfIDandSC.get(r.Opportunity__c).id).Completion_of_Construction__c==null && MapOfIDandSCE.get(MapOfIDandSC.get(r.Opportunity__c).id).M2_proof_substantial_completion__c==null)  
             {
               r.Referral_Status__c='Ready for Installation'; 
             } 
            if(r.Opportunity__c!=null && MapOfIDandSC.containsKey(r.Opportunity__c) && MapOfIDandSCE.containsKey(MapOfIDandSC.get(r.Opportunity__c).id) &&  MapOfIDandSCE.get(MapOfIDandSC.get(r.Opportunity__c).id).NTP_Granted__c!=null && MapOfIDandSCE.get(MapOfIDandSC.get(r.Opportunity__c).id).Completion_of_Construction__c!=null && MapOfIDandSCE.get(MapOfIDandSC.get(r.Opportunity__c).id).M2_proof_substantial_completion__c==null)
             {
              //  If((MapOfSalesOrgIDandName.get(MapOfIDandSC.get(r.Opportunity__c).Sales_Organization_Id__c).contains('Sunrun')))
             If(MapOfIDandSC.get(r.Opportunity__c).Sales_Organization_Id__c==System.Label.Sunrun_Inc_id)
                {   
                System.debug('###');    
                r.Referral_Status__c='Solar Install Complete'; 
                }    
            }  
            if(r.Opportunity__c!=null && MapOfIDandSC.containsKey(r.Opportunity__c) && MapOfIDandSCE.containsKey(MapOfIDandSC.get(r.Opportunity__c).id)  && MapOfIDandSCE.get(MapOfIDandSC.get(r.Opportunity__c).id).NTP_Granted__c!=null && MapOfIDandSCE.get(MapOfIDandSC.get(r.Opportunity__c).id).Completion_of_Construction__c==null && MapOfIDandSCE.get(MapOfIDandSC.get(r.Opportunity__c).id).M2_proof_substantial_completion__c!=null)
             {
             //   If((!MapOfSalesOrgIDandName.get(MapOfIDandSC.get(r.Opportunity__c).Sales_Organization_Id__c).contains('Sunrun')))
             If(MapOfIDandSC.get(r.Opportunity__c).Sales_Organization_Id__c!=System.Label.Sunrun_Inc_id)
               {   
                System.debug('###');    
                r.Referral_Status__c='Solar Install Complete'; 
               }    
            }   
             
             if(r.Opportunity__c != null && !mapOppIdConId.isEmpty() && r.Target_Contact_Id__c == null)
            {
               r.Target_Contact_Id__c = mapOppIdConId.get(r.Opportunity__c);
               r.Target_Account_Id__c = mapOppIdAccountId.get(r.Opportunity__c);
            }
            if(trigger.isInsert||(Trigger.isupdate && r.Source_Contact_Id__c!=null&&Trigger.oldMap.get(r.Id).Source_Contact_Id__c!=r.Source_Contact_Id__c)){
              if(ServiceContractContactMap.containsKey(r.Source_Contact_Id__c)){
              r.Service_Contract_RR__c=ServiceContractContactMap.get(r.Source_Contact_Id__c).id;
              r.Service_Contract_Event_RR__c=ServiceContractContactMap.get(r.Source_Contact_Id__c).Service_Contract_Event__c;
              }
            }
            /*
            if(r.Opportunity__c != null && mapOppIdToGAId.get(r.Opportunity__c) != null && r.Generation_Asset__c == null)
            {
              r.Generation_Asset__c = mapOppIdToGAId.get(r.Opportunity__c);
            }
            */
            if(r.Opportunity__c != null && mapOppIdToSCId.get(r.Opportunity__c) != null && r.Service_Contract__c == null)
            {
              r.Service_Contract__c = mapOppIdToSCId.get(r.Opportunity__c);
            }
         }
         
         Set<Id> setReferralReady = new Set<Id>(); 
         List<Referral_Input__c> ReferralsList = new List<Referral_Input__c>(); 
         for(Referral_Input__c referral:Trigger.New){
           system.debug('Referrer Contact ' + referral.Source_Contact_Stop_Payment__c);
           system.debug('Referee Contact ' + referral.Target_Contact_Stop_payment__c);
              
            //Milestone_1_Status
            if((Trigger.isInsert || Trigger.isUpdate) && referral.Milestone_1_Status__c == Label.ReferralReadyForPayment){
              system.debug('referral.Milestone_1_Status__c : ' + referral.Milestone_1_Status__c);
              if(referral.Referrer_Status_1__c == null || referral.Referrer_Status_1__c == Label.ReferralReadyForPayment || referral.Referrer_Status_1__c == Label.ReferralStopPayment){
                system.debug('referral.Referrer_Status_1__c : ' + referral.Referrer_Status_1__c);
                if(referral.Source_Contact_id__c != null && referral.Source_Contact_Stop_Payment__c == false){
                    system.debug('Qualified for Payment');
                    referral.Referrer_Status_1__c = Label.ReferralReadyForPayment;
                  //   referral.Ambassador_Sync_Field__c = 'Referrer_Status_1__c';
                  //  referral.Ambassador_Sync_Status__c = 'To Be Synced';
                }else if(referral.Source_Contact_id__c != null && referral.Source_Contact_Stop_Payment__c == true){
                  system.debug('Stop Payment');
                  referral.Referrer_Status_1__c =  Label.ReferralStopPayment;
                //  referral.Ambassador_Sync_Field__c = 'Referrer_Status_1__c';
                //  referral.Ambassador_Sync_Status__c = 'To Be Synced';  
                }
              }
              //
              if(referral.Referee_Status_1__c == null || referral.Referee_Status_1__c == Label.ReferralReadyForPayment  || referral.Referee_Status_1__c == Label.ReferralStopPayment){
                system.debug('Referee_Status_1__c : ' + referral.Referee_Status_1__c);
                if(referral.Target_Contact_Id__c != null && referral.Target_Contact_Stop_payment__c == false){
                  system.debug('Qualified for Payment');
                  referral.Referee_Status_1__c = Label.ReferralReadyForPayment;
                  
                }else if(referral.Target_Contact_Id__c != null && referral.Target_Contact_Stop_payment__c == true){
                  system.debug('Stop Payment');
                  referral.Referee_Status_1__c =  Label.ReferralStopPayment;
                  
                }
              }
                   
            }
            //Milestone_2_Status
            if((Trigger.isInsert || Trigger.isUpdate) && referral.Milestone_2_Status__c == Label.ReferralReadyForPayment){
              if(referral.Referrer_Status_2__c == null || referral.Referrer_Status_2__c == Label.ReferralReadyForPayment || referral.Referrer_Status_2__c == Label.ReferralStopPayment){
                system.debug('referral.Referrer_Status_2__c : ' + referral.Referrer_Status_2__c);
                if(referral.Source_Contact_id__c != null && referral.Source_Contact_Stop_Payment__c == false){
                  system.debug('Qualified for Payment');
                  referral.Referrer_Status_2__c = Label.ReferralReadyForPayment;
              //    referral.Ambassador_Sync_Field__c = 'Referrer_Status_2__c';
              //    referral.Ambassador_Sync_Status__c = 'To Be Synced';   
                }else if(referral.Source_Contact_id__c != null && referral.Source_Contact_Stop_Payment__c == true){
                  system.debug('Stop Payment');
                  referral.Referrer_Status_2__c =  Label.ReferralStopPayment;
              //    referral.Ambassador_Sync_Field__c = 'Referrer_Status_2__c';
              //    referral.Ambassador_Sync_Status__c = 'To Be Synced';   
                }
              }
              //
              if(referral.Referee_Status_2__c == null ||referral.Referee_Status_2__c == Label.ReferralReadyForPayment  || referral.Referee_Status_2__c == Label.ReferralStopPayment){
                system.debug('referral.Referee_Status_2__c : ' + referral.Referee_Status_2__c);
                if(referral.Target_Contact_Id__c != null && referral.Target_Contact_Stop_payment__c == false){
                  system.debug('Qualified for Payment');
                  referral.Referee_Status_2__c = Label.ReferralReadyForPayment;
                }else if(referral.Target_Contact_Id__c != null && referral.Target_Contact_Stop_payment__c == true){
                  system.debug('Stop Payment');
                  referral.Referee_Status_2__c =  Label.ReferralStopPayment;
                     
                }
              }
                   
            }
            
            //Milestone_3_Status
            if((Trigger.isInsert || Trigger.isUpdate) && referral.Milestone_3_Status__c == Label.ReferralReadyForPayment){
              if(referral.Referrer_Status_3__c == null || referral.Referrer_Status_3__c == Label.ReferralReadyForPayment || referral.Referrer_Status_3__c == Label.ReferralStopPayment){
                system.debug('referral.Referrer_Status_3__c : ' + referral.Referrer_Status_3__c);
                if(referral.Source_Contact_id__c != null && referral.Source_Contact_Stop_Payment__c == false){
                    system.debug('Qualified for Payment');
                    referral.Referrer_Status_3__c = Label.ReferralReadyForPayment;
                  //  referral.Ambassador_Sync_Field__c = 'Referrer_Status_3__c';
                //  referral.Ambassador_Sync_Status__c = 'To Be Synced'; 
                }else if(referral.Source_Contact_id__c != null && referral.Source_Contact_Stop_Payment__c == true){
                  system.debug('Stop Payment');
                  referral.Referrer_Status_3__c =  Label.ReferralStopPayment;
               //   referral.Ambassador_Sync_Field__c = 'Referrer_Status_3__c';
               //   referral.Ambassador_Sync_Status__c = 'To Be Synced';   
                }
              }
              //
              if(referral.Referee_Status_3__c == null ||referral.Referee_Status_3__c == Label.ReferralReadyForPayment  || referral.Referee_Status_3__c == Label.ReferralStopPayment){
                system.debug('referral.Referee_Status_3__c : ' + referral.Referee_Status_3__c);
                if(referral.Target_Contact_Id__c != null && referral.Target_Contact_Stop_payment__c == false){
                  system.debug('Qualified for Payment');
                  referral.Referee_Status_3__c = Label.ReferralReadyForPayment;
                }else if(referral.Target_Contact_Id__c != null && referral.Target_Contact_Stop_payment__c == true){
                  system.debug('Stop Payment');
                  referral.Referee_Status_3__c =  Label.ReferralStopPayment;
                }
              }
                   
            }
            
         }
  }
}
    Sf.ambassadorSyncService.handleReferralsTrigger();
    Sf.ambassadorSyncService.handleNonAmbassadorReferrals();
}