public class scInvestorPartnerUtil {
   
 public static String Investor = 'Investor';
 public Static string Borrower = 'Borrower' ;
    
    public static void createInvestorPartner(   map<id,Investor_Mapping__c > scInvMap, set<ServiceContract> scSet ) {
        map<id,set<Service_Contract_Partner_Rel__c> > scRelatedPartnerMap = new  map<id,set <Service_Contract_Partner_Rel__c> > ();
        list<Service_Contract_Partner_Rel__c> existingSCInvestorPartnerList = new list<Service_Contract_Partner_Rel__c>();
        list<Service_Contract_Partner_Rel__c> newSCInvestorPartnerList = new list<Service_Contract_Partner_Rel__c>();
        if( scInvMap.size() >0 && !scInvMap.isEmpty() ){
             
             map<id, Service_Contract_Partner_Rel__c>  partnerMap = getSCRelatedPartner( scInvMap.keySet());  
            for (  Service_Contract_Partner_Rel__c scRelatedPartner: partnerMap.values())
            /*for ( Service_Contract_Partner_Rel__c scRelatedPartner : [ select Id, name, Account__c, ServiceContract__c, Type__c 
                                                                      from Service_Contract_Partner_Rel__c where ServiceContract__c =: scInvMap.keySet() 
                                                                      and (type__c =  :Investor or type__C =: Borrower) ])*/
            {
                if(scRelatedPartnerMap.containsKey(scRelatedPartner.ServiceContract__c)   )
                    scRelatedPartnerMap.get(scRelatedPartner.ServiceContract__c).add(scRelatedPartner);
                else{
                    scRelatedPartnerMap.put(scRelatedPartner.ServiceContract__c  , new set<Service_Contract_Partner_Rel__c> {scRelatedPartner});
                }
            }	
            
            for( id scid : scInvMap.keyset() ){
                if( scRelatedPartnerMap.containsKey(scid) ){
                    set<Service_Contract_Partner_Rel__c> existingRelPartnerSet = scRelatedPartnerMap.get(scid);
                    for( Service_Contract_Partner_Rel__c relPartner: existingRelPartnerSet  ){
                        if(relPartner.type__c != null && relPartner.type__C == Investor ){
                            relPartner.Account__c = scInvMap.get(scid).name__c;  
                            existingSCInvestorPartnerList.add(relPartner);
                        }
                        
                        else if(relPartner.type__c != null && relPartner.type__C == Borrower){
                            relPartner.Account__c =  scInvMap.get(scid).Borrower__c;  
                            existingSCInvestorPartnerList.add(relPartner);
                        }
                    }

                    System.debug('>> Exisiting Inv partner list : ' + existingSCInvestorPartnerList );
                }
                else{
                   	Service_Contract_Partner_Rel__c   newInvestorPartner = new Service_Contract_Partner_Rel__c(ServiceContract__c = scid,  Account__c =  scInvMap.get(scid).name__c ,type__c = Investor );
                   	Service_Contract_Partner_Rel__c   newBorrowerPartner = new Service_Contract_Partner_Rel__c(ServiceContract__c = scid,  Account__c =  scInvMap.get(scid).borrower__c ,type__c = Borrower );

                    newSCInvestorPartnerList.add(newInvestorPartner);
                    newSCInvestorPartnerList.add(newBorrowerPartner);
                     System.debug('>> newInvestorPartnerList: ' + newSCInvestorPartnerList );
                    
                }
            }
            
            if( existingSCInvestorPartnerList.size() >0 && !existingSCInvestorPartnerList.isEmpty()  )
                update existingSCInvestorPartnerList;
            
            if( newSCInvestorPartnerList.size() >0 && !newSCInvestorPartnerList.isEmpty()  )
                insert newSCInvestorPartnerList;
            
        }
    }
    
    public static map<id,Service_Contract_Partner_Rel__c> getSCRelatedPartner(set<id> Scid){
        map<id, Service_Contract_Partner_Rel__c> scRelatedPartnerMap = new map<id,Service_Contract_Partner_Rel__c> ();
        if(Scid.size() > 0 && !Scid.isempty() ){
            for (Service_Contract_Partner_Rel__c rel: [ select Id, name, Account__c, ServiceContract__c, Type__c 
                                                       from Service_Contract_Partner_Rel__c where ServiceContract__c =: Scid 
                                                       and (type__c =  :Investor or type__C =: Borrower) ] ){
                                                           scRelatedPartnerMap.put(rel.id, rel) ;
                                                       }
        }
    
   		 return scRelatedPartnerMap;
    }
    
    public static void deleteSCInvestorPartners(set<id> Scid){
        list<Service_Contract_Partner_Rel__c> relatedInvPartnersToDlt = new list<Service_Contract_Partner_Rel__c> ();
       
         if (scid.size()>0 && !scid.isEmpty() ){
            relatedInvPartnersToDlt = scInvestorPartnerUtil.getSCRelatedPartner(scid).values(); 
        }
        if(relatedInvPartnersToDlt.size() > 0 && !relatedInvPartnersToDlt.isEmpty() ){
            delete relatedInvPartnersToDlt;
        }
    }

}