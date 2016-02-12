trigger Employee_Referral on Contact (before Update, before Insert)
{
    Boolean skipValidations = false;
    skipValidations = SkipTriggerValidation.performTriggerValidations();
    if(skipValidations == false){
    //Account[] A = [Select Id, Name from Account where name = 'Sunrun' Limit 1];    
    //RecordType[] R =[SELECT DeveloperName,Id FROM RecordType where Developername='Employee' and SobjectType ='contact' Limit 1]  ; 
    Id R=Schema.SObjectType.Contact.RecordTypeInfosByName.get('Employee').RecordTypeId;                 
    if(controlContactTriggerRecursion.AllowTriggerFlag)
    {   
        controlContactTriggerRecursion.AllowTriggerFlag = false;
        Map<String,list<contact>> MapOfContactsNeedToProcess = new Map<String,list<contact>>();
        for(Contact ContactTempObj: Trigger.new)
        {
          If(Trigger.IsBefore && Trigger.IsInsert)
 
          {   
             system.debug('@#*$#@&@#*&$@# External_Id ='+ContactTempObj.lastname);
             system.debug('@#*$#@&@#*&$@# External_Id ='+ContactTempObj.External_Id__c);
             system.debug('@#*$#@&@#*&$@# Email ='+ContactTempObj.Email);
             system.debug('@#*$#@&@#*&$@# Ambassador__Ambassador_ID__c ='+ContactTempObj.Ambassador__Ambassador_ID__c); 
             if((ContactTempObj.External_Id__c==null || ContactTempObj.External_Id__c=='') && ContactTempObj.Email!=null && ContactTempObj.Email!='' && ContactTempObj.Ambassador__Ambassador_ID__c!=null && ContactTempObj.Ambassador__Ambassador_ID__c!='')         
            {
                ContactTempObj.External_Id__c=ContactTempObj.Email;
            } 
          }    
            If(Trigger.IsBefore && Trigger.Isupdate) 
          {     
             if((ContactTempObj.External_Id__c==null || ContactTempObj.External_Id__c=='') && ContactTempObj.Email!=null && ContactTempObj.Email!='' && ContactTempObj.Ambassador__Ambassador_ID__c!=null && ContactTempObj.Ambassador__Ambassador_ID__c!='' && trigger.oldmap.get(ContactTempObj.id).Ambassador__Ambassador_ID__c!=ContactTempObj.Ambassador__Ambassador_ID__c)         
            {
                ContactTempObj.External_Id__c=ContactTempObj.Email;
            } 
          }    
           If(Trigger.IsBefore && Trigger.IsInsert)   
          {     
             if(ContactTempObj.Email!=null && ContactTempObj.Email!='' && ContactTempObj.Ambassador__Ambassador_ID__c!=null && (ContactTempObj.Email.Contains('@sunrun')||ContactTempObj.Email.Contains('@Sunrun')||ContactTempObj.Email.Contains('@cleanenergyexperts.com')||ContactTempObj.Email.Contains('@snapnrack.com')||ContactTempObj.Email.Contains('@aeesolar.com')))
            {
                     if (R!=null)
                     ContactTempObj.RecordTypeId=R;
                     //if (A.size() > 0)
                     ContactTempObj.AccountId=System.label.sunrun_inc_id;
                //   ContactTempObj.AccountId = '001g000000Utzpp';
                   ContactTempObj.Contact_Type__c='Employee';
                System.debug('This is cont type: '+ ContactTempObj.Contact_Type__c);
                System.debug('This is Acc Id: '+ ContactTempObj.AccountId);
                System.debug('This is RecordType Id: '+  ContactTempObj.RecordTypeId);
            }    
              
             if(ContactTempObj.Email!=null && ContactTempObj.Email!='' && ContactTempObj.Ambassador__Ambassador_ID__c!=null && (ContactTempObj.Email.Contains('@sunrun.com')||ContactTempObj.Email.Contains('@Sunrun.com')||ContactTempObj.Email.Contains('@sunrunhome.com')||ContactTempObj.Email.Contains('@Sunrunhome.com')))
            {
               // ContactTempObj.RecordTypeId=R[0].Id;
              //  ContactTempObj.AccountId=A[0].id;
              //  ContactTempObj.Contact_Type__c='Employee';
                List<String> EmailSplit = new list<string>();
                EmailSplit = ContactTempObj.Email.split('@');
                System.debug('This is Email split' + EmailSplit);
                String MapKey = EmailSplit[0]+'%';
                MapKey = MapKey.toLowerCase();
                System.debug('This is MapKey:'+ MapKey);
              
                if(MapOfContactsNeedToProcess.containsKey(MapKey))
                {
                    
                    list<contact> TempContactLst = new list<contact>();
                    TempContactLst.addall(MapOfContactsNeedToProcess.get(MapKey));
                    TempContactLst.add(ContactTempObj);
                    MapOfContactsNeedToProcess.put(MapKey,TempContactLst);
                    System.debug('This is '+MapOfContactsNeedToProcess);
                }
                else
                {
                    list<contact> TempContactLst = new list<contact>();
                    TempContactLst.add(ContactTempObj);
                    MapOfContactsNeedToProcess.put(MapKey,TempContactLst);
                    System.debug('This is MapOfContactsNeedToProcess: '+ MapOfContactsNeedToProcess);
                }
            }
          }    
        }
        if(MapOfContactsNeedToProcess.size()>0)
        {
            list<contact> LstOfExistingContact = new list<contact>();
            System.debug('This contains Key :'+MapOfContactsNeedToProcess.keyset());
            LstOfExistingContact = [select id,name,email,RecordType.name from contact where email like : MapOfContactsNeedToProcess.keyset() and (Email LIKE '%@Sunrun%' or Email Like '%@sunrun%' ) and (Email LIKE '%com') and RecordType.name='Employee'];
            System.debug('This is list of ext contacts :' +LstOfExistingContact);
            if(!(LstOfExistingContact.isempty()))
            {
                list<contact> LstOfExistingContactsToUpdate = new list<contact>();
                for(Contact TempExistingContactObj : LstOfExistingContact)
                {
                    List<String> ExistingContactsEmailSplit = new list<string>();
                    ExistingContactsEmailSplit = TempExistingContactObj.Email.split('@');
                    String KeyToSearch = ExistingContactsEmailSplit[0]+'%';
                    KeyToSearch = KeyToSearch.toLowerCase();
                    System.debug('This is Keyto Search: '+KeyToSearch);
                    if(MapOfContactsNeedToProcess.containskey(KeyToSearch))
                    {
                        TempExistingContactObj.Ambassador__Ambassador_ID__c = MapOfContactsNeedToProcess.get(KeyToSearch)[0].Ambassador__Ambassador_ID__c;
                        TempExistingContactObj.External_Id__c = MapOfContactsNeedToProcess.get(KeyToSearch)[0].External_Id__c;
                        LstOfExistingContactsToUpdate.add(TempExistingContactObj);
                        System.debug('This is size :' +MapOfContactsNeedToProcess.get(KeyToSearch).size());
                      for(integer i=0;i<MapOfContactsNeedToProcess.get(KeyToSearch).size();i++)
                        {
                            
                          //  MapOfContactsNeedToProcess.get(KeyToSearch)[i].addError('Duplicate Found contact Id ='+TempExistingContactObj.id);
                            
                           MapOfContactsNeedToProcess.get(KeyToSearch)[i].Ambassador__Ambassador_ID__c = null;
                           MapOfContactsNeedToProcess.get(KeyToSearch)[i].External_Id__c= null; 
                            if (R!=null)   
                            MapOfContactsNeedToProcess.get(KeyToSearch)[i].RecordTypeId=R;
                           //if (A.size() > 0)
                           MapOfContactsNeedToProcess.get(KeyToSearch)[i].AccountId=System.label.sunrun_inc_id;
                      //   MapOfContactsNeedToProcess.get(KeyToSearch)[i].AccountId='001g000000Utzpp';
                            MapOfContactsNeedToProcess.get(KeyToSearch)[i].Contact_Type__c='Employee';
                            MapOfContactsNeedToProcess.get(KeyToSearch)[i].Mark_for_Delete__c=true;
                            
                        } 
                    }
                   
                        
                }
                If(!LstOfExistingContactsToUpdate.IsEmpty())
                update LstOfExistingContactsToUpdate;
                
            }
        }
    } 
  }
}