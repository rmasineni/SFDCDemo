trigger Contact_After_Update on Contact (After Update) 
{
  Boolean skipValidations = false;
  skipValidations = SkipTriggerValidation.performTriggerValidations();
  if(skipValidations == false){
    if(controlContactTriggerRecursion.AllowcontactTrigger)
    {
        controlContactTriggerRecursion.AllowcontactTrigger = false;
        set<Id> SetOfContUpdated = New set<Id>();
        Map<string,contact> MapOfContactEmailAndContact = new Map<string,contact>();
        for(Contact UpdatedContact : Trigger.new ) 
        {      
            system.debug('$#&*&#$$&value from Old map='+trigger.oldmap.get(UpdatedContact.id).Ambassador__Ambassador_ID__c);
            system.debug('$#&*&#$$&New Update Value ='+UpdatedContact.Ambassador__Ambassador_ID__c);
            if(trigger.oldmap.get(UpdatedContact.id).Ambassador__Ambassador_ID__c!=UpdatedContact.Ambassador__Ambassador_ID__c )
            {
                
                SetOfContUpdated.add(UpdatedContact.Id); 
                MapOfContactEmailAndContact.put(UpdatedContact.Email,UpdatedContact); 
                system.debug('==This is SetOfContUpdated===:'+SetOfContUpdated + '===This isMapOfContactEmailAndContact keys:'+ MapOfContactEmailAndContact.keySet() + '===This isMapOfContactEmailAndContact values:' + MapOfContactEmailAndContact.values());
            }
        }
        
        set<String> EmailIdProcessed = new set<String>();
        Map<id,contact> NewRecordToupdate = new map<id,contact>();
          if(!SetOfContUpdated.isEmpty()) 
            {
               NewRecordToupdate = new map<id,contact>([select id,name,Email,ERP_Contact_of_Record__c,Ambassador__Remote_Customer_ID__c,Ambassador__Ambassador_ID__c from Contact Where Id in :SetOfContUpdated]);
            }
        list<Contact> LstOfNewContactToUpdate = new list<Contact>();
        List<contact> LstOfExistingContactToUpdate = new list<Contact>();
        For(Contact ExistingContacts : [Select Id,name,Email,CreatedDate,ERP_Contact_of_Record__c,Ambassador__Remote_Customer_ID__c,Ambassador__Ambassador_ID__c from Contact Where Id not in :SetOfContUpdated and email in : MapOfContactEmailAndContact.keyset() and ERP_Contact_of_Record__c=true Order by CreatedDate Desc])   
        {
            if(!(EmailIdProcessed.contains(ExistingContacts.Email)))
            {
                EmailIdProcessed.add(ExistingContacts.Email);
                if(MapOfContactEmailAndContact.containskey(ExistingContacts.Email))
                {
                 // if((trigger.oldmap.get((MapOfContactEmailAndContact.get(ExistingContacts.Email)).id)).CreatedDate < ExistingContacts.CreatedDate)
                 if((trigger.oldmap.get((MapOfContactEmailAndContact.get(ExistingContacts.Email)).id)).CreatedDate < ExistingContacts.CreatedDate 
                 && ((trigger.oldmap.get((MapOfContactEmailAndContact.get(ExistingContacts.Email)).id)).ERP_Contact_of_Record__c==true && ExistingContacts.ERP_Contact_of_Record__c==true) ) 
                  {    
                    ExistingContacts.Ambassador__Ambassador_ID__c = (MapOfContactEmailAndContact.get(ExistingContacts.Email)).Ambassador__Ambassador_ID__c;
                    ExistingContacts.External_Id__c = (MapOfContactEmailAndContact.get(ExistingContacts.Email)).External_Id__c;
                    System.debug('===Amb ID'+ (MapOfContactEmailAndContact.get(ExistingContacts.Email)).Ambassador__Ambassador_ID__c);
                    LstOfExistingContactToUpdate.add(ExistingContacts);
                    if(NewRecordToupdate.containskey((MapOfContactEmailAndContact.get(ExistingContacts.Email)).id))
                    {
                        contact con = new contact();
                        con = NewRecordToupdate.get(MapOfContactEmailAndContact.get(ExistingContacts.Email).id);
                        con.Ambassador__Ambassador_ID__c = null;
                        con.External_Id__c = null;
                        System.debug('==AmID=='+ con.Ambassador__Ambassador_ID__c+ '==ExtID=='+con.External_Id__c);                        
                        LstOfNewContactToUpdate.add(con);
                    }
                  }   
                 if((trigger.oldmap.get((MapOfContactEmailAndContact.get(ExistingContacts.Email)).id)).ERP_Contact_of_Record__c==False && ExistingContacts.ERP_Contact_of_Record__c==true) 
                  {    
                    ExistingContacts.Ambassador__Ambassador_ID__c = (MapOfContactEmailAndContact.get(ExistingContacts.Email)).Ambassador__Ambassador_ID__c;
                    ExistingContacts.External_Id__c = (MapOfContactEmailAndContact.get(ExistingContacts.Email)).External_Id__c;
                    System.debug('===Amb ID'+ (MapOfContactEmailAndContact.get(ExistingContacts.Email)).Ambassador__Ambassador_ID__c);
                    LstOfExistingContactToUpdate.add(ExistingContacts);
                    if(NewRecordToupdate.containskey((MapOfContactEmailAndContact.get(ExistingContacts.Email)).id))
                    {
                        contact con = new contact();
                        con = NewRecordToupdate.get(MapOfContactEmailAndContact.get(ExistingContacts.Email).id);
                        con.Ambassador__Ambassador_ID__c = null;
                        con.External_Id__c = null;
                        System.debug('==AmID=='+ con.Ambassador__Ambassador_ID__c+ '==ExtID=='+con.External_Id__c);                        
                        LstOfNewContactToUpdate.add(con);
                    }
                  }     
                }
            }
        }
        System.debug('==LstOfNewContactToUpdate===:'+LstOfNewContactToUpdate);
        System.debug('==LstOfExistingContactToUpdate===:'+LstOfExistingContactToUpdate);
        if(!(LstOfNewContactToUpdate.isempty()))
            update LstOfNewContactToUpdate;
        if(!(LstOfExistingContactToUpdate.isempty()))
            update LstOfExistingContactToUpdate;
    }
  }    
}