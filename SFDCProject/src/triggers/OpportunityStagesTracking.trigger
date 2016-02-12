trigger OpportunityStagesTracking on Opportunity (before update) {
   Map<id,Opportunity> leadGeneratedByOpptyMap=new Map<id,Opportunity>(); 
   for (Opportunity opp: trigger.new){
        if(Trigger.oldMap.get(opp.id).stageName!=opp.stageName){
        if (opp.StageName == '2. Appointment Process'){
            opp.Stage2TimeStamp__c = opp.Stage2TimeStamp__c==null? system.now() : opp.Stage2TimeStamp__c;            
        } 
       else if (opp.StageName == '3. Proposal Presented to Customer') {
            opp.Stage3TimeStamp__c = opp.Stage3TimeStamp__c==null? system.now() : opp.Stage3TimeStamp__c;
            opp.Stage2TimeStamp__c = opp.Stage2TimeStamp__c==null? system.now() : opp.Stage2TimeStamp__c;            
       }            
        else if (opp.StageName =='4. Verbal Commit'){
            opp.Stage4TimeStamp__c = opp.Stage4TimeStamp__c==null? system.now() : opp.Stage4TimeStamp__c;
            opp.Stage3TimeStamp__c = opp.Stage3TimeStamp__c==null? system.now() : opp.Stage3TimeStamp__c;
            opp.Stage2TimeStamp__c = opp.Stage2TimeStamp__c==null? system.now(): opp.Stage2TimeStamp__c;           
            }
        else if (opp.StageName == '5. Customer Signed Agreement'){
            opp.Stage5TimeStamp__c = opp.Stage5TimeStamp__c==null ? system.now() : opp.Stage5TimeStamp__c;
            opp.Stage4TimeStamp__c = opp.Stage4TimeStamp__c==null ? system.now() : opp.Stage4TimeStamp__c;
            opp.Stage3TimeStamp__c = opp.Stage3TimeStamp__c == null ? system.now() : opp.Stage3TimeStamp__c;
            opp.Stage2TimeStamp__c = opp.Stage2TimeStamp__c == null ? system.now() : opp.Stage2TimeStamp__c;            
        }
        else if (opp.StageName == '6. Submitted To Operations'){
            opp.Stage6TimeStamp__c = opp.Stage6TimeStamp__c==null? system.now() : opp.Stage6TimeStamp__c;
            opp.Stage5TimeStamp__c = opp.Stage5TimeStamp__c ==null ? system.now() : opp.Stage5TimeStamp__c ;
            opp.Stage4TimeStamp__c = opp.Stage4TimeStamp__c==null ? system.now() : opp.Stage4TimeStamp__c;
            opp.Stage3TimeStamp__c = opp.Stage3TimeStamp__c == null ? system.now() : opp.Stage3TimeStamp__c;
            opp.Stage2TimeStamp__c = opp.Stage2TimeStamp__c == null ? system.now() : opp.Stage2TimeStamp__c;           
        }
        else if (opp.StageName == '7. Closed Won'){
            opp.Stage7TimeStamp__c = opp.Stage7TimeStamp__c==null? system.now() : opp.Stage7TimeStamp__c;
        }
        else if (opp.StageName == '8. Future Prospect'){
            opp.Stage8TimeStamp__c = opp.Stage8TimeStamp__c==null? system.now() : opp.Stage8TimeStamp__c;
            }
        else if (opp.StageName == '9. Closed Lost'){
            opp.Stage9Timestamp__c = opp.Stage9TimeStamp__c==null? system.now() : opp.Stage9TimeStamp__c;
        }
    }
    if(userinfo.getUserType()!='PowerPartner'&&opp.salesrep__c!=null&&opp.ownerid!=opp.salesrep__c&&opp.Channel_2__c!='Partner'){
        opp.ownerid=opp.salesrep__c;
    }
    if(opp.Lead_Generated_By__c!=Trigger.oldMap.get(opp.id).Lead_Generated_By__c){
        leadGeneratedByOpptyMap.put(opp.Lead_Generated_By__c,opp);
    }     
    }
    if(Trigger.isupdate&&Trigger.isBefore){
        OpportunityUtil.doJitterBitRollBackFields(Trigger.new,Trigger.oldMap);       
    } 
    if(!leadGeneratedByOpptyMap.isempty()){
        Map<id,String> userFMBMap=new Map<id,String>();
        for(User userObj:[select id,Field_marketing_team__c from user where id in:leadGeneratedByOpptyMap.keyset()]){
            userFMBMap.put(userObj.id,userObj.Field_marketing_team__c);
        }
        for(opportunity opp:leadGeneratedByOpptyMap.values()){
            if(userFMBMap.containsKey(opp.lead_generated_by__c)){
                opp.field_marketing_branch__c=userFMBMap.get(opp.lead_generated_by__c);
            }
        }
    }   
}