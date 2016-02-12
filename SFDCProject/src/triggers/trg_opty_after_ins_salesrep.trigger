trigger trg_opty_after_ins_salesrep on Opportunity (after insert,after update) {
  Boolean skipValidations = false;
  skipValidations = SkipTriggerValidation.performTriggerValidations();
  if(skipValidations == false){ 
    List<Opportunity> oppList=new List<Opportunity>();
    List<Partner_Role__c> prList=new List<Partner_Role__c>();
    List<Opportunity>opptylist = new List<Opportunity>(); 
    Map<id,Opportunity> SalesRepDivMap = new Map<id,Opportunity>();    
    Map<id,id> oppSalesRepMap=new Map<id,id>();
    //List<Contact> conList=new List<Contact>();
    List<ContactShare> CSShareList=new List<ContactShare>();
    if(userinfo.getUserType()!='PowerPartner'&&trigger.isinsert){    
      for(opportunity o:trigger.new){            
          if(o.salesrep__c==null&&o.Number_of_Proposals__c==0&&o.lead_qualifier__c!=null){
          Opportunity opp=new Opportunity();
          opp.id=o.id;
          opp.ready_for__c='Sales';   
          oppList.add(opp);        
          }
          else if(o.salesrep__c!=null&&o.lead_qualifier__c!=null&&o.Number_of_Proposals__c==0){
          Opportunity opp=new Opportunity();
          opp.id=o.id;
          opp.ready_for__c='Sales'; 
          opp.ownerid=o.SalesRep__c;
          oppList.add(opp);   
          oppSalesRepMap.put(o.id,o.salesrep__c);  
          }
          else if(o.SalesRep__c!=null&&o.lead_qualifier__c!=null&&o.Number_of_Proposals__c>0&&!o.Designer_Assigned_Once__c){
          Opportunity opp=new Opportunity();
          opp.id=o.id;
          opp.ready_for__c='Sales';   
          opp.ownerid=o.SalesRep__c;
          opp.designer__c=o.lead_qualifier__c;
          oppList.add(opp); 
          oppSalesRepMap.put(o.id,o.salesrep__c);    
          }
          else if(o.salesrep__c!=null){
          Opportunity opp=new Opportunity();
          opp.id=o.id;
          opp.ownerid=o.salesrep__c;   
          oppList.add(opp);
          oppSalesRepMap.put(o.id,o.salesrep__c);  
          }
      }       
      }
      else if(trigger.isupdate){
        
        LightMile_User__c lmuser =  LightMile_User__c.getValues('LightMile User');      
          for(opportunity o:trigger.new){                    
              if(userinfo.getUserType()!='PowerPartner'&&o.SalesRep__c!=null&&o.lead_qualifier__c!=null&&o.designer__c==null&&o.Number_of_Proposals__c>0&&!o.Designer_Assigned_Once__c&&lmuser!=null&&o.createdbyid==lmuser.user_id__c){
                Opportunity opp=new Opportunity();
                opp.id=o.id;
                opp.ownerid=o.SalesRep__c;
                opp.ready_for__c='Sales'; 
                opp.designer__c=o.lead_qualifier__c;
                opp.Designer_Assigned_Once__c=true;
                oppList.add(opp);                  
              }
             else if(o.salesrep__c!=null&&Trigger.oldMap.get(o.id).salesrep__c!=o.salesrep__c){                       
                   oppSalesRepMap.put(o.id,o.salesrep__c);
              }            
          }              
//BSKY-5402 Start
         System.debug('BSKY-5402');
         Map<id,id> oppIdSalesRepMap = new Map<id,id>();
         Map<id,id> oppIdContactIdMap = new Map<id,id>();
         Id OpptyId;
         for (Opportunity opp: trigger.new){
            if(userinfo.getUserType()=='PowerPartner' &&
               opp.SalesRep__c!=null && 
               Trigger.oldMap.get(opp.id).salesrep__c!=opp.salesrep__c){  
                  System.debug('Adding Oppty, Salesrep');
                  oppIdSalesRepMap.put(opp.Id, opp.salesrep__c);
            }
         }
         if(!oppIdSalesRepMap.isempty()){
         for(OpportunityContactRole ocr:[Select id, OpportunityId, ContactId From OpportunityContactRole where OpportunityId in :oppIdSalesRepMap.keyset()]){
            oppIdContactIdMap.put(ocr.ContactId,ocr.OpportunityId);  
         }  
         }
         //for(Contact con:[select id, ownerid from Contact where id in :oppIdContactIdMap.keyset()]){
         for(Id conId:oppIdContactIdMap.keyset()){  
            opptyId = oppIdContactIdMap.get(conId);            
            ContactShare CS=new ContactShare();
            CS.ContactAccessLevel='Edit';
            CS.ContactId=conId;
            CS.UserOrGroupId=oppIdSalesRepMap.get(opptyId); 
            System.debug('CS.ContactId :' +CS.ContactId);
            System.debug('CS.UserOrGroupId : ' +CS.UserOrGroupId); 
            if(CS.ContactId != null && CS.UserOrGroupId != null){
              CSShareList.add(CS);  
            }
         }  
         if(!CSShareList.isempty()){
          System.debug('CSShareList :' +CSShareList);                 
            //database.insert(CSShareList,false); 
           try{
             Database.SaveResult[] results = Database.insert(CSShareList,false);
             if(results != null){
               for(Database.SaveResult result : results){
                 if(!result.isSuccess()){
                   Database.Error[] errs = result.getErrors();
                   for(Database.Error err : errs)
                   system.debug(err.getStatusCode() + ' - ' + err.getMessage());  
                 }
               }
             }
           }
           catch(Exception e){
           system.debug(e.getTypeName() + ' - ' + e.getCause() + ':' + e.getMessage());
           }
         }
         
//BSKY-5402 End
      } // end-if update 
      if(!oppSalesRepMap.isempty()){  
            Map<id,Contact> contactMap=new Map<id,Contact>();        
              for(contact c:[select id,email,phone,Department__c,Division__c,Sunrun_User__c from contact where Sunrun_User__c in:oppSalesRepMap.values() and Ultimate_Parent_Account__c != null and Ultimate_Parent_Account__c != '']){
                  contactMap.put(c.Sunrun_User__c,c);
              }
              for(User u:[select id,contactid,contact.email,contact.division__c,contact.phone,contact.department__c from user where id in:oppSalesRepMap.values() and contactid!=null]){
                Contact c=new Contact(id=u.contactid,email=u.contact.email,phone=u.contact.phone,division__c=u.contact.division__c,department__c=u.contact.department__c);
                 contactMap.put(u.id,c);
              }                
            for(Partner_Role__c pr:[select Sales_Rep_Email__c,Sales_Rep_Division__c,Department__c,Sales_Rep_Phone__c,SalesRep__c,opportunity__c from Partner_Role__c where opportunity__c in:oppSalesRepMap.keyset() and Role__c='Sales']){
              if(oppSalesRepMap.containsKey(pr.opportunity__c)){
                Partner_Role__c prole=new Partner_Role__c();
                prole.id=pr.id;
                prole.SalesRep__c=oppSalesRepMap.get(pr.opportunity__c);              
                if(contactMap.containsKey(prole.salesrep__c)){
                  prole.Sales_Rep_Email__c=contactMap.get(prole.salesrep__c).email;
                  prole.Sales_Rep_Phone__c=contactMap.get(prole.salesrep__c).phone;
                  prole.Sales_Rep_Division__c=contactMap.get(prole.salesrep__c).Division__c;
                  prole.Department__c=contactMap.get(prole.salesrep__c).Department__c;
                }
                prList.add(prole);
              }           
            }
                       
            for(Id id:oppSalesRepMap.keyset()){
              Opportunity opp=new Opportunity();
              opp.id=id;
              opp.ownerid=oppSalesRepMap.get(id);
              if(contactMap.containsKey(oppSalesRepMap.get(id))){
              opp.Sales_Rep_Email__c =contactMap.get(oppSalesRepMap.get(id)).Email;       
              opp.Sales_Rep_Division__c=contactMap.get(oppSalesRepMap.get(id)).Division__c;   
              opp.Sales_Representative__c=contactMap.get(oppSalesRepMap.get(id)).id;      
              SalesRepDivMap.put(opp.id,opp);
              }
            }                  
                           
        }
      /*  
         Map<id,id> ocrMap = new Map<id,id>();
         List<Opportunity>opList = new List<Opportunity>();
          Set<Id> setOppIds = new Set<Id>();
         for (Opportunity opp: trigger.new){
           if(Trigger.isInsert)
              setOppIds.add(opp.id);  
         }
         for(OpportunityContactRole ocr:[Select id, OpportunityId, ContactId, Contact.Email From OpportunityContactRole where OpportunityId in :setOppIds and IsPrimary = true]){
           ocrMap.put(ocr.OpportunityId, ocr.ContactId);
         }
         for(Id id:ocrMap.keyset()){
           Opportunity opp = new Opportunity();
           opp.id=id;           
           if(ocrMap.containskey(opp.id)){
             opp.Contact__c = ocrmap.get(opp.id);
           }
           opList.add(opp);
         }
         
        
         if(!opList.isempty())
         update opList;
       */
        if(!SalesRepDivMap.isempty())
       update SalesRepDivMap.values(); 
      if(!oppList.isempty())
      update oppList; 
      if(!prList.isempty())
      update prList;
  }  
}