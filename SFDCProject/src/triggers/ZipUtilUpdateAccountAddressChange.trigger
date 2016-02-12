trigger ZipUtilUpdateAccountAddressChange on Account (after update) {

   if(System.isFuture())
        {
            return;
        }
    
   	if(CheckRecursiveTrigger.runOnce()){
    Map <Id,Account> accountmap = new map <Id,Account>();
    Map <String,ZipUtility__c> ziputilitymap = new map <String,ZipUtility__c>();
	Map <String,Appointment_Territory__c> zipTerritorymap = new map <String,Appointment_Territory__c>();
	Map <String,Appointment_Territory__c> zipServiceTerritorymap = new map <String,Appointment_Territory__c>();
    List<Opportunity> opplist = new List <Opportunity>();
    List<Opportunity> opplistnull = new List <Opportunity>();
    Map <Id,Account> accountmapnull = new map <Id,Account>();
    Set <String> ZipcodeSet = new set <String>();
    List<ZipUtility__c> ziplist = new List<ZipUtility__c>();
    List<Appointment_Territory__c> territoryList = new List<Appointment_Territory__c>();
	                
    for(Account acc: Trigger.new)
        {
            system.debug('Prining Values   '+trigger.oldmap.get(acc.Id).Billingpostalcode+' And More   '+acc.Billingpostalcode);
            if (acc.Billingpostalcode!=trigger.oldmap.get(acc.Id).Billingpostalcode && acc.Billingpostalcode!=null && acc.Billingpostalcode!='' )
                {
                accountmap.put(acc.Id,acc);
                ZipcodeSet.add(acc.BillingPostalCode);
                }
            else
                {
                    if(acc.Billingpostalcode!=trigger.oldmap.get(acc.Id).Billingpostalcode && (acc.Billingpostalcode == null || acc.Billingpostalcode == ''))
                        {
                            accountmapnull.put(acc.Id,acc);
                        }
                }
        }
    
    if (!accountmap.isEmpty())
        {
            
            If(!ZipcodeSet.isEmpty())
                {
                    ziplist =[Select Name,zip_code__c,Sales_Branch__c from ZipUtility__c where zip_code__c IN:ZipcodeSet];
                    territoryList =[Select Name,zip_code__c, Territory__c, category__c from Appointment_Territory__c where zip_code__c IN:ZipcodeSet];
                }
            
            if(!ziplist.isEmpty())
                {              
                    for (ZipUtility__c zp: ziplist )
                        {
                            ziputilitymap.put(zp.zip_code__c,zp);
                        }
                }

            	if(!territoryList.isEmpty())
                {
                    	for (Appointment_Territory__c tr: territoryList ){
                            if(tr.category__c == 'Sales'){
                            	zipTerritorymap.put(tr.zip_code__c,tr);
                            }else if(tr.category__c == 'Service'){
                            	zipServiceTerritorymap.put(tr.zip_code__c,tr);
                            }
                        }                    
                }
    
        	opplist = [Select Id,Name,AccountId,zip_utility__c,sales_branch__C from Opportunity where AccountId IN :accountmap.Keyset()];
        
			if(!opplist.isEmpty()){
				for (Opportunity opp : opplist){
					if (ziputilitymap.get(accountmap.get(opp.accountId).BillingPostalCode)== null){
					        opp.zip_utility__c = null;
					}else {
				        opp.zip_utility__c = ziputilitymap.get(accountmap.get(opp.AccountId).BillingPostalCode.substring(0,5)).Id;
				        if(ziputilitymap.get(accountmap.get(opp.AccountId).BillingPostalCode.substring(0,5)).Sales_Branch__c!=null){
				        opp.Sales_Branch__c =ziputilitymap.get(accountmap.get(opp.AccountId).BillingPostalCode.substring(0,5)).Sales_Branch__c;
					}
			        if (zipTerritorymap.get(accountmap.get(opp.accountId).BillingPostalCode)== null){
			                opp.Appointment_Territory__c = null;
					}else{
						opp.Appointment_Territory__c = zipTerritorymap.get(accountmap.get(opp.AccountId).BillingPostalCode).Territory__c;
					}   
			        if (zipServiceTerritorymap.get(accountmap.get(opp.accountId).BillingPostalCode)== null){
			                opp.Appointment_Service_Territory__c = null;
					}else{
						opp.Appointment_Service_Territory__c = zipServiceTerritorymap.get(accountmap.get(opp.AccountId).BillingPostalCode).Territory__c;
					}
				}    
			}       
			update opplist; 
		}
	}

    if (!accountmapnull.isEmpty())
        {
    
            opplistnull = [Select Id,Name,Sales_Branch__c,AccountId,zip_utility__c from Opportunity where AccountId IN :accountmapnull.Keyset()];
        
            if(!opplistnull.isEmpty())
            {
                for (Opportunity oppnull : opplistnull)
                    {
                        oppnull.zip_utility__c = null;
                        oppnull.Sales_Branch__c = null;
                        
                    }
                update opplistnull; 
            }
        }

  }
}