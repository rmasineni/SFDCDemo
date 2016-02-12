public without sharing class LeadDeDupServiceImpl extends BaseClass implements LeadDedupService{
    public void handleLeadsTrigger() {
        List<Lead> listLeads = new List<Lead>();  
        Map<String, string> leadDupStatusMap = new map<String, string>(); 
        Set<string> addressTokenSet = new set<string>(); 
        Set<string> phoneSet = new set<string>(); 
        Set<string> emailSet = new set<string>(); 
        Set<Id> leadIdSet = new Set<Id>(); 
        Set<Id> leadIdSet1 = new Set<Id>(); 
        Set<Id> deleteLeadIdSet = new Set<Id>(); 
        List<Lead>  possibleMatchingLeadsList = new List<Lead>(); 
        List<OpportunityContactRole>  possibleMatchingOpptysList = new List<OpportunityContactRole>(); 
        List<Opportunity>  possibleMatchingOpptysList1 = new List<Opportunity>(); 

        if(Label.LeadDeDupeMethod != 'AddressPhoneEmail'){
           System.debug('Lead De-Dup Service is not enabled'); 
           return; 
        }

//Before Insert Logic - 
// 1. Detemine if the new lead is duplicate based on Address / Phone / Email 
 
        System.debug('Before isBeforeInsert()'); 
        if (isBeforeInsert()) {
            System.debug('In isBeforeInsert()'); 
            for (Sobject sobj : Trigger.new) {
                Lead lead = (Lead) sobj;
                System.debug('lead.Address_Token__c : '+lead.Address_Token__c); 
                System.debug('lead.Email : ' +lead.Email); 
                System.debug('lead.Phone : ' +lead.Phone); 

                if(lead.Address_Token__c != null || lead.Email != null || lead.Phone != null ){
              
                   listLeads.add(lead);
                    
                   if(lead.Status != null && 
                      lead.Status.equalsIgnoreCase('Created') &&
                      lead.Lead_Status__c == null){
                          System.debug('Setting Lead_Status__c = Open'); 
                          lead.Lead_Status__c = 'Open';
                          lead.Reason__c = null;
                   }
 
                   if(lead.Address_Token__c != null){
                      addressTokenSet.add(lead.Address_Token__c);
                   }

                   if(lead.Email != null){
                      emailSet.add(lead.Email);
                   }

                   if(lead.Phone != null){
                      phoneSet.add(lead.Phone);
                   }
                }
            }
            
            System.debug('addressTokenSet: ' +addressTokenSet);
            System.debug('phoneSet: ' +phoneSet);
            System.debug('emailSet: ' +emailSet);

            if(!addressTokenSet.isEmpty()){
              possibleMatchingOpptysList1 = queryOpportunityWithAddressToken(addressTokenSet);
            }
            System.debug('possibleMatchingOpptysList1 :' +possibleMatchingOpptysList1);

            if(!phoneSet.isEmpty() || !emailSet.isEmpty()){
              possibleMatchingOpptysList = queryOCRWithPhoneEmail(phoneSet, emailSet);                                                    
            }
            System.debug('possibleMatchingOpptysList :' +possibleMatchingOpptysList); 

            if(!addressTokenSet.isEmpty() || !phoneSet.isEmpty() || !emailSet.isEmpty()){
              possibleMatchingLeadsList = queryLead(addressTokenSet, phoneSet, emailSet);                                                                  
            }
            System.debug('possibleMatchingLeadsList :' +possibleMatchingLeadsList);

            leadDupStatusMap = checkLeadDupStatus(listLeads, addressTokenSet, phoneSet, emailSet, possibleMatchingOpptysList1, possibleMatchingOpptysList, possibleMatchingLeadsList); 
                      
/* Update Lead Stage, Status and Reason */
            for (Sobject sobj : Trigger.new) {
                Lead lead = (Lead) sobj;
                String dupStatus = null; 
                String leadKey = lead.Channel__c + '+' +
                                 lead.Custom_Lead_Source__c + '+' +
                                 lead.Lead_Type__c + '+' +   
                                 lead.Address_Token__c + '+' +
                                 lead.Phone + '+' +
                                 lead.Email; 
 

                if(leadDupStatusMap.containsKey(leadKey)){
                   dupStatus = leadDupStatusMap.get(leadKey);   
                   System.debug('dupStatus : ' +dupStatus);
                } 

                if(dupStatus == 'Closed Won Opportunity Found'){
                   lead.Status         = 'Potential Duplicate'; 
                   lead.Lead_Status__c = 'Unqualified'; 
                   lead.Reason__c      = 'Already a Sunrun Customer';
                } else if(dupStatus == 'Closed Lost Opportunity Found - Working With Partner'){
                   if(lead.Technology__c != null && 
                      lead.Technology__c.equalsIgnoreCase('Sunrun.com Click-to-Call')){
                      lead.Status      = 'Potential Duplicate';  
                   }else{
                      lead.Status      = 'Closed Lost'; 
                   }
                   lead.Lead_Status__c = 'Unqualified'; 
                   lead.Reason__c      = 'Working with Partner';
                } else if(dupStatus == 'Closed Lost Opportunity Found'){
                   if(lead.Technology__c != null && 
                      lead.Technology__c.equalsIgnoreCase('Sunrun.com Click-to-Call')){
                      lead.Status      = 'Potential Duplicate';  
                   }else{
                      lead.Status      = 'Closed Lost'; 
                   }
                   lead.Lead_Status__c = 'Unqualified'; 
                   lead.Reason__c      = 'Duplicate Opportunity Found';
                } else if(dupStatus == 'Potential Duplicate Opportunity Found'){
                   lead.Status         = 'Potential Duplicate'; 
                   lead.Lead_Status__c = 'Unqualified'; 
                   lead.Reason__c      = 'Duplicate Opportunity Found';
                } else if(dupStatus == 'Duplicate Opportunity Found'){
                   if(lead.Technology__c != null && 
                      lead.Technology__c.equalsIgnoreCase('Sunrun.com Click-to-Call')){
                      lead.Status      = 'Potential Duplicate';  
                   }else{
                      lead.Status      = 'Closed Lost'; 
                   } 
                   lead.Lead_Status__c = 'Unqualified'; 
                   lead.Reason__c      = 'Duplicate Opportunity Found';
                } else if(dupStatus == 'Potential Duplicate Lead Found'){
                   lead.Status         = 'Potential Duplicate'; 
                   lead.Lead_Status__c = 'Unqualified'; 
                   lead.Reason__c      = 'Duplicate Lead Found';
                } else if(dupStatus == 'Duplicate Lead Found'){
                   if(lead.Technology__c != null && 
                      lead.Technology__c.equalsIgnoreCase('Sunrun.com Click-to-Call')){
                      lead.Status      = 'Potential Duplicate';  
                   }else{
                      lead.Status      = 'Closed Lost'; 
                   }
                   lead.Lead_Status__c = 'Unqualified'; 
                   lead.Reason__c      = 'Duplicate Lead Found';
                }

                System.debug('Lead Key: ' +leadKey);
                System.debug('lead.Status: ' +lead.Status);
                System.debug('lead.Lead_Status__c: ' +lead.Lead_Status__c);
                System.debug('lead.Reason__c: ' +lead.Reason__c);
            }

//Before Update logic 
//1. Determine if the updated lead is duplicate because of updated Address Token / Phone / Email 
    
         } else if (isBeforeUpdate()){
            //  checkRecursive.loadRelatedRecords = true; 
              for (Integer i = 0; i < Trigger.new.size(); i++) {
                  Lead oldLead = (Lead) Trigger.old.get(i);
                  Lead newLead = (Lead) Trigger.new.get(i);    
                  System.debug('oldLead.Address_Token__c : ' +oldLead.Address_Token__c);
                  System.debug('newLead.Address_Token__c : ' +newLead.Address_Token__c); 
                  System.debug('oldlead.Email : ' +oldLead.Email);
                  System.debug('newlead.Email : ' +newLead.Email);
                  System.debug('oldlead.Phone : ' +oldLead.Phone);
                  System.debug('newlead.Phone : ' +newLead.Phone);
                  System.debug('Lead Id: ' +newLead.Id);
 
                  if(!checkRecursive.deDupLeadIds.contains(newLead.Id) &&
                    ( oldLead.Address_Token__c != newLead.Address_Token__c || 
                      oldLead.Email != newLead.Email || 
                      oldLead.Phone != newLead.Phone)){
                      listLeads.add(newLead);
                      leadIdSet.add(newLead.Id); 
                      if(newLead.Id != Null){
                         checkRecursive.deDupLeadIds.add(newLead.Id);
                      }
                      
                      if(newLead.Status != null && 
                        !newLead.Status.equalsIgnoreCase('Out of Market')){
                            newLead.Status = 'Created'; 
                            newLead.Lead_Status__c = 'Open';
                            newLead.Reason__c = null;
                      }
                      
                      if(newLead.Address_Token__c != Null){
                         addressTokenSet.add(newLead.Address_Token__c);
                      }

                      if(newLead.Email != Null){
                         emailSet.add(newLead.Email);
                      }

                      if(newLead.Phone != Null){
                         phoneSet.add(newLead.Phone);
                      } 

                    }
                }

                if(!addressTokenSet.isEmpty()){
                    possibleMatchingOpptysList1 = queryOpportunityWithAddressToken(addressTokenSet);                                                        
                }

                if(!phoneSet.isEmpty() || !emailSet.isEmpty()){
                    possibleMatchingOpptysList = queryOCRWithPhoneEmail(phoneSet, emailSet);                                                         
                }

                if(!addressTokenSet.isEmpty() || !phoneSet.isEmpty() || !emailSet.isEmpty()){
                    If(leadIdSet.isEmpty()){
                        possibleMatchingLeadsList = queryLead(addressTokenSet, phoneSet, emailSet);                                                          
                    }else{
                        possibleMatchingLeadsList = queryLead(addressTokenSet, phoneSet, emailSet, leadIdSet);                                                                                  
                    }                     
                }                     
                
                leadDupStatusMap = checkLeadDupStatus(listLeads, addressTokenSet, phoneSet, emailSet, possibleMatchingOpptysList1, possibleMatchingOpptysList, possibleMatchingLeadsList); 
            
/* Update Lead Stage, Status and Reason */
                for (Sobject sobj : Trigger.new) {
                    Lead lead = (Lead) sobj;
                    String dupStatus = null; 
                    String leadKey = lead.Channel__c + '+' +
                                 lead.Custom_Lead_Source__c + '+' +
                                 lead.Lead_Type__c + '+' +   
                                 lead.Address_Token__c + '+' +
                                 lead.Phone + '+' +
                                 lead.Email; 

                if(leadDupStatusMap.containsKey(leadKey)){
                   dupStatus = leadDupStatusMap.get(leadKey);   
                   System.debug('dupStatus : ' +dupStatus);
                } 

                if(dupStatus == 'Closed Won Opportunity Found'){
                   lead.Status         = 'Potential Duplicate'; 
                   lead.Lead_Status__c = 'Unqualified'; 
                   lead.Reason__c      = 'Already a Sunrun Customer';
                } else if(dupStatus == 'Closed Lost Opportunity Found - Working With Partner'){
                   if(lead.Technology__c != null && 
                      lead.Technology__c.equalsIgnoreCase('Sunrun.com Click-to-Call')){
                      lead.Status      = 'Potential Duplicate';  
                   }else{
                      lead.Status      = 'Closed Lost'; 
                   }
                   lead.Lead_Status__c = 'Unqualified'; 
                   lead.Reason__c      = 'Working with Partner';
                } else if(dupStatus == 'Closed Lost Opportunity Found'){
                   if(lead.Technology__c != null && 
                      lead.Technology__c.equalsIgnoreCase('Sunrun.com Click-to-Call')){
                      lead.Status      = 'Potential Duplicate';  
                   }else{
                      lead.Status      = 'Closed Lost'; 
                   }
                   lead.Lead_Status__c = 'Unqualified'; 
                   lead.Reason__c      = 'Duplicate Opportunity Found';
                } else if(dupStatus == 'Potential Duplicate Opportunity Found'){
                   lead.Status         = 'Potential Duplicate'; 
                   lead.Lead_Status__c = 'Unqualified'; 
                   lead.Reason__c      = 'Duplicate Opportunity Found';
                } else if(dupStatus == 'Duplicate Opportunity Found'){
                   if(lead.Technology__c != null && 
                      lead.Technology__c.equalsIgnoreCase('Sunrun.com Click-to-Call')){
                      lead.Status      = 'Potential Duplicate';  
                   }else{
                      lead.Status      = 'Closed Lost'; 
                   }
                   lead.Lead_Status__c = 'Unqualified'; 
                   lead.Reason__c      = 'Duplicate Opportunity Found';
                } else if(dupStatus == 'Potential Duplicate Lead Found'){
                   lead.Status         = 'Potential Duplicate'; 
                   lead.Lead_Status__c = 'Unqualified'; 
                   lead.Reason__c      = 'Duplicate Lead Found';
                } else if(dupStatus == 'Duplicate Lead Found'){
                   if(lead.Technology__c != null && 
                      lead.Technology__c.equalsIgnoreCase('Sunrun.com Click-to-Call')){
                      lead.Status      = 'Potential Duplicate';  
                   }else{
                      lead.Status      = 'Closed Lost'; 
                   }
                   lead.Lead_Status__c = 'Unqualified'; 
                   lead.Reason__c      = 'Duplicate Lead Found';
                }
                System.debug('Lead Key: ' +leadKey);
                System.debug('lead.Status: ' +lead.Status);
                System.debug('lead.Lead_Status__c: ' +lead.Lead_Status__c);
                System.debug('lead.Reason__c: ' +lead.Reason__c);

            }
         }

// After Insert Logic -
// 1. Update Last click fields for all duplicate direct leads and opportunities. This is executed only when direct leads are updated as True duplicate 
         if (isAfterInsert()) {
            System.debug('After Insert'); 
            List<Partner_Lead_Criteria__c> partnerLeadCriteriaList = Partner_Lead_Criteria__c.getAll().values();
            List<Lead> leadList = new List<Lead>();
            List<Lead> leadList1 = new List<Lead>();
            //checkRecursive.loadRelatedRecords = true; 

            for (Sobject sobj : Trigger.new) {
              Lead lead = (Lead) sobj;
              //listLeads.add(lead);

              if(!isPartnerLead(partnerLeadCriteriaList, lead.Channel__c, lead.Custom_Lead_Source__c, lead.Channel_Last__c, lead.Lead_Source_Last__c) &&
                (lead.Status != null && lead.Status.equalsIgnoreCase('Closed Lost')) &&
                (lead.Lead_Status__c != null && lead.Lead_Status__c.equalsIgnoreCase('Unqualified')) && 
                (lead.Reason__c != null && (lead.Reason__c.equalsIgnoreCase('Duplicate Lead Found') ||
                                            lead.Reason__c.equalsIgnoreCase('Duplicate Opportunity Found') ||
                                            lead.Reason__c.equalsIgnoreCase('Working With Partner')))){

                  leadIdSet.add(lead.Id);
                  leadList.add(lead);
                    
              }//End-if

              if(!isPartnerLead(partnerLeadCriteriaList, lead.Channel__c, lead.Custom_Lead_Source__c, lead.Channel_Last__c, lead.Lead_Source_Last__c) &&
                (lead.Status != null && (lead.Status.equalsIgnoreCase('Potential Duplicate')) &&
                (lead.Lead_Status__c != null && lead.Lead_Status__c.equalsIgnoreCase('Unqualified')) && 
                (lead.Reason__c != null && (lead.Reason__c.equalsIgnoreCase('Duplicate Lead Found') ||
                                            lead.Reason__c.equalsIgnoreCase('Duplicate Opportunity Found') ||
                                            lead.Reason__c.equalsIgnoreCase('Working With Partner') ||
                                            lead.Reason__c.equalsIgnoreCase('Already a Sunrun Customer'))))){

                  leadIdSet1.add(lead.Id);
                  leadList1.add(lead);
                    
              }//End-if
            }//End-for  

 
//Update the Last-Click fields                 
            if(!leadIdSet.isEmpty()){
                updateLastClickForDups(leadIdSet, leadList);   
            } 

//Load Related Records            
            if(!leadIdSet1.isEmpty()){
                loadRelatedRecords(leadIdSet1, leadList1);
            }            
    
         } // End-if isAfterInsert()

// After Update Logic -
// 1. Update Last click fields for all duplicate direct leads and opportunities. This is executed only when direct leads are updated as True duplicate 
         if(isAfterUpdate()){
            System.debug('After Update'); 
            List<Partner_Lead_Criteria__c> partnerLeadCriteriaList = Partner_Lead_Criteria__c.getAll().values();     
            List<Lead> leadList = new List<Lead>();
            List<Lead> leadList1 = new List<Lead>();

            for (Integer i = 0; i < Trigger.new.size(); i++) {
                  Lead oldLead = (Lead) Trigger.old.get(i);
                  Lead newLead = (Lead) Trigger.new.get(i);    

                  if(!checkRecursive.deDupLeadIdsAfterUpdate.contains(newLead.Id) &&
                     !isPartnerLead(partnerLeadCriteriaList, newLead.Channel__c, newLead.Custom_Lead_Source__c, newLead.Channel_Last__c, newLead.Lead_Source_Last__c) &&
                    (((newLead.Address_Token__c != oldLead.Address_Token__c || newLead.Phone != oldLead.Phone || newLead.Email != oldLead.Email) ||
                      (newLead.Status != oldLead.Status || newLead.Lead_Status__c != oldLead.Lead_Status__c || newLead.Reason__c != oldLead.Reason__c)) &&
                     (newLead.Status != null && newLead.Status.equalsIgnoreCase('Closed Lost')) &&
                     (newLead.Lead_Status__c != null && newLead.Lead_Status__c.equalsIgnoreCase('Unqualified')) && 
                     (newLead.Reason__c != null && (newLead.Reason__c.equalsIgnoreCase('Duplicate Lead Found') ||
                                                    newLead.Reason__c.equalsIgnoreCase('Duplicate Opportunity Found') ||
                                                    newLead.Reason__c.equalsIgnoreCase('Working With Partner'))))){
                      leadIdSet.add(newLead.Id);
                      leadList.add(newLead);
                      checkRecursive.deDupLeadIdsAfterUpdate.add(newLead.Id); 
                  }//End-if

                  if(!checkRecursive.loadLeadIdsAfterUpdate.contains(newLead.Id) &&
                     !isPartnerLead(partnerLeadCriteriaList, newLead.Channel__c, newLead.Custom_Lead_Source__c, newLead.Channel_Last__c, newLead.Lead_Source_Last__c)){
                        if(((newLead.Address_Token__c != oldLead.Address_Token__c || newLead.Phone != oldLead.Phone || newLead.Email != oldLead.Email) ||
                           (newLead.Status != oldLead.Status || newLead.Lead_Status__c != oldLead.Lead_Status__c || newLead.Reason__c != oldLead.Reason__c)) &&
                           (newLead.Status != null && newLead.Status.equalsIgnoreCase('Potential Duplicate')) &&
                           (newLead.Lead_Status__c != null && newLead.Lead_Status__c.equalsIgnoreCase('Unqualified')) && 
                           (newLead.Reason__c != null && (newLead.Reason__c.equalsIgnoreCase('Duplicate Lead Found') ||
                                                   newLead.Reason__c.equalsIgnoreCase('Duplicate Opportunity Found') ||
                                                   newLead.Reason__c.equalsIgnoreCase('Working With Partner') ||
                                                   newLead.Reason__c.equalsIgnoreCase('Already a Sunrun Customer')))){

                            leadIdSet1.add(newLead.Id);
                            leadList1.add(newLead);
                            checkRecursive.loadLeadIdsAfterUpdate.add(newLead.Id); 

                        }
                      
                  }//End-if

                  if(oldLead.Status != newLead.Status &&
                    (!newLead.Status.equalsIgnoreCase('Closed Lost') && !newLead.Status.equalsIgnoreCase('Potential Duplicate')) &&
                    (oldLead.Status != null && (oldLead.Status.equalsIgnoreCase('Closed Lost') || oldLead.Status.equalsIgnoreCase('Potential Duplicate'))) &&
                    (oldLead.Lead_Status__c != null && oldLead.Lead_Status__c.equalsIgnoreCase('Unqualified')) && 
                    (oldLead.Reason__c != null && (oldLead.Reason__c.equalsIgnoreCase('Duplicate Lead Found') ||
                                                   oldLead.Reason__c.equalsIgnoreCase('Duplicate Opportunity Found') ||
                                                   oldLead.Reason__c.equalsIgnoreCase('Working With Partner') ||
                                                   oldLead.Reason__c.equalsIgnoreCase('Already a Sunrun Customer')))){
                            
                            deleteLeadIdSet.add(newLead.Id);
                  }

            }//End-for      

//Update the Last-Click fields                 

            if(!leadIdSet.isEmpty()){
                updateLastClickForDups(leadIdSet, leadList);   
            }            

//Delete existing Related Records
            if(!deleteLeadIdSet.isEmpty()){
                List<Related_Leads__c> deleteRelatedRecs = [Select Id from Related_Leads__c where Lead__c in :deleteLeadIdSet]; 
                System.debug('deleteRelatedRecs : ' +deleteRelatedRecs);
                if(!deleteRelatedRecs.isEmpty()){
                    System.debug('Deleting Related Leads');
                    Database.delete(deleteRelatedRecs, false);  
                } 
            }

//Load Related Records            
            if(!leadIdSet1.isEmpty()){
                loadRelatedRecords(leadIdSet1, leadList1);
            }

         } // End-if isAfterUpdate()

    }
    
    public Map<String, String> checkLeadDupStatus(List<lead> leads, Set<String> addressTokenSet, Set<String> phoneSet, Set<String> emailSet, 
                                              List<Opportunity> possibleMatchingOpptysList1, List<OpportunityContactRole> possibleMatchingOpptysList,
                                              List<Lead> possibleMatchingLeadsList){
        
        List<lead> listLeadsDupCheck1 = new List<Lead>();
        List<Lead> listLeadsDupCheck2 = new List<Lead>();  
        List<Lead> listLeadsDupCheck3 = new List<Lead>();  
        List<Lead> listLeadsDupCheck4 = new List<Lead>();  
        List<Lead> listLeadsDupCheck5 = new List<Lead>();  
        List<Lead> listLeadsDupCheck6 = new List<Lead>();  
        Map<String, String> leadDupStatusMap = new map<String, String>(); 
        Map<String, string> leadDupStatusMap1 = new map<String, String>(); 
        Map<String, string> leadDupStatusMap2 = new map<String, String>(); 
        Map<String, string> leadDupStatusMap3 = new map<String, String>(); 
        Map<String, string> leadDupStatusMap4 = new map<String, String>(); 
        Map<String, string> leadDupStatusMap5 = new map<String, String>(); 
        Map<String, string> leadDupStatusMap6 = new map<String, String>(); 

        listLeadsDupCheck1 = leads.clone();
        
        System.debug('leads : ' +leads);
        System.debug('addressTokenSet: ' +addressTokenSet);
        System.debug('phoneSet: ' +phoneSet);
        System.debug('emailSet: ' +emailSet);
        System.debug('possibleMatchingOpptysList1 : ' +possibleMatchingOpptysList1);
        System.debug('possibleMatchingOpptysList  : ' +possibleMatchingOpptysList);
        System.debug('possibleMatchingLeadsList : ' +possibleMatchingLeadsList);
        
        List<Partner_Lead_Criteria__c> partnerLeadCriteriaList = Partner_Lead_Criteria__c.getAll().values();
         
        if(!listLeadsDupCheck1.isEmpty()){
          System.debug('Processing listLeadsDupCheck1');
          leadDupStatusMap1  = checkForDupOpptyWithAddress(listLeadsDupCheck1, possibleMatchingOpptysList1, partnerLeadCriteriaList); 
        }

        listLeadsDupCheck2 = getLeadListForDupCheck(listLeadsDupCheck1,leadDupStatusMap1.keySet());                                       
        if(!listLeadsDupCheck2.isEmpty()){
          System.debug('Processing listLeadsDupCheck2');
          leadDupStatusMap2  = checkForDupLeadWithAddress(listLeadsDupCheck2, possibleMatchingLeadsList, addressTokenSet, partnerLeadCriteriaList);  
        }

        listLeadsDupCheck3 = getLeadListForDupCheck(listLeadsDupCheck2,leadDupStatusMap2.keySet());
        if(!listLeadsDupCheck3.isEmpty()){
          System.debug('Processing listLeadsDupCheck3');
          leadDupStatusMap3  = checkForDupOpptyWithPhone(listLeadsDupCheck3, possibleMatchingOpptysList, phoneSet, partnerLeadCriteriaList);  
        }

        listLeadsDupCheck4 = getLeadListForDupCheck(listLeadsDupCheck3,leadDupStatusMap3.keySet());
        if(!listLeadsDupCheck4.isEmpty()){
          System.debug('Processing listLeadsDupCheck4');
          leadDupStatusMap4  = checkForDupLeadWithPhone(listLeadsDupCheck4, possibleMatchingLeadsList, phoneSet, partnerLeadCriteriaList);  
        }  

        listLeadsDupCheck5 = getLeadListForDupCheck(listLeadsDupCheck4,leadDupStatusMap4.keySet());
        if(!listLeadsDupCheck5.isEmpty()){
          System.debug('Processing listLeadsDupCheck5');
          leadDupStatusMap5  = checkForDupOpptyWithEmail(listLeadsDupCheck5, possibleMatchingOpptysList, emailSet, partnerLeadCriteriaList);  
        }

        listLeadsDupCheck6 = getLeadListForDupCheck(listLeadsDupCheck5,leadDupStatusMap5.keySet());
        if(!listLeadsDupCheck6.isEmpty()){
          System.debug('Processing listLeadsDupCheck6');
          leadDupStatusMap6  = checkForDupLeadWithEmail(listLeadsDupCheck6, possibleMatchingLeadsList, emailSet, partnerLeadCriteriaList);  
        }

        if(!leadDupStatusMap1.isEmpty()){
           System.debug('Adding leadDupStatusMap1');
           leadDupStatusMap.putAll(leadDupStatusMap1);
        }   

        if(!leadDupStatusMap2.isEmpty()){
          System.debug('Adding leadDupStatusMap2');
          leadDupStatusMap.putAll(leadDupStatusMap2);
        }

        if(!leadDupStatusMap3.isEmpty()){
          System.debug('Adding leadDupStatusMap3');
          leadDupStatusMap.putAll(leadDupStatusMap3);
        }

        if(!leadDupStatusMap4.isEmpty()){
          System.debug('Adding leadDupStatusMap4');
          leadDupStatusMap.putAll(leadDupStatusMap4);
        }

        if(!leadDupStatusMap5.isEmpty()){
          System.debug('Adding leadDupStatusMap5');
          leadDupStatusMap.putAll(leadDupStatusMap5);
        }

        if(!leadDupStatusMap6.isEmpty()){
          System.debug('Adding leadDupStatusMap6');
          leadDupStatusMap.putAll(leadDupStatusMap6);
        }
        
        System.debug('leadDupStatusMap : ' +leadDupStatusMap);
        return leadDupStatusMap; 
    } 

    public Map<String, String> checkForDupOpptyWithAddress(List<Lead> leads, List<Opportunity> possibleMatchingOpptysList1, List<Partner_Lead_Criteria__c> partnerLeadCriteriaList){
        Map<String, String> leadIdAddressTokenMap = new Map<String, String>();  
        Map<String, List<Opportunity>> addressTokenOpptyMap = new Map<String, List<Opportunity>>(); 
        Set<String> partnerLeadIdSet = new Set<String>(); 
        Map<String, Lead> idLeadMap = new Map<String, Lead>();
        Map<String, String> opptyMatchingStatusMap = new Map<String, String>(); 
          
        for(Lead l: leads){
            String leadKey = l.Channel__c + '+' +
                             l.Custom_Lead_Source__c + '+' +
                             l.Lead_Type__c + '+' +   
                             l.Address_Token__c + '+' +
                             l.Phone + '+' +
                             l.Email; 
            idLeadMap.put(leadKey, l); 
            if(l.Address_Token__c != null){
               leadIdAddressTokenMap.put(leadKey, l.Address_Token__c);  
            }
            
            if(isPartnerLead(partnerLeadCriteriaList, l.Channel__c, l.Custom_Lead_Source__c, l.Channel_Last__c, l.Lead_Source_Last__c)){
               System.debug('Partner Lead');
               partnerLeadIdSet.add(leadKey); 
            }
        }

        for(Opportunity opp: possibleMatchingOpptysList1)
        {
            List<Opportunity> oppList = new List<Opportunity>(); 
            if(addressTokenOpptyMap.containsKey(opp.Account.Address_Token__c)){
                oppList = addressTokenOpptyMap.get(opp.Account.Address_Token__c);
            }    
            oppList.add(opp);
            addressTokenOpptyMap.put(opp.Account.Address_Token__c, oppList);       
            
        }
        
        for(String leadKey: leadIdAddressTokenMap.keySet()){
            String addToken = leadIdAddressTokenMap.get(leadKey);
            String opptyMatchStatus = null; 
              
            if (addressTokenOpptyMap.containsKey(addToken)){
              
              if (isMatchingOpptyWithStage(addressTokenOpptyMap.get(addToken), '7. Closed Won', null)) {
                  opptyMatchingStatusMap.put(leadKey, 'Closed Won Opportunity Found');
              } else if (!partnerLeadIdSet.contains(leadKey)){
                  
                  if (isMatchingOpptyWithStage(addressTokenOpptyMap.get(addToken), '9. Closed Lost', partnerLeadCriteriaList)){
                        Opportunity dupOppty = getDupOppty(addressTokenOpptyMap.get(addToken), '9. Closed Lost', partnerLeadCriteriaList); 
                        if(dupOppty.Opportunity_Status__c != null && dupOppty.Opportunity_Status__c.equalsIgnoreCase('Working With Partner')){    
                           opptyMatchingStatusMap.put(leadKey, 'Closed Lost Opportunity Found - Working With Partner');
                        }else{
                           opptyMatchingStatusMap.put(leadKey, 'Closed Lost Opportunity Found'); 
                        }
                  } else {
                      opptyMatchStatus = findMatchingOppty(addressTokenOpptyMap.get(addToken), idLeadMap.get(leadKey), partnerLeadCriteriaList);       
                      if (opptyMatchStatus != null){
                          opptyMatchingStatusMap.put(leadKey, opptyMatchStatus);   
                      } //End-If
                  } //End-Else
              } //End-If
            }//End-If
        }//End-For
        
        return opptyMatchingStatusMap;
    }
    
    public Map<String, String> checkForDupLeadWithAddress(List<Lead> leads, List<Lead> possibleMatchingLeadsList, Set<String> addressTokenSet, List<Partner_Lead_Criteria__c> partnerLeadCriteriaList){
        Map<String, String> leadIdAddressTokenMap = new Map<String, String>();  
        Map<String, List<Lead>> addressTokenLeadMap = new Map<String, List<Lead>>(); 
        Set<String> partnerLeadIdSet = new Set<String>(); 
        Map<String, Lead> idLeadMap = new Map<String, Lead>();
        Map<String, String> leadMatchingStatusMap = new Map<String, String>(); 
          
        for(Lead l: leads){
            String leadKey = l.Channel__c + '+' +
                             l.Custom_Lead_Source__c + '+' +
                             l.Lead_Type__c + '+' +   
                             l.Address_Token__c + '+' +
                             l.Phone + '+' +
                             l.Email; 

            idLeadMap.put(leadKey, l); 
            if(l.Address_Token__c != null){
               leadIdAddressTokenMap.put(leadKey, l.Address_Token__c);  
            }

            if(isPartnerLead(partnerLeadCriteriaList, l.Channel__c, l.Custom_Lead_Source__c, l.Channel_Last__c, l.Lead_Source_Last__c)){
               System.debug('Partner Lead');
               partnerLeadIdSet.add(leadKey); 
            }
        }
 
        for(Lead l: possibleMatchingLeadsList)
        {
            List<Lead> leadList = new List<Lead>(); 
            if(addressTokenSet.contains(l.Address_Token__c)){ 
                if(addressTokenLeadMap.containsKey(l.Address_Token__c)){
                  leadList = addressTokenLeadMap.get(l.Address_Token__c);
                }
                  
                leadList.add(l);
                addressTokenLeadMap.put(l.Address_Token__c, leadList);                       
            }
        }
        
        for(String leadKey: leadIdAddressTokenMap.keySet()){
            String addToken = leadIdAddressTokenMap.get(leadKey);
            String leadMatchStatus = null; 
            
            if (!partnerLeadIdSet.contains(leadKey)){  
                if (addressTokenLeadMap.containsKey(addToken)){
              
                    leadMatchStatus = findMatchingLead(addressTokenLeadMap.get(addToken), idLeadMap.get(leadKey), partnerLeadCriteriaList);       
                    if (leadMatchStatus != null){
                        leadMatchingStatusMap.put(leadKey, leadMatchStatus);   
                    }
                }
            }
        }
        
        return leadMatchingStatusMap;
    }

    public Map<String, String> checkForDupOpptyWithPhone(List<Lead> leads, List<OpportunityContactRole> possibleMatchingOCRList, Set<String> phoneSet, List<Partner_Lead_Criteria__c> partnerLeadCriteriaList){
        Map<String, String> leadIdPhoneMap = new Map<String, String>();  
        Map<String, List<OpportunityContactRole>> phoneOCRMap = new Map<String, List<OpportunityContactRole>>(); 
        Set<String> partnerLeadIdSet = new Set<String>(); 
        Map<String, Lead> idLeadMap = new Map<String, Lead>();
        Map<String, String> opptyMatchingStatusMap = new Map<String, String>(); 
          
        for(Lead l: leads){
            String leadKey = l.Channel__c + '+' +
                             l.Custom_Lead_Source__c + '+' +
                             l.Lead_Type__c + '+' +   
                             l.Address_Token__c + '+' +
                             l.Phone + '+' +
                             l.Email; 

            idLeadMap.put(leadKey, l); 
            if(l.Phone != null){
               leadIdPhoneMap.put(leadKey, l.Phone);  
            }

            if(isPartnerLead(partnerLeadCriteriaList, l.Channel__c, l.Custom_Lead_Source__c, l.Channel_Last__c, l.Lead_Source_Last__c)){
               System.debug('Partner Lead');  
               partnerLeadIdSet.add(leadKey); 
            }            
        }
        
        System.debug('possibleMatchingOCRList : ' +possibleMatchingOCRList);
        for(OpportunityContactRole ocr: possibleMatchingOCRList)  
        {
            List<OpportunityContactRole> ocrList = new List<OpportunityContactRole>(); 
            System.debug('ocr : ' +ocr);
            System.debug('ocr.Contact.Phone : ' +ocr.Contact.Phone);
            if(phoneSet.contains(ocr.Contact.Phone)){ 
              System.debug('Entering ----> 1');
              if(phoneOCRMap.containsKey(ocr.Contact.Phone)){
                  System.debug('Entering ----> 2');
                  ocrList = phoneOCRMap.get(ocr.Contact.Phone);
              }    
              ocrList.add(ocr);
              phoneOCRMap.put(ocr.Contact.Phone, ocrList);       
            }
        }
        
        System.debug('phoneOCRMap : ' +phoneOCRMap);
        for(String leadKey: leadIdPhoneMap.keySet()){
            String phoneNum = leadIdPhoneMap.get(leadKey);
            String opptyMatchStatus = null; 
              
            if (phoneOCRMap.containsKey(phoneNum)){
               System.debug('phoneOCRMap.get(phoneNum) : ' +phoneOCRMap.get(phoneNum));
               if (isMatchingOpptyWithStage(phoneOCRMap.get(phoneNum), '7. Closed Won', null)) {
                  opptyMatchingStatusMap.put(leadKey, 'Closed Won Opportunity Found');
               } else if (!partnerLeadIdSet.contains(leadKey)){
                   System.debug('Sunrun Direct Lead'); 
                   if (isMatchingOpptyWithStage(phoneOCRMap.get(phoneNum), '9. Closed Lost', partnerLeadCriteriaList)){
                  
                       OpportunityContactRole dupOCR = getDupOCR(phoneOCRMap.get(phoneNum), '9. Closed Lost', partnerLeadCriteriaList); 
                        if(dupOCR.Opportunity.Opportunity_Status__c != null && dupOCR.Opportunity.Opportunity_Status__c.equalsIgnoreCase('Working With Partner')){    
                           opptyMatchingStatusMap.put(leadKey, 'Closed Lost Opportunity Found - Working With Partner');
                        }else{
                           opptyMatchingStatusMap.put(leadKey, 'Closed Lost Opportunity Found');
                        }

                   }  else {
                        opptyMatchStatus = findMatchingOppty(phoneOCRMap.get(phoneNum), idLeadMap.get(leadKey), partnerLeadCriteriaList);       
                        System.debug('opptyMatchStatus : ' +opptyMatchStatus); 
                        if (opptyMatchStatus != null){
                          opptyMatchingStatusMap.put(leadKey, opptyMatchStatus);   
                        }
                   }
               }
            }
        }            
        return opptyMatchingStatusMap;
    }  


    public Map<String, String> checkForDupLeadWithPhone(List<Lead> leads, List<Lead> possibleMatchingLeadsList, Set<String> phoneSet, List<Partner_Lead_Criteria__c> partnerLeadCriteriaList){
        Map<String, String> leadIdPhoneMap = new Map<String, String>();  
        Map<String, List<Lead>> phoneLeadMap = new Map<String, List<Lead>>(); 
        Set<String> partnerLeadIdSet = new Set<String>(); 
        Map<String, Lead> idLeadMap = new Map<String, Lead>();
        Map<String, String> leadMatchingStatusMap = new Map<String, String>(); 
          
        for(Lead l: leads){
            String leadKey = l.Channel__c + '+' +
                             l.Custom_Lead_Source__c + '+' +
                             l.Lead_Type__c + '+' +   
                             l.Address_Token__c + '+' +
                             l.Phone + '+' +
                             l.Email; 

            idLeadMap.put(leadKey, l); 
            if(l.Phone != null){
               leadIdPhoneMap.put(leadKey, l.Phone);  
            }

            if(isPartnerLead(partnerLeadCriteriaList, l.Channel__c, l.Custom_Lead_Source__c, l.Channel_Last__c, l.Lead_Source_Last__c)){
               System.debug('Partner Lead');
               partnerLeadIdSet.add(leadKey); 
            }            
        }
 
        for(Lead l: possibleMatchingLeadsList)
        {
            List<Lead> leadList = new List<Lead>(); 
            if(phoneSet.contains(l.Phone)){ 
                if(phoneLeadMap.containsKey(l.Phone)){
                  leadList = phoneLeadMap.get(l.Phone);
                }
                  
                leadList.add(l);
                phoneLeadMap.put(l.Phone, leadList);                       
            }
        }
        
        for(String leadKey: leadIdPhoneMap.keySet()){
            String phoneNum = leadIdPhoneMap.get(leadKey);
            String leadMatchStatus = null; 
            
            if (!partnerLeadIdSet.contains(leadKey)){  
              if (phoneLeadMap.containsKey(phoneNum)){
              
                leadMatchStatus = findMatchingLead(phoneLeadMap.get(phoneNum), idLeadMap.get(leadKey), partnerLeadCriteriaList);       
                if (leadMatchStatus != null){
                    leadMatchingStatusMap.put(leadKey, leadMatchStatus);   
                }
              }
            }
        }
        
        return leadMatchingStatusMap;
    }


    public Map<String, String> checkForDupOpptyWithEmail(List<Lead> leads, List<OpportunityContactRole> possibleMatchingOCRList, Set<String> emailSet, List<Partner_Lead_Criteria__c> partnerLeadCriteriaList){
        Map<String, String> leadIdEmailMap = new Map<String, String>();  
        Map<String, List<OpportunityContactRole>> emailOCRMap = new Map<String, List<OpportunityContactRole>>(); 
        Set<String> partnerLeadIdSet = new Set<String>(); 
        Map<String, Lead> idLeadMap = new Map<String, Lead>();
        Map<String, String> opptyMatchingStatusMap = new Map<String, String>(); 
          
        for(Lead l: leads){
            String leadKey = l.Channel__c + '+' +
                             l.Custom_Lead_Source__c + '+' +
                             l.Lead_Type__c + '+' +   
                             l.Address_Token__c + '+' +
                             l.Phone + '+' +
                             l.Email; 

            idLeadMap.put(leadKey, l); 
            if(l.Email != null){
               leadIdEmailMap.put(leadKey, l.Email);  
            }

            if(isPartnerLead(partnerLeadCriteriaList, l.Channel__c, l.Custom_Lead_Source__c, l.Channel_Last__c, l.Lead_Source_Last__c)){
               System.debug('Partner Lead');
               partnerLeadIdSet.add(leadKey); 
            }            
        }
        
        for(OpportunityContactRole ocr: possibleMatchingOCRList)  
        {
            List<OpportunityContactRole> ocrList = new List<OpportunityContactRole>(); 

            if(emailSet.contains(ocr.Contact.Email)){ 
              if(emailOCRMap.containsKey(ocr.Contact.Email)){
                  ocrList = emailOCRMap.get(ocr.Contact.Email);
              }    
              ocrList.add(ocr);
              emailOCRMap.put(ocr.Contact.Email, ocrList);       
            }
        }
        
        for(String leadKey: leadIdEmailMap.keySet()){
            String emailId = leadIdEmailMap.get(leadKey);
            String opptyMatchStatus = null; 
              
            if (emailOCRMap.containsKey(emailId)){
              
                if (isMatchingOpptyWithStage(emailOCRMap.get(emailId), '7. Closed Won', null)) {
                  opptyMatchingStatusMap.put(leadKey, 'Closed Won Opportunity Found');
                } else if (!partnerLeadIdSet.contains(leadKey)){
                  
                    if (isMatchingOpptyWithStage(emailOCRMap.get(emailId), '9. Closed Lost', partnerLeadCriteriaList)){
                       
                        OpportunityContactRole dupOCR = getDupOCR(emailOCRMap.get(emailId), '9. Closed Lost', partnerLeadCriteriaList); 
                        if(dupOCR.Opportunity.Opportunity_Status__c != null && dupOCR.Opportunity.Opportunity_Status__c.equalsIgnoreCase('Working With Partner')){    
                           opptyMatchingStatusMap.put(leadKey, 'Closed Lost Opportunity Found - Working With Partner');
                        }else{
                           opptyMatchingStatusMap.put(leadKey, 'Closed Lost Opportunity Found');
                        }
        
                    } else {
                      opptyMatchStatus = findMatchingOppty(emailOCRMap.get(emailId), idLeadMap.get(leadKey), partnerLeadCriteriaList);       
                      if (opptyMatchStatus != null){
                          opptyMatchingStatusMap.put(leadKey, opptyMatchStatus);   
                      }
                    }
                }
            }
        }
        
        return opptyMatchingStatusMap;
    }  


    public Map<String, String> checkForDupLeadWithEmail(List<Lead> leads, List<Lead> possibleMatchingLeadsList, Set<String> emailSet, List<Partner_Lead_Criteria__c> partnerLeadCriteriaList){
        Map<String, String> leadIdEmailMap = new Map<String, String>();  
        Map<String, List<Lead>> emailLeadMap = new Map<String, List<Lead>>(); 
        Set<String> partnerLeadIdSet = new Set<String>(); 
        Map<String, Lead> idLeadMap = new Map<String, Lead>();
        Map<String, String> leadMatchingStatusMap = new Map<String, String>(); 
          
        for(Lead l: leads){
            String leadKey = l.Channel__c + '+' +
                             l.Custom_Lead_Source__c + '+' +
                             l.Lead_Type__c + '+' +   
                             l.Address_Token__c + '+' +
                             l.Phone + '+' +
                             l.Email; 

            idLeadMap.put(leadKey, l); 
            if(l.Email != null){
               leadIdEmailMap.put(leadKey, l.Email);  
            }

            if(isPartnerLead(partnerLeadCriteriaList, l.Channel__c, l.Custom_Lead_Source__c, l.Channel_Last__c, l.Lead_Source_Last__c)){
               System.debug('Partner Lead');
               partnerLeadIdSet.add(leadKey); 
            }                        
        }
 
        for(Lead l: possibleMatchingLeadsList)
        {
            List<Lead> leadList = new List<Lead>(); 
            if(emailSet.contains(l.Email)){ 
                if(emailLeadMap.containsKey(l.Email)){
                  leadList = emailLeadMap.get(l.Email);
                }
                  
                leadList.add(l);
                emailLeadMap.put(l.Email, leadList);                       
            }
        }
        
        for(String leadKey: leadIdEmailMap.keySet()){
            String emailId = leadIdEmailMap.get(leadKey);
            String leadMatchStatus = null; 
            
            if (!partnerLeadIdSet.contains(leadKey)){  
              if (emailLeadMap.containsKey(emailId)){
               
                leadMatchStatus = findMatchingLead(emailLeadMap.get(emailId), idLeadMap.get(leadKey), partnerLeadCriteriaList);       
                if (leadMatchStatus != null){
                    leadMatchingStatusMap.put(leadKey, leadMatchStatus);   
                }
              }
            }
        }
        
        return leadMatchingStatusMap;
    }

    public boolean isMatchingOpptyWithStage(List<Opportunity> oppList, String opptyStage, List<Partner_Lead_Criteria__c> partnerLeadCriteriaList){
        Boolean result = false; 

        if(opptyStage == '7. Closed Won'){
          for(Opportunity opp: oppList){
              if (opp.stagename == opptyStage){
                  result = true; 
                  break;
              }
          }
        }else{
          for(Opportunity opp: oppList){
              if (opp.stagename == opptyStage && 
                 !isPartnerLead(partnerLeadCriteriaList, opp.Channel_2__c, opp.Lead_Source_2__c, opp.Channel_Last__c, opp.Lead_Source_Last__c)){
                  result = true; 
                  break;
              }
          }          
        }        
        return result;
    }
    
    public Opportunity getDupOppty(List<Opportunity> oppList, String opptyStage, List<Partner_Lead_Criteria__c> partnerLeadCriteriaList){
        Opportunity dupOppty = new Opportunity(); 

        for(Opportunity opp: oppList){
            if (opp.stagename == opptyStage && 
               !isPartnerLead(partnerLeadCriteriaList, opp.Channel_2__c, opp.Lead_Source_2__c, opp.Channel_Last__c, opp.Lead_Source_Last__c)){
                  dupOppty = opp; 
                  break;
            }
        }

        return dupOppty;
    }

    public boolean isMatchingOpptyWithStage(List<OpportunityContactRole> ocrList, String opptyStage, List<Partner_Lead_Criteria__c> partnerLeadCriteriaList){
        System.debug('isMatchingOpptyWithStage');
        System.debug('ocrList : ' +ocrList); 
        boolean result = false; 

        if(opptyStage == '7. Closed Won'){
          for(OpportunityContactRole ocr: ocrList){
              System.debug('ocr.Opportunity.stagename : ' +ocr.Opportunity.stagename);
              if (ocr.Opportunity.stagename == opptyStage){
                  result = true; 
                  break;
              }
          }
        }else{
          for(OpportunityContactRole ocr: ocrList){
              System.debug('ocr.Opportunity.stagename : ' +ocr.Opportunity.stagename);
              if (ocr.Opportunity.stagename == opptyStage && 
                 !isPartnerLead(partnerLeadCriteriaList, ocr.Opportunity.Channel_2__c, ocr.Opportunity.Lead_Source_2__c, ocr.Opportunity.Channel_Last__c, ocr.Opportunity.Lead_Source_Last__c)){
                  result = true; 
                  break;
              }
          }          
        }        
        return result;
    }

    public OpportunityContactRole getDupOCR(List<OpportunityContactRole> ocrList, String opptyStage, List<Partner_Lead_Criteria__c> partnerLeadCriteriaList){
        OpportunityContactRole dupOCR = new OpportunityContactRole(); 

        for(OpportunityContactRole ocr: ocrList){
            System.debug('ocr.Opportunity.stagename : ' +ocr.Opportunity.stagename);
            if (ocr.Opportunity.stagename == opptyStage && 
               !isPartnerLead(partnerLeadCriteriaList, ocr.Opportunity.Channel_2__c, ocr.Opportunity.Lead_Source_2__c, ocr.Opportunity.Channel_Last__c, ocr.Opportunity.Lead_Source_Last__c)){
                  dupOCR = ocr; 
                  break;
              }
          }    
        return dupOCR;
    }

    public String findMatchingOppty(List<Opportunity> oppList, Lead lead, List<Partner_Lead_Criteria__c> partnerLeadCriteriaList){
        String result = null; 
        List<Opportunity> oppNoPartnerList = new List<Opportunity>(); 
        Integer noOfDaysLimit = Integer.valueOf(label.No_Of_Days_Limit_For_DeDup); 

        System.debug('findMatchingOppty'); 
            
        for(Opportunity opp: oppList){
            //if(!opp.Channel_2__c.containsIgnoreCase('Partner')){
            if(!isPartnerLead(partnerLeadCriteriaList, opp.Channel_2__c, opp.Lead_Source_2__c, opp.Channel_Last__c, opp.Lead_Source_Last__c)){
               oppNoPartnerList.add(opp);
            }
        }

        if(!oppNoPartnerList.isEmpty()){
           System.debug('oppList is not empty');
           result = 'Potential Duplicate Opportunity Found'; 
        }
          
        for(Opportunity opp: oppNoPartnerList){
            System.debug('opp.Channel_2__c : ' +opp.Channel_2__c); 
            System.debug('opp.Lead_Source_2__c : ' +opp.Lead_Source_2__c); 
            System.debug('opp.Lead_Type__c : ' +opp.Lead_Type__c); 
            System.debug('lead.Channel__c : ' +lead.Channel__c); 
            System.debug('lead.Custom_Lead_Source__c : ' +lead.Custom_Lead_Source__c); 
            System.debug('lead.Lead_Type__c : ' +lead.Lead_Type__c); 
            Datetime leadCreateDate; 
            if(lead.CreatedDate == null){
              leadCreateDate = Datetime.now(); 
            }else{
              leadCreateDate = lead.CreatedDate; 
            }
            if(opp.createdDate.addDays(noOfDaysLimit) > leadCreateDate){
              if (opp.Channel_2__c == lead.Channel__c && 
                  opp.Lead_Source_2__c == lead.Custom_Lead_Source__c && 
                  opp.Lead_Type__c == lead.Lead_Type__c){
                  result = 'Duplicate Opportunity Found'; 
                  break; 
              }  
            }
        }
        
        System.debug('result : ' +result); 
        return result; 
    }

    public String findMatchingOppty(List<OpportunityContactRole> ocrList, Lead lead, List<Partner_Lead_Criteria__c> partnerLeadCriteriaList){
        String result = null; 
        List<OpportunityContactRole> ocrNoPartnerList = new List<OpportunityContactRole>(); 
        Integer noOfDaysLimit = Integer.valueOf(label.No_Of_Days_Limit_For_DeDup); 

        System.debug('findMatchingOCR'); 

        for(OpportunityContactRole ocr: ocrList){
            
            if(!isPartnerLead(partnerLeadCriteriaList, ocr.Opportunity.Channel_2__c, ocr.Opportunity.Lead_Source_2__c, ocr.Opportunity.Channel_Last__c, ocr.Opportunity.Lead_Source_Last__c)){
               ocrNoPartnerList.add(ocr);
            }
        }

        if(!ocrNoPartnerList.isEmpty()){
           System.debug('ocrList is not isEmpty');
           result = 'Potential Duplicate Opportunity Found'; 
        }
          
        for(OpportunityContactRole ocr: ocrNoPartnerList){
            System.debug('ocr.Channel_2__c : ' +ocr.Opportunity.Channel_2__c); 
            System.debug('ocr.Lead_Source_2__c : ' +ocr.Opportunity.Lead_Source_2__c); 
            System.debug('ocr.Lead_Type__c : ' +ocr.Opportunity.Lead_Type__c); 
            System.debug('lead.Channel__c : ' +lead.Channel__c); 
            System.debug('lead.Custom_Lead_Source__c : ' +lead.Custom_Lead_Source__c); 
            System.debug('lead.Lead_Type__c : ' +lead.Lead_Type__c); 
            System.debug('ocr.Opportunity.CreatedDate : ' +ocr.Opportunity.CreatedDate);
            System.debug('ocr.Opportunity.CreatedDate.addDays(10) : ' +ocr.Opportunity.CreatedDate.addDays(noOfDaysLimit));
            System.debug('lead.CreatedDate : ' +lead.CreatedDate);
            Datetime leadCreateDate; 
            if(lead.CreatedDate == null){
              leadCreateDate = Datetime.now(); 
            }else{
              leadCreateDate = lead.CreatedDate; 
            }
            System.debug('leadCreateDate : ' +leadCreateDate);
            if(ocr.Opportunity.CreatedDate.addDays(noOfDaysLimit) > leadCreateDate){
              if (ocr.Opportunity.Channel_2__c == lead.Channel__c && 
                  ocr.Opportunity.Lead_Source_2__c == lead.Custom_Lead_Source__c && 
                  ocr.Opportunity.Lead_Type__c == lead.Lead_Type__c){
                  result = 'Duplicate Opportunity Found'; 
                  break; 
              }  
            }
        }
        
        System.debug('result : ' +result); 
        return result; 
    }

    public String findMatchingLead(List<Lead> leadList, Lead lead, List<Partner_Lead_Criteria__c> partnerLeadCriteriaList){
        String result = null; 
        Integer noOfDaysLimit = Integer.valueOf(label.No_Of_Days_Limit_For_DeDup); 
        List<Lead> leadNoPartnerList = new List<Lead>(); 
        
        for(Lead l: leadList){
            
            if(!isPartnerLead(partnerLeadCriteriaList, l.Channel__c, l.Custom_Lead_Source__c, l.Channel_Last__c, l.Lead_Source_Last__c)){
               leadNoPartnerList.add(l);
            }
        }

        if(!leadNoPartnerList.isEmpty()){
           result = 'Potential Duplicate Lead Found'; 
        }
          
        if(lead.status != null && lead.status.equalsIgnoreCase('Out Of Market')){
           result = 'Out Of Market'; 
        } else { 

            for(Lead l: leadNoPartnerList){
              Datetime leadCreateDate; 
              if(lead.CreatedDate == null){
                  leadCreateDate = Datetime.now(); 
              }else{
                  leadCreateDate = lead.CreatedDate; 
              }
              if(l.createdDate.addDays(noOfDaysLimit) > leadCreateDate){
                if (l.Channel__c == lead.Channel__c && 
                    l.Custom_Lead_Source__c == lead.Custom_Lead_Source__c && 
                    l.Lead_Type__c == lead.Lead_Type__c){
                    result = 'Duplicate Lead Found'; 
                    break; 
                }  
              }   
            }
        }
        
        return result; 
    }


    public List<lead> getLeadListForDupCheck(List<lead> leadList, Set<String> dupLeadIdSet){
        List<lead> listLeadsForDupCheck = new List<lead>();
        for(Lead l: leadList){
            String leadKey = l.Channel__c + '+' +
                             l.Custom_Lead_Source__c + '+' +
                             l.Lead_Type__c + '+' +   
                             l.Address_Token__c + '+' +
                             l.Phone + '+' +
                             l.Email; 
            if(!dupLeadIdSet.contains(leadKey)){
               listLeadsForDupCheck.add(l); 
            } 
        }

        return listLeadsForDupCheck;
    }

    public static boolean isPartnerLead(List<Partner_Lead_Criteria__c> partnerLeadCriteriaList, String channel, String leadSource,
                                 String channelLast, String leadSourceLast){
        boolean result = false; 

        for(Partner_Lead_Criteria__c partnerLeadCriteria: partnerLeadCriteriaList){
            if((channel != null && channel.equalsIgnoreCase(partnerLeadCriteria.Channel__c) && 
                leadSource != null && leadSource.equalsIgnoreCase(partnerLeadCriteria.Lead_Source__c)) ||
               (channelLast != null && channelLast.equalsIgnoreCase(partnerLeadCriteria.Channel__c) && 
                leadSourceLast != null && leadSourceLast.equalsIgnoreCase(partnerLeadCriteria.Lead_Source__c))){
                  result = true;
                  break; 
            } 
        }  

        return result; 
    } 

    public static List<Opportunity> queryOpportunityWithAddressToken(Set<String> addressTokenSet){
          List<Opportunity> possibleMatchingOpptysList1 = [select id, Channel_2__c, Lead_Source_2__c, Lead_Type__c, StageName, Reason__c, Opportunity_Status__c, 
                                                                  Account.Address_Token__c, CreatedDate, Channel_Last__c, Lead_Source_Last__c,
                                                                  Last_Modified_Date_Last_Click__c
                                                             from Opportunity  
                                                            where Accountid in (select id 
                                                                                  from Account 
                                                                                 where Address_Token__c in :addressTokenSet)
                                                         order by CreatedDate desc limit 10];

          return possibleMatchingOpptysList1; 
    }

    public static List<OpportunityContactRole> queryOCRWithPhoneEmail(Set<String> phoneSet, Set<String> emailSet){
           List<OpportunityContactRole> possibleMatchingOpptysList; 
        if(phoneSet !=null && phoneSet.size()>0 && emailSet !=null && emailSet.size()>0){
               possibleMatchingOpptysList = [select OpportunityId, Opportunity.Channel_2__c, Opportunity.Lead_Source_2__c, 
                                                                             Opportunity.Lead_Type__c, Opportunity.StageName, Opportunity.Opportunity_Status__c, Opportunity.Reason__c, 
                                                                             Contact.Phone, Contact.Email, Opportunity.CreatedDate, 
                                                                             Opportunity.Channel_Last__c, Opportunity.Lead_Source_Last__c, 
                                                                             Opportunity.Last_Modified_Date_Last_Click__c 
                                                                        from OpportunityContactRole  
                                                                       where IsPrimary = true 
                                                                         and (Contact.Phone in :phoneSet 
                                                                          or Contact.Email in :emailSet)
                                                                    order by CreatedDate desc limit 10];
        }
        else   if(phoneSet !=null && phoneSet.size()>0){
               possibleMatchingOpptysList = [select OpportunityId, Opportunity.Channel_2__c, Opportunity.Lead_Source_2__c, 
                                                                             Opportunity.Lead_Type__c, Opportunity.StageName, Opportunity.Opportunity_Status__c, Opportunity.Reason__c, 
                                                                             Contact.Phone, Contact.Email, Opportunity.CreatedDate, 
                                                                             Opportunity.Channel_Last__c, Opportunity.Lead_Source_Last__c, 
                                                                             Opportunity.Last_Modified_Date_Last_Click__c 
                                                                        from OpportunityContactRole  
                                                                       where IsPrimary = true
                                                                         and Contact.Phone in :phoneSet order by CreatedDate desc limit 10];
        }
         else if(emailSet !=null && emailSet.size()>0){
               possibleMatchingOpptysList = [select OpportunityId, Opportunity.Channel_2__c, Opportunity.Lead_Source_2__c, 
                                                                             Opportunity.Lead_Type__c, Opportunity.StageName, Opportunity.Opportunity_Status__c, Opportunity.Reason__c, 
                                                                             Contact.Phone, Contact.Email, Opportunity.CreatedDate, 
                                                                             Opportunity.Channel_Last__c, Opportunity.Lead_Source_Last__c, 
                                                                             Opportunity.Last_Modified_Date_Last_Click__c 
                                                                        from OpportunityContactRole 
                                                                        where IsPrimary = true
                                                                         and Contact.Email in :emailSet order by CreatedDate desc limit 10];
        }       

           return possibleMatchingOpptysList;                                       
    }

    public static List<Lead> queryLead(Set<String> addressTokenSet, Set<String> phoneSet, Set<String> emailSet){
           List<Lead> possibleMatchingLeadsList = [select id, Channel__c, Custom_Lead_Source__c, Lead_Type__c, Status, Lead_Status__c, 
                                                          Email, Phone, Address_Token__c, CreatedDate, 
                                                          Channel_Last__c, Lead_Source_Last__c, 
                                                          Last_Modified_Date_Last_Click__c  
                                                     from Lead  
                                                    where isConverted = false
                                                      and (Address_Token__c in :addressTokenSet
                                                       or  Phone in :phoneSet
                                                       or  Email in :emailSet)
                                                 order by CreatedDate desc limit 10];      

           return possibleMatchingLeadsList; 
    } 

    public static List<Lead> queryLead(Set<String> addressTokenSet, Set<String> phoneSet, Set<String> emailSet, Set<Id> leadIdSet){
           List<Lead> possibleMatchingLeadsList = [select id, Channel__c, Custom_Lead_Source__c, Lead_Type__c, Status, Lead_Status__c, 
                                                          Email, Phone, Address_Token__c, CreatedDate,
                                                          Channel_Last__c, Lead_Source_Last__c, 
                                                          Last_Modified_Date_Last_Click__c  
                                                     from Lead  
                                                    where isConverted = false
                                                      and (Address_Token__c in :addressTokenSet
                                                       or  Phone in :phoneSet
                                                       or  Email in :emailSet)
                                                      and  id not in :leadIdSet
                                                 order by CreatedDate desc limit 10];    

           return possibleMatchingLeadsList; 
    } 

    public static List<Lead> queryLeadwithId(Set<Id> leadIdSet){
           List<Lead> listLeads = [select id, Channel__c, Custom_Lead_Source__c, Lead_Type__c, Status, Lead_Status__c,
                                          Email, Phone, Address_Token__c, CreatedDate, 
                                          Channel_Last__c, Lead_Source_Last__c , Lead_Type_Last__c, 
                                          Campaign_Last__c, Keywords_Last__c, Content_Last__c, Technology_Last__c,
                                          Last_Modified_Date_Last_Click__c
                                     from Lead  
                                    where isConverted = false
                                      and Id in :leadIdSet
                                 order by CreatedDate desc limit 10];      

           return listLeads; 
    } 

//@future   
    public static void updateLastClickForDups(Set<Id> leadIdSet, List<Lead> listLeads){
        System.debug('In updateLastClickForDups'); 

        List<Lead>  possibleMatchingLeadsList = new List<Lead>(); 
        List<OpportunityContactRole>  possibleMatchingOpptysList = new List<OpportunityContactRole>(); 
        List<Opportunity>  possibleMatchingOpptysList1 = new List<Opportunity>(); 
        Set<string> addressTokenSet = new set<string>(); 
        Set<string> phoneSet = new set<string>(); 
        Set<string> emailSet = new set<string>(); 
        Map<String, List<Lead>> addressTokenLeadMap = new Map<String, List<Lead>>(); 
        Map<String, List<Lead>> emailLeadMap = new Map<String, List<Lead>>(); 
        Map<String, List<Lead>> phoneLeadMap = new Map<String, List<Lead>>();  
        Set<Id> updateIdSet = new Set<Id>();
        List<Opportunity> updateOpptyList = new List<Opportunity>();
        List<Lead> updateLeadList = new List<Lead>();
        List<Partner_Lead_Criteria__c> partnerLeadCriteriaList = Partner_Lead_Criteria__c.getAll().values();
                                                          
        for(Lead lead: listLeads){ 
              if(lead.Address_Token__c != null){
                  addressTokenSet.add(lead.Address_Token__c);

                  List<Lead> leadList = new List<Lead>(); 
                 
                  if(addressTokenLeadMap.containsKey(lead.Address_Token__c)){
                       leadList = addressTokenLeadMap.get(lead.Address_Token__c);
                  }
                  
                  leadList.add(lead);
                  addressTokenLeadMap.put(lead.Address_Token__c, leadList);                       
                  
              }

              if(lead.Email != null){
                  emailSet.add(lead.Email);
 
                  List<Lead> leadList = new List<Lead>(); 
                 
                  if(emailLeadMap.containsKey(lead.Email)){
                       leadList = emailLeadMap.get(lead.Email);
                  }
                  
                  leadList.add(lead);
                  emailLeadMap.put(lead.Email, leadList);                       

              }

              if(lead.Phone != null){
                  phoneSet.add(lead.Phone);

                  List<Lead> leadList = new List<Lead>(); 
                 
                  if(phoneLeadMap.containsKey(lead.Phone)){
                       leadList = phoneLeadMap.get(lead.Phone);
                  }
                  
                  leadList.add(lead);
                  phoneLeadMap.put(lead.Phone, leadList);                       

              }
        }//End-for  

        if(!addressTokenSet.isEmpty()){
            possibleMatchingOpptysList1 = queryOpportunityWithAddressToken(addressTokenSet);
        }
        System.debug('possibleMatchingOpptysList1 :' +possibleMatchingOpptysList1);

        if(!phoneSet.isEmpty() || !emailSet.isEmpty()){
            possibleMatchingOpptysList = queryOCRWithPhoneEmail(phoneSet, emailSet);                                                    
        }
        System.debug('possibleMatchingOpptysList :' +possibleMatchingOpptysList); 

        if(!addressTokenSet.isEmpty() || !phoneSet.isEmpty() || !emailSet.isEmpty()){
            If(leadIdSet.isEmpty()){
                possibleMatchingLeadsList = queryLead(addressTokenSet, phoneSet, emailSet);                                                          
            }else{
                possibleMatchingLeadsList = queryLead(addressTokenSet, phoneSet, emailSet, leadIdSet);                                                                                  
            }                     
        }                     
                
        System.debug('possibleMatchingLeadsList :' +possibleMatchingLeadsList);
          
        for(Opportunity opp: possibleMatchingOpptysList1){
            if(!isPartnerLead(partnerLeadCriteriaList, opp.Channel_2__c, opp.Lead_Source_2__c, opp.Channel_Last__c, opp.Lead_Source_Last__c) &&
               !updateIdSet.contains(opp.Id) && 
                opp.StageName != '7. Closed Won' && opp.StageName != '9. Closed Lost'){ 
                 
                  if(addressTokenSet.contains(opp.Account.Address_Token__c)){
                      System.debug('Duplicate Oppty found for Address');
                      List<Lead> tempLeadsList = addressTokenLeadMap.get(opp.Account.Address_Token__c);
                      if((opp.Last_Modified_Date_Last_Click__c == null &&
                          tempLeadsList[0].CreatedDate > opp.CreatedDate) ||
                         (opp.Last_Modified_Date_Last_Click__c != null &&
                          tempLeadsList[0].CreatedDate > opp.Last_Modified_Date_Last_Click__c)){
                          opp.Channel_Last__c      = tempLeadsList[0].Channel_Last__c; 
                          opp.Lead_Source_Last__c  = tempLeadsList[0].Lead_Source_Last__c;
                          opp.Lead_Type_Last__c    = tempLeadsList[0].Lead_Type_Last__c; 
                          opp.Campaign_Last__c     = tempLeadsList[0].Campaign_Last__c; 
                          opp.Keywords_Last__c     = tempLeadsList[0].Keywords_Last__c; 
                          opp.Content_Last__c      = tempLeadsList[0].Content_Last__c; 
                          opp.Technology_Last__c   = tempLeadsList[0].Technology_Last__c; 
                          opp.Last_Modified_Date_Last_Click__c = tempLeadsList[0].CreatedDate;  
                          updateIdSet.add(opp.Id); 
                          updateOpptyList.add(opp);
                      }
                  }//End-if
            }//End-if  
        }//End-for   

        for(OpportunityContactRole ocr: possibleMatchingOpptysList){
            if(!isPartnerLead(partnerLeadCriteriaList, ocr.Opportunity.Channel_2__c, ocr.Opportunity.Lead_Source_2__c, ocr.Opportunity.Channel_Last__c, ocr.Opportunity.Lead_Source_Last__c) &&
               !updateIdSet.contains(ocr.OpportunityId) && 
                ocr.Opportunity.StageName != '7. Closed Won' && ocr.Opportunity.StageName != '9. Closed Lost'){ 
                 
                  if(phoneSet.contains(ocr.Contact.Phone) ||
                     emailSet.contains(ocr.Contact.Email)){
                      List<Lead> tempLeadsList = new List<Lead>(); 
                      if(phoneLeadMap.containsKey(ocr.Contact.Phone)){
                          System.debug('Duplicate Oppty found for Phone');
                          tempLeadsList = phoneLeadMap.get(ocr.Contact.Phone);
                      } else if(emailLeadMap.containsKey(ocr.Contact.Email)){
                          System.debug('Duplicate Oppty found for Email');
                          tempLeadsList = emailLeadMap.get(ocr.Contact.Email);  
                      }
                      Opportunity existingOppty = new Opportunity(id=ocr.OpportunityId);
                      if((ocr.Opportunity.Last_Modified_Date_Last_Click__c == null &&
                          tempLeadsList[0].CreatedDate > ocr.Opportunity.CreatedDate) ||
                         (ocr.Opportunity.Last_Modified_Date_Last_Click__c != null &&
                          tempLeadsList[0].CreatedDate > ocr.Opportunity.Last_Modified_Date_Last_Click__c)){
                          existingOppty.Channel_Last__c      = tempLeadsList[0].Channel_Last__c; 
                          existingOppty.Lead_Source_Last__c  = tempLeadsList[0].Lead_Source_Last__c;
                          existingOppty.Lead_Type_Last__c    = tempLeadsList[0].Lead_Type_Last__c; 
                          existingOppty.Campaign_Last__c     = tempLeadsList[0].Campaign_Last__c; 
                          existingOppty.Keywords_Last__c     = tempLeadsList[0].Keywords_Last__c; 
                          existingOppty.Content_Last__c      = tempLeadsList[0].Content_Last__c; 
                          existingOppty.Technology_Last__c   = tempLeadsList[0].Technology_Last__c; 
                          existingOppty.Last_Modified_Date_Last_Click__c = tempLeadsList[0].CreatedDate;
                          updateIdSet.add(existingOppty.Id); 
                          updateOpptyList.add(existingOppty); 
                      }
                  }//End-if
            }//End-if  
        }//End-for   

        for(Lead lead: possibleMatchingLeadsList){
            if(!isPartnerLead(partnerLeadCriteriaList, lead.Channel__c, lead.Custom_Lead_Source__c, lead.Channel_Last__c, lead.Lead_Source_Last__c) &&
               !updateIdSet.contains(lead.Id)){
                  
                  List<Lead> tempLeadsList  = new List<Lead>(); 
                  if(addressTokenSet.contains(lead.Address_Token__c)){
                      System.debug('Duplicate Lead found for Address');
                      tempLeadsList  = addressTokenLeadMap.get(lead.Address_Token__c);
                  } else if(phoneSet.contains(lead.Phone)){
                      System.debug('Duplicate Lead found for Phone');
                      tempLeadsList  = phoneLeadMap.get(lead.Phone);
                  } else if(emailSet.contains(lead.Email)){
                      System.debug('Duplicate Lead found for Email');
                      tempLeadsList  = emailLeadMap.get(lead.Email);
                  }
                  
                  if((lead.Last_Modified_Date_Last_Click__c == null &&
                      tempLeadsList[0].CreatedDate > lead.CreatedDate) ||
                     (lead.Last_Modified_Date_Last_Click__c != null &&
                      tempLeadsList[0].CreatedDate > lead.Last_Modified_Date_Last_Click__c)){
                      lead.Channel_Last__c      = tempLeadsList[0].Channel_Last__c; 
                      lead.Lead_Source_Last__c  = tempLeadsList[0].Lead_Source_Last__c;
                      lead.Lead_Type_Last__c    = tempLeadsList[0].Lead_Type_Last__c; 
                      lead.Campaign_Last__c     = tempLeadsList[0].Campaign_Last__c; 
                      lead.Keywords_Last__c     = tempLeadsList[0].Keywords_Last__c; 
                      lead.Content_Last__c      = tempLeadsList[0].Content_Last__c; 
                      lead.Technology_Last__c   = tempLeadsList[0].Technology_Last__c; 
                      lead.Last_Modified_Date_Last_Click__c = tempLeadsList[0].CreatedDate; 
                      updateIdSet.add(lead.Id); 
                      updateLeadList.add(lead);
                  }
            }//End-if  
        }//End-for   

        if(!updateOpptyList.isEmpty()){
            System.debug('Updating Oppty ......');  
            Database.update(updateOpptyList,false);
        }

        if(!updateLeadList.isEmpty()){
            System.debug('Updating Lead ......');           
            Database.update(updateLeadList,false);
        }
        
        loadRelatedRecords(leadIdSet, addressTokenSet, phoneSet, emailSet, possibleMatchingOpptysList, possibleMatchingOpptysList1, possibleMatchingLeadsList, listLeads); 
                                          

    }    

//Insert matching leads and opptys into Related Records object
    public static void loadRelatedRecords(Set<Id> leadIdSet, List<lead> leadList) 
                                          
    {
        Map<String, List<Opportunity>> addressTokenOpptyMap = new Map<String, List<Opportunity>>(); 
        Map<String, List<Lead>> addressTokenLeadMap = new Map<String, List<Lead>>(); 
        Map<String, List<OpportunityContactRole>> phoneOCRMap = new Map<String, List<OpportunityContactRole>>(); 
        Map<String, List<OpportunityContactRole>> emailOCRMap = new Map<String, List<OpportunityContactRole>>(); 
        Map<String, List<Lead>> phoneLeadMap = new Map<String, List<Lead>>(); 
        Map<String, List<Lead>> emailLeadMap = new Map<String, List<Lead>>();  
        List<Lead>  possibleMatchingLeadsList = new List<Lead>(); 
        List<OpportunityContactRole>  possibleMatchingOpptysList = new List<OpportunityContactRole>(); 
        List<Opportunity>  possibleMatchingOpptysList1 = new List<Opportunity>(); 
        Set<string> addressTokenSet = new set<string>(); 
        Set<string> phoneSet = new set<string>(); 
        Set<string> emailSet = new set<string>(); 

        for(Lead lead: leadList){ 
              if(lead.Address_Token__c != null){
                  addressTokenSet.add(lead.Address_Token__c);

                  List<Lead> tempLeadList = new List<Lead>(); 
                 
                  if(addressTokenLeadMap.containsKey(lead.Address_Token__c)){
                       tempLeadList = addressTokenLeadMap.get(lead.Address_Token__c);
                  }
                  
                  tempLeadList.add(lead);
                  addressTokenLeadMap.put(lead.Address_Token__c, tempLeadList);                       
                  
              }

              if(lead.Email != null){
                  emailSet.add(lead.Email);
 
                  List<Lead> tempLeadList = new List<Lead>(); 
                 
                  if(emailLeadMap.containsKey(lead.Email)){
                       tempLeadList = emailLeadMap.get(lead.Email);
                  }
                  
                  tempLeadList.add(lead);
                  emailLeadMap.put(lead.Email, tempLeadList);                       

              }

              if(lead.Phone != null){
                  phoneSet.add(lead.Phone);

                  List<Lead> tempLeadList = new List<Lead>(); 
                 
                  if(phoneLeadMap.containsKey(lead.Phone)){
                       tempLeadList = phoneLeadMap.get(lead.Phone);
                  }
                  
                  tempLeadList.add(lead);
                  phoneLeadMap.put(lead.Phone, tempLeadList);                       

              }
        }//End-for  

        if(!addressTokenSet.isEmpty()){
            possibleMatchingOpptysList1 = queryOpportunityWithAddressToken(addressTokenSet);
        }
        System.debug('possibleMatchingOpptysList1 :' +possibleMatchingOpptysList1);

        if(!phoneSet.isEmpty() || !emailSet.isEmpty()){
            possibleMatchingOpptysList = queryOCRWithPhoneEmail(phoneSet, emailSet);                                                    
        }
        System.debug('possibleMatchingOpptysList :' +possibleMatchingOpptysList); 

        if(!addressTokenSet.isEmpty() || !phoneSet.isEmpty() || !emailSet.isEmpty()){
            If(leadIdSet.isEmpty()){
                possibleMatchingLeadsList = queryLead(addressTokenSet, phoneSet, emailSet);                                                          
            }else{
                possibleMatchingLeadsList = queryLead(addressTokenSet, phoneSet, emailSet, leadIdSet);                                                                                  
            }                     
        }                                     
        System.debug('possibleMatchingLeadsList :' +possibleMatchingLeadsList);
        
        loadRelatedRecords(leadIdSet, addressTokenSet, phoneSet, emailSet, possibleMatchingOpptysList, possibleMatchingOpptysList1, possibleMatchingLeadsList, leadList);                                      

    } 

//Map of Address_Token__c to Opportunity List
    public static Map<String, List<Opportunity>> createAddressTokenOpptyMap(List<Opportunity> possibleMatchingOpptysList1){ 
        Map<String, List<Opportunity>> addressTokenOpptyMap = new Map<String, List<Opportunity>>();  
        for(Opportunity opp: possibleMatchingOpptysList1)
        {
            List<Opportunity> oppList = new List<Opportunity>(); 
            if(addressTokenOpptyMap.containsKey(opp.Account.Address_Token__c)){
                oppList = addressTokenOpptyMap.get(opp.Account.Address_Token__c);
            }    
            oppList.add(opp);
            addressTokenOpptyMap.put(opp.Account.Address_Token__c, oppList);       
            
        }    

        return addressTokenOpptyMap; 
    }

//Map of Address_Token__c to Lead List
    public static Map<String, List<Lead>> createAddressTokenLeadMap(List<Lead> possibleMatchingLeadsList, Set<string> addressTokenSet){ 
        Map<String, List<Lead>> addressTokenLeadMap = new Map<String, List<Lead>>();  
        for(Lead l: possibleMatchingLeadsList)
        {
            List<Lead> leadList = new List<Lead>(); 
            if(addressTokenSet.contains(l.Address_Token__c)){ 
                if(addressTokenLeadMap.containsKey(l.Address_Token__c)){
                  leadList = addressTokenLeadMap.get(l.Address_Token__c);
                }
                  
                leadList.add(l);
                addressTokenLeadMap.put(l.Address_Token__c, leadList);                       
            }
        }

        return addressTokenLeadMap; 
    }

//Map of Phone to OCR List    
    public static Map<String, List<OpportunityContactRole>> createPhoneOCRMap(List<OpportunityContactRole> possibleMatchingOCRList, Set<string> phoneSet){ 
        Map<String, List<OpportunityContactRole>> phoneOCRMap = new Map<String, List<OpportunityContactRole>>();   
        for(OpportunityContactRole ocr: possibleMatchingOCRList)  
        {
            List<OpportunityContactRole> ocrList = new List<OpportunityContactRole>(); 
            System.debug('ocr : ' +ocr);
            System.debug('ocr.Contact.Phone : ' +ocr.Contact.Phone);
            if(phoneSet.contains(ocr.Contact.Phone)){ 
              System.debug('Entering ----> 1');
              if(phoneOCRMap.containsKey(ocr.Contact.Phone)){
                  System.debug('Entering ----> 2');
                  ocrList = phoneOCRMap.get(ocr.Contact.Phone);
              }    
              ocrList.add(ocr);
              phoneOCRMap.put(ocr.Contact.Phone, ocrList);       
            }
        }

        return phoneOCRMap; 
    }

//Map of Phone to Lead List   
    public static Map<String, List<Lead>> createPhoneLeadMap(List<Lead> possibleMatchingLeadsList, Set<string> phoneSet){     
        Map<String, List<Lead>> phoneLeadMap = new Map<String, List<Lead>>();  

        for(Lead l: possibleMatchingLeadsList)
        {
            List<Lead> leadList = new List<Lead>(); 
            if(phoneSet.contains(l.Phone)){ 
                if(phoneLeadMap.containsKey(l.Phone)){
                  leadList = phoneLeadMap.get(l.Phone);
                }
                  
                leadList.add(l);
                phoneLeadMap.put(l.Phone, leadList);                       
            }
        }   
        
        return phoneLeadMap;
    } 

//Map of Email to OCR List  
    public static Map<String, List<OpportunityContactRole>> createEmailOCRMap(List<OpportunityContactRole> possibleMatchingOCRList, Set<string> emailSet){ 
        Map<String, List<OpportunityContactRole>> emailOCRMap = new Map<String, List<OpportunityContactRole>>();         

        for(OpportunityContactRole ocr: possibleMatchingOCRList)  
        {
            List<OpportunityContactRole> ocrList = new List<OpportunityContactRole>(); 

            if(emailSet.contains(ocr.Contact.Email)){ 
              if(emailOCRMap.containsKey(ocr.Contact.Email)){
                  ocrList = emailOCRMap.get(ocr.Contact.Email);
              }    
              ocrList.add(ocr);
              emailOCRMap.put(ocr.Contact.Email, ocrList);       
            }
        } 

        return emailOCRMap;  
    }     

//Map of Email to Lead List        
    public static Map<String, List<Lead>> createEmailLeadMap(List<Lead> possibleMatchingLeadsList, Set<string> emailSet){     
        Map<String, List<Lead>> emailLeadMap = new Map<String, List<Lead>>();  

        for(Lead l: possibleMatchingLeadsList)
        {
            List<Lead> leadList = new List<Lead>(); 
            if(emailSet.contains(l.Email)){ 
                if(emailLeadMap.containsKey(l.Email)){
                  leadList = emailLeadMap.get(l.Email);
                }
                  
                leadList.add(l);
                emailLeadMap.put(l.Email, leadList);                       
            }
        }    
        
        return emailLeadMap; 
    } 

    public static void loadRelatedRecords(Set<Id> leadIdSet, Set<String> addressTokenSet, Set<String> phoneSet, Set<String> emailSet, 
                                          List<OpportunityContactRole>  possibleMatchingOpptysList, 
                                          List<Opportunity>  possibleMatchingOpptysList1,
                                          List<Lead>  possibleMatchingLeadsList, List<Lead> leadList) {
        String channel; 
        String leadSource; 
        String leadType;
        String addressToken;
        String phone;
        String email;
        List<Related_Leads__c> relLeadsList = new List<Related_Leads__c>(); 
        Map<String, List<Opportunity>> addressTokenOpptyMap = new Map<String, List<Opportunity>>(); 
        Map<String, List<Lead>> addressTokenLeadMap = new Map<String, List<Lead>>(); 
        Map<String, List<OpportunityContactRole>> phoneOCRMap = new Map<String, List<OpportunityContactRole>>(); 
        Map<String, List<OpportunityContactRole>> emailOCRMap = new Map<String, List<OpportunityContactRole>>(); 
        Map<String, List<Lead>> phoneLeadMap = new Map<String, List<Lead>>(); 
        Map<String, List<Lead>> emailLeadMap = new Map<String, List<Lead>>(); 
        List<Partner_Lead_Criteria__c> partnerLeadCriteriaList = Partner_Lead_Criteria__c.getAll().values();

        addressTokenOpptyMap = createAddressTokenOpptyMap(possibleMatchingOpptysList1); 
        addressTokenLeadMap  = createAddressTokenLeadMap(possibleMatchingLeadsList, addressTokenSet); 
        phoneOCRMap          = createPhoneOCRMap(possibleMatchingOpptysList, phoneSet);
        phoneLeadMap         = createPhoneLeadMap(possibleMatchingLeadsList, phoneSet);
        emailOCRMap          = createEmailOCRMap(possibleMatchingOpptysList, emailSet);
        emailLeadMap         = createEmailLeadMap(possibleMatchingLeadsList, emailSet);
 
        for(Lead lead: leadList){
          Set<Id> relatedRecordIdsSet = new Set<Id>();
          
          channel = lead.Channel__c;
          leadSource = lead.Custom_Lead_Source__c;  
          leadType = lead.Lead_Type__c; 
          addressToken = lead.Address_Token__c;
          phone = lead.Phone;
          email = lead.Email; 

          if(addressTokenOpptyMap.containsKey(addressToken)){
            for(Opportunity relOppty: addressTokenOpptyMap.get(addressToken)){
                if ((isPartnerLead(partnerLeadCriteriaList, relOppty.Channel_2__c, relOppty.Lead_Source_2__c, relOppty.Channel_Last__c, relOppty.Lead_Source_Last__c) && 
                     relOppty.stagename.containsIgnoreCase('7. Closed Won')) ||
                    !isPartnerLead(partnerLeadCriteriaList, relOppty.Channel_2__c, relOppty.Lead_Source_2__c, relOppty.Channel_Last__c, relOppty.Lead_Source_Last__c)){
                    //create Related Lead record
                    
                    if(!relatedRecordIdsSet.contains(relOppty.Id)){
                        Related_Leads__c relRecord = new Related_Leads__c(); 
                        relRecord.Lead__c                  = lead.Id;
                        relRecord.Duplicate_Opportunity__c = relOppty.Id; 
                        relRecord.Channel__c               = relOppty.Channel_2__c; 
                        relRecord.Lead_Source__c           = relOppty.Lead_Source_2__c;
                        relRecord.Lead_Type__c             = relOppty.Lead_Type__c; 
                        relRecord.Stage__c                 = relOppty.StageName;
                        relRecord.Status__c                = relOppty.Opportunity_Status__c; 
                        relLeadsList.add(relRecord);
                        relatedRecordIdsSet.add(relOppty.Id);
                    }
                }
            } 
          }

          if(addressTokenLeadMap.containsKey(addressToken)){
            for(Lead relLead: addressTokenLeadMap.get(addressToken)){
                    //create Related Lead record
                  
                  if(!isPartnerLead(partnerLeadCriteriaList, relLead.Channel__c, relLead.Custom_Lead_Source__c, relLead.Channel_Last__c, relLead.Lead_Source_Last__c) &&
                     !relatedRecordIdsSet.contains(relLead.Id)){
                    Related_Leads__c relRecord = new Related_Leads__c(); 
                    relRecord.Lead__c           = lead.Id;
                    relRecord.Duplicate_Lead__c = relLead.Id; 
                    relRecord.Channel__c        = relLead.Channel__c; 
                    relRecord.Lead_Source__c    = relLead.Custom_Lead_Source__c;
                    relRecord.Lead_Type__c      = relLead.Lead_Type__c; 
                    relRecord.Stage__c          = relLead.Status;
                    relRecord.Status__c         = relLead.Lead_Status__c; 
                    relLeadsList.add(relRecord);
                    relatedRecordIdsSet.add(relLead.Id);
                  }  

            }
          }

          if(phoneOCRMap.containsKey(phone)){
            for(OpportunityContactRole relOCR: phoneOCRMap.get(phone)){
                if ((isPartnerLead(partnerLeadCriteriaList, relOCR.Opportunity.Channel_2__c, relOCR.Opportunity.Lead_Source_2__c, relOCR.Opportunity.Channel_Last__c, relOCR.Opportunity.Lead_Source_Last__c) && 
                     relOCR.Opportunity.stagename.containsIgnoreCase('7. Closed Won')) ||
                    !isPartnerLead(partnerLeadCriteriaList, relOCR.Opportunity.Channel_2__c, relOCR.Opportunity.Lead_Source_2__c, relOCR.Opportunity.Channel_Last__c, relOCR.Opportunity.Lead_Source_Last__c)){
                    //create Related Lead record

                  if(!relatedRecordIdsSet.contains(relOCR.OpportunityId)){  
                    Related_Leads__c relRecord = new Related_Leads__c(); 
                    relRecord.Lead__c                  = lead.Id;
                    relRecord.Duplicate_Opportunity__c = relOCR.OpportunityId; 
                    relRecord.Channel__c               = relOCR.Opportunity.Channel_2__c; 
                    relRecord.Lead_Source__c           = relOCR.Opportunity.Lead_Source_2__c;
                    relRecord.Lead_Type__c             = relOCR.Opportunity.Lead_Type__c; 
                    relRecord.Stage__c                 = relOCR.Opportunity.StageName;
                    relRecord.Status__c                = relOCR.Opportunity.Opportunity_Status__c; 
                    relLeadsList.add(relRecord);
                    relatedRecordIdsSet.add(relOCR.OpportunityId);
                  }
                }
            }
          }

          if(phoneLeadMap.containsKey(phone)){
            for(Lead relLead: phoneLeadMap.get(phone)){
                  //create Related Lead record
                  if(!isPartnerLead(partnerLeadCriteriaList, relLead.Channel__c, relLead.Custom_Lead_Source__c, relLead.Channel_Last__c, relLead.Lead_Source_Last__c) &&
                     !relatedRecordIdsSet.contains(relLead.Id)){    
                    Related_Leads__c relRecord = new Related_Leads__c(); 
                    relRecord.Lead__c           = lead.Id;
                    relRecord.Duplicate_Lead__c = relLead.Id; 
                    relRecord.Channel__c        = relLead.Channel__c; 
                    relRecord.Lead_Source__c    = relLead.Custom_Lead_Source__c;
                    relRecord.Lead_Type__c      = relLead.Lead_Type__c; 
                    relRecord.Stage__c          = relLead.Status;
                    relRecord.Status__c         = relLead.Lead_Status__c; 
                    relLeadsList.add(relRecord);
                    relatedRecordIdsSet.add(relLead.Id);
                  }  

            }
          }

          if(emailOCRMap.containsKey(email)){
            for(OpportunityContactRole relOCR: emailOCRMap.get(email)){
                if ((isPartnerLead(partnerLeadCriteriaList, relOCR.Opportunity.Channel_2__c, relOCR.Opportunity.Lead_Source_2__c, relOCR.Opportunity.Channel_Last__c, relOCR.Opportunity.Lead_Source_Last__c) && 
                     relOCR.Opportunity.stagename.containsIgnoreCase('7. Closed Won')) ||
                    !isPartnerLead(partnerLeadCriteriaList, relOCR.Opportunity.Channel_2__c, relOCR.Opportunity.Lead_Source_2__c, relOCR.Opportunity.Channel_Last__c, relOCR.Opportunity.Lead_Source_Last__c)){
                    //create Related Lead record

                  if(!relatedRecordIdsSet.contains(relOCR.OpportunityId)){  
                    Related_Leads__c relRecord = new Related_Leads__c(); 
                    relRecord.Lead__c                  = lead.Id;
                    relRecord.Duplicate_Opportunity__c = relOCR.OpportunityId; 
                    relRecord.Channel__c               = relOCR.Opportunity.Channel_2__c; 
                    relRecord.Lead_Source__c           = relOCR.Opportunity.Lead_Source_2__c;
                    relRecord.Lead_Type__c             = relOCR.Opportunity.Lead_Type__c; 
                    relRecord.Stage__c                 = relOCR.Opportunity.StageName;
                    relRecord.Status__c                = relOCR.Opportunity.Opportunity_Status__c; 
                    relLeadsList.add(relRecord);
                    relatedRecordIdsSet.add(relOCR.OpportunityId);
                  }  

                }
            }
          }

          if(emailLeadMap.containsKey(email)){
            for(Lead relLead: emailLeadMap.get(email)){
                  //create Related Lead record

                  if(!isPartnerLead(partnerLeadCriteriaList, relLead.Channel__c, relLead.Custom_Lead_Source__c, relLead.Channel_Last__c, relLead.Lead_Source_Last__c) &&
                     !relatedRecordIdsSet.contains(relLead.Id)){    
                    Related_Leads__c relRecord = new Related_Leads__c(); 
                    relRecord.Lead__c           = lead.Id;
                    relRecord.Duplicate_Lead__c = relLead.Id; 
                    relRecord.Channel__c        = relLead.Channel__c; 
                    relRecord.Lead_Source__c    = relLead.Custom_Lead_Source__c;
                    relRecord.Lead_Type__c      = relLead.Lead_Type__c; 
                    relRecord.Stage__c          = relLead.Status;
                    relRecord.Status__c         = relLead.Lead_Status__c; 
                    relLeadsList.add(relRecord);  
                    relatedRecordIdsSet.add(relLead.Id);
                  }
            }
          }

        }

        List<Related_Leads__c> deleteRelatedRecs = [Select Id from Related_Leads__c where Lead__c in :leadIdSet]; 
        System.debug('deleteRelatedRecs : ' +deleteRelatedRecs);
        if(!deleteRelatedRecs.isEmpty()){
          System.debug('Deleting Related Leads');
          Database.delete(deleteRelatedRecs, false); 
        } 

        Database.insert(relLeadsList,false);

    }  

}