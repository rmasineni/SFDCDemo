trigger ERPUpdateRestriction on Contact (before insert, before update, after insert) {
Boolean skipValidations = false;
skipValidations = SkipTriggerValidation.performTriggerValidations();
  if(skipValidations == false)
  {
      Set<Id> SetOfERPContacts = new set<Id>(); 
      Map<Id,Id> ERPConthasSC = new Map<Id,Id>();
      List<Id> ListOfSC = new List<Id>();
      List<Contact> ListOfConToUpd = new List<Contact>();
      if(Trigger.isAfter && Trigger.isInsert)
      {   
      For(Contact ERPContacts: Trigger.new)
        {
          if(ERPContacts.ERP_Contact_of_Record__c==true)
          {
              SetOfERPContacts.add(ERPContacts.id);
          }
        }
      }     
      if(Trigger.isUpdate)
      {     
          For(Contact ERPContacts: Trigger.new)
         {
            if(Trigger.oldmap.get(ERPContacts.id).ERP_Contact_of_Record__c==True && ERPContacts.ERP_Contact_of_Record__c==False)
           {
              SetOfERPContacts.add(ERPContacts.id);
              
           }
         }
      }    
     if(!SetOfERPContacts.isEmpty()) 
     {    
      For(ServiceContract SC : [Select id,name,ContactId from ServiceContract where ContactId in:SetOfERPContacts  ])
      {
          ERPConthasSC.put(SC.ContactId,SC.id);
          ListOfSC.add(SC.id);
          System.debug('This is map keys:'+ ERPConthasSC.keySet());
          System.debug('This is map values:'+ ERPConthasSC.values());
      }
     }    
        
    
      if(Trigger.isUpdate)
      {     
        For(Contact CreateUpdateERP: Trigger.new)
        {  
           System.debug('This contains key: '+ ERPConthasSC.containskey(CreateUpdateERP.id));
          System.debug('This contains key: '+ CreateUpdateERP.ERP_Contact_of_Record__c);  
          system.debug('This is list size:'+ ListOfSC.isEmpty());   
          if(Trigger.oldmap.get(CreateUpdateERP.id).ERP_Contact_of_Record__c==True && CreateUpdateERP.ERP_Contact_of_Record__c==False && ERPConthasSC.containskey(CreateUpdateERP.id))
          {
              CreateUpdateERP.adderror('Cannot update ERP Contact Associated to Service Contract');
          }
        }
      }   
      
       if(Trigger.isAfter && Trigger.isInsert)
      {    
		set<id> ContactNeedsToUpdate = new set<id>();
        For(Contact CreateUpdateERP: Trigger.new)
        {
          System.debug('This contains key: '+ ERPConthasSC.containskey(CreateUpdateERP.id));
          System.debug('This contains key: '+ CreateUpdateERP.ERP_Contact_of_Record__c);  
          // system.debug('This is list size:'+ ListOfSC.isEmpty());  
          //  if(CreateUpdateERP.ERP_Contact_of_Record__c==True && ListOfSC.isEmpty())
          if(CreateUpdateERP.ERP_Contact_of_Record__c==True && !ERPConthasSC.containsKey(CreateUpdateERP.id) && !checkRecursive.CloneERPContactIds.contains(CreateUpdateERP.id))
          {
				ContactNeedsToUpdate.add(CreateUpdateERP.id);
                checkRecursive.CloneERPContactIds.add(CreateUpdateERP.id);
                System.debug('##ContacNeedsToupd##:'+ ContactNeedsToUpdate);
          }
        }
		if(!(ContactNeedsToUpdate.isempty()))
		{
			list<Contact> TempConLst = new list<contact>();
			TempConLst = [select id,name,ERP_Contact_of_Record__c from contact where id in :ContactNeedsToUpdate];
			IF(!(TempConLst.isempty()))
			{
			for(integer i=0;i<TempConLst.size();i++) 
              {
				TempConLst[i].ERP_Contact_of_Record__c = False;
                
              }
			    update TempConLst;
			}
		}
      } 
     
      
  }   

}