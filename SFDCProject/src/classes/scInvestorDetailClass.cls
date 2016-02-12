public class scInvestorDetailClass {
    public serviceContract sc {get;set;}
    public Investor_Data__c  invData {get;set;}
    public serviceContract scObj{get;set;}
    public Investor_Data__c invObj{get;set;}
    Map<id, ServiceContract> scmap = new map<id,serviceContract>();
    map<id,Investor_Data__c> invmap = new map<id,Investor_Data__c>();
    
    map<serviceContract, Investor_data__c> scInvMap = new map<serviceContract, Investor_data__c>();
    public id scid {get;set;}
    
    public scInvestorDetailClass(){
        scid = System.currentPageReference().getparameters().get('id') ;
        if(scid != null ){
           Set<String> tempObjectIds = new Set<String>();
			tempObjectIds.add(scid);
            getScs(tempObjectIds);
            if(scmap !=null && !scmap.isEmpty() )
				scObj = scMap.get(scid);
            if(invMap != null && !invMap.isEmpty() ) 
                 invObj= invMap.get(scid);
			}
         system.debug('>> SC' + scObj);
        }
       


    
    private void getScs(set <string> scids ) {
       
        for ( serviceContract sc : [Select id,name, TE_FUND_NAME__C , Status__C,
                                    (select id,name, Agreement_Number__c, In_TE_Fund__c,ContractNumber__c, ContractNumber__r.name from Investor_Custom_Object__r limit 1)
                                    from serviceContract where id =: scids]){
            		scmap.put(sc.id, sc);
                                list <Investor_Data__c> invCustomList =   sc.Investor_Custom_Object__r;      
                                        
                                        if(invCustomList.size() > 0 && !invCustomList.isEmpty()  )  {
                                            invmap.put(sc.id, invCustomList[0]);
                                            scInvMap.put(sc,invCustomList[0]);
                                        }                  
             		
            }
      
    }
    
      public PageReference backToSearch() {
         // editModeSec = true;
            pageReference returnToscInvSearch;
            returnToscInvSearch = new pageReference('/apex/SCInvestorSearchPage?id='+scid);
            return returnToscInvSearch;
          
            
        }
    

}