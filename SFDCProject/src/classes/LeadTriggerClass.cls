public class LeadTriggerClass{


    
    
    public static Id getConnectionId(String connectionName) {
    
        List<PartnerNetworkConnection> partnerNetConList =
           [Select id, AccountId from PartnerNetworkConnection where connectionStatus = 'Accepted' and connectionName = :connectionName];
        
        if ( partnerNetConList.size() != 0 ) {
            return partnerNetConList.get(0).Id;
        }
        
        return null;
    }
    public static void InsertSouthRecords(List<Lead> lst_SouthLeads){
        String ConnectionName = System.Label.SunRunConnectionName;
        Id networkId = getConnectionId(ConnectionName); 
        
        List<Lead> LocalLeads = new List<Lead>();  
        
        // only share records created in this org, do not add contacts received from another org. 
        for (Lead newLead : lst_SouthLeads) { 
            if (newLead.ConnectionReceivedId == null && newLead.Sunrun_South__c == true && newLead.Sunrun_South_Lead_ID__c == '1'&&newLead.LastUpdateDifference__c!=2) { 
                LocalLeads.add(newLead); 
            }         
        }       
                
        if (LocalLeads.size() > 0) { 
            List<PartnerNetworkRecordConnection> leadConnections =  new  List<PartnerNetworkRecordConnection>();             
            for (Lead newLead : LocalLeads) {                
                PartnerNetworkRecordConnection newConnection = 
                  new PartnerNetworkRecordConnection( 
                      ConnectionId = networkId, 
                      LocalRecordId = newLead.Id, 
                      SendClosedTasks = true, 
                      SendOpenTasks = true, 
                      SendEmails = true); 
                      
                leadConnections.add(newConnection); 
                 
            } 
  
            if (leadConnections.size() > 0 ) { 
                   database.insert(leadConnections); 
                   System.debug('------SS---'+ leadConnections);
            } 
        }        
    }

    private static Boolean isKeyFieldChanged(Lead newLead, Map<id, Lead> map_oldLead)
    {
        //Only add to set if a "key field" has been altered on the lead that is being deduped.
        if(Label.LeadDeDupeMethod == 'Contact')
        {
            if(newLead.LastName != map_oldLead.get(newLead.Id).LastName
               || newLead.Phone != map_oldLead.get(newLead.Id).Phone
               || newLead.Email != map_oldLead.get(newLead.Id).Email)
               {
                   return true;
               }
        }
        if(Label.LeadDeDupeMethod == 'Account' || System.Userinfo.getUserName() == 'SunRunTestRunner@testorg.com')
        {
            if(newLead.Street != map_oldLead.get(newLead.Id).Street
               || newLead.City != map_oldLead.get(newLead.Id).City
               || newLead.State != map_oldLead.get(newLead.Id).State
               || newLead.PostalCode != map_oldLead.get(newLead.Id).PostalCode
               || newLead.Country != map_oldLead.get(newLead.Id).Country
               || newLead.Zip_6__c != map_oldLead.get(newLead.Id).Zip_6__c)                      
               {
                   return true;
               }
        }               
        return false;
    }
    
    public static void trg_LeadAssignation(List<lead> lead_list) {

    Lead_Distribution_SouthNorth.assignLeads(lead_list);
    
    }
    public static void trg_lead_aft_ins_SP_IP_Partner(List<Lead> lst_Leads){
     if(Userinfo.getUserType()=='PowerPartner'&&system.isFuture() == false && system.isBatch() == false){
      Set<id> leadIds=new Set<id>();  
      for(lead l:lst_Leads){  
      if(!l.isconverted&&!checkRecursive.partnerPortalIds.contains(l.id)&&l.Install_Partner__c==null){
        leadIds.add(l.id);  
        checkRecursive.partnerPortalIds.add(l.id);
      }
      }
      if(!leadIds.isempty())
      SearchSalesInstallForPartners.SearchSalesInstallForPartners(leadIds);
      }
   }
     public static void trg_before_insert_company(List<Lead> lst_Leads){
    for(lead l: lst_Leads){
    if(l.company==null || l.company==''){
        if(l.firstname!=null){
            l.company=l.firstname+l.lastname;           
        }
        else{
            l.company=l.lastname;
        }
    }
    }
    }
    //Check to see if a lead exists with the same key
    private static Boolean isDuplicateLead(String key, Set<String> setExistingLeadKey)
    {    
        //  
        // Consider a more robust deduplication method.  
        // Consider Address, but not just a string comparison.
        // or string match on xxx chars of the address.
        // or email and last name match
        // if multiple, match on closest to address.
        // Also consider that perhaps we should allow more than one 
        // ral for the same email, but different home?
        // 06/11/2012: Use ONLY Email for now and check lead and contact
        // 06212012: USE ONLY Address via string compare and check on insert and update
        //           match on lead as well as converte lead (billing/shipping account address)
        // 06262012: Use whatever method is determined by the system label: LeadDeDupeMethod
        //
        if(setExistingLeadKey.Contains(key)) 
        {
           return true;
        }
        return false;
    }
    //Check to see if an oppty exists with the same key    
    private static Boolean isDuplicateOppty(String key, Set<String> setExistingOpptyKey)
    {    
        //  
        // Consider a more robust deduplication method.  
        // Consider Address, but not just a string comparison.
        // or string match on xxx chars of the address.
        // or email and last name match
        // if multiple, match on closest to address.
        // Also consider that perhaps we should allow more than one referral for the same email, but different home?
        // 06/11/2012: Use ONLY Email for now and check lead and contact
        // 06212012: USE ONLY Address via string compare and check on insert and update
        //           match on lead as well as converte lead (billing/shipping account address)
        // 06262012: Use whatever method is determined by the system label: LeadDeDupeMethod
        //
        if(setExistingOpptyKey.Contains(key)) 
        {
           return true;
        }
        return false;
    }
    

/****************************************************************************
Author  : Peter Alexander Mandy (pmandy@sunrunhome.com)
Date    : June 05, 2012
Description: This trigger handles the deduplication process for Lead Input data.
             It dedupes based on a system-level setting (Label: LeadDeDupeMethod) that determines whether the 
             process dedupes on Contact (LName and Email, or LName and Phone)
             or on Account (Street-City-State-Zip-Country string match, or zip+6)
             Looks for duplicate Lead or Oppty, matching on lead fields
             or on OpptyContactRole fields (Contact), or Oppty.Account Shipping/Billing Address Fields (Account)
*****************************************************************************/
public static void  trg_lead_before_insert(Map<Id, Lead> map_oldLead, Map<Id, Lead> map_newLead, List<Lead> lst_Leads, boolean isUpdate, boolean isInsert) {

      List<Lead> listNewChangedLeads = new List<Lead>();  
      List<Lead> Existinglead = New List<Lead>();// Added by MA
      list<Lead> LstOfExistingLeadsToUpdate = new list<Lead>(); // Added by MA
      list<Opportunity> LstOfOpportunityToUpdate = new list<Opportunity>(); //Added by MA
      set<id> OpportunityStageCheckSet = new set<id>();  // Added by MA
      Map<Set<String>,list<Lead>> ExistingLeadAndOldLeadKeyMap = new Map<Set<String>,list<Lead>>();// Added by MA
      Map<String,list<Lead>> ExtLeadKeyMap = new Map<String,list<Lead>>();
  //    Set<String> SearchKey = New Set<String>(); 
      String LeadKey;
    
    //For Comparisons (Contact)
    Set<String> setLeadEmails = new Set<String>();
    Set<String> setLeadPhones = new Set<String>();
    Set<String> setLeadLastNames = new Set<String>();
    //For Comparisons (Account)
    Set<String> setLeadStreet = new Set<String>();
    Set<String> setLeadCity = new Set<String>();
    Set<String> setLeadState = new Set<String>();
    Set<String> setLeadZip = new Set<String>();
    Set<String> setLeadCountry = new Set<String>();
    Set<String> setZipPlusSix = new Set<String>();
    Set<Id> setLeadIds = new Set<Id>();
    Integer size = 0;
    Integer counter = 0;
    //
    Set<Id> setSourceIds = new Set<Id>();
    // Keys are set for Existing Lead and for Oppty, to determine why the lead is duplicative
    Set<String> setExistingLeadKey = new Set<String>(); 
    Set<String> setExistingOpptyKey = new Set<String>(); 
    
    for(Lead newlead:lst_Leads)
    {
        // If new or if updating a lead that is not auto-unqualified, populate sets for comparison.
     /*   if(newlead.LastName != '' && newlead.LastName != null &&
          ((isUpdate && !newlead.Auto_Unqualified__c && isKeyFieldChanged(newlead, map_oldLead))
            || Trigger.isInsert)) */
        if(newlead.Lead_Division_Custom__c==null||(isupdate&&map_oldLead.get(newlead.id).Division!=newlead.Division)){
            newlead.Lead_Division_Custom__c=newlead.Division;
        }    
        if( (isInsert && newlead.LastName != '' && newlead.LastName != null) ||    
            (isUpdate && !newlead.Auto_Unqualified__c && isKeyFieldChanged(newlead, map_oldLead))    
          )
        {           
           //System.debug('Adding Lead to listNewChangedLeads');
           listNewChangedLeads.add(newlead);
           setLeadEmails.add(newlead.email); 
           setLeadPhones.add(newlead.phone);
           setLeadLastNames.add(newlead.lastname);
           setLeadStreet.add(newLead.Street);
           setLeadCity.add(newLead.City);
           setLeadState.add(newLead.State);
           setLeadZip.add(newLead.PostalCode);
           setLeadCountry.add(newLead.Country);
           setZipPlusSix.add(newLead.Zip_6__c);
           setLeadIds.add(newLead.Id);
           System.debug('This is NewLeadId: '+ newLead.Id); 
           System.debug('This is Set Lead Ids:'+setLeadIds); 
           System.debug('This is Set Lead Emails:'+setLeadEmails); 
           System.debug('This is Set Lead Phone :'+setLeadPhones);  
        }
        
        //Verify Contact number
        if(newlead.Prospect_Id__c == null || newlead.Prospect_Id__c == ''){
            size++;
        } 
        Notes__c noteobj = new Notes__c();
        
        if(Trigger.isInsert && newLead.State != null && newLead.State != ''){
            newLead.State__c = newLead.State;
        }
        
        if(isUpdate && newLead.State != newLead.State__c){
          newLead.State__c = newLead.State;
        }
        
        if(isUpdate || Trigger.isInsert){

            if(newLead.street == null){
                newLead.street = '';
            }
            if(newLead.City == null){
                newLead.City = '';
            }
            if(newLead.State == null){
                newLead.State = '';
            }
            if(newLead.PostalCode == null){
                newLead.PostalCode = '';
            }
            
            if(newLead.street != '' || newLead.City != '' || newLead.State != '' || newLead.PostalCode != '' ){
                system.debug('Address for Search:' + newLead.street + ' ' + newLead.City + ' ' + newLead.State + ' ' + newLead.PostalCode + ' ' + newLead.Country);
               newLead.Address_for_Search__c = newLead.street + ' ' + newLead.City + ' ' + newLead.State + ' ' + newLead.PostalCode + ' ' + newLead.Country;
            }else if(newLead.street == '' && newLead.City == '' && newLead.State == '' && newLead.PostalCode == '' ){
                system.debug('Address for Search:' + newLead.street + ' ' + newLead.City + ' ' + newLead.State + ' ' + newLead.PostalCode + ' ' + newLead.Country);
               newLead.Address_for_Search__c = '';
                newlead.CDYNE_Status__c = '';
            }
            
            /* if(isUpdate && newlead.Notes__c != map_oldLead.get(newlead.id).Notes__c){
                noteobj.Notes__c = newLead.Notes__c;
                noteobj.Lead__c = newLead.Id;
                noteobj.Notes_Added_By__c = getwhichOrg();
                insert noteobj;
            }
            if(isUpdate && newlead.Partner_Notes__c != map_oldLead.get(newlead.id).Partner_Notes__c){
                noteobj.Notes__c = newLead.Partner_Notes__c;
                noteobj.Lead__c = newLead.Id;
                noteobj.Notes_Added_By__c = getwhichOrg();
                insert noteobj;
            }*/
         }
         
    }

    List<String> randomNumners = null;
    if(size > 0){
        randomNumners = LeadUtil.getUniqueProspectNumbers(size);
    }

    // System-level De-dupe method is set to Account
    if((Label.LeadDeDupeMethod == 'Account' && listNewChangedLeads.size() > 0) || System.Userinfo.getUserName() == 'SunRunTestRunner@testorg.com')
    {
    //Check Leads for exact address match
    for(Lead existingLeads:[select id, Email, LastName, Referred_by__c, Phone,
                                   Street, City, State, PostalCode, Country,
                                   Zip_6__c  
                             from Lead 
                             where Id not in :setLeadIds
                               and Lead_Status__c != 'Converted'
                               and Why_Unqualified__c != :Label.Lead_Why_Unqualified_DuplicateLeadFound 
                               and Why_Unqualified__c != :Label.Lead_Why_Unqualified_DuplicateOpptyFound
                               and Why_Unqualified__c != :Label.Lead_Why_Unqualified_SalesDeterminedDuplicate
                               and (
                                   (Street in :setLeadStreet
                               and City in :setLeadCity
                               and State in :setLeadState
                               and PostalCode in :setLeadZip
                               and Country in :setLeadCountry)
                                   OR Zip_6__c in :setZipPlusSix)])
    {
        setExistingLeadKey.add(existingLeads.Street + existingLeads.City + existingLeads.State + existingLeads.PostalCode + existingLeads.Country);    
    }
    // Get all Oppty.Account data where the address or zip+6 matches and add values to set of keys
    for(Opportunity o:[SELECT Account.BillingCity, Account.BillingState, Account.BillingStreet, Account.BillingPostalCode, Account.BillingCountry, Account.ShippingCity, Account.ShippingState, Account.ShippingStreet, Account.ShippingPostalCode, Account.ShippingCountry,
                          Account.Zip_6__c
                          FROM Opportunity
                          WHERE (
                               (Account.BillingCity in :setLeadCity
                            AND Account.BillingState in :setLeadState
                            AND Account.BillingStreet in :setLeadStreet
                            AND Account.BillingPostalCode in :setLeadZip
                            AND Account.BillingCountry in :setLeadCountry
                                )
                            OR(    Account.ShippingCity in :setLeadCity
                               AND Account.ShippingState in :setLeadState
                               AND Account.ShippingStreet in :setLeadStreet
                               AND Account.ShippingPostalCode in :setLeadZip
                               AND Account.ShippingCountry in :setLeadCountry)
                               )
                               OR Account.Zip_6__c in :setZipPlusSix])
    {
       if(setLeadCity.Contains(o.Account.BillingCity) &&
          setLeadState.Contains(o.Account.BillingState) &&
          setLeadStreet.Contains(o.Account.BillingStreet) &&
          setLeadZip.Contains(o.Account.BillingPostalCode) &&
          setLeadCountry.Contains(o.Account.BillingCountry))                            
       {
          setExistingOpptyKey.add(o.Account.BillingStreet + o.Account.BillingCity + o.Account.BillingState + o.Account.BillingPostalCode + o.Account.BillingCountry);   
       }
    //
       if(setLeadCity.Contains(o.Account.ShippingCity) &&
          setLeadState.Contains(o.Account.ShippingState) &&
          setLeadStreet.Contains(o.Account.ShippingStreet) &&
          setLeadZip.Contains(o.Account.ShippingPostalCode) &&
          setLeadCountry.Contains(o.Account.ShippingCountry))                            
       {
          setExistingOpptyKey.add(o.Account.ShippingStreet + o.Account.ShippingCity + o.Account.ShippingState + o.Account.ShippingPostalCode + o.Account.ShippingCountry);  
       }
       if(setZipPlusSix.Contains(o.Account.Zip_6__c))
       {
          setExistingOpptyKey.add(o.Account.Zip_6__c);
       }
    
    }
    }
    //
    // System-level De-dupe method is set to Contact
    //
    if(Label.LeadDeDupeMethod == 'Contact' && listNewChangedLeads.size() > 0)
    {
        for(Lead existingLeads:[select id, Email, LastName, Referred_by__c, Phone,
                                   Street, City, State, PostalCode, Country,Isconverted,ConvertedOpportunityId,
                                   Zip_6__c, Channel__c, Lead_Type_Last__c,
                                   Lead_Type__c, Lead_Source_Last__c, Custom_Lead_Source__c,Lead_Status__c,
                                   Campaign_Last__c, Campaign__c, Keywords_Last__c,
                                   Keywords__c, Content_Last__c, Content__c, 
                                   Technology_Last__c, Technology__c 
                              from Lead 
                             where Id not in :setLeadIds
                               and Lead_Status__c != 'Converted'
                               and Why_Unqualified__c != :Label.Lead_Why_Unqualified_DuplicateLeadFound 
                               and Why_Unqualified__c != :Label.Lead_Why_Unqualified_DuplicateOpptyFound
                               and Why_Unqualified__c != :Label.Lead_Why_Unqualified_SalesDeterminedDuplicate
                               and lastname in :setLeadlastNames
                               and (email in :setLeadEmails or phone in :setLeadPhones) and createddate>n_days_ago:30 order by createddate])
        {
             // setExistingLeadKey = new set<String>();
            if(existingLeads.email != null && existingLeads.email != '')
            {
               setExistingLeadKey.add(existingLeads.email + existingLeads.lastname);
               LeadKey = (existingLeads.email + existingLeads.lastname); 
            }
            if(existingLeads.phone != null && existingLeads.phone != '')
            {
               setExistingLeadKey.add(existingLeads.phone + existingLeads.lastname);
               LeadKey = (existingLeads.phone + existingLeads.lastname); 
            }
             Existinglead.add(existingLeads);
             ExtLeadKeyMap.put(LeadKey,Existinglead);
          // ExistingLeadAndOldLeadKeyMap.put(setExistingLeadKey,Existinglead);
          System.debug('This is Existing Lead:'+ Existinglead);  
          System.debug('=== This is map1: ' + ExistingLeadAndOldLeadKeyMap);  
          System.debug('=== all keys in the map1: ' + ExistingLeadAndOldLeadKeyMap.keySet());  
          System.debug('=== all values in the map2: ' + ExistingLeadAndOldLeadKeyMap.values()); 
        }
        //Also check contact if it exists in an Oppty Contact Role
        for(OpportunityContactRole ocr:[select id, Contact.email, Contact.phone, Contact.LastName 
                     from OpportunityContactRole
                    where Contact.LastName in :setLeadLastNames
                      and (Contact.email in :setLeadEmails or Contact.phone in :setLeadPhones)])
        {
          if(ocr.Contact.email != null && ocr.Contact.email != '')
          {
             setExistingOpptyKey.add(ocr.Contact.email + ocr.Contact.lastname);
          }
          if(ocr.Contact.phone != null && ocr.Contact.phone != '')
          {
             setExistingOpptyKey.add(ocr.Contact.phone + ocr.Contact.lastname);
          }
        }
    }
    
    if(Label.LeadDeDupeMethod == 'Contact' && listNewChangedLeads.size() > 0 && Label.Isconverted=='True')
    {
         For(Lead existingLeads :[select id, Email, LastName, Referred_by__c, Phone,
                                   Street, City, State, PostalCode, Country,Isconverted,ConvertedOpportunityId,
                                   Zip_6__c, Channel__c, Lead_Type_Last__c,Campaign_Last__c,
                                   Lead_Type__c, Lead_Source_Last__c, Custom_Lead_Source__c,Lead_Status__c,
                                   Campaign__c, Keywords_Last__c,
                                   Keywords__c, Content_Last__c, Content__c, 
                                   Technology_Last__c, Technology__c 
                              from Lead 
                             where Id not in :setLeadIds
                               and Lead_Status__c = 'Converted' 
                               and lastname in :setLeadlastNames
                               and (email in :setLeadEmails or phone in :setLeadPhones) and createddate>n_days_ago:30 order by createddate])
                   {
                       // setExistingLeadKey = new set<String>();
                        if(existingLeads.email != null && existingLeads.email != '')
                        {
                            setExistingLeadKey.add(existingLeads.email + existingLeads.lastname);
                            LeadKey = (existingLeads.email + existingLeads.lastname);
                        }
                        if(existingLeads.phone != null && existingLeads.phone != '')
                        {
                           setExistingLeadKey.add(existingLeads.phone + existingLeads.lastname);
                           LeadKey = (existingLeads.phone + existingLeads.lastname); 
                        }
                Existinglead.add(existingLeads);   
                ExtLeadKeyMap.put(LeadKey,Existinglead);       
             // ExistingLeadAndOldLeadKeyMap.put(setExistingLeadKey,Existinglead);
        System.debug('===  map Isconverted: ' + ExistingLeadAndOldLeadKeyMap);                 
        System.debug('=== all keys in the map Isconverted: ' + ExistingLeadAndOldLeadKeyMap.keySet());  
        System.debug('=== all values in the map Isconverted: ' + ExistingLeadAndOldLeadKeyMap.values()); 
        } 
     }
    
    
    for(Lead newlead: lst_Leads)
    {
         System.debug('This is NewLeads : '+ newLead); 
                String SearchKey;
            //    SearchKey = New Set<String>();
                     if(newlead.email != null && newlead.email != '')
                          {
                            // SearchKey.add(newlead.email + newlead.lastname);
                               SearchKey = (newlead.email + newlead.lastname);
                          }
                     if(newlead.phone != null && newlead.phone != '')
                          {
                            // SearchKey.add(newlead.phone + newlead.lastname);
                               SearchKey = (newlead.phone + newlead.lastname);
                          }
                  System.debug('This is Search Key'+ SearchKey); 
        
         If(
           ((newlead.Channel__c!=Null )||
            (newlead.Lead_Type__c!=Null)||
            (newlead.Custom_Lead_Source__c!=Null )||
            (newlead.Campaign__c!=Null )||
            (newlead.Keywords__c!=Null )||
            (newlead.Content__c!=Null ) || 
            (newlead.Technology__c!=Null )
           ) &&
           ((newlead.Channel_Last__c==Null || newlead.Channel_Last__c=='')&&
            (newlead.Lead_Type_Last__c==Null || newlead.Lead_Type_Last__c=='' )&&
            (newlead.Lead_Source_Last__c==Null || newlead.Lead_Source_Last__c=='')&&
            (newlead.Campaign_Last__c==Null || newlead.Campaign_Last__c=='')&&
            (newlead.Keywords_Last__c==Null || newlead.Keywords_Last__c=='' )&&
            (newlead.Content_Last__c==Null || newlead.Content_Last__c=='' )&&
            (newlead.Technology_Last__c==Null || newlead.Technology_Last__c=='')
           ) 
          )
            {
              newlead.Channel_Last__c=newlead.Channel__c;
              newlead.Lead_Type_Last__c=newlead.Lead_Type__c;
              newlead.Lead_Source_Last__c=newlead.Custom_Lead_Source__c;
              newlead.Campaign_Last__c=newlead.Campaign__c;
              newlead.Keywords_Last__c=newlead.Keywords__c;
              newlead.Content_Last__c=newlead.Content__c;
              newlead.Technology_Last__c=newlead.Technology__c;  
              System.debug('This is Channel first :'+newlead.Channel__c);  
              System.debug('This is Channel lastt :'+newlead.Channel_Last__c);   
               
            } 
        
        else if
          (
           ((newlead.Invoca_Channel_new__c!=Null )||
            (newlead.Invoca_Lead_Type_new__c!=Null )||
            (newlead.Invoca_Lead_Source_new__c!=Null )         
            
           ) &&
           ((newlead.Channel_Last__c==Null || newlead.Channel_Last__c=='')&&
            (newlead.Lead_Type_Last__c==Null || newlead.Lead_Type_Last__c=='' )&&
            (newlead.Lead_Source_Last__c==Null || newlead.Lead_Source_Last__c=='')            
           ) 
         )  
            {
              system.debug('this is Invoca Channel: '+ newlead.Invoca_Channel_new__c);  
              newlead.Channel_Last__c=newlead.Invoca_Channel_new__c;
              newlead.Lead_Type_Last__c=newlead.Invoca_Lead_Type_new__c;
              newlead.Lead_Source_Last__c=newlead.Invoca_Lead_Source_new__c;              
               
            }
            
           If(
           ((newlead.Channel__c==Null ||newlead.Channel__c=='' )&&
            (newlead.Lead_Type__c==Null || newlead.Lead_Type__c=='' )&& 
            (newlead.Custom_Lead_Source__c==Null ||newlead.Custom_Lead_Source__c=='')&&
            (newlead.Campaign__c==Null || newlead.Campaign__c=='' )&& 
            (newlead.Keywords__c==Null|| newlead.Keywords__c=='')&&
            (newlead.Content__c==Null || newlead.Content__c=='' )&&
            (newlead.Technology__c==Null || newlead.Technology__c=='' )
           ) &&
           ((newlead.Channel_Last__c!=Null )||
            (newlead.Lead_Type_Last__c!=Null )||
            (newlead.Lead_Source_Last__c!=Null )||
            (newlead.Campaign_Last__c!=Null )||
            (newlead.Keywords_Last__c!=Null )||
            (newlead.Content_Last__c!=Null )||
            (newlead.Technology_Last__c!=Null )
           ) 
          )
            {
              newlead.Channel__c=newlead.Channel_Last__c;
              newlead.Lead_Type__c=newlead.Lead_Type_Last__c;
              newlead.Custom_Lead_Source__c=newlead.Lead_Source_Last__c;
              newlead.Campaign__c=newlead.Campaign_Last__c;
              newlead.Keywords__c=newlead.Keywords_Last__c;
              newlead.Content__c=newlead.Content_Last__c;
              newlead.Technology__c=newlead.Technology_Last__c;
              System.debug('THIS'+newlead.Channel_Last__c);
              System.debug('THIS2'+newlead.Channel__c);
            } 
            
        
       if(!newlead.Auto_Unqualified__c || Trigger.isInsert)
        {
            if(   ((Label.LeadDeDupeMethod == 'Account' || System.Userinfo.getUserName() == 'SunRunTestRunner@testorg.com') && isDuplicateLead(newLead.Street + newLead.City + newLead.State + newLead.PostalCode + newLead.Country, setExistingLeadKey))
               || ((Label.LeadDeDupeMethod == 'Account' || System.Userinfo.getUserName() == 'SunRunTestRunner@testorg.com') && isDuplicateLead(newLead.Zip_6__c, setExistingLeadKey))
               || (Label.LeadDeDupeMethod == 'Contact' && isDuplicateLead(newLead.Email + newLead.LastName, setExistingLeadKey))
               || (Label.LeadDeDupeMethod == 'Contact' && isDuplicateLead(newLead.Phone + newLead.LastName, setExistingLeadKey))
              )
                 {  
                   If(!ExtLeadKeyMap.isEmpty() && ExtLeadKeyMap.containsKey(SearchKey))
                   {     
                    for(Lead existingLeads : ExtLeadKeyMap.get(SearchKey))
                //  for(Lead existingLeads : ExistingLeadAndOldLeadKeyMap.get(setExistingLeadKey))    
                         { 
                            
                             System.debug('This Contains ExistingLeads'+  existingLeads);
                             if(existingLeads.IsConverted == False && existingLeads.Lead_Status__c != 'Unqualified') 
                             { 
                                System.debug('This is for IsConverted: ' + existingLeads.IsConverted );
                                // existingLeads.Custom_Channel_Last__c=newLead.Channel__c; 
                                   existingLeads.Channel_Last__c=newLead.Channel__c;
                                existingLeads.Lead_Type_Last__c=newLead.Lead_Type__c;
                                existingLeads.Lead_Source_Last__c=newLead.Custom_Lead_Source__c;
                                existingLeads.Campaign_Last__c=newLead.Campaign__c;
                                existingLeads.Keywords_Last__c=newLead.Keywords__c;
                                existingLeads.Content_Last__c=newLead.Content__c;
                                existingLeads.Technology_Last__c=newLead.Technology__c;  
                                System.debug('This is for Ext Lead: ' + existingLeads.Channel_Last__c );
                                System.debug('This is for New Lead: ' + newLead.Channel_Last__c );
                                existingLeads.Lead_Type_Last__c=newLead.Lead_Type__c; 
                                LstOfExistingLeadsToUpdate.add(existingLeads); 
                            } 
                            
                        }
                     }  
                 }
                            if(   ((Label.LeadDeDupeMethod == 'Account' || System.Userinfo.getUserName() == 'SunRunTestRunner@testorg.com') && isDuplicateOppty(newLead.Street + newLead.City + newLead.State + newLead.PostalCode + newLead.Country, setExistingOpptyKey))
                                     || ((Label.LeadDeDupeMethod == 'Account' || System.Userinfo.getUserName() == 'SunRunTestRunner@testorg.com') && isDuplicateOppty(newLead.Zip_6__c, setExistingOpptyKey))
                                     || (Label.LeadDeDupeMethod == 'Contact' && Label.Isconverted=='True' && isDuplicateOppty(newLead.Email + newLead.LastName, setExistingOpptyKey))
                                     || (Label.LeadDeDupeMethod == 'Contact' && Label.Isconverted=='True' && isDuplicateOppty(newLead.Phone + newLead.LastName, setExistingOpptyKey))
                              ) 
                                  { 
                                    If(!ExtLeadKeyMap.isEmpty() && ExtLeadKeyMap.containsKey(SearchKey))
                                    {     
                                        for(Lead existingLeads : ExtLeadKeyMap.get(SearchKey))
                                     { 
                                       
                                       System.debug('This Contains ExistingLeads'+  existingLeads);
                                       
                                         if(existingLeads.ConvertedOpportunityId != null) 
                             
                                         {
                                               System.debug('This is convertedOpptyId'+ existingLeads.ConvertedOpportunityId );
                                               OpportunityStageCheckSet.add(existingLeads.ConvertedOpportunityId);
                                               Opportunity existingOppty = new Opportunity(id=existingLeads.ConvertedOpportunityId);
                                               System.debug('This is Existing oppty: '+ existingOppty);
                                               existingOppty.Channel_Last__c=newLead.Channel__c;
                                               System.debug('This is Existing oppty Channel Last: '+ existingOppty.Channel_Last__c);
                                               System.debug('This is New Lead Channel : '+ newLead.Channel__c);
                                               existingOppty.Lead_Type_Last__c=newLead.Lead_Type__c;
                                               existingOppty.Lead_Source_Last__c=newLead.Custom_Lead_Source__c;
                                               existingOppty.Campaign_Last__c=newLead.Campaign__c;
                                               existingOppty.Keywords_Last__c=newLead.Keywords__c;
                                               existingOppty.Content_Last__c=newLead.Content__c;
                                               existingOppty.Technology_Last__c=newLead.Technology__c;    
                                          //   existingOppty.Lead_Type_Last__c=newLead.Lead_Type__c;
                                         //    existingOppty.Lead_Source_Last__c=newLead.Custom_Lead_Source__c;
                                               LstOfOpportunityToUpdate.add(existingOppty);
                                          }
                            
                                       }
                                    }   
                                   }
                   } 
        if((counter < size) && (newlead.Prospect_Id__c == null || newlead.Prospect_Id__c == '')){
            newlead.Prospect_Id__c = randomNumners[counter];
            counter++;
        }
        
        // Set to non-duplicate if duplicate, then recheck to determine if it is STILL a duplicate
        // This allows us to set a lead as non-duplicate, if attributes have change to determine it is no longer a dupe.
        if(   isUpdate 
           && isKeyFieldChanged(newLead, map_oldLead)
           && newLead.Lead_Status__c  == Label.Lead_Status_Duplicate 
           && (newLead.Why_Unqualified__c == Label.Lead_Why_Unqualified_DuplicateLeadFound
               || newLead.Why_Unqualified__c == Label.Lead_Why_Unqualified_DuplicateOpptyFound)
           &&
           (((Label.LeadDeDupeMethod == 'Account' || System.Userinfo.getUserName() == 'SunRunTestRunner@testorg.com')
             && !isDuplicateLead(newLead.Street + newLead.City + newLead.State + newLead.PostalCode + newLead.Country, setExistingLeadKey)
             && !isDuplicateLead(newLead.Zip_6__c, setExistingLeadKey)
             && !isDuplicateOppty(newLead.Street + newLead.City + newLead.State + newLead.PostalCode + newLead.Country, setExistingLeadKey)
             && !isDuplicateOppty(newLead.Zip_6__c, setExistingLeadKey)
             )
             || ((Label.LeadDeDupeMethod == 'Contact' 
                  && !isDuplicateLead(newLead.Email + newLead.LastName, setExistingLeadKey)
                  && !isDuplicateLead(newLead.Phone + newLead.LastName, setExistingLeadKey)
                  && !isDuplicateOppty(newLead.Email + newLead.LastName, setExistingLeadKey)
                  && !isDuplicateOppty(newLead.Phone + newLead.LastName, setExistingLeadKey)))
           )
        )                    
        {
           newLead.Lead_Status__c = 'Open';
           newLead.Why_Unqualified__c = '';  
           newLead.reason__c = '';
        }
        if(!newlead.Auto_Unqualified__c || Trigger.isInsert)
        {
            if(   ((Label.LeadDeDupeMethod == 'Account' || System.Userinfo.getUserName() == 'SunRunTestRunner@testorg.com') && isDuplicateLead(newLead.Street + newLead.City + newLead.State + newLead.PostalCode + newLead.Country, setExistingLeadKey))
               || ((Label.LeadDeDupeMethod == 'Account' || System.Userinfo.getUserName() == 'SunRunTestRunner@testorg.com') && isDuplicateLead(newLead.Zip_6__c, setExistingLeadKey))
               || (Label.LeadDeDupeMethod == 'Contact' && isDuplicateLead(newLead.Email + newLead.LastName, setExistingLeadKey))
               || (Label.LeadDeDupeMethod == 'Contact' && isDuplicateLead(newLead.Phone + newLead.LastName, setExistingLeadKey))
              )
            {
              newlead.Lead_Status__c = Label.Lead_Status_Duplicate;
              newlead.Why_Unqualified__c = Label.Lead_Why_Unqualified_DuplicateLeadFound;
              newLead.reason__c = 'Duplicate Lead Found';  
            }
            /*if(   ((Label.LeadDeDupeMethod == 'Account' || System.Userinfo.getUserName() == 'SunRunTestRunner@testorg.com') && isDuplicateOppty(newLead.Street + newLead.City + newLead.State + newLead.PostalCode + newLead.Country, setExistingLeadKey))
               || ((Label.LeadDeDupeMethod == 'Account' || System.Userinfo.getUserName() == 'SunRunTestRunner@testorg.com') && isDuplicateOppty(newLead.Zip_6__c, setExistingLeadKey))
               || (Label.LeadDeDupeMethod == 'Contact' && isDuplicateOppty(newLead.Email + newLead.LastName, setExistingLeadKey))
               || (Label.LeadDeDupeMethod == 'Contact' && isDuplicateOppty(newLead.Phone + newLead.LastName, setExistingLeadKey))
              )*/
            if(   ((Label.LeadDeDupeMethod == 'Account' || System.Userinfo.getUserName() == 'SunRunTestRunner@testorg.com') && isDuplicateOppty(newLead.Street + newLead.City + newLead.State + newLead.PostalCode + newLead.Country, setExistingOpptyKey))
               || ((Label.LeadDeDupeMethod == 'Account' || System.Userinfo.getUserName() == 'SunRunTestRunner@testorg.com') && isDuplicateOppty(newLead.Zip_6__c, setExistingOpptyKey))
               || (Label.LeadDeDupeMethod == 'Contact' && isDuplicateOppty(newLead.Email + newLead.LastName, setExistingOpptyKey))
               || (Label.LeadDeDupeMethod == 'Contact' && isDuplicateOppty(newLead.Phone + newLead.LastName, setExistingOpptyKey))
              ) 
            {
               newlead.Lead_Status__c = Label.Lead_Status_Duplicate;
               newlead.Why_Unqualified__c = Label.Lead_Why_Unqualified_DuplicateOpptyFound;
               newLead.reason__c = 'Duplicate Opportunity Found';            
            }
        }  
       if(!(LstOfExistingLeadsToUpdate.isempty())) 
        update LstOfExistingLeadsToUpdate; 
    System.debug('This is list of ext leads to upd :'+ LstOfExistingLeadsToUpdate);
   // if(!(LstOfOpportunityToUpdate.isempty())) 
        // update LstOfOpportunityToUpdate;   
        
    }
     if(!(LstOfOpportunityToUpdate.isempty())) 
         { 
                System.debug('This is list of Opp to upd: ' + LstOfOpportunityToUpdate);
                    list<Opportunity> FinalOppLstToUpdate = new list<Opportunity>(); 
                    map<id,opportunity> OppMapToCheckStage = new Map<id,opportunity>([select id,name,stagename,IsDeleted from Opportunity where id in :OpportunityStageCheckSet and StageName in ('7. Closed Won','9. Closed Lost') and IsDeleted=False]); 
                System.debug('This is FinalOppLstToUpdate: ' + FinalOppLstToUpdate);
                System.debug('This is OppMapToCheckStage: ' + OppMapToCheckStage);
            if(OppMapToCheckStage.isempty()) 
            {
                 System.debug('This is Check stage' + OppMapToCheckStage.isempty());
                        update LstOfOpportunityToUpdate; 
            }    
                    else 
                    { 
                        for(Opportunity TempOppObj : LstOfOpportunityToUpdate) 
                        { 
                            if(!(OppMapToCheckStage.containskey(TempOppObj.id))) 
                                FinalOppLstToUpdate.add(TempOppObj); 
                        } 
                        if(!(FinalOppLstToUpdate.isempty())) 
                            update FinalOppLstToUpdate; 
                        System.debug('This is FinalOppLstToUpdate: ' + FinalOppLstToUpdate);
                         
                    } 
                }  
    
    
    Contact contobj = new contact();
    if(checkRecursive.runContactOnce()){
        contObj=PRMContactUtil.getLoginUserAccountAndContact();
    }
    Account accObj = new Account();
    Set<id> salesInstallLeadGenids=new set<id>(); 
    if(contobj != null){
        //accObj = [select id, name from Account where id =: contobj.accountId];
        if(contobj.Account != null){
            for(Lead newlead:lst_Leads){
                if(isInsert){
                    if(newlead.Lead_Gen_Partner__c ==null){  
                    newlead.Lead_Gen_Partner__c = contobj.Account.Id;
                    salesInstallLeadGenids.add(newlead.Lead_Gen_Partner__c);
                    }
                    if(newlead.Sales_Partner__c!=null)
                    salesInstallLeadGenids.add(newlead.Sales_Partner__c);
                    if(newlead.Install_Partner__c!=null)
                    salesInstallLeadGenids.add(newlead.Install_Partner__c);
                }
            }
        }  
    }
    /*
    for(lead newlead:lst_Leads){

        if(trigger.isInsert || (isUpdate && newlead.Offer_Promo_Code__c != map_oldLead.get(newlead.Id).Offer_Promo_Code__c)){
          List<Promotion__c> promoObjList = [Select id, Promotion_Code__c, Name from Promotion__c where Promotion_Code__c =: newlead.Offer_Promo_Code__c limit 1];

          if(promoObjList != null && promoObjList.size() > 0){
            newlead.Offer_Promo_Name__c = promoObjList[0].id;
          }
          
          if(isUpdate && newlead.Offer_Promo_Code__c == null){
            newlead.Offer_Promo_Name__c = null;
          } 
        }
    }
    */
     //Code Change to bulkify ---- find Promotion based on Offer(2/18/2014)
    Set<String> promoSet=new Set<String>();
    for(lead newlead:lst_Leads)
    {
      if(newlead.Offer_Promo_Code__c!=null && newlead.Offer_Promo_Code__c!='')
      {    
       promoSet.add(newlead.Offer_Promo_Code__c);
      }
    }
    Map<String,id> promoNamePromotionMap=new Map<String,id>();
    if(!promoSet.isempty()){
    for(Promotion__c p:[Select id, Promotion_Code__c, Name from Promotion__c where Promotion_Code__c in:promoSet and Promotion_Type__c = 'Offer']){
    promoNamePromotionMap.put(p.Promotion_Code__c,p.id);
    }
    }
    for(lead newlead:lst_Leads){
        if(isInsert || (isupdate && newlead.Offer_Promo_Code__c != map_oldLead.get(newlead.Id).Offer_Promo_Code__c)){
        if(promoNamePromotionMap.containsKey(newLead.Offer_Promo_Code__c))
        newlead.Offer_Promo_Name__c = promoNamePromotionMap.get(newLead.Offer_Promo_Code__c);
        //System.debug('Entering1 Offer');
        }
        if(isUpdate && newlead.Offer_Promo_Code__c == null){
            newlead.Offer_Promo_Name__c = null;
            //System.debug('Entering2 Offer');
          } 
    }
    
     Map<String,partner_contract__c> PCMap=new Map<String,partner_contract__c>();   
         if(!salesInstallLeadGenids.isempty()){   
         for(partner_contract__c pc:[select id, name, contract_type__c, effective_date__c, Contract_Status__c, expiration_Date__c , Account__c,Account__r.Site from Partner_contract__c where  Account__c in:salesInstallLeadGenids and Contract_Status__c = 'Active' and expiration_date__c > today and Contract_Type__c in ('Full Service Contract','Installation Contract','Sales Contract') ]){         
         PCMap.put(pc.account__c+pc.Contract_Type__c,pc);
         }
     } 
     for(Lead newlead:lst_Leads){
      if(Trigger.isInsert){
        
        newlead.LC_Salutation__c = newlead.Salutation;
        newlead.LC_FirstName__c = newlead.FirstName;
        newlead.LC_LastName__c = newlead.LastName;
        newlead.LC_AccountName__c = newlead.Partner_for_Lead_Passing__c;
        newlead.LC_PhoneNumber__c  = newlead.phone;
        newlead.LC_Email__c = newlead.email;
        newlead.LC_Street__c = newlead.street;
        newlead.LC_City__c = newlead.city;
        newlead.LC_State__c = newlead.state;
        newlead.LC_ZipCode__c = newlead.postalcode;
        newlead.LC_Country__c = newlead.country;
       
       if(contobj != null){        
        Id userId = UserInfo.getUserId();        
        //Install Partner       
        if(PCMap.containsKey(newlead.Install_Partner__c+'Full Service Contract')){
            newlead.EPCPartnerName__c = PCMap.get(newlead.Install_Partner__c+'Full Service Contract').Account__c;
            newlead.EPCExecutionDate__c = PCMap.get(newlead.Install_Partner__c+'Full Service Contract').Effective_Date__c;
            newlead.InstallationOffice__c = PCMap.get(newlead.Install_Partner__c+'Full Service Contract').Account__r.Site;
            newlead.CorporatePartner__c = null;
        }else {            
            if(PCMap.containsKey(newlead.Install_Partner__c+'Installation Contract')){
                newlead.EPCPartnerName__c = PCMap.get(newlead.Install_Partner__c+'Installation Contract').Account__c;
                newlead.EPCExecutionDate__c = PCMap.get(newlead.Install_Partner__c+'Installation Contract').Effective_Date__c;
                newlead.InstallationOffice__c = PCMap.get(newlead.Install_Partner__c+'Installation Contract').Account__r.Site;
                newlead.CorporatePartner__c = null;
            }
        }
        
        //Lead-Gen Partner
        if(PCMap.containsKey(newlead.Lead_Gen_Partner__c +'Full Service Contract')){
            newlead.LeadOrganizationName__c = PCMap.get(newlead.Lead_Gen_Partner__c +'Full Service Contract').Account__c ;
            newlead.LeadOrganizationOffice__c = PCMap.get(newlead.Lead_Gen_Partner__c +'Full Service Contract').Account__r.Site;
            newlead.CorporatePartner__c = null;
        }
        
        //Sales Partner
        if(PCMap.containsKey(newlead.Sales_Partner__c +'Full Service Contract')){
             if(newlead.SalesRep__c==null)  {
             newlead.SalesCellPhone__c = contobj.phone;
             newlead.Sales_Rep_Email__c = contobj.email;
             newlead.SalesRep__c = userId;
             }
             newlead.SalesOrganizationName__c = PCMap.get(newlead.Sales_Partner__c +'Full Service Contract').Account__c ;
             newlead.SalesOrgContractExecutionDate__c = PCMap.get(newlead.Sales_Partner__c +'Full Service Contract').Effective_Date__c;             
             newlead.CorporatePartner__c = null;
        }else {            
            if(PCMap.containsKey(newlead.Sales_Partner__c +'Sales Contract')){
                if(newlead.SalesRep__c==null)   {
                 newlead.SalesCellPhone__c = contobj.phone;
                 newlead.Sales_Rep_Email__c = contobj.email;
                 newlead.SalesRep__c = userId;
                }
                 newlead.SalesOrganizationName__c = PCMap.get(newlead.Sales_Partner__c +'Sales Contract').Account__c ;
                 newlead.SalesOrgContractExecutionDate__c = PCMap.get(newlead.Sales_Partner__c +'Sales Contract').Effective_Date__c;                 
                 newlead.CorporatePartner__c = null;
            }
        }
      }
      /*       
      if(contobj != null){
        List<Partner_contract__c> PCObjlist = new List<Partner_contract__c>();
        Partner_contract__c PCObj = new Partner_contract__c();
        Id userId = UserInfo.getUserId();
        
        //Install Partner
        PCObjlist = [select id, name, contract_type__c, effective_date__c, Contract_Status__c, expiration_Date__c , Account__c,Account__r.Site from Partner_contract__c where  Account__c =: newlead.Install_Partner__c and Contract_Status__c = 'Active' and expiration_date__c > today and Contract_Type__c ='Full Service Contract' ];
        system.debug('Partner contract' + PCObjlist);
        if(PCObjlist.size() > 0 && PCObjlist != null){
            PCObj = PCObjlist[0];
            newlead.EPCPartnerName__c = PCObj.Account__c;
            newlead.EPCExecutionDate__c = PCObj.Effective_Date__c;
            newlead.InstallationOffice__c = PCObj.Account__r.Site;
            newlead.CorporatePartner__c = null;
        }else {
            PCObjlist = [select id, name, contract_type__c, effective_date__c, Contract_Status__c, expiration_Date__c , Account__c ,Account__r.Site from Partner_contract__c where Account__c =: newlead.Install_Partner__c and Contract_Status__c = 'Active' and expiration_date__c > today and Contract_Type__c ='Installation Contract' ];
            system.debug('Partner contract Lead' + PCObjlist);
            
            if(PCObjlist.size() > 0 && PCObjlist != null){
                PCObj = PCObjlist[0];
                newlead.EPCPartnerName__c = PCObj.Account__c;
                newlead.EPCExecutionDate__c = PCObj.Effective_Date__c;
                newlead.InstallationOffice__c = PCObj.Account__r.Site;
                newlead.CorporatePartner__c = null;
            }
        }
        
        //Lead-Gen Partner
        PCObjlist = [select id, name, contract_type__c, effective_date__c, Contract_Status__c, expiration_Date__c , Account__c,Account__r.Site from Partner_contract__c where  Account__c =: newlead.Lead_Gen_Partner__c and Contract_Status__c = 'Active' and expiration_date__c > today and Contract_Type__c ='Full Service Contract' ];
        system.debug('Partner contract' + PCObjlist);
        if(PCObjlist.size() > 0 && PCObjlist != null){
            PCObj = PCObjlist[0];
            newlead.LeadOrganizationName__c = PCObj.Account__c ;
            newlead.LeadOrganizationOffice__c = PCObj.Account__r.Site;
            newlead.CorporatePartner__c = null;
        }
        
        //Sales Partner
        PCObjlist = [select id, name, contract_type__c, effective_date__c, Contract_Status__c, expiration_Date__c , Account__c,Account__r.Site from Partner_contract__c where  Account__c =: newlead.Sales_Partner__c and Contract_Status__c = 'Active' and expiration_date__c > today and Contract_Type__c ='Full Service Contract' ];
        system.debug('Partner contract' + PCObjlist);
        if(PCObjlist.size() > 0 && PCObjlist != null){
            PCObj = PCObjlist[0];
            if(newlead.SalesRep__c==null){
             newlead.SalesCellPhone__c = contobj.phone;
             newlead.Sales_Rep_Email__c = contobj.email;
             newlead.SalesRep__c = userId;
             }
             newlead.SalesOrganizationName__c = PCObj.Account__c ;
             newlead.SalesOrgContractExecutionDate__c = PCObj.Effective_Date__c;             
             newlead.CorporatePartner__c = null;
        }else {
            PCObjlist = [select id, name, contract_type__c, effective_date__c, Contract_Status__c, expiration_Date__c , Account__c,Account__r.Site from Partner_contract__c where Account__c =: newlead.Sales_Partner__c and Contract_Status__c = 'Active' and expiration_date__c > today and Contract_Type__c ='Sales Contract' ];
            system.debug('Partner contract sales' + PCObjlist);
            
            if(PCObjlist.size() > 0 && PCObjlist != null){
                PCObj = PCObjlist[0];
                if(newlead.SalesRep__c ==null){
                newlead.SalesCellPhone__c = contobj.phone;
                 newlead.Sales_Rep_Email__c = contobj.email;
                 newlead.SalesRep__c = userId;
                 }
                 newlead.SalesOrganizationName__c = PCObj.Account__c ;
                 newlead.SalesOrgContractExecutionDate__c = PCObj.Effective_Date__c;                 
                 newlead.CorporatePartner__c = null;
            }
        }
      }
      */
     }
    }   
    
    //if(map_newLead != null){
       // System.debug('map_newLead: ' + map_newLead);
        //Comment Auto calculation of usage(BSKY-4086)       
       // LeadUtil.calculateMonUsage(lst_Leads,map_oldLead,isinsert,isupdate) ;
        //System.debug('map_newLead: ' + map_newLead);
    //}

}

    
   
    /* 
   Peter Alexander Mandy
   29-10-2012:14:01:34.25
   
   Conditions under which we call ZipPlusSix from Cdyne:
   1) If Lead is new and has address info
   2) If Lead is updated and has NULL ZipPlusSix and address info 
      or Non-null ZipPlusSix with Changed Address Info.   
*/
public static void trg_after_lead_ins_upd(Map<id, Lead> map_oldLead, List<Lead> lst_newLead, Boolean isUpdate) {
   //
   // This is to prevent an additional call to CDYNE when the CDYNE Results
   // Cause the Lead to be updated with correct address information
   // True, it is an address change, but not one that we need to send
   // to Cdyne, as the change was initiated by Cdyne.
   //
   if(System.isFuture())
   {
      return;
   }    
   Set<String> setGetZipPlusSix = new Set<String>();
   for(Lead l:lst_newLead)
   {
      if(Trigger.isInsert 
         && !l.Override_CDYNE__c          
         && l.Street != '' 
         && l.City != '' 
         && l.State != '' 
         && l.PostalCode != ''
         && (l.CDYNE_Status__c == null || l.CDYNE_Status__c == '')
         && (l.Zip_6__c == '' || l.Zip_6__c == null))
      {
                      
          setGetZipPlusSix.add(String.ValueOf(l.Id));         
      }

      if(isUpdate  
         && !l.Override_CDYNE__c&&l.CDYNE_Address__c != l.Street + l.City + l.State + l.PostalCode
         && 
         ((l.Street != '' 
           && l.City != '' 
           && l.State != '' 
           && l.PostalCode != ''
           && (l.Street != map_oldLead.get(l.Id).Street
               || l.City != map_oldLead.get(l.Id).City
               || l.State != map_oldLead.get(l.Id).State
               || l.PostalCode != map_oldLead.get(l.Id).PostalCode)
           && l.Zip_6__c != '')   
         ||
         (l.Street != '' 
          && l.City != '' 
          && l.State != '' 
          && l.PostalCode != ''
          && l.Zip_6__c == '')
         )   
         )
      {          
        system.debug('setGetZipPlusSix*****');
         setGetZipPlusSix.add(String.ValueOf(l.Id));
      }
   }
   //Now call Cdyne if any accounts qualified
   system.debug('setGetZipPlusSix*****'+ setGetZipPlusSix);
   /*
   if(!setGetZipPlusSix.isEmpty())
   {
      // Issue Call to CDYNE Service Method that calls CDYNE API Asynchronously.
      CDYNEService.processZipPlusSixForLeads(setGetZipPlusSix);
      system.debug('CDYNE Called*****');
   }
   */
    if(!setGetZipPlusSix.isEmpty())
   {
        if(setGetZipPlusSix.size()>10&&!Test.isRunningTest())
        {
        String query='Select id from lead where id in:leadSet';         
        BatchApexCallCDYNE batch=new BatchApexCallCDYNE(query);
        batch.leadSet=setGetZipPlusSix;
        //check if there are 5 active batch jobs
        if ([SELECT count() FROM AsyncApexJob WHERE JobType='BatchApex' AND (Status = 'Processing' OR Status = 'Preparing')] < 5){
            Database.executeBatch(batch,10);
        } else {
            ScheduleBatchApexCallCDYNE sc = new ScheduleBatchApexCallCDYNE();
            sc.query=query;
            sc.leadSet=setGetZipPlusSix;
            Datetime dt = Datetime.now() + (0.002305); 
            String timeForScheduler = dt.format('s m H d M \'?\' yyyy');
            Id schedId = System.Schedule('Retry'+timeForScheduler,timeForScheduler,sc);
        }
        }
        else{
      // Issue Call to CDYNE Service Method that calls CDYNE API Asynchronously.
      // 
      //New Address Service Integration
      //CDYNEService.processZipPlusSixForLeads(setGetZipPlusSix);
      system.debug('CDYNE Called*****');
        }
   }

}
    
    private static string getwhichOrg(){
        
        Boolean ispartnerUser;
        String whichOrgValue;
        String userType = UserInfo.getUserType();
        if(userType != null && userType != ''){
            if(userType.contains('Partner')){
                ispartnerUser = true;
            }
        }
        
        if(ispartnerUser == true){
            User userRec = [Select ContactId From User WHERE Id = :Userinfo.getUserid()];
            Contact conRec = [Select Id, Account.Name From Contact Where Id = :userRec.ContactId];
            
            system.debug('Organization Name' + conRec.Account.Name);
            whichOrgValue = conRec.Account.Name;
            return whichOrgValue;
        }
        
        whichOrgValue = 'SunRun';
        return whichOrgValue;
        
    }
 public static void LeadAfterUpdate( List<Lead> lst_newLead)
  {
     if(controlContactTriggerRecursion.ControlLeadTriggerRecurtion)
  {
        controlContactTriggerRecursion.ControlLeadTriggerRecurtion = false;
  
       Set<String> LeadAmbassadorUID = new Set<String>();  
       Set<String> ContAmbassadorUID = new Set<String>();   
       Set<Id> RefContID = new Set<Id>(); 
       Set<String> ExtId = new Set<String>();
       Set<String> SetContEmail = New Set<String>();
       Set<String> SetLeadEmail = New Set<String>();
      Map<Set<string>, List<Contact>> MapLeadToContact = new Map<set<String>, List<contact>>(); 
      Map<String,Id> MapLeadUIDToCont = New Map<String,Id>();  
      Map<Set<String>,Id> MapCont= New Map<Set<String>,Id>();
      List<Contact> ListOfContacts = new List<Contact>();  
      List<Lead> ListOfLeadsToUpd = new List<Lead>();
      Map<String,String> MapOfEmailAndCommissionId = New Map<String,String>();
      
      
     for(Lead LeadObj : lst_newLead)
     {
         System.debug('This is Ref Email '+LeadObj.Ambassador__Referred_By_Contact__c);
         if(LeadObj.Referred_by_Contact_Email__c == Null && (LeadObj.Ambassador__Referred_By_Contact__c != null && LeadObj.IsConverted != true && LeadObj.Channel__c!=null && LeadObj.Channel__c!='' && LeadObj.Channel__c.contains('Referral')))
            RefContID.add(LeadObj.Ambassador__Referred_By_Contact__c);
            SetLeadEmail.add(LeadObj.Email);
     }
      System.debug('This is Ref ConT' + RefContID + 'SetLeadEmail'+ SetLeadEmail);
      if(!(RefContID.isempty()))
      {
          map<id,contact> TempContactMap = new Map<id,contact>([Select Id,Email from contact where Id in : RefContID]);
          System.debug('===This is TempContactMap values==:'+ TempContactMap.values());
          System.debug('===This is TempContactMap Keys==:'+ TempContactMap.keySet());
          map<id,Ambassador__Commission__c> TempCommissionMap = new Map<id,Ambassador__Commission__c>([Select Id,Ambassador__Referee__c,Ambassador__Contact__c,Ambassador__Commission_ID__c 
                                                                                                       from Ambassador__Commission__c 
                                                                                                       where Ambassador__Contact__c in : RefContID 
                                                                                                       and Ambassador__Referee__c in :SetLeadEmail]);
          System.debug('===This is TempCommissionMap values==:'+ TempCommissionMap.values());
          System.debug('===This is TempCommissionMap Keys==:'+ TempCommissionMap.keySet());
      For(Ambassador__Commission__c TempCommission : TempCommissionMap.values())
      {
          if(TempCommission.Ambassador__Referee__c!=null && TempCommission.Ambassador__Contact__c!=null && TempCommission.Ambassador__Commission_ID__c!=null)
          {
              MapOfEmailAndCommissionId.put(TempCommission.Ambassador__Referee__c,TempCommission.Ambassador__Commission_ID__c);
              System.debug('===This is MapOfEmailAndCommissionId values==:'+ MapOfEmailAndCommissionId.values());
              System.debug('===This is MapOfEmailAndCommissionId Keys==:'+ MapOfEmailAndCommissionId.keySet());
          }
      }    
          
      For(Contact referredCont : TempContactMap.values())
      {
          if(referredCont.Email != null)
          LeadAmbassadorUID.add(referredCont.Email);
          System.debug('This is Referred by Cont' + LeadAmbassadorUID);
      } 
      if(!(LeadAmbassadorUID.isempty()))
      {
          For(Contact existingcontact : [Select Id,name,External_Id__c,Ambassador__Ambassador_ID__c from contact where External_Id__c in :LeadAmbassadorUID and Ambassador__Ambassador_ID__c!=null])
          {
                 System.debug('This is Existing Contact' + existingcontact);
               //  ListOfContacts.add(existingcontact);
                // ContAmbassadorUID.add(existingcontact.Ambassador__c);
                // MapLeadToContact.put(ContAmbassadorUID,ListOfContacts);
                   ExtId.add(existingcontact.External_Id__c);
                 MapCont.put(ExtId,existingcontact.Id);
                 MapLeadUIDToCont.put(existingcontact.External_Id__c,existingcontact.Id);
                 System.debug('This is Map key Set'+ MapLeadUIDToCont.keySet());
                 System.debug('This is Map Values' + MapLeadUIDToCont.values());
          }      
          for(Lead TempnewLead: lst_newLead)
          {
            Lead newLead = new lead(id = TempnewLead.id,Ambassador__Referred_By_Contact__c=TempnewLead.Ambassador__Referred_By_Contact__c,email=TempnewLead.email,Commission_ID__c=TempnewLead.Commission_ID__c);
              System.debug('This is Newlead'+ NewLead);
             
         //   If(newLead.Ambassador__Referred_By_Contact__c  !=Null && MapCont.ContainsKey(LeadAmbassadorUID))
              If(newLead.Ambassador__Referred_By_Contact__c  !=Null && MapLeadUIDToCont.ContainsKey((TempContactMap.get(TempnewLead.Ambassador__Referred_By_Contact__c)).email))
             {
                 System.debug('This is---:'+ MapLeadUIDToCont.ContainsKey((TempContactMap.get(TempnewLead.Ambassador__Referred_By_Contact__c)).email));
              //   SetContEmail.add(newLead.Referring_Cont_Email__c);
                 System.debug('This is MapLeadUIDToCont'+ MapCont);
              //   System.debug('This is a Value'+MapCont.get(newLead.Referring_Cont_Email__c));
              //   newLead.Referred_By_Contact__c=MapCont.get(SetContEmail);
                   //newLead.Referred_By_Contact__c=MapCont.get(LeadAmbassadorUID);
                 newLead.Referred_By_Contact__c=MapLeadUIDToCont.get((TempContactMap.get(TempnewLead.Ambassador__Referred_By_Contact__c)).email);
                 System.debug('This is---:'+ MapLeadUIDToCont.get((TempContactMap.get(TempnewLead.Ambassador__Referred_By_Contact__c)).email));
                 If(newLead.Commission_ID__c==Null && MapOfEmailAndCommissionId.containsKey(newLead.Email)) 
                 newLead.Commission_ID__c = MapOfEmailAndCommissionId.get(newLead.Email);   
                 System.debug('This is:'+ newLead.Commission_ID__c);
                 System.debug('This is:'+ MapOfEmailAndCommissionId.get(newLead.Email));
                 ListOfLeadsToUpd.add(newLead);
                 System.debug('this is list to upd:'+ListOfLeadsToUpd);
                    
             }
          }
          
          If(!ListOfLeadsToUpd.IsEmpty())
                Update ListOfLeadsToUpd;
        }
        }
      }    
}        
        
public static void LeadBeforeInsert( List<Lead> lst_newLead) {
      
      //System.debug('trg_lead_after_insert'); 
      //System.debug('map_oldLead : ' +map_oldLead);
        System.debug('lst_newLead : ' +lst_newLead);
      //System.debug('isInsert : ' +isInsert); 
      //System.debug('isUpdate : ' +isUpdate);
      
      Set<Id> setUpdateReferralToDupe = new Set<Id>();
      Set<Id> setUpdateReferralToNew = new Set<Id>();
      Map<Id, Id> mapReferralToNewSource = new Map<Id, Id>();
      Set<Id> setDeleteReferrals = new Set<Id>();
      Map<Id, Id> mapSourcePromo;
       Set<String> LeadAmbassadorUID = new Set<String>();  //Added by MA
       Set<String> ContAmbassadorUID = new Set<String>();   //Added by MA
       Set<Id> RefContID = new Set<Id>(); //Added by MA
       Set<String> ExtId = new Set<String>(); //Added by Ma
      Map<Set<string>, List<Contact>> MapLeadToContact = new Map<set<String>, List<contact>>();  //Added by MA
      Map<String,Id> MapLeadUIDToCont = New Map<String,Id>();  
      Map<Set<String>,Id> MapCont= New Map<Set<String>,Id>();
      List<Contact> ListOfContacts = new List<Contact>();  
                 
      for(Lead newLead: lst_newLead)
      {
          System.debug('This is Newlead'+ NewLead);
         
          // Added by MA
          If(newLead.Referred_by_Contact_Email__c !=Null && newLead.Referred_by_Contact_Email__c !='' && newLead.Channel__c!=null && newLead.Channel__c!='' && newLead.Channel__c.contains('Referral'))
          {             
              LeadAmbassadorUID.add(newLead.Referred_by_Contact_Email__c);
              System.debug('This is Lead AUID' +LeadAmbassadorUID );
          }
          
      }    
      For(Contact existingcontact : [Select Id,name,External_Id__c,Ambassador__Ambassador_ID__c from contact where External_Id__c in :LeadAmbassadorUID and Ambassador__Ambassador_ID__c!=null])
             
         {
             System.debug('This is Existing Contact' + existingcontact);
           //  ListOfContacts.add(existingcontact);
            // ContAmbassadorUID.add(existingcontact.Ambassador__c);
            // MapLeadToContact.put(ContAmbassadorUID,ListOfContacts);
               ExtId.add(existingcontact.External_Id__c);
             MapCont.put(ExtId,existingcontact.Id);
             MapLeadUIDToCont.put(existingcontact.External_Id__c,existingcontact.Id);
             System.debug('This is Map key Set'+ MapLeadUIDToCont.keySet());
             System.debug('This is Map Values' + MapLeadUIDToCont.values());
         }
    for(Lead newLead: lst_newLead)
     {  
         If((newLead.Referred_by_Contact_Email__c !=Null && newLead.Referred_by_Contact_Email__c !='') && MapLeadUIDToCont.ContainsKey(newLead.Referred_by_Contact_Email__c))
         {
           //  If(Trigger.IsBefore)
           //  {
             System.debug('This is MapLeadUIDToCont'+ MapLeadUIDToCont);
             System.debug('This is a Value'+MapLeadUIDToCont.get(newLead.Referred_by_Contact_Email__c));
             newLead.Referred_By_Contact__c=MapLeadUIDToCont.get(newLead.Referred_by_Contact_Email__c);
             //}    
         }     
        
      }
    
}    
    public static void LeadExtSourceBeforeInsert( List<Lead> lst_newLead) 
    {
        for(Lead l:lst_newLead)
        {
            if(l.External_Source__c!=null && l.External_Source__c=='ZEUS')
            {
                l.External_Source_Account__c=System.label.Clean_Energy_Experts;
            }
        }
    }
    
    /****************************************************************************
Author  : Peter Alexander Mandy (pmandy@sunrunhome.com)
Date    : June 05, 2012
Description: This trigger creates a referral input based on the Lead data, 
             provided it is not a duplicate entry and the lead is from a referral.
             June052012: Decision was made to go lead=>referral vs. referral=>lead
*****************************************************************************/
    public static void trg_lead_after_insert(Map<id, Lead> map_oldLead, List<Lead> lst_newLead, Boolean isInsert, Boolean isUpdate) {
      
      //System.debug('trg_lead_after_insert'); 
      //System.debug('map_oldLead : ' +map_oldLead);
      //System.debug('lst_newLead : ' +lst_newLead);
      //System.debug('isInsert : ' +isInsert); 
      //System.debug('isUpdate : ' +isUpdate);
      Map<Id, Set<String>> mapReferralIdToStatus = new Map<Id, Set<String>>();    
      ReferralService refSvc = new ReferralService();         
      List<Referral_Input__c> listNewReferrals = new List<Referral_Input__c>();  
      List<Referral_Input__c> listUpdateReferralsDupe = new List<Referral_Input__c>();
      List<Referral_Input__c> listUpdateReferralsNew = new List<Referral_Input__c>();
      Set<Id> setUpdateReferralToDupe = new Set<Id>();
      Set<Id> setUpdateReferralToNew = new Set<Id>();
      Map<Id, Id> mapReferralToNewSource = new Map<Id, Id>();
      Set<Id> setDeleteReferrals = new Set<Id>();
      Map<Id, Id> mapSourcePromo;
      /*for(lead oLead:lst_newLead)
      {
        if(checkRecursive.runReferralServiceOnce()
           || (oLead.Referred_By_Contact__c != null && isInsert)
           || (isUpdate && map_oldLead.get(oLead.Id).Referred_By_Contact__c == null && oLead.Referred_By_Contact__c !=  null)
          )
        {
          mapSourcePromo = refSvc.getMapSourceToPromo(lst_newLead);
        } 
      }*/
      List<Lead> Reff_Leads=new List<Lead>();
      for(lead oLead:lst_newLead){
        if((oLead.Referred_By_Contact__c != null && isInsert)
           || (isUpdate && map_oldLead.get(oLead.Id).Referred_By_Contact__c == null && oLead.Referred_By_Contact__c !=  null)
          )
        {
            Reff_Leads.add(oLead);
        }
      }
      if(!Reff_Leads.isempty()){
         mapSourcePromo = refSvc.getMapSourceToPromo(Reff_Leads);
      }     
      for(Lead newLead: lst_newLead)
      {
          if(//setReferralLeadSource.Contains(newLead.LeadSource)
             // As of 06192012, we want to go ahead and create the duplicate referrals too, for reporting sake.
             //&& newLead.Status != 'Unqualified' -- technically we should NOT be able to set Why_Unqualified__c unless Status is "Unqualified", but we can, so just check Why_Unqualified__c
             //&& newLead.Why_Unqualified__c != 'Duplicate lead'
                (newLead.Referred_By_Contact__c != null && isInsert)
             || (isUpdate && map_oldLead.get(newLead.Id).Referred_By_Contact__c == null && newLead.Referred_By_Contact__c !=  null)
             &&!checkRecursive.referralLeadIds.contains(newLead.id)
            )     
         {
            Referral_Input__c newReferral = refSvc.createReferral(newLead, lst_newLead, mapSourcePromo);
            listNewReferrals.add(newReferral);   
            checkRecursive.referralLeadIds.add(newLead.id);        
         }
         // Delete referral
         if(isUpdate && map_oldLead.get(newLead.Id).Referred_By_Contact__c != null && newLead.Referred_By_Contact__c ==  null)
         {
            setDeleteReferrals.add(newLead.Referral_Input__c);
         }
         //Update Referred By Contact   
         if(isUpdate && newLead.Referred_By_Contact__c != map_oldLead.get(newLead.Id).Referred_By_Contact__c && map_oldLead.get(newLead.Id).Referred_By_Contact__c != null && newLead.Referred_By_Contact__c !=  null)
         {
            mapReferralToNewSource.put(newLead.Referral_Input__c, newLead.Referred_By_Contact__c);
         }       
         // Update Status 
         if(isUpdate && newlead.Lead_Status__c == Label.Lead_Status_Duplicate && (newlead.Why_Unqualified__c == Label.Lead_Why_Unqualified_DuplicateLeadFound || newlead.Why_Unqualified__c == Label.Lead_Why_Unqualified_DuplicateOpptyFound))
         {
            setUpdateReferralToDupe.add(newLead.Referral_Input__c);
         }
         if(isUpdate && newlead.Why_Unqualified__c != Label.Lead_Why_Unqualified_DuplicateLeadFound && newlead.Why_Unqualified__c != Label.Lead_Why_Unqualified_DuplicateOpptyFound && map_oldLead.get(newLead.Id).Lead_Status__c == Label.Lead_Status_Duplicate)
         {
            setUpdateReferralToNew.add(newLead.Referral_Input__c);
         }           
         if(isUpdate && newLead.Lead_Status__c != map_oldLead.get(newLead.Id).Lead_Status__c && newLead.Referral_Input__c != null)
         {              
             if(mapReferralIdToStatus.get(newLead.Referral_Input__c) != null)
             {
                mapReferralIdToStatus.get(newLead.Referral_Input__c).add(newLead.Lead_Status__c);
             }
             else
             {
                mapReferralIdToStatus.put(newLead.Referral_Input__c, new Set<String>{newLead.Lead_Status__c});  
             }                                                                      
         }
         Notes__c noteobj = new Notes__c();
         if(isInsert){

                if(newLead.Notes__c != null && newLead.Notes__c != ''){
                    noteobj.Notes__c = newLead.Notes__c;
                    noteobj.Lead__c = newLead.Id;
                    noteobj.Notes_Added_By__c = getwhichOrg();
                    insert noteobj;
                }
                if(newLead.Partner_Notes__c != null && newLead.Partner_Notes__c != ''){

                    //system.debug('LeadId' + newLead.Id);
                    noteobj.Notes__c = newLead.Partner_Notes__c;
                    noteobj.Lead__c = newLead.Id;
                    noteobj.Notes_Added_By__c = getwhichOrg();
                    insert noteobj;
                }

            }
            if(isUpdate && newlead.Notes__c != map_oldLead.get(newlead.id).Notes__c && newlead.Notes__c != null && !checkrecursive.updatedNotesLeadIds.contains(newLead.id)){
                noteobj.Notes__c = newLead.Notes__c;
                noteobj.Lead__c = newLead.Id;
                noteobj.Notes_Added_By__c = getwhichOrg();
                checkRecursive.updatedNotesLeadIds.add(newlead.id);
                insert noteobj;
            }
            if(isUpdate && newlead.Partner_Notes__c != map_oldLead.get(newlead.id).Partner_Notes__c && newlead.Partner_Notes__c != null && !checkrecursive.updatedPartnerNotesLeadIds.contains(newLead.id)){
                noteobj.Notes__c = newLead.Partner_Notes__c;
                noteobj.Lead__c = newLead.Id;
                noteobj.Notes_Added_By__c = getwhichOrg();
                checkRecursive.updatedPartnerNotesLeadIds.add(newlead.id);
                insert noteobj;
            }
      }
      //
      if(!setUpdateReferralToDupe.isEmpty())
      {
        for(Referral_Input__c r:[select id, Milestone_1_Status__c, Milestone_2_Status__c, Milestone_3_Status__c from Referral_Input__c where id in :setUpdateReferralToDupe])
        {
            listUpdateReferralsDupe.add(r);
        }
      }
      if(!setUpdateReferralToNew.isEmpty())
      {
         for(Referral_Input__c r:[select id, Milestone_1_Status__c, Milestone_2_Status__c, Milestone_3_Status__c from Referral_Input__c where id in :setUpdateReferralToNew])
         {
            listUpdateReferralsNew.add(r);
         }
      }      
      //
      if(!mapReferralToNewSource.isEmpty())
      {
        refSvc.updateReferralSource(mapReferralToNewSource);
      }
      //
      if(!setDeleteReferrals.isEmpty())
      {
         refSvc.deleteReferral(setDeleteReferrals);
      }
      //
      if(listNewReferrals.size() > 0)
      {
         insert listNewReferrals;
      }
      if(listUpdateReferralsDupe.size() > 0)
      {
         update listUpdateReferralsDupe;
      }
      if(listUpdateReferralsNew.size() > 0)
      {
         update listUpdateReferralsNew;
      }      
      //check for stage change to see if qualifies for referral payment
      if(!mapReferralIdToStatus.isEmpty())
      {
         //System.Debug('Calling Referral Service to set the status to ' + Label.ReferralReadyForPayment);
         refSvc.setReferralStatus(mapReferralIdToStatus, 'Lead');
      } 
      
     
    
    List<Offer__c> offerObjList = new List<Offer__c>();
    List<Partner_Role__c> partnerRoleList = new List<Partner_Role__c>();
    Partner_Role__c partnerRoleLead = new Partner_Role__c();
    Partner_Role__c partnerRoleInstall= new Partner_Role__c();
    Partner_Role__c partnerRoleSales= new Partner_Role__c();
    Set<Id> convertedOpportunity = new Set<Id>();
    map<Id, Lead> convertedContactMap = new map<Id, Lead>();
    map<Id, string> convertedAccountMap = new map<Id, string>();
    map<Id, string> convertedOpptyMap = new map<Id, string>();
    map<Id, Id> convertedLeadIds = new map<Id, Id>();
    map<Id, Id> convertedLeadToContact = new map<Id, Id>();
    for(Lead newLead: lst_newLead)
    {
        //Creating offers
        //System.debug('Entering3 Offer');
        //System.debug('isInsert : ' +isInsert); 
        //System.debug('isupdate : ' +isupdate);
        //System.debug('Old Offer Promo Code :' +map_oldLead.get(newlead.Id).Offer_Promo_Code__c); 
        //System.debug('New Offer Promo Code :' +newLead.Offer_Promo_Code__c); 
        if(isInsert || (isupdate && map_oldLead.get(newlead.Id).Offer_Promo_Code__c == null)){
            if(newLead.Offer_Promo_Code__c != null && newLead.Offer_Promo_Name__c != null ) {
                Offer__c offerObj = new Offer__c();
                offerObj.Lead__c = newLead.Id;
                offerObj.Promotion__c = newLead.Offer_Promo_Name__c;
                offerObj.Customer_Salutation__c = newLead.LC_Salutation__c;
                offerObj.Customer_Contact__c = newLead.ConvertedContactId;
                offerObj.Customer_Address_City__c =  newLead.LC_City__c;
                offerObj.Customer_Address_Country__c =  newLead.LC_Country__c;
                offerObj.Customer_Email__c =  newLead.LC_Email__c;
                offerObj.Customer_First_Name__c =  newLead.LC_FirstName__c;
                offerObj.Customer_Last_Name__c =  newLead.LC_LastName__c;
                offerObj.Customer_Phone_Number__c =  newLead.LC_PhoneNumber__c;
                offerObj.Customer_Address_State__c =  newLead.LC_State__c;
                offerObj.Customer_Address_Street__c =  newLead.LC_Street__c;
                offerObj.Customer_Address_ZipCode__c =  newLead.LC_ZipCode__c;
             
             offerObjList.add(offerObj);
             //System.debug('Offer rec added to list :' +newLead.Offer_Promo_Name__c); 
             //System.debug('Entering4 Offer');
            }
        }
      if(newlead.Isconverted &&!checkrecursive.convertedLeadIds.contains(newLead.id)){
      checkrecursive.convertedLeadIds.add(newLead.id);  
        if(newlead.IsConverted == true && newLead.convertedOpportunityId != null){
            convertedLeadIds.put(newlead.id,newLead.convertedOpportunityId);
            if(newlead.Street != null || newlead.Street != ''){
                String OpptyName = newlead.Street + '-' + newlead.PostalCode;
                convertedOpptyMap.put(newlead.convertedOpportunityId, OpptyName);
            }
            //system.debug('convertedLeadIds : ' + convertedLeadIds);
        }
        if(newlead.Isconverted == true && newlead.ConvertedContactId != null){
            convertedLeadToContact.put(newlead.id,newlead.ConvertedContactId );
            convertedContactMap.put(newlead.ConvertedContactId, newlead);
        }
        
        if(newlead.Isconverted == true && newlead.ConvertedAccountId != null){
            if(newlead.Street != null || newlead.Street != ''){
                String AccountName = newlead.Street + '-' + newlead.PostalCode;
                convertedAccountMap.put(newlead.ConvertedAccountId, AccountName);
            }
        }
        
        if(newLead.IsConverted == true && newLead.convertedOpportunityId != null){
            convertedOpportunity.add(newLead.convertedOpportunityId);           
            //Contact contobj = PRMContactUtil.getLoginUserContact();
                 partnerRoleLead.Opportunity__c = newLead.convertedOpportunityId;
                partnerRoleLead.Partner_Name__c = newLead.Lead_Gen_Partner__c;
                partnerRoleLead.Role__c = 'Lead Gen';
                //partnerRoleLead.LeadOrganizationName__c = newlead.LeadOrganizationName__c;
                //partnerRoleLead.LeadOrganizationOffice__c = newlead.LeadOrganizationOffice__c;
                partnerRoleLead.CorporatePartner__c = newlead.CorporatePartner__c;
                
                partnerRoleList.add(partnerRoleLead);
                
                partnerRoleInstall.Opportunity__c = newLead.convertedOpportunityId;
                partnerRoleInstall.Partner_Name__c = newLead.Install_Partner__c;
                partnerRoleInstall.Role__c = 'Install';
                partnerRoleInstall.Contract_Execution_Date__c = newlead.EPCExecutionDate__c;
                //partnerRoleInstall.EPCPartnerName__c = newlead.EPCPartnerName__c;
                //partnerRoleInstall.InstallationOffice__c = newlead.InstallationOffice__c;
                partnerRoleInstall.CorporatePartner__c = newlead.CorporatePartner__c;
               // partnerRoleInstall.Install_Branch__c = newlead.Install_Branch_id__c;
                
                partnerRoleList.add(partnerRoleInstall);
                
                partnerRoleSales.Opportunity__c = newLead.convertedOpportunityId;
                partnerRoleSales.Partner_Name__c = newLead.Sales_Partner__c;
                partnerRoleSales.Role__c = 'Sales';
                partnerRoleSales.Sales_Rep_Phone__c = newlead.SalesCellPhone__c;
                partnerRoleSales.Sales_Rep_Email__c = newlead.Sales_Rep_Email__c;
                partnerRoleSales.Sales_Rep_Division__c= newlead.Sales_Rep_Division__c;
                partnerRoleSales.Department__c=newlead.Department__c;
                
                //partnerRoleSales.SalesOrganizationName__c = newlead.SalesOrganizationName__c;
                partnerRoleSales.Contract_Execution_Date__c = newlead.SalesOrgContractExecutionDate__c;
                partnerRoleSales.SalesRep__c = newlead.SalesRep__c;
                partnerRoleSales.CorporatePartner__c = newlead.CorporatePartner__c;
                
                partnerRoleList.add(partnerRoleSales);               
            
          }      
      }
    }
    
    List<Offer__c> UpdateOfferwithOppty = new List<Offer__c>();
    List<Referral_Input__c> UpdateReferralwithOppty = new List<Referral_Input__c>();
    map<Id, Id> mapOffertoOppty = new map<Id, Id>();
     map<Id, Id> mapReferraltoOppty = new map<Id, Id>();
    if(!convertedLeadIds.isEmpty()){
        for(Offer__c offerObj : [Select id, name, lead__c, Opportunity__c,Offer_Promotion_Code__c from Offer__c where lead__c in :convertedLeadIds.keyset()]){
            offerObj.Opportunity__c = convertedLeadIds.get(offerObj.lead__c);
            offerObj.Customer_Contact__c = convertedLeadToContact.get(offerObj.lead__c);
            mapOffertoOppty.put(offerObj.Opportunity__c,offerObj.id);
            //system.debug('mapOffertoOppty:' + mapOffertoOppty);
            UpdateOfferwithOppty.add(offerObj);
        }  
        for(Referral_input__c refObj : [Select id, name, lead__c, Opportunity__c from Referral_input__c where lead__c in :convertedLeadIds.keyset()]){
            refObj.Opportunity__c = convertedLeadIds.get(refObj.lead__c);
            refObj.Target_Contact_Id__c = convertedLeadToContact.get(refObj.lead__c);
            mapReferraltoOppty.put(refObj.Opportunity__c,refObj.id);
            UpdateReferralwithOppty.add(refObj);
        }        
    }
    if(UpdateReferralwithOppty.size() > 0){
        update UpdateReferralwithOppty;
    }
    if(UpdateOfferwithOppty.size() > 0){
        update UpdateOfferwithOppty;
    }
    /*
    if(!mapOffertoOppty.isEmpty()){
        system.debug('isEmpty mapOffertoOppty :' + !mapOffertoOppty.isEmpty());
        LeadUtil.UpdateOpptywithOffer(mapOffertoOppty);
    } 
    */      
    List<Design_Option__c> designOptionList = new List<Design_Option__c>();
    if(!convertedLeadIds.isempty()){
    designOptionList=[select costPerYearkWh__c,KWH_KWP__c,KWH__c,KWP__c,Lead__c,Module__c,Name,
                                                Opportunity__c,Serial_Number__c,Usage__c FROM Design_Option__c 
                                                where Lead__c in :convertedLeadIds.keyset()];
    }
    //system.debug('designOptionList : ' + designOptionList) ;
    List<Design_Option__c>  OpptyDesignOption = new List<Design_Option__c>();                       
    if(designOptionList.size() > 0){
        Design_Option__c newDesign = new Design_Option__c();
        for(Design_Option__c Design : designOptionList){
            newDesign.name = Design.Name;
            newDesign.costPerYearkWh__c = Design.costPerYearkWh__c;
            newDesign.KWH__c = Design.KWH__c;
            newDesign.KWH_KWP__c = Design.KWH_KWP__c;
            newDesign.KWP__c = Design.KWP__c;
            newDesign.Module__c = Design.Module__c;
            newDesign.Serial_Number__c = Design.Serial_Number__c;
            newDesign.Usage__c = Design.Usage__c;
            //system.debug(' Oppty Id :' + convertedLeadIds.get(Design.lead__c));
            newDesign.Opportunity__c = convertedLeadIds.get(Design.lead__c);
            
            OpptyDesignOption.add(newDesign);
        }
    }
        
        List<Design_Option__c> insertDOList = new List<Design_Option__c>();
        Set<Design_Option__c> insertDOset = new Set<Design_Option__c>();
        if(OpptyDesignOption.size() > 0){
            for(Design_Option__c designObj : OpptyDesignOption){
                if(insertDOset.add(designObj)){
                    insertDOList.add(designObj);
                }
            }
            if(insertDOList.size() > 0){
                insert insertDOList;
            }
        }
            
    //}                           
    
    
    if(!convertedContactMap.isEmpty()){
        LeadUtil.UpdateContactOnConversion(convertedContactMap);
    }
    
    if(!convertedAccountMap.isEmpty()){
        LeadUtil.UpdateAccountOnConversion(convertedAccountMap);
    }
    List<OpportunityContactRole> contactRoleList = new List<OpportunityContactRole>();
    Set<Id> contactIds=new Set<id>();
    if(!convertedOpportunity.isempty()){
    for(OpportunityContactRole ContactRole :[Select Id, role, isPrimary, ContactId, OpportunityId from OpportunityContactRole where OpportunityId =:convertedOpportunity] ){
        ContactRole.role = 'Homeowner';
          ContactRole.isPrimary = true;
          contactRoleList.add(ContactRole);
          contactIds.add(ContactRole.ContactId);
    }
    }
    
   if(contactRoleList.size() > 0){
    update contactRoleList;
   }
   
   if(offerObjList.size() > 0 && offerObjList != null){
        insert offerObjList;
     }
  if(partnerRoleList != null && partnerRoleList.size() > 0){
        insert partnerRoleList;
    }
    if(!contactIds.isempty()){
        ContactSharing.ContactSharing(contactIds);
    }
    
}
    public static void ConversionAndUpdateOppty(List<Lead> lst_newLead){
            Set<Id> convertedOpportunityIds = new Set<Id>();
            for(Lead ld:lst_newLead){
                if(ld.convertedOpportunityId!=null && ld.Status =='Converted'){
                    convertedOpportunityIds.add(ld.convertedOpportunityId);
                    //system.debug('Converted Opportunity IDS **********'+convertedOpportunityIds);
                }                
            }           
            List < Opportunity> opplist = new List<Opportunity>();
            if(!convertedOpportunityIds.isempty()){
            oppList=[Select Id,Name,StageName,Opportunity_Status__c from Opportunity where Id IN :convertedOpportunityIds];
            }
            Map <Id,Opportunity> oppmap = new Map <Id,Opportunity>(opplist);
                If(!oppmap.isEmpty()){
                //system.debug('Printing OppMap *********'+oppmap);
                }    
            
            List <Opportunity> updateOpportunity = new List<Opportunity>();
            
            If(!oppmap.isEmpty()){
            for(Lead ld:lst_newLead){
                if(ld.convertedOpportunityId!=null && ld.Status =='Converted')
                    {
                        if(ld.Lead_Status_For_Oppty__c == 'Warm Transfer')
                        {
                            Opportunity oppr = oppmap.get(ld.convertedOpportunityId);
                            oppr.StageName = '1. Created';
                            oppr.Opportunity_Status__c = 'Warm Transfer';
                            oppr.contact__c=ld.ConvertedContactId;
                            oppr.lead_qualifier__c=userinfo.getuserid();
                            if(ld.Install_Partner__c!= System.Label.Sunrun_Inc_Id){
                             oppr.Install_Branch_Id__c = null;
                            }
                            updateOpportunity.add(oppr);
                            //system.debug('Printing Opportunity Stage and Add'+oppr.StageName+'   and    '+oppr.Opportunity_Status__c);
                        }
                        else if(ld.Lead_Status_For_Oppty__c == 'Appointment Set - Confirmed' || ld.Lead_Status_For_Oppty__c == 'Appointment Set - Not Confirmed')
                        {
                            Opportunity oppr = oppmap.get(ld.convertedOpportunityId);
                            oppr.StageName = '2. Appointment Process';
                            oppr.contact__c=ld.ConvertedContactId;
                            oppr.lead_qualifier__c=userinfo.getuserid();
                            if(ld.Install_Partner__c!= System.Label.Sunrun_Inc_Id){
                             oppr.Install_Branch_Id__c = null;
                            }
                            updateOpportunity.add(oppr);  
                            //system.debug('Printing Opportunity Stage and Add'+oppr.StageName);
                        }
                        else{
                            Opportunity oppr = oppmap.get(ld.convertedOpportunityId);
                            oppr.contact__c=ld.ConvertedContactId;
                            oppr.lead_qualifier__c=userinfo.getuserid();
                            if(ld.Install_Partner__c!= System.Label.Sunrun_Inc_Id){
                             oppr.Install_Branch_Id__c = null;
                            }
                            updateOpportunity.add(oppr);                            
                        }
                    }                    
            }
            
            if(!updateOpportunity.isEmpty())
            {
                update updateOpportunity;
            }
    }
       
 }
    public static void ConversionScript(List<Lead> lst_oldLead , List<Lead> lst_newLead){
        if(!lst_oldLead.isEmpty() && lst_oldLead.size() ==1){
        if (lst_oldLead[0].isConverted == false && lst_newLead[0].isConverted == true)  {

   // if a new account was created
   if (lst_newLead[0].ConvertedAccountId != null) {
        
        //get all the quotes belonging to that lead
        Quote__c[] quotes = [Select q.Id from Quote__c q where q.Lead__c= :lst_newLead[0].Id];
        
        for (Quote__c quote : quotes) {
            //set the account id to the given account
            quote.account__c=lst_newLead[0].ConvertedAccountId;
            update quote;   
        }
   }
      
  }
  }
    }   
    
    public static void trg_before_insert_fillLeadGeneratedByBefIns(List<Lead> lst_Leads){
        id id=userinfo.getUserId();
        for(lead l:lst_Leads){
            if(l.Lead_Generated_by__c==null){                
                l.Lead_Generated_by__c=id;
            } 
            if(l.Sales_Partner__c!=null&&l.Retail_Sales_Partner_Assigned__c==false){
            l.Partner_for_Lead_Passing__c=l.Sales_Partner__c;
            l.Retail_Sales_Partner_Assigned__c=true;
            }
        }
    }
    public static void trg_before_insert_fillLeadGeneratedByAftUp(List<Lead> lst_Leads){
        for(lead l:lst_Leads){                    
            if(l.Sales_Partner__c!=null&&l.Retail_Sales_Partner_Assigned__c==false){
            l.Partner_for_Lead_Passing__c=l.Sales_Partner__c;
            l.Retail_Sales_Partner_Assigned__c=true;
            }
        }  
    }
    public static void LeadEmail(List<Lead> lst_Leads){
        for(Lead newLead : lst_Leads){
        
            Messaging.SingleEmailMessage msg = new Messaging.SingleEmailMessage();
            msg.setToAddresses(new String[]{newLead.Email});
            
        }
    }   
    public static void trg_lead_bef_upd_leadStatus(List<Lead> lst_Leads){
       // Set<id> LeadIds=new Set<id>();
        for(lead l:lst_Leads){
            if(l.IsConverted){
                l.Lead_Status_For_Oppty__c = l.Lead_Status__c;
                l.Lead_Status__c='Converted';
                l.lead_qualifier__c=userinfo.getuserid();
                if(l.Install_Partner__c!= System.Label.Sunrun_Inc_Id){
                   l.Install_Branch_Id__c = null;
                }
               // LeadIds.add(l.id);
            }
        }
        /*if(!LeadIds.isempty()){
                List<CampaignMember> cmList=[Select id from CampaignMember where LeadId in:LeadIds];
                if(!cmList.isempty()){
                System.debug('---delete cm'+cmList);
                    delete cmList;
                }
         }
         */       
    }
    
    public static void LeadAssignmentBeforeInsert(List<Lead> lst_Leads){
        if(userinfo.getUserType()=='PowerPartner'){
            for(Lead l : lst_Leads){
              l.lock_assignment__c=true;
            }  
        }
    }
    public static void LeadAssignmentAfterUpdate(List<Lead> lst_Leads,Map<id, Lead> map_oldLead){
        if(system.isFuture() == false && system.isBatch() == false && Userinfo.getUserType()!='PowerPartner'){    
         List<Contact_Preferences__c>  ContactPreferenceList=new List<Contact_Preferences__c>();
         if(checkRecursive.runContactPreferenceOnce()){
            ContactPreferenceList=[select id from Contact_Preferences__c where contact__r.email=:userinfo.getUserEmail() and lock_assignment__c='Yes'];
         }
         Set<id> ids=new Set<id>();
         Set<id> SynchronousIds=new Set<id>();
         Set<String> leadSourceSet=new Set<String>();
         for(Partner_Ma__c pma:Partner_Ma__c.getAll().values()){
            leadSourceSet.add(pma.Lead_Source__c);
          }
          for(lead l:lst_Leads){      
           //System.debug('l.SalesRep_contact__c : ' +l.SalesRep_contact__c);
           if(ContactPreferenceList.isempty()&&l.channel__c!=null&&l.custom_lead_source__c!=null&&l.SalesRep_contact__c==null&&l.custom_lead_source__c!='Partner: Legacy'&&!leadSourceSet.contains(l.custom_lead_source__c)&&(l.lock_assignment__c==false||map_oldLead.get(l.id).custom_lead_source__c!=l.custom_lead_source__c||map_oldLead.get(l.id).salesrep__c!=l.salesrep__c||map_oldLead.get(l.id).postalcode!=l.postalcode)&&!l.isConverted &&!checkRecursive.leadsetIds.contains(l.id)&&!l.Sunrun_South__c&&!(l.phone==null&&l.email==null&&l.Alternate_Phone__c==null&&l.MobilePhone==null)){                    
          if(l.Synchronous_Assignment__c||(map_oldLead.get(l.id).salesrep__c!=l.salesrep__c)){
            SynchronousIds.add(l.id);
            //System.debug('Adding Lead Id to SynchronousIds');
          }
          else{
          ids.add(l.id);
          //System.debug('Adding Lead Id to non-SynchronousIds');
          }
          checkRecursive.leadsetIds.add(l.id);
          }      
        }
        if(!ids.isEmpty()&&!test.isrunningTest()){  
        System.debug('----> insert lead ids'+ids);    
        Lead_Assignment.Lead_Assignment(ids);    
        }
        if(!SynchronousIds.isempty()&&!test.isrunningtest()){
        //System.debug('Calling Lead Assignment synchronously');  
        Lead_Assignment.Lead_Assignment_Immediate(SynchronousIds);  
        }
      
  } 
    }
    public static void trg_webtoleadBeforeInsert(List<Lead> lst_Leads){
        for(lead l: lst_Leads){
        if((l.Sales_Rep_Email__c!=null || l.Sales_Rep_Email__c!='') && l.Channel__c == 'Retail'){
            if(l.firstname!=null){
                l.company=l.firstname+' '+l.lastname;           
            }
            else{
                l.company=l.lastname;
            }
        }
      }
    }
    public static void trg_webtoleadAfterInsert(List<Lead> lst_Leads){
        Set<id> leadids=new Set<id>();
         Created_By__c devAccount =  Created_By__c.getValues('Created By Name');
         //user devAccount=[select id from user where name='Sunrun CRM' limit 1];
         for(lead l:lst_Leads){
          if((l.Sales_Rep_Email__c!=null || l.Sales_Rep_Email__c!='') && l.Channel__c == 'Retail'&&l.CreatedById==devAccount.User_ID__c){
                leadids.add(l.id);
            }
         }
         if(!leadids.isempty())
         Web2LeadOwnerUpdate.Web2LeadOwnerUpdate(leadids);
    }
    
    public static void trg_lead_after_delete (List<Lead> lst_Leads){
         List<Referral_Input__c> listReferrals = new List<Referral_Input__c>();
           Set<Id> setRefIds = new Set<Id>();
           for(Lead deletedLead:lst_Leads)
           {
              if(deletedLead.Referral_Input__c != null)
              {
                 setRefIds.add(deletedLead.Referral_Input__c);
              }
           }
           for(Referral_Input__c ri:[select id from Referral_Input__c where id in :setRefIds])
           {
              listReferrals.add(ri);
           }
           if(!listReferrals.isEmpty())
           {
              delete listReferrals;
           }
    }
  
    public static void trg_lead_zip_to_utility(List<Lead> lst_Leads,Map<id, Lead> map_oldLead){
        Set<String> zipcodeSet=new Set<String>();
        Map<String,ZipUtility__c> ZipUtilityMap=new Map<String,ziputility__c>();
        Map <String,Appointment_Territory__c> zipTerritorymap = new map <String,Appointment_Territory__c>();
        Map <String,Appointment_Territory__c> zipServiceTerritorymap = new map <String,Appointment_Territory__c>();
        
        set<String> clearValZipCodeSet = new set<String>();
        
        for(lead l:lst_Leads){ 
            if(l.channel__c=='3rd Party'){
            l.override_cdyne__c=true;   
            }
            if( system.isBatch() == false&&Trigger.isinsert && l.State != null && l.State != ''){ 
            l.State__c = l.State; 
            }         
            if( system.isBatch() == false&&Trigger.isUpdate && l.State != l.State__c){ 
            l.State__c = l.State; 
            }           
            if(l.postalcode!=null&&l.postalcode!=''&&l.PostalCode.length()>=5){
                if((Trigger.isinsert||Trigger.isupdate&&map_oldLead!=null&&map_oldLead.containskey(l.id)&&map_oldLead.get(l.id).postalcode!=l.postalcode)){                        
                    if(l.postalcode != null && l.postalcode.length() >= 5)
                        zipcodeSet.add(l.postalcode.substring(0,5));
                }                               
            }
        }       
        if(!zipcodeset.isempty()){
            Set<String> AccNameSet=new Set<String>();
            Map<String,Account> AccNameIdMap=new Map<String,Account>();
            for(ZipUtility__c z:[select Name,State__c,Sales_Branch__c,Install_Branch__c,Utility_Company__c,Territory__c,Zip_Code__c from ZipUtility__c where Zip_Code__c in:zipCodeSet]){
            ZipUtilityMap.put(z.zip_code__c,z);
            AccNameSet.add(z.Install_Branch__c);
            }
            for(Appointment_Territory__c tr : [Select Name,zip_code__c, Territory__c,category__c from Appointment_Territory__c where zip_code__c IN :zipCodeSet]){
                if(tr.category__c == 'Sales'){
                    zipTerritorymap.put(tr.zip_code__c,tr);
                }else if(tr.category__c == 'Service'){
                    zipServiceTerritorymap.put(tr.zip_code__c,tr);
                }
            }            

            if(!AccNameSet.isempty()){
                Id BranchRectypeId=Schema.SObjectType.Account.RecordTypeInfosByName.get('Branch').RecordTypeId;                 
                for(Account acc:[select id,name,site,Local_Branch_Constant__c,Over_Head_Per_Watt__c,Over_Head_Per_Project__c,Local_System_Size_Exponent__c,Parent.System_Size_Exponent__c,Parent.National_Branch_Constant__c,Parent.EPC_Adjustment__c from Account where site in:AccNameSet and RecordtypeId =:BranchRectypeId]){
                    if(acc.site != null){
                        AccNameIdMap.put(acc.site,acc);
                    }
                }               
                
            }
            
            for(lead l:lst_Leads){     
               if(l.postalcode!=null&&l.postalcode!=''&&(Trigger.isinsert||(Trigger.isupdate&&!checkRecursive.installBranchFactors.contains(l.id)))){
                    if(Trigger.isupdate){
                        checkRecursive.installBranchFactors.add(l.id);
                    }
//BSKY-4890 - Install Branch should be re-populated when Install Partner is updated to Sunrun                                       
                    ZipUtility__c objZipUtility = new ZipUtility__c();
                                       
                        if(l.postalcode != null && l.postalcode.length() >= 5 && ZipUtilityMap.containsKey(l.postalcode.substring(0,5))){
                            objZipUtility = ZipUtilityMap.get(l.postalcode.substring(0,5));
                            l.Install_Branch__c = objZipUtility.Install_Branch__c;
                            l.Sales_Branch__c = objZipUtility.Sales_Branch__c;
                            l.Zip_Utility__c = objZipUtility.Id;                           
                            
                        }
                        if(l.postalcode != null && l.postalcode.length() >= 5 && zipTerritorymap.containsKey(l.postalcode.substring(0,5))){
                            Appointment_Territory__c tr = zipTerritorymap.get(l.postalcode.substring(0,5));
                            l.Appointment_Territory__c = tr.Territory__c;       
                        }
                        if(l.postalcode != null && l.postalcode.length() >= 5 && zipServiceTerritorymap.containsKey(l.postalcode.substring(0,5))){
                            Appointment_Territory__c tr = zipServiceTerritorymap.get(l.postalcode.substring(0,5));
                            l.Appointment_Service_Territory__c = tr.Territory__c;       
                        }
                        
                        if(l.postalcode != null && l.postalcode.length() >= 5 &&  zipcodeset.contains(l.postalcode.substring(0,5)) && !ZipUtilityMap.containsKey(l.postalcode.substring(0,5))){
                        l.Install_Branch__c = null;
                        l.Sales_Branch__c = null;
                        }
                        if(AccNameIdMap.containsKey(l.Install_Branch__c) && AccNameIdMap.get(l.Install_Branch__c) != null){                             
                            
                            l.Install_Branch_Id__c = AccNameIdMap.get(l.Install_Branch__c).id;
                            
                            l.Local_Branch_Constant__c=AccNameIdMap.get(l.Install_Branch__c).Local_Branch_Constant__c;
                            l.Over_Head_Per_Watt__c=AccNameIdMap.get(l.Install_Branch__c).Over_Head_Per_Watt__c;
                            l.Over_Head_Per_Project__c=AccNameIdMap.get(l.Install_Branch__c).Over_Head_Per_Project__c;
                            l.Local_System_Size_Exponent__c=AccNameIdMap.get(l.Install_Branch__c).Local_System_Size_Exponent__c;
                            l.System_Size_Exponent__c = AccNameIdMap.get(l.Install_Branch__c).Parent.System_Size_Exponent__c;
                            l.National_Branch_Constant__c = AccNameIdMap.get(l.Install_Branch__c).Parent.National_Branch_Constant__c;
                            l.EPC_Adjustment__c = AccNameIdMap.get(l.Install_Branch__c).Parent.EPC_Adjustment__c;
                        }
                     /*   if(!AccNameIdMap.containsKey(l.Install_Branch__c) ){
                            clearLeadFields(l);
                        }  */                                  
                if(l.postalcode!=null&&l.postalcode!=''&&!system.isfuture()){                   
                    if( Trigger.isinsert||Trigger.isupdate&&map_oldLead!=null&&map_oldLead.containskey(l.id)
                        && map_oldLead.get(l.id).postalcode!=l.postalcode )
                    {                        
                        if(l.postalcode != null && l.postalcode.length() >= 5 && ZipUtilityMap.containsKey(l.postalcode.substring(0,5))){                   
                            
                            l.status='Created';
                            l.Lead_Status__c='Open';
                            if((Userinfo.getUserType()!='PowerPartner'&&l.channel__c!='Partner') && ZipUtilityMap.get(l.postalcode.substring(0,5)).Install_branch__c==Null)
                            { l.status='Out of Market';
                              l.Lead_Status__c=null;
                            }
                            if(   Trigger.isupdate||Trigger.isinsert&&l.utility_company__c==null
                               || UserInfo.getName()==label.MarketoProfileId 
                               || (UserInfo.getUserid()==label.SunRun_CRM&&l.channel__c!='Retail'))
                            {       
                                if(l.postalcode != null && l.postalcode.length() >= 5)
                                    l.Utility_Company__c=ZipUtilityMap.get(l.postalcode.substring(0,5)).utility_company__c;                   
                            }
                            
                            if(l.postalcode != null && l.postalcode.length() >= 5 && ZipUtilityMap.get(l.postalcode.substring(0,5)).Territory__c!=null&&(Trigger.isupdate||Trigger.isinsert&&l.Territory__c==null))
                                l.Territory__c=ZipUtilityMap.get(l.postalcode.substring(0,5)).Territory__c;                                                                                                                  
                            if(l.postalcode != null && l.postalcode.length() >= 5 && ZipUtilityMap.get(l.postalcode.substring(0,5)).state__c!=null) { 
                                l.state= ZipUtilityMap.get(l.postalcode.substring(0,5)).state__c;  
                            }                                                                               
                        }
                        else{
                            if((Userinfo.getUserType()!='PowerPartner'&&l.channel__c!='Partner')&&l.postalcode != null && l.postalcode.length() >= 5 && !ZipUtilityMap.containsKey(l.postalcode.substring(0,5))){    
                                l.status='Out of Market';
                                l.Lead_Status__c=null;
                                l.lock_assignment__c=true;
                                l.Utility_Company__c=null;
                                l.territory__c=null;
                                l.usage_option__c=null;
                                l.Zip_Utility__c=null;                              
                            }
                        }                       
                    }
                                         
                }
                if(Trigger.isinsert){
                      if(l.territory__c==null||l.territory__c=='')
                      l.territory__c='NA';
                      if((l.usage_option__c==null||l.usage_option__c=='')&&(l.Utility_Company__c!='Pacific Gas & Electric (PG&E)'&&l.Utility_Company__c!='SMUD'&&l.Utility_Company__c!='Southern California Edison (SCE)'&&l.Utility_Company__c!='San Diego Gas & Electric (SDG&E)'&&l.Utility_Company__c!='SCE'&&l.Utility_Company__c!='SDG&E'&&l.Utility_company__c!='PG&E'))
                      l.usage_option__c='NA';
              }
             }
            }            
        }
      if(trigger.isbefore&&Userinfo.getUserType()=='PowerPartner'){
      Set<string> zipSet=new Set<String>();
      Set<string> stateSet=new Set<String>();
      Set<String> zipcodesset=new set<String>();
      Set<String> zipplus4set=new set<String>();
      User u=[select id,contactid from user where id=:userinfo.getUserId()];
      Contact c=[select accountid,division,Contact_Division_Custom__c from contact where id=:u.contactid];
      Map<String,Market_Assignment__c> maMap=new Map<String,Market_Assignment__c>();  
      for(lead l:lst_Leads){
    if(l.PostalCode!=null&&l.Postalcode.length()>=5&&!checkRecursive.installPartnerLeadIds.contains(l.id)&&(Trigger.isinsert||(Trigger.isupdate&&(map_oldLead.get(l.id).postalcode!=l.postalcode||map_oldLead.get(l.id).utility_company__c!=l.utility_company__c)))){
      checkrecursive.installPartnerLeadIds.add(l.id);
      zipset.add(l.postalcode.substring(0,5));
      zipcodesset.add(l.postalcode.substring(0,5));
      if(Trigger.isupdate&&map_oldLead.get(l.id).postalcode!=null&&map_oldLead.get(l.id).postalcode.substring(0,5)!=l.postalcode.substring(0,5)){
      zipplus4set.add(l.PostalCode);
      }
      if(l.state!=null){
      stateset.add(l.state);
      zipcodesset.add(l.state);
      
      }
      }       
       for(market_assignment__c ma:[select market__r.utility_company__c,market__r.state__c,zipcodes__c,role__c,Select_All_Zipcodes__c,Territory__c,Partner__c,partner__r.Lead_Eligible__c from Market_Assignment__c where (start_date__c<=today and end_date__c>=today and role__c includes ('Sales') and partner__r.Lead_Eligible__c=true and partner__r.Active__c=true and partner__c=:c.accountid)or( start_date__c<=today and end_date__c>=today and role__c includes ('Sales') and partner__r.Lead_Eligible__c=true and partner__r.Active__c=true and market__r.state__c in:stateSet and partner__c=:c.accountid)  order by Select_All_Zipcodes__c nulls last]){
       for(string zip:zipcodesset){                    
                    if(!String.isempty(ma.Zipcodes__c)&&!String.isempty(zip)&&ma.Zipcodes__c.contains(zip.trim())){
                        maMap.put(zip+' '+ma.Market__r.state__c+' '+ma.Market__r.utility_company__c+' '+ma.partner__c,ma);
                    }
                    if(ma.Select_All_Zipcodes__c==true&&!String.isempty(ma.market__r.state__c)&&stateset.contains(ma.market__r.state__c)){
                       maMap.put(ma.Market__r.state__c+' '+ma.Market__r.utility_company__c+' '+ma.partner__c,ma);
                    }
                }  
      }    
      }
    if(!zipcodesset.isempty()){
    for(lead l:lst_Leads){
        if(!zipplus4set.isempty()){
        l.install_partner__c=null;
        l.Market_Assignment_Install__c=null;   
        l.Market_Assignment_Sales__c=null;
        }
        l.Sales_Partner__c=c.AccountId;
        if(c.Division == label.AEE_label){
          l.Install_partner__c = l.Sales_Partner__c;
        }
        if(l.PostalCode!=null&&l.PostalCode.length()>=5){
        if(maMap.containsKey(l.postalcode.substring(0,5)+' '+l.state+' '+l.utility_company__c+' '+c.accountid)){          
          l.Market_Assignment_Sales__c=maMap.get(l.postalcode.substring(0,5)+' '+l.state+' '+l.utility_company__c+' '+c.accountid).id;
          if(maMap.get(l.postalcode.substring(0,5)+' '+l.state+' '+l.utility_company__c+' '+c.accountid).role__c.contains('Install')){
          l.Install_Partner__c=maMap.get(l.postalcode.substring(0,5)+' '+l.state+' '+l.utility_company__c+' '+c.accountid).partner__c;
          l.Market_Assignment_Install__c=maMap.get(l.postalcode.substring(0,5)+' '+l.state+' '+l.utility_company__c+' '+c.accountid).id;  
          }                  
        }
        else if(l.state!=null&&maMap.containsKey(l.state+' '+l.utility_company__c+' '+c.accountid)){          
          l.Market_Assignment_Sales__c=maMap.get(l.state+' '+l.utility_company__c+' '+c.accountid).id;
          if(maMap.get(l.state+' '+l.utility_company__c+' '+c.accountid).role__c.contains('Install')){
          l.Install_Partner__c=maMap.get(l.state+' '+l.utility_company__c+' '+c.accountid).partner__c;
          l.Market_Assignment_Install__c=maMap.get(l.state+' '+l.utility_company__c+' '+c.accountid).id;  
          }                  
        }                 
        if(l.Install_Partner__c != null && l.Install_Partner__c != System.Label.Sunrun_Inc_Id){
         nullOutFactors.nullOutFactors(l);
         clearLeadFields(l);
         }
        }
        if(l.state!=null&&l.Market_Assignment_Sales__c==null){
        if(maMap.containsKey(l.state+' '+l.utility_company__c+' '+c.accountid)){          
          l.Market_Assignment_Sales__c=maMap.get(l.state+' '+l.utility_company__c+' '+c.accountid).id;
          if(maMap.get(l.state+' '+l.utility_company__c+' '+c.accountid).role__c.contains('Install')){
          l.Install_Partner__c=maMap.get(l.state+' '+l.utility_company__c+' '+c.accountid).partner__c;
          l.Market_Assignment_Install__c=maMap.get(l.state+' '+l.utility_company__c+' '+c.accountid).id;  
          }                  
        }
        if(l.Install_Partner__c != null && l.Install_Partner__c != System.Label.Sunrun_Inc_Id){
         nullOutFactors.nullOutFactors(l);
         clearLeadFields(l);
         }  
        }  
      
      }
          
    }
    
    }
    }
    
    public static void clearLeadFields(Lead l){            
        l.Install_Branch__c = null;
        l.Install_Branch_Id__c = null; 
        l.Local_Branch_Constant__c = null;
        l.Over_Head_Per_Watt__c = null;
        l.Over_Head_Per_Project__c=null;
        l.Local_System_Size_Exponent__c=null;
        l.System_Size_Exponent__c = null;
        l.National_Branch_Constant__c = null;
        l.EPC_Adjustment__c = null;
    }
      
    public static void trg_lead_bef_ins_upd_salesRepEmailPhone(List<Lead> lst_Leads,Map<id,Lead> oldMap){
        if(Userinfo.getUserType()!='PowerPartner'){
        Set<id> userids=new Set<id>();
        Map<String,Contact> contactMap=new Map<String,Contact>();
        for(lead l:lst_Leads){
            if((Trigger.isinsert&&l.SalesRep__c!=null)||(l.SalesRep__c!=null&&Trigger.isupdate&&oldMap.get(l.id).SalesRep__c!=l.SalesRep__c)){          
                    userids.add(l.SalesRep__c);         
            }
        }   
        if(!userids.isempty()){
            Set<String> emailSet=new Set<String>();
            for(User userObj:[select email from User where id in:userids]) {                
                emailSet.add(userObj.email);
            } 
            if(!emailSet.isempty()){  
            Id RectypeId=Schema.SObjectType.Contact.RecordTypeInfosByName.get('Residential').RecordTypeId;          
            for(contact c:[select id,email,phone,Department__c,Division__c,Sunrun_User__c from contact where email in:emailSet and recordtypeid!=:RectypeId]){
                contactMap.put(c.email,c);
            }
            }
            for(lead l:lst_Leads){
                if((Trigger.isinsert&&l.SalesRep__c!=null)||(l.SalesRep__c!=null&&Trigger.isupdate&&oldMap.get(l.id).SalesRep__c!=l.SalesRep__c)){      
                    if(contactMap.containskey(l.Sales_Rep_Email_2__c)){                      
                            l.Sales_Rep_Email__c=contactMap.get(l.Sales_Rep_Email_2__c).email;                                               
                            l.SalesCellPhone__c=contactMap.get(l.Sales_Rep_Email_2__c).phone;  
                            l.Sales_Rep_Division__c = contactMap.get(l.Sales_Rep_Email_2__c).Division__c;
                            l.Department__c = contactMap.get(l.Sales_Rep_Email_2__c).Department__c;
                                               
                    }       
                }
            }
        }
        }
     }
     public static void trg_bef_ins_FindSalesrep(List<Lead> lst_Leads){
        Set<String> emailSet=new Set<String>();
        List<Lead> ld_lst=new List<Lead>();
        for(lead l:lst_Leads){
            if(l.Sales_Rep_Email__c!=null){
                emailSet.add(l.Sales_Rep_Email__c);
                ld_lst.add(l);
            }
        }
        if(!emailSet.isempty()){
            Map<string,id> emailUserMap=new Map<String,id>();
            for(User u:[select id,email from user where email in:emailSet]){
                emailUserMap.put(u.email,u.id);
            }
            for(lead l:ld_lst){
                if(emailUserMap.containsKey(l.Sales_Rep_Email__c)){
                    l.salesrep__c=emailUserMap.get(l.Sales_Rep_Email__c);
                }
            }
        }
        
     }
     public static void trg_lead_bf_up_findMarketsManual(List<Lead> lst_Leads,Map<id,Lead> oldMap){
       if(Userinfo.getUserType()!='PowerPartner'){
         List<Lead> LdList=new List<lead>();
         Map<string,List<Lead>> zipCodeMap=new Map<string,List<Lead>>();
         Set<String> zipcodeset=new Set<String>();
         Set<String> stateset=new Set<String>();
         Set<id> salespartnerIds=new Set<id>();
         Set<id> installpartnerIds=new Set<id>();
         Set<String> utilitySet=new Set<String>();
                             
         for(lead l:lst_Leads){
           if(l.lock_assignment__c&&l.state!=null&&l.utility_company__c!=null&&oldMap.get(l.id).utility_company__c!=l.utility_company__c){
             if(l.Sales_Partner__c!=null){
             LdList.add(l);
             zipcodeset.add(l.postalcode);
             stateset.add(l.state);
             salespartnerIds.add(l.sales_partner__c);
             utilitySet.add(l.utility_company__c);
             }
             if(l.Install_Partner__c!=null){
             LdList.add(l);
             zipcodeset.add(l.postalcode);
             stateset.add(l.state);
             installpartnerIds.add(l.install_partner__c);
             utilitySet.add(l.utility_company__c);  
             }
           }
         }
         if(!LdList.isempty()&&!salespartnerIds.isempty()){
        Map<String,Market_Assignment__c> salesMAMap=FindMarketsManual.doFindSalesMarket( zipcodeset, stateset, salespartnerIds, utilitySet);        
        Map<String,Market_Assignment__c> installMAMap=FindMarketsManual.doFindInstallMarket( zipcodeset, stateset, installpartnerIds, utilitySet);
        for(lead l:lst_Leads){
          if(salesMAMap!=null&&salesMAMap.containsKey(l.sales_partner__c+l.utility_company__c+l.state)){
            l.Market_Assignment_Sales__c=salesMAMap.get(l.sales_partner__c+l.utility_company__c+l.state).id;
          }
          else{
            l.Market_Assignment_Sales__c.adderror('Sales Partner does not have a valid Market. Please contact your Lead Admin');
          }
          if(installMAMap!=null&&installMAMap.containsKey(l.install_partner__c+l.utility_company__c+l.state)){
            l.Market_Assignment_install__c=installMAMap.get(l.install_partner__c+l.utility_company__c+l.state).id;
          }
          else{
            l.Market_Assignment_install__c.adderror('Install Partner does not have a valid Market. Please contact your Lead Admin');
          }
        }
         }
       }
     }


    public static void LeadPromoCodePopulateBeforeInsert(List<Lead> lst_Leads){
    
    Default_Promotion_Code__c defPromo = Default_Promotion_Code__c.getValues('Referral Promo1');
    String promoCode = defPromo.Promotion_Code__c;

    Promotion__c DefaultCustPromo = [Select Id,Name from Promotion__c where Promotion_Code__c =: promoCode AND Primary_Promotion__c= True]; 
            
    Set<Id> PromotionIdsSet = new Set<Id>();   
    PromotionIdsSet.add(DefaultCustPromo.Id);     
   
    for(Lead ldtemp :lst_Leads){
                if(ldtemp.Promotion_Name__c != null){
                PromotionIdsSet.add(ldtemp.Promotion_Name__c);
                }
                
                if(ldtemp.Offer_Promo_Name__c != null){
                PromotionIdsSet.add(ldtemp.Offer_Promo_Name__c);
                }
                if(ldtemp.external_source__c!=null&&ldtemp.external_source__c=='Sunrun'){
                    ldtemp.lead_gen_partner__c=system.label.sunrun_inc_id;
                }
                if(ldtemp.salesrep__c!=null){
                    ldtemp.ownerid=ldtemp.salesrep__c;
                }
        }    
         
    Map<Id,Promotion__c> MapAllPromotions  = new Map<Id,Promotion__c>([Select id,Promotion_Code__c from Promotion__c where id in :PromotionIdsSet]);    
        for(Lead ldtemp :lst_Leads){
                if(ldtemp.Promotion_Name__c != null && MapAllPromotions != null && MapAllPromotions.containsKey(ldtemp.Promotion_Name__c))
                ldtemp.Promotion_Code__c = MapAllPromotions.get(ldtemp.Promotion_Name__c).Promotion_Code__c;

                if(ldtemp.Offer_Promo_Name__c != null && MapAllPromotions != null && MapAllPromotions.containsKey(ldtemp.Offer_Promo_Name__c))
                ldtemp.Offer_Promo_Code__c = MapAllPromotions.get(ldtemp.Offer_Promo_Name__c).Promotion_Code__c;
        
                if(ldtemp.Promotion_Name__c == null){
                if(DefaultCustPromo != null ){
                ldtemp.Promotion_Name__c = DefaultCustPromo.Id;
                ldtemp.Promotion_Code__c = promoCode;
                }
                /*
                if(ldtemp.Custom_Lead_Source__c!=null&&ldtemp.Custom_Lead_Source__c.containsIgnoreCase(System.label.Mickey_Account)){
                  ldtemp.Promotion_Name__c = null;
                  ldtemp.Promotion_Code__c = ' ';                  
                } */       
                }            
        }   
    } 
    
    public static void LeadPromoCodePopulateBeforeUpdate(List<Lead> lst_Leads,Map<id,Lead> oldMap){
    Default_Promotion_Code__c defPromo = Default_Promotion_Code__c.getValues('Referral Promo1');
    
    String promoCode;
    if(defPromo!=null)
    promoCode = defPromo.Promotion_Code__c;

    Promotion__c DefaultCustPromo;
    try{
    if(checkrecursive.runPromotionOnce())  
    DefaultCustPromo = [Select Id,Name from Promotion__c where Promotion_Code__c =: promoCode and Primary_Promotion__c=true]; 
    }
    catch(exception e){}
        if(DefaultCustPromo!=null){ 
        String DefaultCustPromoName = DefaultCustPromo.Name;
        Id DefaultCustPromoID = DefaultCustPromo.Id;
        }
        Set<Id> UpdatePromotionIdsSet = new Set<Id>();
        Set<Id> ReferralInputIdsDeleteSet = new Set<Id>();
        Set<Id> OfferIdsDeletedSet = new Set<Id>();       
        /*Map<String, Comcast_Referral_Promotions__c> comcastRefPromoMap = Comcast_Referral_Promotions__c.getAll();
        String refPromoCode;*/
    
        for(Lead ldtemp1 : lst_Leads){
              /* System.debug('ldtemp1.Promotion_Name__c1 :' +ldtemp1.Promotion_Name__c);
               refpromoCode = ldtemp1.Promotion_Name__c;
               if(ldtemp1.Custom_Lead_Source__c!=null && ldtemp1.Custom_Lead_Source__c.containsIgnoreCase(System.label.Mickey_Account) &&
                  oldMap.containsKey(ldtemp1.id) && oldMap.get(ldtemp1.id).Custom_Lead_Source__c != ldtemp1.Custom_Lead_Source__c &&
                  ldtemp1.Promotion_Name__c != null && !comcastRefPromoMap.containsKey(refPromoCode.substring(0,15))){
                  ldtemp1.Promotion_Name__c = null; 
                  ldtemp1.Promotion_Code__c = ' '; 
               }*/
               if(ldtemp1.Offer_Promo_Name__c != null){
                UpdatePromotionIdsSet.add(ldtemp1.Offer_Promo_Name__c);
                }
            
                if(ldtemp1.Promotion_Name__c != null) {
                UpdatePromotionIdsSet.add(ldtemp1.Promotion_Name__c);
                } 
                if(ldtemp1.salesrep__c!=null&&oldMap.get(ldtemp1.id).salesrep__c!=ldtemp1.salesrep__c){
                ldtemp1.ownerid=ldtemp1.salesrep__c;    
                }          
                /*
                if(ldtemp1.Offer_Promo_Name__c == null && ldtemp1.Offer__c != null) {
                OfferIdsDeletedSet.add(ldtemp1.Offer__c);
                }
            
                if(ldtemp1.Promotion_Name__c == null && ldtemp1.Referral_Input__c != null) {
                ReferralInputIdsDeleteSet.add(ldtemp1.Referral_Input__c); 
                }                       
        List<Offer__c> OfferIdsDeletedList =new List<Offer__c>();
        if(!OfferIdsDeletedSet.isempty()){
        OfferIdsDeletedList = [SELECT Id FROM Offer__c WHERE id in :OfferIdsDeletedSet];
        }
        List<Referral_Input__c> ReferralInputDeletedList =new List<Referral_input__c>();
        if(!ReferralInputIdsDeleteSet.isempty()){
        ReferralInputDeletedList = [SELECT Id FROM Referral_Input__c WHERE id in :ReferralInputIdsDeleteSet];  
        }
        if(OfferIdsDeletedList.size() > 0){delete OfferIdsDeletedList;}
        if(ReferralInputDeletedList.size() > 0){delete ReferralInputDeletedList;}    
        */         
        }        
        Map<Id,Promotion__c> MapAllPromotions  = new Map<Id,Promotion__c>([Select id,Promotion_Code__c from Promotion__c where id in :UpdatePromotionIdsSet]);                       
        Set<Id> ReferralInputIdsUpdateSet = new Set<Id>();
        Set<Id> OfferIdsUpdateSet = new Set<Id>();
        Map<Id,Promotion__c> MapAllOffers = new Map<Id,Promotion__c>();
        Map<Id,Promotion__c> MapAllReferral = new Map<Id,Promotion__c>();
                  
        for(Lead ldtemp2 : lst_Leads){
               if(ldtemp2.Offer_Promo_Name__c != null && ldtemp2.Offer_Promo_Name__c != oldMap.get(ldtemp2.id).Offer_Promo_Name__c && MapAllPromotions != null && MapAllPromotions.containsKey(ldtemp2.Offer_Promo_Name__c)){
               ldtemp2.Offer_Promo_Code__c = MapAllPromotions.get(ldtemp2.Offer_Promo_Name__c).Promotion_Code__c;
               
               if(ldtemp2.Offer__c != null)
               OfferIdsUpdateSet.add(ldtemp2.Offer__c);
               MapAllOffers.put(ldtemp2.Offer__c,MapAllPromotions.get(ldtemp2.Offer_Promo_Name__c));
             
               }
            
               if(ldtemp2.Promotion_Name__c != null && ldtemp2.Promotion_Name__c != oldMap.get(ldtemp2.id).Promotion_Name__c && MapAllPromotions != null && MapAllPromotions.containsKey(ldtemp2.Promotion_Name__c)){
               ldtemp2.Promotion_Code__c = MapAllPromotions.get(ldtemp2.Promotion_Name__c).Promotion_Code__c; 
               
               if(ldtemp2.Referral_Input__c != null)
               ReferralInputIdsUpdateSet.add(ldtemp2.Referral_Input__c);    
               MapAllReferral.put(ldtemp2.Referral_Input__c,MapAllPromotions.get(ldtemp2.Promotion_Name__c));
              
               }
               /*
               if(ldtemp2.Offer_Promo_Name__c == null){
               ldtemp2.Offer_Promo_Name__c = null;
               ldtemp2.Offer_Promo_Code__c = null;
               ldtemp2.Offer__c = null;  
               ldtemp2.Referred_by_Contact_First_Name__c = null;
               ldtemp2.Referred_by_Contact_Last_Name__c = null;
               ldtemp2.Referred_by_Contact_Phone__c = null;
               ldtemp2.Referred_by_Contact_Email__c = null;
               ldtemp2.Referred_by__c = null;
               }       
                       
               if(ldtemp2.Promotion_Name__c == null){
               ldtemp2.Promotion_Code__c = null;
               ldtemp2.Referred_By_Contact__c = null;
               ldtemp2.Sales_rep_of_referrer__c = null; 
               ldtemp2.Referral_Input__c = null;   
               } 
               */      
        }
        
        List<Offer__c> OfferIdsUpdateList =new List<Offer__c>();
        if(!OfferIdsUpdateSet.isempty()){
        OfferIdsUpdateList =[SELECT Id FROM Offer__c WHERE id in :OfferIdsUpdateSet];
        }
        List<Referral_Input__c> ReferralInputUpdateList = new List<Referral_input__c>();
        if(!ReferralInputIdsUpdateSet.isempty()){
        ReferralInputUpdateList =[SELECT Id FROM Referral_Input__c WHERE id in :ReferralInputIdsUpdateSet];  
        }
    
        for(Offer__c tempoffer:OfferIdsUpdateList){
               tempoffer.Promotion__c = MapAllOffers.get(tempoffer.id).Id;
        }
        if(!OfferIdsUpdateList.isempty())
        update OfferIdsUpdateList;
    
        for(Referral_Input__c tempref:ReferralInputUpdateList){
               tempref.Promotion__c = MapAllReferral.get(tempref.id).Id;
        }
        if(!ReferralInputUpdateList.isempty())
        update ReferralInputUpdateList;
    } 

//Mickey 
       public static void ProcessMickeyLeads(List<Lead> lst_Leads, Map<id, Lead> map_oldLead) {
              //Account MickeyAcct;
              //if(!test.isrunningtest() && Userinfo.getUserType()!='PowerPartner'){
              //  MickeyAcct = [Select Id, Name from Account where Name = :System.label.Mickey_Account Limit 1];
              //}
              Set<Id> leadIdSet = new set<Id>();
              Map<id,String> leadFive9DNIS=new Map<id,String>();
       
              for(Lead l: lst_Leads){          
                  if(l.Custom_Lead_Source__c!=null&&l.Custom_Lead_Source__c.containsIgnoreCase(System.label.Mickey_Account)&&
                    !l.Custom_Lead_Source__c.equalsIgnoreCase('Co-Marketing: LGCY-Comcast')) {
                    l.Synchronous_Assignment__c = true;
                    if(!test.isrunningtest() && Userinfo.getUserType()!='PowerPartner'){  
                      //l.Lead_Gen_Partner__c = MickeyAcct.Id;
                      l.Lead_Gen_Partner__c = System.label.Comcast_Account_Id;
                    }
                    if(l.External_Source__c != null && !l.External_Source__c.containsIgnoreCase('Comcast_Lead')){
                      l.External_Source__c = System.label.Mickey_Account; 
                    }
                    leadIdSet.add(l.Id);  
                    //System.debug('Adding Lead :' +l.Id);
                  }else if(!map_oldLead.isEmpty() && map_oldLead.containsKey(l.id) && map_oldLead.get(l.id).External_Source__c == System.label.Mickey_Account){
                       l.External_Source__c = ' ';
                  }    //if 
               }   //for
              
              //System.debug('leadIdSet :' +leadIdSet);
             if(!leadIdSet.isEmpty())
             {
              for(task t:[select id,whoid,Five9__Five9DNIS__c from task where whoid in:leadIdSet and CallType = 'Inbound' order by createddate])
              {
                  if(!leadFive9DNIS.containsKey(t.whoid))
                  {
                     if(t.Five9__Five9DNIS__c != null){
                        leadFive9DNIS.put(t.whoid,t.Five9__Five9DNIS__c);
                        //System.debug('Adding Lead :' +t.whoid+ 'Five9DNIS :' +t.Five9__Five9DNIS__c);
                     }
                  }
              } 
             }
             //System.debug('leadFive9DNIS :' +leadFive9DNIS);   
             for(Lead l: lst_Leads){ 
                //System.debug('Content__c :' +l.Content__c); 
                //System.debug('l.Id :' +l.Id);
                if(l.Content__c == null || l.Content__c == ' '){
                   l.Content__c = leadFive9DNIS.get(l.Id);
                   //System.debug('Updating Content :' +l.Content__c); 

                }
             } 
        }
   public static void PopulateChannelLeadSourceForPPLeads(List<Lead> leadList){
        for(Lead oLead : leadList){
            if(Userinfo.getUserType()=='PowerPartner'){
                oLead.Channel__c = 'Partner';
                
              if(oLead.Sales_Partner__c == Label.SalesPartnerAccLGCY){
                oLead.Custom_Lead_Source__c = 'Partner: Legacy';
              }
              else if(oLead.Sales_Partner__c == Label.SalesPartnerAccGenSun){
                oLead.Custom_Lead_Source__c = 'Partner: Generation Sun';
              }
              else if(oLead.Sales_Partner__c == Label.SalesPartnerAccFluent){
                oLead.Custom_Lead_Source__c = 'Partner: Fluent';
              }
              else if(oLead.Sales_Partner__c == Label.SalesPartnerAccRedVentures){
                oLead.Custom_Lead_Source__c = 'Partner: Red Ventures';
              }
              else
              {
                oLead.Custom_Lead_Source__c = 'Sales Partner';
              }
            }
        }
    }
    
    public static void ProcessRetailLeads(List<Lead> lst_Leads, Map<id, Lead> map_oldLead) {
         for(Lead l: lst_Leads){  
            if(l.Custom_Lead_Source__c!=null && l.Custom_Lead_Source__c.containsIgnoreCase(System.label.Costco)) { 
                 l.Purchased_Thru__c = System.label.Costco; 
            }
            else if(l.Technology_Last__c!=null && l.Technology_Last__c.equalsIgnoreCase('BrightPath Mobile')){
                 return;
            }
            else{
                l.Purchased_Thru__c = ' ';
            }
         } 
    }
   public static void doReferralStagesUpdate(list<Lead> list_Lead,Map<id,Lead> old_Map){
      Set<id> closedLostIds=new Set<id>();
      Set<id> convertedIds=new Set<id>();
      for(lead l:list_Lead){
        if(l.Referral_Input__c!=null){
          if(l.status=='Closed Lost'&&old_Map.get(l.id).status!=l.status){
            closedLostIds.add(l.id);
          }
          else if(l.isconverted){
            convertedIds.add(l.id);
          }
        }
      }
      if(!closedLostIds.isempty()){
        RefferalStagesChanges.updateReferralStatus(closedLostIds,'Not Ready for Solar Now','Lead__c');
      }
      else if(!convertedIds.isempty()){
        RefferalStagesChanges.updateReferralStatus(convertedIds,'Solar Consultation In-Progress','Lead__c');
      }
    } 
    
  public static void doFieldMarketingBranch(List<Lead> lst_leads,Map<id,Lead> oldMap,Boolean isinsert,Boolean isupdate){
    Map<id,Lead> leadGeneratedByLeadMap=new Map<id,Lead>();
    for(Lead leadObj:lst_leads){
        if(isinsert||(isupdate&&oldMap.get(leadObj.id).lead_generated_by__c!=leadObj.lead_generated_by__c)){
            leadGeneratedByLeadMap.put(leadObj.lead_generated_by__c,leadObj);
        }
    }
    if(!leadGeneratedByLeadMap.isempty()){
        Map<id,String> userFMBMap=new Map<id,String>();
        for(User userObj:[select id,Field_marketing_team__c from user where id in:leadGeneratedByLeadMap.keyset()]){
            userFMBMap.put(userObj.id,userObj.Field_marketing_team__c);
        }
        for(lead l:leadGeneratedByLeadMap.values()){
            if(userFMBMap.containsKey(l.lead_generated_by__c)){
                l.field_marketing_branch__c=userFMBMap.get(l.lead_generated_by__c);
            }
        }
    }
  }  
          
  public static void ProcessCostcoLead(List<Lead> lst_Leads) 
   {
        Map<Id,String> AcntIDAndNameMap = New Map<Id,String>();
        Set<Id> SetAcntId = New Set<Id>();
        List<Lead> ListLead = New List<Lead>();
        system.debug('This is Lead Id :'+ lst_Leads);
        
         for(Lead l: lst_Leads)
         {  
              if(l.Purchased_Thru__c!=null && l.Purchased_Thru__c!='' && l.Purchased_Thru__c.Contains('Costco'))
              {
                  SetAcntId.add(l.Lead_Organization_Location_2__c);
                  ListLead.add(l);
              } 
         }    
         if(!SetAcntId.isEmpty())
         {  
              for(Account acc: [select id, name from account where id in : SetAcntId])
              {
                AcntIDAndNameMap.put(acc.id,acc.name);
                System.debug('this is key :'+ AcntIDAndNameMap.keySet());    
                System.debug('this is value :'+ AcntIDAndNameMap.values());    
              }    
          }  
        
      If(!AcntIDAndNameMap.isEmpty())
      {   
        for(Lead NewLead: ListLead)
        {
           // system.debug('this contains:'+ AcntIDAndNameMap.get(NewLead.Lead_Organization_Location_2__c).contains('Costco'));
           if(AcntIDAndNameMap.containsKey(NewLead.Lead_Organization_Location_2__c))
           {    
             If(!AcntIDAndNameMap.get(NewLead.Lead_Organization_Location_2__c).contains('Costco'))
            {
                NewLead.Lead_Organization_Location_2__c.adderror('Please enter a Costco store location only');
            }
           }    
         }   
      }
    }    
     // Public static void NotifyReferee(List<Lead> lst_Leads)
  Public static void NotifyReferee(Map<id, Lead> map_oldLead, List<Lead> lst_newLead, Boolean isInsert, Boolean isUpdate)    
    {
    //  System.debug('Before AllowAfterEmailTriggerFlag : ' +controlContactTriggerRecursion.AllowAfterEmailTriggerFlag);
      System.debug('map_oldLead : ' +map_oldLead); 
      System.debug('lst_newLead : ' +lst_newLead);
    //  if(controlContactTriggerRecursion.AllowAfterEmailTriggerFlag)
    //  {     
    //    controlContactTriggerRecursion.AllowAfterEmailTriggerFlag = False;  
    //    System.debug('After AllowAfterEmailTriggerFlag : ' +controlContactTriggerRecursion.AllowAfterEmailTriggerFlag);
        List<Lead> ListofReferralLeads = new List<Lead>();
        Set<Id> SetofReferralLeadIds = new Set<Id>();
        Map<Id, string> MapofLeadIdandEmail = new Map<Id, String>();
        map<Id,map<String,String>> LeadWhereClauseFieldValueMap = new map<Id,map<String,String>>();
        map<String,String> whereClauseFieldValueMap = new map<String,String>();
        map<Id,String> LeadSourceTypeMap = new map<Id,String>();
        map<Id,List<Id>> LeadToRecipientListMap = new map<Id,List<Id>>();
        map<Id,List<String>> LeadCCRecipientMap = new map<Id,List<String>>();
        List<Lead> ListOfEmailSentLeadsToUpd = New List<Lead>();
       
        for(Lead NewLead :lst_newLead)
        {    
            System.debug('---this is NewLead--- :'+ NewLead);
            System.debug('isInsert : ' +isInsert); 
            System.debug('isUpdate : ' +isUpdate); 
        //    System.debug('---this is OldLead ReferredByCont--- :'+ map_oldLead.get(NewLead.Id).Referred_By_Contact__c);
            System.debug('---this is NewLead ReferredByCont--- :'+ NewLead.Referred_By_Contact__c);

           if(
                (newLead.Referred_By_Contact__c != null && newLead.email!= null && isInsert)
             || (isUpdate && map_oldLead.get(newLead.Id).Referred_By_Contact__c == null && newLead.Referred_By_Contact__c !=  null && newLead.email!= null)
             &&!checkRecursive.AmbassadorReferralLeadIds.contains(newLead.id)  
             && NewLead.Lead_Division_Custom__c != label.AEE_label
             )  
          //   If(NewLead.Email!=null && NewLead.Referee_Email_Sent__c==False && NewLead.Referred_By_Contact__c!=null && NewLead.Channel__c!=null && NewLead.Channel__c!='' && NewLead.Channel__c.contains('Referral') && (!checkRecursive.AmbassadorReferralLeadIds.contains(NewLead.id)))
          //  If(isUpdate && NewLead.Email!=null && map_oldLead.get(NewLead.Id).Referred_By_Contact__c==Null && NewLead.Referred_By_Contact__c!=null && NewLead.Channel__c!=null && NewLead.Channel__c!='' && NewLead.Channel__c.contains('Referral') && (!checkRecursive.AmbassadorReferralLeadIds.contains(NewLead.id)))
            {
                checkRecursive.AmbassadorReferralLeadIds.add(NewLead.id);
                ListofReferralLeads.add(NewLead);
                SetofReferralLeadIds.add(NewLead.Id);
                System.debug('This is List of Lead IDs : ' + SetofReferralLeadIds);
                          
            }
        }  
        if(!SetofReferralLeadIds.IsEmpty())
            {
               if(!ListofReferralLeads.isEmpty()) 
               {
             //   LeadSourceTypeMap = getLeadSourceType(ListofReferralLeads);
                LeadToRecipientListMap = getToRecipientList(ListofReferralLeads);
            //  LeadCCRecipientMap = getLeadCCRecipientMap(sceList, sceSalesPartnerGenericEmailMap); 
                LeadWhereClauseFieldValueMap = getLeadWhereClauseFieldValue(ListofReferralLeads);
             
                for(Id LeadId: SetofReferralLeadIds)
                { 
                          System.debug('This is recipientList :' +LeadToRecipientListMap.get(LeadId));
                      //  System.debug('CCList : ' +sceCCRecipientMap.get(sceId));
                          System.debug('This is WhereClause :' +LeadWhereClauseFieldValueMap.get(LeadId));
                        CustomEmailManager.communicateScheduledEvent(LeadWhereClauseFieldValueMap.get(LeadId), 
                                                                     'Referee Email', LeadToRecipientListMap.get(LeadId),null,
                                                                     'The Sunrun Team' , 'info@sunrunhome.com','info@sunrunhome.com');
                } 
             /*   for(Lead EmailSentLead:[Select Id,Referee_Email_Sent__c from Lead where Id in :SetofReferralLeadIds]) 
                {
                    EmailSentLead.Referee_Email_Sent__c=True;
                    ListOfEmailSentLeadsToUpd.add(EmailSentLead);
                }
                   If(!ListOfEmailSentLeadsToUpd.isEmpty())
                     Update ListOfEmailSentLeadsToUpd;  */
               }
            }
    //  }
    } 
    private static map<Id,List<Id>> getToRecipientList(List<Lead> ListofReferralLeads)
    {
        Set<Id> LeadIdSet = new Set<Id>(); 
        List<Id> recipientList = new List<Id>(); 
        List<Id> tempRecipientList = new List<Id>();
        map<Id,List<Id>> LeadToRecipientListMap = new map<Id,List<Id>>();
        
        for(Lead olead: ListofReferralLeads)
        {
            if (olead.Custom_Lead_Source__c!= null && oLead.Channel__c.contains('Referral'))
            {
               recipientList.add(olead.Id);
            }   
              
            tempRecipientList = recipientList.clone();  
            LeadToRecipientListMap.put(olead.id,tempRecipientList);
            recipientList.clear();
        }    
        
        return LeadToRecipientListMap;
    }
    
    private static map<Id, map<String,String>> getLeadWhereClauseFieldValue(List<Lead> ListofReferralLeads)
    {
        map<Id,map<String,String>> LeadWhereClauseFieldValueMap = new map<Id,map<String,String>>();
        map<String,String> whereClauseFieldValueMap = new map<String,String>(); 
        map<String,String> TempwhereClauseFieldValueMap = new map<String,String>();
        List<Id> recipientList = new List<Id>(); 
        List<Id> tempRecipientList = new List<Id>();
        String LeadId;
        String TempLeadId;
       
        for(Lead oLead: ListofReferralLeads)
        {
            whereClauseFieldValueMap.put('id', oLead.id);
            TempwhereClauseFieldValueMap = whereClauseFieldValueMap.clone();
            LeadWhereClauseFieldValueMap.put(oLead.id,TempwhereClauseFieldValueMap);
            whereClauseFieldValueMap.clear();
 
        }    
         
        return LeadWhereClauseFieldValueMap;
    } 
 //adding logic to update lead information based inContact data
    public static void updateInContactInfoOnLead(Map<id, Lead> map_oldLead, List<Lead> lst_newLead, Boolean isInsert, Boolean isUpdate){
        Set<String> channelSet =  new Set<String>();
        
        for(lead leadObj : lst_newLead){
            channelSet.add(leadObj.Channel__c);
        }
        system.debug('channelSet>>'  + channelSet);
        Map<Id,InContact_Lead_Management__c> clmMap = new Map<Id,InContact_Lead_Management__c>
            ([select Id,Call_Center__c ,Campaign_Call_Attempts_c__c,Channel__c,
              Dail_Status__c,Lead_Type__c,Priority__c,To_Stage__c,To_Status__c,Stage__c,
              Wait__c,Caller_Id__c,Voicemail__c,Use_API__c from InContact_Lead_Management__c where Channel__c in:channelSet] );
        
        List<Lead> LeadList = new  List<Lead>();
        list<Lead> leadAPIList = new  list<Lead>();
        if(!clmMap.isEmpty() && !lst_newLead.isEmpty() ){
            for(lead lead: lst_newLead){
                if(IsInsert || (IsUpdate && (lead.Call_Center__c!= map_oldLead.get(lead.Id).Call_Center__c 
                                             || lead.Campaign_Call_Attempts__c!=map_oldLead.get(lead.Id).Campaign_Call_Attempts__c
                                             || lead.Channel__c !=map_oldLead.get(lead.Id).Channel__c
                                             || lead.Lead_Status__c!=map_oldLead.get(lead.Id).Lead_Status__c
                                             || lead.Status!=map_oldLead.get(lead.Id).Status
                                             || lead.Lead_Type__c!=map_oldLead.get(lead.Id).Lead_Type__c
                                             || lead.Callback_Disposition__c!=map_oldLead.get(lead.Id).Callback_Disposition__c))){
                                                 for(Id key :clmMap.keySet()){
                                                     if(clmMap.get(key).Channel__c == lead.Channel__c 
                                                        && clmMap.get(key).Lead_Type__c == lead.Lead_Type__c
                                                        && clmMap.get(key).Campaign_Call_Attempts_c__c == lead.Campaign_Call_Attempts__c
                                                        && clmMap.get(key).Stage__c == lead.Status){
                                                            system.debug('clmmap>>' + clmMap);
                                                            system.debug('isUpdate' +  IsUpdate);
                                                            If(IsUpdate){ 
                                                                if(clmMap.get(key).Use_API__c!=true){
                                                                    lead.inContact_Priority__c = clmMap.get(key).Priority__c;
                                                                    if(clmMap.get(key).Wait__c!=null){
                                                                        lead.Future_Contact_Date_Time__c  = system.Datetime.now().addMinutes(Integer.valueof(clmMap.get(key).Wait__c));
                                                                    } else{
                                                                        lead.Future_Contact_Date_Time__c=null;
                                                                    }
                                                                    lead.Call_Center__c=clmMap.get(key).Call_Center__c;
                                                                    lead.Status= clmMap.get(key).To_Stage__c;
                                                                    lead.Voicemail__c= clmMap.get(key).Voicemail__c;
                                                                    lead.Caller_Id__c= clmMap.get(key).Caller_Id__c;
                                                                    lead.Lead_Status__c= clmMap.get(key).To_Status__c;
                                                                    system.debug('leadlead>'+ lead);
                                                                    lead.Dial_Status__c=clmMap.get(key).Dail_Status__c; 
                                                                    lead.Lead_Type__c=clmMap.get(key).Lead_Type__c;
                                                                }
                                                                if(clmMap.get(key).Use_API__c==true){
                                                                    lead.inContact_Priority__c = clmMap.get(key).Priority__c;
                                                                    if(clmMap.get(key).Wait__c!=null){
                                                                        lead.Future_Contact_Date_Time__c  = system.Datetime.now().addMinutes(Integer.valueof(clmMap.get(key).Wait__c));
                                                                    } else{
                                                                        lead.Future_Contact_Date_Time__c=null;
                                                                    }
                                                                    lead.Call_Center__c=clmMap.get(key).Call_Center__c;
                                                                    lead.Status= clmMap.get(key).To_Stage__c;
                                                                    lead.Voicemail__c= clmMap.get(key).Voicemail__c;
                                                                    lead.Caller_Id__c= clmMap.get(key).Caller_Id__c;
                                                                    lead.Lead_Status__c= clmMap.get(key).To_Status__c;
                                                                    system.debug('leadlead>'+ lead);
                                                                    lead.Dial_Status__c=clmMap.get(key).Dail_Status__c; 
                                                                    lead.Lead_Type__c=clmMap.get(key).Lead_Type__c;
                                                                    leadAPIList.add(lead);
                                                                }
                                                                
                                                            }
                                                            else If (IsInsert){
                                                                Lead newlead = new Lead();       
                                                                if(clmMap.get(key).Use_API__c!=true){ 
                                                                    newlead.inContact_Priority__c = clmMap.get(key).Priority__c;
                                                                    if(clmMap.get(key).Wait__c!=null){
                                                                        newlead.Future_Contact_Date_Time__c  = system.Datetime.now().addMinutes(Integer.valueof(clmMap.get(key).Wait__c));
                                                                    } else{
                                                                        newlead.Future_Contact_Date_Time__c=null;
                                                                    }
                                                                    newlead.Call_Center__c=clmMap.get(key).Call_Center__c;
                                                                    newlead.Status= clmMap.get(key).To_Stage__c;
                                                                    newlead.Voicemail__c= clmMap.get(key).Voicemail__c;
                                                                    newlead.Caller_Id__c= clmMap.get(key).Caller_Id__c;
                                                                    newlead.Lead_Status__c= clmMap.get(key).To_Status__c;
                                                                    newlead.Dial_Status__c=clmMap.get(key).Dail_Status__c; 
                                                                    newlead.Lead_Type__c=clmMap.get(key).Lead_Type__c;
                                                                    newlead.Id= lead.Id;
                                                                    newlead.LastName= lead.LastName;
                                                                    newlead.FirstName=lead.FirstName;
                                                                    newlead.State=lead.State;
                                                                    newlead.phone =  lead.Phone;
                                                                    newlead.Custom_Lead_Source__c =  lead.Custom_Lead_Source__c;
                                                                    newlead.PostalCode=lead.PostalCode;
                                                                    newlead.Campaign_Call_Attempts__c= lead.Campaign_Call_Attempts__c;
                                                                    LeadList.add(newlead);
                                                                } 
                                                                else{
                                                                    newlead.inContact_Priority__c = clmMap.get(key).Priority__c;
                                                                    if(clmMap.get(key).Wait__c!=null){
                                                                        newlead.Future_Contact_Date_Time__c  = system.Datetime.now().addMinutes(Integer.valueof(clmMap.get(key).Wait__c));
                                                                    } else{
                                                                        newlead.Future_Contact_Date_Time__c=null;
                                                                    }
                                                                    newlead.Call_Center__c=clmMap.get(key).Call_Center__c;
                                                                    newlead.Status= clmMap.get(key).To_Stage__c;
                                                                    newlead.Voicemail__c= clmMap.get(key).Voicemail__c;
                                                                    newlead.Caller_Id__c= clmMap.get(key).Caller_Id__c;
                                                                    newlead.Lead_Status__c= clmMap.get(key).To_Status__c;
                                                                    newlead.Dial_Status__c=clmMap.get(key).Dail_Status__c; 
                                                                    newlead.Lead_Type__c=clmMap.get(key).Lead_Type__c;
                                                                    newlead.Id= lead.Id;
                                                                    newlead.LastName= lead.LastName;
                                                                    newlead.FirstName=lead.FirstName;
                                                                    newlead.State=lead.State;
                                                                    newlead.phone =  lead.Phone;
                                                                    newlead.Custom_Lead_Source__c =  lead.Custom_Lead_Source__c;
                                                                    newlead.PostalCode=lead.PostalCode;
                                                                    newlead.Campaign_Call_Attempts__c= lead.Campaign_Call_Attempts__c;
                                                                    leadAPIList.add(newlead);
                                                                }
                                                                
                                                            }
                                                            
                                                        } 
                                                 }   
                                             }
            }
        }
        
        if(!LeadList.isEmpty()){
            update LeadList;
        }
        system.debug('leadList' +  leadAPIList);
        if(!leadAPIList.isEmpty() && IsInsert){
            update leadAPIList;
        }
        
        if(!leadAPIList.isEmpty()){
            
            InContactAPIUtilityManager.InContactLeadInfo(leadAPIList);
        }
        
    }
    
}