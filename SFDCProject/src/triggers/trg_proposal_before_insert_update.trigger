/****************************************************************************
Author  : ZCloudInc.net
Date    : July 2012
Description: This trigger implments the SunRun EDP workflow.
*****************************************************************************/
trigger trg_proposal_before_insert_update on Proposal__c (before insert, before update) {
    Boolean skipValidations = false;
    skipValidations = SkipTriggerValidation.performTriggerValidations();
    if(skipValidations == false){ 
        try{
            Map<String, Partners_For_Proposal_Upload__c> partnersForProposalUpload = Partners_For_Proposal_Upload__c.getAll();
            String salesPartnerId = (Trigger.new[0].Sales_Partner__c != null) ? Trigger.new[0].Sales_Partner__c + '' : '';
            //if( (Trigger.new[0].External_Id__c != null && Trigger.new[0].External_Id__c != '') &&
            //  (salesPartnerId != '' && partnersForProposalUpload.containsKey(salesPartnerId.subString(0,15)))){
            //Code changes for Bob's project
            //}
            if( (Trigger.new[0].Mode_Name__c != null && Trigger.new[0].Mode_Name__c == 'Sungevity Bulk Load Only')){
                //Code changes for Bob's project
            }else{
                
                List<Proposal__c> proposalList = new List<Proposal__c>();
                List<Proposal__c> posigenproposalList = new List<Proposal__c>();
                Map<Id,Proposal__c> srOpsReviewd = new Map<Id,Proposal__c>();
                List<Proposal__c> pendingProposalList = new List<Proposal__c>();
                Set<Id> userIds = new Set<Id>();
                Set<String> profileNames = new Set<String>();
                Set<Id> opportunityIdsForProposals = new  Set<Id>();
                Set<Id> customerCreditIds = new  Set<Id>();
                List<Proposal__C> newlySubmittedProposals = new List<Proposal__C>();
                Map<Id, Opportunity> optyMap = new Map<Id, Opportunity>();
                
                Set<Id> propOriginalIds = new Set<Id>();
                set<Id> currentPropIds = new set<Id>();
                Set<Id> opptyIdSet = new Set<Id>();
                Set<Id> propIdSet = new Set<Id>();
                
                Map<Id, Id> opptyIdPrimConIdsMap = new Map<Id, Id>();     
                Map<Id, Contact> conIdConRecMap = new Map<Id, Contact>();
                Set<Id> conIds = new Set<Id>();
                Contact tempCon;
                
                for (proposal__c childProp : trigger.new) {
                    propOriginalIds.add(childProp.Original_Proposal_ID__c);
                }
                
                Map<Id, Proposal__c> ProposalMp =  new Map<Id, Proposal__c>();
                if(!propOriginalIds.isEmpty()){
                    ProposalMp = ProposalUtil.getOriginalProposalMap(propOriginalIds);
                    system.debug('>> ProposalMp' + ProposalMp);
                }
                
                profileNames.add(EDPUtil.SR_OPS);
                profileNames.add(EDPUtil.SR_FINANCE);
                Id edpRecordTypeId = EDPUtil.getTaskEDPRecordType();
                
                List<Id> proposalIdsForReview = new List<Id>();
                User defaultOpsUser = null;
                User defaultFinanceUser = null;
                List<User> userList = EDPUtil.getSRUserDetails();
                User loginUser = EDPUtil.getLoginUser();
                
                String strProposalApprovalLimit1 = Label.ProposalApprovalLimit1;
                if(strProposalApprovalLimit1 == null || strProposalApprovalLimit1 == ''){
                    strProposalApprovalLimit1 = '15';
                }       
                
                String strProposalApprovalLimit2 = Label.ProposalApprovalLimit2;
                if(strProposalApprovalLimit2 == null || strProposalApprovalLimit2 == ''){
                    strProposalApprovalLimit2 = '20';
                } 
                
                Decimal proposalLimit1 = Decimal.valueOf(strProposalApprovalLimit1);
                Decimal proposalLimit2 = Decimal.valueOf(strProposalApprovalLimit2);
                
                for(User userObj : userList){
                    if(defaultOpsUser == null && userObj.name == EDPUtil.USER_NAME_TEST){
                        defaultOpsUser = userObj;
                    }
                    if(defaultFinanceUser == null && userObj.name == EDPUtil.USER_NAME_TEST){
                        defaultFinanceUser = userObj;
                    }
                    
                    if(userObj.name == EDPUtil.USER_NAME_SR_OPS){
                        defaultOpsUser = userObj;
                    }else if(userObj.name == EDPUtil.USER_NAME_SR_FINANCE){
                        defaultFinanceUser = userObj;
                    }
                }   
                
                Map<Id, Proposal__C> changeOrders = new Map<Id, Proposal__C>();
                List<Proposal__C> proposalsForCreditReview = new List<Proposal__C>();
                Map<Id, Proposal__C> proposalsForApprovalReview = new Map<Id, Proposal__C>();
                Map<Id, Proposal__C> proposalsForFinalReview = new Map<Id, Proposal__C>();
                Set<Id> existingProposalIds = new Set<Id>();
                Set<Id> opportunityIds = new  Set<Id>();
                List<Task> taskList = new List<Task>();
                
                if(Trigger.isInsert){
                    ProposalUtil.modifyOpportunity(Trigger.new);
                    ProposalUtil.optyAndContactSharingForProposals(Trigger.new);
                    ProposalUtil.calculateUltimateProposalId(Trigger.new);
                }
                
                if(Trigger.isUpdate){
                    optyMap = ProposalUtil.optyAndContactSharingForInstallPartners(Trigger.newMap, Trigger.oldMap);
                }
                
                Map<Id, Proposal__C> lowUpfrontProposals = new Map<Id, Proposal__C>();
                Set<Id> lowUpforntParentProposals = new Set<Id>();
                Set<String> proposalStagesForVerification = new Set<String>();
                proposalStagesForVerification.add(EDPUtil.SR_OPS_REVIEWED);
                proposalStagesForVerification.add(EDPUtil.CREDIT_APPROVED);
                proposalStagesForVerification.add(EDPUtil.SR_SIGNOFF_REVIEW);
                proposalStagesForVerification.add(EDPUtil.SR_OPS_APPROVED);
                proposalStagesForVerification.add(EDPUtil.CREDIT_REVIEW);
                
                Set<String> invalidProposalStagesForWithdrawn = new Set<String>();
                invalidProposalStagesForWithdrawn.add(EDPUtil.EXPIRED);
                invalidProposalStagesForWithdrawn.add(EDPUtil.REPLACED_BY);
                invalidProposalStagesForWithdrawn.add(EDPUtil.SR_OPS_APPROVED);
                invalidProposalStagesForWithdrawn.add(EDPUtil.SR_DECLINED);
                Map<Id, Proposal__c> partnerFinancedProposalMap = new Map<Id, Proposal__c>();
                Map<Id, Proposal__c> asBuiltProposalMap = new Map<Id, Proposal__c>();
                Set<Id> asBuiltOriginalProposalIds = new Set<Id>();
                
                //ADDED FOR POSIGEN SALESORG 
                List<Proposal__c> listProposal =  new List<Proposal__c>();
                for (Proposal__c proposalObj : Trigger.new) {
                    system.debug('proposalObjproposalObjproposalObj>>.' +  proposalObj);
                    if(trigger.isupdate && Trigger.oldMap.get(proposalObj.Id).Stage__c!= proposalObj.Stage__c && proposalObj.Stage__c==edputil.SR_OPS_REVIEWED && !checkRecursive.duplicateProposalIds.contains(proposalObj.id) ){
                        if(proposalObj.Current_Customer_Credit_Report__c!=null){
                        checkRecursive.duplicateProposalIds.add(proposalObj.id);
                        listProposal.add(proposalObj);
                        }
                        else{
                            proposalObj.Stage__c=edputil.SR_OPS_REVIEWED;
                            // Trigger.newMap.get(proposalObj.id).addError('PosiGen deals requires a Credit Report. Please make sure Credit Report exists.'); 
                        }
                    }
                }
                if(!listProposal.isEmpty()){
                    system.debug('listProposal>>.' +  listProposal);
                    proposalUtil.PosigenCreditProcess(listProposal);
                }
                    
                               
                Set<Id> ccIds = new Set<Id>();                  
                for(Proposal__c proposalObj: Trigger.new) {
                    Proposal__c oldProposalObj;
                    
                    if(trigger.isInsert && proposalObj.Proposal_Source__c != null && proposalObj.Proposal_Source__c == ProposalUtil.BLACK_BIRD 
                       && (proposalObj.cost_stack__c == 'MULTI_PARTY' || proposalObj.cost_stack__c == 'INTEGRATED_SUNRUN_SELLS')){
                           proposalObj.Design_Plan_Review_Required__c = true;
                       }
                    
                    if(trigger.isUpdate){
                        oldProposalObj = Trigger.oldMap.get(proposalObj.Id);
                    }
                    if(proposalObj.Proposal_Source__c != 'BB'){
                        ProposalUtil.updateUsageValues(proposalObj, oldProposalObj);
                    }
                    
                      /*  if(trigger.isUpdate && Trigger.oldMap.get(proposalObj.Id).stage__c == EDPUtil.EXPIRED 
                    && (Trigger.newMap.get(proposalObj.Id).stage__c != Trigger.oldMap.get(proposalObj.Id).stage__c)){
                    Trigger.newMap.get(proposalObj.id).addError(CustomErrorMessages.EXPIRED_ERROR);       
                    } */
                    
                    if(trigger.isUpdate && Trigger.oldMap.get(proposalObj.Id).stage__c == EDPUtil.INACTIVE 
                       && (Trigger.newMap.get(proposalObj.Id).stage__c != Trigger.oldMap.get(proposalObj.Id).stage__c)
                       && (Trigger.newMap.get(proposalObj.Id).stage__c != EDPUtil.CREATED  && 
                           Trigger.newMap.get(proposalObj.Id).stage__c != EDPUtil.Voided && Trigger.newMap.get(proposalObj.Id).stage__c != EDPUtil.EXPIRED) ){
                               Trigger.newMap.get(proposalObj.id).addError(SunrunErrorMessage.getErrorMessage('ERROR_000005').error_message__c); 
                           }
                    
                    // BSKY-4879 - Code to Evaluate the logic for Last Customer Signed Proposal ID  
                    if(( Trigger.isUpdate   || Trigger.isInsert) 
                       && (proposalObj.Proposal_Source__c == ProposalUtil.BLACK_BIRD ) ){
                           if (proposalObj.Change_Order_Information__c != null &&
                               ( proposalObj.Change_Order_Information__c.containsIgnoreCase('FULL_PROPOSAL') || 
                                (proposalObj.Change_Order_Information__c.containsIgnoreCase('CUSTOMER_CHANGE_ORDER') && proposalObj.Signed__c ) )) {
                                    proposalObj.Last_Customer_Signed_Proposal__c = null; 
                                    
                                    System.debug('> Customer Facing ProPosal');  
                                }
                           
                           else if(proposalMP.size() > 0 && proposalObj.Original_proposal_ID__c != Null ) {
                               
                               if(ProposalMp.get(proposalObj.Original_proposal_ID__c).Last_Customer_Signed_Proposal__c != Null  ) {
                                   proposalObj.Last_Customer_Signed_Proposal__c = ProposalMp.get(proposalObj.Original_proposal_ID__c).Last_Customer_Signed_Proposal__c;
                                   
                               }  
                               else if(proposalObj.Original_Proposal_ID__c != null && ProposalMp.get(proposalObj.Original_proposal_ID__c).Signed__c ){
                                   proposalObj.Last_Customer_Signed_Proposal__c = proposalObj.Original_Proposal_ID__c;
                                   
                               }
                               
                               System.debug('> Last_Customer_Signed_Proposal__c' +proposalObj.Last_Customer_Signed_Proposal__c);
                           }
                       }
                    // End Code for BSKY-4879 
                    
                    if(trigger.isUpdate && proposalObj.Stage__c == EDPUtil.SR_OPS_APPROVED
                       && ((proposalObj.SR_Ops_Actions__c != null &&  proposalObj.SR_Ops_Actions__c != '')
                           || (proposalObj.SR_Finance_Action__c != null &&  proposalObj.SR_Finance_Action__c != ''))){
                               Trigger.newMap.get(proposalObj.id).addError(CustomErrorMessages.APPROVED_PROPOSAL_STAGE);       
                           }
                    
                    if(trigger.isupdate && 
                       ((proposalObj.SR_Ops_Actions__c == EDPUtil.WITH_DRAWN && Trigger.oldMap.get(proposalObj.Id).SR_Ops_Actions__c != proposalObj.SR_Ops_Actions__c)
                        ||(proposalObj.SR_Finance_Action__c == EDPUtil.WITH_DRAWN && Trigger.oldMap.get(proposalObj.Id).SR_Finance_Action__c != proposalObj.SR_Finance_Action__c))){
                            
                            if(proposalObj.Stage__c != null && invalidProposalStagesForWithdrawn.contains(proposalObj.Stage__c)){
                                Trigger.newMap.get(proposalObj.id).addError(CustomErrorMessages.NOT_ALLOWED_TO_WITHDRAW); 
                            }else if(proposalObj.Stage__c != null && proposalObj.Stage__c == EDPUtil.PENDING){
                                Trigger.newMap.get(proposalObj.id).addError(CustomErrorMessages.NOT_ALLOWED_TO_WITHDRAW_IN_PENDING); 
                            }
                        }
                    
                    if(trigger.isInsert){
                        if (String.isNotBlank(proposalObj.Primary_Title__c) && String.isNotBlank(proposalObj.Secondary_Title__c)){
                            proposalObj.Name_on_title__c = proposalObj.Primary_Title__c +','+' '+ proposalObj.Secondary_Title__c;
                            system.debug('CombinedTitle  '+proposalObj.Name_on_title__c);
                        }
                        
                        if (String.isBlank(proposalObj.Primary_Title__c) && String.isNotBlank(proposalObj.Secondary_Title__c)){
                            
                            proposalObj.Name_on_title__c = proposalObj.Secondary_Title__c;
                            system.debug('PropSecondaryTitle is  '+proposalObj.Name_on_title__c);
                        }
                        
                        if (String.isNotBlank(proposalObj.Primary_Title__c) && String.isBlank(proposalObj.Secondary_Title__c)){
                            proposalObj.Name_on_title__c = proposalObj.Primary_Title__c;
                            system.debug('PropPrimaryTitle is  '+proposalObj.Name_on_title__c);
                        } 
                    }   
                    
                    
                    if(trigger.isupdate && proposalObj.Name_on_title__c != Trigger.oldMap.get(proposalObj.Id).Name_on_title__c){
                        proposalObj.Title_checked_date__c = DateTime.now();
                    }
                    
                    
                    
                    if(trigger.isupdate && proposalObj.SR_Ops_Actions__c != null 
                       && proposalObj.SR_Ops_Actions__c != '' 
                       && Trigger.oldMap.get(proposalObj.Id).SR_Ops_Actions__c != proposalObj.SR_Ops_Actions__c){
                           proposalObj.Stage__c = proposalObj.SR_Ops_Actions__c;
                           proposalObj.SR_Ops_Actions__c = '';
                       }
                    
                    
                    
                    Opportunity optyObj = optyMap.get(proposalObj.Opportunity__c);  
                   
                     if(trigger.isupdate && proposalObj.SR_Finance_Action__c != null 
                       && proposalObj.SR_Finance_Action__c != '' && optyObj.SalesOrganizationName__c!=Label.PosigenID
                       && Trigger.oldMap.get(proposalObj.Id).SR_Finance_Action__c != proposalObj.SR_Finance_Action__c){
                           proposalObj.Stage__c = proposalObj.SR_Finance_Action__c;
                             proposalObj.SR_Finance_Action__c = '';
                       }
                    
                    
                    //if(trigger.isUpdate && proposalStagesForVerification.contains(proposalObj.Stage__c)
                    //   && (Trigger.oldMap.get(proposalObj.Id).Stage__c != proposalObj.Stage__c 
                    //       || Trigger.oldMap.get(proposalObj.Id).System_Size_Validated_by_SR_Ops__c != proposalObj.System_Size_Validated_by_SR_Ops__c
                    //       || Trigger.oldMap.get(proposalObj.Id).Utility__c != proposalObj.Utility__c 
                    //       || Trigger.oldMap.get(proposalObj.Id).System_Size_STC_DC__c != proposalObj.System_Size_STC_DC__c )){
                    //           if((proposalObj.System_Size_STC_DC__c > proposalLimit1  || proposalObj.Utility__c == 'LADWP' 
                    //               || (optyObj != null && (optyObj.billing_state__c == 'CT' || optyObj.billing_state__c == 'Connecticut')))
                    //              && (proposalObj.System_Size_Validated_by_SR_Ops__c == false )){
                    //                  Trigger.newMap.get(proposalObj.id).addError(CustomErrorMessages.REQUIRES_LARGE_SYSTEM_CHECKS); 
                    //              }
                    //       } 
                    
                    
                    
                    if(trigger.isUpdate && proposalStagesForVerification.contains(proposalObj.Stage__c)
                       && (proposalObj.Proposal_Scenarios__c != ProposalUtil.AS_BUILT)
                       && (Trigger.oldMap.get(proposalObj.Id).Stage__c != proposalObj.Stage__c
                           || Trigger.oldMap.get(proposalObj.Id).EDP_Phase__c != proposalObj.EDP_Phase__c)
                       && (proposalObj.EDP_Phase__c == null || proposalObj.EDP_Phase__c == '')){
                           Trigger.newMap.get(proposalObj.id).addError(CustomErrorMessages.SELECT_EDP_PHASE);      
                       } 
                    
                    
                    if(trigger.isUpdate && proposalObj.Stage__c == EDPUtil.SR_OPS_APPROVED 
                       && proposalObj.Proposal_Scenarios__c != ProposalUtil.AS_BUILT
                       && Trigger.oldMap.get(proposalObj.Id).Stage__c != proposalObj.Stage__c 
                       && EDPUtil.CREDIT_APPROVED != proposalObj.Sunrun_Credit_Status__c){
                           Trigger.newMap.get(proposalObj.id).addError(CustomErrorMessages.REQUIRES_CREDIT_REVIEW);        
                       }        
                    
                    if(trigger.isInsert || trigger.isupdate){
                        proposalObj.Customer_Address__c = (proposalObj.Homeowner_Address__c != null && 
                                                           proposalObj.Homeowner_Address__c != '' && 
                                                           proposalObj.Homeowner_Address__c.length() > 254 ) ? proposalObj.Homeowner_Address__c.substring(0,254) : proposalObj.Homeowner_Address__c;
                        
                        
                        //List<Design_Option__c> designOptionList = [Select id, costPerYearkWh__c,KWH_KWP__c,KWP__c,Module__c,Serial_Number__c,Usage__c,KWH__c,Opportunity__c from Design_Option__c
                        //                                           where Opportunity__c =: proposalObj.Opportunity__c limit 1 ];
                        //if(designOptionList != null && designOptionList.size() > 0){
                        //    Design_Option__c designOptObj = new Design_Option__c();
                        //    designOptObj = designOptionList[0];
                        //    //proposalObj.Number_of_Panels__c = ;
                        //    proposalObj.Modules__c = designOptObj.Module__c;
                        //    proposalObj.System_Size_kWp__c = designOptObj.KWP__c;
                        //    proposalObj.kWh_kWp__c = designOptObj.KWH_KWP__c;
                        //}
                    }
                    
                    //BSKY-2431
                    if(trigger.isInsert || (trigger.isupdate && proposalObj.Promo_Code__c != Trigger.oldMap.get(proposalObj.Id).Promo_Code__c)){
                        List<Promotion__c> promoObjList = [Select id, Promotion_Code__c, Name from Promotion__c where Promotion_Code__c =: proposalObj.Promo_Code__c limit 1];
                        
                        if(promoObjList != null && promoObjList.size() > 0){
                            proposalObj.Lead_Promotion_Id__c = promoObjList[0].id;
                        }   
                    }
                    
                    
                    if(trigger.isInsert){
                        if(proposalObj.Stage__c == null || proposalObj.Stage__c == ''){
                            proposalObj.Stage__c = EDPUtil.CREATED;
                        }
                        proposalObj.Stage_Last_Modified__c = date.today();
                        continue;
                    }
                    
                    if((trigger.isupdate && proposalObj.Assigne__c != null 
                        && proposalObj.Assigne__c != Trigger.oldMap.get(proposalObj.Id).Assigne__c)){
                            proposalList.add(proposalObj);
                            userIds.add(proposalObj.assigne__c);
                        }
                    
                    //BSKY-5975
                    if(trigger.isUpdate && proposalObj.Stage__c == EDPUtil.SR_OPS_APPROVED &&
                       proposalObj.Stage__c != Trigger.oldMap.get(proposalObj.Id).Stage__c){
                           propIdSet.add(proposalObj.id);    
                       }
                    
                                   
                    if(trigger.isUpdate 
                       && (proposalObj.Stage__c != Trigger.oldMap.get(proposalObj.Id).Stage__c )
                       && (Trigger.oldMap.get(proposalObj.Id).Stage__c != EDPUtil.REPLACED_BY)
                       && (proposalObj.Stage__c == EDPUtil.SR_OPS_APPROVED)){
                           
                           if(proposalObj.Proposal_Scenarios__c != ProposalUtil.AS_BUILT){
                               //If the  "Partner Guarantees Rebate" check box is checked on the proposal; 
                               //then the estimate rebate amount is required
                               if(proposalObj.Partner_Guaranteed_Rebate__c == true  && 
                                  (proposalObj.Estimated_Rebate_Amount__c == null 
                                   || proposalObj.Estimated_Rebate_Amount__c <= 0)){
                                       Trigger.newMap.get(proposalObj.id).addError(CustomErrorMessages.REQUIRED_ESTIMATED_REBATE_AMOUNT);                          
                                   }
                               
                               //Verify Credit status
                               if(proposalObj.Sunrun_Credit_Status__c != EDPUtil.CREDIT_APPROVED){
                                   Trigger.newMap.get(proposalObj.Id).addError(CustomErrorMessages.INVALID_CREDIT_STATUS);                         
                               }
                               
                               //If credit status on the opportunity equals to expired;
                               //then alert operations that the credit report has expired and 
                               //that a new credit report should be requested from the partner     
                               if(proposalObj.Opportunity__c != null){
                                   opportunityIds.add(proposalObj.Opportunity__c);
                                   proposalsForFinalReview.put(proposalObj.Id, proposalObj);
                                   proposalIdsForReview.add(proposalObj.Id);
                               }
                           }else if(proposalObj.Proposal_Scenarios__c == ProposalUtil.AS_BUILT && proposalObj.Original_Proposal_ID__c != null){
                               //AS BUILT Proposal
                               asBuiltProposalMap.put(proposalObj.Id, proposalObj);
                               asBuiltOriginalProposalIds.add(proposalObj.Original_Proposal_ID__c);
                           }
                       }else if((trigger.isUpdate && proposalObj.Stage__c != Trigger.oldMap.get(proposalObj.Id).Stage__c
                                 && proposalObj.Stage__c == EDPUtil.SR_OPS_REVIEWED)){
                                     
                                     if((Trigger.oldMap.get(proposalObj.Id).Stage__c == EDPUtil.CREDIT_APPROVED 
                                         || Trigger.oldMap.get(proposalObj.Id).Stage__c == EDPUtil.SR_SIGNOFF_REVIEW)
                                        && proposalObj.Stage__c == EDPUtil.SR_OPS_REVIEWED){
                                            Trigger.newMap.get(proposalObj.Id).addError(CustomErrorMessages.ALREADY_REVIWED_BY_SUNRUN_OPS);                         
                                        }
                                     
                                     //Customer Sign Off Date is should not NULL; 
                                     if(proposalObj.Customer_SignOff_Date__c == null){
                                         Trigger.newMap.get(proposalObj.id).addError(CustomErrorMessages.INVALID_CUSTOMER_SIGNOFF_DATE);                          
                                     }
                                     
                                     if(proposalObj.Opportunity__c != null){
                                         proposalObj.SR_Ops_Reviewed_On__c = Datetime.now();
                                         proposalObj.SR_Ops_Reviewed_By__c  = UserInfo.getUserId();
                                         opportunityIds.add(proposalObj.Opportunity__c);
                                         proposalsForApprovalReview.put(proposalObj.Id, proposalObj);
                                     }
                                     
                                     //if(EDPUtil.CREDIT_APPROVED != proposalObj.Sunrun_Credit_Status__c){   
                                     //    proposalObj.Assigne__c = defaultFinanceUser.Id;
                                     //}
                                     
                                     System.debug('proposalObj.Agreement_Type__c: ' + proposalObj.Agreement_Type__c);
                                     if(((proposalObj.Agreement_Type__c != null && proposalObj.Agreement_Type__c.contains('Prepaid')) && (proposalObj.Partner_Financed__c == true || proposalObj.Total_Solar_Prepay_Required__c == true)) 
                                        || (proposalObj.Agreement_Type__c == ProposalUtil.CUST_OWNED_FULL_UPFRONT || proposalObj.Agreement_Type__c == ProposalUtil.CUST_OWNED_BANK_FINANCE)){
                                            partnerFinancedProposalMap.put(proposalObj.Id, proposalObj);    
                                        }
                                    
                                     
                                 }else if((trigger.isUpdate && proposalObj.Stage__c != Trigger.oldMap.get(proposalObj.Id).Stage__c
                                           && proposalObj.Stage__c == EDPUtil.CREDIT_APPROVED)){
                                               proposalObj.Sunrun_Credit_Status__c = EDPUtil.CREDIT_APPROVED;
                                               proposalObj.Date_Time_Ops_Received_Proposal_back__c = datetime.now();
                                               proposalObj.Assigne__c = defaultOpsUser.Id;            
                                               
                                           }else if(trigger.isUpdate && proposalObj.Stage__c != Trigger.oldMap.get(proposalObj.Id).Stage__c
                                                    && proposalObj.Stage__c == EDPUtil.SUBMITTED){
                                                        
                                                        if(proposalObj.Change_Order_Information__c != null){
                                                            String changeOrderType = ProposalUtil.getProposalType(proposalObj.Change_Order_Information__c);
                                                            if(changeOrderType == ProposalUtil.NO_SIGNATURES_REQUIRED 
                                                               || changeOrderType == ProposalUtil.EPC_CHANGE_ORDER 
                                                               || changeOrderType == ProposalUtil.SALES_PARTNER_CHANGE_ORDER){
                                                                   proposalObj.signed__c = true;
                                                               }
                                                        }
                                                        
                                                        newlySubmittedProposals.add(proposalObj);
                                                        
                                                        if(proposalObj.Change_Order__c == true 
                                                           && proposalObj.Original_Proposal_ID__c != null){
                                                               existingProposalIds.add(proposalObj.Original_Proposal_ID__c);
                                                               changeOrders.put(proposalObj.Id, proposalObj);  
                                                           }
                                                        if(trigger.isUpdate && Trigger.oldMap.get(proposalObj.Id).Stage__c != EDPUtil.PENDING){
                                                            if(proposalObj.Electronically_Signed_Document__c == false){
                                                                proposalObj.Assigne__c = defaultOpsUser.Id;
                                                            }else if(proposalObj.Electronically_Signed_Document__c == true){
                                                                proposalObj.Assigne__c = defaultFinanceUser.Id;
                                                            }
                                                        }
                                                        if(proposalObj.Opportunity__C != null){
                                                            opportunityIdsForProposals.add(proposalObj.Opportunity__C);
                                                        }
                                                        
                                                    }
                    
                    if(trigger.isUpdate && proposalObj.Stage__c != Trigger.oldMap.get(proposalObj.Id).Stage__c
                       && proposalObj.Stage__c == EDPUtil.PENDING){
                           
                           //Pending reasons should be selected for the pending stages.
                           if(proposalObj.Pending_Proposal_Reason__c == null || 
                              proposalObj.Pending_Proposal_Reason__c == ''){
                                  Trigger.newMap.get(proposalObj.id).addError('Select pending reason(s)');    
                              }
                           
                           opportunityIds.add(proposalObj.Opportunity__c);
                           pendingProposalList.add(proposalObj);
                       }
                    
                    if(proposalObj.Pending_Proposal_Reason__c != null 
                       && proposalObj.Pending_Proposal_Reason__c != ''
                       && proposalObj.Stage__c != EDPUtil.PENDING){
                           proposalObj.Pending_Proposal_Reason__c = '';
                           proposalObj.pending_comments__c = '';
                           proposalObj.pending_notes__c = '';
                           
                           if(proposalObj.Current_Customer_Credit_Report__c != null){
                               customerCreditIds.add(proposalObj.Current_Customer_Credit_Report__c);
                           }  
                       }  
                    // System.debug('>>>>Original Proposal ID = ' + proposalObj.Original_Proposal_ID__c);  
                    
                    if(trigger.isInsert){
                        if(proposalObj.Proposal_Source__c != null && proposalObj.Proposal_Source__c == ProposalUtil.BLACK_BIRD
                           && proposalObj.Original_Proposal_ID__c != Null){
                               if(proposalMP.size() > 0 && !proposalMP.isEmpty() && proposalMp.containsKey(proposalObj.Original_Proposal_ID__c) )  
                               {
                                   proposalObj.CVV__c =  ProposalMp.get(proposalObj.Original_proposal_ID__c).cvv__c;
                                   proposalObj.Shopping_Pass__c = ProposalMp.get(proposalObj.Original_proposal_ID__c).Shopping_Pass__c;
                                   
                               }
                               
                           }
                    }
                }
                
                // BSKY-5252 - Code to add the proposal ACH required  from parent proposal
                
                if(trigger.isInsert ) {
                    Set<Id> pIds = new Set<Id>();   
                    for (Proposal__c currentProposal : Trigger.new) {
                        system.debug('>> currentProposal.Original_Proposal_ID__c ' + currentProposal.Original_Proposal_ID__c  );
                        if (currentProposal.Original_Proposal_ID__c != null)
                            pIds.add(currentProposal.Original_Proposal_ID__c);
                    }
                    
                    Map<Id, proposal__c> parentProp = new Map<Id, proposal__c>( [select Id, ACH_Required__c,ACH_Fee_Eligible__c,ExpirationDate__c,Max_Loan_Amount__c,cvv__c,Shopping_Pass__c,
                                                                                 Shopping_Pass_Expiration_Month__c,Shopping_Pass_Expiration_Year__c  from proposal__c where id in :pids]  );
                    system.debug('parentProp>>>' +  parentProp);
                    if (parentProp.size() > 0){
                        
                        for (Proposal__c proposalObj : Trigger.new) {
                            system.debug('proposalObj>>' +  proposalObj);
                            if(proposalObj.Proposal_Source__c != null && proposalObj.Proposal_Source__c == ProposalUtil.BLACK_BIRD
                               && proposalObj.Original_Proposal_ID__c != Null && proposalObj.Agreement_Type__c == ProposalUtil.CUST_OWNED_BANK_FINANCE){
                                   if(parentProp.size() > 0 && !parentProp.isEmpty() && parentProp.containsKey(proposalObj.Original_Proposal_ID__c)  )  
                                   {
                                       system.debug('proposalObj>>>>s' +  proposalObj);
                                       
                                       // Added for Change Order (COBF)
                                       
                                       proposalObj.CVV__c =  parentProp.get(proposalObj.Original_proposal_ID__c).cvv__c;
                                       proposalObj.Shopping_Pass__c = parentProp.get(proposalObj.Original_proposal_ID__c).Shopping_Pass__c;
                                       proposalObj.ExpirationDate__c = parentProp.get(proposalObj.Original_proposal_ID__c).ExpirationDate__c;
                                       proposalObj.Max_Loan_Amount__c = parentProp.get(proposalObj.Original_proposal_ID__c).Max_Loan_Amount__c;
                                       proposalObj.Shopping_Pass_Expiration_Month__c = parentProp.get(proposalObj.Original_proposal_ID__c).Shopping_Pass_Expiration_Month__c;
                                       proposalObj.Shopping_Pass_Expiration_Year__c = parentProp.get(proposalObj.Original_proposal_ID__c).Shopping_Pass_Expiration_Year__c;
                                       system.debug('proposalObj>>>>s' +  proposalObj);
                                   }
                               }
                       /*  if(proposalObj.Proposal_Source__c != null && proposalObj.Proposal_Source__c == ProposalUtil.BLACK_BIRD
                               && proposalObj.Original_Proposal_ID__c != Null && proposalObj.Revised_Customer_SignOff_Date__c == null &&  
                               !proposalObj.Change_Order_Information__c.containsIgnoreCase('FULL_PROPOSAL') && 
                               !proposalObj.Change_Order_Information__c.containsIgnoreCase('CUSTOMER_CHANGE_ORDER') ){
                                   if(parentProp.size() > 0 && !parentProp.isEmpty() && parentProp.containsKey(proposalObj.Original_Proposal_ID__c)  
                                      &&  parentProp.get(proposalObj.Original_Proposal_ID__c).Revised_Customer_Signoff_Date__c != null )  
                                   {
                                       system.debug('parentProp>>>' +  parentProp);
                                       system.debug('parentProp.get(proposalObj.Original_proposal_ID__c).Revised_Customer_Signoff_Date__c' +  parentProp.get(proposalObj.Original_proposal_ID__c).Revised_Customer_Signoff_Date__c);
                                       
                                       proposalObj.Revised_Customer_Signoff_Date__c =  parentProp.get(proposalObj.Original_proposal_ID__c).Revised_Customer_Signoff_Date__c;
                                       
                                   }
                               } */
                            
                        }
                        for (Proposal__c proposalObj : Trigger.new) {
                            proposal__c parentAchReq = parentProp.get(proposalObj.Original_Proposal_ID__c);          
                            if ( ( proposalObj.Proposal_Source__c == null || proposalObj.Proposal_Source__c.equals('PT')) && 
                                parentAchReq != null && proposalObj.Change_Order__c ) {  
                                    System.debug('Parent ACH Fee Eligible:' +  parentAchReq.ACH_Fee_Eligible__c );
                                    proposalObj.ACH_Fee_Eligible__c = parentAchReq.ACH_Fee_Eligible__c;
                                }
                        }
                    } 
                } 
                // End Code For BSKY-5252 
                
                
                //BSKY-5975 - Check if the Primary Contact associated with the Costco Oppty has Member ID 
                if(!propIdSet.isEmpty()){
                    Map<Id, Proposal__c> propIdPropObjMap =  new Map<Id, proposal__c>( [select Id, Opportunity__c, Opportunity__r.Purchased_Thru__c from proposal__c where id in :propIdSet]  );
                    for(Proposal__c prop: propIdPropObjMap.values()){
                        System.debug('prop.Opportunity__r.Purchased_Thru__c : ' +prop.Opportunity__r.Purchased_Thru__c);
                        if(prop.Opportunity__r.Purchased_Thru__c == 'Costco'){
                            opptyIdSet.add(prop.Opportunity__c);   
                        }
                    }
                    
                    if(!opptyIdSet.isEmpty()){
                        opptyIdPrimConIdsMap = EDPUtil.getPrimaryContactIdForOpportunities(opptyIdSet);  
                        for(Id conId: opptyIdPrimConIdsMap.values()){
                            conIds.add(conId); 
                        } 
                        System.debug('conIds : ' +conIds);
                        if(!conIds.isEmpty()){
                            conIdConRecMap = ContactUtil.getContactRec(conIds);   
                            System.debug('opptyIdPrimConIdsMap : '+opptyIdPrimConIdsMap);
                            System.debug('conIdConRecMap :' +conIdConRecMap);
                            for(Id propId: propIdPropObjMap.keySet()){
                                //tempProp = propIdPropObjMap.get(propId);
                                System.debug('prop.Opportunity__c :' +propIdPropObjMap.get(propId).Opportunity__c);
                                tempCon = conIdConRecMap.get(opptyIdPrimConIdsMap.get(propIdPropObjMap.get(propId).Opportunity__c)); 
                                if(tempCon !=null && tempCon.Member_ID__c == null){
                                    Trigger.newMap.get(propIdPropObjMap.get(propId).id).addError('Member ID is required on Primary Contact');
                                }  
                            } 
                        }    
                    }        
                }
                
                //BSKY-5975 - End       
                
                if(!asBuiltProposalMap.isEmpty()){
                    ProposalUtil.processAsBuiltProposals(asBuiltProposalMap, asBuiltOriginalProposalIds);
                }
                
                System.debug('partnerFinancedProposalMap: '  +partnerFinancedProposalMap);
                if(partnerFinancedProposalMap != null && !partnerFinancedProposalMap.isEmpty()){
                    Set<Id> newCCIds = ProposalUtil.createCustomerCreditRecords(partnerFinancedProposalMap);
                    if(newCCIds != null && !newCCIds.isEmpty()){
                        ccIds.addall(newCCIds);
                    }
                }
                
                if(customerCreditIds != null && customerCreditIds.size() > 0){
                    ProposalUtil.resetCustomerCreditPendingComments(customerCreditIds);
                }
                
                Map<Id, Profile> profileMap = EDPUtil.getProfiles(profileNames);
                Map<Id, User> userMap = new Map<Id, User>();
                if(userIds.size() > 0){
                    userMap = EDPUtil.getUserdetails(userIds);
                }
                
                Map<Id, Opportunity> opportunityMap = new Map<Id, Opportunity>();
                if(opportunityIds.size() > 0){
                    opportunityMap = EDPUtil.getOpportunities(opportunityIds);
                }
                
                
                Id proposalAssigne;
                Profile profileObj;
                User assigne;
                
                List<EDPUtil.PendingTask> pendingTaskList = new List<EDPUtil.PendingTask>();
                for(Proposal__c proposalObj : pendingProposalList){
                    if(!EDPUtil.pendingTaskProposalIds.contains(proposalObj.Id)){ 
                        EDPUtil.pendingTaskProposalIds.add(proposalObj.Id);
                        EDPUtil.PendingTask pendingTaskObj = EDPUtil.createProposalPendingTask(edpRecordTypeId, proposalObj);
                        if(pendingTaskObj != null ){
                            if(pendingTaskObj.taskObj != null){
                                taskList.add(pendingTaskObj.taskObj); 
                                pendingTaskList.add(pendingTaskObj);       
                            }
                        }
                    }
                }
                
                if(taskList.size() > 0){
                    Database.DMLOptions dmlo = new Database.DMLOptions();
                    database.insert(taskList, dmlo);
                    for(EDPUtil.PendingTask pendingTaskObj : pendingTaskList){
                        User userObj;
                        if(pendingTaskObj.taskObj.OwnerId != null){
                            userObj = [Select Id, name, contactId, email from User where Id =:pendingTaskObj.taskObj.OwnerId];
                            
                            pendingTaskObj.toAddressList.add(userObj.email);
                            pendingTaskObj.htmlBody = PRMEmailManager.getTaskHTMLBody(pendingTaskObj.subject, Trigger.newmap.get(pendingTaskObj.taskObj.whatId), 
                                                                                      pendingTaskObj.taskObj, userObj);
                            
                            PRMEmailManager.sendEmail(pendingTaskObj.toAddressList, pendingTaskObj.subject, pendingTaskObj.htmlBody);           
                        }
                    }
                }
                
                for(Proposal__c proposalObj: proposalList){
                    proposalAssigne = proposalObj.Assigne__c;
                    if(proposalObj.Assigne__c == null)
                        continue;
                    
                    assigne = userMap.get(proposalAssigne);
                    if(assigne == null)
                        continue;
                    
                    profileObj = profileMap.get(assigne.profileId);
                    if(profileObj == null)
                        continue;
                    
                    if(trigger.isUpdate  && ( (proposalObj.Stage__c == EDPUtil.SR_OPS_APPROVED 
                                               && proposalObj.Stage__c == Trigger.oldMap.get(proposalObj.Id).Stage__c) 
                                             || (proposalObj.Proposal_Scenarios__c == ProposalUtil.AS_BUILT) )) {
                                                 continue;                          
                                             }    
                    
                    if((profileObj.Name == EDPUtil.SR_FINANCE)
                       && assigne.name != EDPUtil.USER_NAME_SR_FINANCE){
                           proposalObj.Stage__c = EDPUtil.CREDIT_REVIEW;
                       }else if((profileObj.Name == EDPUtil.SR_OPS) 
                                && assigne.name != EDPUtil.USER_NAME_SR_OPS){
                                    Proposal__c oldProposalObj = Trigger.oldMap.get(proposalObj.Id);
                                    if(proposalObj.Stage__c != null && proposalObj.Stage__c == EDPUtil.CREDIT_APPROVED 
                                       && Trigger.oldMap.get(proposalObj.Id).Assigne__c == defaultOpsUser.Id 
                                       && Trigger.oldMap.get(proposalObj.Id).Assigne__c != proposalObj.Assigne__c){
                                           proposalObj.Stage__c = EDPUtil.SR_SIGNOFF_REVIEW;
                                       }else{
                                           if(oldProposalObj.Stage__c != EDPUtil.CREDIT_APPROVED 
                                              && proposalObj.Stage__c != EDPUtil.SR_SIGNOFF_REVIEW){
                                                  proposalObj.Stage__c = EDPUtil.SR_OPS_RECEIVED;
                                              }
                                       }
                                }
                    
                    if(trigger.isUpdate){
                        Proposal__c tempOldProposalObj = Trigger.oldMap.get(proposalObj.Id);
                        System.debug('tempOldProposalObj.Stage__c: ' + tempOldProposalObj.Stage__c);
                        System.debug('proposalObj.Stage__c: ' + proposalObj.Stage__c);
                        System.debug('proposalObj.Current_Customer_Credit_Report__c: ' + proposalObj.Current_Customer_Credit_Report__c);
                        if(tempOldProposalObj.Stage__c != proposalObj.Stage__c && proposalObj.Stage__c == EDPUtil.SR_OPS_REVIEWED
                           && proposalObj.Current_Customer_Credit_Report__c != null){
                               ccIds.add(proposalObj.Current_Customer_Credit_Report__c);
                           }
                    }
           
                }
        
                if(existingProposalIds.size() > 0){
                    Map<Id, Proposal__C> existingProposals = EDPUtil.getProposals(existingProposalIds);
                    for(Proposal__c proposalObj: changeOrders.values()){
                        if(proposalObj.Change_Order__c == true 
                           && proposalObj.Original_Proposal_ID__c != null){
                               Proposal__C existingProposal = existingProposals.get(proposalObj.Original_Proposal_ID__c);
                               if(existingProposal != null){
                                   proposalObj.Assigne__c = existingProposal.assigne__c;
                                   proposalObj.Stage__c = EDPUtil.SUBMITTED;  
                               }     
                           }
                    }
                }
      
                
                Map<Id, Customer_Credit__c> ccMap = new Map<Id, Customer_Credit__c>();
                if(ccIds != null && !ccIds.isEmpty()){
                    ccMap = new Map<Id, Customer_Credit__c>([Select Id, Sunrun_Credit_Status__c, Date_Pulled__c, name, Approved_By__c, SRH_Customer_Number__c, Approved__c, Date_Approved__c from Customer_Credit__c where Id in :ccIds]);
                }
                
                
                if(proposalIdsForReview.size() > 0){
                    Map<Id, String> proposalValidationMap = new Map<Id, String>();
                    EDPUtil.performDocumentValidationsForSRApproval(proposalsForFinalReview, proposalValidationMap);
                    for(Id proposalId : proposalValidationMap.keySet()){
                        String tempErrorMessage = proposalValidationMap.get(proposalId);
                        Trigger.newMap.get(proposalId).addError(tempErrorMessage);  
                    }
                    String errorMessage = SRAttachmentManager.verifyDocumentSignatures(proposalIdsForReview);
                    if(errorMessage != EDPUtil.SUCCESS){
                        Id tempProposalId = proposalIdsForReview[0];
                        Trigger.newMap.get(tempProposalId).addError(errorMessage);  
                    }
                }
                Id loginUserId = UserInfo.getUserId();
                Map<Id, Id> optyContactMap = new Map<Id, Id>();
                Map<Id, Customer_Credit__c> modifiedCustomerCredits = new  Map<Id, Customer_Credit__c>();
                
               
                for(Proposal__c proposalObj: proposalsForApprovalReview.values()){
                    Proposal__c tempOldProposalObj = Trigger.oldMap.get(proposalObj.Id);
                    
                    if(trigger.isUpdate && tempOldProposalObj.Stage__c != proposalObj.Stage__c 
                       && proposalObj.Stage__c == EDPUtil.SR_OPS_REVIEWED ){
                           
                           Boolean modifyAssigne = true;               
                           String approver1 = Label.Proposal_Approver_1;
                           String approver2 = Label.Proposal_Approver_2;
                           
                                                           /*
                                //Following approval process has been removed from the business logic.
                                if(proposalObj.Completed_Approval_Process__c != true && (proposalObj.System_Size_Validated_by_SR_Ops__c == true)){
                                if(loginUser.Proposal_Approval_Limit__c == null ||
                                loginUser.Proposal_Approval_Limit__c < proposalObj.System_Size_STC_DC__c){      
                                modifyAssigne = false;
                                Boolean createApprovalProcess = false;
                                Id approverId;
                                if((proposalObj.System_Size_Validated_by_SR_Ops__c == true) 
                                && (proposalObj.System_Size_STC_DC__c != null && proposalObj.System_Size_STC_DC__c  >= proposalLimit2)){
                                proposalObj.Stage__c = (loginUserId != approver2) ? EDPUtil.SR_OPS_RECEIVED : EDPUtil.SR_OPS_REVIEWED;
                                createApprovalProcess = (loginUserId != approver2) ? true : false;
                                approverId = approver2;
                                }else if(proposalObj.System_Size_Validated_by_SR_Ops__c == true){
                                proposalObj.Stage__c = ((loginUserId != approver1) && (loginUserId != approver2)) ? EDPUtil.SR_OPS_RECEIVED : EDPUtil.SR_OPS_REVIEWED;
                                createApprovalProcess = ((loginUserId != approver1) && (loginUserId != approver2)) ? true : false;
                                approverId = approver1;
                                }
                                
                                if(createApprovalProcess == true && !ProposalUtil.inProgressProposalIds.contains(proposalObj.Id)){
                                Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
                                req.setComments('Please Approve the proposal');
                                req.setObjectId(proposalObj.Id); 
                                if(approverId != null){
                                req.setNextApproverIds(new Id[] {approverId});
                                }
                                try{
                                Approval.ProcessResult result = Approval.process(req);
                                }catch(Exception e){
                                Trigger.newMap.get(proposalObj.id).addError('' + e.getMessage());
                                }
                                ProposalUtil.inProgressProposalIds.add(proposalObj.Id);
                                }
                                }
                                }
                                */
                                                           
                           //TODO:
                           //Credit automation ...
                           
                           Opportunity tempOpty = optyMap.get(proposalObj.Opportunity__c);
                           if( proposalObj.Current_Customer_Credit_Report__c != null && 
                              ccMap.containsKey(proposalObj.Current_Customer_Credit_Report__c) &&
                              (EDPUtil.CREDIT_APPROVED != proposalObj.Sunrun_Credit_Status__c) && (proposalObj.Sales_Partner__c!= Label.PosigenID)&&
                              (((proposalObj.Agreement_Type__c != null && proposalObj.Agreement_Type__c.contains('Prepaid')) 
                                && (proposalObj.Partner_Financed__c == true || proposalObj.Total_Solar_Prepay_Required__c == true))
                               || proposalObj.Agreement_Type__c == ProposalUtil.CUST_OWNED_FULL_UPFRONT 
                               || proposalObj.Agreement_Type__c == ProposalUtil.CUST_OWNED_BANK_FINANCE
                               || proposalObj.Name_on_Credit_Verified__c == true)){
                                   
                                   Customer_Credit__c ccObj = ccMap.get(proposalObj.Current_Customer_Credit_Report__c) ;
                                   system.debug('not posigen>>>');
                                   System.debug('ccObj.Date_Pulled__c: ' + ccObj.Date_Pulled__c);
                                   ProposalUtil.updateProposalAndCustomerCreditForCreditAutomation(tempOpty, proposalObj, ccObj, 
                                                                                                   defaultOpsUser, modifiedCustomerCredits,optyContactMap);
                               }
                           
                           System.debug('proposalObj.Sunrun_Credit_Status__c : ' + proposalObj.Sunrun_Credit_Status__c );
                           if(EDPUtil.CREDIT_APPROVED != proposalObj.Sunrun_Credit_Status__c && 
                              proposalObj.Stage__c == EDPUtil.SR_OPS_REVIEWED){   
                                  proposalObj.Assigne__c = defaultFinanceUser.Id;
                                  proposalObj.Completed_Approval_Process__c = true;
                              }   
                       }
                }
                
                if(modifiedCustomerCredits != null && !modifiedCustomerCredits.isEmpty()){
                    system.debug('modifiedCustomerCredits>>' + modifiedCustomerCredits);
                    update modifiedCustomerCredits.values();
                }
                
                for(Proposal__c proposalObj: proposalsForFinalReview.values()){
                    Proposal__c tempOldProposalObj = Trigger.oldMap.get(proposalObj.Id);
                    if(trigger.isUpdate && tempOldProposalObj.Stage__c != proposalObj.Stage__c 
                       && proposalObj.Stage__c == EDPUtil.SR_OPS_APPROVED){
                           
                           //Customer Sign Off Date is should not NULL; 
                           if(!Test.isRunningTest() && proposalObj.Customer_SignOff_Date__c == null){
                               Trigger.newMap.get(proposalObj.id).addError(CustomErrorMessages.INVALID_CUSTOMER_SIGNOFF_DATE);                          
                           }
                           if(proposalObj.SR_Signoff__c == null){
                               proposalObj.SR_Signoff__c = datetime.now();
                           }
                           
                           if((proposalObj.name.indexOf('H') == 0 ) || (proposalObj.name.indexOf('C') == 0 ) || ((proposalObj.name.indexOf('P') == 0 ) && proposalObj.Revised_Proposal__c == true)){
                               proposalObj.Revised_SR_Signoff__c = datetime.now();
                           }
                       }
                } 
                System.debug('optyContactMap: ' + optyContactMap);
                if(optyContactMap != null && !optyContactMap.isEmpty()){
                    ProposalUtil.createCustomerCreditContactRole(optyContactMap);
                }  
            
            
            }
            
            Sf.costcoSyncService.handleProposalsTrigger();      
        }catch(Exception expObj){
            System.debug('Before Trigger: Proposal Exception: ' + expObj);
            for(Proposal__c proposalObj : Trigger.new){
                proposalObj.adderror(expObj.getMessage());
            }
        }
    }
}