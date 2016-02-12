public class AccountUtil {
    
    public static string RESIDENTIAL = 'Residential';
    public static Set<Id> eligibleForVoid = new Set<Id>();
    public static Set<Id> voidedAccountIds = new Set<Id>();
    public static Boolean isZip6Changed(Account newAccountObj, Account oldAccountObj){
    	boolean result = false;
    	if(newAccountObj != null && oldAccountObj != null){
    		if(newAccountObj.Zip_6__c != oldAccountObj.Zip_6__c){
    			result = true;
    		} 
    	}
    	return result;
    }
    
	public static Boolean isAddressInformationChanged(Account newAccountObj, Account oldAccountObj){
        boolean result = false;
		//System.debug('newAccountObj: '  +newAccountObj);
		//System.debug('oldAccountObj: '  +oldAccountObj);
		Boolean modifiedPostalCode = false;
		String oldPostalCode = (oldAccountObj.BillingPostalCode != null) ? oldAccountObj.BillingPostalCode : '';
		String newPostalCode = (newAccountObj.BillingPostalCode != null) ? newAccountObj.BillingPostalCode : '';
		if(newPostalCode != oldPostalCode && !newPostalCode.contains(oldPostalCode)){
			modifiedPostalCode = true;
		}
		System.debug('modifiedPostalCode: '  +modifiedPostalCode);
		
		if(newAccountObj != null && oldAccountObj != null && !system.isFuture()){
			if((newAccountObj.BillingCity != oldAccountObj.BillingCity) 
			|| (newAccountObj.BillingCountry != oldAccountObj.BillingCountry) 
			|| (newAccountObj.BillingState != oldAccountObj.BillingState) 
			|| (newAccountObj.BillingStreet != oldAccountObj.BillingStreet) 
			|| (modifiedPostalCode) 
			|| (modifiedPostalCode && newAccountObj.Zip_6__c != oldAccountObj.Zip_6__c)){
				result = true;
			}
		}
		System.debug('result: ' + result);
        return result;
    }
    
    public static void copyAcctAddressInformation(Account targetAcct, Account sourceAcct){
        targetAcct.BillingStreet = sourceAcct.BillingStreet ;
        targetAcct.BillingCity = sourceAcct.BillingCity;
        targetAcct.BillingState = sourceAcct.BillingState ;
        targetAcct.BillingCountry = sourceAcct.BillingCountry ;
        targetAcct.BillingPostalCode = sourceAcct.BillingPostalCode ;
        targetAcct.Zip_6__c = sourceAcct.Zip_6__c ;
        targetAcct.CDYNE_Status__c =  sourceAcct.CDYNE_Status__c ;
  }
  
  public static Map<Id, Account> accountsMap;
  public static Map<id,Account> getAccountsForBillingPostalcode(set<Id> accountIds){
  	if(accountsMap != null && !accountsMap.isEmpty()){
  		for(Id accountId : accountIds){
  			if(!accountsMap.containsKey(accountId)){
  				accountsMap = null;
  				break;
  			}
  		}
  	}
  	if(accountsMap == null){
  		accountsMap = new Map<id,Account>([select Id, billingpostalcode from account where id in:accountIds]);
  	}
  	return accountsMap;
  }
}