trigger trg_opptyteam_before_insert_update on Opportunity_Team__c (before insert, before update, before delete,after insert, after update) {
     Map<Id, Opportunity> optyMap = New Map<Id, Opportunity>(); 
     List<Opportunity>opplist = new List<Opportunity>(); 
     List<Task__c> taskList = new  List<Task__c>();
     Set<String> roles =  new Set<String>();
     public List<project__c> listPrj =null;
     Map<Id, Opportunity> updateoptyMap = New Map<Id, Opportunity>(); 
    
     if(trigger.isdelete){ 
      for(Opportunity_Team__c ot: trigger.old){
        
            Opportunity opp=new Opportunity();
            opp.id=ot.Opportunity__c;
            opp.OM_Assigned__c = false;
            //optyMap.put(opp.Id, opp);
            
            opplist.add(opp);
      }
   
      }
      if(!opplist.isempty())
        update opplist;
    
     if(!trigger.isdelete){
          if(trigger.isBefore){
     for(Opportunity_Team__c ot: trigger.new){
        if((trigger.isinsert&& ot.Role__c=='Order Manager') || (trigger.isUpdate &&trigger.oldmap.get(ot.id).Role__c!=ot.Role__c && ot.Role__c =='Order Manager')){
            Opportunity opp=new Opportunity();
            opp.id=ot.Opportunity__c;
            opp.OM_Assigned__c = true;
            optyMap.put(opp.Id, opp);
        }
        
        if((trigger.isinsert&& ot.Role__c!='Order Manager') || (trigger.isUpdate &&trigger.oldmap.get(ot.id).Role__c!=ot.Role__c && ot.Role__c !='Order Manager')){
            Opportunity opp=new Opportunity();
            opp.id=ot.Opportunity__c;
            opp.OM_Assigned__c = false;
            optyMap.put(opp.Id, opp);
        }
        
         if((trigger.isinsert && ot.Role__c!=null)||(trigger.isUpdate &&trigger.oldmap.get(ot.id).Role__c!=ot.Role__c )) {
             If(!roles.contains(ot.Role__c)){
                 roles.add(ot.Role__c);
             }
             else {
                 ot.Role__c.addError('Role already exists with another User.');
             }        
             
         }
     }
         
              if(!optyMap.isEmpty() && optyMap.size() >0  ){
                  for(Opportunity_Team__c optyTeam:[Select Role__c,id,Opportunity__c 
                                                    From Opportunity_Team__c 
                                                    where Role__c in:roles and Opportunity__c in : optyMap.keyset() ]){
                                                        for(Opportunity_Team__c ot: trigger.new){
                                                            if( optyTeam.Opportunity__c == ot.Opportunity__c &&  optyTeam.Role__c == ot.Role__c){
                                                                ot.Role__c.addError('Role already exists with another User');
                                                            }
                                                        }
                                                    }
              }    

          
    if(!optyMap.isempty()){
        update optyMap.values();
        } 
     }
    }
    
   //Assign OptyTeam user as task owner for the assigned project
            If(System.trigger.isAfter){
                If(System.trigger.isInsert|| System.trigger.isUpdate){
                    assignOptyTeamUsertoTaskOwner(System.Trigger.newMap);
                }
            }
            
    private void assignOptyTeamUsertoTaskOwner( Map<Id, Opportunity_Team__c> TeamOptyMap ) {
        for(Id optyTeamID : TeamOptyMap.keySet()){
            Opportunity opty =  new Opportunity();
            listPrj=  [Select Id,Status__c from project__c where Opportunity__c in (Select Id FROM Opportunity where id =:TeamOptyMap.get(optyTeamID).Opportunity__c) 
                       limit 1 ];
            opty=[Select Id FROM Opportunity where id =:TeamOptyMap.get(optyTeamID).Opportunity__c limit 1 ];
            If(listPrj.size()>0){
                for(Task__c task : [Select id, Group_Name__c, Task_Owner__c FROM Task__c where Project_Name__c in (select id from project__c where Status__c!='Blocked' and Id=: listPrj[0].id ) and Status__c!='Complete']){
                    If(TeamOptyMap.get(optyTeamID).Role__c== task.Group_Name__c){
                        task.Task_Owner__c= TeamOptyMap.get(optyTeamID).user__c;
                        taskList.add(task);
                    }
                    if(TeamOptyMap.get(optyTeamID).Role__c=='Project Planner'){
                        opty.Project_Manager__c=TeamOptyMap.get(optyTeamID).user__c;
                        updateoptyMap.put(opty.id,opty);
                    } if(TeamOptyMap.get(optyTeamID).Role__c=='Design Engineering'){
                        opty.PV_Designer__c=TeamOptyMap.get(optyTeamID).user__c;
                        updateoptyMap.put(opty.id,opty);
                    }
                    
                    
                }
            } 
            
        }
        If(!taskList.isEmpty())
            update taskList;
        If(!updateoptyMap.isEmpty())
            update updateoptyMap.values();
    }
        
}