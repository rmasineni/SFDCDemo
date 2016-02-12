/************************************************************************************************
Name:trg_aft_ins_PartAssignStaging
Author: Prashanth Veloori
Date: 1/29/2014
Description: Trigger on Partner Assignment Staging Object to find MA on leads
************************************************************************************************/
trigger trg_aft_ins_PartAssignStaging on Partner_Assignment_Staging__c (after insert) {    
  Set<id> salesMAIds=new Set<id>();
  Set<id> installMAIds=new Set<id>();  
  //id recordtypeid=[select id,sobjecttype,name from recordtype  where sobjecttype='Account' and name ='Partner'].id;
  //Decimal count=srao.current_assignment_order__c;
  Id SunrunIncId=System.Label.Sunrun_Inc_Id;
  Account sunrun=[select id from account where id=:SunrunIncId limit 1];  
  //List<Sales_Rep_Profiles__c> srProfilesList=Sales_Rep_Profiles__c.getAll().Values();
  //Set<String> salesProfiles=new Set<String>();
  //if(!srProfilesList.isempty()){
  //  for(Sales_Rep_Profiles__c srp:srProfilesList){
  //      salesProfiles.add(srp.Profile_Name__c);
  //  }
  //}
  //List<opportunity> oppList=new List<opportunity>();
  List<lead> leadList=new List<lead>();
  //List<user> userList=[select id,name,Assignment_Order__c from user where isactive=true and Assignment_Order__c!=null order by Assignment_Order__c];  
  //Map<Decimal,user> userOrderMap=new Map<Decimal,user>();
  //  for(user u:userList){
  //    userOrderMap.put(u.assignment_order__c,u);
  //  }
  //if(!userList.isempty()){  
  //if(srao.current_assignment_order__c>userList[userList.size()-1].Assignment_Order__c) {
  //count=userList[0].Assignment_Order__c;
  //}
  //}
  Set<id> accids=new Set<id>();
  Set<id> sunrunleadids=new Set<id>();
  Set<id> leadids=new Set<id>();  
  Set<id> SalesInstallMarketids=new Set<id>();
  Map<id,account> accMap=new Map<id,account>();
  Map<id,id> salesinstallPartnerMap=new Map<id,id>();
  Set<id> SalesInstallPartnerIds=new set<id>(); 
  Map<id,id> LeadSalesPartnerMap=new Map<id,id>(); 
  Map<String,partner_contract__c> PCMap=new Map<String,partner_contract__c>();   
  //Map<id,account> installPartnerMap=new Map<id,account>();
      for(Partner_Assignment_Staging__c pas:trigger.new){
          if(pas.Referral_With_Contact__c==true)    
          accids.add(pas.account__c);
          if(pas.Account__c==sunrun.id)
          sunrunleadids.add(pas.lead__c);
          if(pas.Sales_Market_Assignment__c!=null)
          SalesInstallMarketids.add(pas.Sales_Market_Assignment__c);
          if(pas.Install_Market_Assignment__c!=null)
          SalesInstallMarketids.add(pas.Install_Market_Assignment__c);
      }
      if(!SalesInstallMarketids.isempty()){
      for(Market_assignment__c ma:[select id,partner__c from market_assignment__c where id in:SalesInstallMarketids]){
        salesinstallPartnerMap.put(ma.id,ma.Partner__c);
        SalesInstallPartnerIds.add(ma.Partner__c);
      }
      }
      if(!SalesInstallPartnerIds.isempty()){                   
         for(partner_contract__c pc:[select id, name, contract_type__c, effective_date__c, Contract_Status__c, expiration_Date__c , Account__c,Account__r.Site from Partner_contract__c where  Account__c in:SalesInstallPartnerIds and Contract_Status__c = 'Active' and expiration_date__c > today and Contract_Type__c in ('Full Service Contract','Installation Contract','Sales Contract') ]){         
         PCMap.put(pc.account__c+pc.Contract_Type__c,pc);        
        }
      }
      if(!accids.isempty()){
      for(Account a:[select id,Stage__c,recordtypeid,Office_Location__c,Active__c from account where id in:accids]){
        if(a.Stage__c=='Confirmed'&&a.Office_Location__c=='Headquarters'&&a.active__c==true)
        accMap.put(a.id,a);
      }
      }
          for(Partner_Assignment_Staging__c pas:trigger.new)
          { 
               Lead l;                 
              if(pas.Lead__c!=null){   
              if(pas.Account__c==sunrun.id&&pas.Referral_With_Contact__c==false&&pas.Referral_With_Contact_NoMatch__c==false){                             
                              l=new Lead(id=pas.Lead__c,lock_assignment__c=true,SalesOrganizationName__c=sunrun.id,Sales_Partner__c=sunrun.id);                                                                                       
                              if(pas.sales_market_assignment__c!=null){
                                l.Market_Assignment_Sales__c=pas.sales_market_assignment__c;
                                salesMAids.add(pas.sales_market_assignment__c);
                              }
                              if(pas.Install_market_assignment__c!=null){
                                l.Market_Assignment_Install__c=pas.Install_market_assignment__c;
                                if(salesinstallPartnerMap.containskey(pas.Install_market_assignment__c)){
                                l.Install_Partner__c=salesinstallPartnerMap.get(pas.Install_market_assignment__c);
                                installMAids.add(pas.Install_market_assignment__c);
                                }
                              }                                           
              }
              else if(pas.Referral_With_Contact__c==true){
                l=new lead(id=pas.lead__c,lock_assignment__c=true);
                if(pas.account__c!=null&&accMap.containsKey(pas.account__c)){       
                l.sales_partner__c=pas.account__c;
                l.SalesOrganizationName__c=pas.account__c;
                if(pas.sales_market_assignment__c!=null){
                        l.Market_Assignment_Sales__c=pas.sales_market_assignment__c;
                }
                if(pas.Install_market_assignment__c!=null){
                  if(salesinstallPartnerMap.containskey(pas.Install_market_assignment__c)){
                    l.install_partner__c=salesinstallPartnerMap.get(pas.Install_market_assignment__c);
                        l.Market_Assignment_Install__c=pas.Install_market_assignment__c;
                  }
                }
                }                                   
                }                            
             else if(pas.Account__c!=sunrun.id&&pas.Referral_With_Contact__c==false&&pas.Referral_With_Contact_NoMatch__c==false&&pas.Market_Assignment__c==true&&pas.Offer_Assignment__c==false&&!sunrunleadids.contains(pas.lead__c)){                  
                l=new lead(id=pas.lead__c,lock_assignment__c=true); 
                     if(pas.sales_market_assignment__c!=null){
                        l.sales_partner__c=pas.account__c;
                        l.Market_Assignment_Sales__c=pas.sales_market_assignment__c;
                        salesMAids.add(pas.sales_market_assignment__c);                                    
                      }
                     if(pas.Install_market_assignment__c!=null){
                        l.Market_Assignment_Install__c=pas.Install_market_assignment__c;
                        if(salesinstallPartnerMap.containskey(pas.Install_market_assignment__c)){
                        l.Install_Partner__c=salesinstallPartnerMap.get(pas.Install_market_assignment__c);
                        installMAids.add(pas.Install_market_assignment__c);
                        }
                      }                                        
              } 
            else if(pas.Account__c!=sunrun.id&&pas.Referral_With_Contact__c==false&&pas.Referral_With_Contact_NoMatch__c==false&&pas.Market_Assignment__c==false&&pas.Offer_Assignment__c==true&&!sunrunleadids.contains(pas.lead__c)){
                l=new lead(id=pas.lead__c,lock_assignment__c=true);   
                if(pas.sales_market_assignment__c!=null){
                        l.sales_partner__c=pas.account__c;
                        l.Market_Assignment_Sales__c=pas.sales_market_assignment__c;
                      }
                     if(pas.Install_market_assignment__c!=null){
                        l.Market_Assignment_Install__c=pas.Install_market_assignment__c;
                        if(salesinstallPartnerMap.containskey(pas.Install_market_assignment__c)){
                        l.Install_Partner__c=salesinstallPartnerMap.get(pas.Install_market_assignment__c);
                        }                        
                      }                                         
              } 
            else if(pas.Referral_With_Contact__c==false&&pas.Referral_With_Contact_NoMatch__c==true&&pas.Market_Assignment__c==false&&pas.Offer_Assignment__c==false){                 
                l=new lead(id=pas.lead__c,lock_assignment__c=true);                                    
              }
            else if(pas.Referral_With_Contact__c==false&&pas.Referral_With_Contact_NoMatch__c==false&&pas.Market_Assignment__c==false&&pas.No_Data__c==true){                  
                l=new lead(id=pas.lead__c,lock_assignment__c=true);                                   
            }
            else if(pas.Referral_from_Web__c==true){   
                l=new lead(id=pas.lead__c);                                 
              }  
            }                          
          //*********************Code to Fill in SalesOrg,SalesOrgContractExecutionDate,EPCExecutionDate,InstallationOffice,EPCPartnerName***********//
                        if(l!=null&&PCMap.containsKey(l.Sales_Partner__c +'Full Service Contract')){                                  
                             l.SalesOrganizationName__c = PCMap.get(l.Sales_Partner__c +'Full Service Contract').Account__c ;
                             l.SalesOrgContractExecutionDate__c = PCMap.get(l.Sales_Partner__c +'Full Service Contract').Effective_Date__c;             
                        }
                        else {            
                        if(l!=null&&PCMap.containsKey(l.Sales_Partner__c +'Sales Contract')){                           
                             l.SalesOrganizationName__c = PCMap.get(l.Sales_Partner__c +'Sales Contract').Account__c ;
                             l.SalesOrgContractExecutionDate__c = PCMap.get(l.Sales_Partner__c +'Sales Contract').Effective_Date__c;                 
                        } 
                        }
                        if(l!=null&&PCMap.containsKey(l.Install_Partner__c+'Full Service Contract')){
                            l.EPCPartnerName__c = PCMap.get(l.Install_Partner__c+'Full Service Contract').Account__c;
                            l.EPCExecutionDate__c = PCMap.get(l.Install_Partner__c+'Full Service Contract').Effective_Date__c;
                            l.InstallationOffice__c = PCMap.get(l.Install_Partner__c+'Full Service Contract').Account__r.Site;
                        }else {            
                            if(l!=null&&PCMap.containsKey(l.Install_Partner__c+'Installation Contract')){
                                l.EPCPartnerName__c = PCMap.get(l.Install_Partner__c+'Installation Contract').Account__c;
                                l.EPCExecutionDate__c = PCMap.get(l.Install_Partner__c+'Installation Contract').Effective_Date__c;
                                l.InstallationOffice__c = PCMap.get(l.Install_Partner__c+'Installation Contract').Account__r.Site;
                            }
                        }
          //****************************************************************************************************************************************//
           if(l.Install_Partner__c!=null && l.Install_Partner__c!=System.Label.Sunrun_Inc_Id){
                  LeadTriggerClass.clearLeadFields(l);
                  nullOutFactors.nullOutFactors(l);
                  system.debug('trg Install_Partner__c' +l.Install_Partner__c);                 
          }
          if(l!=null&&!checkrecursive.batchLeadIds.contains(l.id)){
            if(l.Market_Assignment_Sales__c==null||l.Market_Assignment_Install__c==null){
                l.Lock_Assignment__c=false;
            }
          leadList.add(l);
          checkrecursive.batchLeadIds.add(l.id);
          }
          //}
          //Share Lead with POC if the lead is not Sunrun's
          if(l.Sales_partner__c!=sunrun.id&&pas.Lead_Owner_Contact__c==null&&pas.Sales_Partner_POC__c!=null){
            LeadSalesPartnerMap.put(l.id,pas.Sales_Partner_POC__c);
          } 
          }            
  if(!leadList.isEmpty()){
  system.debug('--->update leads'+leadList); 
  Set<Lead> leadset=new Set<Lead>();
  leadset.addall(leadList);
  LeadList.clear();
  leadlist.addall(leadset);
  try {
         
            Database.SaveResult[] results = Database.update(leadList,false);
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
  List<market_assignment__c> salesMAList=new List<market_assignment__c>();
  List<market_assignment__c> installMAList=new List<market_assignment__c>();
  if(!salesMAids.isempty()||!installMAids.isempty()){
  for(market_assignment__c ma:[select id,Current_No_Of_Leads_Sales__c,Current_No_Of_Leads_Install__c from market_assignment__c where id in:salesMAids or id in:installMAids]){
    if(salesMAids.contains(ma.id))
    ma.Current_No_Of_Leads_Sales__c++;
    if(installMAids.contains(ma.id))
    ma.Current_No_Of_Leads_Install__c++;    
    salesMAList.add(ma);
  }  
  }
  if(!salesMAList.isempty()){
    update salesMAList;
  }     
  if(!LeadSalesPartnerMap.isempty()){
    List<LeadShare> LSShareList=new List<LeadShare>();
    Map<id,id> contUserMap=new Map<id,id>();
    for(user userObj:[select id,contactid from user where contactid in:LeadSalesPartnerMap.values()]){
        contUserMap.put(userObj.contactid,userObj.id);
    }
    for(Id id:LeadSalesPartnerMap.keyset()){
        LeadShare LS=new LeadShare();
        LS.LeadAccessLevel='Edit';
        LS.LeadId=id;
        LS.UserOrGroupId=contUserMap.get(LeadSalesPartnerMap.get(id));
        LSShareList.add(LS);
    }
    if(!LSShareList.isempty()){
        try{
        database.insert(LSShareList);
        }
        catch(exception e){}
    }
  }
}