trigger CoreLogicInfoUpdate on Account (before insert, before update) {
    set<String> LandUseCodeSet = new set<String>();
    if (trigger.isInsert || (trigger.isUpdate)){
        for (Account acc : Trigger.new){
            Account Oldacc;
            if (trigger.isInsert){
                if(acc.Land_Use__c !=null && acc.Land_Use__c !=''){
                LandUseCodeSet.add(acc.Land_Use__c);
                }
                acc.Account_Division_Custom__c=acc.Division;
            }  
            else if (trigger.isUpdate){
                Oldacc = trigger.oldmap.get(acc.Id);
                if (Oldacc.Land_Use__c != acc.Land_Use__c){
                    LandUseCodeSet.add(acc.Land_Use__c);
                   }
                if(acc.Account_Division_Custom__c==null||Oldacc.division!=acc.division){
                  acc.Account_Division_Custom__c=acc.Division;
                }
            }  
        }
    }    
    if (!LandUseCodeSet.isEmpty()){
        Map <String,Land_Use__c> LandUseIMap = new Map <String,Land_Use__c>();
        for (Land_Use__c ld : [Select id,Name,Description__c,Permitted__c,Type__c from Land_Use__c where Name IN: LandUseCodeSet]){
            LandUseIMap.put(ld.Name,ld);
           
        }
       
        for (Account acc: Trigger.new){
            if(acc.Land_Use__c !=null && acc.Land_Use__c !=''){
                if (LandUseIMap.containsKey(acc.Land_Use__c)){
                    acc.Land_Use_Type__c = LandUseIMap.get(acc.Land_Use__c).Type__c;
                    
                     }
               
            }
            else {
                acc.Land_Use_Type__c = null;
            }
        }
    }
}