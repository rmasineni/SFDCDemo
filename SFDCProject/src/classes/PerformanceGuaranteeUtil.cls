public with sharing class PerformanceGuaranteeUtil {
    
    public static void performanceguaranteeservicecontract(boolean isinsert,boolean isupdate,List<servicecontract>scList,
                                                            Map<id,ServiceContract> oldMap, Map<Id,Id> serviceContractToProposal,
                                                            Map<Id, Proposal__c> proposalMp ){

        if(proposalMp == null || proposalMp.isEmpty()){
            return;
        }
                                                                
                                                                
        
       /* List<ServiceContract> listSC = new  list<ServiceContract>();
        List<Contract_Performance_Guarantee__c>  cpgList = New List<Contract_Performance_Guarantee__c>();
        Set<Id> modifiedSCIds = new Set<Id>();
        for(Id scId : serviceContractToProposal.keySet()){
            Id proposalId = serviceContractToProposal.get(scId);
            if(proposalId != null && proposalMp.containsKey(proposalId)){
                Proposal__c proposalObj = proposalMp.get(proposalId);
             if (proposalObj.Proposal_Source__c != null) {
                    if(  proposalObj.Proposal_Source__c.equals('PT') ) {
                       System.debug('>>>inside PT');
                    modifiedSCIds.add(scId);
                        List<Proposal_Performance_Guarantee__c> ppgList = proposalObj.Proposal_Performance_Guarantee__r;
                        if(ppgList != null && !ppgList.isEmpty()){
                            for(Proposal_Performance_Guarantee__c ppg : ppgList){
                                Contract_Performance_Guarantee__c cpg = new Contract_Performance_Guarantee__c();
                                cpg.Service_Contract__c = scId;
                                cpg.Guaranteed_Output__c = ppg.Guranteed_Output__c;
                                cpg.Refund_Rate__c = ppg.Refund_Rate__c;
                                cpg.Year__c = ppg.Year__c;
                                cpgList.add(cpg);                           
                            }
                        }
                      }  
                  
                    else if (proposalObj.Change_Order_Information__c != null ) {
                        if (( proposalObj.Proposal_Source__c.equals('BB') && (proposalObj.Change_Order_Information__c.containsIgnoreCase('CUSTOMER_CHANGE_ORDER') || proposalObj.Change_Order_Information__c.containsIgnoreCase('FULL_PROPOSAL')))){
                        System.debug('>>>>>inside BBB');
                        modifiedSCIds.add(scId);
                        List<Proposal_Performance_Guarantee__c> ppgList = proposalObj.Proposal_Performance_Guarantee__r;
                        if(ppgList != null && !ppgList.isEmpty()){
                            for(Proposal_Performance_Guarantee__c ppg : ppgList){
                                Contract_Performance_Guarantee__c cpg = new Contract_Performance_Guarantee__c();
                                cpg.Service_Contract__c = scId;
                                cpg.Guaranteed_Output__c = ppg.Guranteed_Output__c;
                                cpg.Refund_Rate__c = ppg.Refund_Rate__c;
                                cpg.Year__c = ppg.Year__c;
                                cpgList.add(cpg);                           
                            }
                        }
                     }   
                 }
              }
           }
        } */
                
       List<ServiceContract> listSC = new  list<ServiceContract>();
        List<Contract_Performance_Guarantee__c>  cpgList = New List<Contract_Performance_Guarantee__c>();
        Set<Id> modifiedSCIds = new Set<Id>();
            for(Id scId : serviceContractToProposal.keySet()){
                Id proposalId = serviceContractToProposal.get(scId);
                if(proposalId != null && proposalMp.containsKey(proposalId)){
                    Proposal__c proposalObj = proposalMp.get(proposalId);
                 if (proposalObj.Proposal_Source__c != null) {
                        if(  proposalObj.Proposal_Source__c.equals('PT') ) {
                           System.debug('>>>inside PT');
                        modifiedSCIds.add(scId);
                            List<Proposal_Performance_Guarantee__c> ppgList = proposalObj.Proposal_Performance_Guarantee__r;
                            if(ppgList != null && !ppgList.isEmpty()){
                                for(Proposal_Performance_Guarantee__c ppg : ppgList){
                                    Contract_Performance_Guarantee__c cpg = new Contract_Performance_Guarantee__c();
                                    cpg.Service_Contract__c = scId;
                                    cpg.Guaranteed_Output__c = ppg.Guranteed_Output__c;
                                    cpg.Refund_Rate__c = ppg.Refund_Rate__c;
                                    cpg.Year__c = ppg.Year__c;
                                    cpgList.add(cpg);                           
                                    }
                                }
                              }
                         }
                    }
                }
                                                                
       /*   for(Id scId : scToProp.keySet()){
   			Id proposalId = scToProp.get(scId);
              if(proposalId != null && proposalMp.containsKey(proposalId)){
                  system.debug('>>>>>PropObj' + proposalMp.get(proposalId));
                  Proposal__c proposalObj = proposalMp.get(proposalId);
                  if (proposalObj.Proposal_Source__c != null && proposalObj.Change_Order_Information__c != null ) {
                        if ( proposalObj.Proposal_Source__c.equals('BB') ){
                        System.debug('>>>>>inside BBB');
                        modifiedSCIds.add(scId);
                        List<Proposal_Performance_Guarantee__c> ppgList = proposalObj.Proposal_Performance_Guarantee__r;
                        if(ppgList != null && !ppgList.isEmpty()){
                            for(Proposal_Performance_Guarantee__c ppg : ppgList){
                                Contract_Performance_Guarantee__c cpg = new Contract_Performance_Guarantee__c();
                                cpg.Service_Contract__c = scId;
                                cpg.Guaranteed_Output__c = ppg.Guranteed_Output__c;
                                cpg.Refund_Rate__c = ppg.Refund_Rate__c;
                                cpg.Year__c = ppg.Year__c;
                                cpgList.add(cpg);                           
                            }
                        }
                     }   
                 }
              }
           }      */                                                    
                                                                
                                                                
                                                                
                                                                
        List<Contract_Performance_Guarantee__c>  listCpgForDelete;
        if(modifiedSCIds != null && !modifiedSCIds.isEmpty()){
            
            listCpgForDelete = [select id from Contract_Performance_Guarantee__c where Service_Contract__c in :modifiedSCIds ];
            if(listCpgForDelete != null && !listCpgForDelete.isEmpty()){
                delete listCpgForDelete;
            }
        }
        if(cpglist != null && !cpglist.isEmpty()){
            insert cpglist;
        }  
    }       
    
    
  public static void performanceGuaranteeServiceContractForBB(boolean isinsert,boolean isupdate,List<servicecontract>scList,
                                                            Map<id,ServiceContract> oldMap, Map<Id,Id> serviceContractToProposal,
                                                            Map<Id, Proposal__c> proposalMp, Map<Id,Id> scToProp ){

        if(proposalMp == null || proposalMp.isEmpty()){
            return;
        }
                                                                
                                                   
       List<ServiceContract> listSC = new  list<ServiceContract>();
        List<Contract_Performance_Guarantee__c>  cpgList = New List<Contract_Performance_Guarantee__c>();
        Set<Id> modifiedSCIds = new Set<Id>();
                                                       
          for(Id scId : scToProp.keySet()){
   			Id proposalId = scToProp.get(scId);
              if(proposalId != null && proposalMp.containsKey(proposalId)){
                  system.debug('>>>>>PropObj' + proposalMp.get(proposalId));
                  Proposal__c proposalObj = proposalMp.get(proposalId);
                  if (proposalObj.Proposal_Source__c != null && proposalObj.Change_Order_Information__c != null ) {
                        if ( proposalObj.Proposal_Source__c.equals('BB') ){
                        System.debug('>>>>>inside BBB');
                        modifiedSCIds.add(scId);
                        List<Proposal_Performance_Guarantee__c> ppgList = proposalObj.Proposal_Performance_Guarantee__r;
                        if(ppgList != null && !ppgList.isEmpty()){
                            for(Proposal_Performance_Guarantee__c ppg : ppgList){
                                Contract_Performance_Guarantee__c cpg = new Contract_Performance_Guarantee__c();
                                cpg.Service_Contract__c = scId;
                                cpg.Guaranteed_Output__c = ppg.Guranteed_Output__c;
                                cpg.Refund_Rate__c = ppg.Refund_Rate__c;
                                cpg.Year__c = ppg.Year__c;
                                cpgList.add(cpg);                           
                            }
                        }
                     }   
                 }
              }
           }                                                           
                                                                
                                                                
                                                                
                                                                
        List<Contract_Performance_Guarantee__c>  listCpgForDelete;
        if(modifiedSCIds != null && !modifiedSCIds.isEmpty()){
            
            listCpgForDelete = [select id from Contract_Performance_Guarantee__c where Service_Contract__c in :modifiedSCIds ];
            if(listCpgForDelete != null && !listCpgForDelete.isEmpty()){
                delete listCpgForDelete;
            }
        }
        if(cpglist != null && !cpglist.isEmpty()){
            insert cpglist;
        }
    } 

}