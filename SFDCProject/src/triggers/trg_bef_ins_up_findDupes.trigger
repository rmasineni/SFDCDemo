trigger trg_bef_ins_up_findDupes on Contact (before insert, before update) {

 Boolean skipValidations = False;
 skipValidations = SkipTriggerValidation.performTriggerValidations();
 if(skipValidations == false){
  
  Set<id> UniqueIds=new Set<id>();
  Id RectypeId=Schema.SObjectType.Contact.RecordTypeInfosByName.get('Employee').RecordTypeId;
  for(Contact cont:trigger.new){
    if(cont.recordtypeid==RectypeId&&cont.Sunrun_User__c!=null&&(Trigger.isinsert||(Trigger.isupdate&&trigger.oldMap.get(cont.id).Sunrun_User__c!=cont.Sunrun_User__c))){
      UniqueIds.add(cont.Sunrun_User__c);
    }
        cont.Contact_Division_Custom__c=cont.Division;
  }
  if(!UniqueIds.isEmpty()){
    Map<id,Contact> ContMap=new Map<id,Contact>();
    for(Contact cont:[select id,Sunrun_user__c,name from contact where Sunrun_user__c in:UniqueIds and recordTypeId=:RectypeId]){
      ContMap.put(cont.Sunrun_user__c,cont);
    }
    for(Contact cont:trigger.new){
      if(ContMap.containsKey(cont.Sunrun_user__c)){
        String ContURL = URL.getSalesforceBaseUrl().toExternalForm() + '/' + ContMap.get(cont.Sunrun_user__c).id;
        ContURL='<a href=\"' + ContURL + '\">' +  ContMap.get(cont.Sunrun_user__c).name + '</a>';
        cont.adderror('Cannot have duplicate contact for the User: '+ContURL,false);
      }
    }
  }
  
 }     
}