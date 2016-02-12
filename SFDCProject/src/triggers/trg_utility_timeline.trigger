trigger trg_utility_timeline on ServiceContract (before insert, before update) {

  Map<Id,string> scMap = new Map<id,string>();
  Map<string,string> uttMap = new Map<string,string>();
  List<serviceContract> scList = new List<serviceContract>();
  List<serviceContract> updSCList = new List<ServiceContract>();
  
  for(serviceContract sc : Trigger.new){
   if(Trigger.isInsert || Trigger.isUpdate && sc.Utility_Company__c != Trigger.OldMap.get(sc.id).Utility_Company__c){
   scmap.put(sc.Id,sc.Utility_Company__c);
   system.debug('-->scmap'+scmap);
   scList.add(sc);
   }
  }

  //List<Utility_Timelines__c> utilList = [Select Id, name, Timeline_PDF_URL__c from Utility_Timelines__c where name in : scmap.values()];
  if(!scMap.isEMpty()){
   for(Utility_Timelines__c utt : [Select Id, name, Timeline_PDF_URL__c from Utility_Timelines__c where name in : scmap.values()]){
     uttMap.put(utt.name,utt.Timeline_PDF_URL__c);
     
   }
   system.debug('-->uttmap'+uttmap);
  }  

  if(!uttMap.isEmpty()){
   for(serviceContract sercon : scList){
  
      if(uttMap.containsKey(sercon.Utility_Company__c)){
      system.debug('-->contains'+uttmap.keyset());
        sercon.Timeline_PDF__c = uttmap.get(sercon.Utility_Company__c);
        updSCList.add(sercon);
      }
   }
  } 

  if(!updSCList.isEmpty()){
  //database.update(updSCList,false);
  }





}