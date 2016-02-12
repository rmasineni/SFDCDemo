trigger SCUpdate on ServiceContract (After update, After Insert) 
{
  Boolean skipValidations = false;
  skipValidations = SkipTriggerValidation.performTriggerValidations();
  if(skipValidations == false)
  {
     Set<Id> SetOfSCUpdated = new Set<Id>();
     Set<Id> SetOfOldContacts = new Set<Id>(); 
     Set<Id> SetOfNewContacts = new Set<Id>(); 
     Set<Id> SetOfNonErpContacts = new Set<Id>();  
     Map<Id, Contact> MapOfContact = new Map<Id, Contact>();
      Map<Id, Contact> MapOfNewContact = new Map<Id, Contact>();  
     List<Contact> ListOfContactsToUpd = new List<Contact>(); 
 //    List<Id> ListOfMoreThanOneSC = new List<Id>(); 
     map<id,ServiceContract> MapOfMoreThanOneSC = new map<id,ServiceContract>(); 
     if(Trigger.IsAfter && Trigger.isInsert)
     {
       For(ServiceContract NewSC: Trigger.new)
       {
           If(NewSC.ContactId!=null && NewSC.Contact.ERP_Contact_of_Record__c==False && (!checkRecursive.NewServiceContractIds.contains(NewSC.id)))
              {
                  checkRecursive.NewServiceContractIds.add(NewSC.id);
                  SetOfNonErpContacts.add(NewSC.ContactId);
              }
       }
     }   
      
     if(!(SetOfNonErpContacts.isempty()))
		{
			list<Contact> TempConLst = new list<contact>();
			TempConLst = [select id,name,ERP_Contact_of_Record__c from contact where id in :SetOfNonErpContacts];
			IF(!(TempConLst.isempty()))
			{
			for(integer i=0;i<TempConLst.size();i++) 
              {
				TempConLst[i].ERP_Contact_of_Record__c = True;
                
              }
			    update TempConLst;
			}
		} 
      
   if(Trigger.IsAfter && Trigger.isUpdate)  
   {    
     For (ServiceContract UpdatedSC : Trigger.new)
    {
        If(UpdatedSC.ContactId!=null && Trigger.oldmap.get(UpdatedSC.id).ContactId!=null && Trigger.oldmap.get(UpdatedSC.id).ContactId!=UpdatedSC.ContactId && (!checkRecursive.ServiceContractIds.contains(UpdatedSC.id)))
        {
           checkRecursive.ServiceContractIds.add(UpdatedSC.id);
           SetOfOldContacts.add(Trigger.oldmap.get(UpdatedSC.id).ContactId);
           SetOfSCUpdated.add(UpdatedSC.ID); 
           SetOfNewContacts.add(UpdatedSC.ContactId); 
        }
    }
     If(!SetOfOldContacts.isEmpty() && (!SetOfSCUpdated.isEmpty()) ) 
     {
       MapOfMoreThanOneSC = new Map<Id, ServiceContract>([Select Id,ContactId from ServiceContract where ContactId in :SetOfOldContacts and Id not in : SetOfSCUpdated]);
	 }   
     If(!SetOfOldContacts.isEmpty())
     {    
       MapOfContact = new Map<Id, Contact>([Select Id,Name, ERP_Contact_of_Record__c From Contact where Id in :SetOfOldContacts ]);   
     }    
     If(!SetOfNewContacts.isEmpty())
     {    
      //   For (Contact NewContact:[Select Id,Name, ERP_Contact_of_Record__c From Contact where Id in :SetOfNewContacts ])
      // {
          MapOfNewContact= new Map<Id, Contact>([Select Id,Name, ERP_Contact_of_Record__c From Contact where Id in :SetOfNewContacts ]); 
      // }
     }    
     For (ServiceContract SC: Trigger.new)
     {
       //  If(ListOfMoreThanOneSC.isempty() && MapOfContact.containsKey(Trigger.oldmap.get(SC.id).ContactId) && MapOfContact.get(Trigger.oldmap.get(SC.id).ContactId).ERP_Contact_of_Record__c==True)
         If(MapOfMoreThanOneSC.isempty() && MapOfContact.containsKey(Trigger.oldmap.get(SC.id).ContactId) && MapOfContact.get(Trigger.oldmap.get(SC.id).ContactId).ERP_Contact_of_Record__c==True)
         {
             Contact con = new Contact();
             Con = MapOfContact.get(Trigger.oldmap.get(SC.id).ContactId);
             Con.ERP_Contact_of_Record__c = False;
             ListOfContactsToUpd.add(Con);
         }
         
         If(SC.ContactId!=null && MapOfNewContact.containsKey(SC.ContactId) && MapOfNewContact.get(SC.ContactId).ERP_Contact_of_Record__c!=True)
         {
           // SC.Adderror('Cannot Associate Non ERP Contact to Service Contract');
             Contact con = new Contact();
             Con = MapOfNewContact.get(SC.ContactId);
             Con.ERP_Contact_of_Record__c = True;
             ListOfContactsToUpd.add(Con);
         }
     }
      If(!ListOfContactsToUpd.isEmpty())
          Update ListOfContactsToUpd;
    }
      
  }
      
}