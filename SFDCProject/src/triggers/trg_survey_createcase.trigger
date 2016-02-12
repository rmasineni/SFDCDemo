trigger trg_survey_createcase on Survey__c (after insert) {
     List<Case> caseList=new List<Case>();
     Recordtype recId=[select id from recordtype where sobjecttype='Case' and name='Survey' limit 1];
    Group Detractorid = [Select Id from Group where Name = 'Detractor Call Cases' and Type = 'Queue'];
    for(Survey__c survObj:trigger.new){
        if(survObj.CSAT_Survey_Response__c<7){
             Case ca=new Case();
              ca.recordtypeid=recId.id;
              ca.Service_Contract__c=survObj.Service_Contract__c;
              ca.Survey__c =  survObj.id;            
              ca.status = 'Open';
              ca.origin = 'CSAT Survey';
              ca.ContactId = survObj.Contact__c;
              ca.Subject='Survey Detractor Callback';
              if(Detractorid!=null) {          
              ca.ownerid=Detractorid.id;           
              }
          caseList.add(ca);    
        }
    }
   
    if(!caseList.isempty()){
        insert caseList;    
    }
}