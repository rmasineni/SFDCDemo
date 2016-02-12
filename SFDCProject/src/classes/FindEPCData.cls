Public Class FindEPCData{
    public static void FindEPCData(List<Lead> lst_Leads){
    Set<id> SalesInstallIds=new Set<id>();
    Map<String,partner_contract__c> PCMap=new Map<String,partner_contract__c>();   
        for(Lead l:lst_Leads){
            if(l.sales_partner__c!=null)
            SalesInstallIds.add(l.sales_partner__c);
            if(l.Install_Partner__c!=null)
            SalesInstallIds.add(l.Install_partner__c);
        }
       if(!SalesInstallIds.isempty()){                   
         for(partner_contract__c pc:[select id, name, contract_type__c, effective_date__c, Contract_Status__c, expiration_Date__c , Account__c,Account__r.Site from Partner_contract__c where  Account__c in:SalesInstallIds and Contract_Status__c = 'Active' and expiration_date__c > today and Contract_Type__c in ('Full Service Contract','Installation Contract','Sales Contract') ]){         
         PCMap.put(pc.account__c+pc.Contract_Type__c,pc);        
        }
      }
      
      for(Lead l:lst_Leads){
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
      } 
    }
}