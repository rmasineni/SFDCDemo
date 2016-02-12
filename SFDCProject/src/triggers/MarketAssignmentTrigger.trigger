trigger MarketAssignmentTrigger on Market_Assignment__c (before insert, before update) {

    List<String> zipcodeList = new List<String>();
    List<String> territoryZipCodeList = new List<String>();

     for(Market_Assignment__c t:trigger.new)
     	{   
     		if(t.Zipcodes__c !=null)
     		{           
        zipcodeList = t.Zipcodes__c.split(',');
        for(String s: zipcodeList){
            s=(s.trim());
            if(s.length() !=5){
                t.addError('Zip Code can only contain 5 digits');
            }
            if(!(Pattern.matches('^[0-9]+$', s))){
            System.debug('****s****'+s);
                t.addError('Zip Code can only contain numeric values');
            }
            territoryZipCodeList.add(s);        
        }       

     } 

  	}
}