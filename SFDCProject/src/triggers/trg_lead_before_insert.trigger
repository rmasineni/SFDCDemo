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
trigger trg_lead_before_insert on Lead (before insert, before update) {
/*
    List<Lead> listNewChangedLeads = new List<Lead>();  
    //
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
    
    for(Lead newlead:Trigger.New)
    {
        // If new or if updating a lead that is not auto-unqualified, populate sets for comparison.
        if(newlead.LastName != '' && newlead.LastName != null &&
          ((Trigger.isUpdate && !newlead.Auto_Unqualified__c && isKeyFieldChanged(newlead))
            || Trigger.isInsert))
        {           
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
        }
        
        //Verify Contact number
        if(newlead.Prospect_Id__c == null || newlead.Prospect_Id__c == ''){
            size++;
        } 
        Notes__c noteobj = new Notes__c();
        
        if(Trigger.isInsert && newLead.State != null && newLead.State != ''){
            newLead.State__c = newLead.State;
        }
        
        if(Trigger.isUpdate && newLead.State != newLead.State__c){
          newLead.State__c = newLead.State;
        }
        
        if(Trigger.isUpdate || Trigger.isInsert){

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
        for(Lead existingLeads:[select id, email, lastname, Referred_by__c, phone 
                              from Lead 
                             where Id not in :setLeadIds
                               and Why_Unqualified__c != :Label.Lead_Why_Unqualified_DuplicateLeadFound 
                               and Why_Unqualified__c != :Label.Lead_Why_Unqualified_DuplicateOpptyFound
                               and Why_Unqualified__c != :Label.Lead_Why_Unqualified_SalesDeterminedDuplicate
                               and Lead_Status__c != 'Converted'                             
                               and lastname in :setLeadlastNames
                               and (email in :setLeadEmails or phone in :setLeadPhones)])
        {
            if(existingLeads.email != null && existingLeads.email != '')
            {
               setExistingLeadKey.add(existingLeads.email + existingLeads.lastname);
            }
            if(existingLeads.phone != null && existingLeads.phone != '')
            {
               setExistingLeadKey.add(existingLeads.phone + existingLeads.lastname);
            }
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
    
    for(Lead newlead: Trigger.New)
    {
        if((counter < size) && (newlead.Prospect_Id__c == null || newlead.Prospect_Id__c == '')){
            newlead.Prospect_Id__c = randomNumners[counter];
            counter++;
        }
        
        // Set to non-duplicate if duplicate, then recheck to determine if it is STILL a duplicate
        // This allows us to set a lead as non-duplicate, if attributes have change to determine it is no longer a dupe.
        if(   Trigger.isUpdate 
           && isKeyFieldChanged(newLead)
           && newLead.Lead_Status__c  == Label.Lead_Status_Duplicate 
           && (newLead.Why_Unqualified__c == Label.Lead_Why_Unqualified_DuplicateLeadFound
               || newLead.Why_Unqualified__c == Label.Lead_Why_Unqualified_DuplicateOpptyFound)
           &&
           (((Label.LeadDeDupeMethod == 'Account' || System.Userinfo.getUserName() == 'SunRunTestRunner@testorg.com')
             && !isDuplicateLead(newLead.Street + newLead.City + newLead.State + newLead.PostalCode + newLead.Country)
             && !isDuplicateLead(newLead.Zip_6__c)
             && !isDuplicateOppty(newLead.Street + newLead.City + newLead.State + newLead.PostalCode + newLead.Country)
             && !isDuplicateOppty(newLead.Zip_6__c)
             )
             || ((Label.LeadDeDupeMethod == 'Contact' 
                  && !isDuplicateLead(newLead.Email + newLead.LastName)
                  && !isDuplicateLead(newLead.Phone + newLead.LastName)
                  && !isDuplicateOppty(newLead.Email + newLead.LastName)
                  && !isDuplicateOppty(newLead.Phone + newLead.LastName)))
           )
        )                           
        {
           newLead.Lead_Status__c = 'Open';
           newLead.Why_Unqualified__c = ''; 
        }
        if(!newlead.Auto_Unqualified__c || Trigger.isInsert)
        {
            if(   ((Label.LeadDeDupeMethod == 'Account' || System.Userinfo.getUserName() == 'SunRunTestRunner@testorg.com') && isDuplicateLead(newLead.Street + newLead.City + newLead.State + newLead.PostalCode + newLead.Country))
               || ((Label.LeadDeDupeMethod == 'Account' || System.Userinfo.getUserName() == 'SunRunTestRunner@testorg.com') && isDuplicateLead(newLead.Zip_6__c))
               || (Label.LeadDeDupeMethod == 'Contact' && isDuplicateLead(newLead.Email + newLead.LastName))
               || (Label.LeadDeDupeMethod == 'Contact' && isDuplicateLead(newLead.Phone + newLead.LastName))
              )
            {
              newlead.Lead_Status__c = Label.Lead_Status_Duplicate;
              newlead.Why_Unqualified__c = Label.Lead_Why_Unqualified_DuplicateLeadFound;
            }
            if(   ((Label.LeadDeDupeMethod == 'Account' || System.Userinfo.getUserName() == 'SunRunTestRunner@testorg.com') && isDuplicateOppty(newLead.Street + newLead.City + newLead.State + newLead.PostalCode + newLead.Country))
               || ((Label.LeadDeDupeMethod == 'Account' || System.Userinfo.getUserName() == 'SunRunTestRunner@testorg.com') && isDuplicateOppty(newLead.Zip_6__c))
               || (Label.LeadDeDupeMethod == 'Contact' && isDuplicateOppty(newLead.Email + newLead.LastName))
               || (Label.LeadDeDupeMethod == 'Contact' && isDuplicateOppty(newLead.Phone + newLead.LastName))
              )
            {
               newlead.Lead_Status__c = Label.Lead_Status_Duplicate;
               newlead.Why_Unqualified__c = Label.Lead_Why_Unqualified_DuplicateOpptyFound;
            }
        }        
    }
    
    private Boolean isKeyFieldChanged(Lead newLead)
    {
        //Only add to set if a "key field" has been altered on the lead that is being deduped.
        if(Label.LeadDeDupeMethod == 'Contact')
        {
            if(newLead.LastName != Trigger.oldMap.get(newLead.Id).LastName
               || newLead.Phone != Trigger.oldMap.get(newLead.Id).Phone
               || newLead.Email != Trigger.oldMap.get(newLead.Id).Email)
               {
                   return true;
               }
        }
        if(Label.LeadDeDupeMethod == 'Account' || System.Userinfo.getUserName() == 'SunRunTestRunner@testorg.com')
        {
            if(newLead.Street != Trigger.oldMap.get(newLead.Id).Street
               || newLead.City != Trigger.oldMap.get(newLead.Id).City
               || newLead.State != Trigger.oldMap.get(newLead.Id).State
               || newLead.PostalCode != Trigger.oldMap.get(newLead.Id).PostalCode
               || newLead.Country != Trigger.oldMap.get(newLead.Id).Country
               || newLead.Zip_6__c != Trigger.oldMap.get(newLead.Id).Zip_6__c)                      
               {
                   return true;
               }
        }               
        return false;
    }
    
    //Check to see if a lead exists with the same key
    private Boolean isDuplicateLead(String key)
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
        if(setExistingLeadKey.Contains(key)) 
        {
           return true;
        }
        return false;
    }
    //Check to see if an oppty exists with the same key    
    private Boolean isDuplicateOppty(String key)
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
    
    Contact contobj = PRMContactUtil.getLoginUserAccountAndContact();
    Account accObj = new Account();
    if(contobj != null){
        //accObj = [select id, name from Account where id =: contobj.accountId];
        if(contobj.Account != null){
            for(Lead newlead:Trigger.New){
                if(Trigger.isInsert){
                
                    newlead.Lead_Gen_Partner__c = contobj.Account.Id;
                    //newlead.Install_Partner__c = contobj.Account.Id;
                    //newlead.Sales_Partner__c = contobj.Account.Id;
                }
            }
        }  
    }
    
    for(lead newlead:Trigger.new){

        if(trigger.isInsert || (trigger.isupdate && newlead.Offer_Promo_Code__c != Trigger.oldMap.get(newlead.Id).Offer_Promo_Code__c)){
          List<Promotion__c> promoObjList = [Select id, Promotion_Code__c, Name from Promotion__c where Promotion_Code__c =: newlead.Offer_Promo_Code__c limit 1];

          if(promoObjList != null && promoObjList.size() > 0){
            newlead.Offer_Promo_Name__c = promoObjList[0].id;
          }
          
          if(trigger.isUpdate && newlead.Offer_Promo_Code__c == null){
            newlead.Offer_Promo_Name__c = null;
          } 
        }
    }
    
    //To capture lead information at the time of creation. This Information is used to create "offer" record
     for(Lead newlead:Trigger.New){
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
             newlead.SalesCellPhone__c = contobj.phone;
             newlead.Sales_Rep_Email__c = contobj.email;
             newlead.SalesOrganizationName__c = PCObj.Account__c ;
             newlead.SalesOrgContractExecutionDate__c = PCObj.Effective_Date__c;
             newlead.SalesRep__c = userId;
             newlead.CorporatePartner__c = null;
        }else {
            PCObjlist = [select id, name, contract_type__c, effective_date__c, Contract_Status__c, expiration_Date__c , Account__c,Account__r.Site from Partner_contract__c where Account__c =: newlead.Sales_Partner__c and Contract_Status__c = 'Active' and expiration_date__c > today and Contract_Type__c ='Sales Contract' ];
            system.debug('Partner contract sales' + PCObjlist);
            
            if(PCObjlist.size() > 0 && PCObjlist != null){
                PCObj = PCObjlist[0];
                newlead.SalesCellPhone__c = contobj.phone;
                 newlead.Sales_Rep_Email__c = contobj.email;
                 newlead.SalesOrganizationName__c = PCObj.Account__c ;
                 newlead.SalesOrgContractExecutionDate__c = PCObj.Effective_Date__c;
                 newlead.SalesRep__c = userId;
                 newlead.CorporatePartner__c = null;
            }
        }
      }
     }
    }   
    
    if(Trigger.NewMap != null){
        System.debug('Trigger.NewMap: ' + Trigger.NewMap);
        LeadUtil.calculateMonUsage(Trigger.NewMap) ;
        //System.debug('Trigger.NewMap: ' + Trigger.NewMap);
    }
*/
}