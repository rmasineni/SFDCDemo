public class JurisdictionOnOppty{

 public static void copyJurisdictionToOppty(List<Opportunity> opportunityList, Boolean IsUpdate, Map<Id,Opportunity> oldMap, Map<Id,Opportunity> newMap){

  Map<Id,String> optyCountyMap = new Map<Id,String>();
  Map<Id,String> optyCityMap = new Map<Id,String>();
  Map<string,string> ahjCountyMap = new Map<string,string>();
  Map<string,string> ahjCityMap = new Map<string,string>();
  List<Opportunity> optylist = new List<opportunity>();
  Map<string,Id> ahjCountyMap1 = new Map<string,Id>();
  Map<string,Id> ahjCityMap1 = new Map<string,Id>();
     
  for(opportunity opp : opportunityList){
   if(isUpdate && (opp.Account_County__c != null || newMap.get(opp.Id).Address__c != oldMap.get(opp.Id).Address__c)){
     if(!jurisdictionIds.contains(opp.Id)){
      jurisdictionIds.add(opp.Id); 
        if(opp.Incorporation_Status__c == 'No'){
          optyCountyMap.put(opp.Id,opp.Account_County__c.toLowerCase());
        }
        else{
          optyCityMap.put(opp.Id,opp.Account_City__c.toLowerCase());
        }
      optylist.add(opp);
     }
   }
  }
      
  if(!optyCountyMap.isEmpty()){
    for(Jurisdictions__c ahj : [select id,Name,Jurisdiction_Name__c, county__c from Jurisdictions__c where county__c in : optyCountyMap.values()])
    {
     //ahjCountyMap.put(ahj.county__c,ahj.Name);
     ahjCountyMap1.put(ahj.county__c.toLowerCase(),ahj.Id);
    }
  }
  system.debug('==>ahjCountyMap1'+ahjCountyMap1);
  if(!optyCityMap.isEmpty()){
    for(Jurisdictions__c ahj : [select id,Name,Jurisdiction_Name__c, city__c from Jurisdictions__c where city__c in : optyCityMap.values()])
    {
     //ahjCityMap.put(ahj.city__c,ahj.Name);
     ahjCityMap1.put(ahj.city__c.toLowerCase(),ahj.Id);
    }
  }
  system.debug('==>ahjCityMap1'+ahjCityMap1);
  for(opportunity oppt : optylist){
    if(oppt.Incorporation_Status__c == 'No'){
      if(!ahjCountyMap1.isEmpty() && ahjCountyMap1.get(optyCountyMap.get(oppt.Id)) != null){  
        oppt.Jurisdiction__c = ahjCountyMap1.get(optyCountyMap.get(oppt.Id));
        system.debug('==>AHJ'+oppt.Jurisdiction__c);
      }
    }
    else{
      if(!ahjCityMap1.isEmpty() && ahjCityMap1.get(optyCityMap.get(oppt.Id)) != null){
        oppt.Jurisdiction__c = ahjCityMap1.get(optyCityMap.get(oppt.Id));
        system.debug('==>AHJ'+oppt.Jurisdiction__c);
      }
    }
  }

 }
 
 public static Set<Id> jurisdictionIds = new Set<Id>();
 

}